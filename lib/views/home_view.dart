import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recargas_app/providers/auth_providers.dart';
import 'package:recargas_app/views/login_view.dart';
import 'recharge_view.dart';

class HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authProvider);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Principal', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: width * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                ButtonCustom(
                    width: width, 
                    height: height, 
                    ontap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RechargeView()),
                      );
                    }, 
                    text: 'Ir a Recargar',
                    colorButton: Colors.pinkAccent,
                    colorText: Colors.white,
                    ),
                    SizedBox(height: height * 0.05,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
