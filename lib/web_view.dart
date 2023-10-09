// ignore_for_file: prefer_const_constructors, sort_child_properties_last, unrelated_type_equality_checks

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

// import '../../provider/scrapDataPreovider.dart';
// import '../../service/app_service.dart';
// import 'package:http/http.dart' as http;
// import 'package:html/parser.dart' as parser;

class WebViewWebsite extends StatefulWidget {
  // String url;
  // String value;
  // WebViewWebsite({required this.url, required this.value});

  // const getWebViewLink({super.key});

  @override
  State<WebViewWebsite> createState() => _WebViewWebsiteState();
}

class _WebViewWebsiteState extends State<WebViewWebsite> {
  // WebViewController? controller;
  InAppWebViewController? _webViewController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  String Url = "";

  String imageurls = "";
  String? title;
  // ScrapView_Model? scrapView_Model;
  // AuthProvider? authProvider;
  File? imagefile;
  String? imageURL;
  bool imageupload = false;
  final picker = ImagePicker();
  var loadingPercentage = 0;
  bool isChecked = false;
  Logger logger = Logger();
  bool removeHeaderFooter = false;
  bool showMoreImg = false;
  bool adding = false;
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();
  TextEditingController controller5 = TextEditingController();
  TextEditingController controller6 = TextEditingController();
  String connectionStatus = 'Unknown';
  bool dropdown = false;
  bool showImge = false;
  bool isInternetUnavailableDialogShown = false; // Flag to track dialog state
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  int maxUsernameLength = 0;

  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;

  void initState() {
    // TODO: implement initState
    // scrapView_Model = Provider.of<ScrapView_Model>(context, listen: false);
    // authProvider = Provider.of<AuthProvider>(context, listen: false);

    super.initState();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);

    showMoreImg = false;
    // print("...........${authProvider!.URL}......${Url}......${domain}");
    startTimer();
    // if (authProvider!.URL != null) {
    //   setState(() {
    //     Url = authProvider!.URL!;
    //     controller6.text = Url;
    //   });
    // }

    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });

    // for (var accountInfo in authProvider!.account) {
    //   String username = accountInfo["username"].toString();
    //   int usernameLength = username.length;
    //   if (usernameLength > maxUsernameLength) {
    //     maxUsernameLength = usernameLength;
    //   }
    // }

    splitUrl();

    _updateNavigationState();
    adding = false;
  }

  @override
  void dispose() {
    // Dispose the FocusNode and TextEditingController when they're no longer needed
    _focusNode.dispose();
    controller6.dispose();
    _connectivitySubscription.cancel();

    super.dispose();
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.mobile) {
      _updateStatus('Mobile data');
      _hideNoInternetDialog(); // Hide the dialog if connection is restored
    } else if (connectivityResult == ConnectivityResult.wifi) {
      _updateStatus('WiFi');
      _hideNoInternetDialog(); // Hide the dialog if connection is restored
    } else {
      _updateStatus('No internet connection');
      Fluttertoast.showToast(
          msg: "No Internet Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
      // _showNoInterNetBottomSheet(context);
    }
  }

  void _updateStatus(String status) {
    setState(() {
      connectionStatus = status;
    });
    print('Connection Status: $status');
  }

  void _showNoInternetDialog() {
    if (!isInternetUnavailableDialogShown) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Internet Connection'),
            content:
                Text('Please check your internet connection and try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      isInternetUnavailableDialogShown = true;
    }
  }

  void _hideNoInternetDialog() {
    if (isInternetUnavailableDialogShown) {
      Navigator.of(context).pop();
      isInternetUnavailableDialogShown = false;
    }
  }

//  String connectionStatus = 'Unknown';
//   late StreamSubscription<ConnectivityResult> _connectivitySubscription;

// void _updateConnectionStatus(ConnectivityResult connectivityResult) {
//     if (connectivityResult == ConnectivityResult.mobile) {
//       setState(() => connectionStatus = 'Mobile data');
//     } else if (connectivityResult == ConnectivityResult.wifi) {
//       setState(() => connectionStatus = 'WiFi');
//     } else {
//       setState(() => connectionStatus = 'No internet connection');
//     }
//   }

  // @override
  // void dispose() {
  //   _connectivitySubscription.cancel();
  //   super.dispose();
  // }
  String? value;
  String? domain;
  splitUrl() {
    // String? value = authProvider!.URL;
    //  value=Uri.parse(url!.to);
    Uri uri = Uri.parse(value!);
    setState(() {
      domain = uri.host;
    });

    print("this is value URL ...${value}......$domain");
  }

  bool fieldColor = false;
//   scrapFunction(String url) async {
//     scrapView_Model = Provider.of<ScrapView_Model>(context, listen: false);

//     if (domain == "www.sephora.com" || domain == "sephora.com") {
//       print("in function url...$url");
//       bool res = await scrapView_Model!.getDataFromWebForSephora(url);
//       print("this is res data$res");
//       if (res == true) {
//         _webViewController!.reload();
//       }

//       print("sophora");
//     } else if (domain == "shop.lululemon.com" || domain == "lululemon.com") {
//       bool res = await scrapView_Model!.getDataFromWebForlululemon(url);
//       print("this is res data$res");
//       if (res == false) {
//         // Navigator.pop(context);
// //  Fluttertoast.showToast(
// //             msg: "No internet Try again",
// //             toastLength: Toast.LENGTH_SHORT,
// //             gravity: ToastGravity.CENTER,
// //             timeInSecForIosWeb: 1,
// //             textColor: Colors.white,
// //             fontSize: 16.0);
//       }
//       //   // _webViewController!.reload();
//       //   //  await scrapFunction(Url);
//       //   //     setState(() {
//       //   //       controller1.text =
//       //   //           scrapView_Model!.title != null ? scrapView_Model!.title! : "";
//       //   //       controller2.text = scrapView_Model!.price! ?? "";
//       //   //     });
//       //   //     showLoader(context);
//       //   //     Future.delayed(Duration(seconds: 15), () {
//       //   //       Navigator.of(context).pop();
//       //   //     });
//       //   // Fluttertoast.showToast(
//       //   //     msg: "Try again",
//       //   //     toastLength: Toast.LENGTH_SHORT,
//       //   //     gravity: ToastGravity.CENTER,
//       //   //     timeInSecForIosWeb: 1,
//       //   //     textColor: Colors.white,
//       //   //     fontSize: 16.0);
//       //   // print("no data found");
//       // }
//     } else if (domain == "www.catbirdnyc.com" || domain == "catbirdnyc.com") {
//       scrapView_Model!.getDataFromWebCatBird(url);
//     } else if (domain == "www.freepeople.com" || domain == "freepeople.com") {
//       bool res = await scrapView_Model!.getDataFromFreePeople(url);
//       if (res == false) {
//         _webViewController!.reload();
//         Fluttertoast.showToast(
//             msg: "Try again",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.CENTER,
//             timeInSecForIosWeb: 1,
//             textColor: Colors.white,
//             fontSize: 16.0);
//         print("no data found");
//         print("Free_People");
//       }
//     } else if (domain == "lovevery.eu" || domain == "lovevery.com") {
//       scrapView_Model!.getDataFromLuvEvery(url);
//       print("Lovevery");
//     } else if (domain == "www.rei.com" || domain == "rei.com") {
//       scrapView_Model!.getDataFromRai(url);
//       print("REI");
//     } else if (domain == "shopcraftedbeauty.com") {
//       scrapView_Model!.getDataFromShowCraftedByBeauty(url);
//     } else if (domain == "www.crateandbarrel.com" ||
//         domain == "crateandbarrel.com") {
//       scrapView_Model!.getDataFromWebcrateandbarrel(url);
//     } else if (domain == "Home_Depot") {
//       scrapView_Model!.getDataFromWebcrateandbarrel(url);
//     } else if (domain == "www.neimanmarcus.com" ||
//         domain == "neimanmarcus.com") {
//       scrapView_Model!.getDataFromWebNeimanmarcus(url);
//     } else if (domain == "www.hannaandersson.com" ||
//         domain == "hannaandersson.com") {
//       scrapView_Model!.getDataFromWebHannaandersson(url);
//     } else if (domain == "www.cb2.com" || domain == "cb2.com") {
//       bool res = await scrapView_Model!.getDataCB2(url);

