part of '../main.dart';

abstract class FakeDataEvent extends Equatable {
  const FakeDataEvent();
}

class UpdateFakeDataEvent extends FakeDataEvent {
  const UpdateFakeDataEvent();

  @override
  List<Object> get props => <Object>[];
}

class FakeDataState extends Equatable {
  const FakeDataState({
    required this.fakeData,
  });

  final FakeData fakeData;

  FakeDataState copyWith({
    FakeData? fakeData,
  }) {
    return FakeDataState(
      fakeData: fakeData ?? this.fakeData,
    );
  }

  @override
  List<Object> get props => <Object>[fakeData];
}

class FakeDataBloc extends Bloc<FakeDataEvent, FakeDataState> {
  static FakeData initialValue = FakeData(
    person: Person(random),
    vehicle: Vehicle(random),
    currency: Currency(random),
  );
  FakeDataBloc() : super(FakeDataState(fakeData: initialValue)) {
    on<UpdateFakeDataEvent>(handleUpdateFakeDataEvent);
  }

  void handleUpdateFakeDataEvent(
    UpdateFakeDataEvent event,
    Emitter<FakeDataState> emit,
  ) async {
    emit(
      state.copyWith(
        fakeData: FakeData(
          person: Person(random),
          vehicle: Vehicle(random),
          currency: Currency(random),
        ),
      ),
    );
  }
}

class BlocWidgetPresentation extends StatefulWidget {
  const BlocWidgetPresentation({
    super.key,
    required this.fakeData,
  });
  final FakeData fakeData;
  @override
  State<BlocWidgetPresentation> createState() =>
      _BlocWidgetPresentationWidgetState();
}

class _BlocWidgetPresentationWidgetState extends State<BlocWidgetPresentation> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // when _fakeData is updated, only the widgets that depend on it will be rebuilt,
    // which makes the application more efficient and performant.
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      context.read<FakeDataBloc>().add(const UpdateFakeDataEvent());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FakeDataListTile(
      fakeData: widget.fakeData,
      source: 'B',
    );
  }
}

class BlocWidgetRender extends StatelessWidget {
  const BlocWidgetRender({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        // timelineEvent will be calculated in here
        // ideally BlocBuilder<FakeDataCubit, FakeData>(builder: ...
        BlocBuilder<FakeDataBloc, FakeDataState>(
          builder: (BuildContext context, FakeDataState state) {
            // fakeData is the updated state
            return BlocWidgetPresentation(fakeData: state.fakeData);
          },
        );
      },
      debugLabel: 'Bloc',
    );
    // It is used as a dependency injection (DI) widget so that a single
    // instance of a Bloc can be provided to multiple widgets within a subtree.
    return BlocProvider(
      create: (_) => FakeDataBloc(),
      // BlocBuilder handles building a widget in response to new states
      child: BlocBuilder<FakeDataBloc, FakeDataState>(
        builder: (BuildContext context, FakeDataState state) {
          // fakeData is the updated state
          return BlocWidgetPresentation(fakeData: state.fakeData);
        },
      ),
    );
  }
}
