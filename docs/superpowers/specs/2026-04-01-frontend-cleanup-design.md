# Frontend Cleanup & Refactor — Design Spec
**Date:** 2026-04-01  
**Scope:** Flutter frontend (`lib/`) — bug fixes, visual consistency, dead code removal, minor refactors  
**Out of scope:** New features, shuffle/repeat logic, backend changes

---

## 1. Bug Fixes

### 1.1 Artista mostrado incorrectamente en el player
- **Archivo:** `lib/features/player/presentation/pages/player_screen.dart:128`
- **Problema:** Se muestra `song.album` donde debería ir el nombre del artista.
- **Fix:** Reemplazar `song.album.isNotEmpty ? song.album : 'Artista Desconocido'` por `song.artistName.isNotEmpty ? song.artistName : 'Artista Desconocido'`.

### 1.2 Botón "Crear Playlist" en estado vacío de Biblioteca no hace nada
- **Archivo:** `lib/features/library/presentation/pages/library_page.dart:98`
- **Problema:** `onButtonPressed: () {}` — callback vacío, el botón no navega a ningún lado.
- **Fix:** Usar `MainNavigationCubit` para cambiar al tab de Crear (índice 3). El widget `LibraryView` accede al cubit con `context.read<MainNavigationCubit>().changeTab(3)`.

### 1.3 Portada en `PlaylistDetailPage` sin `ClipRRect`
- **Archivo:** `lib/features/playlist_detail/presentation/pages/playlist_detail_page.dart` — método `_buildCoverSpace`
- **Problema:** El `Container` tiene `borderRadius` en `BoxDecoration` pero no está envuelto en `ClipRRect`, por lo que la imagen de red no queda recortada.
- **Fix:** Envolver el `Container` en `ClipRRect(borderRadius: BorderRadius.zero)` — la portada es intencionalmente cuadrada, pero así la imagen respeta los límites del contenedor correctamente. Verificar si se desea algún radio de esquina (por ejemplo 4–8 px) para consistencia con otras cards.

### 1.4 Consolidar archivos de extensiones duplicados
- **Archivos:** `lib/core/extensions/extensions.dart` y `lib/core/utils/extensions.dart`
- **Acción:** Revisar el contenido de ambos. Si uno es subconjunto del otro o están duplicados, consolidar en `lib/core/utils/extensions.dart` y actualizar imports. Si tienen responsabilidades distintas, dejarlos pero documentar el propósito de cada uno.

---

## 2. Colores y Consistencia Visual

### 2.1 Agregar constantes faltantes a `AppColors`
- **Archivo:** `lib/core/theme/app_colors.dart`
- **Añadir:**
  ```dart
  static const Color surface = Color(0xFF282828);        // cards, bottom sheets, dialogs
  static const Color coverPlaceholder = Color(0xFF6A2C50); // placeholder de portadas
  ```

### 2.2 Reemplazar colores hardcodeados en los archivos afectados
Reemplazar `Color(0xFF282828)` → `AppColors.surface` y `Color(0xFF6A2C50)` → `AppColors.coverPlaceholder` en:
- `lib/features/player/presentation/pages/player_screen.dart`
- `lib/features/player/presentation/widgets/mini_player.dart`
- `lib/features/playlist_detail/presentation/pages/playlist_detail_page.dart`
- `lib/features/library/presentation/pages/library_page.dart`
- `lib/features/home/presentation/pages/home.dart`
- `lib/features/profile/presentation/pages/profile_page.dart`
- `lib/features/create/presentation/pages/create_page.dart`
- `lib/features/library/presentation/widgets/add_to_playlist_sheet.dart`
- `lib/features/main_navigation/presentation/pages/main_page.dart`

---

## 3. Consistencia de Loading en Profile

### 3.1 Crear `ProfileSkeleton` en `shimmer_skeleton.dart`
- **Archivo:** `lib/core/widgets/shimmer_skeleton.dart`
- **Añadir** la clase `ProfileSkeleton` al final del archivo, siguiendo el mismo patrón que `HomeSkeleton` y `LibrarySkeleton`.
- Estructura del skeleton:
  - Círculo (~140 px) para el avatar
  - Línea ancha (~150 px) para el nombre
  - Rectángulo pequeño (~100 px) para el botón "Editar Perfil"
  - Caja rectangular para la sección "Información personal"

