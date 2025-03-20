import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
      } else if (next is AsyncError) {
        _showErrorDialog(context, "Error", next.error.toString());
      }
    });

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
       resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          
          InkWell(
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
                      Image.asset(Paths.logoTextPuntoRed),
                      SizedBox(height: height * 0.2),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Registrarse',
                          style: GoogleFonts.roboto(fontSize: 30, fontWeight: FontWeight.w800),
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
          
                      ButtonCustom(
                        width: width,
                        height: height,
                        colorText: Colors.pinkAccent,
                        ontap: () {
                          final user = controllerText.text.trim();
                          final pass = controllerPass.text.trim();
                          final passConfirm = controllerPassConfirm.text.trim();
          
                          if (user.isEmpty || pass.isEmpty || passConfirm.isEmpty) {
                            _showErrorDialog(context, "Campos vacíos", "Todos los campos son obligatorios.");
                            return;
                          }
          
                          if (pass != passConfirm) {
                            _showErrorDialog(context, "Contraseñas incorrectas", "Las contraseñas no coinciden.");
                            return;
                          }
          
                          ref.read(authProvider.notifier).register(user, pass);
                        },
                        text: authState is AsyncLoading ? 'Registrando...' : 'Registrarse',
                      ),
                      SizedBox(height: height * 0.01),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Volver',
                          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w800,),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(width: width,
              height: height * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25), color: Colors.white
              ),
              child: Column(
                children: [
                  SizedBox(height: height * 0.16),
                      Image.asset(Paths.logoTextPuntoRed),

                ],
              ),),
        ],
      ),
    );
  }
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: GoogleFonts.roboto(color: Colors.pinkAccent)),
            ),
          ],
        );
      },
    );
  }
}
