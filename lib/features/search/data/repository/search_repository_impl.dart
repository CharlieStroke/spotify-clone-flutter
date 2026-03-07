import 'package:dartz/dartz.dart';
import '../sources/search_api_service.dart';
import '../../domain/repository/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchApiService _apiService;

  SearchRepositoryImpl(this._apiService);

  @override
  Future<Either<String, Map<String, List<dynamic>>>> searchByQuery(String query) async {
    try {
      final results = await _apiService.search(query);
      return Right(results);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
