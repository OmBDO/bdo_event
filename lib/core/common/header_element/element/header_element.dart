// Location: lib/features/event_screen/widget/header_element.dart
import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/core/common/dropdown_list/element/location_dropdown.dart';
import 'package:bdo_event/core/model/location_model/location_model.dart';
import 'package:bdo_event/core/model/location_model/location_catalog.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:bdo_event/core/util/notification_count_formatter.dart';
import 'package:bdo_event/features/notification_screen/presentation/pages/notification_screen.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class HeaderElement extends StatefulWidget {
  final int currentScreenIndex;
  final VoidCallback onProfileSelected;
  final VoidCallback onLogoutSelected;

  const HeaderElement({
    super.key,
    required this.currentScreenIndex,
    required this.onProfileSelected,
    required this.onLogoutSelected,
  });

  @override
  State<HeaderElement> createState() => _HeaderElementState();
}

class _HeaderElementState extends State<HeaderElement> {
  late Future<int> _unreadCountFuture;

  @override
  void initState() {
    super.initState();
    _refreshUnreadCount();
  }

  void _refreshUnreadCount() {
    _unreadCountFuture = getIt<EventStore>().loadUnreadNotificationCount();
  }

  Location selectedLocation = const Location(
    id: AppLocations.mumbaiZoneOneId,
    name: AppLocations.mumbai,
    city: AppLocations.mumbai,
    country: AppLocations.india,
    zone: AppLocations.zoneOne,
  );

  final List<Location> locations = [...LocationCatalog.offices];

  Future<void> onNotificationClick() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
    if (!mounted) return;
    setState(_refreshUnreadCount);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: AppScrollTracker.scrollOffsetNotifier,
      builder: (context, currentPixels, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final profilePhotoUrl = context
          .watch<ProfileScreenCubit>()
          .state
          .user
          ?.photoUrl
          ?.trim();
        final controlBackground = colorScheme.surface.withValues(alpha: 0.9);
        final controlIconColor = colorScheme.onSurface;
        // 1. Establish the scrolling condition parameter flag
        bool isVisible =
            widget.currentScreenIndex != 0 || currentPixels <= 50.0;
        bool hasScrolled = currentPixels > 0.0;

        return AnimatedContainer(
          // 2. Smoothly transition the background appearance
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          width: double.infinity,
          height: 130,
          decoration: BoxDecoration(
            // 3. Apply the gradient condition layer rule
            gradient: hasScrolled
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.9),
                      Colors.transparent,
                    ],
                  )
                : null, // Resolves to a fully transparent background when at the top
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Visibility(
                  visible: isVisible,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isVisible ? 1.0 : 0.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: controlBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.language_outlined,
                            color: controlIconColor,
                            size: 20,
                          ),
                        ),
                        const Gap(AppSpace.space10),
                        Expanded(
                          child: LocationDropdown(
                            selectedValue: selectedLocation,
                            items: locations,
                            onChanged: (Location? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedLocation = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Gap(AppSpace.space16),

              // 2. Notification Squircle Button Block
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: controlBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: onNotificationClick,
                      icon: Icon(
                        Icons.notifications_none_outlined,
                        size: 20,
                        color: controlIconColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: FutureBuilder<int>(
                        future: _unreadCountFuture,
                        builder: (context, snapshot) {
                          final badgeText = formatNotificationCount(
                            snapshot.data ?? 0,
                          );
                          if (badgeText.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            constraints: const BoxConstraints(minWidth: 18),
                            height: 18,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                color: colorScheme.onError,
                                fontSize: AppSize.text9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(AppSpace.space12),

              // 3. User Avatar Block (Right Side)
              PopupMenuButton<String>(
                tooltip: AppText.accountMenu,
                position: PopupMenuPosition.under,
                offset: const Offset(0, 8),
                padding: EdgeInsets.zero,
                menuPadding: const EdgeInsets.symmetric(vertical: 8),
                constraints: const BoxConstraints(minWidth: 190),
                elevation: 10,
                shadowColor: colorScheme.shadow,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                onSelected: (value) async {
                  if (value == AppIdentifiers.profileMenuValue) {
                    widget.onProfileSelected();
                  } else if (value == AppIdentifiers.logoutMenuValue) {
                    widget.onLogoutSelected();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: AppIdentifiers.profileMenuValue,
                    height: 52,
                    child: Row(
                      children: [
                        Icon(Icons.person_outline_rounded, size: 21),
                        Gap(AppSpace.space12),
                        Text(
                          AppText.profile,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: AppIdentifiers.logoutMenuValue,
                    height: 52,
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, size: 21),
                        Gap(AppSpace.space12),
                        Text(
                          AppText.logOut,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    backgroundImage: profilePhotoUrl?.isNotEmpty == true
                        ? NetworkImage(profilePhotoUrl!)
                        : const NetworkImage(AppAssets.defaultAvatarUrl),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
