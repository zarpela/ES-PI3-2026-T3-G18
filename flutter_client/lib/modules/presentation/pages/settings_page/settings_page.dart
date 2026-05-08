// feito por Gabriel Scolfaro

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_client/modules/presentation/components/home/home_palette.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_client/modules/presentation/pages/settings_page/settings_controller.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller;

  bool _mfaEnabled = false;

  @override
  void initState() {
    super.initState();
    final homeController = Modular.get<HomeController>();
    _controller = SettingsController(homeController);
    _controller.addListener(_refresh);
    _controller.loadUserName();
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _onPhotoTap() async {
    final source = await _showPhotoSourceSheet();
    if (source == null) return;

    final success = await _controller.pickAndUploadPhoto(source);

    if (!mounted) return;

    _showSnackBar(
      success
          ? 'Foto atualizada com sucesso!'
          : 'Erro ao atualizar a foto. Tente novamente.',
    );
  }

  Future<ImageSource?> _showPhotoSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PhotoSourceSheet(),
    );
  }

  Future<void> _onSignOut() async {
    final confirmed = await _showConfirmDialog(
      title: 'Sair do app',
      message: 'Deseja realmente sair da sua conta?',
      confirmLabel: 'Sair',
      isDestructive: true,
    );
    if (!confirmed) return;

    await _controller.signOut();
    if (mounted) Modular.to.navigate(AppRoutes.login);
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HomePalette.pageBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: const TextStyle(
            color: HomePalette.deepText,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: HomePalette.mutedText, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: HomePalette.mutedText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: isDestructive
                    ? Colors.red.shade600
                    : HomePalette.brandPink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: HomePalette.deepText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePalette.pageBackground,
      appBar: AppBar(
        backgroundColor: HomePalette.pageBackground,
        elevation: 0,
        leading: const BackButton(color: HomePalette.deepText),
        title: const Text(
          'Configurações',
          style: TextStyle(
            color: HomePalette.deepText,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _AvatarSection(
            profileImage: _controller.profileImage,
            userInitials: _controller.userInitials,
            userName: _controller.userLabel,
            isLoading: _controller.isUploadingPhoto,
            onTap: _onPhotoTap,
          ),
          const SizedBox(height: 24),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.shield_outlined,
                iconColor: HomePalette.brandPink,
                label: 'Autenticação multifator',
                trailing: CupertinoSwitch(
                  value: _mfaEnabled,
                  activeColor: HomePalette.brandPink,
                  onChanged: (v) => setState(() => _mfaEnabled = v),
                ),
              ),
              const _SettingsDivider(),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                iconColor: HomePalette.brandPurple,
                label: 'Alterar senha',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: HomePalette.mutedText,
                ),
                onTap: () => Modular.to.pushNamed(AppRoutes.changePassword),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _SignOutButton(onTap: _onSignOut),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar
// ---------------------------------------------------------------------------

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.profileImage,
    required this.userInitials,
    required this.userName,
    required this.isLoading,
    required this.onTap,
  });

  final ImageProvider? profileImage;
  final String userInitials;
  final String userName;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomePalette.panel,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: isLoading ? null : onTap,
            child: Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [HomePalette.brandPink, HomePalette.brandPurple],
                    ),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: profileImage != null
                          ? DecorationImage(
                              image: profileImage!,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profileImage == null
                        ? Center(
                            child: Text(
                              userInitials,
                              style: const TextStyle(
                                color: HomePalette.deepText,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.35),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!isLoading)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: HomePalette.brandPink,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HomePalette.panel,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_camera_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              userName,
              style: const TextStyle(
                color: HomePalette.deepText,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet de seleção de foto
// ---------------------------------------------------------------------------

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      decoration: const BoxDecoration(
        color: HomePalette.pageBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD5CCE5),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Foto de perfil',
            style: TextStyle(
              color: HomePalette.deepText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          _PhotoSourceOption(
            icon: Icons.photo_camera_rounded,
            label: 'Tirar foto',
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          const SizedBox(height: 12),
          _PhotoSourceOption(
            icon: Icons.photo_library_outlined,
            label: 'Escolher da galeria',
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          const SizedBox(height: 12),
          _PhotoSourceOption(
            icon: Icons.close_rounded,
            label: 'Cancelar',
            isDestructive: true,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _PhotoSourceOption extends StatelessWidget {
  const _PhotoSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade600 : HomePalette.deepText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: HomePalette.panel,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de configurações
// ---------------------------------------------------------------------------

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomePalette.panel,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: HomePalette.deepText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Divider(height: 1, color: Color(0xFFE5DFF5)),
    );
  }
}

// ---------------------------------------------------------------------------
// Botão de sair
// ---------------------------------------------------------------------------

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 20),
            const SizedBox(width: 10),
            Text(
              'Sair do app',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}