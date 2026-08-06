import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool isLightMode;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.validator,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.isLightMode = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    final bgColor = widget.isLightMode 
        ? Colors.grey.shade50 
        : AppColors.surfaceElevated;
    final textColor = widget.isLightMode 
        ? AppColors.primaryBackground 
        : AppColors.offWhite;
    final hintColor = widget.isLightMode 
        ? Colors.grey.shade400 
        : AppColors.tertiaryNeutral;
    final borderColor = widget.isLightMode
        ? Colors.grey.shade300
        : AppColors.tertiaryNeutral;

    return FormField<String>(
      initialValue: widget.controller?.text,
      validator: (value) {
        final error = widget.validator?.call(widget.controller?.text);
        if (error != null) {
          _triggerShake();
        }
        return error;
      },
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) => Transform.translate(
                offset: Offset(shakeAnimation.value, 0),
                child: child,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: field.hasError ? AppColors.error : (_isFocused ? AppColors.accentCta : borderColor),
                    width: _isFocused || field.hasError ? 2.0 : 1.0,
                  ),
                  color: bgColor,
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  style: TextStyle(color: textColor),
                  onChanged: (val) {
                    field.didChange(val);
                    if (field.hasError) {
                      field.validate();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: widget.label,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(color: hintColor),
                    labelStyle: TextStyle(
                      color: _isFocused ? AppColors.accentCta : hintColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6.0, left: 16.0),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
