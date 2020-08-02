import 'package:flutter/material.dart';

class CommonField extends StatelessWidget {
  final String placeholder;
  final Color bgColor;
  final Color borderColor;
  final double borderRadius;
  final String fontFamily;
  final double fontSize;
  final bool isPassword;
  final Widget suffixIcon;
  final TextAlign textAlign;
  final Function onPressed;
  final bool readOnly;
  final double width;
  final Function validator;
  final Function onSaved;
  final Function onChanged;
  final TextInputType keyboardType;
  final int maxLines;
  final int maxLength;
  final double topPadding;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function onFieldSubmitted;
  final String initialValue;

  CommonField({
    @required this.placeholder,
    @required this.borderColor,
    @required this.bgColor,
    this.fontFamily,
    this.borderRadius = 0,
    this.fontSize = 18,
    this.isPassword = false,
    this.suffixIcon,
    this.textAlign = TextAlign.left,
    this.onPressed,
    this.readOnly = false,
    this.width = double.infinity,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.topPadding = 0,
    this.controller,
    this.focusNode,
    this.onFieldSubmitted,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: TextFormField(
        readOnly: readOnly,
        initialValue: initialValue,
        obscureText: isPassword,
        maxLength: maxLength,
        textAlign: textAlign,
        onTap: onPressed,
        controller: controller,
        decoration: InputDecoration(
          fillColor: bgColor,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              width: 0,
              color: borderColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              width: 0,
              color: borderColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              width: 0,
              color: borderColor,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              width: 0,
              color: borderColor,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              width: 0,
              color: borderColor,
            ),
          ),
          errorStyle: TextStyle(color: Colors.red[200]),
          alignLabelWithHint: true,
          hintText: placeholder,
          hintStyle: TextStyle(
            color: Colors.grey,
            fontFamily: fontFamily,
            fontWeight: FontWeight.w300,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(end: 15, start: 10),
            child: suffixIcon,
          ),
          suffixStyle: TextStyle(fontSize: 16),
          contentPadding: EdgeInsets.only(
            left: 30,
            top: topPadding,
          ),
        ),
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmitted,
        style: TextStyle(
          color: Theme.of(context).cardColor,
          fontFamily: fontFamily,
          fontSize: fontSize,
        ),
        maxLines: maxLines,
        onSaved: onSaved,
        onChanged: onChanged,
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }
}
