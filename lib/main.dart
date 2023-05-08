import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gps_pending_payment_f/Model/PendingOrderModel.dart';
import 'package:gps_pending_payment_f/Theam/Theam.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  void onPayableAmountChanged(int amount) {
    // do something with the payable amount
    print("object");
  }
}

class _MyAppState extends State<MyApp> {
  String userCode = "";
  String token = "";
  String baseUrl = "";
  PendingOrder? pendingOrder;
  List<UnpaidOrder> unpaidOrderList = [];
  int? payableAmount;

  final MethodChannel channel = MethodChannel('com.example.myapp/mychannel');

  @override
  void initState() {
    super.initState();
    const MethodChannel('myChannel').setMethodCallHandler(_receiveFromNative);
   // fetchAPI();
  }

  Future<dynamic> _receiveFromNative(MethodCall call) async {
    switch (call.method) {
      case 'sendString':
        setState(() {
          Map<String, dynamic> _receiveddataFromOp = Map.from(call.arguments);
          userCode = _receiveddataFromOp["userCode"];
          token = _receiveddataFromOp["token"];
          baseUrl = _receiveddataFromOp["baseUrl"];
          pendingOrder = null;
          unpaidOrderList = [];
          payableAmount = null;
          fetchAPI();
          print(_receiveddataFromOp);
        });
        break;
      default:
        throw UnimplementedError("Method ${call.method} not implemented");
    }
  }

  Future fetchAPI() async {
    var url = Uri.parse(baseUrl+'/shield/payment/pending-orders?pageNo=0&pageSize=500');
    final response = await http.get(url, headers: {"token": token,"userCode" : userCode} );
    // var url = Uri.parse('https://mocki.io/v1/e7353b3d-d8e2-4874-bdf4-a41645657f87');
    // final response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(response.body);
      pendingOrder = PendingOrder.fromJson(data);
      //PendingOrder pendingOrderCopy = PendingOrder.fromJson(data);
      unpaidOrderList = pendingOrder?.data?.unpaidOrders ?? [];
      pendingOrder?.data?.unpaidOrders.forEach((subject) {
        payableAmount = ((payableAmount ?? 0) + (subject.payableAmount ?? 0)).toInt();
        //print(subject.payableAmount ?? 0);
      });
      setState(() {});
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              channel.invokeMethod('backClicked');
            },
          ),
          title: Text('Pending Payment', style: bodyLarge.copyWith(fontWeight: FontWeight.w600, fontSize: 18)),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add_alert),
              tooltip: 'Show Snackbar',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This is a snackbar')));
              },
            ),
            IconButton(
              icon: const Icon(Icons.navigate_next),
              tooltip: 'Go to the next page',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Next page'),
                      ),
                      body: const Center(
                        child: Text(
                          'This is the next page',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                ));
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Center(
                    child: Text(token ?? "No string received"),
                  ),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(bottom: 70),
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          // border: Border.all(width: 1, color: lightGreySecondary),
                          // borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: lightGreySecondary,
                          ),
                          borderRadius: BorderRadius.circular(8.0), //<-- SEE HERE
                        ),
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                          itemCount: pendingOrder?.data?.unpaidOrders.length ?? 0,
                          itemBuilder: (context, index) {

                             return PendingPaymentCell(index: index, unpaidOrder: pendingOrder!.data!.unpaidOrders[index]!,
                               onPayableAmountChanged: (amount) {
                                 setState(() {
                                   payableAmount = (payableAmount ?? 0) + amount;
                                   // if (unpaidOrderList?.contains(unpaidOrder) ?? false) {
                                   //   print(unpaidOrder);
                                   //   unpaidOrderList?.remove(unpaidOrder);
                                   // }
                                   print(payableAmount);
                                 });
                               },
                             );
                          }
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.only(top: 16),
                  height: 90,
                  color: Colors.grey,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total amount to pay:"),
                            Text("${payableAmount}"),
                          ],
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(bluePrimary), // Background color
                              minimumSize: MaterialStateProperty.all(Size(150, 45)),
                          ),
                          onPressed: () {
                            List<UnpaidOrder> unpaidOrderArr = [];
                            unpaidOrderList.forEach((subject) {
                              //payableAmount = ((payableAmount ?? 0) + (subject.payableAmount ?? 0));
                              //print(subject.payableAmount ?? 0);
                              if (subject.isSelected) {
                                unpaidOrderArr.add(subject);
                              }
                            });
                            print(unpaidOrderArr.length);
                            channel.invokeMethod('data', {
                              'myData': payableAmount,
                              'entityId' : ["1","2","3","4"]
                            });
                          },
                          child: Text('Pay now', style: bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600),),
                        ),
                      )
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}

class PendingPaymentCell extends StatefulWidget {
  final int index;
  final UnpaidOrder unpaidOrder;
  final void Function(int amount) onPayableAmountChanged; // declare the callback function as a parameter
  const PendingPaymentCell({Key? key , required this.index, required this.unpaidOrder, required this.onPayableAmountChanged}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PendingPaymentCellState();
}

class _PendingPaymentCellState extends State<PendingPaymentCell> {

