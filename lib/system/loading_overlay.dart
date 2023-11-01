import 'dart:async';

import 'package:flutter/material.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({Key? key, required this.child}) : super(key: key);

  final Widget child;

  static _LoadingOverlayState of(BuildContext context) {
    return context.findAncestorStateOfType<_LoadingOverlayState>()!;
  }

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  bool _isLoading = false;
  Timer? timer;

  void show() {
    setState(() {
      _isLoading = true;
    });
  }

  void hide() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> runLoader()async{
    show();
    timer = Timer(Duration(seconds: 2), () {
      hide();
    });
  }

  @override
  void initState() {
    runLoader();
    super.initState();
  }
  
  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isLoading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}