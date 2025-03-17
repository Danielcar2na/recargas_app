import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recargas_app/providers/history_provider.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsyncValue = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Historial de Recargas')),
      body: historyAsyncValue.when(
        data: (recharges) {
          if (recharges.isEmpty) {
            return Center(child: Text("No hay recargas almacenadas."));
          }
          return ListView.builder(
            itemCount: recharges.length,
            itemBuilder: (context, index) {
              final recharge = recharges[index];
              return ListTile(
                title: Text("Celular: ${recharge.phoneNumber}"),
                subtitle: Text("Monto: \$${recharge.amount} | Fecha: ${recharge.date}"),
                trailing: Text(recharge.provider),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
