class HomeBanner {
  const HomeBanner({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
}

class HomeCategory {
  const HomeCategory({required this.name, required this.imageAsset});

  final String name;
  final String imageAsset;
}

class HomeProduct {
  const HomeProduct({
    this.id = '',
    required this.name,
    required this.price,
    required this.imageAsset,
    this.imageUrl,
    this.hot = false,
  });

  final String id;
  final String name;
  final String price;
  final String imageAsset;
  final String? imageUrl;
  final bool hot;
}

class HomeCatalog {
  const HomeCatalog({
    required this.banners,
    required this.categories,
    required this.brands,
    required this.bestSellers,
    required this.newArrivals,
  });

  final List<HomeBanner> banners;
  final List<HomeCategory> categories;
  final List<HomeCategory> brands;
  final List<HomeProduct> bestSellers;
  final List<HomeProduct> newArrivals;
}
