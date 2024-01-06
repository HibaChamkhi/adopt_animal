
import 'package:adopt_animal/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/container_button.dart';
import '../../../../core/text_field_container.dart';
import '../../../../core/toast.dart';
import '../../domain/entities/user_entity.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        builder: (context, credentialState) {
          if (credentialState is CredentialLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (credentialState is CredentialSuccess) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is Authenticated) {
                  return Container(child: Text("successs"),);
                } else {
                  return _bodyWidget();
                }
              },
            );
          }


          return _bodyWidget();
        },
        listener: (context, credentialState) {
          if (credentialState is CredentialSuccess) {
            BlocProvider.of<AuthCubit>(context).loggedIn();
          }
          if (credentialState is CredentialFailure) {
            toast("wrong email please check");
            ///SnackBar
          }
        },
      ),
    );
  }
  Widget _bodyWidget(){
    return  SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 22,vertical: 32),
        child: Column(
          children: [
            SizedBox(height: 15,),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Registration",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                  color: bermudaGray,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              thickness: 1,
            ),
            SizedBox(height: 10,),

            TextFieldContainer(
              prefixIcon: Icons.person,
              controller: _usernameController,
              hintText: "username",
            ),
            SizedBox(height: 20,),
            TextFieldContainer(
              prefixIcon: Icons.email,
              controller: _emailController,
              hintText: "Email",
            ),
            SizedBox(height: 20,),
            Divider(
              thickness: 2,
              indent: 120,
              endIndent: 120,
            ),
            SizedBox(height: 20,),
            TextFieldContainer(
              prefixIcon: Icons.lock,
              controller: _passwordController,
              hintText: "Password",
              isObscureText: true,
            ),
            SizedBox(height: 20,),
            TextFieldContainer(
              prefixIcon: Icons.lock,
              controller: _passwordAgainController,
              hintText: "Password (Again)",
              isObscureText: true,
            ),

            SizedBox(height: 20,),
            ContainerButton(
              onTap: (){
                _submitSignUp();
              },
              title: "Sign Up",
            ),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Text(
                  "Do you have already an account?",
                  style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                  onTap: (){
                    //Navigator.pushNamedAndRemoveUntil(context, "/registration", (route) => false);
                  //  Navigator.pushNamedAndRemoveUntil(context, PageConst.loginPage,(routes) => false);
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: bermudaGray),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'By clicking register, you agree to the Privacy Policy',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: rockBlue),
                ),

              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'and terms of use',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: rockBlue),
                ),
              ],
            ),
            Container(
             // padding: EdgeInsets.only(bottom: 30) ,
                child: Image.asset("assets/animals.png")
            )
            
          ],
        ),
      ),
    );
  }


  void _submitSignUp(){


    if (_usernameController.text.isEmpty){
      toast("Enter username");
      return;
    }

    if (_emailController.text.isEmpty){
      toast("Enter email");
      return;
    }

    if (_passwordController.text.isEmpty){
      toast("Enter password");
      return;
    }

    if (_passwordAgainController.text.isEmpty){
      toast("Enter again password");
      return;
    }

    if (_passwordController.text != _passwordAgainController.text){
      toast("both password must be same");
      return;
    }


    BlocProvider.of<AuthCubit>(context).signUpSubmit(user: UserEntity(
      name: _usernameController.text,
      profileUrl: "",
      status: "",
      email: _emailController.text,
      password: _passwordController.text,
    ));
  }
}