import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_clone/core/extensions/extensions.dart';

void main() {
  group('formatPlays', () {
    test('formats millions with one decimal', () {
      expect(formatPlays(4200000), '4.2M');
    });
    test('removes trailing .0 for exact millions', () {
      expect(formatPlays(1000000), '1M');
    });
    test('formats thousands', () {
      expect(formatPlays(840000), '840K');
    });
    test('formats exact thousands without decimal', () {
      expect(formatPlays(5000), '5K');
    });
    test('returns raw number below 1000', () {
      expect(formatPlays(999), '999');
      expect(formatPlays(0), '0');
    });
  });
}
