import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/data/datasources/collections_remote_data_source.dart';
import 'package:mobile_hexy/data/models/product_collection.dart';
import 'package:mobile_hexy/data/models/product_list_request.dart';
import 'package:mobile_hexy/presentation/widgets/catalog_image.dart';
import 'package:mobile_hexy/presentation/widgets/clean_app_bar.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  late Future<List<ProductCollection>> _collections = _fetch();

  Future<List<ProductCollection>> _fetch() =>
      Get.find<CollectionsRemoteDataSource>().fetchCollections();

  Future<void> _refresh() async {
    final request = _fetch();
    setState(() => _collections = request);
    // FutureBuilder displays errors while RefreshIndicator finishes normally.
    try {
      await request;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CleanAppBar(title: 'Collections'),
    body: FutureBuilder<List<ProductCollection>>(
      future: _collections,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Could not load collections.'.tr),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: Text('Try again'.tr),
                ),
              ],
            ),
          );
        }
        final items = snapshot.data ?? const <ProductCollection>[];
        return RefreshIndicator(
          onRefresh: _refresh,
          child: items.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No collections found.'.tr,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _CollectionTile(collection: items[index]),
                ),
        );
      },
    ),
  );
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({required this.collection});

  final ProductCollection collection;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        key: Key('collection-${collection.id}'),
        onTap: () => Get.toNamed<void>(
          AppRoutes.productList,
          arguments: ProductListRequest.collection(
            id: collection.id,
            name: collection.name,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.square(
                  dimension: 80,
                  child: CatalogImage(url: collection.imageUrl),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (collection.subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        collection.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      '${collection.itemCount} ${collection.itemCount == 1 ? 'item' : 'items'}',
                      style: TextStyle(color: colors.primary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
