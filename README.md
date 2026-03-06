# SAYO App Demo V1

**Demo funcional de la app fintech SAYO** por SOLVENDOM SOFOM E.N.R.

Wallet digital, creditos, transferencias SPEI, tarjetas virtuales/fisicas, pagos QR/CoDi, marketplace de puntos, motor de IA para scoring crediticio, y mesa de control administrativa completa.

---

## Metricas del Proyecto

| Metrica | Valor |
|---------|-------|
| Archivos Dart | 52 |
| Lineas de codigo | ~23,100 |
| Rutas (GoRouter) | 32 |
| Pantallas usuario | 19 |
| Pantallas admin | 13 |
| Modulos de features | 15 |
| Placeholders pendientes | 0 |

---

## Stack Tecnologico

- **Framework:** Flutter 3.x + Dart
- **Navegacion:** GoRouter (ShellRoute + rutas independientes)
- **Tipografia:** Google Fonts — Urbanist
- **Tema:** Material 3 con paleta SAYO (cafe, beige, cream, green, blue, orange, purple)
- **Estado:** StatefulWidget + StatefulBuilder (modales locales)
- **Datos:** Mock data local (listo para integracion con backend)

---

## Arquitectura

```
lib/
├── main.dart                          # Entry point
├── app_router.dart                    # 32 rutas GoRouter
├── core/
│   ├── theme/
│   │   ├── sayo_colors.dart           # Tokens de color
│   │   └── sayo_theme.dart            # Material 3 theme
│   ├── config/
│   │   └── api_config.dart            # Config API
│   ├── models/
│   │   ├── jaak_models.dart           # Modelos JAAK (KYC)
│   │   └── tapi_models.dart           # Modelos TAPI (tarjetas)
│   ├── services/
│   │   ├── ai_engine.dart             # Motor IA (~600 lineas)
│   │   ├── api_client.dart            # HTTP client
│   │   ├── csv_service.dart           # Exportar CSV
│   │   ├── pdf_service.dart           # Generar PDF
│   │   ├── jaak_service.dart          # Servicio KYC
│   │   ├── tapi_service.dart          # Servicio tarjetas
│   │   └── web_download.dart          # Descargas web
│   └── utils/
│       └── formatters.dart            # Formateo moneda/fecha/CLABE
├── shared/
│   ├── data/
│   │   ├── mock_data.dart             # Datos mock usuario
│   │   └── spei_participants.dart     # Catalogo bancos SPEI
│   └── widgets/
│       └── main_shell.dart            # Bottom nav + SAYO AI chat
└── features/
    ├── onboarding/                    # Pantalla bienvenida
    ├── auth/                          # Login, registro, KYC
    ├── dashboard/                     # Home principal
    ├── tarjetas/                      # Tarjetas virtual/fisica
    ├── credito/                       # 4 productos crediticios
    ├── transferencias/                # SPEI con auto-deteccion banco
    ├── adelanto/                      # Adelanto de nomina (4 pasos)
    ├── servicios/                     # Pago de servicios
    ├── movimientos/                   # Historial transacciones
    ├── estados_cuenta/                # PDF/CSV estados de cuenta
    ├── qr/                            # QR/CoDi cobrar y pagar
    ├── marketplace/                   # SAYO Points y recompensas
    ├── insights/                      # Insights financieros IA
    ├── perfil/                        # Perfil usuario
    └── admin/                         # Mesa de control (13 pantallas)
```

---

## Pantallas de Usuario (19)

| # | Pantalla | Ruta | Descripcion |
|---|----------|------|-------------|
| 1 | Onboarding | `/onboarding` | Bienvenida con carrusel de features |
| 2 | Login | `/login` | Autenticacion email/password |
| 3 | Registro | `/register` | Alta de cuenta nueva |
| 4 | KYC | `/kyc` | Verificacion de identidad (niveles 0-3) |
| 5 | Dashboard | `/dashboard` | Saldo, acciones rapidas, movimientos |
| 6 | Tarjetas | `/tarjetas` | Virtual + fisica, CVV temporal, bloqueo, Apple/Google Pay |
| 7 | Credito | `/credito` | 4 productos: nomina, adelanto, simple, revolvente |
| 8 | Disponer Credito | `/credito/disponer` | Flujo completo de disposicion |
| 9 | Pagar Credito | `/credito/pagar` | Pago parcial/total de credito |
| 10 | Perfil | `/perfil` | Datos personales, seguridad, config |
| 11 | Transferir | `/transferir` | SPEI con catalogo de bancos |
| 12 | Adelanto | `/adelanto` | Adelanto de nomina en 4 pasos |
| 13 | Servicios | `/servicios` | Pago de servicios (luz, tel, etc) |
| 14 | Pago Flow | `/servicios/pago` | Flujo de pago de servicio |
| 15 | Movimientos | `/movimientos` | Historial con filtros |
| 16 | Estados de Cuenta | `/estados-cuenta` | Descarga PDF/CSV |
| 17 | QR / CoDi | `/qr` | Cobrar y pagar con QR |
| 18 | Marketplace | `/marketplace` | SAYO Points, recompensas, partners |
| 19 | Insights IA | `/insights` | Analisis financiero con IA |

