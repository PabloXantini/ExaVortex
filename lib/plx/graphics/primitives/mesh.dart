abstract class PlxMesh {
  /// Updates the mesh geometry with new vertices and optional indices.
  void overwrite(List<double> vertices, {List<int>? indices16, List<int>? indices32});
}
