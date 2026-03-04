import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/kyc_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/tarjetas/tarjetas_screen.dart';
import 'features/credito/credito_screen.dart';
import 'features/perfil/perfil_screen.dart';
import 'features/servicios/servicios_screen.dart';
import 'features/servicios/pago_flow_screen.dart';
import 'features/transferencias/transferencia_screen.dart';
import 'features/adelanto/adelanto_screen.dart';
import 'features/credito/credito_flow_screen.dart';
import 'features/credito/credito_pago_screen.dart';
import 'features/credito/credit_product_model.dart';
import 'features/movimientos/movimientos_screen.dart';
import 'features/estados_cuenta/estados_cuenta_screen.dart';
import 'shared/widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/kyc',
      builder: (context, state) => const KycScreen(),
    ),
    GoRoute(
      path: '/transferir',
      builder: (context, state) => const TransferenciaScreen(),
    ),
    GoRoute(
      path: '/adelanto',
      builder: (context, state) => const AdelantoScreen(),
    ),
    GoRoute(
      path: '/credito/disponer',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final productId = extra['productId'] as String? ?? 'nomina';
        final product = creditProducts.firstWhere(
          (p) => p.id == productId,
          orElse: () => creditProducts[1],
        );
        return CreditoFlowScreen(
          product: product,
          initialAmount: (extra['amount'] as num?)?.toDouble() ?? product.minAmount,
          initialPlazo: (extra['plazo'] as num?)?.toInt() ?? product.minPlazo,
        );
      },
    ),
    GoRoute(
      path: '/credito/pagar',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final productId = extra['productId'] as String? ?? 'nomina';
        final product = creditProducts.firstWhere(
          (p) => p.id == productId,
          orElse: () => creditProducts[1],
        );
        return CreditoPagoScreen(product: product);
      },
    ),
    GoRoute(
      path: '/servicios',
      builder: (context, state) => const ServiciosScreen(),
    ),
    GoRoute(
      path: '/servicios/pago',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return PagoFlowScreen(
          companyId: extra['companyId'] ?? '',
          companyName: extra['companyName'] ?? '',
          categoryId: extra['categoryId'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/movimientos',
      builder: (context, state) => const MovimientosScreen(),
    ),
    GoRoute(
      path: '/estados-cuenta',
      builder: (context, state) => const EstadosCuentaScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/tarjetas',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TarjetasScreen(),
          ),
        ),
        GoRoute(
          path: '/credito',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CreditoScreen(),
          ),
        ),
        GoRoute(
          path: '/perfil',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PerfilScreen(),
          ),
        ),
      ],
    ),
  ],
);
