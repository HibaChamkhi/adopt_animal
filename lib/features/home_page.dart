import 'package:adopt_animal/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/injection.dart' as di;
import 'auth/presentation/cubit/auth/auth_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext _) {
    return BlocProvider(
      create: (_) => di.sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        builder: (profileContext, credentialState) {
          // if (credentialState is lodding) {
          //   return const Center(
          //     child: CircularProgressIndicator(),
          //   );
          // }
          return Scaffold(
            body: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome,",
                    style: TextStyle(fontSize: 50,fontFamily: "Exo2"),
                  ),
                  Text(
                    "Hiba",
                    style: TextStyle(fontSize: 50,fontFamily: "Exo2"),
                  ),
                  Text(
                    "We will help you to find your lovely pet",
                    style: TextStyle(fontSize: 20,fontFamily: "Exo2"),
                  ),
                ],
              ),
            ),
          );
        },
        listener: (context, credentialState) {},
      ),
    );
  }
}
