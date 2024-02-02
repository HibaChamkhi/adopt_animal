import 'package:adopt_animal/features/auth/presentation/pages/signIn_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bottom_nav_bar.dart';
import '../cubit/auth/auth_cubit.dart';
import '/injection.dart' as di;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _logoVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _logoVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => di.sl<AuthCubit>()..appStarted(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              print("Authenticated");
              Future.delayed(const Duration(seconds: 4), () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const BottomNavBarPage(),
                  ),
                );
              });
            } else {
              print("not Authenticated");
              Future.delayed(const Duration(seconds: 4), () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              });
            }
          },
          builder: (BuildContext context, AuthState state) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: _logoVisible ? 1.0 : 0.0,
                    child: Image.asset('assets/logo.png'),
                  ),
                  // if (state.isLoading)
                  //   Container(
                  //     // margin: EdgeInsets.only(top: 20.0.h),
                  //     child: const Center(
                  //       child: CircularProgressIndicator(
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   )
                ],
              ),
            );
            // }
          },
        ),
      ),
    );
  }
}
