import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(WebbyFondueApp());
}

class WebbyFondueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Webby Fondue',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReportPage(),
    );
  }
}

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedType;
  bool _urlError = false;
  bool _typeError = false;

  List<Map<String, dynamic>> _webTypes = [
    {"id": "gambling", "title": "เว็บพนัน"},
    {"id": "fraud", "title": "เว็บปลอมแปลง เลียนแบบ"},
    {"id": "fake-news", "title": "เว็บข่าวมั่ว"},
    {"id": "share", "title": "เว็บแชร์ลูกโซ่"},
  ];

  Map<String, String> _webTypeImages = {
    "gambling": "https://cpsu-api-49b593d4e146.herokuapp.com/images/webby_fondue/gambling.jpg",
    "fraud": "https://cpsu-api-49b593d4e146.herokuapp.com/images/webby_fondue/fraud.png",
    "fake-news": "https://cpsu-api-49b593d4e146.herokuapp.com/images/webby_fondue/fake_news_2.jpg",
    "share": "https://cpsu-api-49b593d4e146.herokuapp.com/images/webby_fondue/thief.jpg",
  };

  Future<void> _submitReport() async {
    if (_urlController.text.isEmpty || _selectedType == null) {
      setState(() {
        _urlError = _urlController.text.isEmpty;
        _typeError = _selectedType == null;
      });
      return;
    }

    // Prepare data
    Map<String, dynamic> reportData = {
      "url": _urlController.text,
      "description": _descriptionController.text,
      "type": _selectedType,
    };

    // Send report
    final response = await http.post(
      Uri.parse("https://cpsu-api-49b593d4e146.herokuapp.com/api/2_2566/final/report_web"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(reportData),
    );

    if (response.statusCode == 200) {
      // Report success
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print("Report success: $responseData");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Thank you for your report!"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _urlController.clear();
                    _descriptionController.clear();
                    _selectedType = null;
                    _urlError = false;
                    _typeError = false;
                  });
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      // Report failed
      print("Report failed: ${response.body}");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to submit report. Please try again later."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Webby Fondue"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "ระบบรายงานเว็บเลวๆ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              "*ต้องกรอกข้อมูล",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.red),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "URL *",
                errorText: _urlError ? "URL is required" : null,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "รายละเอียด",
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              "ระบุประเภทเว็บเลว *",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.red),
            ),
            SizedBox(height: 16.0),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              runSpacing: 8.0,
              children: _webTypes.map((webType) {
                return ChoiceChip(
                  label: Text(webType['title']),
                  selected: _selectedType == webType['id'],
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? webType['id'] : null;
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitReport,
              child: Text("ส่งข้อมูล"),
            ),
            SizedBox(height: 16.0),
            if (_urlError || _typeError)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Error: ต้องกรอก URL และเลือกประเภทเว็บ",
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_selectedType != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      "รายละเอียดประเภทเว็บ: ",
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ประเภท: ${_webTypes.firstWhere((webType) => webType['id'] == _selectedType)['title']}",
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          "รายละเอียด: ${_webTypes.firstWhere((webType) => webType['id'] == _selectedType)['subtitle']}",
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 8.0),
                        SizedBox(
                          height: 100,
                          child: Image.network(
                            _webTypeImages[_selectedType]!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(WebbyFondueApp());
// }

// class WebbyFondueApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Webby Fondue',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: ReportPage(),
//     );
//   }
// }

// class ReportPage extends StatefulWidget {
//   @override
//   _ReportPageState createState() => _ReportPageState();
// }

// class _ReportPageState extends State<ReportPage> {
//   final TextEditingController _urlController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   String? _selectedType;
//   bool _urlError = false;
//   bool _typeError = false;

//   List<Map<String, dynamic>> _webTypes = [
//     {"id": "gambling", "title": "เว็บพนัน"},
//     {"id": "fraud", "title": "เว็บปลอมแปลง เลียนแบบ"},
//     {"id": "fake-news", "title": "เว็บข่าวมั่ว"},
//     {"id": "share", "title": "เว็บแชร์ลูกโซ่"},
//   ];

//   Map<String, String> _webTypeImages = {
//     "gambling": "https://cpsu-api-49b593d4e146.herokuapp.com/images/webby_fondue/gambling.jpg",
//     "fraud": "https://cpsu-api-49b593d4e146.herokuapp.com/images/webby_fondue/fraud.png",
//     "fake-news": "https://cpsu-api-49b593d4e146.herokuapp.com/images/webby_fondue/fake_news_2.jpg",
//     "share": "https://cpsu-api-49b593d4e146.herokuapp.com/images/webby_fondue/thief.jpg",
//   };

//   Future<void> _submitReport() async {
//     if (_urlController.text.isEmpty || _selectedType == null) {
//       setState(() {
//         _urlError = _urlController.text.isEmpty;
//         _typeError = _selectedType == null;
//       });
//       return;
//     }

//     // Prepare data
//     Map<String, dynamic> reportData = {
//       "url": _urlController.text,
//       "description": _descriptionController.text,
//       "type": _selectedType,
//     };

//     // Send report
//     final response = await http.post(
//       Uri.parse("https://cpsu-api-49b593d4e146.herokuapp.com/api/2_2566/final/report_web"),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(reportData),
//     );

//     if (response.statusCode == 200) {
//       // Report success
//       Map<String, dynamic> responseData = jsonDecode(response.body);
//       print("Report success: $responseData");
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Success"),
//             content: Text("Thank you for your report!"),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   setState(() {
//                     _urlController.clear();
//                     _descriptionController.clear();
//                     _selectedType = null;
//                     _urlError = false;
//                     _typeError = false;
//                   });
//                 },
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       // Report failed
//       print("Report failed: ${response.body}");
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Error"),
//             content: Text("Failed to submit report. Please try again later."),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Webby Fondue"),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               "ระบบรายงานเว็บเลวๆ",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               "*ต้องกรอกข้อมูล",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16.0, color: Colors.red),
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               controller: _urlController,
//               decoration: InputDecoration(
//                 labelText: "URL *",
//                 errorText: _urlError ? "URL is required" : null,
//               ),
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               controller: _descriptionController,
//               decoration: InputDecoration(
//                 labelText: "รายละเอียด",
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               "ระบุประเภทเว็บเลว *",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16.0, color: Colors.red),
//             ),
//             SizedBox(height: 16.0),
//             Wrap(
//               alignment: WrapAlignment.center,
//               spacing: 8.0,
//               runSpacing: 8.0,
//               children: _webTypes.map((webType) {
//                 return ChoiceChip(
//                   label: Text(webType['title']),
//                   selected: _selectedType == webType['id'],
//                   onSelected: (selected) {
//                     setState(() {
//                       _selectedType = selected ? webType['id'] : null;
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: _submitReport,
//               child: Text("ส่งข้อมูล"),
//             ),
//             SizedBox(height: 16.0),
//                         if (_selectedType != null)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: _webTypes.map((webType) {
//                   return Column(
//                     children: [
//                       Image.network(
//                         _webTypeImages[webType['id']]!,
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         webType['title'],
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   );
//                 }).toList(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(WebbyFondueApp());
// }

// class WebbyFondueApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Webby Fondue',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: ReportPage(),
//     );
//   }
// }

// class ReportPage extends StatefulWidget {
//   @override
//   _ReportPageState createState() => _ReportPageState();
// }

// class _ReportPageState extends State<ReportPage> {
//   final TextEditingController _urlController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   String? _selectedType;
//   bool _urlError = false;
//   bool _typeError = false;

//   List<Map<String, dynamic>> _webTypes = [
//     {"id": "gambling", "title": "เว็บพนัน"},
//     {"id": "fraud", "title": "เว็บปลอมแปลง เลียนแบบ"},
//     {"id": "fake-news", "title": "เว็บข่าวมั่ว"},
//     {"id": "share", "title": "เว็บแชร์ลูกโซ่"},
//   ];

//   Future<void> _submitReport() async {
//     if (_urlController.text.isEmpty || _selectedType == null) {
//       setState(() {
//         _urlError = _urlController.text.isEmpty;
//         _typeError = _selectedType == null;
//       });
//       return;
//     }

//     // Prepare data
//     Map<String, dynamic> reportData = {
//       "url": _urlController.text,
//       "description": _descriptionController.text,
//       "type": _selectedType,
//     };

//     // Send report
//     final response = await http.post(
//       Uri.parse("https://cpsu-api-49b593d4e146.herokuapp.com/api/2_2566/final/report_web"),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(reportData),
//     );

//     if (response.statusCode == 200) {
//       // Report success
//       Map<String, dynamic> responseData = jsonDecode(response.body);
//       print("Report success: $responseData");
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Success"),
//             content: Text("Thank you for your report!"),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   setState(() {
//                     _urlController.clear();
//                     _descriptionController.clear();
//                     _selectedType = null;
//                     _urlError = false;
//                     _typeError = false;
//                   });
//                 },
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       // Report failed
//       print("Report failed: ${response.body}");
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Error"),
//             content: Text("Failed to submit report. Please try again later."),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Webby Fondue"),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               "ระบบรายงานเว็บเลวๆ",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               "*ต้องกรอกข้อมูล",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16.0, color: Colors.red),
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               controller: _urlController,
//               decoration: InputDecoration(
//                 labelText: "URL *",
//                 errorText: _urlError ? "URL is required" : null,
//               ),
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               controller: _descriptionController,
//               decoration: InputDecoration(
//                 labelText: "รายละเอียด",
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               "ระบประเภทเว็บเลว *",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16.0, color: Colors.red),
//             ),
//             SizedBox(height: 16.0),
//             Wrap(
//               alignment: WrapAlignment.center,
//               spacing: 8.0,
//               runSpacing: 8.0,
//               children: _webTypes.map((webType) {
//                 return ChoiceChip(
//                   label: Text(webType['title']),
//                   selected: _selectedType == webType['id'],
//                   onSelected: (selected) {
//                     setState(() {
//                       _selectedType = selected ? webType['id'] : null;
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: _submitReport,
//               child: Text("ส่งข้อมูล"),
//             ),
//             SizedBox(height: 16.0),
//             // แสดงรูปภาพ
//             Image.network(
//               "https://cpsu-api-49b593d4e146.herokuapp.com/images/webby_fondue/gambling.jpg",
//               width: 200,
//               height: 200,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(WebbyFondueApp());
// }

