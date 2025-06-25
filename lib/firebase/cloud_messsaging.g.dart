// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_messsaging.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(CloudMessaging)
const cloudMessagingProvider = CloudMessagingProvider._();

final class CloudMessagingProvider
    extends $NotifierProvider<CloudMessaging, void> {
  const CloudMessagingProvider._()
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

String _$cloudMessagingHash() => r'e7b1ca03a469d2c91c63648330681342dfd39a86';

abstract class _$CloudMessaging extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
