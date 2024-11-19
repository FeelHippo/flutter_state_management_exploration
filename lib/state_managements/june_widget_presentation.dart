part of '../main.dart';

/// declare a state
class FakeDataJuneState extends JuneState {
  FakeData fakeData = FakeData(
    person: Person(random),
    vehicle: Vehicle(random),
    currency: Currency(random),
  );
}

class JuneWidgetConsumer extends StatelessWidget {
  const JuneWidgetConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 5), () {
      // Update the states using the setState method
      final state = June.getState(() => FakeDataJuneState());
      state.fakeData = FakeData(
        person: Person(random),
        vehicle: Vehicle(random),
        currency: Currency(random),
      );
      state.setState();
    });
    // The state management wraps the widget to be managed with JuneBuilder
    return JuneBuilder(
      () => FakeDataJuneState(),
      builder: (state) => ListTile(
        title: Text(state.fakeData.person.name()),
        subtitle: Text(
            '${state.fakeData.vehicle.model()} is worth ${Random().nextInt(100000)} ${state.fakeData.currency.code()}'),
      ),
    );
  }
}