// class WebbyFondueApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Webby Fondue',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: ReportPage(),
//     );
//   }
// }

// class ReportPage extends StatefulWidget {
//   @override
//   _ReportPageState createState() => _ReportPageState();
// }

// class _ReportPageState extends State<ReportPage> {
//   final TextEditingController _urlController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   String? _selectedType;
//   bool _urlError = false;
//   bool _typeError = false;

//   List<Map<String, dynamic>> _webTypes = [
//     {"id": "gambling", "title": "เว็บพนัน"},
//     {"id": "fraud", "title": "เว็บปลอมแปลง เลียนแบบ"},
//     {"id": "fake-news", "title": "เว็บข่าวมั่ว"},
//     {"id": "share", "title": "เว็บแชร์ลูกโซ่"},
//   ];

//   Future<void> _submitReport() async {
//     if (_urlController.text.isEmpty || _selectedType == null) {
//       setState(() {
//         _urlError = _urlController.text.isEmpty;
//         _typeError = _selectedType == null;
//       });
//       return;
//     }

//     // Prepare data
//     Map<String, dynamic> reportData = {
//       "url": _urlController.text,
//       "description": _descriptionController.text,
//       "type": _selectedType,
//     };

//     // Send report
//     final response = await http.post(
//       Uri.parse("https://cpsu-api-49b593d4e146.herokuapp.com/api/2_2566/final/report_web"),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(reportData),
//     );

