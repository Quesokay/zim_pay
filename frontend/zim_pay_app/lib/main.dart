import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/wallet/wallet_bloc.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'repositories/user_repository.dart';
import 'repositories/wallet_repository.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/health_repository.dart';
import 'screens/splash_screen.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';

void main() async {
  // 1. Ensure Flutter's engine is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => UserRepository()),
        RepositoryProvider(create: (context) => WalletRepository()),
        RepositoryProvider(create: (context) => TransactionRepository()),
        RepositoryProvider(create: (context) => HealthRepository()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserBloc(
            context.read<UserRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => WalletBloc(
            walletRepository: context.read<WalletRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => TransactionBloc(
            transactionRepository: context.read<TransactionRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Zim Pay',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF0058BA),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}