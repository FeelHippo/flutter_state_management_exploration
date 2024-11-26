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
    flutter pub get
    flutter run --debug
  ''',
    );
  } on ShellException catch (e) {
    print(e);
  }
}

Future<void> webSocketChannel(String uri) async {
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
  final WebSocketChannel channel = WebSocketChannel.connect(Uri.parse(uri));

  await channel.ready;

  for (var message in [
    '{"jsonrpc": "2.0","id": "1","method": "getVM","params": {}}',
    ...[
      'Debug',
      'Timeline',
      'VM',
    ].asMap().entries.map(
          (stream) =>
              '{"jsonrpc": "2.0","id": "${stream.key + 1}","method": "streamListen","params": {"streamId": "${stream.value}"}}',
        ),
  ]) {
    channel.sink.add(message);
  }

  channel.stream.listen(
    (message) {
      final decodedJson = jsonDecode(message);
      if (decodedJson?['result']?['type'] == 'VM') {
        final String isolateId = decodedJson['result']['isolates'].first['id'];
        Timer.periodic(const Duration(seconds: 5), (timer) {
          channel.sink.add(
            '{"jsonrpc": "2.0","id": "99","method": "getIsolate","params": {"isolateId": "$isolateId"}}',
          );
        });
      }

      if (decodedJson?['params']?['event']?['kind'] == 'TimelineEvents') {
        Iterable<dynamic> timeLineEvents =
            decodedJson?['params']?['event']?['timelineEvents'];
        var relevantTimelineEvents = timeLineEvents.where(
          (timeLineEvent) => allTimelineEvents.any(
            (timelineName) => timeLineEvent['name'].contains(
              timelineName,
            ),
          ),
        );
        if (relevantTimelineEvents.isNotEmpty) {
          print('~~~  $relevantTimelineEvents');
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
    },
  );

  Timer(
    const Duration(minutes: 4),
    () {
      channel.sink.close();
      for (var data in result) {
        print('||| ${data.name}: ${data.average} |||');
      }
    },
  );
}
