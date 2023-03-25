/// 统计数据
class Statistics {
  late num page;
  late bool load;
  StatisticsData? data;
  StatisticsParame? params;

  Statistics({
    this.page = 0,
    this.load = false,
    required this.data,
    this.params,
  });
}

class StatisticsParame {
  bool reports;
  bool players;
  bool confirmed;
  bool registers;
  bool banappeals;
  bool details;
  num? from;

  StatisticsParame({
    this.reports = true,
    this.players = true,
    this.confirmed = true,
    this.registers = true,
    this.banappeals = true,
    this.details = true,
    this.from,
  });

  get toMap {
    return {
      "reports": reports,
      "players": players,
      "confirmed": confirmed,
      "registers": registers,
      "banappeals": banappeals,
      "details": details,
      "from": from,
    };
  }
}

class StatisticsData {
  int? reports;
  int? players;
  int? confirmed;
  int? registers;
  int? banappeals;
  int? details;

  StatisticsData({
    this.reports,
    this.players,
    this.confirmed,
    this.registers,
    this.banappeals,
    this.details,
  });

  setData (Map i) {
    reports = i["reports"];
    players = i["players"];
    confirmed = i["confirmed"];
    registers = i["registers"];
    banappeals = i["banappeals"];
    details = i["details"];
    return toMap;
  }

  get toMap {
    return {
      "reports": reports,
      "players": players,
      "confirmed": confirmed,
      "registers": registers,
      "banappeals": banappeals,
      "details": details,
    };
  }
}
