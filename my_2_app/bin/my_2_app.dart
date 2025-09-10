import 'package:http/http.dart' as http;

void main(List<String> arguments) async {
  print('AAA');
  var res = await http.get(
    Uri.parse('http://202.28.34.197/tripbooking/trip/15'),
  );
  print(res.body);
  print('CCC');
}

Future<void> testAsync() {
  return Future.delayed(const Duration(seconds: 2), () => print("BBB"));
}
