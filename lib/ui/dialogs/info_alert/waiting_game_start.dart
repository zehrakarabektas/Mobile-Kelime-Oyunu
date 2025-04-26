import 'package:flutter/material.dart';

class WaitingGameStart extends StatelessWidget {
  final VoidCallback onCancel;

  const WaitingGameStart({Key? key, required this.onCancel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Eşleşme Bekleniyor'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Rakip aranıyor...'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('İptal'),
        ),
      ],
    );
  }
}
