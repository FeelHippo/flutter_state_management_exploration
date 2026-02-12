part of '../main.dart';

/// declare a state
class FakeDataJuneState extends JuneState {
  FakeData fakeData = FakeData(
    person: Person(random),
    vehicle: Vehicle(random),
    currency: Currency(random),
  );

  void update() {
    fakeData = FakeData(
      person: Person(random),
      vehicle: Vehicle(random),
      currency: Currency(random),
    );
    setState();
  }
}

class JuneWidgetConsumer extends StatelessWidget {
  const JuneWidgetConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      // Update the states using the setState method
      Timeline.startSync('June');
      June.getState(() => FakeDataJuneState()).update();
      Timeline.finishSync();
    });
    // The state management wraps the widget to be managed with JuneBuilder
    return JuneBuilder<FakeDataJuneState>(
      () => FakeDataJuneState(),
      builder: (FakeDataJuneState state) => FakeDataListTile(
        fakeData: state.fakeData,
        source: 'J',
      ),
    );
  }
}
