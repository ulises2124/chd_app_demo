import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:chd_app_demo/utils/HexValueConverter.dart';
import 'package:chd_app_demo/views/Pedidos/PedidosController.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class ChatPedido extends StatefulWidget {
  final String consignment;
  ChatPedido({Key key, this.consignment}) : super(key: key);

  _ChatPedidoState createState() => _ChatPedidoState();
}

class _ChatPedidoState extends State<ChatPedido> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: DataUI.backgroundColor,
      appBar: GradientAppBar(
        centerTitle: true,
        elevation: 0,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HexColor('#F56D00'),
            HexColor('#F56D00'),
            HexColor('#F78E00'),
          ],
        ),
        title: Text(
          'Chat',
          style: TextStyle(color: Colors.white, fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 19),
        ),
      ),
      body: PedidosController.chatWindow(widget.consignment, 0),
    );
  }
}