//     if (response.statusCode == 200) {
//       // Report success
//       Map<String, dynamic> responseData = jsonDecode(response.body);
//       print("Report success: $responseData");
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Success"),
//             content: Text("Thank you for your report!"),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   setState(() {
//                     _urlController.clear();
//                     _descriptionController.clear();
//                     _selectedType = null;
//                     _urlError = false;
//                     _typeError = false;
//                   });
//                 },
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       // Report failed
//       print("Report failed: ${response.body}");
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Error"),
//             content: Text("Failed to submit report. Please try again later."),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Webby Fondue"),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               "ระบบรายงานเว็บเลวๆ",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               "*ต้องกรอกข้อมูล",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16.0, color: Colors.red),
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               controller: _urlController,
//               decoration: InputDecoration(
//                 labelText: "URL *",
//                 errorText: _urlError ? "URL is required" : null,
//               ),
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               controller: _descriptionController,
//               decoration: InputDecoration(
//                 labelText: "รายละเอียด",
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               "ระบประเภทเว็บเลว *",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16.0, color: Colors.red),
//             ),
//             SizedBox(height: 16.0),
//             Wrap(
//               alignment: WrapAlignment.center,
//               spacing: 8.0,
//               runSpacing: 8.0,
//               children: _webTypes.map((webType) {
//                 return ChoiceChip(
//                   label: Text(webType['title']),
//                   selected: _selectedType == webType['id'],
//                   onSelected: (selected) {
//                     setState(() {
//                       _selectedType = selected ? webType['id'] : null;
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: _submitReport,
//               child: Text("ส่งข้อมูล"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:final_640710149/api_caller.dart';
// import 'package:final_640710149/dialog_utils.dart';
// import 'package:final_640710149/my_list_tile.dart';
// import 'package:final_640710149/my_text_field.dart';
// import 'package:flutter/material.dart';
// //import 'package:your_app_name/helpers/api_caller.dart';
// //import 'package:your_app_name/helpers/dialog_utils.dart';

