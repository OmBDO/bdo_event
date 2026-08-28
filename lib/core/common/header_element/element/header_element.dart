// Location: lib/features/event_screen/widget/header_element.dart
import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/core/common/dropdown_list/element/location_dropdown.dart';
import 'package:bdo_event/core/model/location_model/location_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:bdo_event/core/util/event.resource.dart';

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
  Location selectedLocation = const Location(
    id: AppLocations.mumbaiZoneOneId,
    name: AppLocations.mumbai,
    city: AppLocations.mumbai,
    country: AppLocations.india,
    zone: AppLocations.zoneOne,
  );

  final List<Location> locations = [
    const Location(
      id: AppLocations.mumbaiZoneOneId,
      name: AppLocations.mumbai,
      city: AppLocations.mumbai,
      country: AppLocations.india,
      zone: AppLocations.zoneOne,
    ),
    const Location(
      id: AppLocations.bangaloreEastId,
      name: AppLocations.bangalore,
      city: AppLocations.bangalore,
      country: AppLocations.india,
      zone: AppLocations.east,
    ),
    const Location(
      id: AppLocations.kolkataNorthId,
      name: AppLocations.kolkata,
      city: AppLocations.kolkata,
      country: AppLocations.india,
      zone: AppLocations.north,
    ),
    const Location(
      id: AppLocations.mumbaiZoneTwoId,
      name: AppLocations.mumbai,
      city: AppLocations.mumbai,
      country: AppLocations.india,
      zone: AppLocations.zoneTwo,
    ),
    const Location(
      id: AppLocations.bangaloreWestId,
      name: AppLocations.bangalore,
      city: AppLocations.bangalore,
      country: AppLocations.india,
      zone: AppLocations.west,
    ),
    const Location(
      id: AppLocations.kolkataSouthId,
      name: AppLocations.kolkata,
      city: AppLocations.kolkata,
      country: AppLocations.india,
      zone: AppLocations.south,
    ),
    const Location(
      id: AppLocations.delhiNcrId,
      name: AppLocations.delhi,
      city: AppLocations.delhi,
      country: AppLocations.india,
      zone: AppLocations.ncr,
    ),
  ];

  void onNotificationClick() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppText.noNewNotifications)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: AppScrollTracker.scrollOffsetNotifier,
      builder: (context, currentPixels, child) {
        // 1. Establish the scrolling condition parameter flag
        bool isVisible =
            widget.currentScreenIndex != 0 || currentPixels <= 50.0;
        bool hasScrolled = currentPixels > 0.0;

        return AnimatedContainer(
          // 2. Smoothly transition the background appearance
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          width: double.infinity,
          height: 150,
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
                            color: Colors.white.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.language_outlined,
                            color: Colors.black87,
                            size: 20,
                          ),
                        ),
                        const Gap(10),
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

              const Gap(16),

              // 2. Notification Squircle Button Block
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: onNotificationClick,
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    size: 20,
                    color: Colors.black87,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

              const Gap(12),

              // 3. User Avatar Block (Right Side)
              PopupMenuButton<String>(
                tooltip: AppText.accountMenu,
                position: PopupMenuPosition.under,
                offset: const Offset(0, 8),
                padding: EdgeInsets.zero,
                menuPadding: const EdgeInsets.symmetric(vertical: 8),
                constraints: const BoxConstraints(minWidth: 190),
                elevation: 10,
                shadowColor: Colors.black26,
                color: Colors.white,
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
                        SizedBox(width: 12),
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
                        SizedBox(width: 12),
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
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(
                      AppAssets.defaultAvatarUrl,
                    ),
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
