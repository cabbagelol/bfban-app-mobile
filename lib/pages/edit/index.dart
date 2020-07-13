import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/edit/ImageRadioController.dart';
import 'package:bfban/widgets/edit/gameTypeRadio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_elui/elui.dart';
import 'package:flutter_svg/flutter_svg.dart';

class editPage extends StatefulWidget {
  @override
  _editPageState createState() => _editPageState();
}

class _editPageState extends State<editPage> {
  ImageRadioController controller;

  int gameTypeIndex = 1;

  List reportInfoCheatMethods = new List();

  bool reportInfoUserNameIsBool = false;

  bool reportInfoUserNameLoad = false;

  List games = [
    {
      "img": "assets/images/edit/battlefield-1-logo.png",
      "value": "bf1",
    },
    {
      "img": "assets/images/edit/battlefield-v-png-logo.png",
      "value": "bfv",
    },
  ];

  Map<String, dynamic> reportInfo = {
    "originId": "",
    "gameName": "",
  };

  var images = [
    "https://file03.16sucai.com/2016/10/1100/16sucai_p20161017095_34f.JPG",
    "https://file03.16sucai.com/2016/10/1100/16sucai_p20161017095_34f.JPG",
    "https://file03.16sucai.com/2016/10/1100/16sucai_p20161017095_34f.JPG",
  ];

  String valueCaptcha = "";

  String CaotchaCookie = "";

  bool valueCaptchaLoad = false;

