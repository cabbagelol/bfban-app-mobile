class ViewedStatus {
  bool? load;
  ViewedStatusParame? parame;

  ViewedStatus({
    this.load,
    this.parame,
  });
}

class ViewedStatusParame {
  num? id;

  ViewedStatusParame({
    this.id,
  });

  Map<String, dynamic> get toMap {
    return {
      "data": {
        "id": id,
      }
    };
  }
}
