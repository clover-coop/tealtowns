import 'package:flutter/material.dart'; //need on every page

import '../../app_scaffold.dart';

class Team extends StatefulWidget {
  @override
  _TeamState createState() => _TeamState();
}

// Represent image data
class ImageData {
  final String imagePath;
  final String name;
  final String role;

  ImageData({required this.imagePath, required this.name, required this.role});
}

class _TeamState extends State<Team> {
  
  // List of headshots, names, and roles
  final List<ImageData> imagesData = [
    // ImageData(
    //   imagePath: 'assets/images/claire-adair-headshot.jpg',
    //   name: 'Claire Adair',
    //   role: 'Customer Acquisition',
    // ),
    ImageData(
      imagePath: 'assets/images/team/angeline-neo.jpg',
      name: 'Angeline Neo',
      role: 'Product Designer',
    ),
    ImageData(
      imagePath: 'assets/images/team/jacob-russo-headshot.jpg',
      name: 'Jacob Russo',
      role: 'Web Developer',
    ),
    ImageData(
      imagePath: 'assets/images/team/luke-madera-headshot.jpg',
      name: 'Luke Madera',
      role: 'Product Engineer',
    ),
    ImageData(
      imagePath: 'assets/images/team/layla-tadjpour-headshot.jpg',
      name: 'Layla Tadjpour',
      role: 'Product Engineer',
    ),
    ImageData(
      imagePath: 'assets/images/team/tolu-garcia.jpg',
      name: 'Tolu Garcia',
      role: 'Product Designer',
    ),
    ImageData(
      imagePath: 'assets/images/team/vishad-tomar.jpg',
      name: 'Vishad Tomar',
      role: 'Product Designer',
    ),
  ];

  // Function to dynamically create columns with images and text
  Widget buildImageColumn(ImageData imageData) {
    return Column(
      children: [
        // Headshots
        Image.asset(
          imageData.imagePath, 
          width: 150, 
          height: 150, 
          fit: BoxFit.cover, 
        ),
        SizedBox(height: 5),
        // Text
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Column(
            children: [
              Text(
                imageData.name,
                style: TextStyle(fontSize: 14),
              ), 
              Text(
                imageData.role,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  } 

  @override
  Widget build(BuildContext context) {
    return AppScaffoldComponent(
      width: 750,
      body: Column(
        children: [
          SizedBox(height: 20),
          // Wrap widget deals with varying number of images on different screen sizes
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: <Widget> [
              ...imagesData.map((imageData) => buildImageColumn(imageData) ).toList(),
            ]
          ),
        ],
      ),
    );
  }
}