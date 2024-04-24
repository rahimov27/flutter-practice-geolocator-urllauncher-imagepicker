import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaterialApp(
    home: MyWidget(),
  ));
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  XFile? image;

  pickMyImage(ImageSource source) async {
    final result = await ImagePicker().pickImage(source: source);
    if (result == null) return;
    image = result;

    setState(() {});

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Image picker"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            image == null
                ? const CircleAvatar(
                    radius: 100,
                  )
                : CircleAvatar(
                    radius: 100,
                    backgroundImage: FileImage(
                      File(image!.path),
                    ),
                  ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  context: context,
                  builder: (context) => Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.grey),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            pickMyImage(ImageSource.camera);
                          },
                          child: const Text("Camera"),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            pickMyImage(ImageSource.gallery);
                          },
                          child: const Text("Gallery"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final currentPosition = await _determinePosition();

                            launchMyUrl(
                                "http://www.google.com/maps/place/${currentPosition.longitude},${currentPosition.latitude}");
                          },
                          child: const Text("Location"),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Text("Change"),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Url launcher
  Future<void> launchMyUrl(String url) async {
    Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
