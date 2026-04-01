# Frontend Cleanup & Refactor — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Corregir bugs de UI, eliminar colores hardcodeados, unificar el estilo de loading, extraer código duplicado y desactivar botones sin implementar en toda la app Flutter.

**Architecture:** Cambios contenidos en `lib/`. No se toca el backend ni se añaden features. Cada tarea modifica archivos independientes y puede commitearse por separado. El orden importa para las tareas 1-4 (fundaciones) pero las demás son independientes entre sí.

**Tech Stack:** Flutter/Dart, BLoC/Cubit, just_audio, shimmer, image_picker

---

## Mapa de archivos

| Archivo | Acción |
|---|---|
| `lib/core/theme/app_colors.dart` | Modificar: agregar 2 constantes |
| `lib/core/widgets/shimmer_skeleton.dart` | Modificar: agregar `ProfileSkeleton` |
| `lib/core/utils/image_picker_helper.dart` | Crear: utilidad compartida para seleccionar imagen |
| `lib/core/extensions/extensions.dart` | Modificar: absorber `BuildContextExtension` de utils |
| `lib/core/utils/extensions.dart` | Eliminar |
| `lib/features/player/presentation/pages/player_screen.dart` | Modificar: fix artist name, colores, null onPressed |
| `lib/features/player/presentation/widgets/mini_player.dart` | Modificar: colores |
| `lib/features/playlist_detail/presentation/pages/playlist_detail_page.dart` | Modificar: ClipRRect, colores, null onPressed |
| `lib/features/library/presentation/pages/library_page.dart` | Modificar: fix botón vacío, colores |
| `lib/features/home/presentation/pages/home.dart` | Modificar: colores |
| `lib/features/profile/presentation/pages/profile_page.dart` | Modificar: ProfileSkeleton, image picker, colores |
| `lib/features/create/presentation/pages/create_page.dart` | Modificar: image picker, colores |
| `lib/features/search/presentation/pages/search_page.dart` | Modificar: extraer `_DiscoverGrid` |
| `lib/features/main_navigation/presentation/pages/main_page.dart` | Modificar: colores |
| `lib/features/library/presentation/widgets/add_to_playlist_sheet.dart` | Modificar: colores |
| `lib/features/profile/presentation/pages/edit_profile_page.dart` | Modificar: actualizar import de extensions |

---

## Task 1: Agregar constantes de color a AppColors

**Files:**
- Modify: `lib/core/theme/app_colors.dart`

- [ ] **Paso 1: Agregar las dos constantes nuevas**

Abrir `lib/core/theme/app_colors.dart`. El archivo completo debe quedar así:

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFBE4EF2);
  static const Color background = Color(0xFF121212);
  static const Color secondBackground = Color(0xFF1E1E1E);
  static const Color grey = Color(0xFFBEBEBE);
  static const Color textSecondary = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFCF6679);
  static const Color surface = Color(0xFF282828);
  static const Color coverPlaceholder = Color(0xFF6A2C50);
}
```

- [ ] **Paso 2: Verificar con analyze**

```bash
flutter analyze lib/core/theme/app_colors.dart
```
Esperado: sin errores ni warnings nuevos.

- [ ] **Paso 3: Commit**

```bash
git add lib/core/theme/app_colors.dart
git commit -m "style: add surface and coverPlaceholder constants to AppColors"
```

---

## Task 2: Consolidar archivos de extensions duplicados

**Files:**
- Modify: `lib/core/extensions/extensions.dart`
- Delete: `lib/core/utils/extensions.dart`
- Modify: `lib/features/profile/presentation/pages/edit_profile_page.dart` (solo el import)

**Contexto:** `lib/core/utils/extensions.dart` solo tiene `BuildContextExtension.showSnack` con color default `Colors.redAccent`. `lib/core/extensions/extensions.dart` ya tiene `ContextX.showSnack` con `Color?` nullable. Solo `edit_profile_page.dart` importa el de utils; login y register importan el de extensions. Al consolidar, `edit_profile_page.dart` pasará a usar el `showSnack` de `core/extensions` — las llamadas sin `color:` explícito pasarán de rojo a color de tema (púrpura), lo cual es aceptable.

- [ ] **Paso 1: Eliminar `lib/core/utils/extensions.dart`**

Borrar el archivo. En bash:
```bash
rm lib/core/utils/extensions.dart
```

- [ ] **Paso 2: Actualizar el import en `edit_profile_page.dart`**

En `lib/features/profile/presentation/pages/edit_profile_page.dart`, encontrar:
```dart
import '../../../../core/utils/extensions.dart';
```
Reemplazar por:
```dart
import '../../../../core/extensions/extensions.dart';
```

- [ ] **Paso 3: Verificar**

```bash
flutter analyze lib/features/profile/presentation/pages/edit_profile_page.dart
```
Esperado: sin errores.

- [ ] **Paso 4: Commit**

```bash
git add lib/core/utils/extensions.dart lib/features/profile/presentation/pages/edit_profile_page.dart
git commit -m "refactor: consolidate duplicate extensions files into core/extensions"
```

---

## Task 3: Crear ImagePickerHelper

**Files:**
- Create: `lib/core/utils/image_picker_helper.dart`

- [ ] **Paso 1: Crear el archivo**

Crear `lib/core/utils/image_picker_helper.dart` con este contenido:

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static Future<File?> pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }
}
```

