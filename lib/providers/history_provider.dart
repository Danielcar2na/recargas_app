import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recargas_app/database/database_helper.dart';
import 'package:recargas_app/models/recharge_model.dart';



final historyProvider = FutureProvider<List<Recharge>>((ref) async {
  return DatabaseHelper.instance.getAllRecharges();
});