// class WebReportPage extends StatefulWidget {
//   @override
//   _WebReportPageState createState() => _WebReportPageState();
// }

// class _WebReportPageState extends State<WebReportPage> {
//   TextEditingController _urlController = TextEditingController();
//   TextEditingController _descriptionController = TextEditingController();
//   String? _selectedType;
//   List<Map<String, dynamic>> _webTypes = [
//     {
//       "id": "gambling",
//       "title": "เว็บพนัน",
//       "subtitle": "การพนัน แทงบอล และอื่นๆ",
//       "image": "/images/webby_fondue/gambling.jpg"
//     },
//     {
//       "id": "fraud",
//       "title": "เว็บปลอมแปลง",
//       "subtitle": "หลอกให้กรอกข้อมูลส่วนตัว/รหัสผ่าน",
//       "image": "/images/webby_fondue/fraud.png"
//     },
//     {
//       "id": "fake-news",
//       "title": "เว็บข่าวมั่ว",
//       "subtitle": "Fake news, ข้อมูลที่ทำให้เข้าใจผิด",
//       "image": "/images/webby_fondue/fake_news_2.jpg"
//     },
//     {
//       "id": "share",
//       "title": "เว็บแชร์ลูกโซ่",
//       "subtitle": "หลอกลงทุน",
//       "image": "/images/webby_fondue/thief.jpg"
//     }
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Webby Fondue'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'ระบบรายงานเว็บเลวๆ',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 24.0),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               '* ต้องกรอกข้อมูล',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.0),
//             MyTextField(
//               controller: _urlController,
//               hintText: 'URL *',
//             ),
//             SizedBox(height: 8.0),
//             MyTextField(
//               controller: _descriptionController,
//               hintText: 'รายละเอียด',
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'ประเภทเว็บเลว *',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.0),
//             ListView.builder(
//               shrinkWrap: true,
//               itemCount: _webTypes.length,
//               itemBuilder: (BuildContext context, int index) {
//                 final webType = _webTypes[index];
//                 return MyListTile(
//                   title: webType['title'],
//                   subtitle: webType['subtitle'],
//                   imageUrl: 'https://cpsu-api-49b593d4e146.herokuapp.com${webType['image']}',
//                   selected: _selectedType == webType['id'],
//                   onTap: () {
//                     setState(() {
//                       _selectedType = webType['id'];
//                     });
//                   },
//                 );
//               },
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: _submitReport,
//               child: Text('ส่งข้อมูล'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _submitReport() async {
//     String url = _urlController.text.trim();
//     String description = _descriptionController.text.trim();