- [ ] **Paso 2: Verificar**

```bash
flutter analyze lib/core/utils/image_picker_helper.dart
```
Esperado: sin errores.

- [ ] **Paso 3: Commit**

```bash
git add lib/core/utils/image_picker_helper.dart
git commit -m "refactor: add ImagePickerHelper shared utility"
```

---

## Task 4: Agregar ProfileSkeleton a shimmer_skeleton.dart

**Files:**
- Modify: `lib/core/widgets/shimmer_skeleton.dart`

- [ ] **Paso 1: Agregar la clase `ProfileSkeleton` al final del archivo**

Añadir después de la clase `LibrarySkeleton` (línea 169):

```dart
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 30),
          // Avatar
          const ShimmerSkeleton(width: 140, height: 140, shape: BoxShape.circle),
          const SizedBox(height: 16),
          // Nombre
          const ShimmerSkeleton(width: 160, height: 24),
          const SizedBox(height: 12),
          // Botón editar perfil
          const ShimmerSkeleton(width: 110, height: 34, borderRadius: 20),
          const SizedBox(height: 32),
          // Sección información personal
          const ShimmerSkeleton(width: double.infinity, height: 16),
          const SizedBox(height: 12),
          const ShimmerSkeleton(width: double.infinity, height: 100, borderRadius: 20),
        ],
      ),
    );
  }
}
```

- [ ] **Paso 2: Verificar**

```bash
flutter analyze lib/core/widgets/shimmer_skeleton.dart
```
Esperado: sin errores.

- [ ] **Paso 3: Commit**

```bash
git add lib/core/widgets/shimmer_skeleton.dart
git commit -m "feat: add ProfileSkeleton to shimmer_skeleton for consistent loading UI"
```

---

## Task 5: Fix bug — artista incorrecto en PlayerScreen + colores + null onPressed

**Files:**
- Modify: `lib/features/player/presentation/pages/player_screen.dart`

- [ ] **Paso 1: Actualizar import de AppColors si no está ya**

Verificar que la línea de import exista (ya está en el archivo):
```dart
import '../../../../core/theme/app_colors.dart';
```

- [ ] **Paso 2: Corregir el nombre del artista (línea 128)**

Encontrar:
```dart
song.album.isNotEmpty ? song.album : 'Artista Desconocido',
```
Reemplazar por:
```dart
song.artistName.isNotEmpty ? song.artistName : 'Artista Desconocido',
```

- [ ] **Paso 3: Desactivar botones sin implementar con `onPressed: null`**

Localizar el `IconButton` de shuffle (cerca de la línea 173) y cambiar:
```dart
// ANTES
IconButton(
  icon: const Icon(Icons.shuffle, color: Colors.white, size: 28),
  onPressed: () {},
),
```
```dart
// DESPUÉS
IconButton(
  icon: Icon(Icons.shuffle, color: Colors.white.withValues(alpha: 0.3), size: 28),
  onPressed: null,
),
```

Mismo cambio para el botón de repeat (cerca de línea 244):
```dart
// ANTES
IconButton(
  icon: const Icon(Icons.repeat, color: Colors.white, size: 28),
  onPressed: () {},
),
```
```dart
// DESPUÉS
IconButton(
  icon: Icon(Icons.repeat, color: Colors.white.withValues(alpha: 0.3), size: 28),
  onPressed: null,
),
```

Mismo cambio para `more_vert` (cerca de línea 75):
```dart
// ANTES
IconButton(
  icon: const Icon(Icons.more_vert, color: Colors.white),
  onPressed: () {},
),
```
```dart
// DESPUÉS
IconButton(
  icon: Icon(Icons.more_vert, color: Colors.white.withValues(alpha: 0.3)),
  onPressed: null,
),
```

