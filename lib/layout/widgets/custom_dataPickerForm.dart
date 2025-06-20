// lib/layout/widgets/date_picker_form_field.dart
import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_colors.dart'; // Asegúrate de importar tus colores

class DatePickerFormField extends StatefulWidget {
  final String labelText;
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime?>? onChanged; // Callback para cuando la fecha cambia
  final FormFieldValidator<String>? validator; // Validador del campo de texto
  final IconData? prefixIcon;
  final String? helpText;
  final String? cancelText;
  final String? confirmText;

  const DatePickerFormField({
    super.key,
    required this.labelText,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.helpText,
    this.cancelText,
    this.confirmText,
  });

  @override
  State<DatePickerFormField> createState() => _DatePickerFormFieldState();
}

class _DatePickerFormFieldState extends State<DatePickerFormField> {
  DateTime? _selectedDate; // Estado interno para la fecha seleccionada
  final TextEditingController _controller = TextEditingController(); // Controlador para el TextFormField

  @override
  void initState() {
    super.initState();
    // Si no hay fecha inicial, usa la fecha de hoy
    _selectedDate = widget.initialDate ?? DateTime.now();
    _updateTextController();
  }

  @override
  void didUpdateWidget(covariant DatePickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      _selectedDate = widget.initialDate ?? DateTime.now();
      _updateTextController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Actualiza el texto del controlador cuando la fecha cambia
  void _updateTextController() {
    if (_selectedDate != null) {
      _controller.text = '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
    } else {
      _controller.text = ''; // Vacío si no hay fecha seleccionada
    }
  }

  // Lógica para mostrar el selector de fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? widget.initialDate ?? DateTime.now(),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      helpText: widget.helpText,
      cancelText: widget.cancelText,
      confirmText: widget.confirmText,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textTitle,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateTextController(); // Actualiza el texto visible
      });
      widget.onChanged?.call(_selectedDate); // Llama al callback si se proporciona
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        // AbsorbPointer evita que el TextFormField reciba toques directos
        // y permite que el GestureDetector maneje el onTap.
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.labelText, // Usa el labelText pasado por parámetro
            border: const OutlineInputBorder(),
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          readOnly: true, // El usuario no puede escribir en el campo
          validator: widget.validator, // Pasa el validador
        ),
      ),
    );
  }
}