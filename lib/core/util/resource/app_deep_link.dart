
abstract final class AppDeepLinks {
    static const baseUrl = String.fromEnvironment(
        'EVENT_LINK_BASE_URL',
        defaultValue: 'https://bdo-event.app',
    );
    static const httpsScheme = 'https';
    static const customScheme = 'bdoevent';
    static const eventsPath = 'events';
}
