import 'package:exa_vortex/plx/core/component.dart';
import 'mesh.dart';

class MeshComponent extends Component {
  Mesh? mesh;

  MeshComponent(this.mesh);

  @override
  void dispose() {
    mesh = null;
    super.dispose();
  }
}
