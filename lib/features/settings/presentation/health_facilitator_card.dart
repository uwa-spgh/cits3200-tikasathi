import 'package:flutter/material.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'health_facility_card.dart';

export 'health_facility_card.dart';

// Backward compatibility alias supporting the old key
class HealthFacilitatorCard extends StatelessWidget {
  const HealthFacilitatorCard({
    required this.facilitator,
    super.key,
  });

  final HealthFacilitator? facilitator;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const Key('health-facilitator-action'),
      child: HealthFacilityCard(facility: facilitator),
    );
  }
}