### 3.2 Usar `ProfileSkeleton` en `ProfilePage`
- **Archivo:** `lib/features/profile/presentation/pages/profile_page.dart:141`
- Reemplazar `const Center(child: CircularProgressIndicator(color: Colors.white))` por `const ProfileSkeleton()`.

---

## 4. Extracción de `_pickImage` a Utilidad Compartida

### 4.1 Crear `lib/core/utils/image_picker_helper.dart`
Exponer una función estática:
```dart
static Future<File?> pickFromGallery() async {
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  return image != null ? File(image.path) : null;
}
```

### 4.2 Actualizar consumidores
- `lib/features/create/presentation/pages/create_page.dart` — reemplazar `_pickImage(setStateDialog)` por llamada a `ImagePickerHelper.pickFromGallery()` y actualizar estado con el resultado.
- `lib/features/profile/presentation/pages/profile_page.dart` — misma sustitución.

**Nota:** La nueva firma devuelve `Future<File?>` en lugar de recibir un `StateSetter`. Cada consumidor es responsable de llamar a `setStateDialog` con el resultado. Esto separa la lógica de picking de la lógica de estado del widget.

---

## 5. Botones Muertos → `onPressed: null`

Cambiar `onPressed: () {}` a `onPressed: null` en todos los botones sin implementar para que Flutter los renderice visualmente inactivos:

### 5.1 `player_screen.dart`
- `Icons.shuffle` — Shuffle
- `Icons.repeat` — Repeat
- `Icons.more_vert` — Menú superior
- `Icons.devices` — Dispositivos
- `Icons.share_outlined` — Compartir
- `Icons.menu` — Ver cola

### 5.2 `playlist_detail_page.dart`
- Botón `Icons.shuffle` (fila de controles)
- Botón `Icons.play_arrow` en contenedor circular (fila de controles)
- Chip "Guardado" (`Icons.check_circle_outline`) — envolver en `GestureDetector` con `onTap: null` o simplemente dejarlo como widget no interactivo

---

## 6. Extracción de Widget en Search

### 6.1 Extraer `_buildDiscoverGrid` a widget privado `_DiscoverGrid`
- **Archivo:** `lib/features/search/presentation/pages/search_page.dart`
- Crear `class _DiscoverGrid extends StatelessWidget` dentro del mismo archivo.
- El widget recibe los datos necesarios (o los lee directamente del `HomeBloc` mediante `context.watch`).
- `_SearchViewState._buildDiscoverGrid` se elimina y se reemplaza por `const _DiscoverGrid()` (o `_DiscoverGrid()` si necesita datos del estado).

---

## Archivos Modificados (resumen)

| Archivo | Tipo de cambio |
|---|---|
| `lib/core/theme/app_colors.dart` | Agregar 2 constantes |
| `lib/core/widgets/shimmer_skeleton.dart` | Agregar `ProfileSkeleton` |
| `lib/core/utils/extensions.dart` | Consolidar (revisar primero) |
| `lib/core/utils/image_picker_helper.dart` | **Nuevo archivo** |
| `lib/features/player/presentation/pages/player_screen.dart` | Bug fix, colores, null onPressed |
| `lib/features/player/presentation/widgets/mini_player.dart` | Colores |
| `lib/features/playlist_detail/presentation/pages/playlist_detail_page.dart` | ClipRRect, colores, null onPressed |
| `lib/features/library/presentation/pages/library_page.dart` | Fix botón vacío, colores |
| `lib/features/home/presentation/pages/home.dart` | Colores |
| `lib/features/profile/presentation/pages/profile_page.dart` | ProfileSkeleton, image picker, colores |
| `lib/features/create/presentation/pages/create_page.dart` | Image picker, colores |
| `lib/features/search/presentation/pages/search_page.dart` | Extracción `_DiscoverGrid` |
| `lib/features/main_navigation/presentation/pages/main_page.dart` | Colores |
| `lib/features/library/presentation/widgets/add_to_playlist_sheet.dart` | Colores |

---

## Criterios de éxito

- `flutter analyze` sin nuevos warnings tras los cambios
- La app compila y corre sin errores en Android
- El player muestra el nombre del artista correcto
- El botón "Crear Playlist" navega al tab Crear
- Los botones sin implementar son visualmente inactivos (grises)
- La pantalla de perfil muestra skeleton en lugar de spinner
- No hay `Color(0xFF282828)` ni `Color(0xFF6A2C50)` hardcodeados fuera de `app_colors.dart`