//       if (res == false) {
//         _webViewController!.reload();
//         Fluttertoast.showToast(
//             msg: "Try again",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.CENTER,
//             timeInSecForIosWeb: 1,
//             textColor: Colors.white,
//             fontSize: 16.0);
//       }
//     } else if (domain == "www.westelm.com" || domain == "westelm.com") {
//       scrapView_Model!.getDataFromShowWestElm(url);
//     } else if (domain == "www.nordstrom.com" || domain == "nordstrom.com") {
//       bool res = await scrapView_Model!.getDataNordStrom(url);

//       if (res == false) {
//         _webViewController!.reload();
//         // Fluttertoast.showToast(
//         //     msg: "please wait......",
//         //     toastLength: Toast.LENGTH_SHORT,
//         //     gravity: ToastGravity.CENTER,
//         //     timeInSecForIosWeb: 1,
//         //     textColor: Colors.white,
//         //     fontSize: 16.0);
//       }
//     } else if (domain == "www.carawayhome.com" || domain == "carawayhome.com") {
//       bool res = await scrapView_Model!.getDataFromShowCaraWayHome(url);
//       print("this is res data$res");
//       if (res == false) {
//         _webViewController!.reload();
//         Fluttertoast.showToast(
//             msg: "Try again",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.CENTER,
//             timeInSecForIosWeb: 3,
//             textColor: Colors.white,
//             fontSize: 16.0);
//         print("no data found");
//       }
//     } else if (domain == "www.glassybaby.com" || domain == "glassybaby.com") {
//       scrapView_Model!.getDataFromGlassBaby(url);
//     } else if (domain == "rhoback.com") {
//       scrapView_Model!.getDataFromRhoBack(url);
//     } else if (domain == "www.volcom.com" || domain == "volcom.com") {
//       scrapView_Model!.getDataFromVolcom(url);
//     } else if (domain == "vuoriclothing.com") {
//       scrapView_Model!.getDataFromVuoriClothing(url);
//     } else if (domain == "zoechicco.com") {
//       scrapView_Model!.getDataFromZoeChicco(url);
//     } else if (domain == "shop.bombas.com" || domain == "bombas.com") {
//       scrapView_Model!.getDataFromBombas(url);
//     } else if (domain == "www.amazon.com" || domain == "amazon.com") {
//       scrapView_Model!.getDataFromAmazon(url);
//     } else if (domain == "www.anthropologie.com" ||
//         domain == "anthropologie.com") {
//       bool res = await scrapView_Model!.getDataAnthropologie(url);

//       print("this is res data$res");
//       if (res == false) {
//         _webViewController!.reload();
//         Fluttertoast.showToast(
//             msg: "Please Wait....",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.CENTER,
//             timeInSecForIosWeb: 3,
//             textColor: Colors.white,
//             fontSize: 16.0);
//         print("no data found");
//       }
//     } else if (domain == "www.zara.com" || domain == "zara.com") {
//       bool res = await scrapView_Model!.getDataFromZara(url);
//       print("this is res data$res");
//       if (res == false) {
//         _webViewController!.reload();
//         Fluttertoast.showToast(
//             msg: "Try again",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.CENTER,
//             timeInSecForIosWeb: 3,
//             textColor: Colors.white,
//             fontSize: 16.0);
//         print("no data found");
//       }
//     } else if (domain == "www.target.com" || domain == "target.com") {
//       scrapView_Model!.getDataFromTarget(url);
//     } else {
//       Fluttertoast.showToast(
//           msg: "No Site Found",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.CENTER,
//           timeInSecForIosWeb: 1,
//           textColor: Colors.white,
//           fontSize: 16.0);
//       print("no data found");
//     }
//   }

  bool _showFAB = false;
  void startTimer() {
    Timer(Duration(seconds: 3), () {
      setState(() {
        _showFAB = true;
      });
    });
  }

  // bool _canGoBack = false;
  // bool _canGoForword = false;
  bool check = false;

  // String google="https://www.google.com/search?q=\$encoded";x
  showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Return Dialog with loader content
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /////////Api//////////////////
  ///
  ///
  String? _title;
  String? _price;
  String? _imgUrl;
  String? _error;
  bool navigator = false;
  var chunks;
  String? pageContent;
  List imgesUrrl = [];

  /// using for every dynamic site scrapping Chat Gpt API required/////
  /// 
  /// 
  /// 
//   Future<void> fetchResponse(String text, double h, double w) async {
//     final apiUrl = 'https://api.openai.com/v1/chat/completions';
   
//     final apiKey = '';

//     print(text);

//     Map<String, String> headerss = {
//       'User-Agent':
//           'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36',
//     };

//     try {
//       final res = await http
//           .get(Uri.parse(text), headers: headerss)
//           .timeout(Duration(seconds: 12));

//       print("this is responnse ${res.body.toString()}");
//       print("this is responnse ${res.body.toString().length}");

//       if (res == null) {
//         _showToast("System Connection Timeout");
//         return;
//       }

//       final document = parser
//           .parse(res.body.toString().length < 2000 ? pageContent : res.body);
//       // final document = parser.parse(pageContent);

//       final headerElement = document.querySelector('header');
//       if (headerElement != null) {
//         headerElement.remove();
//       }

//       final footerElement = document.querySelector('footer');
//       if (footerElement != null) {
//         footerElement.remove();
//       }

//       var data = document.outerHtml;

//       int maxChuk = 31000;
//       if (data.length < maxChuk) {
//         maxChuk = data.length;
//       }

//       chunks = data.substring(0, maxChuk);
//       print("this is split result  ${chunks.length}");

//       final headers = {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $apiKey',
//       };

//       final prompt = '''{
//   "text": "This is our html DOM\\n${chunks}\\n\\nplease extract only product title, price, main image source of the product, \\n\\ 3 images of this product from this HTML DOM and please give precise answer in the below json format:",
//   "productTitle": "",
//   "price": "",
//   "mainImageSource": "",
//   "imageSources": ["", "", ""]
// }''';

//       final requestBody = jsonEncode({
//         'messages': [
//           {'role': 'user', 'content': prompt}
//         ],
//         'model': 'gpt-3.5-turbo-16k-0613',
//         'temperature': 1,
//         'max_tokens': 600,
//         'top_p': 1,
//         'frequency_penalty': 0,
//         'presence_penalty': 0,
//       });

//       final response = await http
//           .post(Uri.parse(apiUrl), headers: headers, body: requestBody)
//           .timeout(Duration(seconds: 15));
//       print("this is URLLLL res${response.body}");

//       if (response == null) {
//         Navigator.pop(context);
//         _showToast("System Connection Timeout");
//         return;
//       }

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         final assistantResponse =
//             responseData['choices'][0]['message']['content'];
//         print("this is result of assistant$assistantResponse");

//         var result = jsonDecode(assistantResponse);

//         print('Title: ${result['productTitle']}');
//         print('Price: ${result['price']}');
//         print('Image URL: ${result['mainImageSource']}');
//         print('Image URL 1: ${result['imageSources']}');
//         print('-----------');

//         setState(() {
//           _title = result['productTitle'];
//           _price = result['price'].toString();
//           _imgUrl = result['mainImageSource'];
//           imgesUrrl = result['imageSources'] ?? "";
//         });

//         scrapView_Model!.getNeimanPriceData(
//           _price ?? "",
//           _imgUrl ?? "",
//           _title ?? "",
//         );

//         Navigator.pop(context);
//         _showFullScreenBottomSheet(context, h, w);
//         setState(() {
//           controller1.text =
//               scrapView_Model!.title != null ? scrapView_Model!.title! : "";
//           controller2.text = scrapView_Model!.price ?? "";

//           print("..value${controller1.text}...${controller2.text}");
//         });
//       } else {
//         Navigator.pop(context);
//         _showToast("${response.statusCode}");
//         print('API request failed with status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');

//       final document = parser.parse(pageContent);

//       final headerElement = document.querySelector('header');
//       if (headerElement != null) {
//         headerElement.remove();
//       }

//       final footerElement = document.querySelector('footer');
//       if (footerElement != null) {
//         footerElement.remove();
//       }

