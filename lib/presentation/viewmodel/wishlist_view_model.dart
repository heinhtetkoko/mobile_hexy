import 'package:get/get.dart';
import 'package:mobile_hexy/domain/entities/wishlist_item.dart';

class WishlistViewModel extends GetxController {
  final items = <WishlistItem>[
    const WishlistItem(
      id: 'pencil-set',
      name: 'Staedtler Noris Pencil Set 12pcs',
      price: 'Ks 4,500',
      imageAsset: 'assets/images/wishlist/pencil_set.png',
    ),
    const WishlistItem(
      id: 'composition-notebook',
      name: 'Mead Composition Notebook',
      price: 'Ks 2,800',
      imageAsset: 'assets/images/wishlist/composition_notebook.png',
    ),
    const WishlistItem(
      id: 'gel-pen',
      name: 'Pilot G2 Gel Pen Blue',
      price: 'Ks 1,200',
      imageAsset: 'assets/images/wishlist/gel_pen.png',
    ),
    const WishlistItem(
      id: 'magic-tape',
      name: 'Scotch Magic Tape 3-Pack',
      price: 'Ks 3,500',
      imageAsset: 'assets/images/wishlist/magic_tape.png',
    ),
    const WishlistItem(
      id: 'eraser-set',
      name: 'Faber-Castell Eraser Set',
      price: 'Ks 900',
      imageAsset: 'assets/images/wishlist/eraser_set.png',
    ),
    const WishlistItem(
      id: 'index-cards',
      name: 'Oxford Index Cards 100pk',
      price: 'Ks 1,800',
      imageAsset: 'assets/images/wishlist/index_cards.png',
    ),
  ].obs;

  void removeItem(WishlistItem item) =>
      items.removeWhere((wishlistItem) => wishlistItem.id == item.id);

  void addToCart(WishlistItem item) {
    Get.snackbar(
      'Added to cart',
      item.name,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
