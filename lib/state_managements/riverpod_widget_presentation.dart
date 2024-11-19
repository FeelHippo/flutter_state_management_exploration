part of '../main.dart';

class UpdateFakeDataNotifier extends riverpod.Notifier<FakeData> {
  @override
  FakeData build() => FakeData(
        person: Person(random),
        vehicle: Vehicle(random),
        currency: Currency(random),
      );
}

final fakeDataProvider =
    riverpod.NotifierProvider<UpdateFakeDataNotifier, FakeData>(
        UpdateFakeDataNotifier.new);

class RiverpodWidgetConsumer extends riverpod.ConsumerWidget {
  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    Timer(const Duration(seconds: 5), () {
      ref.invalidate(fakeDataProvider);
    });
    final FakeData fakeData = ref.watch(fakeDataProvider);
    return ListTile(
      title: Text(fakeData.person.name()),
      subtitle: Text(
          '${fakeData.vehicle.model()} is worth ${Random().nextInt(100000)} ${fakeData.currency.code()}'),
    );
  }
}

class RiverpodWidgetRender extends StatelessWidget {
  const RiverpodWidgetRender({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return riverpod.ProviderScope(child: RiverpodWidgetConsumer());
  }
}
