import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class ImageUtils {
  /// Optimizes an image for OCR processing
  static Future<File> optimizeForOcr(File imageFile,
      {int maxWidth = 1024}) async {
    try {
      // Read the image file
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return imageFile;

      // Calculate new dimensions maintaining aspect ratio
      if (image.width > maxWidth) {
        final scaleFactor = maxWidth / image.width;
        image = img.copyResize(
          image,
          width: maxWidth,
          height: (image.height * scaleFactor).round(),
          interpolation: img.Interpolation.average, // Faster resizing
        );
      }

      // Convert to grayscale and enhance contrast
      image = img.grayscale(image);
      image = img.contrast(image, contrast: 30);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(tempDir.path,
          'optimized_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final optimizedFile = File(tempPath);

      await optimizedFile.writeAsBytes(img.encodeJpg(image, quality: 85));
      return optimizedFile;
    } catch (e) {
      // If any error occurs during optimization, return original file
      return imageFile;
    }
  }

  /// Converts an image to grayscale for better OCR accuracy
  static Future<Uint8List?> convertToGrayscaleBytes(
      Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      final grayscale = img.grayscale(image);
      return Uint8List.fromList(img.encodeJpg(grayscale, quality: 90));
    } catch (e) {
      return null;
    }
  }

  /// Gets a temporary directory for storing processed images
  static Future<Directory> getTemporaryDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final receiptScanDir = Directory(path.join(tempDir.path, 'receipt_scans'));
    if (!await receiptScanDir.exists()) {
      await receiptScanDir.create(recursive: true);
    }
    return receiptScanDir;
  }
}
