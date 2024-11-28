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
  Fimber.plantTree(DebugTree(useColors: true));

  var controller = ShellLinesController();
  var shell = Shell(workingDirectory: '../../../', stdout: controller.sink);

  // read stdout line by line, ws uri will be shown there
  controller.stream.listen((event) async {
    if (event.contains('uri=')) {
      final uri = event.split('uri=http://').last;
      await vmServiceConnection('ws://$uri/ws', shell);
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
  const allTimelineEvents = [
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
        (timelineEvent) => Data(
          name: timelineEvent,
          count: 0,
          average: 0.0,
        ),
      )
      .toList();

  Fimber.i('Dart process started.');

  serviceClient = await vmServiceConnectUri(
    uri,
    log: StdoutLog(),
  );

  Fimber.i('VM service web socket connected.');

  serviceClient.onSend.listen((message) => Fimber.d('message: $message'));

  serviceClient.onReceive.listen((message) {
    final json = jsonDecode(message);
    if (json?['params']?['event']?['kind'] == 'TimelineEvents') {
      Iterable<dynamic> timeLineEvents =
          json?['params']?['event']?['timelineEvents'];
      if (timeLineEvents.any(
        (timeLineEvent) => allTimelineEvents.contains(
          timeLineEvent?['name'],
        ),
      )) {
        final relevantTimelineEvents = timeLineEvents.where(
          (timeLineEvent) => allTimelineEvents.contains(
            timeLineEvent?['name'],
          ),
        );
        var start = relevantTimelineEvents.first;
        var end = relevantTimelineEvents.last;
        var diff = end['ts'] - start['ts'];
        var name = start['name'];
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

  serviceClient.onIsolateEvent.listen((e) => Fimber.d('onIsolateEvent: $e'));
  serviceClient.onTimelineEvent.listen((e) => TimelineEvent.parse);

  unawaited(serviceClient.streamListen(EventStreams.kIsolate));
  unawaited(serviceClient.streamListen(EventStreams.kTimeline));

  final vm = await serviceClient.getVM();
  final isolates = vm.isolates!;
  Fimber.i('isolates: $isolates');

  final isolateRef = isolates.first;
  await serviceClient.getIsolate(isolateRef.id!);

  Timer(
    const Duration(minutes: 5),
    () async {
      Fimber.i('Waiting for service client to shut down...');
      await serviceClient.dispose();

      await serviceClient.onDone;
      Fimber.i('Service client shut down.');

      for (var data in result) {
        Fimber.i('|| ${data.name}: ${data.average} milliseconds');
      }

      shell.kill();
    },
  );
}
