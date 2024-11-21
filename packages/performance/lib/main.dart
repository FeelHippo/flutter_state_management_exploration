import 'package:flutter/services.dart';

void main() {
  const systemChannels = SystemChannels.system;
  print('~~~ ${systemChannels.name}');
  print('~~~ ${systemChannels.binaryMessenger}');
  print('~~~ ${systemChannels.codec}');
}
