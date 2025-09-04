
import 'dart:math';
import 'package:algorithm_visualization/algo/sort.dart';

void main(){
  var rng=Random();
  var numbers=List.generate(10, (_)=>rng.nextInt(100));
  print(numbers);
  SortAlgo.bubble_sort(numbers, (a,b)=>a.compareTo(b));
  print(numbers);
}