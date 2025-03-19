import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recargas_app/models/recharge_model.dart';
import 'package:recargas_app/providers/history_provider.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsyncValue = ref.watch(historyProvider);
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Recargas', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: historyAsyncValue.when(
        data: (recharges) {
          if (recharges.isEmpty) {
            return Center(child: Text("No hay recargas almacenadas."));
          }

          return ListView.builder(
            itemCount: recharges.length,
            itemBuilder: (context, index) {
              final recharge = recharges[index];

              return Padding(
                padding:  EdgeInsets.symmetric(horizontal: width * 0.02),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    title: Text("Celular: ${recharge.phoneNumber}"),
                    subtitle: Text("Monto: \$${recharge.amount}\nFecha: ${recharge.date}\n ${recharge.provider}", style: TextStyle(letterSpacing: -width * 0.0015 ),),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditDialog(context, ref, recharge),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => ref.read(historyProvider.notifier).deleteRecharge(recharge.id!),
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
        error: (err, stack) => Center(child: Text("Error cargando historial: $err")),
      ),
    );
  }

  // 🔹 Función para mostrar el formulario de edición
  void _showEditDialog(BuildContext context, WidgetRef ref, Recharge recharge) {
    final TextEditingController phoneController = TextEditingController(text: recharge.phoneNumber);
    final TextEditingController amountController = TextEditingController(text: recharge.amount.toString());
    final TextEditingController providerController = TextEditingController(text: recharge.provider);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar Recarga"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: phoneController, decoration: InputDecoration(labelText: "Número de Celular")),
              TextField(controller: providerController, decoration: InputDecoration(labelText: "Operador")),
              TextField(controller: amountController, decoration: InputDecoration(labelText: "Monto"), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                final updatedRecharge = Recharge(
                  id: recharge.id,
                  userId: recharge.userId,
                  phoneNumber: phoneController.text.trim(),
                  provider: providerController.text.trim(),
                  amount: double.tryParse(amountController.text.trim()) ?? recharge.amount,
                  date: recharge.date,
                );

                ref.read(historyProvider.notifier).updateRecharge(updatedRecharge);
                Navigator.pop(context);
              },
              child: Text("Guardar"),
            ),
          ],
        );
      },
    );
  }
}
