import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';

class CropImagePage extends StatefulWidget {
  final File file;

  const CropImagePage({Key? key, required this.file}) : super(key: key);
  @override
  CropImagePageState createState() => CropImagePageState();
}

class CropImagePageState extends State<CropImagePage> {
  final cropKey = GlobalKey<CropState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: _buildCroppingImage(),
        ),
      ),
    );
  }

  Widget _buildCroppingImage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(
            widget.file,
            key: cropKey,
            aspectRatio: 4.0 / 4.0,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20.0),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  _cropImage().then((file) => {
                        Navigator.pop(context, file),
                      });
                },
                child: const Text(
                  'Обрезать изображение',
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<File> _cropImage() async {
    final scale = cropKey.currentState!.scale;
    final area = cropKey.currentState!.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return Future.error("Ошибка изображения");
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: widget.file,
      preferredSize: (2000 / scale).round(),
    );

    return await ImageCrop.cropImage(
      file: sample,
      area: area,
    );
  }
}
