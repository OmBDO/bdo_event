import 'package:bdo_event/features/watcher_screen/domain/model/scan_history_entry.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_state.dart';
import 'package:flutter/material.dart';

class ScanHistorySheet extends StatelessWidget {
  const ScanHistorySheet({super.key, required this.history});

  final List<ScanHistoryEntry> history;

  static Future<void> show(
    BuildContext context,
    List<ScanHistoryEntry> history,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => ScanHistorySheet(history: history),
  );

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.45,
      child: history.isEmpty
          ? const Center(child: Text('No scans yet'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      entry.status == 'Checked in'
                          ? Icons.check
                          : Icons.person_outline,
                    ),
                  ),
                  title: Text(entry.userId ?? 'Unknown attendee'),
                  subtitle: Text(entry.status),
                );
              },
            ),
    ),
  );
}
