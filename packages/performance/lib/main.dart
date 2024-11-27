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
    '{"jsonrpc": "2.0","id": "2","method": "getStreamHistory","params": {"stream": "Extension"}}',
    '{"jsonrpc": "2.0","id": "3","method": "getStreamHistory","params": {"stream": "Stderr"}}',
    ...[
      'Debug',
      'GC',
      'Isolate',
      'Stdout',
      'Timeline',
      'VM',
    ].asMap().entries.map(
          (stream) =>
              '{"jsonrpc": "2.0","id": "${stream.key + 4}","method": "streamListen","params": {"streamId": "${stream.value}"}}',
        ),
  ]) {
    channel.sink.add(message);
  }

  channel.stream.listen(
    (message) {
      var countId = 10;
      final decodedJson = jsonDecode(message);
      if (decodedJson?['result']?['type'] == 'VM') {
        final String isolateId = decodedJson['result']['isolates'].first['id'];
        Timer.periodic(
          const Duration(milliseconds: 100),
          (timer) {
            // maybe? https://api.flutter.dev/flutter/vm_service/VmService/getVMTimeline.html
            channel.sink.add(
              '{"jsonrpc": "2.0","id": "$countId","method": "getIsolate","params": {"isolateId": "$isolateId"}}',
            );
            countId += 1;
            channel.sink.add(
              '{"jsonrpc": "2.0","id": "$countId","method": "ext.dart.io.httpEnableTimelineLogging","params": {"isolateId": "$isolateId"}}',
            );
            countId += 1;
            channel.sink.add(
              '{"jsonrpc": "2.0","id": "$countId","method": "setVMTimelineFlags","params": {"recordedStreams": ["Dart","Embedder","GC"]}}',
            );
            countId += 1;
            channel.sink.add(
              '{"jsonrpc": "2.0","id": "$countId","method": "getVMTimelineMicros","params": {}}',
            );
            countId += 1;
            channel.sink.add(
              '{"jsonrpc": "2.0","id": "$countId","method": "getVMTimelineFlags","params": {}}',
            );
            countId += 1;
          },
        );
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
        print('~~~  $relevantTimelineEvents');
        if (relevantTimelineEvents.isNotEmpty &&
            relevantTimelineEvents.length >= allTimelineEvents.length) {
          // FIX THE BELOW, you should group relevantTimelineEvents in tuples, by name
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
