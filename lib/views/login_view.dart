import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recargas_app/providers/auth_providers.dart';
import 'package:recargas_app/routes/paths.dart';
import 'package:recargas_app/views/home_view.dart';
import 'package:recargas_app/views/register_view.dart';

class LoginView extends ConsumerWidget {
  LoginView({super.key});
  final TextEditingController controllerText = TextEditingController();
  final TextEditingController controllerPass = TextEditingController();
  final FocusNode _focusNodeUser = FocusNode();
  final FocusNode _focusNodePass = FocusNode();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeView()),
        );
      }
    });

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.pinkAccent],
              stops: [1, 0.4],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.03),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: height * 0.18),
                  Image.asset(Paths.logoTextPuntoRed),
                  SizedBox(height: height * 0.2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Login',
                      style:
                          TextStyle(fontSize: 30, fontStyle: FontStyle.italic),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  TextFormFieldCustom(
                    width: width,
                    controller: controllerText,
                    focusNode: _focusNodeUser,
                    hintText: 'User',
                  ),
                  SizedBox(height: height * 0.02),
                  TextFormFieldCustom(
                    width: width,
                    controller: controllerPass,
                    focusNode: _focusNodePass,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  SizedBox(height: height * 0.17),
                  if (authState is AsyncError)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        "❌ ${(authState as AsyncError).error}",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ButtonCustom(
                    width: width,
                    height: height,
                    colorText: Colors.pinkAccent,
                    ontap: () {
                      final user = controllerText.text.trim();
                      final pass = controllerPass.text.trim();

                      if (user.isNotEmpty && pass.isNotEmpty) {
                        ref.read(authProvider.notifier).login(user, pass);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Ingrese usuario y contraseña")),
                        );
                      }
                    },
                    text: authState is AsyncLoading ? 'Cargando...' : 'Sign In',
                  ),
                  SizedBox(height: height * 0.01),
                  InkWell(
                    onTap: () {
                      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RegisterView()),
        );
                    },
                      child: Text(
                    'Register',
                    style: TextStyle(fontSize: 16),
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonCustom extends StatelessWidget {
  const ButtonCustom({
    super.key,
    required this.width,
    required this.height,
    required this.ontap,
    required this.text,
    this.colorText = Colors.black,
    this.colorButton = Colors.white,
  });

  final double width;
  final double height;
  final VoidCallback ontap;
  final String text;
  final Color colorText;
  final Color colorButton;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        alignment: Alignment.center,
        width: width,
        height: height * 0.05,
        decoration: BoxDecoration(
          color: colorButton,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(color: colorText),
        ),
      ),
    );
  }
}

class TextFormFieldCustom extends StatelessWidget {
  const TextFormFieldCustom({
    super.key,
    required this.width,
    required this.hintText,
    this.obscureText = false,
    required this.controller,
    required this.focusNode,
    this.colorBorde = Colors.white,
    this.enable = true,
    this.keyboardType = TextInputType.text,
  });

  final double width;
  final TextEditingController controller;
  final String hintText;
  final FocusNode focusNode;
  final bool obscureText;
  final bool enable;
  final Color colorBorde;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorBorde,
          )),
      child: TextFormField(
        enabled: enable,
        focusNode: focusNode,
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black54),
          border: InputBorder.none,
        ),
        obscureText: obscureText,
      ),
    );
  }
}