  //bool _checkbox = false;
  int index = -1;
  UnpaidOrder? unpaidOrder;
  //final MethodChannel channel = MethodChannel('com.example.myapp/mychannel');

  void _onCheckboxChanged(bool newValue) {
    setState(() {
      if (newValue) {
        widget.onPayableAmountChanged((widget.unpaidOrder.payableAmount ?? 0.0).toInt());
      } else {
        widget.onPayableAmountChanged((-(widget.unpaidOrder.payableAmount ?? 0.0).toInt()));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    index = widget.index;
    unpaidOrder = widget.unpaidOrder;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: unpaidOrder?.isSelected,
                  onChanged: (value) {

                    setState(() {
                      if (unpaidOrder?.isSelected ?? false) {
                        _onCheckboxChanged(false);
                      }
                      else {
                        _onCheckboxChanged(true);
                      }
                      unpaidOrder?.isSelected = !(unpaidOrder?.isSelected ?? false);
                    });
                  },
                ),
                Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unpaidOrder?.name ?? "",
                            style: bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16, color: darkGreySecondary
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Total amount" + ":" + " \u{20B9}${unpaidOrder?.totalAmount ?? 0} ",
                                style: bodyMedium.copyWith(color: greySecondary),
                              ),
                              InkWell(
                                onTap: () {
                                  // channel.invokeMethod('data', {'myData': unpaidOrder?.orderId});
                                  print("Mahakal");
                                  if ((unpaidOrder?.vehNums?.length != null) && (unpaidOrder!.vehNums!.length! > 0)) {
                                    showModalBottomSheet<void>(
                                      backgroundColor: Colors.redAccent.withOpacity(0),
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return BottomSheetExample(unpaidOrder: unpaidOrder!,);
                                      },
                                    );
                                  }
                                },
                                child: ((unpaidOrder?.vehCount ?? 0) > 1) ?
                                Visibility(
                                  visible: ((unpaidOrder?.vehCount != null) || ((unpaidOrder?.vehCount ?? 0) > 0)),
                                  child: Text(
                                      "Trucks" + " ${(unpaidOrder?.vehCount ?? 0)}",
                                    style: bodyMediumUnderline.copyWith(color: bluePrimary)
                                  ),
                                ) :
                                Visibility(
                                  visible: ((unpaidOrder?.vehCount == null) && ((unpaidOrder?.vehCount ?? 0) == 0)),
                                  child: Text(
                                    "Truck" + " ${(unpaidOrder?.vehCount ?? 0)}",
                                      style: bodyMediumUnderline.copyWith(color: bluePrimary)
                                  ),
                                )
                              )
                            ],
                          ),
                          Visibility(
                            visible: ((unpaidOrder?.paidAmount ?? 0) > 0),
                            child: Text(
                              "Advance paid" + ":" + " \u{20B9}${unpaidOrder?.paidAmount}",
                              style: bodyMedium.copyWith(color: greySecondary),
                            ),
                          )
                        ],
                      ),
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                      " \u{20B9}${unpaidOrder?.payableAmount ?? 0}",
                      style: bodyLarge.copyWith(color: darkGreySecondary)
                  ),
                )
              ],
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: lightGreySecondary,
          ),
        ],
      ),
    );
  }
}





class BottomSheetExample extends StatelessWidget {
  final UnpaidOrder unpaidOrder;
  const BottomSheetExample({super.key, required this.unpaidOrder});


  @override
  Widget build(BuildContext context) {
     return Container(
       constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height-100.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.end,
         mainAxisSize: MainAxisSize.min,
         children: [
           IconButton(
             iconSize: 35,
             icon: const Icon(Icons.volume_up),
             onPressed: () {
               Navigator.pop(context);
             },
           ),
           Container(
             width: MediaQuery.of(context).size.width,
             decoration: const BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.only(
                   topLeft: Radius.circular(8),
                   topRight: Radius.circular(8)
                 )
             ),
             child: Padding(
               padding: const EdgeInsets.all(16),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                       unpaidOrder.pkgeName ?? "",
                     style: bodyLarge.copyWith(
                         fontWeight: FontWeight.w600,
                       fontSize: 18, color: darkGreySecondary
                     ),
                   ),
                   Visibility(
                     visible: (unpaidOrder.pkgDescription != null) ? true : false,
                     child: Text(
                         unpaidOrder.pkgDescription ?? "",
                       style: bodyMedium.copyWith(color: midGreySecondary),
                     ),
                   )
                 ],
               ),
             ),
           ),
           Flexible(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: unpaidOrder!.vehNums!.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile (
                          leading: Icon(Icons.fire_truck),
                          title: Text(
                              "${unpaidOrder!.vehNums[index]!}",
                            style: bodyLarge.copyWith(color: greySecondary),
                          ),
                        ),
                        Divider(
                          height: 0,
                          thickness: 1,
                          indent: 16,
                          endIndent: 0,
                          color: lightGreySecondary,
                        ),
                      ],
                    );
                  }
              ),
            ),
    ),
         ],
       ),
     );
  }
}