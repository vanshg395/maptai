import 'package:flutter/material.dart';

class MultilineDropdownButtonFormField<T> extends FormField<T> {
  MultilineDropdownButtonFormField({
    Key key,
    T value,
    @required List<DropdownMenuItem<T>> items,
    this.onChanged,
    InputDecoration decoration = const InputDecoration(),
    FormFieldSetter<T> onSaved,
    FormFieldValidator<T> validator,
    Widget hint,
    bool isExpanded = false,
    bool isDense = true,
    Widget icon,
    double iconSize,
    Color iconEnabledColor,
    Color iconDisabledColor,
  })  : assert(decoration != null),
        assert(isExpanded != null),
        assert(isDense != null),
        super(
            key: key,
            onSaved: onSaved,
            initialValue: value,
            validator: validator,
            builder: (FormFieldState<T> field) {
              final InputDecoration effectiveDecoration = decoration
                  .applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return InputDecorator(
                decoration:
                    effectiveDecoration.copyWith(errorText: field.errorText),
                isEmpty: value == null,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    icon: icon,
                    iconSize: iconSize,
                    iconEnabledColor: iconEnabledColor,
                    iconDisabledColor: iconDisabledColor,
                    isExpanded: isExpanded,
                    isDense: isDense,
                    value: value,
                    items: items,
                    hint: hint,
                    onChanged: field.didChange,
                  ),
                ),
              );
            });

  final ValueChanged<T> onChanged;
  @override
  FormFieldState<T> createState() =>
      _MultilineDropdownButtonFormFieldState<T>();
}

class _MultilineDropdownButtonFormFieldState<T> extends FormFieldState<T> {
  @override
  MultilineDropdownButtonFormField<T> get widget => super.widget;
  @override
  void didChange(T value) {
    super.didChange(value);
    if (widget.onChanged != null) widget.onChanged(value);
  }
}
