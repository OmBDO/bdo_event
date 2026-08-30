import 'package:bdo_event/core/util/event_resource.dart';
import 'package:bdo_event/features/watcher_screen/domain/model/scan_history_entry.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScanHistorySheet extends StatelessWidget {
  const ScanHistorySheet({
    super.key,
    required this.history,
    required this.onConfirmAll,
    required this.onConfirmEntry,
    required this.keepHistoryVisibleAfterCheckIn,
  });

  final List<ScanHistoryEntry> history;
  final Future<void> Function() onConfirmAll;
  final Future<void> Function(ScanHistoryEntry entry) onConfirmEntry;
  final bool keepHistoryVisibleAfterCheckIn;

  static Future<void> show(
    BuildContext context,
    List<ScanHistoryEntry> history, {
    bool autoOpenNext = true,
    bool keepHistoryVisibleAfterCheckIn = false,
  }) {
    final cubit = context.read<WatcherScanCubit>();
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => ScanHistorySheet(
        history: history,
        onConfirmAll: () => cubit.checkInAll(autoOpenNext: autoOpenNext),
        onConfirmEntry: (entry) =>
            cubit.checkInEntry(entry, autoOpenNext: autoOpenNext),
        keepHistoryVisibleAfterCheckIn: keepHistoryVisibleAfterCheckIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.45,
      child: history.isEmpty
          ? const Center(child: Text(AppText.notScanYet))
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppText.scanHistory,
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
                      onPressed:
                          history.any(
                            (entry) =>
                                entry.status == AppIdentifiers.readytocheckIn,
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
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onPrimary,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(AppText.confirmAll),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      final isPending =
                          entry.status == AppIdentifiers.readytocheckIn;
                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            entry.status == AppText.checkedInitial
                                ? Icons.check
                                : Icons.person_outline,
                          ),
                        ),
                        title: Text(
                          entry.displayName ?? AppText.unknownAttendee,
                        ),
                        subtitle: Text(entry.status),
                        trailing: isPending
                            ? IconButton(
                                tooltip: AppText.cofirmCheckedIn,
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
