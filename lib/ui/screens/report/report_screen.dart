import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/ui/components/report_success.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';

class ReportScreen extends StatefulWidget {
  final String title;
  final String uid;
  final String name;
  const ReportScreen(
      {super.key, required this.title, required this.uid, required this.name});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  File? _photo;
  final ImagePicker _picker = ImagePicker();
  FirebaseAuth auth = FirebaseAuth.instance;
  String? _currentAddress;
  Position? _currentPosition;
  bool _busy = false;
  File? _image;

  bool isLoading = false;
  String responseText = '';

  final TextEditingController _whatHappendCont = TextEditingController();
  bool isSwitched = false;
  var textValue = '';
  final apiKey =
      Platform.environment['AIzaSyB1SiI7ZJrx48pctwPIlwaakN50VgGTkgs'];

  Future<void> getTextFromImage(File photo, String message) async {
    isLoading = true;
    print('APIKET ======================= $apiKey');
    try {
      final model = GenerativeModel(
          model: 'gemini-pro-vision',
          apiKey: 'AIzaSyB1SiI7ZJrx48pctwPIlwaakN50VgGTkgs');

      final prompt = TextPart(message);
      final imageParts = [
        DataPart('image/jpeg', await photo.readAsBytes()),
      ];
      final response = await model.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);
      print(response.text.toString());
      setState(() {
        responseText = response.text.toString();
        isLoading = false;
      });
    } catch (e) {
      print("Error is $e");
    }
  }

  @override
  void initState() {
    super.initState();

    _busy = true;

    super.initState();
  }

  FirebaseFirestore reports = FirebaseFirestore.instance;
  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality},${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _busy = true;
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        getTextFromImage(_photo!,
            "What is the accident in this image ? , How dangerous is it?");
        //uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    var pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        getTextFromImage(_photo!,
            "What is the accident in this image ? , How dangerous is it?");
      } else {
        print('No image selected.');
      }
    });
    setState(() {
      _busy = true;
    });
  }

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
      print('Switch Button is ON');
    } else {
      setState(() {
        isSwitched = false;
      });
      print('Switch Button is OFF');
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _handleLocationPermission() async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location services are disabled. Please enable the services')));
        return false;
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
        return false;
      }
      return true;
    }

    Future uploadFile() async {
      await _handleLocationPermission();
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _getAddressFromLatLng(_currentPosition!);
      if (_photo == null) return;
      final fileName = basename(_photo!.path);
      final destination = 'files/$fileName';

      try {
        final ref = firebase_storage.FirebaseStorage.instance
            .ref(destination)
            .child('file/');
        await ref.putFile(_photo!);
        await FirebaseFirestore.instance.collection('reports').add({
          'user Id': auth.currentUser!.uid,
          'title': widget.title,
          'what happend?': _whatHappendCont.text,
          'did you see?': isSwitched,
          'image_path': 'gs://gp-proj-30b79.appspot.com/$destination/file',
          'ai_detection': responseText,
          'address':_currentAddress,
        }).then((value) => {
              setState(() {
                isLoading = false;
              }),
              showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.white,
                enableDrag: false,
                context: context,
                builder: (context) {
                  return Padding(
                    padding: MediaQuery.viewInsetsOf(context),
                    child: SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.6,
                      child: ReportSuccess(name: widget.name, uid: widget.uid),
                    ),
                  );
                },
              ).then((value) => setState(() {}))
            });

        //
      } catch (e) {
        print('error occured');
      }
    }

    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      // ignore: unnecessary_null_comparison
      child:
          // ignore: unnecessary_null_comparison
          _image == null
              ? const Text("No Image Selected")
              : Image.file(_image!),
    ));

    if (_busy) {
      stackChildren.add(const Center(
        child: CircularProgressIndicator(),
      ));
    }
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: double.infinity),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: COLOR_PRIMARY,
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                side: BorderSide(
                  color: COLOR_PRIMARY,
                ),
              ),
            ),
            child: isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ],
                  )
                : const Text(
                    'Submit report',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              await uploadFile();
            },
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Tell us what happend ',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                hintText: 'About accident',
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: COLOR_PRIMARY, width: 2.0)),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              textAlignVertical: TextAlignVertical.center,

              controller: _whatHappendCont,
              keyboardType: TextInputType.multiline,
              minLines: 1, // <-- SEE HERE
              maxLines: 5,
              style: const TextStyle(fontSize: 18.0),
              cursorColor: COLOR_PRIMARY,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Did you see this accident ?',
                  style: TextStyle(fontSize: 18),
                ),
                Transform.scale(
                  scale: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Switch(
                      onChanged: toggleSwitch,
                      value: isSwitched,
                      activeColor: Colors.blue,
                      activeTrackColor: Colors.yellow,
                      inactiveThumbColor: Colors.redAccent,
                      inactiveTrackColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Capture an image',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  height: 250,
                  child: _photo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.file(
                            _photo!,
                            width: double.infinity,
                            height: 350,
                            fit: BoxFit.fitHeight,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10)),
                          width: 100,
                          height: 100,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[800],
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          // SizedBox(
          //   height: 500,
          //   child: Stack(
          //     children: stackChildren,
          //   ),
          // )
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              responseText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }
}
