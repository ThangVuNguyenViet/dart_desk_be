import 'dart:typed_data';

import 'package:dart_desk_server/src/services/image_metadata.dart';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';

void main() {
  group('slugifyFilename', () {
    test('lowercases and replaces spaces', () {
      expect(slugifyFilename('My Photo.JPG'), 'my-photo.jpg');
    });

    test('collapses runs of punctuation to a single dash', () {
      expect(slugifyFilename('my__photo (1).png'), 'my-photo-1.png');
    });

    test('preserves the extension', () {
      expect(slugifyFilename('Weird!Name.webp'), 'weird-name.webp');
    });

    test('strips leading and trailing dashes', () {
      expect(slugifyFilename('  hello  .jpg'), 'hello.jpg');
    });

    test('handles missing extension', () {
      expect(slugifyFilename('no ext'), 'no-ext');
    });

    test('replaces diacritics with ascii', () {
      expect(slugifyFilename('café.jpg'), 'cafe.jpg');
    });
  });

  group('extractFromDecodedImage', () {
    Uint8List pngBytes() {
      final image = img.Image(width: 20, height: 10);
      for (var y = 0; y < 10; y++) {
        for (var x = 0; x < 20; x++) {
          image.setPixelRgb(x, y, 10, 200, 50);
        }
      }
      return Uint8List.fromList(img.encodePng(image));
    }

    test('populates all fields from a valid image', () async {
      final bytes = pngBytes();
      final decoded = img.decodeImage(bytes)!;
      final meta = await extractFromDecodedImage(decoded, bytes);
      expect(meta.width, 20);
      expect(meta.height, 10);
      expect(meta.hasAlpha, isFalse);
      expect(meta.blurHash.isNotEmpty, isTrue);
      expect(meta.lqip, startsWith('data:image/jpeg;base64,'));
      expect(meta.paletteJson, contains('dominant'));
    });
  });
}
