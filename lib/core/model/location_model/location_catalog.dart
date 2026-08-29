import 'package:bdo_event/core/model/location_model/location_model.dart';
import 'package:bdo_event/core/util/event.resource.dart';

abstract final class LocationCatalog {
  static const offices = [
    // ─────────────────────────────────────────────
    // Mumbai
    // ─────────────────────────────────────────────
    Location(
      id: AppLocations.bdoRiseMumbaiId,
      name: AppLocations.bdoRiseOffice,
      city: AppLocations.mumbai,
      country: AppLocations.india,
      address:
          '49th Floor, Oberoi Commerz III, International Business Park, '
          'Oberoi Garden City, Off Western Express Highway, Goregaon East, '
          'Mumbai 400063, India',
      latitude: 19.1729,
      longitude: 72.8607,
    ),

    // ─────────────────────────────────────────────
    // Bengaluru
    // ─────────────────────────────────────────────
    Location(
      id: AppLocations.bdoRiseBengaluruId,
      name: AppLocations.bdoRiseOffice,
      city: AppLocations.bangalore,
      country: AppLocations.india,
      address:
          'RMZ Eco Space Campus, 1C Building, 5th Floor, No. 502, '
          'Bellandur, Bengaluru, Karnataka 560103, India',
      latitude: 12.9352,
      longitude: 77.6944,
    ),

    // ─────────────────────────────────────────────
    // Ahmedabad
    // ─────────────────────────────────────────────
    Location(
      id: AppLocations.bdoRiseAhmedabadId,
      name: AppLocations.bdoRiseOffice,
      city: AppLocations.ahmedabad,
      country: AppLocations.india,
      address:
          '701, 801, 901 and 1001, Aurelien, Sanand Sarkhej Road, '
          'Opp TTEC Corporate Office, Ahmedabad, Gujarat 380054, India',
      latitude: 22.9968,
      longitude: 72.5117,
    ),

    // ─────────────────────────────────────────────
    // Kolkata
    // ─────────────────────────────────────────────
    Location(
      id: AppLocations.bdoRiseKolkataId,
      name: AppLocations.bdoRiseOffice,
      city: AppLocations.kolkata,
      country: AppLocations.india,
      address:
          '8th Floor, Technopolis Building, Plot No. BP4, Sector V, '
          'Salt Lake City, Bidhan Nagar, West Bengal 700091, India',
      latitude: 22.5697,
      longitude: 88.4330,
    ),

    // ─────────────────────────────────────────────
    // Hyderabad
    // ─────────────────────────────────────────────
    Location(
      id: AppLocations.bdoRiseHyderabadId,
      name: AppLocations.bdoRiseOffice,
      city: AppLocations.hyderabad,
      country: AppLocations.india,
      address:
          '14th Floor, 1401, Tower 30, RMZ Nexity Building, '
          'Plot No. 8B/2, 9, 10A and 10B, Survey No. 83/1, '
          'Hyderabad Knowledge City Layout, Raidurgam Village, '
          'Serilingampally Mandal, Hyderabad, Telangana 500032, India',
      latitude: 17.4345,
      longitude: 78.3773,
    ),

    // ─────────────────────────────────────────────
    // Gurugram
    // ─────────────────────────────────────────────
    Location(
      id: AppLocations.bdoRiseGurugramId,
      name: AppLocations.bdoRiseOffice,
      city: AppLocations.gurugram,
      country: AppLocations.india,
      address:
          '9th Floor, Tower No. B, Tower 10, DLF Cyber City, '
          'DLF Phase 2, Sector 24, Gurugram, Haryana 122002, India',
      latitude: 28.4956,
      longitude: 77.0896,
    ),
  ];

  static Location? byId(String? id) {
    for (final location in offices) {
      if (location.id == id) {
        return location;
      }
    }

    return null;
  }
}