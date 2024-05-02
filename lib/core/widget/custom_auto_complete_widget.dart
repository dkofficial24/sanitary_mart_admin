import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CustomAutoCompleteWidget<T> extends StatefulWidget {
  const CustomAutoCompleteWidget(
      {super.key, required this.label,
      required this.options,
      required this.initailValue,
      required this.onSuggestionSelected,
      this.onEditComplete,
      this.validatorError,
      this.hintText,
      this.errorText,
      this.readOnly = true,
      this.enabled = true});

  final T? initailValue;
  final List<T> options;
  final SuggestionSelectionCallback<T?> onSuggestionSelected;
  final Function(String)? onEditComplete;
  final String? validatorError;
  final String? hintText;
  final String? errorText;
  final String label;
  final bool readOnly;
  final bool enabled;

  @override
  State<CustomAutoCompleteWidget<T>> createState() =>
      _CustomAutoCompleteWidgetState<T>();
}

class _CustomAutoCompleteWidgetState<T>
    extends State<CustomAutoCompleteWidget<T>> {
  TextEditingController controller = TextEditingController();
  final suggestionBoxController = SuggestionsBoxController();

  String? selectedValue;

  @override
  void initState() {
    setInitialValue(widget.initailValue?.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField<T>(
      autoFlipDirection: true,enabled: true,
      direction: AxisDirection.down,
      suggestionsBoxController: suggestionBoxController,
      suggestionsBoxDecoration:
          SuggestionsBoxDecoration(borderRadius: BorderRadius.circular(8)),
      textFieldConfiguration: textFieldConfiguration(),
      noItemsFoundBuilder: noItemFoundBuilder,
      itemBuilder: itemBuilder,
      suggestionsCallback: (String value) {
        if (value.trim().isEmpty) {
          return widget.options;
        }
        return widget.options.where((element) =>
            element.toString().toLowerCase().contains(value.toLowerCase()));
      },
      onSuggestionSelected: onItemSelected,
    );
  }

  Widget itemBuilder(context, T suggestion) {
      final inputText = controller.text.toLowerCase();
      final selectedIndex = suggestion.toString().toLowerCase();

      var startIndex = 0;
      var endIndex = suggestion.toString().length;

      if (selectedIndex.isNotEmpty) {
        startIndex = suggestion.toString().toLowerCase().indexOf(inputText);
        endIndex = startIndex + inputText.length;
      }

      if (startIndex == -1) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(''),
        );
      }

      const boldTextStyle = TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      );

      const normalTextStyle = TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black);

      final textWidgets = <InlineSpan>[
        TextSpan(
            text: suggestion.toString().substring(0, startIndex),
            style: normalTextStyle),
        TextSpan(
            text: suggestion.toString().substring(startIndex, endIndex),
            style: boldTextStyle),
        TextSpan(
            text: suggestion.toString().substring(endIndex),
            style: normalTextStyle)
      ];

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: textWidgets,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
            //if(suggestion.toString() == selectedValue)
          ],
        ),
      );
    }

  Widget noItemFoundBuilder(context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Text(
          'No Item found',
          textAlign: TextAlign.center,
          style:
              TextStyle(color: Theme.of(context).disabledColor, fontSize: 18),
        ),
      );
    }

  @override
  void didUpdateWidget(covariant CustomAutoCompleteWidget<T> oldWidget) {
    if (widget.initailValue != oldWidget.initailValue) {
      setState(() {
        setInitialValue(widget.initailValue?.toString());
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void setInitialValue(String? value) {
    selectedValue = value;
  }

  void onItemSelected(T? suggestion) {
    setState(() {
      controller.text = '';
      selectedValue = suggestion?.toString();
    });
    widget.onSuggestionSelected(suggestion);
  }

  TextFieldConfiguration textFieldConfiguration() {
    return TextFieldConfiguration(
        controller: controller,
        enabled: widget.enabled,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
            hintText: selectedValue ?? 'Input value',
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (selectedValue != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedValue = null;
                        onItemSelected(null);
                        if (suggestionBoxController.isOpened()) {
                          suggestionBoxController.close();
                        }
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                IconButton(
                  onPressed: () {
                    if (suggestionBoxController.isOpened()) {
                      suggestionBoxController.close();
                    } else {
                      suggestionBoxController.open();
                    }
                  },
                  icon: Icon(
                    suggestionBoxController.isOpened()
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16,),
            disabledBorder: buildOutlinedInputBorder(),
            border: buildOutlinedInputBorder(),
            enabledBorder: buildOutlinedInputBorder(),
            focusedBorder: buildOutlinedInputBorder(
                borderWidth: 2, mainColor: Colors.blueAccent)));
  }

  OutlineInputBorder buildOutlinedInputBorder(
      {Color? mainColor, double borderWidth = 1}) {
    return OutlineInputBorder(
        borderSide: BorderSide(
            color: shouldShowError() ? Colors.red : mainColor ?? Colors.grey,
            width: borderWidth));
  }

  void onEditingComplete() {
    if (controller.text.isNotEmpty) {
      final inputtedItem =
          isItemExistsInOptions(widget.options, controller.text);
      if (inputtedItem == null && widget.readOnly) {
        clearTextField();
      } else if (widget.readOnly) {
        onItemSelected(inputtedItem);
      } else {
        widget.onEditComplete?.call(controller.text);
      }
    }
  }

  bool shouldShowError() =>
      (widget.validatorError == null || widget.validatorError!.isEmpty) &&
      widget.errorText != null &&
      widget.errorText!.isNotEmpty;

  void clearTextField() {
    selectedValue = null;
    controller.text = '';
    widget.onSuggestionSelected(null);
    setState(() {});
  }

  T? isItemExistsInOptions(List<T> options, String input) {
    T? item;
    for (var i = 0; i < options.length; i++) {
      final value = options[i];
      if (value.toString().toLowerCase() == input.toLowerCase()) {
        item = value;
        break;
      }
    }
    return item;
  }
}
