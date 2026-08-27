import 'package:flutter/material.dart';

void showFeedbackSnackBar(BuildContext context, String message) {
  final ScaffoldMessengerState scaffoldMessenger =
      ScaffoldMessenger.of(context);
  scaffoldMessenger.hideCurrentSnackBar();
  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

class ReadAloudButton extends StatelessWidget {
  const ReadAloudButton({
    super.key,
    required this.tooltip,
    required this.unavailableMessage,
  });

  final String tooltip;
  final String unavailableMessage;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF1D65C1),
        ),
      ),
      child: IconButton(
        onPressed: () {
          showFeedbackSnackBar(context, unavailableMessage);
        },
        icon: const Icon(
          Icons.record_voice_over,
          color: Color(0xFF1D65C1),
        ),
        tooltip: tooltip,
      ),
    );
  }
}
