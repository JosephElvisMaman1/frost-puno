import 'package:flutter/material.dart';

class DataSourceInfo {
  const DataSourceInfo({
    required this.name,
    required this.tag,
    required this.description,
    required this.icon,
  });

  final String name;
  final String tag;
  final String description;
  final IconData icon;
}
