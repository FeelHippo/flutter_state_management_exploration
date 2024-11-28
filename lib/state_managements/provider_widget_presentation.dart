part of '../main.dart';

/// ChangeNotifier is one way to encapsulate your application state.
/// The only code that is specific to ChangeNotifier is the call to notifyListeners().
/// Call this method any time the model changes in a way that might change your app's UI
class FakeDataModel extends ChangeNotifier {
  FakeData _fakeData = FakeData(
    person: Person(random),
    vehicle: Vehicle(random),
    currency: Currency(random),
  );

  Widget get listTile => FakeDataListTile(
        fakeData: _fakeData,
        source: 'P',
      );

  void update() {
    _fakeData = FakeData(
      person: Person(random),
      vehicle: Vehicle(random),
      currency: Currency(random),
    );
    notifyListeners();
  }
}

class ProviderWidgetPresentation extends StatefulWidget {
  const ProviderWidgetPresentation({
    super.key,
    required this.fakeDataModel,
  });
  final FakeDataModel fakeDataModel;
  @override
  State<ProviderWidgetPresentation> createState() =>
      _ProviderWidgetPresentationWidgetState();
}

class _ProviderWidgetPresentationWidgetState
    extends State<ProviderWidgetPresentation> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    // when _fakeData is updated, only the widgets that depend on it will be rebuilt,
    // which makes the application more efficient and performant.
    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        setState(() {
          Timeline.startSync('Provider');
          widget.fakeDataModel.update();
          Timeline.finishSync();
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.fakeDataModel.listTile;
  }
}

/// ChangeNotifierProvider is the widget that provides an instance of a ChangeNotifier to its descendants.
/// It should be placed above the widgets that need to access it, but not higher than necessary

class ProviderWidgetRender extends StatelessWidget {
  const ProviderWidgetRender({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FakeDataModel(),
      // Consumer allows to access the provider of <FakeDataModel>
      child: Consumer<FakeDataModel>(
        builder: (context, fakeDataModel, child) {
          return ProviderWidgetPresentation(fakeDataModel: fakeDataModel);
        },
      ),
    );
  }
}
