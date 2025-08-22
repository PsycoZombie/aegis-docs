import 'dart:typed_data';

class PickedFile {

  PickedFile({required this.bytes, required this.name, this.path});
  final Uint8List bytes;
  final String name;
  final String? path;
}
