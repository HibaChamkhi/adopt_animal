
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'core/const/page_const.dart';
import 'features/auth/presentation/pages/signUp_page.dart';

class OnGenerateRoute{


  static Route<dynamic> route(RouteSettings settings){

    final args = settings.arguments;

    switch(settings.name){
      case PageConst.registrationPage :{
        return materialPageBuilder(widget: const SignUpPage());
      }
      default:
        return materialPageBuilder(widget: const ErrorPage());
    }

  }




}

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("error"),
      ),
      body: const Center(
        child: Text("error"),
      ),
    );
  }
}



MaterialPageRoute materialPageBuilder({required Widget widget}){
  return MaterialPageRoute(builder: (_) =>widget);
}