import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:ui' as ui;


class MapFeature extends StatefulWidget {
  MapFeature({Key? key}) : super(key: key);

  @override
  State<MapFeature> get createState => _MapFeatureState();
}

class _MapFeatureState extends State<MapFeature> {
  final String imageUrl = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSzHQv_th9wq3ivQ1CVk7UZRxhbPq64oQrg5Q&usqp=CAU';
  final List<LatLng> markerLocations = [
    LatLng(37.42796133580664, -122.085749655962),
    LatLng(37.42496133580664, -122.082749655962),
    LatLng(37.42196133580664, -122.079749655962),
    LatLng(37.41996133580664, -122.076749655962),
  ];

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: markerLocations[0],
        zoom: 14.4746,
      ),
      markers: markerLocations.map((location) => Marker(
        markerId: MarkerId(location.toString()),
        position: location,
        icon: BitmapDescriptor.fromBytes(markerIcon),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              child: Text('Marker at $location'),
            ),
          );
        },
      )).toSet(),
    );
  }

  Future<Uint8List> getBytesFromCanvas(int width, int height, url) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.transparent;
    final Radius radius = Radius.circular(width/2);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);
    final img = await http.get(url);
    final imgCodec = await ui.instantiateImageCodec(img.bodyBytes);
    final ui.FrameInfo frameInfo = await imgCodec.getNextFrame();
    canvas.drawImage(frameInfo.image, Offset.zero, paint);
    final ui.Image image = await pictureRecorder
        .endRecording()
        .toImage(width, height);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

  Future<BitmapDescriptor> getMarkerIcon(String url) async {
    final Uint8List markerIcon = await getBytesFromCanvas(200, 200, url);
    return BitmapDescriptor.fromBytes(markerIcon);
  }
}