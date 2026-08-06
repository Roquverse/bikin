// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_booking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TicketTiers)
final ticketTiersProvider = TicketTiersFamily._();

final class TicketTiersProvider
    extends $AsyncNotifierProvider<TicketTiers, List<TicketTierModel>> {
  TicketTiersProvider._({
    required TicketTiersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ticketTiersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ticketTiersHash();

  @override
  String toString() {
    return r'ticketTiersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TicketTiers create() => TicketTiers();

  @override
  bool operator ==(Object other) {
    return other is TicketTiersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ticketTiersHash() => r'0bd552f332bc1e6a794ebf711b39e9f53ac2d6b0';

final class TicketTiersFamily extends $Family
    with
        $ClassFamilyOverride<
          TicketTiers,
          AsyncValue<List<TicketTierModel>>,
          List<TicketTierModel>,
          FutureOr<List<TicketTierModel>>,
          String
        > {
  TicketTiersFamily._()
    : super(
        retry: null,
        name: r'ticketTiersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TicketTiersProvider call(String videoId) =>
      TicketTiersProvider._(argument: videoId, from: this);

  @override
  String toString() => r'ticketTiersProvider';
}

abstract class _$TicketTiers extends $AsyncNotifier<List<TicketTierModel>> {
  late final _$args = ref.$arg as String;
  String get videoId => _$args;

  FutureOr<List<TicketTierModel>> build(String videoId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<TicketTierModel>>, List<TicketTierModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<TicketTierModel>>,
                List<TicketTierModel>
              >,
              AsyncValue<List<TicketTierModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(TicketBooking)
final ticketBookingProvider = TicketBookingFamily._();

final class TicketBookingProvider
    extends $NotifierProvider<TicketBooking, Map<String, int>> {
  TicketBookingProvider._({
    required TicketBookingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ticketBookingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ticketBookingHash();

  @override
  String toString() {
    return r'ticketBookingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TicketBooking create() => TicketBooking();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, int>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TicketBookingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ticketBookingHash() => r'fd3e49834936caff496aefa964bd5491846bcbb6';

final class TicketBookingFamily extends $Family
    with
        $ClassFamilyOverride<
          TicketBooking,
          Map<String, int>,
          Map<String, int>,
          Map<String, int>,
          String
        > {
  TicketBookingFamily._()
    : super(
        retry: null,
        name: r'ticketBookingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TicketBookingProvider call(String videoId) =>
      TicketBookingProvider._(argument: videoId, from: this);

  @override
  String toString() => r'ticketBookingProvider';
}

abstract class _$TicketBooking extends $Notifier<Map<String, int>> {
  late final _$args = ref.$arg as String;
  String get videoId => _$args;

  Map<String, int> build(String videoId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<String, int>, Map<String, int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, int>, Map<String, int>>,
              Map<String, int>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
