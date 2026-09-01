import 'dart:typed_data';

import 'package:bdo_event/core/util/resource/app_buckets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../shared/actors/actor_cleanup.dart';
import '../../../shared/actors/actor_factory.dart';
import '../../../shared/actors/supabase_actor_cleanup.dart';
import '../../../shared/actors/supabase_actor_registrar.dart';
import '../../../shared/actors/test_actor.dart';
import '../../../shared/cleanup/cleanup_scope.dart';
import '../../../shared/cleanup/storage_cleanup.dart';
import '../../../shared/harness/supabase_client_factory.dart';
import '../../../shared/harness/supabase_environment.dart';
import '../../../shared/harness/test_run_context.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseEnvironment environment;
  late TestRunContext context;
  late SupabaseActorRegistrar registrar;
  late supabase.SupabaseClient ownerClient;
  late supabase.SupabaseClient otherClient;
  late supabase.SupabaseClient anonymousClient;
  late supabase.SupabaseClient cleanupClient;
  late ProvisionedTestActor owner;
  late ProvisionedTestActor otherUser;
  CleanupScope? cleanupScope;
  StorageCleanup? storageCleanup;

  setUp(() async {
    environment = SupabaseEnvironment.fromEnvironment();
    environment.requireCleanupConfiguration();
    context = TestRunContext.create();
    cleanupScope = CleanupScope();
    final clientFactory = SupabaseClientFactory(environment);
    cleanupClient = clientFactory.createCleanupClient();
    anonymousClient = clientFactory.createAppClient();
    registrar = SupabaseActorRegistrar(environment: environment);
    final provisioner = TestActorProvisioner(
      context: context,
      register: registrar.register,
    );
    final actorCleanup = ActorCleanup(
      scope: cleanupScope!,
      delete: SupabaseActorCleanup(environment: environment).delete,
    );

    owner = await provisioner.create(
      testId: 'event-image-owner',
      role: TestActorRole.user,
    );
    actorCleanup.track(owner);
    otherUser = await provisioner.create(
      testId: 'event-image-other',
      role: TestActorRole.user,
    );
    actorCleanup.track(otherUser);
    ownerClient = await _signIn(
      clientFactory.createAppClient(),
      owner,
      registrar,
    );
    otherClient = await _signIn(
      clientFactory.createAppClient(),
      otherUser,
      registrar,
    );
    storageCleanup = StorageCleanup(
      scope: cleanupScope!,
      delete: (bucket, path) async {
        await cleanupClient.storage.from(bucket).remove([path]);
      },
    );
  });

  tearDown(() async {
    await cleanupScope?.cleanup();
    cleanupScope = null;
  });

  test(
    'enforces private event-image ownership and authenticated reads',
    () async {
      final bucket = AppStorageBuckets.eventImages;
      final path = '${owner.userId}/${context.namespace('event-image')}.jpg';
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final replacement = Uint8List.fromList([4, 5, 6, 7]);
      final trackedObject = storageCleanup!.track(bucket: bucket, path: path);

      await ownerClient.storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const supabase.FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );
      final signedUrl = await otherClient.storage
          .from(bucket)
          .createSignedUrl(path, 60);
      expect(signedUrl, startsWith('http'));

      await expectLater(
        anonymousClient.storage.from(bucket).createSignedUrl(path, 60),
        throwsA(isA<Exception>()),
      );
      final otherPath =
          '${owner.userId}/${context.namespace('unauthorized-upload')}.jpg';
      storageCleanup!.track(bucket: bucket, path: otherPath);
      await expectLater(
        otherClient.storage
            .from(bucket)
            .uploadBinary(
              otherPath,
              bytes,
              fileOptions: const supabase.FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ),
            ),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        otherClient.storage.from(bucket).remove([path]),
        throwsA(isA<Exception>()),
      );

      await ownerClient.storage
          .from(bucket)
          .uploadBinary(
            path,
            replacement,
            fileOptions: const supabase.FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      final downloaded = await ownerClient.storage.from(bucket).download(path);
      expect(downloaded, orderedEquals(replacement));

      await trackedObject.delete();
      await expectLater(
        ownerClient.storage.from(bucket).download(path),
        throwsA(isA<Exception>()),
      );
    },
  );
}

Future<supabase.SupabaseClient> _signIn(
  supabase.SupabaseClient client,
  ProvisionedTestActor actor,
  SupabaseActorRegistrar registrar,
) async {
  await client.auth.signInWithPassword(
    email: actor.email!,
    password: registrar.passwordFor(actor.definition),
  );
  return client;
}
