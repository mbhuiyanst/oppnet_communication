import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class AttachedDevice{

  final List<Device> devices;
  final String attachedModel;

  AttachedDevice(this.devices, this.attachedModel);
}