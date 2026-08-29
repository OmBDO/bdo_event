abstract final class AppText {
  static const appName = 'BDO Event';
  static const configurationRequired = 'Supabase configuration required';
  static const configurationInstructions =
      'Provide SUPABASE_URL and SUPABASE_ANON_KEY with --dart-define before running the app.';
  static const brandName = 'BDO Events';
  static const missingEventImage = 'Missing event image';
  static const accountMenu = 'Account menu';
  static const logOut = 'Log out';

  static const signIn = 'Sign in';
  static const signInTitle = 'Sign in to continue';
  static const signInSubtitle =
      'Your next great event is only a few taps away.';
  static const emailAddress = 'Email address';
  static const password = 'Password';
  static const showPassword = 'Show password';
  static const hidePassword = 'Hide password';
  static const createAccount = 'Create account';
  static const createAccountTitle = 'Create your account';
  static const createAccountSubtitle =
      'Save events, manage registrations, and never miss a moment.';
  static const fullName = 'Full name';
  static const confirmPassword = 'Confirm password';
  static const role = 'Role';
  static const roleUser = 'User';
  static const roleAdmin = 'Admin';
  static const roleWatcher = 'Watcher';
  static const roleRequestNote =
      'Admin and watcher access must be approved by an administrator.';
  static const termsAgreement = 'I agree to the terms and privacy policy';
  static const newToApp = 'New to BDO Events? ';
  static const alreadyHaveAccount = 'Already have an account? ';

  static const upcoming = 'Upcoming';
  static const myEvents = 'My Events';
  static const past = 'Past';
  static const event = 'Event';
  static const register = 'Register';
  static const create = 'Create';
  static const profile = 'Profile';
  static const registration = 'Registration';
  static const eventCategories = 'Event Categories';
  static const copyEventDetails = 'Copy event details';
  static const eventDetailsCopied = 'Event details copied';
  static const createEvent = 'Create event';
  static const updateEvent = 'Update event';
  static const updateEventEyebrow = 'UPDATE EVENT';
  static const createEventEyebrow = 'CREATE EVENT';
  static const updateYourEvent = 'Update your event';
  static const bringPeopleTogether = 'Bring people together';
  static const eventDetailsPrompt =
      'Add the essential details and publish your next event.';
  static const addEventImage = 'Add event image';
  static const eventTitle = 'Event title';
  static const eventDate = 'Event date';
  static const location = 'Location';
  static const description = 'Description';
  static const selectCategory = 'Select Category';
  static const pleaseSelectCategory = 'Please select a category';
  static const eventUpdated = 'Event updated successfully';
  static const eventCreated = 'Event created successfully';
  static const deleteEventDescription =
      '"{eventTitle}" will be removed permanently.';
  static const tapToCreateFirstEvent =
      'Tap the + button below to create your first event.';
  static const savingEvent = 'Saving event...';
  static const update = 'Update';
  static const delete = 'Delete';
  static const manageEvent = 'Manage event';
  static const administratorAccessRequired =
      'Administrator access is required to manage user roles';
  static const roleRequired = 'A user must have at least one role';
  static const roleManagementTrustedServer =
      'Role management requires a trusted server';
  static const pleaseSignInToUpdatePreferences =
      'Please sign in to update preferences';
  static const unableToSaveNotificationPreference =
      'Unable to save notification preference';
  static const music = 'Music';
  static const business = 'Business';
  static const deleteEventQuestion = 'Delete event?';
  static const keepEvent = 'Keep event';

  static const available = 'Available';
  static const registered = 'Registered';
  static const cancelRegistration = 'Cancel Registration';
  static const registrationClosed = 'Registration Closed';
  static const unavailable = 'Unavailable';
  static const eventFull = 'Event Full';
  static const fullyBooked = 'Fully Booked';
  static const registeredEvent = 'REGISTERED EVENT';
  static const myTicket = 'My ticket';
  static const cancelRegistrationQuestion = 'Cancel registration?';
  static String cancelDescription(String input) =>
      "Your registration for $input will be removed from My Events.\n\nNote: You can still able to register again, check terms on ⓘ.";
  static const keepRegistration = 'Keep registration';
  static const cancelEvent = 'Cancel event';
  static const aboutQrCode = 'About your QR code';
  static const whyQrCode = 'Why is there a QR code?';
  static const gotIt = 'Got it';
  static const showQrCode = 'Show this QR code at the event entrance';
  static const registrationConfirmed = 'Registration confirmed';
  static const cancellation = 'CANCELLATION';
  static const needToChangePlans = 'Need to change your plans?';
  static const cancellationWarning =
      'Cancelling removes this ticket and its QR code from your registered events. This action cannot be undone.';
  static const cancelling = 'Cancelling...';
  static const cancelRegistrationButton = 'Cancel registration';
  static const qrCodeHelp =
      'This QR code is your digital event pass. Show it at the entrance so the event team can scan and verify your registration quickly.';

  static const accountSettings = 'Account Settings';
  static const editProfile = 'Edit Profile';
  static const profileDetails = 'Profile details';
  static const myEventRegistrations = 'My Event Registrations';
  static const paymentMethods = 'Payment Methods';
  static const preferences = 'Preferences';
  static const pushNotifications = 'Push Notifications';
  static const darkThemeMode = 'Dark Theme Mode';
  static const appLanguage = 'App Language';
  static const englishIndia = 'English (IN)';
  static const supportLegal = 'Support & Legal';
  static const helpCenterFaq = 'Help Center & FAQ';
  static const privacyPolicy = 'Privacy Policy';
  static const logout = 'Log Out Account';
  static const close = 'Close';
  static const paymentMethodsInfo =
      'Payment methods are not required for free event registration in this version of BDO Events.';
  static const onlyAvailableLanguage =
      'English (IN) is the only available language.';
  static const changeProfileDetails = 'Change name, email, and bio details';
  static const viewTicketsAndFestivals = 'View tickets and saved festivals';
  static const linkedPaymentMethods = 'Linked cards and digital wallets';
  static const festivalUpdateAlerts = 'Alerts for upcoming festival updates';
  static const darkModeInterface = 'Toggle dark mode interface canvas';
  static const troubleshootingHelp = 'Troubleshooting and event booking help';
  static const termsAndSecurity = 'Terms of service and data security rules';
  static const eventHelp =
      'For event help, open the event details and use the registration action. Your registered events are available under My Event Registrations.';
  static const supabaseDataPolicy =
      'BDO Events stores account, event, and registration data using Supabase.';

  static const enterEmail = 'Enter your email address';
  static const enterPassword = 'Enter your password';
  static const enterFullName = 'Enter your full name';
  static const unexpectedConnectionError =
      'An unexpected connection error occurred.';
  static const unexpectedCredentialError =
      'An unexpected error occurred while writing user credentials.';
  static const enterEventTitle = 'Enter an event title';
  static const enterEventLocation = 'Enter the event location';
  static const chooseEventDate = 'Choose an event date';
  static const useAtLeastEightCharacters = 'Use at least 8 characters';
  static const addAtLeastTenCharacters = 'Add at least 10 characters';
  static const validEmail = 'Enter a valid email address';
  static const passwordsDoNotMatch = 'Passwords do not match';
  static const acceptTerms = 'You must accept the terms and privacy policy';

  static const emailOrPasswordIncorrect = 'Email or password is incorrect';
  static const emailAlreadyRegistered = 'This email is already registered';
  static const unableToCreateAccount = 'Unable to create the account';
  static const unableToSignIn = 'Unable to sign in';
  static const pleaseSignInToManageEvents = 'Please sign in to manage events';
  static const pleaseSignInToRegister = 'Please sign in to register for events';
  static const pleaseSignInToModifyRegistrations =
      'Please sign in to modify registrations';
  static const eventNoLongerAvailable =
      'This event is no longer available for registration';
  static const eventAtCapacity = 'This event has reached its capacity';
  static const alreadyRegistered = 'You are already registered for this event';
  static const registrationRevoked =
      'This registration was cancelled and cannot be reactivated';
  static const unableToLoadTicket = 'Unable to load ticket';
  static const watcherAccessRequired = 'Watcher access is required';
  static const invalidRegistrationQr =
      'This QR code is not valid for this event';
  static const registrationValid = 'Registration is valid';
  static const checkIn = 'Check in attendee';
  static const checkedIn = 'Attendee checked in';
  static const alreadyCheckedIn = 'Attendee is already checked in';
  static const unableToCheckIn = 'Unable to record attendance';
  static const checkInUnavailable = 'This registration cannot be checked in';
  static const scanRegistration = 'Scan registration';
  static const scanRegistrationPrompt = 'Scan a registration QR code';
  static const scanAgain = 'Scan again';
  static const notRegistered = 'You are not registered for this event';
  static const registrationCancelled =
      'Your registration was cancelled successfully.';
  static const eventRegistered = 'Event registered successfully!';
  static const status = 'STATUS';
  static const upcomingEvent = 'UPCOMING EVENT';
  static const attend100Plus = 'Attend 100+';
  static const attendees = 'attendees';
  static const eventDetailDescription =
      'AI Global Leadership Future Summit unites global leaders to explore innovation, share insights, and shape the future of technology worldwide...';
  static const unableToSaveRegistration = 'Unable to save the registration';
  static const unableToCancelRegistration = 'Unable to cancel the registration';
  static const updateInProgress = 'An update is already in progress';
  static const unableToSaveEvent = 'Unable to save the event';
  static const unableToLoadEvents = 'Unable to load events';
  static const unableToUpdateEvent = 'Unable to update the event';
  static const unableToDeleteEvent = 'Unable to delete the event';
  static const eventNotFound = 'Event could not be found';
  static const adminAccessRequiredForEvents =
      'Admin access is required to create events';
  static const cannotUpdateEvent =
      'You do not have permission to update this event';
  static const cannotDeleteEvent =
      'You do not have permission to delete this event';
  static const noEventsCreated = 'No events created yet';
  static const noRegisteredEvents = 'No registered events yet';
  static const noMatchingEvents = 'No matching events found';
  static const searchFestivalsOrEvents = 'Search festivals or events...';
  static const noNewNotifications = 'No new notifications';
    static const notifications = 'Notifications';
    static const noNotifications = 'No notifications yet';
    static const unableToLoadNotifications = 'Unable to load notifications';
    static const unableToUpdateArrival = 'Unable to update arrival status';
    static const arrivalConfirmation = 'Will you attend this event?';
    static const attending = 'I will attend';
    static const notAttending = 'I cannot attend';
    static const arrivalConfirmed = 'Arrival status updated';
  static const pleaseWait = 'Please wait';
}

