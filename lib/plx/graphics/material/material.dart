import 'dart:typed_data';
import 'package:vector_math/vector_math_64.dart';
import 'texture.dart';

enum PlxShader { vertex, fragment }

abstract class PlxMaterial {
  MaterialInstance use(PlxShader stage);
  void dispose();

  PlxTexture setTexture(PlxShader shader, String name, PlxTexture texture);
  ByteData setFloat(PlxShader shader, String name, double value);
  ByteData setInt(PlxShader shader, String name, int value);
  ByteData setBool(PlxShader shader, String name, bool value);
  ByteData setVector2(PlxShader shader, String name, Vector2 vector);
  ByteData setVector3(PlxShader shader, String name, Vector3 vector);
  ByteData setVector4(PlxShader shader, String name, Vector4 vector);
  ByteData setMatrix2(PlxShader shader, String name, Matrix2 matrix);
  ByteData setMatrix3(PlxShader shader, String name, Matrix3 matrix);
  ByteData setMatrix4(PlxShader shader, String name, Matrix4 matrix);
}

abstract class MaterialInstance {
  MaterialInstance use(PlxShader stage);
  MaterialInstance setFloat(String name, double value);
  MaterialInstance setInt(String name, int value);
  MaterialInstance setBool(String name, bool value);
  MaterialInstance setVector2(String name, Vector2 vector);
  MaterialInstance setVector3(String name, Vector3 vector);
  MaterialInstance setVector4(String name, Vector4 vector);
  MaterialInstance setMatrix2(String name, Matrix2 matrix);
  MaterialInstance setMatrix3(String name, Matrix3 matrix);
  MaterialInstance setMatrix4(String name, Matrix4 matrix);
  MaterialInstance setTexture(String name, PlxTexture texture);
}
