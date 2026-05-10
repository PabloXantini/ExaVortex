import 'dart:typed_data';

import 'package:vector_math/vector_math_64.dart';

ByteData boolean(List<bool> values){
  final data = Uint8List(values.length);
  for (int i = 0; i < data.length; i++){
    data[i] = values[i] ? 1 : 0;
  }
  return data.buffer.asByteData();
}

ByteData uint16(List<int> values) {
  final data = Uint16List(values.length);
  for (int i = 0; i < data.length; i++){
    data[i] = values[i];
  }
  return data.buffer.asByteData();
}

ByteData uint32(List<int> values) {
  final data = Uint32List(values.length);
  for (int i = 0; i < data.length; i++){
    data[i] = values[i];
  }
  return data.buffer.asByteData();
}

ByteData float32(List<double> values) {
  final data = Float32List(values.length);
  for (int i = 0; i < data.length; i++){
    data[i] = values[i];
  }
  return data.buffer.asByteData();
}

ByteData float32Mat2(Matrix2 matrix) {
  return Float32List.fromList(matrix.storage).buffer.asByteData();
}

ByteData float32Mat3(Matrix3 matrix) {
  return Float32List.fromList(matrix.storage).buffer.asByteData();
}

ByteData float32Mat4(Matrix4 matrix) {
  return Float32List.fromList(matrix.storage).buffer.asByteData();
}