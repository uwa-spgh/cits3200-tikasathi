import 'package:flutter/material.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';

import 'health_facility_screen.dart';

class HealthFacilityCard extends StatelessWidget {
  const HealthFacilityCard({
    required this.facility,
    super.key,
  });

  final HealthFacilitator? facility;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return InkWell(
      key: const Key('health-facility-action'),
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HealthFacilityScreen(facility: facility),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFB9DED5),
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.health_and_safety_outlined,
              size: 32,
              color: Color(0xFF0F766E),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: facility == null
                  ? Text(
                      localizations.healthFacilitySaveAction,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF115E59),
                      ),
                    )
                  : _FacilityDetails(
                      facility: facility!,
                      localizations: localizations,
                    ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right,
              size: 32,
              color: Color(0xFF0F766E),
            ),
          ],
        ),
      ),
    );
  }
}

class _FacilityDetails extends StatelessWidget {
  const _FacilityDetails({
    required this.facility,
    required this.localizations,
  });

  final HealthFacilitator facility;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final details = <Widget>[
      Text(
        localizations.healthFacilitySavedHeading,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF115E59),
        ),
      ),
      if (_hasValue(facility.name))
        _detailRow(
          Icons.apartment_outlined,
          localizations.healthFacilityName,
          facility.name!,
        ),
      if (_hasValue(facility.address))
        _detailRow(
          Icons.location_on_outlined,
          localizations.healthFacilityAddress,
          facility.address!,
        ),
      if (_hasValue(facility.phone))
        _detailRow(
          Icons.phone_outlined,
          localizations.healthFacilityPhone,
          facility.phone!,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < details.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          details[index],
        ],
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F766E)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}
