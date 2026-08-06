// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_interaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VideoInteraction)
final videoInteractionProvider = VideoInteractionFamily._();

final class VideoInteractionProvider
    extends $NotifierProvider<VideoInteraction, VideoModel> {
  VideoInteractionProvider._({
    required VideoInteractionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'videoInteractionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$videoInteractionHash();

  @override
  String toString() {
    return r'videoInteractionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VideoInteraction create() => VideoInteraction();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideoModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideoModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VideoInteractionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$videoInteractionHash() => r'4ee5108d80f458fc402cfa39286c96305157d3ab';

final class VideoInteractionFamily extends $Family
    with
        $ClassFamilyOverride<
          VideoInteraction,
          VideoModel,
          VideoModel,
          VideoModel,
          String
        > {
  VideoInteractionFamily._()
    : super(
        retry: null,
        name: r'videoInteractionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VideoInteractionProvider call(String videoId) =>
      VideoInteractionProvider._(argument: videoId, from: this);

  @override
  String toString() => r'videoInteractionProvider';
}

abstract class _$VideoInteraction extends $Notifier<VideoModel> {
  late final _$args = ref.$arg as String;
  String get videoId => _$args;

  VideoModel build(String videoId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VideoModel, VideoModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VideoModel, VideoModel>,
              VideoModel,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
