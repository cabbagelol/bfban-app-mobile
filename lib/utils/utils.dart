import 'package:flutter/material.dart';
//import 'package:quiver/strings.dart';
import 'dart:math' as math;

Map url2query(String url){
  var search = new RegExp('([^&=]+)=?([^&]*)');
  var result = new Map();

  // Get rid off the beginning ? in query strings.
  if (url.startsWith('?')) url = url.substring(1);

  // A custom decoder.
  decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

  // Go through all the matches and build the result map.
  for (Match match in search.allMatches(url)) {
    result[decode(match.group(1))] = decode(match.group(2));
  }

  return result;
}

Color randomColor(){
  return Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);
}