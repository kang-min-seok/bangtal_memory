import 'package:flutter/material.dart';

import '../constants/constants.dart';



class SatisfactionFilterOptions extends StatefulWidget {
  const SatisfactionFilterOptions({super.key});
  @override
  _SatisfactionFilterOptionsState createState() =>
      _SatisfactionFilterOptionsState();
}

class _SatisfactionFilterOptionsState extends State<SatisfactionFilterOptions> {
  static List<String> selectedSatisfactions = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "만족도 필터 선택",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: satisfactionList.map((satisfaction) {
              return ChoiceChip(
                label: Text(satisfaction),
                selected: selectedSatisfactions.contains(satisfaction),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      selectedSatisfactions.add(satisfaction);
                    } else {
                      selectedSatisfactions.remove(satisfaction);
                    }
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: selectedSatisfactions.contains(satisfaction)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                  ),
                ),
                backgroundColor: Colors.transparent,
                selectedColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.19),
                labelStyle: TextStyle(
                  color: selectedSatisfactions.contains(satisfaction)
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onBackground,
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'selectedSatisfactions': selectedSatisfactions,
                });
              },
              child: const Text('선택 완료'),
            ),
          ),
        ],
      ),
    );
  }
}
