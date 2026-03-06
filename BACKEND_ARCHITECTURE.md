# SAYO — Arquitectura Backend Requerida

Documento tecnico que detalla todos los servicios, endpoints, base de datos,
integraciones y componentes que el backend necesita para llevar la app a produccion.

---

## Diagrama General

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         CLIENTES                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                  │
│  │ App Flutter   │  │ Portal Web   │  │ Mesa Control │                  │
│  │ (iOS/Android) │  │ (Next.js)    │  │ (Next.js)    │                  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                  │
└─────────┼─────────────────┼─────────────────┼──────────────────────────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       API GATEWAY (Kong / AWS API GW)                   │
│  • Rate limiting  • JWT validation  • CORS  • Request logging          │
└─────────────────────────┬───────────────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
┌────────────────┐ ┌─────────────┐ ┌──────────────┐
│  Auth Service  │ │  Core API   │ │  Admin API   │
│  (NestJS)      │ │  (NestJS)   │ │  (NestJS)    │
│                │ │             │ │              │
│ • Login/Signup │ │ • Wallet    │ │ • Users mgmt │
│ • JWT tokens   │ │ • Txns      │ │ • Credits    │
│ • 2FA/OTP      │ │ • Credits   │ │ • KYC review │
│ • Sessions     │ │ • Transfers │ │ • Collections│
│                │ │ • Services  │ │ • Reports    │
└───────┬────────┘ │ • Cards     │ │ • Config     │
        │          └──────┬──────┘ └──────┬───────┘
        │                 │               │
        ▼                 ▼               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        MESSAGE BROKER (RabbitMQ / SQS)                  │
│  Colas: txn.created, credit.applied, kyc.completed, alert.triggered    │
└─────────────────────────┬───────────────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
┌────────────────┐ ┌─────────────┐ ┌──────────────┐
│ Notifications  │ │  AI Engine  │ │  SPEI Worker │
│ Service        │ │  Service    │ │  (Processor) │
│                │ │             │ │              │
│ • Push (FCM)   │ │ • Scoring   │ │ • Enviar     │
│ • SMS (Twilio) │ │ • Predict   │ │ • Recibir    │
│ • Email (SES)  │ │ • Insights  │ │ • Conciliar  │
│ • In-app       │ │ • Chat LLM  │ │ • Webhook    │
└────────────────┘ └─────────────┘ └──────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      INTEGRACIONES EXTERNAS                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐    │
│  │  JAAK    │ │  TAPI    │ │  STP /   │ │  Claude  │ │  Auth0   │    │
│  │  (KYC)   │ │  (Pagos) │ │  PoliPay │ │  AI(LLM) │ │  (Auth)  │    │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        BASE DE DATOS                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                  │
│  │ PostgreSQL   │  │ Redis        │  │ S3 / Minio   │                  │
│  │ (principal)  │  │ (cache/sess) │  │ (archivos)   │                  │
│  │ 17 tablas    │  │ • Tokens     │  │ • KYC docs   │                  │
│  │              │  │ • Sessions   │  │ • PDFs       │                  │
│  │              │  │ • Rate limit │  │ • Recibos    │                  │
│  └──────────────┘  └──────────────┘  └──────────────┘                  │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Esquema de Base de Datos (17 tablas)

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ESQUEMA RELACIONAL                           │
│                                                                     │
│  ┌──────────────┐         ┌──────────────────┐                      │
│  │    users     │────1:N──│   transactions   │                      │
│  │──────────────│         │──────────────────│                      │
│  │ id (PK)      │         │ id (PK)          │                      │
│  │ email        │         │ user_id (FK)     │                      │
│  │ password_hash│         │ title            │                      │
│  │ full_name    │         │ amount           │                      │
│  │ phone        │         │ is_income        │                      │
│  │ clabe        │         │ type             │                      │
│  │ balance      │         │ reference        │                      │
│  │ credit_limit │         │ date             │                      │
│  │ credit_used  │         └──────────────────┘                      │
│  │ kyc_level    │                                                   │
│  │ status       │         ┌──────────────────┐                      │
│  │ created_at   │────1:N──│ credit_assignments│                     │
│  │ last_activity│         │──────────────────│                      │
│  └──────┬───────┘         │ id (PK)          │                      │
│         │                 │ user_id (FK)     │                      │
│         │                 │ product_type     │                      │
│         │                 │ assigned_limit   │──1:N──┐              │
│         │                 │ used_amount      │       │              │
│         │                 │ interest_rate    │  ┌────▼─────────┐    │
│         │                 │ plazo_months     │  │credit_payments│   │
│         │                 │ status           │  │──────────────│    │
│         │                 └──────────────────┘  │ id (PK)      │    │
│         │                                       │ credit_id(FK)│    │
│         │                 ┌──────────────────┐  │ due_date     │    │
│         ├────1:N──────────│   transfers      │  │ capital      │    │
│         │                 │──────────────────│  │ interest     │    │
│         │                 │ id (PK)          │  │ total        │    │
│         │                 │ user_id (FK)     │  │ paid (bool)  │    │
│         │                 │ recipient_clabe  │  └──────────────┘    │
│         │                 │ recipient_name   │                      │
│         │                 │ amount           │  ┌──────────────┐    │
│         │                 │ concept          │  │ kyc_sessions │    │
│         │                 │ status           │  │──────────────│    │
│         │                 └──────────────────┘  │ id (PK)      │    │
│         │                                       │ user_id (FK) │    │
│         ├────1:N────────────────────────────────│ provider_id  │    │
│         │                                       │ status       │    │
│         │                 ┌──────────────────┐  │ results JSON │    │
│         ├────1:N──────────│  payment_orders  │  └──────────────┘    │
│         │                 │──────────────────│                      │
│         │                 │ id (PK)          │  ┌──────────────┐    │
│         │                 │ user_id (FK)     │  │   cards      │    │
│         │                 │ provider_order_id│  │──────────────│    │
│         │                 │ amount           │  │ id (PK)      │    │
│         │                 │ service_id       │  │ user_id (FK) │    │
│         ├────1:N──────────│ status           │  │ type         │    │
│         │                 └──────────────────┘  │ last4        │    │
│         │                                       │ status       │    │
│         └────1:N────────────────────────────────│ is_locked    │    │
│                                                 └──────────────┘    │
│                                                                     │
│  TABLAS ADICIONALES:                                                │
│  ┌───────────────────┐ ┌──────────────────┐ ┌──────────────────┐   │
│  │credit_applications│ │  admin_accounts  │ │   audit_logs     │   │
│  │ spei_participants │ │  notifications   │ │   ai_scores      │   │
│  │ service_companies │ │  alert_rules     │ │   sessions       │   │
│  └───────────────────┘ └──────────────────┘ └──────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Endpoints API — Inventario Completo (63 endpoints)

