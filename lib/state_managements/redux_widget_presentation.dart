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
          Timeline.startSync('Redux');
          store.dispatch(Actions.update);
          Timeline.finishSync();
        });
        return store.state;
      },
      builder: (BuildContext context, FakeData fakeData) {
        return FakeDataListTile(
          fakeData: fakeData,
          source: 'R',
        );
      },
    );
  }
}

// ideally stored in IoC
final Store<FakeData> store = Store<FakeData>(
  updateReducer,
  initialState: FakeData(
    person: Person(random),
    vehicle: Vehicle(random),
    currency: Currency(random),
  ),
);

class ReduxWidgetRender extends StatelessWidget {
  const ReduxWidgetRender({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<FakeData>(
      store: store,
      child: const ReduxWidgetPresentation(),
    );
  }
}
