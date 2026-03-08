import 'package:dartz/dartz.dart';

abstract class LibraryRepository {
  Future<Either<String, Map<String, List<dynamic>>>> getUserLibrary();
}
