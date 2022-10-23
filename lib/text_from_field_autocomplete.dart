import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class TextFromFieldAutocomplete extends StatelessWidget {
  late List<String> _options;
  late TextEditingController _textEditingController;
  AutocompleteOnSelected<String>? _onSelected;
  late FocusNode _focusNode;
  late FocusNode _nextFocusNode;

  TextFromFieldAutocomplete(
      {required List<String> options,
      required TextEditingController textEditingController,
        AutocompleteOnSelected<String>? onSelected,
        required FocusNode focusNode, required FocusNode nextFocusNode,
      Key? key})
      : super(key: key) {
    _options = options;
    _textEditingController = textEditingController;
    _onSelected = onSelected;
    _focusNode = focusNode;
    _nextFocusNode = nextFocusNode;
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete(
      focusNode: _focusNode,
      textEditingController: _textEditingController,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        } else {
          return _options.where((String option) {
            return option.startsWith(fixLoc(textEditingValue.text));
          });
        }
      },
      onSelected: _onSelected,
      fieldViewBuilder: (BuildContext context, _cityTextEditingController,
          _locationFocusNode, VoidCallback onFieldSubmitted) {
        return TextFormField(
          keyboardType: TextInputType.name,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: "City"),
          controller: _cityTextEditingController,
          focusNode: _locationFocusNode,
          onEditingComplete: () {
            _nextFocusNode.requestFocus();
          },
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return _AutocompleteOptions<String>(
          displayStringForOption: RawAutocomplete.defaultStringForOption,
          onSelected: onSelected,
          options: options,
          maxOptionsHeight: 200,
        );
      },
    );
  }

  String fixLoc(String loc) {
    if (loc.isEmpty) {
      return loc;
    }
    if (!loc.contains(" ")) {
      return loc.toLowerCase().capitalize;
    }
    List<String> splitted = [];
    for (String st in loc.split(" ")) {
      splitted.add(st.toLowerCase().capitalize);
    }
    return splitted.join(" ");
  }
}

class _AutocompleteOptions<T extends Object> extends StatelessWidget {
  const _AutocompleteOptions({
    Key? key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.options,
    required this.maxOptionsHeight,
  }) : super(key: key);

  final AutocompleteOptionToString<T> displayStringForOption;

  final AutocompleteOnSelected<T> onSelected;

  final Iterable<T> options;
  final double maxOptionsHeight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxOptionsHeight),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final T option = options.elementAt(index);
              return InkWell(
                onTap: () {
                  onSelected(option);
                },
                child: Builder(builder: (BuildContext context) {
                  final bool highlight =
                      AutocompleteHighlightedOption.of(context) == index;
                  if (highlight) {
                    SchedulerBinding.instance
                        .addPostFrameCallback((Duration timeStamp) {
                      Scrollable.ensureVisible(context, alignment: 0.5);
                    });
                  }
                  return Container(
                    color: highlight ? Theme.of(context).focusColor : null,
                    padding: const EdgeInsets.all(16.0),
                    child: Text(displayStringForOption(option)),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
