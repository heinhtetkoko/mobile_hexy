import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/data/datasources/home_products_remote_data_source.dart';
import '../../presentation/product_list_sort_filter_test.dart'
    show RecordingApi;

void main() {
  test(
    'recommended cards use backend ratings and default missing ratings to zero',
    () async {
      final api = RecordingApi();
      final pending = HomeProductsRemoteDataSource(
        api,
      ).fetch(path: ApiEndpoints.recommendedProducts, page: 1, limit: 5);
      final call = api.calls.single;
      call.completion.complete(
        Response(
          requestOptions: RequestOptions(path: call.path),
          data: {
            'success': true,
            'data': [
              {'id': 1, 'rating': 3.5},
              {'id': 2, 'rating': '4.2'},
              {'id': 3},
              {'id': 4, 'rating': 'NaN'},
              {'id': 5, 'rating': 8},
            ],
          },
        ),
      );
      expect((await pending).products.map((item) => item.rating), [
        3.5,
        4.2,
        0,
        0,
        5,
      ]);
    },
  );
}