abstract final class AppAssets {
  static const logo = 'assets/logo/bdo_event.png';
  static const defaultAvatarUrl =
      'https://yt3.ggpht.com/yti/ANjgQV_bOKivh_MVo0VJcxLjy_iAfiAyY4wThz34mHihfEe6ow=s88-c-k-c0x00ffffff-no-rj';
  static const assetPathPrefix = 'assets/';
  static const mayDay = 'assets/festivals/1_may.png';
  static const diwali = 'assets/festivals/diwali.png';
  static const ganapati = 'assets/festivals/ganapati.png';
}

abstract final class AppStorageKeys {
  static const displayName = 'display_name';
  static const notificationsEnabled = 'notifications_enabled';
}

abstract final class AppDatabase {
  static const eventsTable = 'events';
  static const eventRegistrationsTable = 'event_registrations';
  static const id = 'id';
  static const eventId = 'event_id';
  static const userId = 'user_id';
  static const creatorId = 'creator_id';
  static const createdAt = 'created_at';
  static const registeredAt = 'registered_at';
  static const registrationStatus = 'status';
  static const cancelledAt = 'cancelled_at';
  static const registrationToken = 'registration_token';
  static const checkInsTable = 'event_check_ins';
  static const checkedInAt = 'checked_in_at';
  static const checkedInBy = 'checked_in_by';
  static const activeRegistration = 'active';
  static const revokedRegistration = 'revoked';
  static const payload = 'payload';
  static const isCheckedIn = 'is_checked_in';
}

