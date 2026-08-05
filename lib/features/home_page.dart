import 'package:flutter/material.dart';
import '/injection.dart' as di;
import 'auth/domain/entities/user_entity.dart';
import 'auth/domain/useCases/get_current_user_use_case.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<UserEntity> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = di.sl<GetCurrentUserUseCase>().call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: FutureBuilder<UserEntity>(
          future: _userFuture,
          builder: (context, snapshot) {
            String name;
            if (snapshot.connectionState == ConnectionState.waiting) {
              name = "";
            } else if (snapshot.hasData &&
                (snapshot.data!.name?.trim().isNotEmpty ?? false)) {
              name = snapshot.data!.name!;
            } else {
              name = "there";
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome,",
                  style: TextStyle(fontSize: 50, fontFamily: "Exo2"),
                ),
                Text(
                  name,
                  style: const TextStyle(fontSize: 50, fontFamily: "Exo2"),
                ),
                const Text(
                  "We will help you to find your lovely pet",
                  style: TextStyle(fontSize: 20, fontFamily: "Exo2"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
