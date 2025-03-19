import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recargas_app/views/login_view.dart';
import '../providers/supplier_provider.dart';
import '../providers/recharge_provider.dart';

class RechargeView extends ConsumerStatefulWidget {
  final String supplierHome;
  RechargeView(this.supplierHome, {super.key});

  final TextEditingController controllerCel = TextEditingController();
  final TextEditingController controllerOperator = TextEditingController();
  final TextEditingController controllerPrice = TextEditingController();
  final FocusNode _focusNodeCel = FocusNode();
  final FocusNode _focusNodeOperator = FocusNode();
  final FocusNode _focusNodePrice = FocusNode();

  @override
  _RechargeViewState createState() => _RechargeViewState();
}

class _RechargeViewState extends ConsumerState<RechargeView> {
  String? selectedProviderId;
  @override
  void initState() {
    super.initState();

    if (widget.supplierHome.isNotEmpty) {
      Future.microtask(() {
        final suppliers = ref.read(supplierProvider).value;
        if (suppliers != null) {
          for (var supplier in suppliers) {
            if (widget.supplierHome == supplier["name"]) {
              setState(() {
                widget.controllerOperator.text = supplier["name"]!;
                selectedProviderId = supplier["id"]!;
              });
              break;
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplierAsyncValue = ref.watch(supplierProvider);
    final rechargeState = ref.watch(rechargeProvider);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Selecciona un Proveedor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pinkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.03),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Recarga Celular',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              TextFormFieldCustom(
                width: width,
                hintText: 'ingresa el celular',
                controller: widget.controllerCel,
                focusNode: widget._focusNodeCel,
                colorBorde: Colors.black12,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  supplierAsyncValue.maybeWhen(
                    data: (suppliers) {
                      if (suppliers == null || suppliers.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("No hay proveedores disponibles.")),
                        );
                      } else {
                        showSupplierSelection(context, suppliers);
                      }
                    },
                    orElse: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Cargando proveedores..."))),
                  );
                },
                child: TextFormFieldCustom(
                  width: width,
                  hintText: 'Operador',
                  controller: widget.controllerOperator,
                  focusNode: widget._focusNodeOperator,
                  colorBorde: Colors.black12,
                  enable: false,
                ),
              ),
              const SizedBox(height: 20),
              TextFormFieldCustom(
                width: width,
                hintText: '¿Cuánto?',
                controller: widget.controllerPrice,
                focusNode: widget._focusNodePrice,
                colorBorde: Colors.black12,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text(
                'Cupo disponible',
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.center,
                width: width * 0.3,
                height: height * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: const Text('\$ 300000'),
              ),
              SizedBox(height: height * 0.32,),
              rechargeState.when(
                data: (message) => message != null
                    ? Text(message, style: TextStyle(color: Colors.green))
                    : ButtonCustom(
                        width: width,
                        height: height,
                        ontap: () {
                          _attemptRecharge();
                        },
                        text: 'Realizar recarga',
                        colorButton: Colors.pinkAccent,
                        colorText: Colors.white,
                      ),
                loading: () => Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    Text("Error: $err", style: TextStyle(color: Colors.red)),
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  void _attemptRecharge() {
    final phone = widget.controllerCel.text.trim();
    final amount = double.tryParse(widget.controllerPrice.text.trim()) ?? 0;

    if (phone.length != 10 || !phone.startsWith('3')) {
      _showErrorMessage("Número de teléfono inválido");
      return;
    }

    if (amount < 1000 || amount > 100000) {
      _showErrorMessage("El monto debe estar entre 1,000 y 100,000");
      return;
    }

    if (selectedProviderId == null) {
      _showErrorMessage("Debe seleccionar un operador");
      return;
    }

    ref
        .read(rechargeProvider.notifier)
        .buyRecharge(phone, selectedProviderId!, amount);

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        widget.controllerCel.clear();
        widget.controllerOperator.clear();
        widget.controllerPrice.clear();
        selectedProviderId = null;
      });
    });
  }

  void showSupplierSelection(
      BuildContext context, List<Map<String, String>> suppliers) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: suppliers.length,
          itemBuilder: (context, index) {
            final supplier = suppliers[index];
            return ListTile(
              title: Text(supplier["name"]!),
              onTap: () {
                widget.controllerOperator.text = supplier["name"]!;
                selectedProviderId = supplier["id"]!;
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
