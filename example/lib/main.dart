import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_kit_reporter/health_kit_reporter.dart';
import 'package:health_kit_reporter/model/payload/category.dart';
import 'package:health_kit_reporter/model/payload/device.dart';
import 'package:health_kit_reporter/model/payload/source.dart';
import 'package:health_kit_reporter/model/payload/source_revision.dart';
import 'package:health_kit_reporter/model/predicate.dart';
import 'package:health_kit_reporter/model/type/category_type.dart';
import 'package:health_kit_reporter/model/type/quantity_type.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final _predicate = Predicate(
    DateTime.now().add(Duration(days: -365)),
    DateTime.now(),
  );
  final _device = Device(
    'FlutterTracker',
    'kvs',
    'T-800',
    '3',
    '3.0',
    '1.1.1',
    'kvs.sample.app',
    '444-888-555',
  );
  final _source = Source(
    'myApp',
    'com.kvs.health_kit_reporter_example',
  );
  final _operatingSystem = OperatingSystem(
    1,
    2,
    3,
  );

  SourceRevision get _sourceRevision => SourceRevision(
        _source,
        '5',
        'fit',
        '4',
        _operatingSystem,
      );

  bool _isAuthorizationRequested = false;

  @override
  void initState() {
    super.initState();
    final initializationSettingsIOs = IOSInitializationSettings();
    final initSettings = InitializationSettings(iOS: initializationSettingsIOs);
    _flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: (string) {
      print(string);
      return Future.value(string);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Health Kit Reporter 3'),
          actions: [
            IconButton(
              onPressed: () async {
                try {
                  final readTypes = <String>[];
                  final writeTypes = <String>[
                    CategoryType.mindfulSession.identifier,
                  ];
                  final isRequested =
                      await HealthKitReporter.requestAuthorization(
                          readTypes, writeTypes);
                  setState(() => _isAuthorizationRequested = isRequested);
                } catch (e) {
                  print(e);
                }
              },
              icon: Icon(Icons.login),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: _isAuthorizationRequested
              ? Center(
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Text('READ'),
                          ElevatedButton(
                              onPressed: () {
                                handleQuantitiySamples();
                              },
                              child: Text('preferredUnit:quantity:statistics')),

                        ],
                      ),
                      Column(
                        children: [
                          Text('WRITE'),

                          ElevatedButton(
                            onPressed: () {
                              saveMindfulMinutes();
                            },
                            child: Text('saveMindfulMinutes'),
                          ),
                        ],
                      ),

                    ],
                  ),
                )
              : Container(),
        ),
      ),
    );
  }

  void saveMindfulMinutes() async {
    try {
      final canWrite = await HealthKitReporter.isAuthorizedToWrite(
          CategoryType.mindfulSession.identifier);
      if (canWrite) {
        final now = DateTime.now();
        final minuteAgo = now.add(Duration(minutes: -10));
        final harmonized = CategoryHarmonized(
          0,
          'Breath Meditation',
          {},
        );
        final mindfulMinutes = Category(
          'testMindfulMinutesUUID',
          CategoryType.mindfulSession.identifier,
          minuteAgo.millisecondsSinceEpoch,
          now.millisecondsSinceEpoch,
          null,
          _sourceRevision,
          harmonized,
        );
        print('try to save: ${mindfulMinutes.map}');
        final saved = await HealthKitReporter.save(mindfulMinutes);
        print('mindfulMinutesSaved: $saved');
      } else {
        print('error canWrite mindfulMinutes: $canWrite');
      }
    } catch (e) {
      print(e);
    }
  }



  void handleQuantitiySamples() async {
    try {
      final preferredUnits = await HealthKitReporter.preferredUnits([
        QuantityType.stepCount,
      ]);
      preferredUnits.forEach((preferredUnit) async {
        final identifier = preferredUnit.identifier;
        final unit = preferredUnit.unit;
        print('preferredUnit: ${preferredUnit.map}');
        final type = QuantityTypeFactory.from(identifier);
        final quantities =
            await HealthKitReporter.quantityQuery(type, unit, _predicate);
        print('quantity: ${quantities.map((e) => e.map).toList()}');
        final statistics =
            await HealthKitReporter.statisticsQuery(type, unit, _predicate);
        print('statistics: ${statistics.map}');
      });
    } catch (e) {
      print(e);
    }
  }

}
