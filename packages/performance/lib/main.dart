import 'dart:async';
import 'dart:convert';

import 'package:process_run/process_run.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  var channel;
  void webSocketChannel(String uri) async {
    channel = WebSocketChannel.connect(Uri.parse(uri));

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

    channel.stream.listen((message) {
      final decodedJson = jsonDecode(message);
      if (decodedJson?['result']?['type'] == 'VM') {
        channel.sink.add(
            '{"jsonrpc": "2.0","id": "20","method": "getIsolate","params": {"isolateId": "${decodedJson['result']['isolates'].first['id']}"}}');
      }
      if (decodedJson?['params']?['event']?['timelineEvents']?.runtimeType ==
          List<dynamic>) {
        print(
            '~~~ ${decodedJson?['params']?['event']?['timelineEvents'].any((timelineEvent) => [
                  'InheritedWidget',
                  'Provider',
                  'Cubit',
                  'Bloc',
                  'Riverpod',
                  'Redux',
                  'June',
                  'MobX'
                ].contains(timelineEvent['name']))}');
      }
    });
  }

  var controller = ShellLinesController();
  var shell = Shell(workingDirectory: '../../../', stdout: controller.sink);

  // read stdout line by line, ws uri will be shown there
  controller.stream.listen((event) {
    if (event.contains('uri=')) {
      final uri = event.split('uri=http://').last;
      webSocketChannel('ws://$uri/ws');
    }
    // stop app after 1 minute
    Timer(const Duration(minutes: 1), () {
      channel?.sink.close();
      controller.close();
      shell.kill();
    });
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