  @override
  void initState() {
    controller = new ImageRadioController();
    super.initState();

    setState(() {
      reportInfo["gameName"] = games[0]["value"];
    });

    this._getCaptcha();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// 更新验证码
  void _getCaptcha() async {
    var t = DateTime.now().millisecondsSinceEpoch.toString();

    setState(() {
      valueCaptchaLoad = true;
    });

    Response<dynamic> result = await Http.request(
      'api/captcha?r=${t}',
      method: Http.GET,
    );

    result.headers['set-cookie'].forEach((i) {
      CaotchaCookie += i + ';';
    });

    setState(() {
      valueCaptcha = result.data;
      valueCaptchaLoad = false;
    });
  }

  /// 验证用户是否存在
  _getIsUser() async {
    setState(() {
      reportInfoUserNameLoad = true;
    });

    if (reportInfo["originId"] == "" || reportInfo["originId"].toString().length <= 0) {
      EluiMessageComponent.warning(context)(
        child: Text("举报这ID不存在,请检查用户ID是否填写正确"),
      );
      setState(() {
        reportInfoUserNameLoad = false;
      });
      return;
    }

    var result = await Http.request(
      'api/checkGameIdExist',
      headers: {'Cookie': this.CaotchaCookie},
      data: {
        "id": reportInfo["originId"],
      },
      method: Http.POST,
    );

    if (!result.data["idExist"]) {
      EluiMessageComponent.warning(context)(
        child: Text("举报这ID不存在,请检查用户ID是否填写正确"),
      );
      return 1;
    }

    var data = result.data;

    setState(() {
      reportInfo["avatarLink"] = data["avatarLink"];
      reportInfo["originPersonaId"] = data["originPersonaId"];
      reportInfo["originUserId"] = data["originUserId"];

      /// 更改检测状态
      reportInfoUserNameIsBool = true;
      reportInfoUserNameLoad = false;
    });

    return 0;
  }

  /// 提交举报
  void _onCheaters() async {
    var _is;

    /// 是否检测过。 避免重复检测
    if (!reportInfoUserNameIsBool) {
      _is = await this._getIsUser();

      if (_is == 1) {
        return;
      }
    }

    if (reportInfo["cheatMethods"] == "") {
      EluiMessageComponent.warning(context)(
        child: Text("至少选择一个作弊方式"),
      );
      return;
    }

    if (reportInfo["description"] == "") {
      EluiMessageComponent.warning(context)(
        child: Text("至少填写描述内容, 有力的证据"),
      );
      return;
    }

    if (reportInfo["bilibiliLink"] == "") {
      EluiMessageComponent.warning(context)(
        child: Text("填写有效的举报视频"),
      );
      return;
    }

    if (reportInfo["captcha"] == "") {
      EluiMessageComponent.warning(context)(
        child: Text("请填写验证码"),
      );
      return;
    }

    print(reportInfo);

    Response<dynamic> result = await Http.request(
      'api/cheaters/',
      parame: reportInfo,
      method: Http.GET,
    );

    print(result);

    if (result.data["error"] > 0) {
      EluiMessageComponent.warning(context)(
        child: Text("至少填写描述内容, 有力的证据"),
      );
    } else if (result.data["error"] == 0) {
      EluiMessageComponent.success(context)(
        child: Text("发布成功"),
      );
      Navigator.pop(context);
    }
  }

  /// 修改举报游戏类型
  void _setGamesIndex(num index) {
    setState(() {
      gameTypeIndex = index;

      reportInfo["gameName"] = games[gameTypeIndex - 1]["value"];
    });
  }

  /// 复选举报游戏作弊行为
  List<Widget> _setCheckboxIndex() {
    List<Widget> list = new List();

    List _cheatingTpyes = new List();

    String _value = "";

    num _valueIndex = 0;

    Config.cheatingTpyes.forEach((key, value) {
      _cheatingTpyes.add({
        "name": value,
        "value": key,
      });
    });

    _cheatingTpyes.forEach((element) {
      list.add(
        EluiCheckboxComponent(
          color: Colors.amber,
          child: Text(
            element["name"],
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          onChanged: (bool) {
            print(bool);
            setState(() {
              if (bool) {
                reportInfoCheatMethods.add(element["value"]);
              } else {
                reportInfoCheatMethods.remove(element["value"]);
              }
            });
          },
        ),
      );
    });

    reportInfoCheatMethods.forEach((element) {
      _value += element + (_valueIndex >= reportInfoCheatMethods.length - 1 ? "" : ",");
      _valueIndex += 1;
    });

    setState(() {
      reportInfo["cheatMethods"] = _value;
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/bk-companion.jpg',
          ),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Color(0xff364e80),
          elevation: 0,
          centerTitle: true,
          title: Text(
            "举报作弊",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              color: Color(0xff364e80),
              child: Text(
                "提交",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                this._onCheaters();
              },
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Color(0xff111b2b),
                border: Border(
                  bottom: BorderSide(
                    width: 10,
                    color: Colors.black,
                  ),
                ),
              ),
              child: EluiCellComponent(
                title: "草稿箱",
                label: "副本",
                theme: EluiCellTheme(
                  backgroundColor: Colors.transparent,
                  titleColor: Colors.white,
                ),
                cont: Icon(
                  Icons.inbox,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

            /// S 游戏类型
            Container(
              color: Color(0xff111b2b),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "游戏",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(
                    width: 45,
                  ),
                  Row(
                    children: <Widget>[
                      gameTypeRadio(
                        select: 1,
                        index: gameTypeIndex == 1,
                        child: Image.asset(
                          "assets/images/edit/battlefield-1-logo.png",
                          width: 80,
                        ),
                        onTap: () {
                          this._setGamesIndex(1);
                        },
                      ),
                      gameTypeRadio(
                        select: 2,
                        index: gameTypeIndex == 2,
                        child: Image.asset(
                          "assets/images/edit/battlefield-v-png-logo.png",
                          width: 80,
                        ),
                        onTap: () {
                          this._setGamesIndex(2);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// E 游戏类型

            /// S 游戏ID
//            EluiTipComponent(
//              child: Text("一次只填写一个ID，不要把战队名字写进来，不要写成自己的ID"),
//            ),
//            EluiTipComponent(
//              child: Text("游戏ID是不区分大小写的，但请特别注意区分i I 1 l L o O 0，正确填写举报ID"),
//            ),
            Container(
              padding: EdgeInsets.only(
                top: 10,
                left: 20,
                right: 20,
              ),
              color: Color(0xff111b2b),
              child: Column(
                children: <Widget>[
                  Text(
                    reportInfo["originId"] == "" ? "USER ID" : "" + reportInfo["originId"].toString(),
                    style: TextStyle(
                      color: reportInfo["originId"] == "" ? Colors.white12 : Colors.white,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Center(
                    child: Text(
                      reportInfoUserNameLoad ? "检查用户是否存在..." : (reportInfoUserNameIsBool ? "已通过检查" : "检查用户id是否举报正确"),
                      style: TextStyle(
                        color: reportInfoUserNameIsBool ? Colors.lightGreen : Colors.white12,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Color(0xff111b2b),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: EluiInputComponent(
                title: "游戏ID",
                theme: EluiInputTheme(
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Internalstyle: true,
                value: "",
                placeholder: "游戏ID",
                onChange: (data) {
                  setState(() {
                    reportInfo["originId"] = data["value"];
                  });
                },
              ),
            ),

            /// E 游戏ID

            /// S 作弊方式
            Container(
              color: Color(0xff111b2b),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "作弊方式",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 80,
                      height: 25,
                      margin: EdgeInsets.only(
                        left: 10,
                      ),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: this._setCheckboxIndex(),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

            /// E 作弊方式

            /// S 视频链接
            Container(
              color: Color(0xff111b2b),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: EluiInputComponent(
                title: "视频链接",
                theme: EluiInputTheme(
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Internalstyle: true,
                value: "",
                placeholder: "http(s)://",
              ),
            ),

            /// E 视频链接

            /// S 言论
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              color: Color(0xff111b2b),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text(
                      "请列出阐明足够的证据，编辑器支持上传图片（限制2M)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white12,
                      ),
                    ),
                    margin: EdgeInsets.only(
                      bottom: 10,
                    ),
                  ),
                  Wrap(
                    spacing: 10,
                    children: <Widget>[
                      Icon(
                        Icons.image,
                        size: 20,
                        color: Colors.white,
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xff111b2b),
                border: Border(
                  bottom: BorderSide(
                    width: 10,
                    color: Colors.black,
                  ),
                ),
              ),
              child: EluiTextareaComponent(
                color: Colors.white,
                maxLength: 500,
                maxLines: 15,
                onChange: (data) {
                  setState(() {
                    reportInfo["description"] = data["value"];
                  });
                },
              ),
            ),

            /// E 言论

            /// S 验证码
            Container(
              color: Color(0xff111b2b),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: EluiInputComponent(
                title: "验证码",
                Internalstyle: true,
                theme: EluiInputTheme(
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onChange: (data) {
                  setState(() {
                    reportInfo["captcha"] = data["value"];
                  });
                },
                right: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    margin: EdgeInsets.only(
                      left: 10,
                      bottom: 10,
                      top: 10,
                    ),
                    width: 100,
                    height: 55,
                    child: valueCaptchaLoad
                        ? Icon(
                            Icons.slow_motion_video,
                            color: Colors.black54,
                          )
                        : new SvgPicture.string(
                            valueCaptcha,
                          ),
                  ),
                  onTap: () {
                    this._getCaptcha();
                  },
                ),
                maxLenght: 4,
                placeholder: "输入验证码",
              ),
            ),

            /// E 验证码
          ],
        ),
      ),
    );
  }
}
