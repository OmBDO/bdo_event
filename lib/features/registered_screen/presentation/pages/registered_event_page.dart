import 'dart:convert';
import 'dart:ui' show ImageFilter;

import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_cubit.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_cubit.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:flutter/services.dart';
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
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            28.0,
          ), // Custom border radius for the dialog box
        ),
        titlePadding: const EdgeInsets.fromLTRB(
          24,
          20,
          12,
          8,
        ), // Adjusted for icon button alignment
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                AppText.cancelRegistrationQuestion,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Material 3 Tooltip with a clean tail layout configuration
            Tooltip(
              message: "you can register upto the date of event",
              triggerMode: TooltipTriggerMode.tap,
              preferBelow: false,
              verticalOffset: 16,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              textStyle: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: Colors.black.withOpacity(0.06),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  8.0,
                ), // Expands hit target for easier tapping
                child: Icon(
                  Icons.info_outline_rounded,
                  color: theme.hintColor,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          AppText.cancelDescription(widget.event.title),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              AppText.keepRegistration,
              style: TextStyle(color: theme.hintColor),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
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
    if (cancelled) {
      await context.read<EventScreenCubit>().load(force: true);
      await context.read<CalendarScreenCubit>().loadRegistrations();
      if (mounted) navigator.pop();
    }
  }

  String _qrData(String token) => jsonEncode({
    'type': AppIdentifiers.qrRegistrationType,
    'eventId': widget.event.id,
    'token': token,
    'event': widget.event.title,
    'date': widget.event.date,
    'location': widget.event.location,
  });

  String _manualCode(String token) {
    final value = utf8
        .encode('${widget.event.id}|$token')
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return 'BDO1$value';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisteredEventCubit, RegisteredEventState>(
      builder: (context, state) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    content: const Text(AppText.qrCodeHelp),
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
                  color: Theme.of(context).colorScheme.surface,
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
                    Text(
                      AppText.registeredEvent,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.event.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.event.date}  •  ${widget.event.location}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: 14,
                      ),
                    ),
                    if (widget.event.startTime != null ||
                        widget.event.endTime != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${widget.event.startTime ?? '--:--'} - ${widget.event.endTime ?? '--:--'}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 26),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant,
                        ),
                      ),
                      child: state.registrationToken == null
                          ? SizedBox(
                              width: 220,
                              height: 220,
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 5,
                                  sigmaY: 5,
                                ),
                                child: Opacity(
                                  opacity: 0.55,
                                  child: QrImageView(
                                    data: 'bdo-event-ticket-preparing',
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
                              ),
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
                    if (state.registrationToken != null) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppText.registrationCode,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                _manualCode(state.registrationToken!),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: AppText.copyRegistrationCode,
                              icon: const Icon(Icons.copy_rounded),
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(
                                    text: _manualCode(state.registrationToken!),
                                  ),
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(AppText.registrationCodeCopied),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Give this code to event staff if the QR code cannot be scanned.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      AppText.showQrCode,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
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
                  color: Theme.of(context).colorScheme.surface.withValues(
                    alpha: 0.9,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF0C9C4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.cancellation,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppText.needToChangePlans,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppText.cancellationWarning,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: state.isCancelling
                            ? null
                            : _confirmCancellation,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            state.isCancelling
                                ? Icons.flight_takeoff_rounded
                                : Icons.delete_outline_rounded,
                            key: ValueKey(state.isCancelling),
                          ),
                        ),
                        label: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            state.isCancelling
                                ? 'Ticket is departing...'
                                : AppText.cancelRegistrationButton,
                            key: ValueKey(state.isCancelling),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                    if (state.error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        state.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
