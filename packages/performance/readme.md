### Performance monitor

this is a little tool to measure how each state management performs.

- Run the app:

Make sure your emulator or adb is connected

```shell
dart main.dart
```

This will:
- init a [shell](https://github.com/tekartik/process_run.dart/blob/master/packages/process_run/doc/shell.md) from the app's root
- run `flutter pub get`
- run `flutter run --debug`
  - the debug flag is not necessary for now, but:
  - initially, I meant to use [addPostFrameCallback ](https://api.flutter.dev/flutter/scheduler/SchedulerBinding/addPostFrameCallback.html)
  - this is because it comes out of the box with a nice implementation of the [Timeline class](https://api.dart.dev/dart-developer/Timeline-class.html)
  - and by looking at its implementation: it [requires a debug build](https://github.com/flutter/flutter/blob/c6260a86f662c72c13cb3ee26ffad89642afd32b/packages/flutter/lib/src/scheduler/binding.dart#L789C1-L794C77)
  - it also requires [debugTracePostFrameCallbacks ](https://api.flutter.dev/flutter/scheduler/debugTracePostFrameCallbacks.html) to be set to true
  - this needs to be done manually, in your [local Flutter SDK](https://github.com/flutter/flutter/blob/a0ba2decab156c88708c4261d40660ab8f60da5f/packages/flutter/lib/src/scheduler/debug.dart#L70)
- start listening to the shell lines controller
- isolate the ws URI
- use `package:vm_service` to connect to the VM
  - initially, I meant to use a webSocket connection to the ws URI
  - unfortunately, that turned out to be [more complicated than expected](https://github.com/flutter/devtools/issues/8566)
  - fortunately, [Dart / Flutter tooling uses package:vm_service to pull timeline data from the connected app](https://github.com/flutter/devtools/issues/8566#issuecomment-2504788133) 
- listen for state management TimelineEvents
  - each UI widget implements its own [Timeline tracing events](https://api.dart.dev/dart-developer/Timeline-class.html)
  - the docs suggest [running the app in profile mode](https://docs.flutter.dev/testing/code-debugging#trace-dart-code-performance, but that is misleading, see docs from binding.dart above
  - Timeline events will be tracked in the [devTools](https://docs.flutter.dev/tools/devtools/performance#timeline-events-tab) as well
- aggregate and display an average update time
  - I found [this implementation](https://github.com/dart-lang/sdk/blob/main/pkg/vm_service/example/vm_service_tester.dart) very useful
  - the [Timeline StreamId](https://github.com/dart-lang/sdk/blob/5430e686807911940bf2412e65def9567f69c7d3/pkg/vm_service/lib/src/vm_service.dart#L1829) allows to listen to the custom events

#### Roadmap, TODO:
- implement more state management solutions:
  - https://pub.dev/packages/signals
  - https://pub.dev/packages/my_own_mvvm_with_dependency_injection_blackjack_and_hookers
- track more metrics, like maybe widget rebuild time
- make results more consistent. Number are fairly realistic, but it's clear there are some big outliers