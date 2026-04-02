import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:neosecurity/SecurityInfo/Security_Home.dart';
import 'package:neosecurity/Setting.dart';

import 'package:url_launcher/url_launcher.dart';

import 'ERPInfo/ERP_Home.dart';
import 'Select/Cus_Select.dart';
import 'functions.dart';
import 'globals.dart';
import 'notice.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Display에서 데이터 로딩이 완료된 후 진입하므로 바로 UI 상태 초기화
    selectedOption = stateMatchingModel[stateList['state']] ?? '';

    // 10초마다 현재 상태 갱신
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) return;
      getState().then((_) {
        if (mounted) {
          setState(() {
            state = stateList['state'] ?? '';
            selectedOption = stateMatchingModel[state] ?? '';
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text(
            '시큐리티 정보',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xfff7f7f7),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          children: [
            CusSelect(
              title: "",
              onPressed: () {
                setState(() {
                  print('stateList[state]' + stateList['state'].toString());
                });
                UiChanger(state);
              },
            ),

            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          getImagePath(stateList['state']),
                          fit: BoxFit.cover, // 필요에 따라 추가
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Row(
                        children: [
                          command('경계'),
                          const SizedBox(width: 10),
                          command('해제'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    //개통코드가 한세시큐리티에 해당하면 문열림, 문닫힘 보임
                    if (syscode == '62083651') ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Row(
                          children: [
                            command('문열림'),
                            const SizedBox(width: 10),
                            command('문닫힘'),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        //인덱스에 원격사용여부가 true면 원격요청버튼 보임
                        if (isremote == 'true') ...[
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  String result = await receiveRemote();
                                  if (result == "1") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('원격요청되었습니다.'),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('원격오류. 관리자에게 문의하세요.'),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff2196f3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  shadowColor: Colors.transparent,
                                ),
                                child: const Text('원격요청'),
                              ),
                            ),
                          ),
                        ],
                        //원격요청버튼, 관제실통화 버튼이 둘 다 보여지게 설정되면 사이 여백 추가
                        if ((isremote == 'true') && (centerPhone != ""))
                          const SizedBox(width: 10),

                        //고객센터 전화번호 값이 빈칸이 아니면 관제실통화 버튼 보임
                        if (centerPhone != "")
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  launchUrl(
                                    Uri(scheme: 'tel', path: centerPhone),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Color(0xff545454)),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  shadowColor: Colors.black38,
                                  elevation: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.phone, color: Colors.black54),
                                    SizedBox(width: 12),
                                    Text(
                                      "관제실 통화",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            //영업관리표시여부 열이 true면 영업정보 보임.
            if (erpVisible == true) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SecurityHome(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  //side: BorderSide(color: Color(0xff545454)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                shadowColor: Colors.transparent,
                                elevation: 4,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.security,
                                    size: 30,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "관제정보",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ErpHome(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  //side: BorderSide(color: Color(0xff545454)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                shadowColor: Colors.transparent,
                                elevation: 4,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bar_chart,
                                    size: 30,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "영업정보",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Notice(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  //side: BorderSide(color: Color(0xff545454)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                shadowColor: Colors.transparent,
                                elevation: 4,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.campaign,
                                    size: 30,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "공지사항",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Setting(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  //side: BorderSide(color: Color(0xff545454)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                shadowColor: Colors.transparent,
                                elevation: 4,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.settings,
                                    size: 30,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "환경설정",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SecurityHome(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  //side: BorderSide(color: Color(0xff545454)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                shadowColor: Colors.transparent,
                                elevation: 4,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.security,
                                    size: 30,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "관제정보",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Setting(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  //side: BorderSide(color: Color(0xff545454)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                shadowColor: Colors.transparent,
                                elevation: 4,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.settings,
                                    size: 30,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "환경설정",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    //const SizedBox(height: 20),

                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: SizedBox(
                    //         width: double.infinity,
                    //         child: ElevatedButton(
                    //           onPressed: () async {
                    //             Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                 builder: (context) => const Notice(),
                    //               ),
                    //             );
                    //             dispose();
                    //           },
                    //           style: ElevatedButton.styleFrom(
                    //             backgroundColor: Colors.white,
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(12),
                    //               //side: BorderSide(color: Color(0xff545454)),
                    //             ),
                    //             padding: const EdgeInsets.symmetric(vertical: 0),
                    //             textStyle: TextStyle(
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //             shadowColor: Colors.transparent,
                    //             elevation: 4,
                    //           ),
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               Icon(
                    //                 Icons.campaign,
                    //                 size: 30,
                    //                 color: Colors.black54,
                    //               ),
                    //               SizedBox(width: 12),
                    //               Text(
                    //                 "공지사항",
                    //                 style: TextStyle(
                    //                   fontSize: 14,
                    //                   color: Colors.black54,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //
                    //
                    //     const SizedBox(width: 10),
                    //     Expanded(
                    //       child: SizedBox(
                    //         width: double.infinity,
                    //         child: ElevatedButton(
                    //           //로그인된 휴대폰번호로 영업고객이 있는지 확인하고 API에서 들고온 정보가 없으면 오류메세지
                    //           onPressed: () async {
                    //             () async {
                    //               bool isConfirmed = await RestApiService()
                    //                   .isERPUserConfirm(syscode, phoneCode);
                    //
                    //               if (!isConfirmed) {
                    //                 ScaffoldMessenger.of(context).showSnackBar(
                    //                   const SnackBar(
                    //                     content: Text('등록된 영업고객이 없습니다.'),
                    //                   ),
                    //                 );
                    //               } else {
                    //                 //검증 모두 통과하면
                    //                 Navigator.push(
                    //                   context,
                    //                   MaterialPageRoute(
                    //                     builder: (context) => const ErpHome(),
                    //                   ),
                    //                 );
                    //                 dispose();
                    //               }
                    //             }();
                    //           },
                    //           style: ElevatedButton.styleFrom(
                    //             backgroundColor: Colors.white,
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(12),
                    //               //side: BorderSide(color: Color(0xff545454)),
                    //             ),
                    //             padding: const EdgeInsets.symmetric(vertical: 0),
                    //             textStyle: TextStyle(
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //             shadowColor: Colors.transparent,
                    //             elevation: 4,
                    //           ),
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               Icon(
                    //                 Icons.bar_chart,
                    //                 size: 30,
                    //                 color: Colors.black54,
                    //               ),
                    //               SizedBox(width: 12),
                    //               Text(
                    //                 "영업정보",
                    //                 style: TextStyle(
                    //                   fontSize: 14,
                    //                   color: Colors.black54,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  //라디오버튼
  Widget command(String value) {
    final bool isSelected = selectedOption == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedOption = value;
            print(selectedOption);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xff5dc7ff) : Color(0xffefefef),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

String UiChanger(String state) {
  String result = "";

  result = stateMatchingModel[stateList['state']] ?? '';
  print(stateMatchingModel[stateList['state']]);
  print('UiChanger$result');
  getImagePath(state);
  return state;
}
