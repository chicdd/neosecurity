import 'package:flutter/material.dart';
import 'package:neosecurity/Select/ERP_Select.dart';
import '../RestAPI.dart';
import 'package:neosecurity/globals.dart';

class ERPCusInfo extends StatefulWidget {
  const ERPCusInfo({super.key});

  @override
  State<ERPCusInfo> createState() => _ERPCusInfoState();
}

class _ERPCusInfoState extends State<ERPCusInfo> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await erpinitializeData();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (erpCusInfoList.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('영업정보가 없습니다'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  Future<void> fetchErpCusInfo() async {
    try {
      final result = await RestApiService().erpCusInfoRequest(
        syscode,
        yongnum,
        phoneCode,
      );
      erpCusInfoList = result;
      setState(() {});
      //print("erpCusInfoList: ${erpCusInfoList}");
    } catch (e) {
      //print("API 호출 오류: $e");
    }
    print('api호출함');
  }

  Future<void> erpinitializeData() async {
    try {
      // 1단계: 고객 리스트 가져오기
      final erpcustomers = await RestApiService().erpCusListRequest(syscode, phoneCode);
      erpList = erpcustomers;

      if (erpcustomers.isEmpty) return;

      // 현재 선택된 관제 고객의 name이 erpList에 있는지 확인
      final selectedName = cusList.isNotEmpty ? cusList[selectInt]['name'] ?? '' : '';
      final matchIdx = erpList.indexWhere((e) => e['name'] == selectedName);
      if (matchIdx == -1) {
        erpselectInt = -1;
        yongnum = '';
        return;
      }

      erpselectInt = matchIdx;
      yongnum = erpList[matchIdx]['yongnum'] ?? '';

      // 2단계: 선택된 고객의 상세 정보 가져오기
      if (yongnum.isNotEmpty) {
        erpCusInfoList = await RestApiService().erpCusInfoRequest(syscode, yongnum, phoneCode);
      }
    } catch (e) {
      print('erpinitializeData 오류: $e');
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
            ERPSelect(
              onPressed: () {
                fetchErpCusInfo(); // 내부에서 setState() 호출
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
                        '기본 정보',
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
                        // color: Colors.white,
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
                                erpCusInfoList.isNotEmpty
                                    ? erpCusInfoList[0]
                                    : '',
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
                                erpCusInfoList.isNotEmpty
                                    ? erpCusInfoList[1]
                                    : '',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '연락처',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                erpCusInfoList.isNotEmpty
                                    ? erpCusInfoList[2]
                                    : '',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '납입방법',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                erpCusInfoList.isNotEmpty
                                    ? erpCusInfoList[3]
                                    : '',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '청구금액',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                erpCusInfoList.isNotEmpty
                                    ? erpCusInfoList[4]
                                    : '',
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
                        '계산서정보',
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
                        // color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '등록번호',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                erpCusInfoList.isNotEmpty
                                    ? erpCusInfoList[5]
                                    : '',
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
                                '상호',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                erpCusInfoList.isNotEmpty
                                    ? erpCusInfoList[6]
                                    : '',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '성명',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Flexible(
                                child: Text(
                                  erpCusInfoList.isNotEmpty
                                      ? erpCusInfoList[7]
                                      : '',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '사업장주소',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Flexible(
                                child: Text(
                                  erpCusInfoList.isNotEmpty
                                      ? erpCusInfoList[8]
                                      : '',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '업태',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                erpCusInfoList.isNotEmpty
                                    ? erpCusInfoList[9]
                                    : '',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '종목',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                erpCusInfoList.isNotEmpty
                                    ? erpCusInfoList[10]
                                    : '',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '담당자',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                erpCusInfoList.isNotEmpty
                                    ? erpCusInfoList[11]
                                    : '',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '핸드폰',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                erpCusInfoList.isNotEmpty
                                    ? erpCusInfoList[12]
                                    : '',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '이메일',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                erpCusInfoList.isNotEmpty
                                    ? erpCusInfoList[13]
                                    : '',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
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
