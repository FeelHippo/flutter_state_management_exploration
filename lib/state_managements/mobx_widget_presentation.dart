part of '../main.dart';

/// Observables represent the reactive-state of your application.
/// They can be simple scalars to complex object trees.
/// By defining the state of the application as a tree of observables,
/// you can expose a reactive-state-tree that the UI (or other observers in the app) consume.
class FakeDataMobXState {
  FakeDataMobXState() {
    update = mobx.Action(_update);
  }
  // Actions are how you mutate the observables. Rather than mutating them directly,
  // actions add a semantic meaning to the mutations.
  // For example, instead of just doing value++, firing an increment() action carries more meaning.
  late mobx.Action update;
  void _update() {
    _value.value = FakeData(
      person: Person(random),
      vehicle: Vehicle(random),
      currency: Currency(random),
    );
  }

  final _value = mobx.Observable(
    FakeData(
      person: Person(random),
      vehicle: Vehicle(random),
      currency: Currency(random),
    ),
  );

  FakeData get value => _value.value;
  set value(FakeData fakeData) => _value.value = fakeData;
}

class MobWidgetRender extends StatelessWidget {
  const MobWidgetRender({super.key});

  @override
  Widget build(BuildContext context) {
    var state = FakeDataMobXState();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      state.update();
    });
    // The Observer widget (which is part of the flutter_mobx package),
    // provides a granular observer of the observables used in its builder function.
    // Whenever these observables change, Observer rebuilds and renders.
    return flutter_mobx.Observer(
      builder: (BuildContext context) => FakeDataListTile(
        fakeData: state.value,
      ),
    );
  }
}
