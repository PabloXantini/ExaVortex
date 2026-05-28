enum AttributeUsage { position, uv, normal, color, custom }

class VertexAttribute {
  final AttributeUsage usage;
  final int numArgs; // number of floats

  const VertexAttribute(this.usage, this.numArgs);
}

class VertexFormat {
  final String name;
  final List<VertexAttribute> attributes;
  final int stride; // total floats per vertex

  VertexFormat(this.name, this.attributes)
      : stride = attributes.fold(0, (sum, attr) => sum + attr.numArgs);
}

abstract class PlxMesh {
  // Abstract mesh representation.
}
