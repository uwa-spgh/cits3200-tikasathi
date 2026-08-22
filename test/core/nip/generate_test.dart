import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/nip/generate.dart';

void main() {
  test('generate throws UnimplementedError', () {
    expect(
      () => generate(DateTime(2000, 4, 15), DateTime(2026, 8, 22), []),
      throwsA(isA<UnimplementedError>()),
    );
  });
}