### TIER 1 — MVP Critico (12 endpoints)

Estos son bloqueantes. Sin ellos la app no funciona.

```
AUTH
──────────────────────────────────────────────────────────
POST   /auth/register          Crear cuenta nueva
POST   /auth/login             Autenticacion email/password
POST   /auth/refresh           Renovar JWT token
POST   /auth/logout            Cerrar sesion
GET    /auth/profile           Obtener perfil del usuario
PUT    /auth/profile           Actualizar perfil

WALLET
──────────────────────────────────────────────────────────
GET    /wallet/balance         Saldo actual + credito disponible

TRANSACCIONES
──────────────────────────────────────────────────────────
GET    /transactions           Historial (paginado, filtros)
GET    /transactions/:id       Detalle de transaccion

TRANSFERENCIAS SPEI
──────────────────────────────────────────────────────────
GET    /transfers/banks        Catalogo SPEI (80+ bancos)
POST   /transfers/validate     Validar CLABE destino
POST   /transfers              Enviar transferencia SPEI
```

### TIER 2 — Funcionalidad Core (18 endpoints)

Necesarios para el flujo completo de credito y KYC.

```
KYC (via JAAK)
──────────────────────────────────────────────────────────
POST   /kyc/session            Crear sesion KYC
POST   /kyc/document/verify    Verificar INE/IFE
POST   /kyc/document/extract   OCR datos personales
POST   /kyc/blacklist/check    Consultar listas negras
POST   /kyc/liveness           Prueba de vida
POST   /kyc/face-match         Comparacion facial 1:1
POST   /kyc/session/finish     Cerrar sesion KYC

CREDITOS
──────────────────────────────────────────────────────────
GET    /credits                Lista productos con uso activo
GET    /credits/:id            Detalle de credito activo
GET    /credits/:id/payments   Tabla de amortizacion
POST   /credits/:id/apply      Solicitar disposicion
POST   /credits/:id/pay        Realizar pago de credito

TARJETAS
──────────────────────────────────────────────────────────
GET    /cards                  Lista tarjetas del usuario
POST   /cards/:id/lock         Bloquear tarjeta
POST   /cards/:id/unlock       Desbloquear tarjeta
GET    /cards/:id/cvv          CVV temporal (30 seg TTL)
POST   /cards/:id/wallet       Vincular Apple/Google Pay
```

