import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/encryption/database_key_store.dart';

void main() {
  group('DatabaseKeyStore', () {
    late FlutterSecureStorage storage;
    late DatabaseKeyStore store;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      storage = const FlutterSecureStorage();
      store = DatabaseKeyStore(storage);
    });

    test('has no key before one is created', () async {
      expect(await store.read(), isNull);
    });

    test('creates a 256-bit key as 64 hex characters', () async {
      final String key = await store.create();

      expect(key, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('reads back the key it created', () async {
      final String key = await store.create();

      expect(await store.read(), key);
    });

    test('creates a different key each time', () async {
      final String first = await store.create();
      final String second = await store.create();

      expect(second, isNot(first));
    });

    test('pads small bytes so the key is always full length', () async {
      final DatabaseKeyStore zeros = DatabaseKeyStore(
        storage,
        random: _ConstantRandom(0),
      );

      expect(await zeros.create(), '0' * 64);
    });

    test('treats a malformed stored value as missing', () async {
      await storage.write(
        key: DatabaseKeyStore.storageKey,
        value: 'not-a-key',
      );

      expect(await store.read(), isNull);
    });

    test('treats a platform failure to read storage as no key', () async {
      final DatabaseKeyStore broken = DatabaseKeyStore(_BrokenStorage());

      expect(await broken.read(), isNull);
    });
  });
}

class _ConstantRandom implements Random {
  _ConstantRandom(this._value);

  final int _value;

  @override
  int nextInt(int max) => _value;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

class _BrokenStorage implements FlutterSecureStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw PlatformException(code: 'keystore');
  }
}
