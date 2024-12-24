import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.isPassword = false,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.controller,
    this.keyboardType,
    this.maxLength,
    this.focusNode,
    this.contentPadding,
    this.textInputAction,
    this.suffixIcon,String? initialValue,
  });

  final String labelText;
  final String hintText;
  final bool isPassword;
  final int? maxLength;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final EdgeInsets? contentPadding;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.red,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: widget.contentPadding ??
              const EdgeInsets.fromLTRB(8, 12, 8, 12),
          child: TextFormField(
            style: const TextStyle(fontFamily: 'NexaRegular'),
            keyboardType: widget.keyboardType,
            controller: widget.controller,
            maxLength: widget.maxLength,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            obscureText: widget.isPassword ? _isObscure : false,
            validator: widget.validator,
            focusNode: widget.focusNode,
            decoration: InputDecoration(
              counterText: "",
              prefixIcon: widget.prefixIcon,
              labelText: widget.labelText,
              hintText: widget.hintText,
              border: InputBorder.none,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.red, width: 2.0),
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    )
                  : widget.suffixIcon,
            ),
          ),
        ),
      ),
    );
  }
}
