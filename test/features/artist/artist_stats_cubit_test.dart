import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/features/artist/domain/entities/artist_stats_entity.dart';
import 'package:spotify_clone/features/artist/domain/usecases/get_artist_stats_usecase.dart';
import 'package:spotify_clone/features/artist/presentation/cubit/artist_stats_cubit.dart';

class MockGetArtistStatsUseCase extends Mock implements GetArtistStatsUseCase {}

final _fakeStats = ArtistStatsEntity(
  totalPlays: 1000000,
  totalSongs: 10,
  totalAlbums: 2,
  topSongs: [],
  playsByAlbum: [],
);

void main() {
  late MockGetArtistStatsUseCase mockUseCase;
  late ArtistStatsCubit cubit;

  setUp(() {
    mockUseCase = MockGetArtistStatsUseCase();
    cubit = ArtistStatsCubit(mockUseCase);
  });

  tearDown(() => cubit.close());

  test('initial state is ArtistStatsInitial', () {
    expect(cubit.state, isA<ArtistStatsInitial>());
  });

  blocTest<ArtistStatsCubit, ArtistStatsState>(
    'emits [Loading, Loaded] on success',
    build: () {
      when(() => mockUseCase.call()).thenAnswer((_) async => Right(_fakeStats));
      return cubit;
    },
    act: (c) => c.loadStats(),
    expect: () => [isA<ArtistStatsLoading>(), isA<ArtistStatsLoaded>()],
  );

  blocTest<ArtistStatsCubit, ArtistStatsState>(
    'emits [Loading, Error] on failure',
    build: () {
      when(() => mockUseCase.call()).thenAnswer((_) async => const Left('Network error'));
      return cubit;
    },
    act: (c) => c.loadStats(),
    expect: () => [isA<ArtistStatsLoading>(), isA<ArtistStatsError>()],
  );

  blocTest<ArtistStatsCubit, ArtistStatsState>(
    'does nothing if state is not Initial (guard)',
    build: () {
      when(() => mockUseCase.call()).thenAnswer((_) async => Right(_fakeStats));
      return ArtistStatsCubit(mockUseCase);
    },
    seed: () => ArtistStatsLoaded(_fakeStats),
    act: (c) => c.loadStats(),
    expect: () => <ArtistStatsState>[],
  );
}
