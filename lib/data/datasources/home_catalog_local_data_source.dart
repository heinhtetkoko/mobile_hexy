import 'package:mobile_hexy/data/models/home_catalog.dart';

class HomeCatalogLocalDataSource {
  const HomeCatalogLocalDataSource();

  HomeCatalog getCatalog() => const HomeCatalog(
    banners: [
      HomeBanner(
        title: 'Back to School Sale',
        subtitle: 'Up to 50% OFF on notebooks, pens & more',
        imageAsset: 'assets/images/figma_home/hero.png',
      ),
      HomeBanner(
        title: 'Fresh Ideas for Every Desk',
        subtitle: 'Shop the newest stationery essentials',
        imageAsset: 'assets/images/figma_home/hero.png',
      ),
      HomeBanner(
        title: 'Create Your Best Work',
        subtitle: 'Quality supplies, delivered to you',
        imageAsset: 'assets/images/figma_home/hero.png',
      ),
    ],
    categories: [
      HomeCategory(
        name: 'Notebook',
        imageAsset: 'assets/images/figma_home/category_1.png',
      ),
      HomeCategory(
        name: 'Paper',
        imageAsset: 'assets/images/figma_home/category_2.png',
      ),
      HomeCategory(
        name: 'Pens',
        imageAsset: 'assets/images/figma_home/category_3.png',
      ),
      HomeCategory(
        name: 'Art Supplies',
        imageAsset: 'assets/images/figma_home/category_4.png',
      ),
      HomeCategory(
        name: 'Files',
        imageAsset: 'assets/images/figma_home/category_5.png',
      ),
      HomeCategory(
        name: 'School',
        imageAsset: 'assets/images/figma_home/category_6.png',
      ),
    ],
    brands: [
      HomeCategory(
        name: 'Deli',
        imageAsset: 'assets/images/figma_home/brand_1.png',
      ),
      HomeCategory(
        name: 'Canon',
        imageAsset: 'assets/images/figma_home/brand_3.png',
      ),
      HomeCategory(
        name: 'Epson',
        imageAsset: 'assets/images/figma_home/brand_4.png',
      ),
    ],
    bestSellers: [
      HomeProduct(
        name: 'Moleskine Notebook',
        price: '45,000 Ks',
        imageAsset: 'assets/images/figma_home/product_1.png',
        hot: true,
      ),
      HomeProduct(
        name: 'Staedtler Fineliner Set',
        price: '32,000 Ks',
        imageAsset: 'assets/images/figma_home/product_2.png',
        hot: true,
      ),
      HomeProduct(
        name: 'Canon Ink Cartridge',
        price: '28,500 Ks',
        imageAsset: 'assets/images/figma_home/product_3.png',
        hot: true,
      ),
    ],
    newArrivals: [
      HomeProduct(
        name: 'Wireless PIXMA',
        price: '186,900 Ks',
        imageAsset: 'assets/images/figma_home/category_4.png',
      ),
      HomeProduct(
        name: 'Special Edition Pen',
        price: '73,500 Ks',
        imageAsset: 'assets/images/figma_home/category_3.png',
      ),
      HomeProduct(
        name: 'Fineliners 20pk',
        price: '47,250 Ks',
        imageAsset: 'assets/images/figma_home/category_5.png',
      ),
    ],
  );
}
