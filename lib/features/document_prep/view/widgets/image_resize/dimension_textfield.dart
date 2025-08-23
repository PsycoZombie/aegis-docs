import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A specialized text form field for inputting a
/// single dimension (e.g., width or height).
///
/// It is pre-configured for numeric input, includes a "px" suffix, and provides
/// basic validation for non-empty, numeric values.
class DimensionTextField extends StatelessWidget {
  /// Creates an instance of [DimensionTextField].
  const DimensionTextField({
    required this.controller,
    required this.label,
    this.enabled = true,
    super.key,
  });

  /// The controller for the text field.
  final TextEditingController controller;

  /// The label to display for the text field (e.g., "Width" or "Height").
  final String label;

  /// A flag to control whether the text field is enabled for user input.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'px',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: TextInputType.number,
        // Restrict input to digits only.
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value == null || value.isEmpty) return 'Req'; // Required
          if (int.tryParse(value) == null) return 'Inv'; // Invalid
          return null;
        },
      ),
    );
  }
}
