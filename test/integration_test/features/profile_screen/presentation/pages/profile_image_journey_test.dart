import 'package:bdo_event/core/util/resource/app_buckets.dart';
import 'package:bdo_event/core/util/resource/app_other.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/features/profile_screen/profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/actors/actor_cleanup.dart';
import '../../../../shared/actors/actor_factory.dart';
import '../../../../shared/actors/supabase_actor_cleanup.dart';
import '../../../../shared/actors/supabase_actor_registrar.dart';
import '../../../../shared/actors/test_actor.dart';
import '../../../../shared/cleanup/cleanup_scope.dart';
import '../../../../shared/cleanup/storage_cleanup.dart';
import '../../../../shared/harness/authenticated_app_harness.dart';
import '../../../../shared/harness/profile_image_test_adapters.dart';
import '../../../../shared/harness/supabase_client_factory.dart';
import '../../../../shared/harness/supabase_environment.dart';
import '../../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late ProvisionedTestActor user;
  SupabaseClient? userClient;
  late SupabaseClient cleanupClient;
  CleanupScope? cleanupScope;
  StorageCleanup? storageCleanup;
  AuthenticatedAppHarness? appHarness;
  String? imagePath;
  String? imageUrl;
  StorageObjectCleanup? trackedImage;

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
    user = await provisioner.create(
      testId: 'profile-image',
      role: TestActorRole.user,
    );
    ActorCleanup(
      scope: cleanupScope!,
      delete: SupabaseActorCleanup(environment: environment).delete,
    ).track(user);
    userClient = await _signIn(
      clientFactory.createAppClient(),
      user,
      registrar,
    );
  });

  tearDown(() async {
    await appHarness?.dispose();
    await userClient?.auth.signOut();
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  testWidgets('uploads and saves a profile image', (tester) async {
    final client = userClient;
    expect(client, isNotNull);
    if (client == null) {
      throw StateError('Profile image client was not created.');
    }
    final session = client.auth.currentSession;
    expect(session, isNotNull);
    if (session == null) {
      throw StateError('Profile image session was not created.');
    }
    final userId = user.userId;
    if (userId == null) {
      throw StateError('Profile image user has no user ID.');
    }

    appHarness = AuthenticatedAppHarness(
      environment: environment,
      session: session,
    );
    await appHarness!.start(
      tester,
      home: ProfileScreen(
        imagePicker: const TestProfileImagePicker(),
        storeImage: (image) async {
          final path = '$userId/${context.namespace('profile-image')}.jpg';
          await client.storage
              .from(AppStorageBuckets.profileImages)
              .uploadBinary(
                path,
                await image.readAsBytes(),
                fileOptions: const FileOptions(
                  contentType: AppMimeTypes.jpeg,
                  upsert: false,
                ),
              );
          imagePath = path;
          imageUrl = client.storage
              .from(AppStorageBuckets.profileImages)
              .getPublicUrl(path);
          trackedImage = storageCleanup!.track(
            bucket: AppStorageBuckets.profileImages,
            path: path,
          );
          return imageUrl!;
        },
        deleteImage: (_) async {
          await trackedImage?.delete();
        },
      ),
    );
    await pumpUntil(tester, find.text(AppText.preferences));
    await tester.tap(find.text(AppText.editProfile));
    await pumpUntil(tester, find.text('Personal details'));
    await tester.tap(find.text(AppText.change));
    await pumpUntil(tester, find.text(AppText.remove));

    await tester.tap(find.byTooltip(AppText.saveProfile));
    await pumpUntil(tester, find.text(AppText.profileUpdated));

    final appUser = Supabase.instance.client.auth.currentUser;
    expect(appUser?.userMetadata?['photo_url'], imageUrl);
    expect(imagePath, isNotNull);
    final stored = await client.storage
        .from(AppStorageBuckets.profileImages)
        .download(imagePath!);
    expect(stored, isNotEmpty);

    await tester.tap(find.text(AppText.editProfile));
    await pumpUntil(tester, find.text('Personal details'));
    await tester.tap(find.text(AppText.remove));
    await tester.tap(find.byTooltip(AppText.saveProfile));
    await pumpUntil(tester, find.text(AppText.profileUpdated));

    expect(trackedImage, isNotNull);
    final clearedUser = Supabase.instance.client.auth.currentUser;
    expect(clearedUser?.userMetadata?['photo_url'], anyOf(isNull, isEmpty));
    await expectLater(
      client.storage.from(AppStorageBuckets.profileImages).download(imagePath!),
      throwsA(isA<Exception>()),
    );
  });
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
