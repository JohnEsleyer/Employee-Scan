import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';


class InternetProvider with ChangeNotifier {
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  void setIsConnected(bool val){
    _isConnected = val;
    notifyListeners();
  }

  InternetProvider(){
    checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none){
        _isConnected = false;
      } else{
        _isConnected = true;
      }
      notifyListeners();
    });
  }

  Future<void> checkConnectivity() async{
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none){
      _isConnected = false;
    }else{
      _isConnected = true;
    }
    notifyListeners();
  }
}