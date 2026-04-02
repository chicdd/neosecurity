import 'package:flutter/material.dart';
import '../RestAPI.dart';
import '../Select/Cus_Select.dart';
import 'package:neosecurity/globals.dart';

class SecurityCusInfo extends StatefulWidget {
  const SecurityCusInfo({super.key});

  @override
  State<SecurityCusInfo> createState() => _SecurityCusInfoState();
}

class _SecurityCusInfoState extends State<SecurityCusInfo> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([fetchSecuBasic(), fetchUserList()]);
    if (mounted) setState(() {});
  }

  Future<void> fetchSecuBasic() async {
    try {
      final result = await RestApiService().secuBasicRequest(syscode, monnum, phoneCode);
      secuBasicList = result;

      if (result.isNotEmpty && monnum.isNotEmpty) {
        stateList = await RestApiService().currentStateRequest(syscode, monnum, phoneCode);
        state = stateList['state'] ?? '';
      }
    } catch (e) {
      print('fetchSecuBasic 오류: $e');
    }
  }

  Future<void> fetchUserList() async {
    try {
      final result = await RestApiService().userListRequest(syscode, monnum, phoneCode);
      userList = result;
    } catch (e) {
      print('fetchUserList 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          children: [
            CusSelect(
              onPressed: () {
                _loadData(); // 내부에서 setState() 호출
              },
            ),

            const SizedBox(height: 15),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        '기본 가입 정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '고객명',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                secuBasicList.isNotEmpty ? secuBasicList[0] : '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '가입일자',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                secuBasicList.length > 1 ? secuBasicList[1] : '',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        '사용자',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Column(
                      children:
                          userList.map<Widget>((user) {
                            return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 30,
                                    horizontal: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        user['name'] ?? '로드 실패',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        user['phone'] ?? '로드 실패',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                  height: 1,
                                  color: Color(0xffdfdfdf),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
