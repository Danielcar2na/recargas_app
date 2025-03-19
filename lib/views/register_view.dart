import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recargas_app/providers/auth_providers.dart';
import 'package:recargas_app/routes/paths.dart';
import 'package:recargas_app/views/home_view.dart';
import 'package:recargas_app/views/login_view.dart';

class RegisterView extends ConsumerWidget {
  RegisterView({super.key});
  final TextEditingController controllerText = TextEditingController();
  final TextEditingController controllerPass = TextEditingController();
  final TextEditingController controllerPassConfirm = TextEditingController();
  final FocusNode _focusNodeUser = FocusNode();
  final FocusNode _focusNodePass = FocusNode();
  final FocusNode _focusNodePassConfirm = FocusNode();

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.18),
                  Image.asset(Paths.logoTextPuntoRed), // Ajusta tu logo
                  SizedBox(height: height * 0.2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Registrarse',
                      style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic),
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
                  SizedBox(height: height * 0.02),
                  TextFormFieldCustom(
                    width: width,
                    controller: controllerPassConfirm,
                    focusNode: _focusNodePassConfirm,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                  SizedBox(height: height * 0.1),

                  if (authState is AsyncError)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
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
                      final passConfirm = controllerPassConfirm.text.trim();

                      if (user.isEmpty || pass.isEmpty || passConfirm.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Todos los campos son obligatorios")),
                        );
                        return;
                      }

                      if (pass != passConfirm) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Las contraseñas no coinciden")),
                        );
                        return;
                      }

                      ref.read(authProvider.notifier).register(user, pass);
                    },
                    text: authState is AsyncLoading ? 'Registrando...' : 'Registrarse',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