//     if (url.isEmpty || _selectedType == null) {
//       showOkDialog(
//         context: context,
//         title: 'Error',
//         message: 'ต้องกรอก URL และเลือกประเภทเว็บ',
//       );
//       return;
//     }

//     try {
//       final response = await ApiCaller().post(
//         'report_web',
//         params: {
//           'url': url,
//           'description': description,
//           'type': _selectedType,
//         },
//       );

//       Map<String, dynamic> data = jsonDecode(response);
//       showOkDialog(
//         context: context,
//         title: 'Success',
//         message: 'ส่งข้อมูลสำเร็จ\n\n - id: ${data['insertItem']['id']} \n - url: ${data['insertItem']['url']} \n - description: ${data['insertItem']['description']} \n - type: ${data['insertItem']['type']}',
//       );
//     } catch (e) {
//       showOkDialog(
//         context: context,
//         title: 'Error',
//         message: e.toString(),
//       );
//     }
//   }
// }

// import 'dart:convert';

// import 'package:final_640710149/api_caller.dart';
// import 'package:final_640710149/dialog_utils.dart';
// import 'package:flutter/material.dart';

// // ignore: unused_import
// import 'package:final_640710149/helpers/api_caller.dart';
// // ignore: unused_import
// import "package:final_640710149/helpers/dialog_utils.dart";

// class WebReportPage extends StatefulWidget {
//   const WebReportPage({Key? key}) : super(key: key);

//   @override
//   _WebReportPageState createState() => _WebReportPageState();
// }

// class _WebReportPageState extends State<WebReportPage> {
//   late String _selectedType;
//   TextEditingController _urlController = TextEditingController();
//   TextEditingController _descriptionController = TextEditingController();

//   List<Map<String, dynamic>> _webTypes = [
//     {"id": "gambling", "title": "เว็บพนัน"},
//     {"id": "fraud", "title": "เว็บปลอมแปลง เลียนแบบ"},
//     {"id": "fake-news", "title": "เว็บข่าวมั่ว"},
//     {"id": "share", "title": "เว็บแชร์ลูกโซ่"}
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Webby Fondue'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'ระบบรายงานเว็บเลวๆ',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             Text(
//               '*ต้องกรอกข้อมูล',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             TextField(
//               controller: _urlController,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 labelText: 'URL *',
//               ),
//             ),
//             SizedBox(height: 8),
//             TextField(
//               controller: _descriptionController,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 labelText: 'รายละเอียด',
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'ประเภทเว็บเลว *',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _webTypes.length,
//                 itemBuilder: (context, index) {
//                   final type = _webTypes[index];
//                   return InkWell(
//                     onTap: () {
//                       setState(() {
//                         _selectedType = type['id'];
//                       });
//                     },
//                     child: Container(
//                       margin: EdgeInsets.symmetric(vertical: 4),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                           color: _selectedType == type['id']
//                               ? Colors.blue
//                               : Colors.grey,
//                         ),
//                       ),
//                       child: ListTile(
//                         title: Text(type['title']),
//                         subtitle: Text(type['subtitle']),
//                         leading: Image.asset(
//                           'assets${type['image']}',
//                           width: 50,
//                           height: 50,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 _handleSubmit();
//               },
//               child: Text('ส่งข้อมูล'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _handleSubmit() async {
//     final url = _urlController.text.trim();
//     final description = _descriptionController.text.trim();

//     if (url.isEmpty || _selectedType.isEmpty) {
//       showOkDialog(
//         context: context,
//         title: 'Error',
//         message: 'ต้องกรอก URL และเลือกประเภทเว็บ',
//       );
//       return;
//     }

