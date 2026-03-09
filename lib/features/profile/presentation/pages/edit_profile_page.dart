import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/basic_app_button.dart';
import '../../../../core/utils/extensions.dart'; // Asegúrate de que este archivo exista, si da error lo borraremos
import '../../domain/entities/user_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  final UserEntity user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _usernameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    
    final username = _usernameController.text.trim();
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    
    if (oldPassword.isEmpty && newPassword.isNotEmpty) {
      context.showSnack('Ingresa tu contraseña actual para guardar la nueva.');
      return;
    }
    if (username.isEmpty) {
      context.showSnack('El nombre de usuario no puede estar vacío.');
      return;
    }

    context.read<ProfileBloc>().add(
      UpdateProfileEvent(
        username: username != widget.user.username ? username : null,
        oldPassword: oldPassword,
        newPassword: newPassword,
        imagePath: _selectedImage?.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoading) {
          setState(() => _isSaving = true);
        } else if (state is ProfileUpdateSuccess) {
          setState(() => _isSaving = false);
          context.showSnack('Perfil actualizado exitosamente', color: Colors.green);
          // Pedimos la recarga completa del perfil
          context.read<ProfileBloc>().add(LoadProfileEvent());
          Navigator.pop(context);
        } else if (state is ProfileUpdateError) {
          setState(() => _isSaving = false);
          context.showSnack(state.message);
        } else if (state is ProfileError) {
          setState(() => _isSaving = false);
          context.showSnack(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Perfil'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Avatar Section
              GestureDetector(
                onTap: _isSaving ? null : _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white10,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!) as ImageProvider
                          : (widget.user.profileImageUrl != null && widget.user.profileImageUrl!.isNotEmpty)
                              ? NetworkImage(widget.user.profileImageUrl!)
                              : null,
                      child: (_selectedImage == null && 
                             (widget.user.profileImageUrl == null || widget.user.profileImageUrl!.isEmpty))
                          ? const Icon(Icons.person, size: 60, color: Colors.white54)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Form Section
              AppTextField(
                controller: _usernameController,
                label: 'Nombre de usuario',
                hintText: '@username',
                prefixIcon: Icons.person_outline,
                enabled: !_isSaving,
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cambiar contraseña (opcional)',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _oldPasswordController,
                label: 'Contraseña actual',
                hintText: '********',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                enabled: !_isSaving,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _newPasswordController,
                label: 'Nueva contraseña',
                hintText: '********',
                isPassword: true,
                prefixIcon: Icons.lock_reset,
                enabled: !_isSaving,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _saveProfile(),
              ),
              
              const SizedBox(height: 48),
              BasicAppButton(
                onPressed: _isSaving ? () {} : _saveProfile,
                title: 'Guardar Cambios',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
