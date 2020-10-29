import 'package:chd_app_demo/redux/actions/SearchActions.dart';

bool isSearchingProductsReducer(bool isSearchingProducts, action) {
  if (action is IsSearchingProductsAction) {
    return action.isSearchingProducts;
  } else {
    return isSearchingProducts;
  }
}
