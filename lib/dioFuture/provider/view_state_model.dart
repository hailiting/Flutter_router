import 'dart:io';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

import 'package:routerApp/dioFuture/config/net/api.dart';
import 'package:routerApp/generated/l10n.dart';

import './view_state.dart';
export './view_state.dart';

class ViewStateModel with ChangeNotifier {
  // 防止页面销毁后，异步任务才完成，导致报错
  bool _disposed = false;
  // 当前页面的状态，默认为busy，可在viewModel的构造方法中指定
  ViewState _viewState;
  ViewStateError _viewStateError;
  ViewStateError get viewStateError => _viewStateError;

  // 根据状态构建
  // 子类可以在构建函数指定需要的页面状态
  // FooModel():super(viewState:ViewState.busy);
  ViewStateModel({ViewState viewState})
      : _viewState = viewState ?? ViewState.idle {
    debugPrint("ViewStateModel---constructor ---> $runtimeType");
  }
  // ViewState
  ViewState get viewState => _viewState;
  set viewState(ViewState viewState) {
    _viewStateError = null;
    _viewState = viewState;
    notifyListeners();
  }

  /// 以下变量是为了代码书写方便，加入get方法，严格意义上讲，并不严谨
  bool get isBusy => viewState == ViewState.busy;
  bool get isIdle => viewState == ViewState.idle;
  bool get isEmpty => viewState == ViewState.empty;
  bool get isError => viewState == ViewState.error;

  void setIdle() {
    viewState = ViewState.idle;
  }

  void setBusy() {
    viewState = ViewState.busy;
  }

  void setEmpty() {
    viewState = ViewState.empty;
  }

  void setError(e, stackTrace, {String message}) {
    ViewStateErrorType errorType = ViewStateErrorType.defaultError;
    if (e is DioError) {}
    viewState = ViewState.error;
    _viewStateError = ViewStateError(
      errorType,
      message: message,
      errorMessage: e.toString(),
    );
    printErrorStack(e, stackTrace);
    onError(viewStateError);
  }

  void onError(ViewStateError viewStateError) {}
  // 显示错误信息
  showErrorMessage(context, {String message}) {
    if (viewStateError != null || message != null) {
      if (viewStateError.isNetworkTimeout) {
        message ??= S.of(context).viewStateMessageNetworkError;
      } else{
        message??=viewStateError.message;
      }
      Future.microtask((){
        showToast(message, context: context);
      });
    }
  }
  @override
  String toString() {
    return 'BaseModel{_viewState: $viewState, _viewStateError: $_viewStateError}';
  }
  @override
  void notifyListeners(){
    if(!_disposed){
      super.notifyListeners();
    }
  }
  @override
  void dispose(){
    _disposed=true;
    debugPrint('view_state_model dispose -->$runtimeType');
    super.dispose();
  }
}

/// [e]为错误类型 :可能为 Error , Exception ,String
/// [s]为堆栈信息
printErrorStack(e, s) {
  debugPrint('''
<-----↓↓↓↓↓↓↓↓↓↓-----error-----↓↓↓↓↓↓↓↓↓↓----->
$e
<-----↑↑↑↑↑↑↑↑↑↑-----error-----↑↑↑↑↑↑↑↑↑↑----->''');
  if (s != null) debugPrint('''
<-----↓↓↓↓↓↓↓↓↓↓-----trace-----↓↓↓↓↓↓↓↓↓↓----->
$s
<-----↑↑↑↑↑↑↑↑↑↑-----trace-----↑↑↑↑↑↑↑↑↑↑----->
    ''');
}
