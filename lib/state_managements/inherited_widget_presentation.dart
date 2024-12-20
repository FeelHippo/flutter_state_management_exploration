part of '../main.dart';

/// widget that efficiently propagates information down the tree
class InheritedWidgetData extends InheritedWidget {
  const InheritedWidgetData({
    required Key super.key,
    required this.fakeData,
    required super.child,
  });

  final FakeData fakeData;

  /// To obtain the nearest instance of a particular type of inherited widget from
  /// a build context, use [BuildContext.dependOnInheritedWidgetOfExactType].
  static InheritedWidgetData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedWidgetData>();
  }

  /// Whether the framework should notify widgets that inherit from this widget.
  @override
  bool updateShouldNotify(InheritedWidgetData oldWidget) {
    return oldWidget.fakeData != fakeData;
  }
}

/// wrapper for the inherited widget
/// updates fake data every 5 seconds
class InheritedWidgetRender extends StatefulWidget {
  const InheritedWidgetRender({
    super.key,
  });
  @override
  State<InheritedWidgetRender> createState() => _InheritedWidgetRenderState();
}

class _InheritedWidgetRenderState extends State<InheritedWidgetRender> {
  late FakeData _fakeData;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    // init state
    _fakeData = FakeData(
      person: Person(random),
      vehicle: Vehicle(random),
      currency: Currency(random),
    );

    // when _fakeData is updated, only the widgets that depend on it will be rebuilt,
    // which makes the application more efficient and performant.
    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        setState(() {
          _fakeData = FakeData(
            person: Person(random),
            vehicle: Vehicle(random),
            currency: Currency(random),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedWidgetData(
      key: GlobalKey(),
      fakeData: _fakeData,
      child: const InheritedWidgetPresentationWidget(),
    );
  }
}

class InheritedWidgetPresentationWidget extends StatelessWidget {
  const InheritedWidgetPresentationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Timeline.startSync('Inherited');
    final FakeData? fakeData = InheritedWidgetData.of(context)?.fakeData;
    Timeline.finishSync();
    return fakeData != null
        ? FakeDataListTile(
            fakeData: fakeData,
            source: 'I',
          )
        : Container();
  }
}
