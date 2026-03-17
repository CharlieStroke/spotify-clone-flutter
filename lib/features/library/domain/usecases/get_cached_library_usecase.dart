import '../../domain/repository/library_repository.dart';

class GetCachedLibraryUseCase {
  final LibraryRepository repository;

  GetCachedLibraryUseCase(this.repository);

  Future<Map<String, List<dynamic>>> call() async {
    return repository.getCachedLibrary(); 
  }
}
