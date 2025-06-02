// lib/layout/widgets/custom_timePickerForm.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear la hora

class CustomTimePickerFormField extends StatefulWidget {
  final String labelText;
  final TimeOfDay? initialTime;
  final IconData? prefixIcon;
  final String? helpText;
  final ValueChanged<TimeOfDay?>? onChanged;
  final FormFieldValidator<TimeOfDay?>? validator;

  const CustomTimePickerFormField({
    super.key,
    required this.labelText,
    this.initialTime,
    this.prefixIcon,
    this.helpText,
    this.onChanged,
    this.validator,
  });

  @override
  State<CustomTimePickerFormField> createState() => _CustomTimePickerFormFieldState();
}

class _CustomTimePickerFormFieldState extends State<CustomTimePickerFormField> {
  final TextEditingController _controller = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    if (_selectedTime != null) {
      _controller.text = _formatTimeOfDay(_selectedTime!);
    }
  }

  @override
  void didUpdateWidget(covariant CustomTimePickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTime != oldWidget.initialTime) {
      _selectedTime = widget.initialTime;
      _controller.text = _selectedTime != null ? _formatTimeOfDay(_selectedTime!) : '';
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    // Combinamos la fecha actual con la hora seleccionada para poder usar DateFormat
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    // Formato de 12 horas con AM/PM (ej. 3:30 PM)
    return DateFormat.jm().format(dt);
    // Si prefieres formato de 24 horas, usa: return DateFormat.Hm().format(dt);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: widget.helpText,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _controller.text = _formatTimeOfDay(picked);
      });
      // Llama al callback si está definido
      if (widget.onChanged != null) {
        widget.onChanged!(picked);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true, // Evita que el usuario escriba directamente en el campo
      onTap: () => _selectTime(context), // Abre el selector de hora al tocar
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: const Icon(Icons.access_time), // Icono para indicar que es un selector de hora
      ),
      validator: (value) {
        if (widget.validator != null) {
          // Pasa el TimeOfDay seleccionado al validador
          return widget.validator!(_selectedTime);
        }
        return null;
      },
    );
  }
}