### TIER 3 — Servicios y Admin (21 endpoints)

Pagos de servicios, panel admin, reportes.

```
PAGO DE SERVICIOS (via TAPI)
──────────────────────────────────────────────────────────
GET    /services               Categorias de servicios
GET    /services/:categoryId   Empresas por categoria
POST   /services/query         Consultar adeudo
POST   /services/pay           Pagar servicio
GET    /services/status/:id    Estado de pago

ADMIN — USUARIOS
──────────────────────────────────────────────────────────
GET    /admin/summary          KPIs del portafolio
GET    /admin/users            Lista usuarios (paginado)
GET    /admin/users/:id        Detalle usuario completo
POST   /admin/users/:id/suspend   Suspender wallet
POST   /admin/users/:id/reactivate Reactivar wallet

ADMIN — CREDITOS
──────────────────────────────────────────────────────────
GET    /admin/credits          Creditos activos (filtros)
POST   /admin/credits/assign   Asignar credito a usuario
PUT    /admin/credits/:id/limit Modificar limite
GET    /admin/dispositions     Disposiciones pendientes
POST   /admin/dispositions/:id/approve  Aprobar disposicion
POST   /admin/dispositions/:id/reject   Rechazar disposicion

ADMIN — KYC
──────────────────────────────────────────────────────────
GET    /admin/kyc/pending      Cola de verificacion
POST   /admin/kyc/:id/approve  Aprobar KYC
POST   /admin/kyc/:id/reject   Rechazar KYC
```

### TIER 4 — IA, Notificaciones, Avanzado (12 endpoints)

Motor de inteligencia artificial y operaciones avanzadas.

```
IA / SCORING
──────────────────────────────────────────────────────────
GET    /ai/credit-scores       Scores de todo el portafolio
GET    /ai/credit-scores/:uid  Score individual con factores
GET    /ai/delinquency         Predicciones de morosidad
GET    /ai/insights/:uid       Insights financieros del usuario
GET    /ai/recommendations/:uid Recomendaciones de productos
GET    /ai/alerts              Alertas inteligentes del portafolio
POST   /ai/chat                Chat con SAYO AI (LLM)

ADMIN — OPERACIONES
──────────────────────────────────────────────────────────
GET    /admin/collections      Cuentas morosas
POST   /admin/collections/:id/plan  Crear plan de pagos
GET    /admin/conciliation     Conciliacion SPEI diaria
GET    /admin/reports          Reportes del portafolio

NOTIFICACIONES
──────────────────────────────────────────────────────────
POST   /notifications/send     Enviar notificacion (SMS/Email/Push)
```

---

## Integraciones Externas (5)

### 1. JAAK — KYC / Verificacion de Identidad

```
Estado:       Integrado en codigo (jaak_service.dart)
Sandbox:      https://sandbox.api.jaak.ai
Produccion:   https://services.api.jaak.ai
Auth:         Bearer token (API key)

Servicios usados:
  • Verificacion de documentos (INE/IFE frente y vuelta)
  • Extraccion OCR (nombre, CURP, direccion, fecha nacimiento)
  • Listas negras (RENAPO, OFAC, Interpol, INE)
  • Prueba de vida (liveness detection)
  • Comparacion facial 1:1 (one-to-one)

Pendiente:
  ✗ Configurar API key de produccion
  ✗ Webhook para notificacion de resultados
  ✗ Almacenar imagenes en S3 (no base64 en memoria)
```

### 2. TAPI — Pago de Servicios

```
Estado:       Integrado en codigo (tapi_service.dart)
Base URL:     https://api.tapi.la
Auth:         Bearer token (API key)

Servicios usados:
  • Consulta de categorias y empresas
  • Consulta de adeudo por referencia
  • Creacion de orden de pago
  • Consulta de estado de pago

Pendiente:
  ✗ Configurar API key de produccion
  ✗ Webhook de confirmacion de pago
  ✗ Manejo de errores y reintentos
```

### 3. STP / PoliPay — Transferencias SPEI

```
Estado:       No integrado (mock data)
Necesario:    Procesador SPEI para envio/recepcion

Requiere:
  ✗ Contrato con STP o PoliPay
  ✗ Cuenta concentradora
  ✗ Certificados digitales (.key, .cer)
  ✗ Webhook para SPEI entrantes
  ✗ Worker de conciliacion diaria
  ✗ Manejo de devoluciones
```

### 4. Claude AI — Motor de IA / Chat