//     try {
//       final response = await ApiCaller().post(
//         'report_web',
//         params: {
//           'url': url,
//           'description': description,
//           'type': _selectedType,
//         },
//       );

//       final data = jsonDecode(response);
//       if (data.containsKey('insertItem')) {
//         showOkDialog(
//           context: context,
//           title: 'Success',
//           message: 'ขอบคุณสำหรับการแจ้งข้อมูล',
//         );
//       }
//     } catch (e) {
//       showOkDialog(
//         context: context,
//         title: 'Error',
//         message: e.toString(),
//       );
//     }
//   }
// }

// import 'dart:convert';
// import 'package:final_640710149/api_caller.dart';
// import 'package:final_640710149/dialog_utils.dart';
// import 'package:final_640710149/my_list_tile.dart';
// import 'package:final_640710149/my_text_field.dart';
// import 'package:flutter/material.dart';
// import 'package:final_640710149/helpers/api_caller.dart';
// import 'package:final_640710149/helpers/dialog_utils.dart';

// class WebReportPage extends StatefulWidget {
//   @override
//   _WebReportPageState createState() => _WebReportPageState();
// }

// class _WebReportPageState extends State<WebReportPage> {
//   TextEditingController _urlController = TextEditingController();
//   TextEditingController _descriptionController = TextEditingController();
//   String? _selectedType;
//   List<Map<String, dynamic>> _webTypes = [
//     {
//       "id": "gambling",
//       "title": "เว็บพนัน",
//       "subtitle": "การพนัน แทงบอล และอื่นๆ",
//       "image": "/images/webby_fondue/gambling.jpg"
//     },
//     {
//       "id": "fraud",
//       "title": "เว็บปลอมแปลง",
//       "subtitle": "หลอกให้กรอกข้อมูลส่วนตัว/รหัสผ่าน",
//       "image": "/images/webby_fondue/fraud.png"
//     },
//     {
//       "id": "fake-news",
//       "title": "เว็บข่าวมั่ว",
//       "subtitle": "Fake news, ข้อมูลที่ทำให้เข้าใจผิด",
//       "image": "/images/webby_fondue/fake_news_2.jpg"
//     },
//     {
//       "id": "share",
//       "title": "เว็บแชร์ลูกโซ่",
//       "subtitle": "หลอกลงทุน",
//       "image": "/images/webby_fondue/thief.jpg"
//     }
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Webby Fondue'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'ระบบรายงานเว็บเลวๆ',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 24.0),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               '* ต้องกรอกข้อมูล',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.0),
//             MyTextField(
//               controller: _urlController,
//               hintText: 'URL *',
//             ),
//             SizedBox(height: 8.0),
//             MyTextField(
//               controller: _descriptionController,
//               hintText: 'รายละเอียด',
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'ประเภทเว็บเลว *',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.0),
//             ListView.builder(
//               shrinkWrap: true,
//               itemCount: _webTypes.length,
//               itemBuilder: (BuildContext context, int index) {
//                 final webType = _webTypes[index];
//                 return MyListTile(
//                   title: webType['title'],
//                   subtitle: webType['subtitle'],
//                   imageUrl: 'https://cpsu-api-49b593d4e146.herokuapp.com${webType['image']}',
//                   selected: _selectedType == webType['id'],
//                   onTap: () {
//                     setState(() {
//                       _selectedType = webType['id'];
//                     });
//                   },
//                 );
//               },
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: _submitReport,
//               child: Text('ส่งข้อมูล'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _submitReport() async {
//     String url = _urlController.text.trim();
//     String description = _descriptionController.text.trim();

//     if (url.isEmpty || _selectedType == null) {
//       showOkDialog(
//         context: context,
//         title: 'Error',
//         message: 'ต้องกรอก URL และเลือกประเภทเว็บ',
//       );
//       return;
//     }

//     try {
//       final response = await ApiCaller().post(
//         'report_web',
//         params: {
//           'url': url,
//           'description': description,
//           'type': _selectedType,
//         },
//       );

