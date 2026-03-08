import 'package:dartz/dartz.dart';
import '../repository/library_repository.dart';

class GetLibraryUseCase {
  final LibraryRepository repository;

  GetLibraryUseCase(this.repository);

  Future<Either<String, Map<String, List<dynamic>>>> call() async {
    return repository.getUserLibrary();
  }
}
