import 'dart:async';
import 'dart:convert';

import 'package:process_run/process_run.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

void main() async {
  var controller = ShellLinesController();
  var shell = Shell(workingDirectory: '../../../', stdout: controller.sink);

  // read stdout line by line, ws uri will be shown there
  controller.stream.listen((event) async {
    if (event.contains('uri=')) {
      final uri = event.split('uri=http://').last;
      await webSocketChannel('ws://$uri/ws');
    }
  });

  // run Flutter app in profile mode
  try {
    await shell.run(
      '''
    flutter run --profile
  ''',
    );
  } on ShellException catch (e) {
    print(e);
  }
}

Future<void> webSocketChannel(String uri) async {
  const allTimelineEvents = [
    'InheritedWidget',
    'Provider',
    'Cubit',
    'Bloc',
    'Riverpod',
    'Redux',
    'June',
    'MobX'
  ];
  List<Data> result = List.generate(
    allTimelineEvents.length - 1,
    (index) => Data(
      name: allTimelineEvents[index],
      count: 0,
      average: 0.0,
    ),
  );
  final WebSocketChannel channel = WebSocketChannel.connect(Uri.parse(uri));

  await channel.ready;

  [
    '{"jsonrpc": "2.0","id": "1","method": "setFlag","params": {"name": "pause_isolates_on_start","value": "true"}}',
    '{"jsonrpc": "2.0","id": "2","method": "requirePermissionToResume","params": {"onPauseStart": true,"onPauseReload": false,"onPauseExit": false}}',
    '{"jsonrpc": "2.0","id": "3","method": "getVM","params": {}}',
    '{"jsonrpc": "2.0","id": "4","method": "getStreamHistory","params": {"stream": "Extension"}}',
    '{"jsonrpc": "2.0","id": "5","method": "getStreamHistory","params": {"stream": "Stderr"}}',
    ...[
      'Debug',
      'Extension',
      'GC',
      'Isolate',
      'Logging',
      'Stderr',
      'Stdout',
      'Timeline',
      'VM',
      'Service',
    ]
        .asMap()
        .entries
        .map((stream) =>
            '{"jsonrpc": "2.0","id": "${stream.key + 6}","method": "streamListen","params": {"streamId": "${stream.value}"}}')
        .toList(),
  ].forEach((message) => channel.sink.add(message));

  channel.stream.listen(
    (message) {
      final decodedJson = jsonDecode(message);
      if (decodedJson?['result']?['type'] == 'VM') {
        channel.sink.add(
            '{"jsonrpc": "2.0","id": "20","method": "getIsolate","params": {"isolateId": "${decodedJson['result']['isolates'].first['id']}"}}');
      }

      if (decodedJson?['params']?['event']?['timelineEvents']?.runtimeType ==
          List<dynamic>) {
        print('||| ${decodedJson?['params']?['event']?['timelineEvents']} |||');
        final Iterable<dynamic> timeLineEvent =
            decodedJson?['params']?['event']?['timelineEvents'].where(
          (event) => allTimelineEvents.contains(
            event['name'],
          ),
        );
        if (timeLineEvent.isNotEmpty) {
          final start = timeLineEvent.first;
          final end = timeLineEvent.last;
          final diff = end['ts'] - start['ts'];
          final name = start['name'];
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
    },
  );

  Timer(
    const Duration(minutes: 1),
    () {
      channel.sink.close();
      for (var data in result) {
        print('||| ${data.name}: ${data.average} |||');
      }
    },
  );
}