```
Estado:       Logica local en ai_engine.dart (reglas, no ML real)
API:          https://api.anthropic.com

Requiere:
  ✗ API key de Anthropic (Claude)
  ✗ Servicio proxy para no exponer key en cliente
  ✗ System prompts para contexto financiero SAYO
  ✗ Limites de tokens por usuario/dia
  ✗ Historial de conversaciones en DB
```

### 5. Auth0 — Autenticacion (opcional)

```
Estado:       No integrado (login es mock)
Alternativa:  JWT propio con NestJS

Si se usa Auth0:
  ✗ Tenant de produccion
  ✗ Social login (Google, Apple)
  ✗ MFA / OTP por SMS
  ✗ Reglas de autorizacion por rol
```

---

## Datos Mock que necesitan Backend Real

Todo lo siguiente esta hardcodeado y debe migrar a base de datos:

### mock_data.dart → Tabla `users` + `transactions`

```
MockUser (1 usuario demo)
├── balance: $47,520.83          → GET /wallet/balance
├── creditLimit: $150,000        → GET /credits
├── creditUsed: $42,000          → GET /credits
├── clabe: 646180204800012345    → generada al crear cuenta
└── kycLevel: Nivel 3            → resultado de KYC

mockTransactions (7 txns)        → GET /transactions
mockTransactionsExtended (25)    → GET /transactions?extended
mockPayments (12 meses)          → GET /credits/:id/payments

MockNomina                       → GET /employment (integracion nomina)
MockEmployment                   → GET /employment
quickActions (4 acciones)        → Constante en cliente (no necesita backend)
```

### admin_mock_data.dart → Tablas `users` + `credit_assignments` + `alerts`

```
mockAdminUsers (8 usuarios)      → GET /admin/users
mockCreditAssignments (8)        → GET /admin/credits
mockAdminAlerts (5)              → GET /admin/alerts (reglas en backend)
AdminSummary (computado)         → GET /admin/summary (agregaciones SQL)
```

### credit_product_model.dart → Tabla `credit_products` o Config

```
4 productos crediticios          → GET /credits (o config admin)
├── Adelanto de Nomina (12%)
├── Credito Nomina (15%)
├── Credito Simple (18%)
└── Credito Revolvente (22%)
```

### spei_participants.dart → Tabla `spei_participants` o constante

```
80+ bancos/instituciones         → GET /transfers/banks
├── Bancos: BANAMEX, BBVA, SANTANDER, HSBC, BANORTE...
├── Fintech: Nu, Klar, albo, Mercado Pago...
└── STP, SPEI indirecto
```

### Datos hardcodeados en pantallas

```
admin_kyc_screen.dart            → 5 solicitudes KYC mock
admin_collections_screen.dart    → cuentas morosas mock
admin_dispositions_screen.dart   → 5 disposiciones mock
admin_cards_ops_screen.dart      → 7 tarjetas + 3 alertas fraude mock
admin_conciliation_screen.dart   → 8 movimientos SPEI mock
admin_config_screen.dart         → configuracion del sistema mock
qr_screen.dart                   → QR generado local (sin CoDi real)
marketplace_screen.dart          → 8 recompensas + 4 partners mock
main_shell.dart                  → 4 respuestas AI hardcodeadas
```

---

## Plan de Implementacion por Fases

### FASE 1 — Fundamentos (4-6 semanas)

```
Infraestructura:
  □ PostgreSQL + Redis + S3
  □ NestJS API con TypeORM
  □ Docker compose para desarrollo
  □ CI/CD pipeline basico

Auth & Usuarios:
  □ POST /auth/register (con validacion email/phone)
  □ POST /auth/login (JWT access + refresh tokens)
  □ GET /auth/profile
  □ PUT /auth/profile
  □ Middleware de autenticacion JWT
  □ Roles: user, admin, super_admin

Wallet & Transacciones:
  □ Tabla users con balance
  □ Tabla transactions con triggers de balance
  □ GET /wallet/balance
  □ GET /transactions (paginado + filtros)
  □ GET /transactions/:id

Conectar Flutter:
  □ Reemplazar MockUser por llamada API
  □ Reemplazar mockTransactions por llamada API
  □ Token storage (flutter_secure_storage)
  □ Interceptor HTTP para JWT refresh
```

### FASE 2 — Operaciones Financieras (4-6 semanas)

