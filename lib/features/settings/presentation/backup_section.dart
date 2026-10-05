import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/services/local_backup_service.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/home/domain/home_status_groups_provider.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';

/// Export and import controls for a local backup file.
class BackupSection extends ConsumerStatefulWidget {
  const BackupSection({super.key});

  @override
  ConsumerState<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<BackupSection> {
  bool _busy = false;

  Future<void> _export() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    File? file;
    try {
      final String json =
          await ref.read(localBackupServiceProvider).buildBackupJson();
      final Directory directory = await getTemporaryDirectory();
      final String name = LocalBackupService.fileNameFor(DateTime.now());
      final File exportFile = File(p.join(directory.path, name));
      file = exportFile;
      await exportFile.writeAsString(json);
      if (!mounted) {
        return;
      }
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      final ShareResult result = await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile(exportFile.path, mimeType: 'application/json', name: name),
          ],
          fileNameOverrides: <String>[name],
          sharePositionOrigin:
              box == null ? null : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
      if (!mounted || result.status == ShareResultStatus.dismissed) {
        return;
      }
      _showMessage(localizations.backupExportSuccess);
    } catch (_) {
      if (mounted) {
        _showMessage(localizations.backupExportError);
      }
    } finally {
      await _deleteQuietly(file);
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  /// The export holds a child's health data, so it must not outlive the share.
  Future<void> _deleteQuietly(File? file) async {
    try {
      if (file != null && await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // The cache directory is cleared by the OS; nothing more to do.
    }
  }

  Future<void> _import() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    try {
      final String? json = await _pickBackupJson();
      if (!mounted || json == null) {
        return;
      }
      try {
        ref.read(localBackupServiceProvider).validate(json);
      } on BackupValidationException {
        _showMessage(localizations.backupInvalidFile);
        return;
      }
      final bool confirmed = await _confirmReplace(localizations);
      if (!mounted || !confirmed) {
        return;
      }
      await ref.read(localBackupServiceProvider).importJson(json);
      if (!mounted) {
        return;
      }
      _showMessage(localizations.backupImportSuccess);
      ref.invalidate(languageControllerProvider);
      ref.invalidate(homeStatusGroupsProvider);
      ref.invalidate(childProfileProvider);
    } on BackupValidationException {
      if (mounted) {
        _showMessage(localizations.backupInvalidFile);
      }
    } on FormatException {
      if (mounted) {
        _showMessage(localizations.backupInvalidFile);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(localizations.backupImportError);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<String?> _pickBackupJson() async {
    final FilePickerResult? picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['json'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) {
      return null;
    }
    final PlatformFile file = picked.files.single;
    final List<int>? bytes = file.bytes;
    if (bytes != null) {
      return utf8.decode(bytes);
    }
    final String? path = file.path;
    if (path == null) {
      return '';
    }
    return File(path).readAsString();
  }

  Future<bool> _confirmReplace(AppLocalizations localizations) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
          contentPadding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
          actionsPadding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
          title: Text(
            localizations.backupReplaceTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            localizations.backupReplaceMessage,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              height: 1.5,
            ),
          ),
          actions: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                    autofocus: true,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F52BA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(localizations.profileCancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(localizations.backupReplaceConfirm),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          localizations.backupSectionTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        _BackupAction(
          key: const Key('backup-export-action'),
          icon: Icons.ios_share,
          title: localizations.backupExportAction,
          onTap: _export,
        ),
        const SizedBox(height: 6),
        _BackupAction(
          key: const Key('backup-import-action'),
          icon: Icons.file_open_outlined,
          title: localizations.backupImportAction,
          onTap: _import,
        ),
        const SizedBox(height: 8),
        Text(
          localizations.backupPrivacyNote,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF64748B),
          ),
        ),
        if (_busy) ...[
          const SizedBox(height: 12),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}

class _BackupAction extends StatelessWidget {
  const _BackupAction({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF5FF),
          border: Border.all(color: const Color(0xFFCFE0FA)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0E64C5)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0E64C5),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF0E64C5)),
          ],
        ),
      ),
    );
  }
}
