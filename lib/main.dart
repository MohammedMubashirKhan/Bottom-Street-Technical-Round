import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map? _overView;
  List? _performance;

  Future<bool> makeAPICall() async {
    http.Response responseOverView = await http.get(Uri.parse(
      "https://api.stockedge.com/Api/SecurityDashboardApi/GetCompanyEquityInfoForSecurity/5051?lang=en",
    ));
    http.Response responsePerformance = await http.get(Uri.parse(
      "https://api.stockedge.com/Api/SecurityDashboardApi/GetTechnicalPerformanceBenchmarkForSecurity/5051?lang=en",
    ));

    Map overView = jsonDecode(responseOverView.body);
    _overView = overView;
    // print(_overView!.keys.elementAt(17));

    List perfornamce = jsonDecode(responsePerformance.body);
    _performance = perfornamce;
    // print(perfornamce[0]["ID"]);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: makeAPICall(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  buildOverview(),
                  buildPerfornamce(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Overview",
          style: TextStyle(
            color: Colors.lightBlue[900],
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),
        ),
        const Divider(),
        SizedBox(
          height: 500,
          child: ListView.builder(
            primary: false,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _overView!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _overView!.keys.elementAt(index),
                      style: TextStyle(color: Colors.blue[900]),
                    ),
                    Text(
                      _overView!.values.elementAt(index).toString() == "null"
                          ? "-"
                          : _overView!.values.elementAt(index).toString(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget buildPerfornamce() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Performance",
          style: TextStyle(
            color: Colors.lightBlue[900],
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),
        ),
        const Divider(),
        ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(
            height: 10,
          ),
          itemCount: _performance!.length,
          shrinkWrap: true,
          primary: false,
          itemBuilder: (context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(_performance![index]["Label"].toString()),
                // LinearProgressIndicator(
                //   minHeight: 8,
                //   value: _performance![index]["ChangePercent"],
                // )
                LinearPercentIndicator(
                  width: 200,
                  lineHeight: 25,
                  curve: Curves.linear,
                  animation: true,
                  barRadius: const Radius.circular(5),
                  progressColor: _performance![index]["ChangePercent"] < 0
                      ? const Color.fromARGB(255, 238, 41, 27)
                      : const Color.fromARGB(255, 27, 112, 30),
                  percent: _performance![index]["ChangePercent"] < 0
                      ? ((_performance![index]["ChangePercent"] * -1) / 400)
                      : (_performance![index]["ChangePercent"] / 400),
                ),
                Row(
                  children: [
                    _performance![index]["ChangePercent"] < 0
                        ? const Icon(
                            Icons.arrow_drop_down,
                            color: Color.fromARGB(255, 238, 41, 27),
                          )
                        : const Icon(
                            Icons.arrow_drop_up,
                            color: Color.fromARGB(255, 27, 112, 30),
                          ),
                    Text(
                      _performance![index]["ChangePercent"] < 0
                          ? (_performance![index]["ChangePercent"] * -1)
                              .toStringAsFixed(1)
                          : _performance![index]["ChangePercent"]
                              .toStringAsFixed(1),
                      style: TextStyle(
                          color: _performance![index]["ChangePercent"] > 0
                              ? const Color.fromARGB(255, 27, 112, 30)
                              : const Color.fromARGB(255, 238, 41, 27)),
                    ),
                  ],
                ),
              ],
            );
          },
        )
      ],
    );
  }
}