abstract final class AppIdentifiers {
  static const qrRegistrationType = 'bdo_event_registration';
  static const createdEventPrefix = 'created-';
  static const profileMenuValue = 'profile';
  static const logoutMenuValue = 'logout';
  static const storedEventFilePrefix = 'event_';
  static const storedEventFileExtension = '.jpg';
}

abstract final class AppLocations {
  static const mumbaiZoneOneId = 'mumbai-zone-1';
  static const bangaloreEastId = 'bangalore-east';
  static const kolkataNorthId = 'kolkata-north';
  static const mumbaiZoneTwoId = 'mumbai-zone-2';
  static const bangaloreWestId = 'bangalore-west';
  static const kolkataSouthId = 'kolkata-south';
  static const bdoRiseHyderabadId = 'Hyderabad-south';
  static const bdoRiseAhmedabadId = 'Ahmedabad';
  static const bdoRiseGurugramId = 'Gurugram';

  static const delhiNcrId = 'delhi-ncr';

  static const bdoRiseMumbaiId = 'bdo-rise-mumbai';
  static const bdoRiseBengaluruId = 'bdo-rise-bengaluru';
  static const bdoRiseKolkataId = 'bdo-rise-kolkata';
  static const bdoRiseDelhiNcrId = 'bdo-rise-delhi-ncr';
  static const bdoRiseOffice = 'BDO RISE Office';
  static const mumbai = 'Mumbai';
  static const bangalore = 'Bangalore';
  static const kolkata = 'Kolkata';
  static const delhi = 'Delhi';
  static const hyderabad = 'hyderabad';
  static const ahmedabad = 'ahmedabad';
  static const gurugram = 'gurugram';

  static const india = 'India';
  static const zoneOne = 'Zone 1';
  static const zoneTwo = 'Zone 2';
  static const east = 'East';
  static const west = 'West';
  static const north = 'North';
  static const south = 'South';
  static const ncr = 'NCR';
}
