import 'package:flutter/material.dart';
import 'package:guardyn_client/core/di/injection.dart';
import 'package:guardyn_client/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await configureDependencies();
  
  runApp(const GuardynApp());
}
