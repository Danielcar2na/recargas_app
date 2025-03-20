import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
      Operator(Paths.wom, 'wom'),
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
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final List<Operator> operatorList = operators['operators'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Facturas y recargas',
          style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.pinkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.02),
             Text(
              'Operadores',
              textAlign: TextAlign.start,
              style: GoogleFonts.roboto(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: height * 0.02),
            SizedBox(
              height: height * 0.12,
              width: width,
              child: ListView.builder(
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                itemCount: operatorList.length,
                itemBuilder: (context, index) {
                  final operator = operatorList[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RechargeView(operator.name),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.02),
                        child: Image.asset(
                          operator.imagePath,
                          width: width * 0.18,
                          height: height * 0.09,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: height * 0.02),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(left: width * 0.8),
              child: FloatingActionButton(
                backgroundColor: Colors.pinkAccent,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryView()),
                  );
                },
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: height * 0.05),
            ButtonCustom(
              key: ValueKey('irRecarga'),
              width: width,
              height: height,
              ontap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RechargeView('')),
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

  // 🔹 Confirmación antes de cerrar sesión
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cerrar sesión"),
          content: const Text("¿Seguro que quieres cerrar sesión?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: GoogleFonts.roboto(color: Colors.pinkAccent),),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginView()),
                  (route) => false,
                );
              },
              child:  Text("Cerrar sesión", style: GoogleFonts.roboto(color: Colors.pinkAccent),),
            ),
          ],
        );
      },
    );
  }
}
