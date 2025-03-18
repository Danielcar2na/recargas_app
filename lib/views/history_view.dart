import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recargas_app/providers/history_provider.dart';
import 'package:recargas_app/providers/supplier_provider.dart';
import 'package:recargas_app/database/database_helper.dart';
import 'package:recargas_app/models/recharge_model.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsyncValue = ref.watch(historyProvider);
    final suppliersAsyncValue = ref.watch(supplierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de recargas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: historyAsyncValue.when(
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

                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 1),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        title: Row(
                          children: [
                            Text("Celular: ${recharge.phoneNumber}"),
                            Spacer(),
                            Text(providerName!, style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                                "Monto: \$${recharge.amount}\nFecha: ${recharge.date}"),
                            Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Botón Editar
                                Flexible(
                                  child: IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () =>
                                        _editRecharge(context, ref, recharge),
                                  ),
                                ),

                                // Botón Eliminar
                                Flexible(
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDelete(
                                        context, ref, recharge.id!),
                                  ),
                                ),
                              ],
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
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  void _editRecharge(BuildContext context, WidgetRef ref, Recharge recharge) {
    final TextEditingController amountController =
        TextEditingController(text: recharge.amount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar Recarga"),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Nuevo Monto"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newAmount = double.tryParse(amountController.text);
                if (newAmount != null &&
                    newAmount >= 1000 &&
                    newAmount <= 100000) {
                  final updatedRecharge = Recharge(
                    id: recharge.id,
                    phoneNumber: recharge.phoneNumber,
                    provider: recharge.provider,
                    amount: newAmount,
                    date: recharge.date,
                  );
                  await DatabaseHelper.instance.updateRecharge(updatedRecharge);
                  ref.invalidate(historyProvider); // Refrescar historial
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Ingrese un monto válido")),
                  );
                }
              },
              child: Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int rechargeId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Eliminar Recarga"),
          content: Text("¿Estás seguro de que deseas eliminar esta recarga?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                await DatabaseHelper.instance.deleteRecharge(rechargeId);
                ref.invalidate(historyProvider); // Refrescar historial
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }
}
