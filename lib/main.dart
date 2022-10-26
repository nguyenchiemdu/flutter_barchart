import 'package:chart_animation/bar_chart/bar_chart_wrapper.dart';
import 'package:chart_animation/bar_chart/model/bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Bar> listbar = [
    Bar(
      value: 300,
      title: 'Bill',
    ),
    Bar(title: 'Simson', value: 550),
    Bar(
      value: 250,
      title: 'Foo',
    ),
    Bar(title: 'Zar', value: 500),
    Bar(
      value: 200,
      title: 'Timir',
    ),
    Bar(title: 'Freg', value: 500),
    Bar(title: 'Burg', value: 499),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Container(
            height: 200,
          ),
          SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: BarChartWrapper(
                listBar: listbar,
                paddingBottom: 20,
                paddingTop: 20,
                barWidth: 50,
                indicatorBuilder: (value) {
                  String text = (value.toInt()).toString();
                  return text;
                },
                onBarTap: (bar) {},
              )),
        ],
      )),
    );
  }
}
