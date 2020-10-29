import 'dart:convert';
import 'package:http/http.dart' as http;

class TimberServices {
  static Future<void> sendLog(String message) async{
    try{
      String url = 'https://us-central1-chedraui-omnicanal.cloudfunctions.net/api_app_logs/api';
      String query = 'mutation SaveLog(\$data: InputLog) { addLog(data: \$data) { message } }';
      
      var now = new DateTime.now();
      var year = now.year.toString();
      var month = now.month.toString();
      var day = now.day.toString();
      var hour = now.hour.toString();
      var minute = now.minute.toString();
      var second = now.second.toString();
      var timezone = now.timeZoneName;

      Map<String, String> headers = {
        // 'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwczovL2FwaS50aW1iZXIuaW8vIiwiZXhwIjpudWxsLCJpYXQiOjE1Njc1MTg4NjYsImlzcyI6Imh0dHBzOi8vYXBpLnRpbWJlci5pby9hcGlfa2V5cyIsInByb3ZpZGVyX2NsYWltcyI6eyJhcGlfa2V5X2lkIjozNjIyLCJ1c2VyX2lkIjoiYXBpX2tleXwzNjIyIn0sInN1YiI6ImFwaV9rZXl8MzYyMiJ9.RgLbhrG1-RrKbnZ3d8tx8X1_057s0WFDr6Y0UciWWZc',
        'Content-Type': 'application/json'
      };
      Map<String, dynamic> body = {
        'query': query,
        'variables': {
          'data': {
            'level': 'INFO',
            'elapsed_time': 0,
            'hostname': 'com.chedrauimobile.dev.app',
            'method': 'POST',
            'path': '/',
            'name': 'SendLog',
            'operation': 'mutation',
            'route': 'addLog',
            'req_body': message,
            'req_length': message.length,
            'res_body': 'None',
            'res_length': 0,
            'res_status': 0,
            'client_agent': 'Dart/2.7 (dart:io)',
            'client_id': '00-123-FW2',
            'client_country': 'None',
            'client_state': 'None',
            'client_city': 'None',
            'client_timezone': timezone,
            'client_ip': 'None',
            'client_did': 'None',
            'phase': 'development',
            'timestamp': now.millisecondsSinceEpoch.toString(),
            'date': '$year-$month-$day',
            'time': '$hour:$minute:$second',
            'message': message
          }
        },
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body)
      );

      return;
    } catch (e) {
      return;
    }
  }
}