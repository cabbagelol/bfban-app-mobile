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
  bool banAppeals;
  bool details;
  num? from;

  StatisticsParame({
    this.reports = true,
    this.players = true,
    this.confirmed = true,
    this.registers = true,
    this.banAppeals = true,
    this.details = true,
    this.from,
  });

  get toMap {
    return {
      "reports": reports,
      "players": players,
      "confirmed": confirmed,
      "registers": registers,
      "banAppeals": banAppeals,
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
  int? banAppeals;
  int? details;

  StatisticsData({
    this.reports,
    this.players,
    this.confirmed,
    this.registers,
    this.banAppeals,
    this.details,
  });

  setData (Map i) {
    reports = i["reports"];
    players = i["players"];
    confirmed = i["confirmed"];
    registers = i["registers"];
    banAppeals = i["banAppeals"];
    details = i["details"];
    return toMap;
  }

  get toMap {
    return {
      "reports": reports,
      "players": players,
      "confirmed": confirmed,
      "registers": registers,
      "banAppeals": banAppeals,
      "details": details,
    };
  }
}