Mismo cambio para `devices` (cerca de línea 257):
```dart
// ANTES
IconButton(
  icon: const Icon(Icons.devices, color: Colors.white54, size: 24),
  onPressed: () {},
),
```
```dart
// DESPUÉS
IconButton(
  icon: const Icon(Icons.devices, color: Colors.white24, size: 24),
  onPressed: null,
),
```

Mismo cambio para `share_outlined` y `menu` (cerca de líneas 262-268):
```dart
// ANTES
IconButton(
  icon: const Icon(Icons.share_outlined, color: Colors.white54, size: 24),
  onPressed: () {},
),
IconButton(
  icon: const Icon(Icons.menu, color: Colors.white54, size: 24),
  onPressed: () {},
),
```
```dart
// DESPUÉS
IconButton(
  icon: const Icon(Icons.share_outlined, color: Colors.white24, size: 24),
  onPressed: null,
),
IconButton(
  icon: const Icon(Icons.menu, color: Colors.white24, size: 24),
  onPressed: null,
),
```

- [ ] **Paso 4: Verificar**

```bash
flutter analyze lib/features/player/presentation/pages/player_screen.dart
```
Esperado: sin errores.

- [ ] **Paso 5: Commit**

```bash
git add lib/features/player/presentation/pages/player_screen.dart
git commit -m "fix: show artist name in player screen; disable unimplemented player buttons"
```

---

## Task 6: Fix bug — ClipRRect en portada de PlaylistDetailPage + colores + null onPressed

**Files:**
- Modify: `lib/features/playlist_detail/presentation/pages/playlist_detail_page.dart`

- [ ] **Paso 1: Agregar import de AppColors si no está**

Ya existe en el archivo:
```dart
import '../../../../core/theme/app_colors.dart';
```

- [ ] **Paso 2: Agregar `ClipRRect` en `_buildCoverSpace`**

Encontrar el método `_buildCoverSpace` (cerca de la línea 323). El `Container` de la portada debe quedar envuelto en `ClipRRect`:

```dart
Widget _buildCoverSpace() {
  final heroTag = type == 'playlist' || type == 'favorites' 
      ? 'playlist_cover_$title' 
      : 'album_cover_$title';

  return Center(
    child: Hero(
      tag: heroTag,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.coverPlaceholder,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ]
          ),
          child: coverUrl != null 
            ? FadeInImage.assetNetwork(
                placeholder: 'assets/images/logo.png',
                image: coverUrl!,
                fit: BoxFit.cover,
                imageErrorBuilder: (e, s, t) => const Center(
                  child: Icon(Icons.photo_outlined, color: Colors.white, size: 80),
                ),
              )
            : const Icon(Icons.photo_outlined, color: Colors.white, size: 80),
        ),
      ),
    ),
  );
}
```

- [ ] **Paso 3: Reemplazar colores hardcodeados en el resto del archivo**

Reemplazar todas las ocurrencias de `Color(0xFF282828)` por `AppColors.surface`:
- `AlertDialog backgroundColor:` (línea ~72)
- Fondo de `PopupMenuButton` (línea ~131)

Reemplazar `const Color(0xFF1DB954)` en el SnackBar (línea ~109) por `AppColors.primary`.

- [ ] **Paso 4: Desactivar botones Play y Shuffle de la fila de controles**

Localizar la fila de controles con `Icons.shuffle` y el botón circular de play (cerca de líneas 185-199). Cambiar:

```dart
// Botón shuffle
IconButton(
  icon: const Icon(Icons.shuffle, color: AppColors.primary, size: 28),
  onPressed: () {},
),
```
por:
```dart
IconButton(
  icon: Icon(Icons.shuffle, color: AppColors.primary.withValues(alpha: 0.3), size: 28),
  onPressed: null,
),
```

Para el botón circular de play:
```dart
// ANTES
Container(
  decoration: const BoxDecoration(
    color: AppColors.primary,
    shape: BoxShape.circle,
  ),
  child: IconButton(
    icon: const Icon(Icons.play_arrow, color: Colors.black, size: 32),
    onPressed: () {},
  ),
),
```
```dart
// DESPUÉS
Container(
  decoration: BoxDecoration(
    color: AppColors.primary.withValues(alpha: 0.3),
    shape: BoxShape.circle,
  ),
  child: IconButton(
    icon: const Icon(Icons.play_arrow, color: Colors.black54, size: 32),
    onPressed: null,
  ),
),
```

