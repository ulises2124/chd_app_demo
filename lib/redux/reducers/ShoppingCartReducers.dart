import 'package:chd_app_demo/redux/actions/ShoppingCartsActions.dart';

int shoppingCartReducer(int shoppingCartQuantity, action) {
  if (action is SetShoppingItems) {
    return action.shoppingCartQuantity;
  } else {
    return shoppingCartQuantity;
  }
}