abstract class Paging {
  int? skip;
  int? _minskip;
  int? limit;

  Paging({
    this.limit = 40,
    this.skip = 1,
  });

  resetPage () {
    skip = _minskip;
  }

  nextPage({int count = 1}) {
    skip = skip! + count;
  }

  prevPage({int count = 1}) {
    if (skip! <= _minskip!) return;
    skip = skip! - count;
  }

  Map get pageToMap => Map.from({
        "skip": skip,
        "limit": limit,
      });
}

abstract class Sort {
  String? sort;

  Sort({
    this.sort,
  });
}