El chip "Guardado" no es interactivo — quitar cualquier `GestureDetector` que lo envuelva si existe. Si es solo `Row` + `Icon` + `Text`, ya está bien.

- [ ] **Paso 5: Verificar**

```bash
flutter analyze lib/features/playlist_detail/presentation/pages/playlist_detail_page.dart
```
Esperado: sin errores.

- [ ] **Paso 6: Commit**

```bash
git add lib/features/playlist_detail/presentation/pages/playlist_detail_page.dart
git commit -m "fix: clip cover image in playlist detail; disable unimplemented play/shuffle buttons"
```

---

## Task 7: Fix bug — botón "Crear Playlist" en estado vacío de Biblioteca

**Files:**
- Modify: `lib/features/library/presentation/pages/library_page.dart`

- [ ] **Paso 1: Agregar import de MainNavigationCubit**

En `lib/features/library/presentation/pages/library_page.dart`, agregar el import:
```dart
import '../../../main_navigation/presentation/cubit/main_navigation_cubit.dart';
```

- [ ] **Paso 2: Conectar el botón al cubit**

Localizar `onButtonPressed: () {}` dentro de `_buildGrid` (línea ~98). Reemplazar:
```dart
onButtonPressed: () {
  // Navegar a la pestaña de creación (índice 3 en MainPage)
  // O podrías abrir el diálogo de creación aquí mismo.
  // Por ahora, solo cerramos el mensaje informativo.
},
```
por:
```dart
onButtonPressed: () {
  context.read<MainNavigationCubit>().changeTab(3);
},
```

- [ ] **Paso 3: Reemplazar colores hardcodeados**

En `library_page.dart`, reemplazar `const Color(0xFF282828)` por `AppColors.surface` donde aparezca. Verificar también `RefreshIndicator(backgroundColor:` que usa ese color directamente.

- [ ] **Paso 4: Verificar**

```bash
flutter analyze lib/features/library/presentation/pages/library_page.dart
```
Esperado: sin errores.

- [ ] **Paso 5: Commit**

```bash
git add lib/features/library/presentation/pages/library_page.dart
git commit -m "fix: library empty state 'Crear Playlist' button now navigates to Create tab"
```

---

## Task 8: Reemplazar colores hardcodeados en Home, MiniPlayer y MainPage

**Files:**
- Modify: `lib/features/home/presentation/pages/home.dart`
- Modify: `lib/features/player/presentation/widgets/mini_player.dart`
- Modify: `lib/features/main_navigation/presentation/pages/main_page.dart`

- [ ] **Paso 1: `home.dart` — reemplazar colores**

Abrir `lib/features/home/presentation/pages/home.dart`.

Reemplazar `const Color(0xFF282828)` por `AppColors.surface` (aparece en el `RefreshIndicator backgroundColor`).

- [ ] **Paso 2: `mini_player.dart` — reemplazar colores**

Abrir `lib/features/player/presentation/widgets/mini_player.dart`.

Reemplazar:
- `color: const Color(0xFF2C2C2C)` (fondo del container del mini player) por `color: AppColors.surface`
- `color: const Color(0xFF6A2C50)` (placeholder de portada) por `color: AppColors.coverPlaceholder`

- [ ] **Paso 3: `main_page.dart` — reemplazar colores**

Abrir `lib/features/main_navigation/presentation/pages/main_page.dart`.

El `RefreshIndicator` o cualquier `Color(0xFF282828)` explícito → `AppColors.surface`.

- [ ] **Paso 4: Verificar los tres archivos**

```bash
flutter analyze lib/features/home/presentation/pages/home.dart lib/features/player/presentation/widgets/mini_player.dart lib/features/main_navigation/presentation/pages/main_page.dart
```
Esperado: sin errores.

- [ ] **Paso 5: Commit**

```bash
git add lib/features/home/presentation/pages/home.dart lib/features/player/presentation/widgets/mini_player.dart lib/features/main_navigation/presentation/pages/main_page.dart
git commit -m "style: replace hardcoded colors with AppColors constants in home, mini player and main nav"
```

---

## Task 9: Reemplazar colores en Profile y add_to_playlist_sheet

**Files:**
- Modify: `lib/features/library/presentation/widgets/add_to_playlist_sheet.dart`
- Modify: `lib/features/profile/presentation/pages/profile_page.dart`

- [ ] **Paso 1: `add_to_playlist_sheet.dart` — reemplazar colores**

