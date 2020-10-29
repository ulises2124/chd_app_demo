import 'package:chd_app_demo/redux/models/AppState.dart';
import 'package:chd_app_demo/utils/Connectivity.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/DeliveryMethod/SelectedLocation.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:redux/redux.dart';

class _ViewModel {
  final String connectivity;
  _ViewModel({
    @required this.connectivity,
  });
  static _ViewModel fromStore(Store<AppState> store) {
    return new _ViewModel(connectivity: store.state.connectivity);
  }
}

class WidgetContainer extends StatefulWidget {
  final Widget widget;
  WidgetContainer(
    this.widget, {
    Key key,
  }) : super(key: key);

  _WidgetContainerState createState() => _WidgetContainerState();
}

class _WidgetContainerState extends State<WidgetContainer> {
  String status;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) {
        status = store.state.connectivity;
      },
      onWillChange: (_viewModel) {
        setState(() {
          status = _viewModel.connectivity;
        });
      },
      converter: _ViewModel.fromStore,
      builder: (BuildContext context, _ViewModel vm) {
        return Scaffold(
          appBar: status != null && status != 'Conectado' &&  status == 'Sin conexión'
              ? PreferredSize(
                  child: GradientAppBar(
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    gradient: DataUI.appbarGradient,
                    titleSpacing: 0.0,
                    title: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 32,
                      color: Colors.white,
                      child: Center(
                          child: Text(
                        status,
                        style: TextStyle(
                          color: HexColor('#FD5339'),
                          fontSize: 14,
                          fontFamily: 'Archivo',
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ),
                  ),
                  preferredSize: Size.fromHeight(32),
                )
              : null,
          body: widget.widget,
        );
      },
    );
  }
}
