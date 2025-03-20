import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recargas_app/models/recharge_model.dart';
import 'package:recargas_app/providers/history_provider.dart';
import 'package:recargas_app/providers/supplier_provider.dart';
import 'package:recargas_app/routes/paths.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsyncValue = ref.watch(historyProvider);
    final suppliersAsyncValue = ref.watch(supplierProvider);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final Map<String, String> providerImages = {
      "Claro": Paths.claro,
      "Movistar": Paths.movistar,
      "Tigo": Paths.tigo,
      "wom": Paths.wom,
      "Desconocido": '',
    };

    return Scaffold(
      appBar: AppBar(
        title:  Text('Historial de Recargas',
            style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.pinkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
      padding: EdgeInsets.only(top: height * 0.015),
        child: historyAsyncValue.when(
          data: (recharges) {
            if (recharges.isEmpty) {
              return Center(child: Text("No hay recargas almacenadas."));
            }
        
            return suppliersAsyncValue.when(
              data: (suppliers) {
                return ListView.builder(
                  itemCount: recharges.length,
                  itemBuilder: (context, index) {
                    final recharge = recharges[index];
        
                    final providerName = suppliers?.firstWhere(
                      (supplier) => supplier["id"] == recharge.provider,
                      orElse: () => {"name": "Desconocido"},
                    )["name"];
        
                    final providerImage = providerImages[providerName] ?? '';
        
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          title: Text("Celular: ${recharge.phoneNumber}"),
                          subtitle: Text(
                              "Monto: \$${recharge.amount}\nFecha: ${recharge.date}"),
                          leading: Image.asset(
                            providerImage,
                            width: width * 0.15,
                            height: height * 0.1,
                            fit: BoxFit.contain,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditDialog(
                                    context, ref, recharge, suppliers ?? []),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => ref
                                    .read(historyProvider.notifier)
                                    .deleteRecharge(recharge.id!),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text("Error cargando proveedores: $err")),
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text("Error cargando historial: $err")),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Recharge recharge,
      List<Map<String, String>> suppliers) {
    final TextEditingController phoneController =
        TextEditingController(text: recharge.phoneNumber);
    final TextEditingController amountController =
        TextEditingController(text: recharge.amount.toString());

    String selectedProviderId = recharge.provider;
    String selectedProviderName = suppliers.firstWhere(
      (supplier) => supplier["id"] == recharge.provider,
      orElse: () => {"name": "Desconocido"},
    )["name"]!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar Recarga"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: "Número de Celular")),
              TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: "Monto"),
                  keyboardType: TextInputType.number),
              DropdownButtonFormField<String>(
                value: selectedProviderId,
                items: suppliers.map((supplier) {
                  return DropdownMenuItem(
                    value: supplier["id"],
                    child: Text(supplier["name"]!),
                  );
                }).toList(),
                onChanged: (newValue) {
                  selectedProviderId = newValue!;
                  selectedProviderName = suppliers.firstWhere(
                    (supplier) => supplier["id"] == newValue,
                    orElse: () => {"name": "Desconocido"},
                  )["name"]!;
                },
                decoration: InputDecoration(labelText: "Operador"),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar", style: GoogleFonts.roboto(color: Colors.pinkAccent),)),
            ElevatedButton(
              onPressed: () {
                final updatedRecharge = Recharge(
                  id: recharge.id,
                  userId: recharge.userId,
                  phoneNumber: phoneController.text.trim(),
                  provider: selectedProviderId,
                  amount: double.tryParse(amountController.text.trim()) ??
                      recharge.amount,
                  date: recharge.date,
                );

                ref
                    .read(historyProvider.notifier)
                    .updateRecharge(updatedRecharge);
                Navigator.pop(context);
              },
              child: Text("Guardar", style: GoogleFonts.roboto(color: Colors.pinkAccent),),
            ),
          ],
        );
      },
    );
  }
}