//       Map<String, dynamic> data = jsonDecode(response);
//       showOkDialog(
//         context: context,
//         title: 'Success',
//         message: 'ส่งข้อมูลสำเร็จ\n\n - id: ${data['insertItem']['id']} \n - url: ${data['insertItem']['url']} \n - description: ${data['insertItem']['description']} \n - type: ${data['insertItem']['type']}',
//       );
//     } catch (e) {
//       showOkDialog(
//         context: context,
//         title: 'Error',
//         message: e.toString(),
//       );
//     }
//   }
// }



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class Report {
//   final String url;
//   final String description;
//   final String type;

//   Report({
//     required this.url,
//     required this.description,
//     required this.type,
//   });
// }

// class WebType {
//   final String id;
//   final String title;
//   final String subtitle;
//   final String image;

//   WebType({
//     required this.id,
//     required this.title,
//     required this.subtitle,
//     required this.image,
//   });
// }

// void main() {
//   runApp(const MaterialApp(
//     title: 'Webby Fondue',
//     home: ReportPage(),
//   ));
// }

// class ReportPage extends StatefulWidget {
//   const ReportPage({Key? key}) : super(key: key);

//   @override
//   _ReportPageState createState() => _ReportPageState();
// }

// class _ReportPageState extends State<ReportPage> {
//   TextEditingController urlController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();
//   String? selectedType;
//   List<WebType> webTypes = [];

//   @override
//   void initState() {
//     super.initState();
//     // เรียก API เพื่อโหลดประเภทของเว็บ
//     fetchWebTypes();
//   }

//   Future<void> fetchWebTypes() async {
//     final response = await http.get(
//       Uri.parse('https://cpsu-api-49b593d4e146.herokuapp.com/api/2_2566/final/web_types'),
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = jsonDecode(response.body);
//       setState(() {
//         webTypes = responseData.map((data) => WebType(
//           id: data['id'],
//           title: data['title'],
//           subtitle: data['subtitle'],
//           image: 'https://cpsu-api-49b593d4e146.herokuapp.com${data['image']}',
//         )).toList();
//       });
//     } else {
//       throw Exception('Failed to load web types');
//     }
//   }

//   Future<void> reportWebsite() async {
//     if (urlController.text.isEmpty || selectedType == null) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('ข้อมูลไม่ครบถ้วน'),
//             content: const Text('กรุณากรอก URL และเลือกประเภทของเว็บ'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//       return;
//     }

//     final report = Report(
//       url: urlController.text,
//       description: descriptionController.text,
//       type: selectedType!,
//     );

//     final response = await http.post(
//       Uri.parse('https://cpsu-api-49b593d4e146.herokuapp.com/api/2_2566/final/report_web'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, String>{
//         'url': report.url,
//         'description': report.description,
//         'type': report.type,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       final List<dynamic> summary = responseData['summary'];
//       String message = '';
//       summary.forEach((data) {
//         message += '${data['title']}: ${data['count']}\n';
//       });

//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('รายงานสำเร็จ'),
//             content: Text(message),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       throw Exception('Failed to report website');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Webby Fondue'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             const Text(
//               'Webby Fondue',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 24.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 labelText: 'ประเภทของเว็บ',
//                 border: OutlineInputBorder(),
//               ),
//               value: selectedType,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   selectedType = newValue;
//                 });
//               },
//               items: webTypes.map<DropdownMenuItem<String>>((WebType webType) {
//                 return DropdownMenuItem<String>(
//                   value: webType.id,
//                   child: Row(
//                     children: <Widget>[
//                       Image.network(webType.image, width: 30, height: 30),
//                       const SizedBox(width: 10.0),
//                       Text(webType.title),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 20.0),
//             TextFormField(
//               controller: urlController,
//               decoration: const InputDecoration(
//                 labelText: 'URL',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             TextFormField(
//               controller: descriptionController,
//               maxLines: 3,
//               decoration: const InputDecoration(
//                 labelText: 'รายละเอียด',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             ElevatedButton(
//               onPressed: reportWebsite,
//               child: const Text('ส่งข้อมูล'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

