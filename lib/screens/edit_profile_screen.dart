import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:maptai_shopping/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/common_button.dart';
import '../widgets/profile_field.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();

  final Map<String, dynamic> data;

  EditProfileScreen(this.data);
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, String> _data = {};
  bool _isLoading = false;
  bool _isLoading2 = false;
  bool _isLoading3 = false;
  List<dynamic> _certificates = [];
  List<bool> _isLoadings = [false, false, false, false];
  FlutterToast flutterToast;

  @override
  void initState() {
    super.initState();
    getDocuments();
    flutterToast = FlutterToast(context);
  }

  Future<void> getDocuments() async {
    final url = 'https://api.maptai.com/business/document/review/buyer/';
    setState(() {
      _isLoading2 = true;
    });
    try {
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader:
              Provider.of<Auth>(context, listen: false).token,
        },
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);
        setState(() {
          _certificates = resBody['payload'];
        });
      }
    } catch (e) {}
    setState(() {
      _isLoading2 = false;
    });
  }

  Future<void> uploadImage() async {
    try {
      String filePath;
      final url = 'https://api.maptai.com/user/profile/change/buyer/';
      filePath = await FilePicker.getFilePath(
        type: FileType.image,
      );
      if (filePath == null) {
        return;
      }
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: filePath,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        cropStyle: CropStyle.circle,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Theme.of(context).primaryColor,
          activeControlsWidgetColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          showCancelConfirmationDialog: true,
        ),
      );
      filePath = croppedFile.path;
      final multipartRequest =
          new http.MultipartRequest('POST', Uri.parse(url));
      multipartRequest.headers.addAll(
        {
          'Authorization': Provider.of<Auth>(context, listen: false).token,
        },
      );
      final multipartFile = await http.MultipartFile.fromPath(
        'picture',
        filePath,
      );
      final length = multipartFile.length;
      if (length > 5242880) {
        await showDialog(
          context: context,
          child: AlertDialog(
            title: Text('File is Too Large'),
            content:
                Text('Maximum File Size is 5MB. Please choose a smaller file.'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
        return;
      }
      setState(() {
        _isLoading3 = true;
      });
      multipartRequest.files.add(multipartFile);
      final response = await multipartRequest.send();
      print(response.statusCode);
      if (response.statusCode == 202) {
        Widget toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.grey[300],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check),
              SizedBox(
                width: 12.0,
              ),
              Text("Profile Image Updated"),
            ],
          ),
        );

        flutterToast.showToast(
          child: toast,
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 2),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading3 = false;
    });
  }

  Future<void> uploadDoc(int i, String fileType) async {
    try {
      String _docTypeChoice = '';

      await showModalBottomSheet(
        context: context,
        builder: (ctx) => Container(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _docTypeChoice = 'Image';
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.image),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Image'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _docTypeChoice = 'Pdf';
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.picture_as_pdf),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Document'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      String filePath;
      if (_docTypeChoice == '') {
        return;
      } else if (_docTypeChoice == 'Image') {
        filePath = await FilePicker.getFilePath(
          type: FileType.image,
        );
        if (filePath == null) {
          return;
        }
        File croppedFile = await ImageCropper.cropImage(
          sourcePath: filePath,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Theme.of(context).primaryColor,
            activeControlsWidgetColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
            showCancelConfirmationDialog: true,
          ),
        );
        filePath = croppedFile.path;
      } else if (_docTypeChoice == 'Pdf') {
        filePath = await FilePicker.getFilePath(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
      }
      if (filePath == null) {
        return;
      }
      bool _isConfirmed = false;
      await showDialog(
        context: context,
        child: AlertDialog(
          title: Text('Confirm?'),
          content: Text('Are you sure, you want to upload this document?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                _isConfirmed = true;
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      if (!_isConfirmed) {
        return;
      }
      setState(() {
        _isLoadings[i] = true;
      });
      showDialog(
        barrierDismissible: false,
        context: context,
        child: AlertDialog(
          title: Text('Uploading Certificate'),
          content: Container(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
      if (filePath == null) {
        setState(() {
          _isLoadings[i] = false;
        });
        Navigator.of(context).pop();
        return;
      }
      final url = 'https://api.maptai.com/business/document/review/buyer/';
      final multipartRequest =
          new http.MultipartRequest('POST', Uri.parse(url));
      multipartRequest.headers.addAll(
        {
          'Authorization': Provider.of<Auth>(context, listen: false).token,
        },
      );
      multipartRequest.fields.addAll({
        'file_type': fileType,
        'buyer': widget.data['payload'][0]['id'],
      });
      final multipartFile = await http.MultipartFile.fromPath(
        'document',
        filePath,
      );
      final length = multipartFile.length;
      if (length > 5242880) {
        await showDialog(
          context: context,
          child: AlertDialog(
            title: Text('File is Too Large'),
            content:
                Text('Maximum File Size is 5MB. Please choose a smaller file.'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
        setState(() {
          _isLoadings[i] = false;
        });
        Navigator.of(context).pop();
        return;
      }
      multipartRequest.files.add(multipartFile);
      final response = await multipartRequest.send();
      print(response.statusCode);
      print(await response.stream.bytesToString());
      if (response.statusCode == 201) {
        Widget toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.grey[300],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check),
              SizedBox(
                width: 12.0,
              ),
              Text("Document Uploaded"),
            ],
          ),
        );

        flutterToast.showToast(
          child: toast,
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 2),
        );
        getDocuments();
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoadings[i] = false;
      });
      await showDialog(
        context: context,
        child: AlertDialog(
          title: Text('Error'),
          content: Text('Something went wrong. Please try again later.'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
    setState(() {
      _isLoadings[i] = false;
      Navigator.of(context).pop();
    });
  }

  Future<void> updateProfile() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    print('>>>>>');
    setState(() {
      _isLoading = true;
    });
    try {
      final url = 'https://api.maptai.com/user/profile/change/buyer/';
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader:
              Provider.of<Auth>(context, listen: false).token,
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode(_data),
      );
      print(response.statusCode);
      if (response.statusCode == 202) {
        Widget toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.grey[300],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check),
              SizedBox(
                width: 12.0,
              ),
              Text("Profile Updated"),
            ],
          ),
        );

        flutterToast.showToast(
          child: toast,
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 2),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _isLoading2
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                            image: widget.data['profile_picture'].length == 0
                                ? null
                                : DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      widget.data['profile_picture'][0]
                                          ['profile_image'],
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          child: widget.data['profile_picture'].length != 0
                              ? null
                              : Icon(
                                  Icons.account_circle,
                                  color: Colors.white,
                                  size: 150,
                                ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: _isLoading3
                            ? CircularProgressIndicator()
                            : CommonButton(
                                title: 'Change Image',
                                onPressed: uploadImage,
                                bgColor: Theme.of(context).primaryColor,
                                borderColor: Theme.of(context).primaryColor,
                                fontSize: 16,
                                height: 50,
                                width: 200,
                                borderRadius: 10,
                              ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        height: 60,
                        margin: EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: ProfileField(
                          label: 'First Name',
                          initialData: widget.data['payload'][0]['user']
                              ['first_name'],
                          validator: (value) {
                            if (value == '') {
                              return 'This field is required.';
                            }
                          },
                          onSaved: (value) {
                            _data['first_name'] = value;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 60,
                        margin: EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: ProfileField(
                          label: 'Last Name',
                          initialData: widget.data['payload'][0]['user']
                              ['last_name'],
                          validator: (value) {
                            if (value == '') {
                              return 'This field is required.';
                            }
                          },
                          onSaved: (value) {
                            _data['last_name'] = value;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 60,
                        margin: EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: ProfileField(
                          label: 'Email',
                          initialData: widget.data['payload'][0]['user']
                              ['email'],
                          enabled: false,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 60,
                        margin: EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: ProfileField(
                          label: 'Phone Number',
                          initialData: widget.data['payload'][0]['mobile'],
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == '') {
                              return 'This field is required.';
                            }
                          },
                          onSaved: (value) {
                            _data['mobile'] = value;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 60,
                        margin: EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: ProfileField(
                          label: 'Company Name',
                          initialData: widget.data['payload'][0]['company'],
                          validator: (value) {
                            if (value == '') {
                              return 'This field is required.';
                            }
                          },
                          onSaved: (value) {
                            _data['company'] = value;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 60,
                        margin: EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: ProfileField(
                          label: 'Department Name',
                          initialData: widget.data['payload'][0]['department'],
                          validator: (value) {
                            if (value == '') {
                              return 'This field is required.';
                            }
                          },
                          onSaved: (value) {
                            _data['department'] = value;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : CommonButton(
                                title: 'Update',
                                onPressed: updateProfile,
                                borderRadius: 10,
                                width: 200,
                                fontSize: 16,
                                bgColor: Theme.of(context).primaryColor,
                                borderColor: Theme.of(context).primaryColor,
                              ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: Text(
                          'Documents',
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              spreadRadius: 0.1,
                              color: Colors.grey,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'IEC Certificate/Import Export Licence',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (_certificates
                                    .where((doc) =>
                                        doc['file_type'] == 'IEC Certificate')
                                    .toList()
                                    .length ==
                                0)
                              _isLoadings[0]
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                          Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    )
                                  : CommonButton(
                                      bgColor: Color(0xFFE9F0F3),
                                      borderColor: Color(0xFFE9F0F3),
                                      title: 'Upload File',
                                      textColor: Theme.of(context).primaryColor,
                                      fontSize: 16,
                                      width: double.infinity,
                                      borderRadius: 5,
                                      onPressed: () =>
                                          uploadDoc(0, 'IEC Certificate'),
                                    )
                            else
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    _certificates
                                            .where((doc) =>
                                                doc['file_type'] ==
                                                'IEC Certificate')
                                            .toList()[0]['review']
                                        ? 'Document Approved'
                                        : 'Approval Pending',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .body2
                                        .copyWith(
                                          color: _certificates
                                                  .where((doc) =>
                                                      doc['file_type'] ==
                                                      'IEC Certificate')
                                                  .toList()[0]['review']
                                              ? Colors.green
                                              : Colors.amber,
                                        ),
                                  ),
                                  InkWell(
                                    child: Icon(
                                      Icons.cloud_download,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onTap: () async {
                                      if (await canLaunch(_certificates
                                          .where((doc) =>
                                              doc['file_type'] ==
                                              'IEC Certificate')
                                          .toList()[0]['document'])) {
                                        await launch(_certificates
                                            .where((doc) =>
                                                doc['file_type'] ==
                                                'IEC Certificate')
                                            .toList()[0]['document']);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Company Registration Certificate/Equivalent Certificate',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (_certificates
                                    .where((doc) =>
                                        doc['file_type'] ==
                                        'Company Registration Certificate')
                                    .toList()
                                    .length ==
                                0)
                              _isLoadings[1]
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                          Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    )
                                  : CommonButton(
                                      bgColor: Color(0xFFE9F0F3),
                                      borderColor: Color(0xFFE9F0F3),
                                      title: 'Upload File',
                                      textColor: Theme.of(context).primaryColor,
                                      fontSize: 16,
                                      width: double.infinity,
                                      borderRadius: 5,
                                      onPressed: () => uploadDoc(1,
                                          'Company Registration Certificate'),
                                    )
                            else
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    _certificates
                                            .where((doc) =>
                                                doc['file_type'] ==
                                                'Company Registration Certificate')
                                            .toList()[0]['review']
                                        ? 'Document Approved'
                                        : 'Approval Pending',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .body2
                                        .copyWith(
                                          color: _certificates
                                                  .where((doc) =>
                                                      doc['file_type'] ==
                                                      'Company Registration Certificate')
                                                  .toList()[0]['review']
                                              ? Colors.green
                                              : Colors.amber,
                                        ),
                                  ),
                                  InkWell(
                                    child: Icon(
                                      Icons.cloud_download,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onTap: () async {
                                      if (await canLaunch(_certificates
                                          .where((doc) =>
                                              doc['file_type'] ==
                                              'Company Registration Certificate')
                                          .toList()[0]['document'])) {
                                        await launch(_certificates
                                            .where((doc) =>
                                                doc['file_type'] ==
                                                'Company Registration Certificate')
                                            .toList()[0]['document']);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'GST Certificate/Tax Certificate',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (_certificates
                                    .where((doc) =>
                                        doc['file_type'] == 'GST Certificate')
                                    .toList()
                                    .length ==
                                0)
                              _isLoadings[2]
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                          Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    )
                                  : CommonButton(
                                      bgColor: Color(0xFFE9F0F3),
                                      borderColor: Color(0xFFE9F0F3),
                                      title: 'Upload File',
                                      textColor: Theme.of(context).primaryColor,
                                      fontSize: 16,
                                      width: double.infinity,
                                      borderRadius: 5,
                                      onPressed: () =>
                                          uploadDoc(2, 'GST Certificate'),
                                    )
                            else
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    _certificates
                                            .where((doc) =>
                                                doc['file_type'] ==
                                                'GST Certificate')
                                            .toList()[0]['review']
                                        ? 'Document Approved'
                                        : 'Approval Pending',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .body2
                                        .copyWith(
                                          color: _certificates
                                                  .where((doc) =>
                                                      doc['file_type'] ==
                                                      'GST Certificate')
                                                  .toList()[0]['review']
                                              ? Colors.green
                                              : Colors.amber,
                                        ),
                                  ),
                                  InkWell(
                                    child: Icon(
                                      Icons.cloud_download,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onTap: () async {
                                      if (await canLaunch(_certificates
                                          .where((doc) =>
                                              doc['file_type'] ==
                                              'GST Certificate')
                                          .toList()[0]['document'])) {
                                        await launch(_certificates
                                            .where((doc) =>
                                                doc['file_type'] ==
                                                'GST Certificate')
                                            .toList()[0]['document']);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Shop & Establishment Licence/Equivalent Other Certificate',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (_certificates
                                    .where((doc) =>
                                        doc['file_type'] ==
                                        'Shop And Establishment Certificate')
                                    .toList()
                                    .length ==
                                0)
                              _isLoadings[3]
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                          Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    )
                                  : CommonButton(
                                      bgColor: Color(0xFFE9F0F3),
                                      borderColor: Color(0xFFE9F0F3),
                                      title: 'Upload File',
                                      textColor: Theme.of(context).primaryColor,
                                      fontSize: 16,
                                      width: double.infinity,
                                      borderRadius: 5,
                                      onPressed: () => uploadDoc(3,
                                          'Shop And Establishment Certificate'),
                                    )
                            else
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    _certificates
                                            .where((doc) =>
                                                doc['file_type'] ==
                                                'Shop And Establishment Certificate')
                                            .toList()[0]['review']
                                        ? 'Document Approved'
                                        : 'Approval Pending',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .body2
                                        .copyWith(
                                          color: _certificates
                                                  .where((doc) =>
                                                      doc['file_type'] ==
                                                      'Shop And Establishment Certificate')
                                                  .toList()[0]['review']
                                              ? Colors.green
                                              : Colors.amber,
                                        ),
                                  ),
                                  InkWell(
                                    child: Icon(
                                      Icons.cloud_download,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onTap: () async {
                                      if (await canLaunch(_certificates
                                          .where((doc) =>
                                              doc['file_type'] ==
                                              'Shop And Establishment Certificate')
                                          .toList()[0]['document'])) {
                                        await launch(_certificates
                                            .where((doc) =>
                                                doc['file_type'] ==
                                                'Shop And Establishment Certificate')
                                            .toList()[0]['document']);
                                      }
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
