import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const URL = "https://api.hgbrasil.com/finance?key=82d35fa7&format=json";

void main() async {
  print(await getData());

  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber),
          ))));
}

Future<Map> getData() async {
  http.Response resp = await http.get(URL);
  return json.decode(resp.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController realController = TextEditingController();
  final TextEditingController dolarController = TextEditingController();
  final TextEditingController euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {

    if (text.isEmpty) {
      return _clear();
    }

    double real = double.parse(text);

    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {

    if (text.isEmpty) {
      return _clear();
    }

    double dolar = double.parse(text);

    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar /euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {

    if (text.isEmpty) {
      return _clear();
    }

    double euro = double.parse(text);

    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clear() {
    realController.text  = "";
    dolarController.text = "";
    euroController.text  = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados....",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on,
                          size: 150.0, color: Colors.amber),
                      buildTextField(
                          "Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField(
                          "Dólares", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euros", "€", euroController, _euroChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function fun) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: fun,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
