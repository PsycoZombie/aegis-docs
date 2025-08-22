import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DimensionTextField extends StatelessWidget {
  const DimensionTextField({
    required this.controller, required this.label, super.key,
  });
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'px',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value == null || value.isEmpty) return 'Req';
          if (int.tryParse(value) == null) return 'Inv';
          return null;
        },
      ),
    );
  }
}
