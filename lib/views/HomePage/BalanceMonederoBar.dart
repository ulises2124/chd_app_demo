import 'dart:async';
import 'package:chd_app_demo/services/BovedaService.dart';
import 'package:chd_app_demo/utils/DataUI.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:chd_app_demo/services/MonederoServices.dart';
import 'package:chd_app_demo/views/Monedero/MonederoPage.dart';


class BalanceMonederoBar extends StatefulWidget {
  BalanceMonederoBar({
    Key key,
  }) : super(key: key);
  @override
  _BalanceMonederoBarState createState() => _BalanceMonederoBarState();
}

class _BalanceMonederoBarState extends State<BalanceMonederoBar> {
  double saldo;
  String _monederoId;
  String _idWallet = "";
  bool _isLoggedIn = false;
  SharedPreferences prefs;

  final formatter = new NumberFormat("###,###,###,##0.00");

  @override
  void initState() {
    getMonedero();
    Timer.periodic(new Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          saldo = prefs.getDouble("saldoMonedero");
        });
      }
    });
    super.initState();
  }

  getMonedero() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _idWallet = prefs.getString('idWallet');
    });
    if (_idWallet != null) {
      getIdMonedero().then((x) {
        getSaldo();
      });
    } else {
      var token = await BovedaService.getWalletByEmail(prefs.getString('email'));
      if (token != null) {
        prefs.setString('idWallet', token);
        setState(() {
          _idWallet = token;
        });
        getIdMonedero().then((x) {
          getSaldo();
        });
      }
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState: saldo == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      sizeCurve: Curves.easeInOut,
      duration: const Duration(milliseconds: 280),
      firstChild: SizedBox(
        height: 1,
      ),
      secondChild: Container(
        height: 40,
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: () {
              Navigator.pushNamed(context, DataUI.monederoRoute);
              // Navigator.of(context).pushAndRemoveUntil(
              //   MaterialPageRoute(
              //     builder: (BuildContext context) => MasterPage(
              //       initialWidget: MenuItem(
              //         id: 'monedero',
              //         title: 'Monedero Mi Chedraui',
              //         screen: MonederoPage(),
              //         color: DataUI.chedrauiColor2,
              //         textColor: DataUI.primaryText,
              //       ),
              //     ),
              //   ),
              //   (Route<dynamic> route) => false,
              // );
            },
            dense: true,
            leading: Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/card.png'),
                  fit: BoxFit.fitWidth,
                ),
                // shape: BoxShape.circle,
              ),
            ),
            // leading: Icon(
            //   Icons.credit_card,
            //   color: DataUI.chedrauiBlueSoftColor,
            // ),
            title: Text(
              _monederoId != null ? '**** ' + _monederoId.substring(12, 16) : ' ',
              style: TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'Rubik'),
            ),
            trailing: Text(
              'Saldo: \$' + formatter.format(saldo ?? 0.0),
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.white, fontFamily: 'Rubik', fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////////////////////////////

  Future<void> getIdMonedero() async {
    if (_idWallet != null || _idWallet.length != 0) {
      var monedero = await MonederoServices.getIdMonedero(_idWallet);
      print(monedero);
      if (mounted) {
        setState(() {
          if (monedero != null && monedero.length > 0 && monedero[0] != null && monedero[0]["monedero"] != null) {
            _monederoId = monedero[0]["monedero"];
            prefs.setString('codCliente', _monederoId);
          }
        });
      }
    }
  }

  Future<void> getSaldo() async {
    /*
    var x = await MonederoServices.getSaldoMonedero(_monederoId);
    if (x != null && x["resultado"] != null && x["resultado"]["saldo"] != null) {
      if(mounted) {
        setState(() {
          saldo = double.parse(x["resultado"]["saldo"].toString());
        });
      }
      prefs.setDouble('saldoMonedero', saldo);
    }
    */
    try {
      var saldoResult = await MonederoServices.getSaldoMonederoRCS(_monederoId);
      if (saldoResult != null && saldoResult["CodigoRes"] == "200" && saldoResult["DatosRCS"] != null) {
        if (mounted) {
          setState(() {
            saldo = double.parse(saldoResult["DatosRCS"]["Monto"]);
            prefs.setDouble('saldoMonedero', saldo);
          });
        }
      } else {
        throw new Exception("Not a valid object");
      }
    } catch (e) {
      prefs.setDouble('saldoMonedero', null);
      setState(() {
        saldo = null;
      });
    }
  }
}
