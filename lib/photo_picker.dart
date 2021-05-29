import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_utils/flutter_file_utils.dart';
import 'package:intl/intl.dart';

class PhotoPickerView extends StatefulWidget {
  @override
  _PhotoPickerViewState createState() => _PhotoPickerViewState();
}

class _PhotoPickerViewState extends State<PhotoPickerView> {
  DateTime? first;
  DateTime? second;
  List<String> paths = [];
  bool isLoading = false;
  Future<void> getFiles() async {
    paths.clear();

    var fm = FileManager(
      root: Directory('/storage/emulated/0/DCIM'),
    ); //
    var files = await fm.filesTree(extensions: ['png', 'jpg', 'jpeg']);
    for (int i = 0; i < files.length; i++) {
      var list = await files[i].stat();
      if (list.accessed.isAfter(first!) && list.accessed.isBefore(second!))
        paths.add(files[i].path);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 50,
                width: 200,
                child: DateTimeField(
                    decoration: InputDecoration(hintText: 'Enter Start Date'),
                    format: DateFormat("yyyy-MM-dd"),
                    onChanged: (c) => first = c,
                    onShowPicker: (context, current) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: DateTime.now(),
                          lastDate: DateTime(2100));
                    }),
              ),
              Container(
                height: 50,
                width: 200,
                child: DateTimeField(
                    decoration: InputDecoration(hintText: 'Enter End Date'),
                    format: DateFormat("yyyy-MM-dd"),
                    onChanged: (c) => second = c,
                    onShowPicker: (context, current) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: DateTime.now(),
                          lastDate: DateTime(2100));
                    }),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              await getFiles();
              setState(() {
                isLoading = false;
              });
            },
            child:
                isLoading ? CircularProgressIndicator() : Text('Show Pictures'),
          ),
          Expanded(
            child: GridView.builder(
                itemCount: paths.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20),
                itemBuilder: (context, index) {
                  return Image.file(File(paths[index]));
                }),
          )
        ],
      )),
    );
  }
}
