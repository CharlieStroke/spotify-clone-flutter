import 'package:dartz/dartz.dart';
import '../repository/search_repository.dart';

class SearchUseCase {
  final SearchRepository repository;

  SearchUseCase(this.repository);

  Future<Either<String, Map<String, List<dynamic>>>> call(String query) async {
    return repository.searchByQuery(query);
  }
}
