part of '../main.dart';

// One simple action: update fake data
enum Actions { update }

// The reducer, which takes the previous state and updates it in response to an action
FakeData updateReducer(FakeData state, dynamic action) {
  return action == Actions.update
      ? FakeData(
          person: Person(random),
          vehicle: Vehicle(random),
          currency: Currency(random),
        )
      : state;
}

class ReduxWidgetPresentation extends StatelessWidget {
  const ReduxWidgetPresentation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<FakeData, FakeData>(
      converter: (Store<FakeData> store) {
        Timer(const Duration(seconds: 5), () {
          store.dispatch(Actions.update);
        });
        return store.state;
      },
      builder: (BuildContext context, FakeData fakeData) {
        return ListTile(
          title: Text(fakeData.person.name()),
          subtitle: Text(
              '${fakeData.vehicle.model()} is worth ${Random().nextInt(100000)} ${fakeData.currency.code()}'),
        );
      },
    );
  }
}

class ReduxWidgetRender extends StatelessWidget {
  const ReduxWidgetRender({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Store<FakeData>(
      updateReducer,
      initialState: FakeData(
        person: Person(random),
        vehicle: Vehicle(random),
        currency: Currency(random),
      ),
    );
    return StoreProvider<FakeData>(
      store: store,
      child: const ReduxWidgetPresentation(),
    );
  }
}