//       var data = document.outerHtml;

//       int maxChuk = 31000;
//       if (data.length < maxChuk) {
//         maxChuk = data.length;
//       }

//       chunks = data.substring(0, maxChuk);
//       print("this is split result  ${chunks.length}");

//       final headers = {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $apiKey',
//       };

//       final prompt =
//           '''This is our html DOM\n${chunks}\n\nplease extract only product title, price, allmain image source of the product from this HTML DOM and please give precise answer in the below json format:
//     Product Title: 
//     Price: 
//     Main Image Source: ''';

//       final requestBody = jsonEncode({
//         'messages': [
//           {'role': 'user', 'content': prompt}
//         ],
//         // 'model': 'gpt-3.5-turbo',
//         // 'model': 'gpt-4-32k-0314',
//         'model': 'gpt-3.5-turbo-16k-0613',
//         'temperature': 1,
//         'max_tokens': 256,
//         'top_p': 1,
//         'frequency_penalty': 0,
//         'presence_penalty': 0,
//       });

//       final response = await http
//           .post(Uri.parse(apiUrl), headers: headers, body: requestBody)
//           .timeout(Duration(seconds: 15));
//       print("this is URLLLL res${response.body}");

//       if (response == null) {
//         Navigator.pop(context);
//         _showToast("System Connection Timeout");
//         return;
//       }

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         final assistantResponse =
//             responseData['choices'][0]['message']['content'];
//         print("this is result of assistant$assistantResponse");

//         var result = jsonDecode(assistantResponse);

//         print('Title: ${result['Product Title']}');
//         print('Price: ${result['Price']}');
//         print('Image URL: ${result['Main Image Source']}');
//         print('-----------');

//         setState(() {
//           _title = result['Product Title'];
//           _price = result['Price'].toString();
//           _imgUrl = result['Main Image Source'];
//         });

//         scrapView_Model!.getNeimanPriceData(
//           _price ?? "",
//           _imgUrl ?? "",
//           _title ?? "",
//         );

//         Navigator.pop(context);
//         _showFullScreenBottomSheet(context, h, w);
//         setState(() {
//           controller1.text =
//               scrapView_Model!.title != null ? scrapView_Model!.title! : "";
//           controller2.text = scrapView_Model!.price ?? "";

//           print("..value${controller1.text}...${controller2.text}");
//         });
//       } else {
//         Navigator.pop(context);
//         _showToast("${response.statusCode}");
//         print('API request failed with status code: ${response.statusCode}');
//       }
//       // Navigator.pop(context);
//       // _showToast('An error occurred. Please try again later.');
//     }
//   }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  bool loader = false;


  bool _canGoBack = false;
  bool _canGoForward = false;

  void _updateNavigationState() {
    print("call");
    if (_webViewController != null) {
      _webViewController!.canGoBack().then((value) {
        setState(() {
          _canGoBack = value;
        });
      });

      _webViewController!.canGoForward().then((value) {
        setState(() {
          _canGoForward = value;
        });
      });
    }
    ;
  }

  void _handleNavigationBack() {
    if (_canGoBack) {
      _webViewController!.goBack();
    }
  }

  void _handleNavigationForward() {
    if (_canGoForward) {
      _webViewController!.goForward();
    }
  }

  @override
