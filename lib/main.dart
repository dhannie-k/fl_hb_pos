import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hb_pos_inv/data/repositories/purchase_repository_impl.dart';
import 'package:hb_pos_inv/domain/repositories/purchase_repository.dart';
import 'package:hb_pos_inv/presentation/bloc/purchase/purchase_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/constans/app_colors.dart';
import 'presentation/router/app_router.dart';

// Dashboard imports
import 'presentation/bloc/dashboard/dashboard_bloc.dart';
import 'presentation/bloc/dashboard/dashboard_event.dart';
import 'data/repositories/dashboard_repository_impl.dart';
import 'data/datasources/supabase_datasource.dart';
import 'domain/repositories/dashboard_service.dart';

// Category imports
import 'presentation/bloc/category/category_bloc.dart';
import 'data/repositories/category_repository_impl.dart';

import 'presentation/bloc/product/product_bloc.dart';
import 'data/repositories/product_repository_impl.dart';

import 'domain/repositories/product_service.dart';

// Inventory imports
import 'presentation/bloc/inventory/inventory_bloc.dart';
import 'presentation/bloc/inventory/inventory_event.dart';
import 'data/repositories/inventory_repository_impl.dart';

// Auth
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/auth_service/auth_repository.dart';
//import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(App());
}

// A global accessor is fine for Supabase client
final supabase = Supabase.instance.client;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the AuthRepository at the top of the tree
    return RepositoryProvider(
      create: (context) => AuthRepository(supabaseClient: supabase),
      child: BlocProvider(
        create: (context) =>
            AuthBloc(authRepository: context.read<AuthRepository>())
              ..add(AuthAppStarted()), // Check auth status on start
        child: const RootApp(),
      ),
    );
  }
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthBloc, AuthenState>(
        builder: (context, state) {
          if (state is AuthInitial) {
            return const CircularProgressIndicator(); // Show a loading screen while checking auth
          }
          if (state is AuthAuthenticated) {
            // User is logged in, show the main app
            return const MyApp();
          }
          // Any other state (Unauthenticated, Error) defaults to LoginPage
          return const LoginPage();
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create datasource instance
    final supabaseDatasource = SupabaseDatasource();
    //final SupabaseClient client = Supabase.instance.client;
    final productRepository = ProductRepositoryImpl(supabaseDatasource);
    final inventoryRepository = InventoryRepositoryImpl(supabaseDatasource);
    final productService = ProductService(productRepository);

    return MultiRepositoryProvider(
      providers: [
        // You can provide simpler repositories directly
        RepositoryProvider<PurchaseRepository>(
          create: (context) => PurchaseRepositoryImpl(supabase),
        ),
        // Keep providing others as needed
      ],
      // MultiBlocProvider consumes the repositories provided above
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DashboardBloc(
              DashboardService(DashboardRepositoryImpl(supabaseDatasource)),
            )..add(LoadDashboard()),
          ),
          BlocProvider(
            create: (context) =>
                CategoryBloc(CategoryRepositoryImpl(supabaseDatasource)),
          ),
          BlocProvider(
            create: (context) => ProductBloc(productService: productService),
          ),
          BlocProvider(
            create: (context) =>
                InventoryBloc(inventoryRepository)..add(const LoadInventory()),
          ),
          // Add the PurchaseBloc here, it can now find PurchaseRepository
          BlocProvider(
            create: (context) =>
                PurchaseBloc(context.read<PurchaseRepository>()),
          ),
        ],
        child: MaterialApp.router(
          title: 'Hidup Baru POS',
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: AppColors.background,
            cardTheme: CardThemeData(
              elevation: 2,
              shadowColor: AppColors.cardShadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.accent, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.error, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
