import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:recargas_app/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:recargas_app/database/database_helper.dart';
import 'mocks/api_service_mock.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late ProviderContainer container;
  late DatabaseHelper dbHelper;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    mockApiService = MockApiService();
    container = ProviderContainer();
    dbHelper = DatabaseHelper.instance;

    await dbHelper.registerUser('prueba', '123');
  });

  tearDown(() {
    container.dispose();
  });

  test('Debe retornar un token válido cuando la autenticación es exitosa',
      () async {
    when(mockApiService.authenticate()).thenAnswer((_) async => 'TOKEN123');

    final authNotifier = container.read(authProvider.notifier);
    await authNotifier.login('prueba', '123');

    final authState = container.read(authProvider);

    expect(authState.value?['token'], 'TOKEN123');
  });

  test('Debe manejar error cuando la autenticación falla', () async {
    when(mockApiService.authenticate()).thenAnswer((_) async => null);

    final authNotifier = container.read(authProvider.notifier);
    await authNotifier.login('prueba', '123');

    final authState = container.read(authProvider);

    expect(authState.hasError, true);
  });
}
