
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:lottie/lottie.dart';

class Alerts {
  static showMessage(String message, BuildContext context) {
    // print("item deleted!");
    showToast(
      message,
      context: context,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.center,
      animDuration: Duration(seconds: 1),
      duration: Duration(seconds: 2),
      curve: Curves.elasticOut,
    );
  }
  static showAlert(String message, BuildContext context) {
    // print("item deleted!");
    showToast(
      message,
      context: context,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.center,
      animDuration: Duration(seconds: 1),
      duration: Duration(seconds: 5),
      curve: Curves.elasticOut,
    );
  }

  static showAlertYesNo(
      {required String title,
      required VoidCallback onPressYes,
      required VoidCallback onPressNo,
      required BuildContext context}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon:
          SizedBox(
            height: 80,
            width: 80,
            child: Lottie.asset('assets/lottie/animation_delete.json',
              fit: BoxFit.contain,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          // judul
          title: Text(title,style: TextStyle(fontSize: 20),),
          actions: [
            // tombel yes
            SizedBox(width: 80,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(4))),
                  backgroundColor:
                  MaterialStateProperty.all(
                      Colors.red),),
                onPressed: onPressYes,
                child: Text('Yes',style: TextStyle(color: Colors.white)),
              ),
            ),
            //tombol no
            SizedBox(
              width: 80,
              child: TextButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(
                          color: Colors.black12,
                        ),
                      ),
                    )),
                onPressed: onPressNo,
                child: Text('No',style:
        TextStyle(color: Colors.black12)),
              ),
            ),


          ],
        );
      },
    );
  }
}
