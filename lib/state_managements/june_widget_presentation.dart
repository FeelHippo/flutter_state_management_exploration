part of '../main.dart';

/// declare a state
class FakeDataJuneState extends JuneState {
  FakeData fakeData = FakeData(
    person: Person(random),
    vehicle: Vehicle(random),
    currency: Currency(random),
  );

  update() {
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
    Timeline.startSync('June');
    WidgetsBinding.instance.addPostFrameCallback((_) => Timeline.finishSync());
    Timer.periodic(const Duration(seconds: 5), (timer) {
      // Update the states using the setState method
      June.getState(() => FakeDataJuneState()).update();
    });
    // The state management wraps the widget to be managed with JuneBuilder
    return JuneBuilder(
      () => FakeDataJuneState(),
      builder: (state) => FakeDataListTile(
        fakeData: state.fakeData,
        source: 'J',
      ),
    );
  }
}
