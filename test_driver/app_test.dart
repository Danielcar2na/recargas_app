import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('probando app', () {
    final ingresarUsuario = find.byValueKey('ingresarUsuario');
    final ingresarContrasena = find.byValueKey('ingresarContrasena');
    final iniciarSesionButton = find.byValueKey('iniciarSesion');
    final ingresaCelular = find.byValueKey('ingresaCelular');
    final seleccionaOperador = find.byValueKey('seleccionaOperador');
    final valor = find.byValueKey('valor');
    final botonRecarga = find.byValueKey('botonRecarga');
    final irRecarga = find.byValueKey('irRecarga');

    late final FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      driver.close();
    });

    test('Verificar app', () async {
      await driver.waitFor(ingresarUsuario);
      await driver.waitFor(ingresarContrasena);
      await driver.waitFor(iniciarSesionButton);

      await driver.tap(ingresarUsuario);
      await driver.enterText('prueba');
      await driver.tap(ingresarContrasena);
      await driver.enterText('123');

      await driver.tap(iniciarSesionButton);

      await driver.waitFor(irRecarga);

      await driver.tap(irRecarga);
      await driver.waitFor(ingresaCelular);
      await driver.waitFor(seleccionaOperador);
      await driver.waitFor(valor);
      await driver.waitFor(botonRecarga);

      await driver.tap(ingresaCelular);
      await driver.enterText('3111234567');

      await driver.tap(seleccionaOperador);
      await driver.tap(find.text('Claro'));

      await driver.tap(valor);
      await driver.enterText('5000');

      await driver.tap(botonRecarga);

      await driver.waitFor(find.text('✅ Recarga exitosa'));
    });
  });
}
