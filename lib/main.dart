import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'features/auth/presentation/pages/signIn_page.dart';
import 'features/auth/presentation/pages/signUp_page.dart';
import 'features/home.dart';
import 'injection.dart' as di;
import 'on_generate_route.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => di.sl<AuthCubit>()..appStarted()),
      ],
      child: MaterialApp(
        title: 'Adopt Animals',
        onGenerateRoute: OnGenerateRoute.route,
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          "/" : (context){
            return BlocBuilder<AuthCubit,AuthState>(
              builder: (context,authState){
                if (authState is Authenticated){
                  return HomePage();
                }else{
                  return const LoginPage();
                }
              },
            );
          }
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}


