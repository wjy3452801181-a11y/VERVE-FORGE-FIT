import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 手机号输入组件 — 支持中国大陆和香港号码
class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String label;
  final String hint;
  final String countryCode;
  final ValueChanged<String>? onCountryCodeChanged;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.validator,
    this.label = '手机号',
    this.hint = '请输入手机号',
    this.countryCode = '+86',
    this.onCountryCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      validator: validator,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: GestureDetector(
          onTap: () => _showCountryCodePicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  countryCode,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                Container(
                  width: 1,
                  height: 24,
                  margin: const EdgeInsets.only(left: 8),
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCountryCodePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('中国大陆 +86'),
              trailing: countryCode == '+86' ? const Icon(Icons.check) : null,
              onTap: () {
                onCountryCodeChanged?.call('+86');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('香港 +852'),
              trailing: countryCode == '+852' ? const Icon(Icons.check) : null,
              onTap: () {
                onCountryCodeChanged?.call('+852');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
