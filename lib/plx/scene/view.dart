import 'package:exagon_plus/plx/core/component.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class PlxView extends Component{
  PlxView();
  Matrix4 getResult(double w, double h);
}