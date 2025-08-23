import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A data model representing a file selected by the user from device storage.
///
/// This class normalizes the data from a
/// file picker into a simple, immutable object.
class PickedFileModel extends Equatable {
  /// Creates an instance of a picked file.
  const PickedFileModel({
    required this.bytes,
    required this.name,
    this.path,
  });

  /// The raw byte data of the file. Null if the file was
  /// picked from a path without being read into memory.
  final Uint8List? bytes;

  /// The name of the file, including its extension.
  final String name;

  /// The original absolute path of the file on the device, if available.
  final String? path;

  @override
  List<Object?> get props => [name, path, bytes];
}
