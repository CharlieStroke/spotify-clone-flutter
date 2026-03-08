import 'package:dartz/dartz.dart';
import '../sources/library_api_service.dart';
import '../../domain/repository/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryApiService _apiService;

  LibraryRepositoryImpl(this._apiService);

  @override
  Future<Either<String, Map<String, List<dynamic>>>> getUserLibrary() async {
    try {
      final results = await _apiService.getUserLibrary();
      return Right(results);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
