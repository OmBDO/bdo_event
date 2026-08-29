import 'dart:convert';

import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_cubit.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/common/event_image/event_image.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class RegisteredEventPage extends StatefulWidget {
  final Event event;

  const RegisteredEventPage({super.key, required this.event});

  @override
  State<RegisteredEventPage> createState() => _RegisteredEventPageState();
}

class _RegisteredEventPageState extends State<RegisteredEventPage> {
  @override
  void initState() {
    super.initState();
    context.read<RegisteredEventCubit>().loadToken(widget.event.id);
  }

  Future<void> _confirmCancellation() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppText.cancelRegistrationQuestion),
        content: Text(
          'Your registration for "${widget.event.title}" will be removed from My Events.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppText.keepRegistration),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(AppText.cancelEvent),
          ),
        ],
      ),
    );

    if (shouldCancel != true || !mounted) return;
    final cancelled = await context.read<RegisteredEventCubit>().cancel(
          widget.event,
        );
    if (!mounted) return;
    if (cancelled) Navigator.of(context).pop();
  }

  String _qrData(String token) => jsonEncode({
    'type': AppIdentifiers.qrRegistrationType,
    'eventId': widget.event.id,
    'token': token,
    'event': widget.event.title,
    'date': widget.event.date,
    'location': widget.event.location,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisteredEventCubit, RegisteredEventState>(
      builder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFFFFF1E6),
      appBar: AppBar(
        title: const Text(AppText.myTicket),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: AppText.aboutQrCode,
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(AppText.whyQrCode),
                  content: const Text(
                    AppText.qrCodeHelp,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(AppText.gotIt),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A7A4C43),
                    blurRadius: 22,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: EventImage(
                      path: widget.event.imageUrl,
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    AppText.registeredEvent,
                    style: TextStyle(
                      color: Color(0xFFB14F36),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF2D0C57),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.event.date}  •  ${widget.event.location}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6F607A),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE8E1E1)),
                    ),
                    child: state.registrationToken == null
                        ? const SizedBox(
                            width: 220,
                            height: 220,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : QrImageView(
                      data: _qrData(state.registrationToken!),
                      version: QrVersions.auto,
                      size: 220,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF2D0C57),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF2D0C57),
                      ),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    AppText.showQrCode,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6F607A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.green,
                        size: 17,
                      ),
                      SizedBox(width: 6),
                      Text(
                        AppText.registrationConfirmed,
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF0C9C4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppText.cancellation,
                    style: TextStyle(
                      color: Color(0xFFB64234),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppText.needToChangePlans,
                    style: TextStyle(
                      color: Color(0xFF2D0C57),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppText.cancellationWarning,
                    style: TextStyle(
                      color: Color(0xFF6F607A),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: state.isCancelling ? null : _confirmCancellation,
                      icon: state.isCancelling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline_rounded),
                      label: Text(
                        state.isCancelling
                          ? AppText.cancelling
                          : AppText.cancelRegistrationButton,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB64234),
                        side: const BorderSide(color: Color(0xFFE5A39A)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
