import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/features/home/data/repository/song_repository.dart';
import 'package:spotify_clone/features/home/domain/usecases/increment_play_count_usecase.dart';

class MockSongRepository extends Mock implements SongRepository {}

void main() {
  late MockSongRepository mockRepo;
  late IncrementPlayCountUseCase useCase;

  setUp(() {
    mockRepo = MockSongRepository();
    useCase = IncrementPlayCountUseCase(mockRepo);
  });

  test('delegates to repository', () async {
    when(() => mockRepo.incrementPlayCount(any())).thenAnswer((_) async {});
    await useCase.call('42');
    verify(() => mockRepo.incrementPlayCount('42')).called(1);
  });
}
