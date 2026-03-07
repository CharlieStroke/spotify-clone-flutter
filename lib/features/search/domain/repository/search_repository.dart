import 'package:dartz/dartz.dart';

abstract class SearchRepository {
  Future<Either<String, Map<String, List<dynamic>>>> searchByQuery(String query);
}