Buscar `Color(0xFF282828)` y reemplazar por `AppColors.surface`. Asegurarse de que `app_colors.dart` está importado.

- [ ] **Paso 2: `profile_page.dart` — reemplazar colores**

Buscar `Color(0xFF282828)` → `AppColors.surface` en:
- `showModalBottomSheet backgroundColor:`
- Cualquier `Container` decoration

- [ ] **Paso 3: Verificar**

```bash
flutter analyze lib/features/library/presentation/widgets/add_to_playlist_sheet.dart lib/features/profile/presentation/pages/profile_page.dart
```
Esperado: sin errores.

- [ ] **Paso 4: Commit**

```bash
git add lib/features/library/presentation/widgets/add_to_playlist_sheet.dart lib/features/profile/presentation/pages/profile_page.dart
git commit -m "style: replace hardcoded colors with AppColors in profile and add-to-playlist sheet"
```

---

## Task 10: Usar ProfileSkeleton y ImagePickerHelper en ProfilePage

**Files:**
- Modify: `lib/features/profile/presentation/pages/profile_page.dart`

- [ ] **Paso 1: Agregar imports necesarios**

En `profile_page.dart`, agregar:
```dart
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../core/utils/image_picker_helper.dart';
```

Eliminar el import de `image_picker` si ya no se usa directamente:
```dart
// Eliminar esta línea:
import 'package:image_picker/image_picker.dart';
```

- [ ] **Paso 2: Reemplazar `CircularProgressIndicator` por `ProfileSkeleton`**

En `profile_page.dart` línea ~141, reemplazar:
```dart
if (state is ProfileLoading) {
  return const Center(child: CircularProgressIndicator(color: Colors.white));
```
por:
```dart
if (state is ProfileLoading) {
  return const ProfileSkeleton();
```

- [ ] **Paso 3: Reemplazar `_pickImage` por `ImagePickerHelper.pickFromGallery()`**

El método `_pickImage(StateSetter setStateDialog)` actualmente:
```dart
Future<void> _pickImage(StateSetter setStateDialog) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    setStateDialog(() {
      _selectedImage = File(image.path);
    });
  }
}
```

Reemplazarlo por:
```dart
Future<void> _pickImage(StateSetter setStateDialog) async {
  final file = await ImagePickerHelper.pickFromGallery();
  if (file != null) {
    setStateDialog(() {
      _selectedImage = file;
    });
  }
}
```

(El método se mantiene con la misma firma para no cambiar los call-sites internos de `profile_page.dart`.)

- [ ] **Paso 4: Verificar**

```bash
flutter analyze lib/features/profile/presentation/pages/profile_page.dart
```
Esperado: sin errores.

- [ ] **Paso 5: Commit**

```bash
git add lib/features/profile/presentation/pages/profile_page.dart
git commit -m "refactor: use ProfileSkeleton and ImagePickerHelper in ProfilePage"
```

---

## Task 11: Usar ImagePickerHelper en CreatePage + reemplazar colores

**Files:**
- Modify: `lib/features/create/presentation/pages/create_page.dart`

- [ ] **Paso 1: Agregar import**

En `create_page.dart`, agregar:
```dart
import 'package:spotify_clone/core/utils/image_picker_helper.dart';
```

Eliminar el import de `image_picker` si ya no se usa directamente:
```dart
// Eliminar:
import 'package:image_picker/image_picker.dart';
```

- [ ] **Paso 2: Reemplazar `_pickImage`**

El método actual en `_CreatePlaylistViewState`:
```dart
Future<void> _pickImage(StateSetter setStateDialog) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    setStateDialog(() {
      _selectedImage = File(image.path);
    });
  }
}
```

Reemplazarlo por:
```dart
Future<void> _pickImage(StateSetter setStateDialog) async {
  final file = await ImagePickerHelper.pickFromGallery();
  if (file != null) {
    setStateDialog(() {
      _selectedImage = file;
    });
  }
}
```

- [ ] **Paso 3: Reemplazar colores hardcodeados**

Reemplazar todas las ocurrencias de `Color(0xFF282828)` por `AppColors.surface` en:
- `showModalBottomSheet backgroundColor:` (x3 — dialogs de playlist, album y canción)
- Cualquier `Container` o `DropdownButtonFormField dropdownColor:` con ese color

- [ ] **Paso 4: Verificar**

```bash
flutter analyze lib/features/create/presentation/pages/create_page.dart
```
Esperado: sin errores.

- [ ] **Paso 5: Commit**

