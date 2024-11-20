part of '../main.dart';

class FakeDataCubit extends Cubit<FakeData> {
  FakeDataCubit()
      : super(
          FakeData(
            person: Person(random),
            vehicle: Vehicle(random),
            currency: Currency(random),
          ),
        );

  void update() => emit(
        FakeData(
          person: Person(random),
          vehicle: Vehicle(random),
          currency: Currency(random),
        ),
      );
}

class CubitWidgetPresentation extends StatefulWidget {
  const CubitWidgetPresentation({
    super.key,
    required this.fakeData,
  });
  final FakeData fakeData;
  @override
  State<CubitWidgetPresentation> createState() =>
      _CubitWidgetPresentationWidgetState();
}

class _CubitWidgetPresentationWidgetState
    extends State<CubitWidgetPresentation> {
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
          // find the nearest instance of the cubit
          // invoke the update method, which will result in a state update
          // the new state will be provided to the BlocBuilder below
          context.read<FakeDataCubit>().update();
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
    return FakeDataListTile(
      fakeData: widget.fakeData,
      source: 'C',
    );
  }
}

class CubitWidgetRender extends StatelessWidget {
  const CubitWidgetRender({super.key});

  @override
  Widget build(BuildContext context) {
    // It is used as a dependency injection (DI) widget so that a single
    // instance of a Cubit can be provided to multiple widgets within a subtree.
    return BlocProvider(
      create: (_) => FakeDataCubit(),
      // BlocBuilder handles building a widget in response to new states
      child: BlocBuilder<FakeDataCubit, FakeData>(
        builder: (BuildContext context, FakeData fakeData) {
          // fakeData is the updated state
          return CubitWidgetPresentation(fakeData: fakeData);
        },
      ),
    );
  }
}
