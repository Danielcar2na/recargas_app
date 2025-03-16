import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/supplier_provider.dart';

class RechargeView extends ConsumerWidget {
  const RechargeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsyncValue = ref.watch(supplierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Selecciona un Proveedor')),
      body: supplierAsyncValue.when(
        data: (suppliers) {
          if (suppliers == null) return Center(child: Text("No hay proveedores."));
          return ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return ListTile(
                title: Text(supplier["name"]!),
                onTap: () {
                  // Aquí podríamos navegar a la vista de compra
                  print("Proveedor seleccionado: ${supplier["name"]}");
                },
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
