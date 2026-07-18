import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url1 = Uri.parse('http://127.0.0.1:8000/api/v1/free-trial/stages');
  final res1 = await http.get(url1);
  print('Stages: ${res1.body}');
  
  // Try with grade 1
  final url2 = Uri.parse('http://127.0.0.1:8000/api/v1/free-trial/stages/1/grades');
  final res2 = await http.get(url2);
  print('Grades for stage 1: ${res2.body}');
}
