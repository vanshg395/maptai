import 'package:flutter/material.dart';

class ProfileField extends StatefulWidget {
  final String label;
  final String initialData;
  final Function validator;
  final Function onSaved;
  final bool enabled;
  final TextInputType keyboardType;

  ProfileField({
    @required this.label,
    @required this.initialData,
    this.validator,
    this.onSaved,
    this.enabled,
    this.keyboardType,
  });

  @override
  _ProfileFieldState createState() => _ProfileFieldState();
}

class _ProfileFieldState extends State<ProfileField> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.initialData;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.keyboardType,
      controller: controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: Theme.of(context).textTheme.bodyText1,
          border:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          disabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          errorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedErrorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15)),
      style: Theme.of(context).textTheme.bodyText1,
      validator: widget.validator,
      onSaved: widget.onSaved,
    );
  }
}
