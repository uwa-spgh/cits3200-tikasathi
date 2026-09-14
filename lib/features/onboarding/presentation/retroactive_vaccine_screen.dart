import 'package:flutter/material.dart';
import 'package:tikasathi/features/vaccine_records/presentation/vaccine_records_screen.dart';

export 'package:tikasathi/features/vaccine_records/presentation/vaccine_records_screen.dart';

/// Backward-compatible wrapper that directs to the unified [VaccineRecordsScreen].
class RetroactiveVaccineScreen extends StatelessWidget {
  const RetroactiveVaccineScreen({
    super.key,
    required this.childId,
    required this.isOnboardingFlow,
  });

  final String childId;
  final bool isOnboardingFlow;

  @override
  Widget build(BuildContext context) {
    return VaccineRecordsScreen(
      childId: childId,
      isOnboardingFlow: isOnboardingFlow,
    );
  }
}