```bash
git add lib/features/create/presentation/pages/create_page.dart
git commit -m "refactor: use ImagePickerHelper in CreatePage; replace hardcoded colors"
```

---

## Task 12: Extraer `_DiscoverGrid` en SearchPage

**Files:**
- Modify: `lib/features/search/presentation/pages/search_page.dart`

- [ ] **Paso 1: Crear la clase `_DiscoverGrid` al final del archivo**

Al final de `search_page.dart` (después de todos los métodos de `_SearchViewState`), agregar la clase privada:

```dart
class _DiscoverGrid extends StatelessWidget {
  const _DiscoverGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const HomeSkeleton();
        }

        if (state is HomeLoaded) {
          final albums = state.albums;
          final playlists = state.playlists;

          return CustomScrollView(
            slivers: [
              if (albums.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Explorar todo',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final album = albums[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaylistDetailPage(
                              id: album.id.toString(),
                              title: album.title,
                              type: 'album',
                              coverUrl: album.coverUrl,
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              if (album.coverUrl.isNotEmpty)
                                Positioned.fill(
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/images/logo.png',
                                    image: album.coverUrl,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (e, s, t) => const Icon(Icons.album, color: Colors.white10),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [Colors.black87, Colors.transparent],
                                    ),
                                  ),
                                  child: Text(
                                    album.title,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: albums.length > 6 ? 6 : albums.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                ),
              ],
              if (playlists.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 12),
                    child: Text(
                      'Para ti',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final playlist = playlists[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.queue_music, color: AppColors.primary),
                        ),
                        title: Text(playlist.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('Playlist • ${playlist.creatorName}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaylistDetailPage(
                              id: playlist.id.toString(),
                              title: playlist.name,
                              type: 'playlist',
                              ownerId: playlist.userId,
                              coverUrl: null,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: playlists.length,
                  ),
                ),
              ],
              if (albums.isEmpty && playlists.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, color: Colors.white24, size: 80),
                        SizedBox(height: 16),
                        Text('Busca canciones, álbumes o artistas', style: TextStyle(color: Colors.white54, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }

        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, color: Colors.white24, size: 80),
              SizedBox(height: 16),
              Text('Busca canciones, álbumes o artistas', style: TextStyle(color: Colors.white54, fontSize: 16)),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Paso 2: Reemplazar `_buildDiscoverGrid` en `_SearchViewState`**

Eliminar el método completo `Widget _buildDiscoverGrid(BuildContext context)` de `_SearchViewState`.

En el `BlocBuilder` dentro de `build`, reemplazar todas las llamadas a `_buildDiscoverGrid(context)` por `const _DiscoverGrid()`.

Hay dos lugares:
1. `} else if (state is SearchRecentLoaded) { ... return _buildDiscoverGrid(context);` → `return const _DiscoverGrid();`
2. `return _buildDiscoverGrid(context);` al final del builder → `return const _DiscoverGrid();`

- [ ] **Paso 3: Verificar**

```bash
flutter analyze lib/features/search/presentation/pages/search_page.dart
```
Esperado: sin errores.

- [ ] **Paso 4: Commit**

```bash
git add lib/features/search/presentation/pages/search_page.dart
git commit -m "refactor: extract _DiscoverGrid widget in SearchPage for readability"
```

---

## Task 13: Verificación final integral

- [ ] **Paso 1: Analyze completo**

```bash
flutter analyze lib/
```
Esperado: 0 errores. Cualquier warning preexistente no relacionado con los cambios puede ignorarse.

- [ ] **Paso 2: Build de verificación**

```bash
flutter build apk --debug --dart-define=API_BASE_URL=http://localhost:4000/api
```
Esperado: compilación exitosa sin errores.

- [ ] **Paso 3: Verificación manual en dispositivo/emulador**

Comprobar:
- [ ] Player muestra nombre del artista (no el álbum)
- [ ] Botones Shuffle/Repeat/Share/Devices en player se ven grises/inactivos
- [ ] Botones Play/Shuffle en PlaylistDetail se ven grises/inactivos
- [ ] Pantalla de perfil muestra skeleton shimmer al cargar
- [ ] Botón "Crear Playlist" en biblioteca vacía navega al tab Crear
- [ ] Las portadas en PlaylistDetail quedan bien recortadas
- [ ] No hay regresiones visuales visibles en Home, Search, Library, Create

- [ ] **Paso 4: Commit final si hay ajustes menores post-verificación**

```bash
git add -p  # solo los archivos tocados
git commit -m "fix: post-verification minor adjustments"
```
