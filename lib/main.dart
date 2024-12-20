import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobx/flutter_mobx.dart' as flutter_mobx;
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:june/instance/june_instance.dart';
import 'package:june/state_manager.dart';
import 'package:mobx/mobx.dart' as mobx;
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';

part 'state_managements/bloc_widget_presentation.dart';
part 'state_managements/cubit_widget_presentation.dart';
part 'state_managements/inherited_widget_presentation.dart';
part 'state_managements/june_widget_presentation.dart';
part 'state_managements/mobx_widget_presentation.dart';
part 'state_managements/provider_widget_presentation.dart';
part 'state_managements/redux_widget_presentation.dart';
part 'state_managements/riverpod_widget_presentation.dart';
part 'state_managements/widgets/fake_data_list_tile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter State Management Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: StateManagementList(),
      ),
    );
  }
}

/// use Equatable to be able to compare two instances of this object
class FakeData extends Equatable {
  const FakeData({
    required this.person,
    required this.vehicle,
    required this.currency,
  });
  final Person person;
  final Vehicle vehicle;
  final Currency currency;

  @override
  List<Object> get props => <Object>[
        person,
        vehicle,
        currency,
      ];
}

class StateManagementList extends StatelessWidget {
  const StateManagementList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = <Widget>[
      const InheritedWidgetRender(),
      const ProviderWidgetRender(),
      const CubitWidgetRender(),
      const BlocWidgetRender(),
      const RiverpodWidgetRender(),
      const ReduxWidgetRender(),
      const JuneWidgetConsumer(),
      const MobWidgetRender(),
    ];
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          fillOverscroll: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(32),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return items[index];
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
