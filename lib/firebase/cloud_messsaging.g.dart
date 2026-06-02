// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_messsaging.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CloudMessaging)
final cloudMessagingProvider = CloudMessagingProvider._();

final class CloudMessagingProvider
    extends $NotifierProvider<CloudMessaging, void> {
  CloudMessagingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudMessagingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudMessagingHash();

  @$internal
  @override
  CloudMessaging create() => CloudMessaging();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$cloudMessagingHash() => r'59e5c2e5cb899106e0e1000a43065b37c666c780';

abstract class _$CloudMessaging extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
