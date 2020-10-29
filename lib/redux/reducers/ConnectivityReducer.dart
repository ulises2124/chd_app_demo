import 'package:chd_app_demo/redux/actions/ConnectivityActions.dart';

String connectivityReducer(String connectivity, action) {
  if (action is ConnectivityActions) {
    connectivity = action.connectivity;
    return connectivity;
  } else {
    return connectivity;
  }
}
