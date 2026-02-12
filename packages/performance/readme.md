### Performance monitor

this is a little tool to measure how each state management performs.

- Run the app:

Make sure your emulator or adb is connected

```shell
dart main.dart
```

This will:

- init
  a [shell](https://github.com/tekartik/process_run.dart/blob/master/packages/process_run/doc/shell.md)
  from the app's root
- run `flutter pub get`
- run `flutter run --debug`
    - the debug flag is not necessary for now, but:
    - initially, I meant to
      use [addPostFrameCallback ](https://api.flutter.dev/flutter/scheduler/SchedulerBinding/addPostFrameCallback.html)
    - this is because it comes out of the box with a nice implementation of
      the [Timeline class](https://api.dart.dev/dart-developer/Timeline-class.html)
    - and by looking at its implementation:
      it [requires a debug build](https://github.com/flutter/flutter/blob/c6260a86f662c72c13cb3ee26ffad89642afd32b/packages/flutter/lib/src/scheduler/binding.dart#L789C1-L794C77)
    - it also
      requires [debugTracePostFrameCallbacks ](https://api.flutter.dev/flutter/scheduler/debugTracePostFrameCallbacks.html)
      to be set to true
    - this needs to be done manually, in
      your [local Flutter SDK](https://github.com/flutter/flutter/blob/a0ba2decab156c88708c4261d40660ab8f60da5f/packages/flutter/lib/src/scheduler/debug.dart#L70)
- start listening to the shell lines controller
- isolate the ws URI
- use `package:vm_service` to connect to the VM
    - initially, I meant to use a webSocket connection to the ws URI
    - unfortunately, that turned out to
      be [more complicated than expected](https://github.com/flutter/devtools/issues/8566)
    -
    fortunately, [Dart / Flutter tooling uses package:vm_service to pull timeline data from the connected app](https://github.com/flutter/devtools/issues/8566#issuecomment-2504788133)
- listen for state management TimelineEvents
    - each UI widget implements its
      own [Timeline tracing events](https://api.dart.dev/dart-developer/Timeline-class.html)
    - the docs
      suggest [running the app in profile mode](https://docs.flutter.dev/testing/code-debugging#trace-dart-code-performance,
      but that is misleading, see docs from binding.dart above
    - Timeline events will be tracked in
      the [devTools](https://docs.flutter.dev/tools/devtools/performance#timeline-events-tab) as
      well
- aggregate and display an average update time
    - I
      found [this implementation](https://github.com/dart-lang/sdk/blob/main/pkg/vm_service/example/vm_service_tester.dart)
      very useful
    -
    the [Timeline StreamId](https://github.com/dart-lang/sdk/blob/5430e686807911940bf2412e65def9567f69c7d3/pkg/vm_service/lib/src/vm_service.dart#L1829)
    allows to listen to the custom events

#### Roadmap, TODO:

- implement more state management solutions:
    - https://pub.dev/packages/signals
    - https://pub.dev/packages/my_own_mvvm_with_dependency_injection_blackjack_and_hookers
- track more metrics, like maybe widget rebuild time
- make results more consistent. Number are fairly realistic, but it's clear there are some big
  outliers

#### Example Output

```terminaloutput
2026-02-12T15:14:14.594119      I       vmServiceConnection:     Dart process started.
2026-02-12T15:14:14.719768      I       vmServiceConnection:     VM service web socket connected.
2026-02-12T15:14:14.727062      D       vmServiceConnection.<ac>:        message: {"jsonrpc":"2.0","id":"0","method":"streamListen","params":{"streamId":"Isolate"}}
2026-02-12T15:14:14.737322      D       vmServiceConnection.<ac>:        message: {"jsonrpc":"2.0","id":"1","method":"streamListen","params":{"streamId":"Timeline"}}
2026-02-12T15:14:14.738654      D       vmServiceConnection.<ac>:        message: {"jsonrpc":"2.0","id":"2","method":"getVM","params":{}}
2026-02-12T15:14:14.766393      I       vmServiceConnection:     isolates: [[IsolateRef id: isolates/5879988945503987, number: 5879988945503987, name: main, isSystemIsolate: false, isolateGroupId: isolateGroups/5782732084646420]]
2026-02-12T15:14:14.766908      D       vmServiceConnection.<ac>:        message: {"jsonrpc":"2.0","id":"3","method":"getIsolate","params":{"isolateId":"isolates/5879988945503987"}}
2026-02-12T15:14:14.829769      I       vmServiceConnection:     isolateById: [Isolate]
2026-02-12T15:19:14.833416      I       vmServiceConnection.<ac>:        Waiting for service client to shut down...
2026-02-12T15:19:14.847983      I       vmServiceConnection.<ac>:        Service client shut down.
2026-02-12T15:19:14.850220      I       vmServiceConnection.<ac>:        || Inherited            | 0.13916693601089145 milliseconds
2026-02-12T15:19:14.850523      I       vmServiceConnection.<ac>:        || Provider             | 2.0604447245762905 milliseconds
2026-02-12T15:19:14.850705      I       vmServiceConnection.<ac>:        || Cubit                | 2.1227956789664715 milliseconds
2026-02-12T15:19:14.850892      I       vmServiceConnection.<ac>:        || Bloc                 | 3.5389446164003044 milliseconds
2026-02-12T15:19:14.851050      I       vmServiceConnection.<ac>:        || Riverpod             | 1.8133529445527636 milliseconds
2026-02-12T15:19:14.851208      I       vmServiceConnection.<ac>:        || Redux                | 1.259199089667205 milliseconds
2026-02-12T15:19:14.851363      I       vmServiceConnection.<ac>:        || June                 | 2.4625874822750693 milliseconds
2026-02-12T15:19:14.851513      I       vmServiceConnection.<ac>:        || MobX                 | 4.834875953179628 milliseconds
```