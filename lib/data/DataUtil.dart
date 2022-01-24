class ObjectToMap {
   toMap (object) {
    late Map<dynamic, dynamic> map = {};

    object.forEach((i) => {
      map[i] = object[i]
    });

    return map;
  }

}

