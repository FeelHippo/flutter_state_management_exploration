part of '../main.dart';

class UpdateFakeDataNotifier extends riverpod.Notifier<FakeData> {
  @override
  FakeData build() => FakeData(
        person: Person(random),
        vehicle: Vehicle(random),
        currency: Currency(random),
      );
}

final NotifierProviderImpl<UpdateFakeDataNotifier, FakeData> fakeDataProvider =
    riverpod.NotifierProvider<UpdateFakeDataNotifier, FakeData>(
        UpdateFakeDataNotifier.new);

// Using ConsumerWidget, this allows the widget tree to listen to changes on provider, so that the UI automatically updates when needed
class RiverpodWidgetConsumer extends riverpod.ConsumerWidget {
  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    Timer(const Duration(seconds: 5), () {
      Timeline.startSync('Riverpod');
      // Invalidates the state of the provider, causing it to refresh
      ref.invalidate(fakeDataProvider);
      Timeline.finishSync();
    });
    // Returns the value exposed by a provider and rebuild the widget when that value changes.
    final FakeData fakeData = ref.watch(fakeDataProvider);
    return FakeDataListTile(
      fakeData: fakeData,
      source: 'RP',
    );
  }
}

class RiverpodWidgetRender extends StatelessWidget {
  const RiverpodWidgetRender({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // A widget that stores the state of providers
    return riverpod.ProviderScope(child: RiverpodWidgetConsumer());
  }
}
