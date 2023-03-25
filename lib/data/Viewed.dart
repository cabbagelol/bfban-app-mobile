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

  get toMap {
    return {
      "id": id,
    };
  }
}
