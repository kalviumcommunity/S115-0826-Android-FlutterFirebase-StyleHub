import 'package:flutter/material.dart';

class TestRadio extends StatelessWidget {
  final int selected = 1;
  const TestRadio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RadioGroup<int>(
        groupValue: selected,
        onChanged: (val) {},
        child: Column(
          children: [
            RadioListTile<int>(
              value: 1,
              title: const Text('One'),
            ),
            RadioListTile<int>(
              value: 2,
              title: const Text('Two'),
            ),
          ],
        ),
      ),
    );
  }
}
