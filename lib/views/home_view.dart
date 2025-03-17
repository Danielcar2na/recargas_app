import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recargas_app/models/operator_model.dart';
import 'package:recargas_app/providers/auth_providers.dart';
import 'package:recargas_app/routes/paths.dart';
import 'package:recargas_app/views/history_view.dart';
import 'package:recargas_app/views/login_view.dart';
import 'recharge_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  late PageController _pageController;

  final Map<String, List<Operator>> operators = {
    'operators': [
      Operator(Paths.claro, 'Claro'),
      Operator(Paths.movistar, 'Movistar'),
      Operator(Paths.tigo, 'Tigo'),
      Operator(Paths.wom, 'Wom'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(authProvider);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final List<Operator> operatorList = operators['operators'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Celulares y paquetes',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.02),
            const Text(
              'Facturas y recargas',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: height * 0.02),
            SizedBox(
              height: height * 0.12,
              width: width, // Ajusta el tamaño del ListView
              child: ListView.builder(
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                itemCount: operatorList.length,
                itemBuilder: (context, index) {
                  final operator = operatorList[index];
                  return GestureDetector(
                    onTap: () {
                      print('Seleccionaste: ${operator.name}');
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.02),
                        child: Image.asset(operator.imagePath,
                            width: width * 0.18, height: height * 0.09),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: height * 0.02),
            const Spacer(),
            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HistoryView()),
    );
  },
  child: Text('Ver Historial'),
),
            ButtonCustom(
              width: width,
              height: height,
              ontap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RechargeView()),
                );
              },
              text: 'Ir a Recargar',
              colorButton: Colors.pinkAccent,
              colorText: Colors.white,
            ),
            SizedBox(height: height * 0.05),
          ],
        ),
      ),
    );
  }
}
