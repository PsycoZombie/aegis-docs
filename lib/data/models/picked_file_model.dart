import 'dart:typed_data';

class PickedFile {
  final Uint8List bytes;
  final String name;
  final String? path;

  PickedFile({required this.bytes, required this.name, this.path});
}
