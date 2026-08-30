import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event_resource.dart';

class EventInvitationPage extends StatefulWidget {
  const EventInvitationPage({required this.event, super.key});

  final Event event;

  @override
  State<EventInvitationPage> createState() => _EventInvitationPageState();
}

class _EventInvitationPageState extends State<EventInvitationPage> {
  late Future<List<Map<String, String>>> _recipientsFuture;
  final Set<String> _selectedIds = <String>{};
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _recipientsFuture = getIt<EventStore>().loadInvitationRecipients();
  }

  Future<void> _send(List<Map<String, String>> recipients) async {
    if (_selectedIds.isEmpty) return;
    setState(() => _isSending = true);
    try {
      final count = await getIt<EventStore>().sendEventInvitations(
        eventId: widget.event.id,
        userIds: _selectedIds.toList(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.invitationsSent(count))),
      );
      Navigator.of(context).pop();
    } on LocalStorageException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppText.unableToSendInvitations)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppText.inviteUsers)),
    body: FutureBuilder<List<Map<String, String>>>(
      future: _recipientsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text(AppText.unableToLoadUsers));
        }
        final recipients = snapshot.data ?? const <Map<String, String>>[];
        if (recipients.isEmpty) {
          return const Center(child: Text(AppText.noUsersAvailableToInvite));
        }
        final allSelected = _selectedIds.length == recipients.length;
        return Column(
          children: [
            CheckboxListTile(
              title: const Text(AppText.selectAllUsers),
              value: allSelected,
              onChanged: _isSending
                  ? null
                  : (selected) => setState(() {
                      _selectedIds
                        ..clear()
                        ..addAll(selected == true
                            ? recipients.map((recipient) => recipient['id']!)
                            : const <String>[]);
                    }),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: recipients.length,
                itemBuilder: (context, index) {
                  final recipient = recipients[index];
                  final id = recipient['id']!;
                  return CheckboxListTile(
                    value: _selectedIds.contains(id),
                    onChanged: _isSending
                        ? null
                        : (selected) => setState(() {
                            if (selected == true) {
                              _selectedIds.add(id);
                            } else {
                              _selectedIds.remove(id);
                            }
                          }),
                    title: Text(
                      recipient['name']!.isEmpty
                          ? recipient['email']!
                          : recipient['name']!,
                    ),
                    subtitle: Text(recipient['email']!),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSending ? null : () => _send(recipients),
                    icon: const Icon(Icons.send_rounded),
                    label: Text(AppText.sendToUsers(_selectedIds.length)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}