// void dispose() {
//   controller!.clearCache();
//   super.dispose();
//   print("this is disposse");
// }

  String currentUrl = "";
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;

    //     final double screenWidth = MediaQuery.of(context).size.width;
    // final double desiredWidth = screenWidth == 1080.0 && screenWidth == 2220.0 ? 240.0 : 260.0;
    final Size screenSize = MediaQuery.of(context).size;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double diagonalSize =
        sqrt(pow(screenWidth, 2) + pow(screenHeight, 2));
    final double desiredWidth = diagonalSize >= 5.0 ? 240.0 : 260.0;
    double desiredHeight =
        Platform.isIOS ? screenHeight * 0.70 : screenHeight * 0.70;

    double TextscreenWidth = MediaQuery.of(context).size.width;
    double textSize = screenWidth >= 280
        ? 31.0
        : 25.0; // Adjust the multiplier as per your requirements

    return Scaffold(
///USing for Scrapping

      // floatingActionButton: AnimatedOpacity(
      //   opacity:
      //       //      (domain == "www.nordstrom.com" ||
      //       //             domain == "nordstrom.com" ||
      //       //             domain == "zoechicco.com" ||
      //       //             domain == "www.neimanmarcus.com" ||
      //       //             domain == "neimanmarcus.com" ||
      //       //             domain == "www.amazon.com" ||
      //       //             domain == "amazon.com")
      //       //         ? (scrapView_Model!.imgUrl != null ||
      //       //                 scrapView_Model!.title != null ||
      //       //                 scrapView_Model!.imgUrl != null)
      //       //             ? 1.0
      //       //             : 0.0
      //       //         :
      //       1.0,
      //   duration: Duration(milliseconds: 500),
      //   child: FloatingActionButton(
      //     child: Image.asset(
      //       "assets/images/Add-white.png",
      //       height: 40,
      //       width: 40,
      //     ),
      //     onPressed: () async {
      //       print("i am on buttton");
      //       showLoader(context);

      //       setState(() {
      //         showMoreImg = false;
      //         var data = imgesUrrl.clear();
      //       });

      //       // if(loader==true){

      //       // }else{
      //       //   Navigator.pop(context);
      //       // }
      //       if (domain == "www.sephora.com" ||
      //               domain == "sephora.com" ||
      //               domain == "shop.lululemon.com" ||
      //               domain == "lululemon.com" ||
      //               domain == "www.catbirdnyc.com" ||
      //               domain == "catbirdnyc.com" ||
      //               domain == "www.freepeople.com" ||
      //               domain == "freepeople.com" ||
      //               domain == "lovevery.eu" ||
      //               domain == "lovevery.com" ||
      //               domain == "www.rei.com" ||
      //               domain == "rei.com" ||
      //               domain == "www.neimanmarcus.com" ||
      //               domain == "neimanmarcus.com" ||
      //               domain == "www.hannaandersson.com" ||
      //               domain == "hannaandersson.com" ||
      //               domain == "www.westelm.com" ||
      //               domain == "westelm.com" ||
      //               domain == "www.nordstrom.com" ||
      //               domain == "nordstrom.com" ||
      //               domain == "www.glassybaby.com" ||
      //               domain == "glassybaby.com" ||
      //               domain == "rhoback.com" ||
      //               domain == "www.volcom.com" ||
      //               domain == "volcom.com" ||
      //               domain == "vuoriclothing.com" ||
      //               domain == "zoechicco.com" ||
      //               // domain == "shop.bombas.com" ||
      //               // domain == "bombas.com" ||
      //               domain == "www.amazon.com" ||
      //               domain == "amazon.com" ||
      //               domain == "www.anthropologie.com" ||
      //               domain == "anthropologie.com" ||
      //               domain == "www.zara.com" ||
      //               domain == "zara.com"
      //           //  || domain == "www.target.com" || domain == "target.com"
      //           ) {
      //         imgesUrrl.clear();

      //         // setState(() {
      //         //   loader=false;
      //         // });

      //         print("click button$Url");
      //         if (domain == "www.anthropologie.com" ||
      //             domain == "anthropologie.com" ||
      //             domain == "www.nordstrom.com" ||
      //             domain == "nordstrom.com" ||
      //             domain == "www.zara.com" ||
      //             domain == "zara.com" ||
      //             domain == "shop.bombas.com" ||
      //             domain == "bombas.com") {
      //           _webViewController!.reload();
      //         }
      //         await scrapFunction(Url).then((value) {
      //           setState(() {
      //             controller1.text = scrapView_Model!.title != null
      //                 ? scrapView_Model!.title!
      //                 : "";
      //             controller2.text = scrapView_Model!.price ?? "";

      //             print("..value${controller1.text}...${controller2.text}");
      //           });
      //         });

      //         if (domain == "www.nordstrom.com") {
      //           Future.delayed(Duration(seconds: 26), () {
      //             Navigator.of(context).pop();
      //             _showFullScreenBottomSheet(
      //                 context, desiredHeight, desiredWidth);
      //             setState(() {
      //               controller1.text = scrapView_Model!.title != null
      //                   ? scrapView_Model!.title!
      //                   : "";
      //               controller2.text = scrapView_Model!.price ?? "";

      //               print("..value${controller1.text}...${controller2.text}");
      //             });
      //           });
      //         } else if (domain == "www.zara.com") {
      //           Future.delayed(Duration(seconds: 7), () {
      //             Navigator.of(context).pop();
      //             _showFullScreenBottomSheet(
      //                 context, desiredHeight, desiredWidth);
      //             setState(() {
      //               controller1.text = scrapView_Model!.title != null
      //                   ? scrapView_Model!.title!
      //                   : "";
      //               controller2.text = scrapView_Model!.price ?? "";

      //               print("..value${controller1.text}...${controller2.text}");
      //             });
      //           });
      //         } else if (domain == "www.amazon.com") {
      //           Future.delayed(Duration(seconds: 10), () {
      //             Navigator.of(context).pop();
      //             _showFullScreenBottomSheet(
      //                 context, desiredHeight, desiredWidth);
      //             setState(() {
      //               controller1.text = scrapView_Model!.title != null
      //                   ? scrapView_Model!.title!
      //                   : "";
      //               controller2.text = scrapView_Model!.price ?? "";

      //               print("..value${controller1.text}...${controller2.text}");
      //             });
      //           });
      //         } else if (domain == "www.zoechicco.com") {
      //           Future.delayed(Duration(seconds: 5), () {
      //             Navigator.of(context).pop();
      //             _showFullScreenBottomSheet(
      //                 context, desiredHeight, desiredWidth);
      //             setState(() {
      //               controller1.text = scrapView_Model!.title != null
      //                   ? scrapView_Model!.title!
      //                   : "";
      //               controller2.text = scrapView_Model!.price ?? "";

      //               print("..value${controller1.text}...${controller2.text}");
      //             });
      //           });
      //         } else if (domain == "www.neimanmarcus.com") {
      //           Future.delayed(Duration(seconds: 12), () {
      //             Navigator.of(context).pop();
      //             _showFullScreenBottomSheet(
      //                 context, desiredHeight, desiredWidth);
      //             setState(() {
      //               controller1.text = scrapView_Model!.title != null
      //                   ? scrapView_Model!.title!
      //                   : "";
      //               controller2.text = scrapView_Model!.price ?? "";

      //               print("..value${controller1.text}...${controller2.text}");
      //             });
      //           });
      //         } else if (domain == "www.anthropologie.com") {
      //           Future.delayed(Duration(seconds: 8), () {
      //             Navigator.of(context).pop();
      //             _showFullScreenBottomSheet(
      //                 context, desiredHeight, desiredWidth);
      //             setState(() {
      //               controller1.text = scrapView_Model!.title != null
      //                   ? scrapView_Model!.title!
      //                   : "";
      //               controller2.text = scrapView_Model!.price ?? "";

      //               print("..value${controller1.text}...${controller2.text}");
      //             });
      //           });
      //         } else {
      //           Future.delayed(Duration(seconds: 6), () {
      //             Navigator.of(context).pop();
      //             _showFullScreenBottomSheet(
      //                 context, desiredHeight, desiredWidth);
      //             setState(() {
      //               controller1.text = scrapView_Model!.title != null
      //                   ? scrapView_Model!.title!
      //                   : "";
      //               controller2.text = scrapView_Model!.price ?? "";

      //               print("..value${controller1.text}...${controller2.text}");
      //             });
      //           });
      //         }
      //       } else {
      //         // setState(() {
      //         //       loader=false;
      //         //     });
      //         // Navigator.of(context).pop();
      //         fetchResponse(Url, desiredHeight, desiredWidth);
      //       }
      //       setState(() {
      //         check = false;
      //       });
      //     },
      //   ),
      // ),
     
      appBar: AppBar(
        centerTitle: true,
        // toolbarHeight: removeHeaderFooter == false ? 80.0 : 40,
        title: Text("Web Scrapping"),
        elevation: 1.0,
        foregroundColor: Colors.white,

        // Text(
        //   "$Url",
        //   style: TextStyle(fontSize: 10),
        // ),13
      //   leadingWidth: 25,
      //   leading: IconButton(
      //     icon: SvgPicture.asset(
      //       "assets/images/LeftArrow_white.svg",
      //     ),
      //     onPressed: () {
      //       print("asas");
      //       authProvider!.homeScreen();
      //     },
      //   ),
      //   actions: [
      //     GestureDetector(
      //       onTap: () {
      //         setState(() {
      //           dropdown = !dropdown;
      //         });
      //       },
      //       child: Padding(
      //         padding: const EdgeInsets.fromLTRB(0, 12, 3, 12),
      //         child: CircleAvatar(
      //           // radius: 10,
      //           backgroundColor: Colors.black,

      //           backgroundImage: NetworkImage(
      //             authProvider!.avatar.toString(),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              removeHeaderFooter == false
                  ? SizedBox(
                      height: 1,
                      // width: 230,s
                      child: Divider(
                        color: Colors.white,
                        // height: 10,
                      ))
                  : Container(
                      height: 0,
                      color: Colors.black,
                    ),
              Container(
                // height: 00,
                width: MediaQuery.sizeOf(context).width,
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 6),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _handleNavigationBack();
                                },
                                child: Icon(
                                  CupertinoIcons.arrow_left,
                                  color:
                                      _canGoBack ? Colors.white : Colors.grey,
                                  size: 25,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  _handleNavigationForward();
                                },
                                child: Icon(CupertinoIcons.arrow_right,
                                    color: _canGoForward
                                        ? Colors.white
                                        : Colors.grey,
                                    // Color.fromARGB(202, 255, 255, 255),
                                    size: 25),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 40,
                          width: MediaQuery.sizeOf(context).width / 1.3,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                          ),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    isFocused = true;
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    child: TextField(
                                      focusNode: _focusNode,
                                      // textAlign: TextAlign.center,
                                      cursorColor: Colors.white,
                                      controller: controller6,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontFamily: "Assistant",
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.only(bottom: 10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    // authProvider!
                                    //     .StoreUrlScreen(controller6.text);

                                    // Url = authProvider!.URL.toString();
                                    print("Updated URL: $Url");
                                    removeHeaderFooter = false;
                                    isFocused = false;
                                    FocusScope.of(context).unfocus();
                                  });

                                  Uri uri = Uri.parse(Url!);
                                  setState(() {
                                    domain = uri.host;
                                  });
                                  if (_webViewController != null) {
                                    _webViewController!.reload();
                                    await _webViewController!.loadUrl(
                                        urlRequest:
                                            URLRequest(url: Uri.parse(Url)));
                                  }
                                },
                                child: Padding(
                                    padding: const EdgeInsets.only(right: 3),
                                    child: !isFocused
                                        ? Icon(
                                            CupertinoIcons.arrow_clockwise,
                                            color: Colors.white,
                                            size: 23,
                                          )
                                        : Icon(
                                            CupertinoIcons.search,
                                            color: Colors.white,
                                            size: 23,
                                          )),
                              ),
                              // You can add more widgets here if needed.
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Container(
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: Uri.parse(Url)),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        cacheEnabled: false,
                        useOnDownloadStart: true,
                        javaScriptEnabled: true,
                      ),
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                      _webViewController!.addJavaScriptHandler(
                          handlerName: 'handlerFoo',
                          callback: (args) {
                            // return data to JavaScript side!
                            return {'bar': 'bar_value', 'baz': 'baz_value'};
                          });

                      _webViewController!.addJavaScriptHandler(
                          handlerName: 'handlerFooWithArgs',
                          callback: (args) {
                            print(args);
                            // it will print: [1, true, [bar, 5], {foo: baz}, {bar: bar_value, baz: baz_value}]
                          });
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      final url = navigationAction.request.url.toString();
                      setState(() {
                        Url = url;
                        print("jalkhsalhsa$Url");
                      });
                      return NavigationActionPolicy
                          .ALLOW; // Allow the webview to load the URL
                    },
                    onLoadStart: (controller, url) {
                      controller.getUrl().then((currentUrl) {
                        setState(() {
                          // _canGoBack =
                          //     false; // Disable the back button when a nsew page starts loading
                          // _canGoForword=true;
                          Url = currentUrl.toString();

                      //     if (domain == "www.sephora.com" ||
                      //         domain == "sephora.com" ||
                      //         domain == "shop.lululemon.com" ||
                      //         domain == "lululemon.com" ||
                      //         domain == "www.catbirdnyc.com" ||
                      //         domain == "catbirdnyc.com" ||
                      //         domain == "www.freepeople.com" ||
                      //         domain == "freepeople.com" ||
                      //         domain == "lovevery.eu" ||
                      //         domain == "lovevery.com" ||
                      //         domain == "www.rei.com" ||
                      //         domain == "rei.com" ||
                      //         domain == "www.neimanmarcus.com" ||
                      //         domain == "neimanmarcus.com" ||
                      //         domain == "www.hannaandersson.com" ||
                      //         domain == "hannaandersson.com" ||
                      //         domain == "www.westelm.com" ||
                      //         domain == "westelm.com" ||
                      //         domain == "www.nordstrom.com" ||
                      //         domain == "nordstrom.com" ||
                      //         domain == "www.glassybaby.com" ||
                      //         domain == "glassybaby.com" ||
                      //         domain == "rhoback.com" ||
                      //         domain == "www.volcom.com" ||
                      //         domain == "volcom.com" ||
                      //         domain == "vuoriclothing.com" ||
                      //         domain == "zoechicco.com" ||
                      //         domain == "shop.bombas.com" ||
                      //         domain == "bombas.com" ||
                      //         domain == "www.amazon.com" ||
                      //         domain == "amazon.com" ||
                      //         domain == "www.anthropologie.com" ||
                      //         domain == "anthropologie.com" ||
                      //         domain == "www.zara.com" ||
                      //         domain == "zara.com") {
                      //       setState(() {
                      //         Url = url.toString();
                      //         //  Uri uri = Uri.parse(Url!);
                      //         //  domain = uri.host;
                      //       });
                      //     } else {
                      //       setState(() {
                      //         Url = url.toString();
                      //         Uri uri = Uri.parse(Url!);
                      //         domain = uri.host;
                      //       });
                      //     }
                        });
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      // _webViewController!.canGoBack().then((value) {
                      //   setState(() {
                      //     _canGoForword =
                      //         value; // Enable the back button if the WebView can go back
                      //   });
                      // });
                      _updateNavigationState();

                      controller.getUrl().then((currentUrl) {
                        setState(() {
                          Url = currentUrl.toString();
                          controller6.text = Url;
                          print("this is Url $Url");
                        });
                      });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      print(consoleMessage);
                      // it will print: {message: {"bar":"bar_value","baz":"baz_value"}, messageLevel: 1}
                    },
                    onLoadStop: (controller, url) async {
                      print("event call");
                      pageContent = await controller.evaluateJavascript(
                          source: 'document.documentElement.outerHTML');
                      print(
                          "this is length of dome ${pageContent.toString().length}");

                      _updateNavigationState();

                      print("this is value URL ...${value}......$domain");
                      // _webViewController!.canGoForward().then((value) {
                      //   setState(() {
                      //     _canGoForword =
                      //         value; // Enable the back button if the WebView can go back
                      //   });
                      // });

                      // print(Url.length);

                      if (domain == "www.nordstrom.com" ||
                          domain == "nordstrom.com") {
                        final title =
                            await _webViewController!.evaluateJavascript(
                          source:
                              'document.querySelector("h1.dls-t8nrr7")?.innerText ?? "Title not found"',
                        );
                        final imageSrc = await _webViewController!
                            .evaluateJavascript(source: """
                                  var elements = document.getElementsByClassName('td7Hr');
                                  var imgElement = null;
      
                                  for (var i = 0; i < elements.length; i++) {
                                    var imgElements = elements[i].getElementsByClassName('LUNts');
                                    if (imgElements.length > 0) {
                                      imgElement = imgElements[0];
                                      break;
                                    }
                                  }
      
                                  var imgSrc = '';
                                  if (imgElement) {
                                    imgSrc = imgElement.getAttribute('src');
                                  }
      
                                  imgSrc;
                                """);

                        final price =
                            await _webViewController!.evaluateJavascript(
                          source: r'''
                                    (function() {
                                      var priceElement = document.querySelector('span.qHz0a.EhCiu.dls-1n7v84y');
                                      if (priceElement) {
                                        return priceElement.innerText;
                                      } else {
                                        return 'Price not found';
                                      }
                                    })();
                                  ''',
                        );
                        print('Title: $title');

                        print('Price: $price');

                        print('Image URL: $imageSrc');

                        // if (title != " Title not found" ||
                        //     price != "Price not found") {
                        //   // scrapView_Model!.getDataFromShowNordstrom(
                        //       Url, title ?? "", price, imageSrc);
                        // } else {
                        //   // print("open one product")
                        //   //   Fluttertoast.showToast(
                        //   //       msg: "Open Specific Product and Reload the page",
                        //   //       toastLength: Toast.LENGTH_SHORT,
                        //   //       gravity: ToastGravity.CENTER,
                        //   //       timeInSecForIosWeb: 1,
                        //   //       textColor: Colors.white,
                        //   //       fontSize: 16.0);
                        // }
                        // print('Price: $price');
                      } else if (domain == "www.carawayhome.com" ||
                          domain == "carawayhome.com") {
                        final title =
                            await _webViewController!.evaluateJavascript(
                          source:
                              'document.querySelector("h1.dls-t8nrr7")?.innerText ?? "Title not found"',
                        );
                        final imageSrc = await _webViewController!
                            .evaluateJavascript(source: '''
                                (function() {
                                  var imgSrc = document.querySelector('figure.iiz img.iiz__img').src;
                                  return imgSrc;
                                })();
                              ''');

                        final price = await _webViewController!
                            .evaluateJavascript(source: '''
                            // Fetch the price using javascriptEvaluate
                            var priceElement = document.querySelector('.css-1djw6ek');
                            var price = priceElement ? priceElement.textContent.trim() : null;
                            price;
                          ''');

                        var titles = await _webViewController
                            ?.evaluateJavascript(source: """
                                  var element = document.querySelector('.css-hpnsbd');
                                  if (element) {
                                    element.innerText;
                                  } else {
                                    null;
                                  }
                                """);

                        final script = '''
                        (function() {
                          var img = document.querySelector('figure.iiz img.iiz__img');
                          console.log(img); // Log the image element to the console
                          if (img && img.src) {
                            return img.src;
                          } else {
                            return null;s
                          }
                        })();
                      ''';
                        var imageSrcs = await _webViewController!
                            .evaluateJavascript(source: script);

                        print(imageSrcs);
                        print('Title: $titles');

                        print('Price: $price');

                        print('Image URL: $imageSrc');

                        // if (titles != null || titles != "") {
                        //   scrapView_Model!.getCokeWayPriceData(
                        //       price ?? "", imageSrc ?? "NODATA", titles);
                        // } else {
                        //   // print("open one product")
                        //   // Fluttertoast.showToast(
                        //   //     msg: "Open Specific Product and Reload the page",
                        //   //     toastLength: Toast.LENGTH_SHORT,
                        //   //     gravity: ToastGravity.CENTER,
                        //   //     timeInSecForIosWeb: 1,
                        //   //     textColor: Colors.white,
                        //   //     fontSize: 16.0);
                        // }
                        // print('Price: $price');
                      } else if (domain == "www.volcom.com" ||
                          domain == "volcom.com") {
                        var volComPrice;
                        final title = await _webViewController!
                            .evaluateJavascript(source: """
                                  (function() {
                                    var element = .querySelector('.product-detail-info__header-name');
                                    return element.text();
                                  })();
                                """);
                        final imageSrc = await _webViewController!
                            .evaluateJavascript(source: '''
                          document.addEventListener('DOMContentLoaded', function() {
                            var elements = document.getElementsByClassName('AspectRatio');
                            var imgElement = null;
      
                            for (var i = 0; i < elements.length; i++) {
                              var container = elements[i].querySelector('.Image--lazyLoaded');
                              if (container) {
                                imgElement = container;
                                break;
                              }
                            }
      
                            var imgSrc = '';
                            if (imgElement) {
                              imgSrc = imgElement.getAttribute('src');
                            }
      
                            console.log(imgSrc);
      
                            // You can also pass the imgSrc variable to Flutter using
                            // a JavaScript bridge method or by updating the UI directly.
                            // For example:
                            // window.flutter_inappwebview.callHandler('getImageSrc', imgSrc);
                          });
                        ''');

                        final price = await _webViewController!
                            .evaluateJavascript(source: '''
                        // JavaScript code to fetch the price
                        // Replace this code with the actual code to fetch the price from the webpage
                        var priceElement = document.querySelector('.ProductHeading__compare-at > span');
                        var price = priceElement?.textContent?.trim();
                        price;
                      ''').then((result) {
                          // The 'result' variable will contain the fetched price
                          print('Price: ${result}');

                          setState(() {
                            volComPrice = result;
                          });
                        });
                        print('Title: $title');

                        print('Price: $price');

                        print('Image URL: $imageSrc');

                        // if (volComPrice != null) {
                        //   scrapView_Model!.getVolcomPriceData(volComPrice);
                        // } else {
                        //   // print("open one product")
                        //   // Fluttertoast.showToast(
                        //   //     msg: "Open Specific Product and Reload the page",
                        //   //     toastLength: Toast.LENGTH_SHORT,
                        //   //     gravity: ToastGravity.CENTER,
                        //   //     timeInSecForIosWeb: 1,
                        //   //     textColor: Colors.white,
                        //   //     fontSize: 16.0);
                        // }
                        // print('Price: $price');
                      } else if (domain == "www.anthropologie.com" ||
                          domain == "anthropologie.com") {
                        String? productTitle;
                        String? productPrice;

                        var title = await _webViewController!
                            .evaluateJavascript(source: '''
                        // JavaScript code to extract the text content of the <h1> element
                        var element = document.getElementsByClassName('c-pwa-product-meta-heading')[0];
                        var textContent = element ? element.textContent.trim() : '';
                        textContent;
                      ''').then((result) {
                          // The 'result' variable will contain the extracted text content
                          print('Product name: $result');

                          setState(() {
                            productTitle = result;
                          });
                        });

                        final script = '''
                                  // Find all script tags with type="application/ld+json"
                                  var scriptTags = document.querySelectorAll('script[type="application/ld+json"]');
                                  var firstImageUrl = null;
      
                                  // Iterate over the script tags
                                  scriptTags.forEach(function(scriptTag) {
                                    var jsonData = JSON.parse(scriptTag.innerHTML);
      
                                    // Check if the JSON data contains an "image" property
                                    if (jsonData.hasOwnProperty('image')) {
                                      var jsonDataImages = Array.isArray(jsonData.image) ? jsonData.image : [jsonData.image];
                                      if (jsonDataImages.length > 0 && !firstImageUrl) {
                                        firstImageUrl = jsonDataImages[0];
                                      }
                                    }
                                  });
      
                                  firstImageUrl;
                                ''';

                        // Evaluate the script to get the first image URL
                        final firstImageUrl = await _webViewController!
                            .evaluateJavascript(source: script);

                        if (firstImageUrl != null && firstImageUrl.isNotEmpty) {
                          print(firstImageUrl);
                          // Handle the first image URL
                        }

                        var price = await _webViewController!
                            .evaluateJavascript(source: '''
                        // JavaScript code to fetch the price
                        var priceElement = document.querySelector('.c-pwa-product-price__current.s-pwa-product-price__current');
                        var price = priceElement ? priceElement.textContent.trim() : '';
                        price;
                      ''').then((result) {
                          // The 'result' variable will contain the fetched price
                          print('Price: $result');

                          setState(() {
                            productPrice = result;
                          });
                        });

                        print('Title: $title');

                        print('Price: $price');

                        print('Image URL: $firstImageUrl');

                        // if (firstImageUrl != null && productTitle != null) {
                        //   scrapView_Model!.getAnthropogiePriceData(
                        //       productPrice!, productTitle!, firstImageUrl);
                        // } else {
                        //   // print("open one product")
                        //   // Fluttertoast.showToast(
                        //   //     msg: "Open Specific Product and Reload the page",
                        //   //     toastLength: Toast.LENGTH_SHORT,
                        //   //     gravity: ToastGravity.CENTER,
                        //   //     timeInSecForIosWeb: 1,
                        //   //     textColor: Colors.white,
                        //   //     fontSize: 16.0);
                        // }
                        // print('Price: $price');
                      } else if (domain == "www.westelm.com" ||
                          domain == "westelm.com") {
                        // String? productTitle;
                        String? productPrice;

                        final script = '''
                        var productPriceElement = document.querySelector('li[data-test-id="product-pricing-list-sale-range"] span[data-test-id="product-pricing-list-sale-range-amount"]');
                        var productPrice = productPriceElement ? productPriceElement.innerText : null;
                        productPrice;
                      ''';

                        final price = await _webViewController!
                            .evaluateJavascript(source: script);

                        if (price != null && price.isNotEmpty) {
                          // print(productPrice);
                          // Handle the product price
                        }

                        print('Title: $title');

                        print('Price: $price');
                        setState(() {
                          productPrice = price;
                        });

                        // if (productPrice != null) {
                        //   scrapView_Model!.getWestElmPriceData(productPrice!);
                        // } else {
                        //   // print("open one product")
                        //   // Fluttertoast.showToast(
                        //   //     msg: "Open Specific Product and Reload the page",
                        //   //     toastLength: Toast.LENGTH_SHORT,
                        //   //     gravity: ToastGravity.CENTER,
                        //   //     timeInSecForIosWeb: 1,
                        //   //     textColor: Colors.white,
                        //   //     fontSize: 16.0);
                        // }
                        // print('Price: $price');
                      } else if (domain == "www.cb2.com" ||
                          domain == "cb2.com") {
                        // String? productTitle;
                        String? productPrice;
                        final script = """
                              var headerContainer = document.querySelector('.header-container');
                              var titleElement = headerContainer.querySelector('.product-name');
                              var priceElement = headerContainer.querySelector('.salePrice');
                              var title = titleElement.innerText;
                              var price = priceElement.innerText;
                              JSON.stringify({ title: title, price: price });
                            """;

                        final result = await _webViewController!
                            .evaluateJavascript(source: script);

                        if (result != null) {
                          final data = json.decode(result);
                          setState(() {
                            title = data['title'];
                            productPrice = data['price'];
                          });
                        }

                        final results = await _webViewController
                            ?.evaluateJavascript(source: '''
                        // Get the showcase item element by class
                        const showcaseElement = document.querySelector('.showcase-item');
      
                        // Get the img element within the showcase item
                        const imgElement = showcaseElement.querySelector('img[data-testid="image"]');
      
                        // Get the src attribute value of the img element
                        const imgSrc = imgElement ? imgElement.getAttribute('src') : null;
      
                        // Return the img src
                        imgSrc;
                      ''').then((result) {
                          // Handle the result here
                          print('Image src: $result');
                          setState(() {
                            imageurls = result;
                          });
                        });
                        // if (price != null && price.isNotEmpty) {
                        //   // print(productPrice);
                        //   // Handle the product price
                        // }

                        print('Title: $title');

                        print('Price: $productPrice');
                        // setState(() {
                        //   productPrice = price;
                        // });

                        // if (productPrice != null) {
                        //   scrapView_Model!.getAnthropogiePriceData(
                        //       productPrice!, title!, imageurls);
                        // } else {
                        //   // print("open one product")
                        //   // Fluttertoast.showToast(
                        //   //     msg: "Open Specific Product and Reload the page",
                        //   //     toastLength: Toast.LENGTH_SHORT,
                        //   //     gravity: ToastGravity.CENTER,
                        //   //     timeInSecForIosWeb: 1,
                        //   //     textColor: Colors.white,
                        //   //     fontSize: 16.0);
                        // }
                        // print('Price: $price');
                      } else if (domain == "zoechicco.com") {
                        // String? productTitle;
                        String? productPrice;
                        final jsCode = '''
                              const img = document.querySelector('.Image--fadeIn.lazyautosizes.Image--lazyLoaded');
                              const attributes = img.attributes;
                              const imageData = {};
                              for (const attr of attributes) {
                                imageData[attr.name] = attr.value;
                              }
                              JSON.stringify(imageData);
                            ''';

                        // Evaluate the JavaScript code and get the result
                        final result = await _webViewController!
                            .evaluateJavascript(source: jsCode);

                        print(result);

                        // if (price != null && price.isNotEmpty) {
                        //   // print(productPrice);
                        //   // Handle the product price
                        // }
                        Map<String, String>? imageData;
                        // print('Title: $title');
                        setState(() {
                          imageData = Map<String, String>.from(
                              jsonDecode(result.toString()));
                        });
                        //
                        print('imgSrc: ${imageData!["data-srcset"]}');
                        var imgUrl = imageData!["data-srcset"];
                        var splitData = imgUrl!.split(" 200w").first;
                        print(splitData);
                        // setState(() {
                        //   productPrice = price;
                        // });

                        // if (splitData != null) {
                        //   scrapView_Model!.getZoeChiccoImgeData(splitData);
                        // } else {
                        //   // print("open one product")
                        //   // Fluttertoast.showToast(
                        //   //     msg: "Open Specific Product and Reload the page",
                        //   //     toastLength: Toast.LENGTH_SHORT,
                        //   //     gravity: ToastGravity.CENTER,
                        //   //     timeInSecForIosWeb: 1,
                        //   //     textColor: Colors.white,
                        //   //     fontSize: 16.0);
                        // }
                        // // print('Price: $price');
                      } else if (domain == "shop.bombas.com" ||
                          domain == "bombas.com") {
                        // String? productTitle;
                        final imageSources = await _webViewController!
                            .evaluateJavascript(source: '''
                                  var div = document.querySelector('.ResponsiveImagestyled__Container-sc-a1bkhb-2.jobune.ProductImagestyled__Image-sc-12vnu5j-1.cgIhoP');
                                  var images = div.querySelectorAll('img');
                                  var sources = [];
                                  for (var i = 0; i < images.length; i++) {
                                    sources.push(images[i].src);
                                  }
                                  sources;
                                ''');

                        // Handle the fetched image sources
                        print(
                            'Image sources within the specified div: $imageSources');

                        // if (price != null && price.isNotEmpty) {
                        //   // print(productPrice);
                        //   // Handle the product price
                        // }

                        //

                        // setState(() {
                        //   productPrice = price;
                        // });

                        if (imageurls != null) {
                          // scrapView_Model!.getZoeChiccoImgeData();
                        } else {
                          // print("open one product")
                          // Fluttertoast.showToast(
                          //     msg: "Open Specific Product and Reload the page",
                          //     toastLength: Toast.LENGTH_LONG,
                          //     gravity: ToastGravity.CENTER,
                          //     timeInSecForIosWeb: 1,
                          //     textColor: Colors.white,
                          //     fontSize: 16.0);
                        }
                        // print('Price: $price');
                      } else if (domain == "www.neimanmarcus.com" ||
                          domain == "neimanmarcus.com") {
                        String? productImage;
                        String? productPrice;

                        var productPrices = await _webViewController
                            ?.evaluateJavascript(source: """
                                    var priceElement = document.querySelector('.Pricingstyles__RetailPrice-eZcFGu.eQRTWG');
                                    priceElement.innerText.trim();
                                  """);
                        var productImgUrl = await _webViewController
                            ?.evaluateJavascript(source: """
                                    var imgElement = document.querySelector('.swiper-zoom-container img');
                                    imgElement.getAttribute('src');
                                  """);

                        var title = await _webViewController
                            ?.evaluateJavascript(source: """
                                    var titleElement = document.querySelector('[data-test="pdp-title"]');
                                    titleElement.innerText.trim();
                                  """);

                        print(
                            "product price $productPrices.........$productImgUrl..............$title");

                        // if (productPrices != null || productImgUrl != null) {
                        //   print("i am hereee");
                        //   scrapView_Model!.getNeimanPriceData(
                        //       productPrices!, productImgUrl!, title);
                        // } else {
                        //   // print("open one product")
                        //   // Fluttertoast.showToast(
                        //   //     msg: "Open Specific Product and Reload the page",
                        //   //     toastLength: Toast.LENGTH_SHORT,
                        //   //     gravity: ToastGravity.CENTER,
                        //   //     timeInSecForIosWeb: 1,
                        //   //     textColor: Colors.white,
                        //   //     fontSize: 16.0);
                        // }
                        // print('Price: $price')÷;
                      } else if (domain == "www.amazon.com" ||
                          domain == "amazon.com") {
                        String? productImage;
                        String? productPrice;
                        String? productTitle;

                        var price = await _webViewController!
                            .evaluateJavascript(source: """
                          var priceElement = document.querySelector('.a-offscreen');
                          var price = priceElement ? priceElement.textContent.trim() : null;
                          price;
                      """);

                        print("this is .....$price");

                        final jsCode = '''
                            const imgElement = document.querySelector('.a-declarative img');
                            imgElement.getAttribute('src');
                          ''';
                        final imge = await _webViewController!
                            .evaluateJavascript(source: jsCode);
                        setState(() {
                          print(imge);
                        });

                        var title =
                            await controller.evaluateJavascript(source: """
                            (function() {
                              var element = document.querySelector('title');
                              if (element) {
                                return element.innerText.trim();
                              } else {
                                return null;
                              }
                            })();
                            """);

                        print("this is title.....$title");

                        setState(() {
                          productTitle = title;
                          productPrice = price;
                          productImage = imge;
                        });
                        var splitData = productTitle!.split("Amazon.com:").last;
                        print(splitData);
                        var splitProductTitle = splitData
                            .split(": Clothing, Shoes & Jewelry")
                            .first;
                        print(splitProductTitle);

                        print(
                            "this is amazon data..$splitProductTitle.......$productPrice.....$productImage");

                        // if (productImage != null) {
                        //   print("i am hereee");
                        //   scrapView_Model!.getAnthropogiePriceData(
                        //       productPrice!, splitProductTitle!, productImage!);
                        // } else {
                        //   // print("open one product")
                        //   // Fluttertoast.showToast(
                        //   //     msg: "Open Specific Product and Reload the page",
                        //   //     toastLength: Toast.LENGTH_SHORT,
                        //   //     gravity: ToastGravity.CENTER,
                        //   //     timeInSecForIosWeb: 1,
                        //   //     textColor: Colors.white,
                        //   //     fontSize: 16.0);
                        // }
                        // print('Price: $price')÷;
                      } else if (domain == "www.zara.com" ||
                          domain == "zara.com") {
                        String? productImage;
                        String? productPrice;
                        String? productTitle;

                        final title = await _webViewController
                            ?.evaluateJavascript(source: '''
                                  function getTitle() {
                                    const titleElement = document.querySelector('title');
                                    return titleElement ? titleElement.innerText : null;
                                  }
                                  getTitle();
                                ''');
                        // Zint('Price: $price')÷;

                        print(title);

                        final priceResult = await _webViewController
                            ?.evaluateJavascript(source: '''
                                  function getPrice() {
                                    const priceElement = document.querySelector('.money-amount__main');
                                    return priceElement ? priceElement.innerText : null;
                                  }
                                  getPrice();
                                ''');

                        print(priceResult);

                        final imageUrlResult = await _webViewController
                            ?.evaluateJavascript(source: '''
                                  function getImageUrl() {
                                    const imageElement = document.querySelector('.media-image__image');
                                    return imageElement ? imageElement.getAttribute('src') : null;
                                  }
                                  getImageUrl();
                                ''');

                        print(imageUrlResult);

                        setState(() {
                          productTitle = title;
                          productPrice = priceResult;
                          productImage = imageUrlResult;
                        });
                        print(
                            "this is ZARA data $productTitle...$productPrice....$productImage");
                      //   if (productImage != null && Url.length > 61) {
                      //     print("i am hereee");
                      //     scrapView_Model!.getZaraPriceData(
                      //         Url, productPrice!, productTitle!, productImage!);
                      //   } else {
                      //     // print("open one product")
                      //     // Fluttertoast.showToast(
                      //     //     msg: "Open Specific Product and Reload the page",
                      //     //     toastLength: Toast.LENGTH_SHORT,
                      //     //     gravity: ToastGravity.CENTER,
                      //     //     timeInSecForIosWeb: 1,
                      //     //     textColor: Colors.white,
                      //     //     fontSize: 16.0);
                      //   }
                      } else {
                        print("i am on load page");
                      }
                    },
                    onLoadError: (controller, url, code, message) {
                      print("this is $controller....$code......$message");
                      // if(code== -1005){
                      //    Fluttertoast.showToast(
                      //         msg: "No internet",
                      //         toastLength: Toast.LENGTH_SHORT,
                      //         gravity: ToastGravity.CENTER,
                      //         timeInSecForIosWeb: 1,
                      //         textColor: Colors.white,
                      //         fontSize: 16.0);
                      // }
                    },
                  ),
                ),
              ),
            ],
          ),
      //     if (dropdown == true)
      //       Positioned(
      //         top: 0,
      //         right: 0,
      //         child: GestureDetector(
      //           onTap: () {
      //             setState(() {
      //               dropdown = false;
      //             });
      //             // Handle tap to close dropdown here
      //             // Set dropdown to false to close it
      //             // dropdown = false;
      //           },
      //           child: Container(
      //               height: MediaQuery.of(context)
      //                   .size
      //                   .height, // Match parent height
      //               width:
      //                   MediaQuery.of(context).size.width, // Match parent width
      //               color: Colors.black
      //                   .withOpacity(0.7), // Semi-transparent black color
      //               child: Container()),
      //         ),
      //       ),
      //     dropdown == true
      //         ? Positioned(
      //             top: 0, // Set the top position value as per your requirement
      //             right: 1,
      //             child: Padding(
      //               padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
      //               child: Container(
      //                 height: authProvider!.account.length == 1
      //                     ? 100
      //                     : authProvider!.account.length == 2
      //                         ? 147
      //                         : authProvider!.account.length == 3
      //                             ? 178
      //                             : authProvider!.account.length == 4
      //                                 ? 208
      //                                 : authProvider!.account.length == 5
      //                                     ? 239
      //                                     : 100,
      //                 width: authProvider!.account.length == 1
      //                     ? 165
      //                     : (maxUsernameLength * 8.0) + 70,
      //                 color: Colors.white,
      //                 child: Column(
      //                   children: [
      //                     SizedBox(
      //                       height: 10,
      //                     ),
      //                     authProvider!.account.length > 1
      //                         ? Expanded(
      //                             child: ListView.builder(
      //                                 physics: NeverScrollableScrollPhysics(),
      //                                 itemCount: authProvider!.account.length,
      //                                 itemBuilder: (context, index) {
      //                                   var email = authProvider!.account[index]
      //                                           ["email"]
      //                                       .toString();
      //                                   return Column(
      //                                     children: [
      //                                       // SizedBox(
      //                                       //   height: 5,
      //                                       // ),
      //                                       GestureDetector(
      //                                           onTap: () async {
      //                                             print("change");
      //                                             if (authProvider!
      //                                                     .account.length >
      //                                                 1) {
      //                                               // if (authProvider!
      //                                               //         .index !=
      //                                               //     index) {
      //                                               await authProvider!
      //                                                   .storeIndex(index);
      //                                               // authProvider!.switchAccount(email);
      //                                               Phoenix.rebirth(context);
      //                                             }
      //                                           },
      //                                           child: Row(
      //                                             children: [
      //                                               SizedBox(
      //                                                 width: 20,
      //                                               ),
      //                                               ClipOval(
      //                                                   child: Image.network(
      //                                                 authProvider!.account[
      //                                                         index]!["avatar"]
      //                                                     .toString(),
      //                                                 height: 17,
      //                                                 width: 17,
      //                                                 fit: BoxFit.cover,
      //                                               )),
      //                                               //                                       CircleAvatar(
      //                                               //    // radius: 10,
      //                                               //   //  backgroundImage: NetworkImage(authProvider!.account[index]!["avatar"].toString(),scale: 10),
      //                                               //  ),
      //                                               // SvgPicture.asset(
      //                                               //   "assets/images/User (2).svg",
      //                                               // ),
      //                                               SizedBox(
      //                                                 width: 7,
      //                                               ),
      //                                               Text(
      //                                                 "${authProvider!.account[index]["username"]}",
      //                                                 // "${authProvider!.account[index]["username"].length > 11 ? authProvider!.account[index]["username"].toString().substring(0, 11) + "..." : authProvider!.account[index]["username"].toString()}",
      //                                                 style: const TextStyle(
      //                                                   fontSize: 12,
      //                                                   height: 1.6,
      //                                                   letterSpacing: 1,
      //                                                   fontFamily:
      //                                                       "Assistant', sans-serif",
      //                                                   fontWeight:
      //                                                       FontWeight.w500,
      //                                                   color:
      //                                                       Color(0xff000000),
      //                                                 ),
      //                                               ),
      //                                             ],
      //                                           )),
      //                                       SizedBox(
      //                                         height: 5,
      //                                       )
      //                                     ],
      //                                   );
      //                                 }),
      //                           )
      //                         : Container(),
      //                     GestureDetector(
      //                       onTap: () {
      //                         authProvider!.onloginScreen();
      //                         print("object");
      //                       },
      //                       child: Row(
      //                         children: [
      //                           SizedBox(
      //                             width: 18,
      //                           ),
      //                           Image.asset(
      //                             "assets/images/Add.png",
      //                             height: 15,
      //                             width: 15,
      //                           ),
      //                           SizedBox(
      //                             width: 3,
      //                           ),
      //                           Text(
      //                             "Add Account",
      //                             style: const TextStyle(
      //                               fontSize: 12,
      //                               height: 1.6,
      //                               letterSpacing: 1,
      //                               fontFamily: "Assistant', sans-serif",
      //                               fontWeight: FontWeight.w500,
      //                               color: Color(0xff000000),
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                     SizedBox(
      //                       height: 5,
      //                     ),

      //                     GestureDetector(
      //                       onTap: () {
      //                         authProvider!.MenuScreen();
      //                         // try {
      //                         //   AppService.launchURLService(
      //                         //       "https://docs.google.com/presentation/d/1mNHBB8m4FQeDZqwWOxYHyfTGK8rFEdWBHyEqrJRho38/edit?hl=en&pli=1#slide=id.g2775d977276_0_47");
      //                         // } catch (e) {
      //                         //   ScaffoldMessenger.of(context).showSnackBar(
      //                         //     SnackBar(content: Text(e.toString())),
      //                         //   );
      //                         // }
      //                       },
      //                       child: Row(
      //                         children: [
      //                           Icon(
      //                             Icons.person_2_outlined,
      //                             color: Colors.white,
      //                           ),
      //                           Text(
      //                             "Help",
      //                             style: const TextStyle(
      //                               fontSize: 12,
      //                               height: 1.6,
      //                               letterSpacing: 1,
      //                               fontFamily: "Assistant', sans-serif",
      //                               fontWeight: FontWeight.w500,
      //                               color: Color(0xff000000),
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                     // SizedBox(height: 2,),

      //                     GestureDetector(
      //                       onTap: () {
      //                         authProvider!.logout();
      //                         print("logout");
      //                       },
      //                       child: Row(
      //                         children: [
      //                           Icon(
      //                             Icons.person_2_outlined,
      //                             color: Colors.white,
      //                           ),
      //                           Text(
      //                             "Log Out",
      //                             style: const TextStyle(
      //                               fontSize: 12,
      //                               height: 1.6,
      //                               letterSpacing: 1,
      //                               fontFamily: "Assistant', sans-serif",
      //                               fontWeight: FontWeight.w500,
      //                               color: Color(0xff000000),
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                     SizedBox(
      //                       height: 13,
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           )
      //         : Container(),
      //   ],
      // ),
      // bottomNavigationBar: BottomAppBar(
      //     height: removeHeaderFooter == false ? 40 : 3,
      //     color: removeHeaderFooter == false ? Colors.black : Colors.white,
      //     child: Row()),
     ]) );
  }


}
