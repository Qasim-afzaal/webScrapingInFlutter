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

class WebViewWebsite extends StatefulWidget {

  @override
  State<WebViewWebsite> createState() => _WebViewWebsiteState();
}

class _WebViewWebsiteState extends State<WebViewWebsite> {
  InAppWebViewController? _webViewController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  String Url = "";

  String imageurls = "";
  String? title;
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
   

    super.initState();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);

    showMoreImg = false;
 
    startTimer();

    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
    splitUrl();

    _updateNavigationState();
    adding = false;
  }

  @override
  void dispose() {
 
    _focusNode.dispose();
    controller6.dispose();
    _connectivitySubscription.cancel();

    super.dispose();
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.mobile) {
      _updateStatus('Mobile data');
      _hideNoInternetDialog(); 
    } else if (connectivityResult == ConnectivityResult.wifi) {
      _updateStatus('WiFi');
      _hideNoInternetDialog();
    } else {
      _updateStatus('No internet connection');
      Fluttertoast.showToast(
          msg: "No Internet Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
     
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

  String? value;
  String? domain;
  splitUrl() {
    Uri uri = Uri.parse(value!);
    setState(() {
      domain = uri.host;
    });

    print("this is value URL ...${value}......$domain");
  }

  bool fieldColor = false;

  bool _showFAB = false;
  void startTimer() {
    Timer(Duration(seconds: 3), () {
      setState(() {
        _showFAB = true;
      });
    });
  }
  bool check = false;
  showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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

  String? _title;
  String? _price;
  String? _imgUrl;
  String? _error;
  bool navigator = false;
  var chunks;
  String? pageContent;
  List imgesUrrl = [];

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

  String currentUrl = "";
  Widget build(BuildContext context) {
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
        : 25.0; 

    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        title: Text("Web Scrapping"),
        elevation: 1.0,
        foregroundColor: Colors.white,

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
                 
                          Url = currentUrl.toString();
                        });
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
               
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
                     
                    },
                    onLoadStop: (controller, url) async {
                      print("event call");
                      pageContent = await controller.evaluateJavascript(
                          source: 'document.documentElement.outerHTML');
                      print(
                          "this is length of dome ${pageContent.toString().length}");

                      _updateNavigationState();

                      print("this is value URL ...${value}......$domain");
              

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

                      } else if (domain == "www.westelm.com" ||
                          domain == "westelm.com") {
         
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
                     
                      } else {
                        print("i am on load page");
                      }
                    },
                    onLoadError: (controller, url, code, message) {
                      print("this is $controller....$code......$message");
                    
                    },
                  ),
                ),
              ),
            ],
          ),
      
     ]) );
  }


}
