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
  static const appVersion = 'App version';
  static const appVersionValue = 'Version 1.0.0 (1)';
  static const licenses = 'Licenses';

  static const upcoming = 'Upcoming';
  static const myEvents = 'My Events';
    static const past = 'Past';
    static const eventTabs = [upcoming, myEvents, past];
    static const recentlyViewed = 'Recently viewed';
    static const upcomingEvents = 'Upcoming Events';
    static const pastEvents = 'Past Events';
    static const quietMoment = 'A quiet moment';
    static const eventsWillAppearHere =
            '{tabTitle} will appear here when there is something to explore.';
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
    static const startTime = 'Start time';
    static const endTime = 'End time';
    static const chooseStartTime = 'Choose a start time';
    static const chooseEndTime = 'Choose an end time';
    static const chooseStartAndEndTime = 'Choose a start and end time';
    static const endTimeMustBeAfterStart = 'End time must be after start time';
    static const limitSeats = 'Limit seats';
    static const seats = 'Seats';
    static const positiveNumber = 'Enter a positive number';
    static const registrationDeadline = 'Registration deadline';
    static const chooseRegistrationDeadline = 'Choose a registration deadline';
    static const deadlineMustBeInFuture = 'Deadline must be in the future';
    static const deadlineDateAndTime = 'Deadline date and time';
  static const location = 'Location';
    static const selectLocation = 'Select location';
    static const searchAddressOrPlace = 'Search an address or place';
    static const eventAnalysis = 'Event analysis';
    static const operationsEventAnalysis = 'OPERATIONS / EVENT ANALYSIS';
    static const refreshAnalytics = 'Refresh analytics';
    static const unableToLoadAnalytics = 'Unable to load analytics';
    static const inviteUsers = 'Invite users';
    static const unableToSendInvitations = 'Unable to send invitations';
    static const unableToLoadUsers = 'Unable to load users';
    static const noUsersAvailableToInvite = 'No users available to invite';
    static const selectAllUsers = 'Select all users';
    static const noSavedEvents = 'You have not saved any events yet.';
    static const phoneNumber = 'Phone number';
    static const bio = 'Bio';
    static const englishIndiaFull = 'English (India)';
    static const englishUnitedStates = 'English (United States)';
    static const unableToUploadProfilePhoto = 'Unable to upload profile photo';
    static const change = 'Change';
    static const remove = 'Remove';
    static const fieldCannotBeChanged = 'This field cannot be changed';
    static const biometricAuthenticationUnavailable =
            'Biometric authentication is unavailable.';
    static const dateFormat = 'Date format';
    static const profileVisibility = 'Profile visibility';
    static const registrationVisibility = 'Registration visibility';
    static const viewAttendees = 'View attendees';
    static const viewEventAnalytics = 'View event analytics';
    static const exploreEvents = 'Explore events';
    static const eventAttendees = 'Event attendees';
    static const unableToLoadAttendees = 'Unable to load attendees';
    static const noAttendeesRegistered = 'No attendees registered yet';
    static const shareCsv = 'Share CSV';
    static const copyAttendeeListAsCsv = 'Copy attendee list as CSV';
    static const attendeeCsvCopied = 'Attendee CSV copied';
    static const shareEvent = 'Share event';
    static const unlockApp = 'Unlock app';
    static const unableToUpdateInvitation = 'Unable to update invitation';
    static const wouldYouLikeToAttend = 'Would you like to attend?';
    static const accept = 'Accept';
    static const decline = 'Decline';
    static const eventDatePrefix = 'Event date:';

    static String registeredForEvent(String eventTitle) =>
            'Registered for $eventTitle';
    static String attendeeListFor(String eventTitle) =>
            'Attendee list for $eventTitle';
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
  static const pleaseSignInToChangePassword =
      'Please sign in to change your password';
  static const unableToChangePassword = 'Unable to change password';
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
  static const registrationCode = 'Registration code for manual entry';
  static const copyRegistrationCode = 'Copy registration code';
  static const registrationCodeCopied = 'Registration code copied';
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
  static const organizerTools = 'Organizer Tools';
  static const manageMyEvents = 'Manage my events';
  static const saveProfile = 'Save profile';
  static const profileUpdated = 'Profile updated successfully';
  static const unableToUpdateProfile = 'Unable to update profile';
  static const changePassword = 'Change Password';
  static const changePasswordDescription = 'Update your account password';
  static const newPassword = 'New password';
  static const confirmNewPassword = 'Confirm new password';
  static const passwordChanged = 'Password changed successfully';
  static const savePassword = 'Save password';
  static const cancel = 'Cancel';
  static const myEventRegistrations = 'My Event Registrations';
  static const savedEvents = 'Saved events';
  static const paymentMethods = 'Payment Methods';
  static const preferences = 'Preferences';
  static const pushNotifications = 'Push Notifications';
  static const eventReminders = 'Event Reminders';
  static const eventRemindersDescription =
      'Get notified before registered events';
  static const reminderLeadTime = 'Reminder lead time';
  static const reminderLeadTimeDescription =
      'Choose when event reminders arrive';
  static const oneHourBefore = '1 hour before';
  static const oneDayBefore = '1 day before';
  static const oneWeekBefore = '1 week before';
  static const darkThemeMode = 'Dark Theme Mode';
  static const largerText = 'Larger text';
  static const largerTextDescription = 'Increase text size across the app';
  static const highContrast = 'High contrast';
  static const highContrastDescription =
      'Increase color contrast across the app';
  static const appLanguage = 'App Language';
  static const englishIndia = 'English (IN)';
  static const supportLegal = 'Support & Legal';
  static const helpCenterFaq = 'Help Center & FAQ';
  static const privacyPolicy = 'Privacy Policy';
  static const signOutEverywhere = 'Sign out from all devices';
  static const signOutEverywhereDescription =
      'End active sessions on every device';
  static const signOutEverywhereQuestion = 'Sign out everywhere?';
  static const signOutEverywhereWarning =
      'You will need to sign in again on all of your devices.';
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

  static String reminderLeadTimeLabel(int minutes) => switch (minutes) {
    60 => oneHourBefore,
    10080 => oneWeekBefore,
    _ => oneDayBefore,
  };
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
  static const unableToSignOutEverywhere =
      'Unable to sign out from all devices';
  static const pleaseSignInToManageEvents = 'Please sign in to manage events';
  static const pleaseSignInToRegister = 'Please sign in to register for events';
  static const pleaseSignInToModifyRegistrations =
      'Please sign in to modify registrations';
  static const eventNoLongerAvailable =
      'This event is no longer available for registration';
  static const eventAtCapacity = 'This event has reached its capacity';
  static const registrationDeadlinePassed =
      'Registration for this event has closed';
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
  static const watcherSettings = 'Watcher settings';
  static const unmuteScanningVoice = 'Unmute scanning voice';
  static const muteScanningVoice = 'Mute scanning voice';
  static const toggleFlashLight = 'Toggle flashlight';
  static const switchCamera = 'Switch camera';
  static const pendingCheckIn = 'Pending check-in';
  static const unknownAttendee = 'Unknown attendee';
  static const validateRegistrationCode = 'Validate registration code';
  static const checkedInitial = 'Checked in';
  static const expected = 'Expected';
  static const viewScanHistory = 'View scan history';
  static const cofirmCheckedIn = 'Confirm check-in';
  static const cancelregisterTooltip =
      "you can register upto the date of event";

  static const muteScanningVoiceDescription =
      'Silence spoken scan results while keeping scanning active.';
  static const scanVibration = 'Scan vibration';
  static const scanVibrationDescription =
      'Vibrate after a successful registration scan.';
  static const scannerSoundVolume = 'Scanner sound volume';
  static const scannerSoundVolumeDescription =
      'Adjust the volume of spoken scan results.';
  static const autoOpenNextAttendee = 'Automatically open next attendee';
  static const autoOpenNextAttendeeDescription =
      'Select the next pending attendee after check-in.';
  static const keepHistoryVisibleAfterCheckIn =
      'Keep scan history visible after check-in';
  static const keepHistoryVisibleAfterCheckInDescription =
      'Leave the scan history open after confirming an attendee.';
  static const scanRegistrationPrompt = 'Scan a registration QR code';
  static const enterRegistrationCode = 'Enter registration code from My Ticket';
  static const pasteRegistrationCode = 'Paste the code shown below the QR';
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
    static const unableToFindLocation = 'Unable to find that location';
  static const unableToUploadEventImage = 'Unable to upload the event image';
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
  static const noEventsFound = 'No events found';
  static const calendarReady = 'Your calendar is ready';
  static const registeredEventsWillAppearHere =
      'Registered events will appear here so you can find every ticket in one place.';
  static const capacityTrajectory = 'Capacity trajectory';
  static const registrationsMappedAgainstCapacity =
      'Current registrations mapped against event capacity';
  static const operationalInsight = 'Operational insight';
  static const quickReadOnEventState = 'A quick read on the current event state';
  static const capacityReached = 'Capacity reached';
  static const attendanceIsActive = 'Attendance is active';
  static const readyForEventDay = 'Ready for event day';
  static const eventAtCapacityInsight =
      'Your event is at capacity. Keep an eye on check-in throughput.';
  static const noCheckInsRecorded =
      'No check-ins recorded yet. This panel will become live when attendees arrive.';
  static const attendanceMix = 'Attendance mix';
  static const registrationToArrivalConversion =
      'Registration to arrival conversion';
  static const analyticsCheckedIn = 'Checked in';
  static const awaitingArrival = 'Awaiting arrival';

  static String invitationsSent(int count) => '$count invitation(s) sent';
  static String sendToUsers(int count) => 'Send to $count users';
  static String attendeesArrived(int count) =>
      '$count attendee${count == 1 ? '' : 's'} have arrived. The live conversion signal is updating.';
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
  static const alreadyCheckedIn2 = 'Already checked in';
  static const notScanYet = 'No scans yet';
  static const scanHistory = 'Scan history';
  static const confirmAll = 'Confirm all';
  static const qrInitilDescription =
      'Give this code to event staff if the QR code cannot be scanned.';

  static const ticketDeparting = 'Ticket is departing...';
  static const nullCount = '--';
  static const profileUnavailable = 'Profile unavailable';
  static const empty = '';
}
