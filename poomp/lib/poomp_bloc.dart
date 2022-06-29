import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

var uri = "http://192.168.1.74:8000/";

enum PoompAction { Play, Fetch }

class PoompBloc {
  var count, target, celebrate;

  final _stateController = StreamController<Map<String, dynamic>>();
  StreamSink get _poompSink => _stateController.sink;
  Stream get poompStream => _stateController.stream;

  final _eventController = StreamController<PoompAction>();
  StreamSink get eventSink => _eventController.sink;
  Stream get _eventStream => _eventController.stream;

  Map<String, dynamic> getData() {
    return {
      "count": count,
      "target": target,
      "celebrate": celebrate,
    };
  }

  PoompBloc() {
    _eventStream.listen((event) async {
      if (event == PoompAction.Play) {
        // Play the horn
        var res = await playPoomp();
        count++;
        if (res != null) celebrate = res["celebrate"];
        _poompSink.add(getData());
      } else if (event == PoompAction.Fetch) {
        // Fetch the value
        try {
          var result = await fetchPoompCount();
          count = result["count"];
          target = result["target"];
          _poompSink.add(getData());
        } catch (e) {
          _poompSink.addError(e);
        }
      }
    });
  }

  void dispose() {
    _stateController.close();
    _eventController.close();
  }
}

Future<Map<String, dynamic>> playPoomp() async {
  var response = await http.post(
    Uri.parse('${uri}poomp/create/'),
  );
  return json.decode(response.body.toString());
}

Future<Map<String, dynamic>> fetchPoompCount() async {
  var response = await http.Client().get(Uri.parse('${uri}poomp/count/'));
  return json.decode(response.body);
}
