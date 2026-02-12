import 'dart:async';
import 'dart:convert';

import 'package:fimber/fimber.dart';
import 'package:process_run/process_run.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

class StdoutLog extends Log {
  @override
  void warning(String message) => Fimber.w(message);

  @override
  void severe(String message) => Fimber.e(message);
}

class Data {
  Data({
    required this.name,
    required this.count,
    required this.average,
  });

  final String name;
  final int count;
  final double average;

  Data copyWith(
    int newCount,
    int newValue,
  ) {
    return Data(
      name: name,
      count: newCount,
      average: (average + newValue) / newCount,
    );
  }
}

late VmService serviceClient;

void main() async {
  // Plant a tree - the source that will receive log messages.
  Fimber.plantTree(DebugTree(useColors: true));

  // Create a shell lines controller.
  ShellLinesController controller = ShellLinesController();
  // Shell usage:
  // https://github.com/tekartik/process_run.dart/blob/2f66de0ae3d8624f43e4684a12e8979c78ba8ee9/packages/process_run/doc/shell.md?plain=1#L101
  Shell shell = Shell(workingDirectory: '../../../', stdout: controller.sink);

  // read stdout line by line, ws uri will be shown there
  controller.stream.listen((String event) async {
    if (event.contains('uri=')) {
      final String uri = event.split('uri=').last;
      await vmServiceConnection(uri, shell);
    }
  });

  // run Flutter app in debug mode
  try {
    await shell.run(
      '''
    flutter pub get
    flutter run --debug
  ''',
    );
  } on ShellException catch (e) {
    Fimber.e(e.toString());
  }
}

Future<void> vmServiceConnection(String uri, Shell shell) async {
  const List<String> allTimelineEvents = <String>[
    'Inherited',
    'Provider',
    'Cubit',
    'Bloc',
    'Riverpod',
    'Redux',
    'June',
    'MobX'
  ];
  List<Data> result = allTimelineEvents
      .map(
        (String timelineEvent) => Data(
          name: timelineEvent,
          count: 0,
          average: 0.0,
        ),
      )
      .toList();

  Fimber.i('Dart process started.');

  // Connect to the given uri and return a new VmService instance.
  serviceClient = await vmServiceConnectUri(
    uri,
    log: StdoutLog(),
  );

  Fimber.i('VM service web socket connected.');

  serviceClient.onSend
      .listen((String message) => Fimber.d('message: $message'));

  serviceClient.onReceive.listen((String message) {
    final dynamic json = jsonDecode(message);
    if (json?['params']?['event']?['kind'] == 'TimelineEvents') {
      Iterable<dynamic> timeLineEvents =
          json?['params']?['event']?['timelineEvents'] as Iterable<dynamic>;
      final Iterable<dynamic> relevantTimelineEvents = timeLineEvents.where(
        (dynamic timeLineEvent) => allTimelineEvents.contains(
          timeLineEvent?['name'],
        ),
      );
      if (relevantTimelineEvents.isNotEmpty) {
        dynamic start = relevantTimelineEvents.first;
        dynamic end = relevantTimelineEvents.last;
        int diff = (end['ts'] - start['ts']) as int;
        String name = start['name'] as String;
        result = result
            .map(
              (Data data) => data.name == name
                  ? data.copyWith(
                      data.count + 1,
                      diff,
                    )
                  : data,
            )
            .toList();
      }
    }
  });

  // on an event from a VM stream
  serviceClient.onIsolateEvent
      .listen((Event e) => Fimber.d('onIsolateEvent: $e'));
  serviceClient.onTimelineEvent.listen((Event e) => TimelineEvent.parse);

  // subscribes to a stream in the VM
  unawaited(serviceClient.streamListen(EventStreams.kIsolate));
  unawaited(serviceClient.streamListen(EventStreams.kTimeline));

  // returns global information about a Dart virtual machine
  final VM vm = await serviceClient.getVM();
  final List<IsolateRef> isolates = vm.isolates!;
  Fimber.i('isolates: $isolates');

  final IsolateRef isolateRef = isolates.first;
  final Isolate isolateById = await serviceClient.getIsolate(isolateRef.id!);
  Fimber.i('isolateById: $isolateById');

  Timer(
    const Duration(minutes: 5),
    () async {
      Fimber.i('Waiting for service client to shut down...');
      await serviceClient.dispose();

      await serviceClient.onDone;
      Fimber.i('Service client shut down.');

      for (Data data in result) {
        Fimber.i(
            '|| ${data.name + (' ' * (20 - data.name.length))} | ${data.average} milliseconds');
      }

      shell.kill();
    },
  );
}
