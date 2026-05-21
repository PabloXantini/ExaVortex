import 'package:exa_vortex/plx/graphics/mesh_component.dart';
import 'package:exa_vortex/plx/graphics/mesh_renderer.dart';
import 'package:exa_vortex/plx/graphics/text/geometry.dart';
import 'package:exa_vortex/plx/graphics/text/rich_text.dart';
import 'package:exa_vortex/plx/graphics/text/mesh_builder.dart';
import 'package:exa_vortex/plx/scene/3d/entity_3d.dart';
import 'package:flutter/material.dart' show Size;

class TextField3D extends Entity3D {
  final TextComposition composition;
  final Size bounds;
  final TextAlign align;
  final TextAnchor anchor;
  final double lineSpacing;
  final MeshRenderer? renderer;

  TextField3D({
    super.name = 'TextField3D',
    required this.composition,
    required this.bounds,
    this.align = TextAlign.left,
    this.anchor = TextAnchor.topLeft,
    this.lineSpacing = 0.0,
    this.renderer,
  }) {
    _build();
  }

  void _build() {
    final meshes = TextMeshBuilder.buildMeshes(
      composition,
      bounds: bounds,
      align: align,
      anchor: anchor,
      lineSpacing: lineSpacing,
    );

    for (var segment in composition.segments) {
      final fontId = segment.font.hashCode;
      final mesh = meshes[fontId];
      if (mesh == null) continue;

      final layerEntity = Entity3D(name: 'TextLayer_$fontId');
      layerEntity.addComponent(MeshComponent(mesh));
      layerEntity.addComponent(renderer ?? segment.font.defaultRenderer!);
      addChild(layerEntity);

      // Remove so we don't re-process if multiple segments share the same font
      meshes.remove(fontId);
    }
  }
}
