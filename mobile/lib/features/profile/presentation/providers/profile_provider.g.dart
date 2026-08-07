// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserEvents)
final userEventsProvider = UserEventsProvider._();

final class UserEventsProvider
    extends $AsyncNotifierProvider<UserEvents, List<VideoModel>> {
  UserEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userEventsHash();

  @$internal
  @override
  UserEvents create() => UserEvents();
}

String _$userEventsHash() => r'9f41844139728d3538192fd9e8c3794b12315aa7';

abstract class _$UserEvents extends $AsyncNotifier<List<VideoModel>> {
  FutureOr<List<VideoModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<VideoModel>>, List<VideoModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<VideoModel>>, List<VideoModel>>,
              AsyncValue<List<VideoModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(UserTickets)
final userTicketsProvider = UserTicketsProvider._();

final class UserTicketsProvider
    extends $AsyncNotifierProvider<UserTickets, List<dynamic>> {
  UserTicketsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userTicketsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userTicketsHash();

  @$internal
  @override
  UserTickets create() => UserTickets();
}

String _$userTicketsHash() => r'e068a3664de26c97d5cf174caec55e17aa89664c';

abstract class _$UserTickets extends $AsyncNotifier<List<dynamic>> {
  FutureOr<List<dynamic>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<dynamic>>, List<dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<dynamic>>, List<dynamic>>,
              AsyncValue<List<dynamic>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
