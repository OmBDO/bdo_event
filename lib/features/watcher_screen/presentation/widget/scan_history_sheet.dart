import 'package:bdo_event/features/watcher_screen/domain/model/scan_history_entry.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_state.dart';
import 'package:flutter/material.dart';

class ScanHistorySheet extends StatelessWidget {
  const ScanHistorySheet({
    super.key,
    required this.history,
    required this.onConfirmAll,
    required this.onConfirmEntry,
  });

  final List<ScanHistoryEntry> history;
  final Future<void> Function() onConfirmAll;
  final Future<void> Function(ScanHistoryEntry entry) onConfirmEntry;

  static Future<void> show(
    BuildContext context,
    List<ScanHistoryEntry> history,
    {
    bool autoOpenNext = true,
    bool keepHistoryVisibleAfterCheckIn = false,
    }
  {
    final cubit = context.read<WatcherScanCubit>();
    return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => ScanHistorySheet(
      history: history,
        onConfirmAll: () => cubit.checkInAll(autoOpenNext: autoOpenNext),
        onConfirmEntry: (entry) =>
          cubit.checkInEntry(entry, autoOpenNext: autoOpenNext),
    ),
  );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.45,
      child: history.isEmpty
          ? const Center(child: Text('No scans yet'))
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Scan history',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: history.any(
                        (entry) => entry.status == 'Ready to check in',
                      )
                          ? () async {
                              await onConfirmAll();
                              if (context.mounted &&
                                  !keepHistoryVisibleAfterCheckIn) {
                                Navigator.pop(context);
                              }
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                          Theme.of(context).colorScheme.primary,
                        foregroundColor:
                          Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Confirm all'),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      final isPending = entry.status == 'Ready to check in';
                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            entry.status == 'Checked in'
                                ? Icons.check
                                : Icons.person_outline,
                          ),
                        ),
                        title: Text(entry.displayName ?? 'Unknown attendee'),
                        subtitle: Text(entry.status),
                        trailing: isPending
                            ? IconButton(
                                tooltip: 'Confirm check-in',
                                icon: const Icon(Icons.check_circle_outline),
                                onPressed: () async {
                                  await onConfirmEntry(entry);
                                  if (context.mounted &&
                                      !keepHistoryVisibleAfterCheckIn) {
                                    Navigator.pop(context);
                                  }
                                },
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
    ),
  );
}
