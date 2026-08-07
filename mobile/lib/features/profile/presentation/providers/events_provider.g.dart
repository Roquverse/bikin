// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventBookings)
final eventBookingsProvider = EventBookingsFamily._();

final class EventBookingsProvider
    extends $AsyncNotifierProvider<EventBookings, List<dynamic>> {
  EventBookingsProvider._({
    required EventBookingsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventBookingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventBookingsHash();

  @override
  String toString() {
    return r'eventBookingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventBookings create() => EventBookings();

  @override
  bool operator ==(Object other) {
    return other is EventBookingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventBookingsHash() => r'f800eafbd7f01d75427e421c13653803d0a283b3';

final class EventBookingsFamily extends $Family
    with
        $ClassFamilyOverride<
          EventBookings,
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>,
          String
        > {
  EventBookingsFamily._()
    : super(
        retry: null,
        name: r'eventBookingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventBookingsProvider call(String eventId) =>
      EventBookingsProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventBookingsProvider';
}

abstract class _$EventBookings extends $AsyncNotifier<List<dynamic>> {
  late final _$args = ref.$arg as String;
  String get eventId => _$args;

  FutureOr<List<dynamic>> build(String eventId);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}
