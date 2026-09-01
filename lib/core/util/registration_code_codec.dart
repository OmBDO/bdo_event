import 'dart:convert';

class RegistrationCodeCodec {
  static const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  static String encode({required String eventId, required String token}) {
    final bytes = utf8.encode('$eventId|$token');
    var buffer = 0;
    var bits = 0;
    final output = StringBuffer('BDO2');
    for (final byte in bytes) {
      buffer = (buffer << 8) | byte;
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        output.write(_alphabet[(buffer >> bits) & 31]);
      }
    }
    if (bits > 0) output.write(_alphabet[(buffer << (5 - bits)) & 31]);
    return output.toString();
  }

  static Map<String, String>? decode(String value) {
    final normalized = value.toUpperCase();
    if (!normalized.startsWith('BDO2')) return null;
    final encoded = normalized.substring(4);
    if (encoded.isEmpty) return null;
    var buffer = 0;
    var bits = 0;
    final bytes = <int>[];
    for (final character in encoded.split('')) {
      final digit = _alphabet.indexOf(character);
      if (digit < 0) return null;
      buffer = (buffer << 5) | digit;
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        bytes.add((buffer >> bits) & 255);
      }
    }
    try {
      final decoded = utf8.decode(bytes);
      final separator = decoded.lastIndexOf('|');
      if (separator <= 0 || separator == decoded.length - 1) return null;
      return {
        'eventId': decoded.substring(0, separator),
        'token': decoded.substring(separator + 1),
      };
    } on FormatException {
      return null;
    }
  }
}
