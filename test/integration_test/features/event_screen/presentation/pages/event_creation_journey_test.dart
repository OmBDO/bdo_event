import 'package:bdo_event/core/model/event_model/event_catagory.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:bdo_event/core/common/form_elements/auth_button.dart';
import 'package:bdo_event/features/event_screen/create_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/actors/actor_cleanup.dart';
import '../../../shared/actors/actor_factory.dart';
import '../../../shared/actors/supabase_actor_cleanup.dart';
import '../../../shared/actors/supabase_actor_registrar.dart';
import '../../../shared/actors/test_actor.dart';
import '../../../shared/cleanup/cleanup_scope.dart';
import '../../../shared/cleanup/event_cleanup.dart';
import '../../../shared/cleanup/storage_cleanup.dart';
import '../../../shared/harness/authenticated_app_harness.dart';
import '../../../shared/harness/event_image_test_adapters.dart';
import '../../../shared/harness/supabase_client_factory.dart';
import '../../../shared/harness/supabase_environment.dart';
import '../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late ProvisionedTestActor owner;
  SupabaseClient? ownerClient;
  late SupabaseClient cleanupClient;
  CleanupScope? cleanupScope;
  StorageCleanup? storageCleanup;
  AuthenticatedAppHarness? appHarness;
  String? uploadedImagePath;

  setUp(() async {
    environment = SupabaseEnvironment.fromEnvironment();
    environment.requireCleanupConfiguration();
    context = TestRunContext.create();
    cleanupScope = CleanupScope();
    final clientFactory = SupabaseClientFactory(environment);
    cleanupClient = clientFactory.createCleanupClient();
    storageCleanup = StorageCleanup(
      scope: cleanupScope!,
      delete: (bucket, path) async {
        await cleanupClient.storage.from(bucket).remove([path]);
      },
    );
    registrar = SupabaseActorRegistrar(environment: environment);
    final provisioner = TestActorProvisioner(
      context: context,
      register: registrar.register,
    );
    owner = await provisioner.create(
      testId: 'event-creation',
      role: TestActorRole.owner,
    );
    ActorCleanup(
      scope: cleanupScope!,
      delete: SupabaseActorCleanup(environment: environment).delete,
    ).track(owner);
    ownerClient = await _signIn(
      clientFactory.createAppClient(),
      owner,
      registrar,
    );
  });

  tearDown(() async {
    await appHarness?.dispose();
    await ownerClient?.auth.signOut();
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  testWidgets('creates an event with an uploaded image', (tester) async {
    final client = ownerClient;
    expect(client, isNotNull);
    if (client == null) {
      throw StateError('Event creation owner client was not created.');
    }
    final session = client.auth.currentSession;
    expect(session, isNotNull);
    if (session == null) {
      throw StateError('Event creation owner session was not created.');
    }
    final ownerId = owner.userId;
    if (ownerId == null) {
      throw StateError('Event creation owner has no user ID.');
    }

    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: session,
    );
    await appHarness!.start(
      tester,
      home: CreateEventPage(
        catagory: EventCategory.defaults.first,
        imagePicker: const TestEventImagePicker(),
        storeImage: (image) async {
          final path =
              '$ownerId/${context.namespace('created-image')}.jpg';
          await client.storage.from(AppStorageBuckets.eventImages).uploadBinary(
            path,
            await image.readAsBytes(),
            fileOptions: const FileOptions(
              contentType: AppMimeTypes.jpeg,
              upsert: false,
            ),
          );
          uploadedImagePath = path;
          storageCleanup!.track(
            bucket: AppStorageBuckets.eventImages,
            path: path,
          );
          return path;
        },
        deleteImage: (path) async {
          await client.storage
              .from(AppStorageBuckets.eventImages)
              .remove([path]);
        },
      ),
    );

    await tester.tap(find.text(AppText.addEventImage));
    await tester.pump(const Duration(milliseconds: 100));
    _setField(tester, AppText.eventTitle, '${context.runId} Created Event');
    _setField(tester, AppText.eventDate, '31/12/2029');
    _setField(tester, AppText.startTime, '10:00');
    _setField(tester, AppText.endTime, '11:00');
    _setField(
      tester,
      AppText.description,
      'Created through the UI journey.',
    );
    await tester.tap(find.bySemanticsLabel(AppText.location));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mumbai, India').last);
    await tester.tap(find.widgetWithText(AppButton, AppText.createEvent));
    await pumpUntil(
      tester,
      find.text('${context.runId} Created Event').hitTestable(),
    );

    expect(uploadedImagePath, isNotNull);
    final rows = await cleanupClient
        .from(AppDatabase.eventsTable)
        .select('id, payload')
        .eq(AppDatabase.creatorId, ownerId);
    final createdRows = (rows as List<dynamic>).cast<Map<String, dynamic>>();
    final createdRow = createdRows.firstWhere(
      (row) =>
          (row[AppDatabase.payload] as Map<String, dynamic>)['title'] ==
          '${context.runId} Created Event',
    );
    final createdPayload =
        createdRow[AppDatabase.payload] as Map<String, dynamic>;
    final createdEvent = Event.fromJson({
      ...createdPayload,
      AppDatabase.id: createdRow[AppDatabase.id],
      AppDatabase.creatorId: ownerId,
    });
    EventCleanup(
      scope: cleanupScope!,
      delete: (fixture) async {
        await cleanupClient
            .from(AppDatabase.eventsTable)
            .delete()
            .eq(AppDatabase.id, fixture.eventId);
      },
    ).track(EventFixtureData(event: createdEvent, testId: 'created-event'));
    expect(createdEvent.imageUrl, uploadedImagePath);
    expect(createdEvent.catagory?.name, EventCategory.defaults.first.name);

    final stored = await client.storage
        .from(AppStorageBuckets.eventImages)
        .download(uploadedImagePath!);
    expect(stored, isNotEmpty);
  });
}

void _setField(WidgetTester tester, String label, String value) {
  final field = tester.widget<TextFormField>(
    find.bySemanticsLabel(label),
  );
  field.controller!.text = value;
}

Future<SupabaseClient> _signIn(
  SupabaseClient client,
  ProvisionedTestActor actor,
  SupabaseActorRegistrar registrar,
) async {
  final email = actor.email;
  if (email == null) {
    throw StateError('Authenticated test actor has no email address.');
  }
  await client.auth.signInWithPassword(
    email: email,
    password: registrar.passwordFor(actor.definition),
  );
  return client;
}
