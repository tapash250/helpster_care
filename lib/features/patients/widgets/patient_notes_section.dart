import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/models/models.dart';
import 'package:helpster_care/shared/widgets/section_header.dart';

/// Displays patient notes and provides an input to add new notes.
class PatientNotesSection extends ConsumerStatefulWidget {
  const PatientNotesSection({
    super.key,
    required this.notes,
    this.patientId,
    this.onAddNote,
  });

  final List<PatientNote> notes;
  final String? patientId;
  final Future<bool> Function(String note, String noteType)? onAddNote;

  @override
  ConsumerState<PatientNotesSection> createState() =>
      _PatientNotesSectionState();
}

class _PatientNotesSectionState extends ConsumerState<PatientNotesSection> {
  final _noteController = TextEditingController();
  String _selectedNoteType = 'GENERAL';
  bool _isAdding = false;

  static const _noteTypes = {
    'GENERAL': 'General',
    'MEDICAL': 'Medical',
    'SOCIAL': 'Social',
    'FOLLOWUP': 'Follow-up',
    'ADMIN': 'Administrative',
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Note input area
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Note',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Note type selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _noteTypes.entries.map((entry) {
                        final isSelected = _selectedNoteType == entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: ChoiceChip(
                            label: Text(entry.value),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() =>
                                    _selectedNoteType = entry.key);
                              }
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Note text field
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    minLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Type your note here...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(AppSpacing.sm),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Submit button
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonalIcon(
                      onPressed: _isAdding ? null : _addNote,
                      icon: _isAdding
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send, size: 18),
                      label: const Text('Add Note'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Note list
        if (widget.notes.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'No notes recorded yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: widget.notes.length,
              itemBuilder: (context, index) {
                final note = widget.notes[index];
                return _NoteCard(note: note);
              },
            ),
          ),
      ],
    );
  }

  Future<void> _addNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty || widget.onAddNote == null) return;

    setState(() => _isAdding = true);

    try {
      final success = await widget.onAddNote!(text, _selectedNoteType);
      if (success && mounted) {
        _noteController.clear();
        setState(() => _isAdding = false);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add note')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final PatientNote note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final diff = now.difference(note.createdAt);
    final timeAgo = _formatTimeAgo(diff);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(_humanizeType(note.noteType)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  labelStyle: const TextStyle(fontSize: 11),
                ),
                const Spacer(),
                Text(
                  timeAgo,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              note.note,
              style: theme.textTheme.bodyMedium,
            ),
            if (note.authorName != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '- ${note.authorName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _humanizeType(String type) {
    return type
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  String _formatTimeAgo(Duration diff) {
    if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return '${months}mo ago';
    }
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