```
SPEI / Transferencias:
  □ Contrato STP o PoliPay
  □ POST /transfers (enviar SPEI)
  □ Webhook SPEI entrantes
  □ Worker de conciliacion
  □ GET /transfers/banks (catalogo)

KYC:
  □ Proxy a JAAK API (no exponer key en cliente)
  □ POST /kyc/session
  □ Almacenar documentos en S3
  □ Webhook de resultados
  □ Actualizar kyc_level automaticamente

Creditos:
  □ Tabla credit_products (configurable)
  □ Tabla credit_assignments
  □ Tabla credit_payments (amortizacion)
  □ POST /credits/:id/apply
  □ POST /credits/:id/pay
  □ Logica de calculo de intereses
```

### FASE 3 — Admin & Servicios (3-4 semanas)

```
Admin Panel Backend:
  □ GET /admin/summary (agregaciones)
  □ GET /admin/users (paginado + busqueda)
  □ CRUD de creditos admin
  □ Flujo de aprobacion de disposiciones
  □ Revision de KYC
  □ Conciliacion SPEI

Pago de Servicios:
  □ Proxy a TAPI API
  □ POST /services/query
  □ POST /services/pay
  □ Recibos de pago

Tarjetas:
  □ Integracion emisor de tarjetas (TAPI o similar)
  □ Bloqueo/desbloqueo
  □ CVV temporal
  □ Vinculacion Apple/Google Pay (tokenizacion)
```

### FASE 4 — IA & Avanzado (3-4 semanas)

```
Motor de IA:
  □ Migrar ai_engine.dart a servicio backend
  □ Credit scoring con datos reales
  □ Prediccion de morosidad (modelo ML)
  □ Categorizacion de gastos con NLP
  □ Generacion de insights

Chat SAYO AI:
  □ Integracion Claude API
  □ System prompt con contexto financiero
  □ Acceso a datos del usuario en tiempo real
  □ Historial de conversaciones
  □ Rate limiting por usuario

Notificaciones:
  □ Push (Firebase Cloud Messaging)
  □ SMS (Twilio)
  □ Email (Amazon SES)
  □ In-app notifications

QR / CoDi:
  □ Integracion con sistema CoDi de Banxico
  □ Generacion de QR con datos reales
  □ Lectura y procesamiento de pagos

Marketplace:
  □ Backend de puntos SAYO
  □ Catalogo de recompensas
  □ Integracion con partners
  □ Canje y fulfillment
```

---

## Stack Tecnologico Recomendado

```
Backend Framework:    NestJS (TypeScript)
Base de Datos:        PostgreSQL 16
Cache / Sesiones:     Redis 7
Object Storage:       AWS S3 / MinIO
Message Broker:       RabbitMQ / AWS SQS
Auth:                 JWT propio o Auth0
AI/LLM:              Claude API (Anthropic)
KYC:                  JAAK API
Pagos Servicios:      TAPI API
SPEI:                 STP / PoliPay
Push Notifications:   Firebase Cloud Messaging
SMS:                  Twilio
Email:                Amazon SES
Monitoreo:            Datadog / Grafana
CI/CD:                GitHub Actions
Infraestructura:      AWS (ECS/Fargate) o Railway
CDN:                  CloudFront
```

---

## Seguridad — Checklist Produccion

```
Autenticacion:
  □ JWT con expiracion corta (15 min) + refresh token (7 dias)
  □ Bcrypt para passwords (salt rounds >= 12)
  □ Rate limiting en login (5 intentos / 15 min)
  □ OTP/2FA para operaciones sensibles

Datos:
  □ Encriptacion en transito (TLS 1.3)
  □ Encriptacion en reposo (AES-256)
  □ PII encriptado en DB (CLABE, CURP, RFC)
  □ No guardar CVV ni datos completos de tarjeta

API:
  □ CORS configurado por dominio
  □ Validacion de input (class-validator)
  □ SQL injection prevention (ORM parametrizado)
  □ Rate limiting por endpoint
  □ Request signing para operaciones financieras

Compliance:
  □ PLD/FT (Prevencion de Lavado de Dinero)
  □ CNBV regulacion SOFOM
  □ Ley Federal de Proteccion de Datos Personales
  □ Logs de auditoria inmutables
  □ Retencion de datos segun regulacion
```

---

## Resumen Ejecutivo

| Metrica | Cantidad |
|---------|----------|
| Endpoints totales requeridos | 63 |
| Tablas de base de datos | 17 |
| Integraciones externas | 5 (JAAK, TAPI, STP, Claude, FCM) |
| Datos mock a migrar | 100+ instancias en 12 archivos |
| Fases de implementacion | 4 (14-20 semanas) |
| Servicios backend | 6 (Auth, Core, Admin, AI, SPEI Worker, Notifications) |

---

*SAYO by SOLVENDOM SOFOM E.N.R. — Backend Architecture v1.0*