---

## Mesa de Control — Admin (13)

| # | Pantalla | Ruta | Descripcion |
|---|----------|------|-------------|
| 1 | Dashboard Admin | `/admin` | KPIs, alertas, navegacion a modulos |
| 2 | Wallets | `/admin/wallets` | Listado de 812 wallets, busqueda |
| 3 | Wallet Detail | `/admin/wallets/detail` | Detalle, asignar credito, modificar limite, suspender |
| 4 | Creditos | `/admin/creditos` | Creditos activos, enviar aviso, plan de pagos |
| 5 | KYC | `/admin/kyc` | Cola de verificacion, aprobar/rechazar documentos |
| 6 | Cobranza | `/admin/cobranza` | Cuentas morosas, planes de pago |
| 7 | Reportes | `/admin/reportes` | Metricas de portafolio, distribucion, KPIs |
| 8 | Movimientos Usuario | `/admin/movimientos` | Historial per-user con filtros |
| 9 | AI Risk | `/admin/ai-risk` | Scoring crediticio, alertas IA, predicciones |
| 10 | Disposiciones | `/admin/disposiciones` | Autorizacion de disposiciones de credito |
| 11 | Tarjetas Ops | `/admin/tarjetas-ops` | Operaciones tarjetas, fraude, emision |
| 12 | Conciliacion | `/admin/conciliacion` | Conciliacion diaria SPEI |
| 13 | Configuracion | `/admin/config` | Tasas, limites, toggles IA, notificaciones |

---

## Motor de IA (ai_engine.dart)

| Funcion | Descripcion |
|---------|-------------|
| `calculateCreditScore()` | Score 300-850 con 5 factores ponderados (historial pago 35%, utilizacion 30%, antiguedad 15%, KYC 10%, saldo 10%) |
| `predictDelinquencies()` | Probabilidad de morosidad a 30 dias por usuario |
| `categorizeSpending()` | Clasificacion automatica de transacciones por categoria |
| `generateInsights()` | Tasa de ahorro, DTI, deteccion de suscripciones, regularidad de ingresos |
| `forecastNextMonth()` | Proyeccion ingreso/gasto con promedio movil |
| `recommendProducts()` | Match score por producto crediticio segun perfil |
| `generateSmartAlerts()` | Alertas de riesgo, utilizacion, liquidez, inactividad |

---

## SAYO AI Assistant

Asistente conversacional integrado en el bottom nav (boton central). Responde consultas sobre:
- Analisis de gastos
- Resumen financiero
- Simulacion de creditos
- Recordatorios de pago

---

## Productos Crediticios

| Producto | Tasa | Monto | Plazo |
|----------|------|-------|-------|
| Credito Nomina | 15% anual | $5,000 - $150,000 | 6-36 meses |
| Adelanto de Nomina | 12% anual | $1,000 - $25,000 | 1-3 meses |
| Credito Simple | 18% anual | $10,000 - $500,000 | 12-48 meses |
| Credito Revolvente | 22% anual | $5,000 - $100,000 | Renovable |

---

## Mock Data

**Usuario demo:** Jose Ignacio Benito
- Saldo: $47,520.83
- CLABE: 646180204800012345
- Limite credito: $150,000
- KYC: Nivel 3

**Admin mock:** 8 usuarios, 8 creditos asignados, 5 alertas operativas

---

## Como Ejecutar

```bash
flutter pub get
flutter run
```

Ruta inicial: `/onboarding` → `/login` → `/dashboard`

Acceso admin: desde Perfil → "Mesa de Control" o directamente `/admin`

---

## Historial de Desarrollo

| Commit | Descripcion |
|--------|-------------|
| `feat: SAYO App Demo V1` | App base: onboarding, auth, dashboard, tarjetas, credito, perfil |
| `feat: complete SPEI participants` | Catalogo bancos SPEI con auto-deteccion |
| `feat: complete credit section` | 4 productos crediticios con flujos completos |
| `feat: add Adelanto de Nomina` | Flujo de 4 pasos para adelanto |
| `feat: add movimientos & estados de cuenta` | Historial + descarga PDF/CSV |
| `feat: add admin control panel` | Mesa de control con wallets y creditos |
| `feat: robustify admin panel` | KYC, cobranza, reportes, acciones funcionales |
| `feat: add AI engine` | Motor IA: scoring, prediccion, insights, recomendaciones |
| `feat: add blueprint gap-fill screens` | Disposiciones, tarjetas ops, conciliacion, config, QR, marketplace |
| `fix: replace last Proximamente` | Cero placeholders pendientes en el proyecto |

---

*SAYO by SOLVENDOM SOFOM E.N.R. — Demo V1*
