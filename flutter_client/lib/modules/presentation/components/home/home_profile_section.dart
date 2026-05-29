import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/home/home_header.dart';
import 'package:flutter_client/modules/presentation/components/home/home_palette.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';

class HomeProfileSection extends StatelessWidget {
  const HomeProfileSection({
    required this.controller,
    required this.onProfileTap,
    this.showHeader = true,
    super.key,
  });

  final HomeController controller;
  final VoidCallback onProfileTap;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          HomeHeader(
            profileImage: controller.profileImage,
            userInitials: controller.userInitials,
            onProfileTap: onProfileTap,
          ),
          const SizedBox(height: 16),
          const Divider(
            height: 1,
            thickness: 1.5,
            color: HomePalette.dividerBlue,
          ),
          const SizedBox(height: 22),
        ],
        _ProfileCard(controller: controller),
        const SizedBox(height: 18),
        _ShortcutCard(
          title: 'Sua foto de perfil',
          description:
              'Toque no avatar ou no botão abaixo para trocar a foto que aparece no cabeçalho.',
          buttonLabel: 'Alterar foto',
          onPressed: onProfileTap,
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HomePalette.panel,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFD4147A), Color(0xFF655AC4)],
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: controller.profileImage == null
                    ? null
                    : DecorationImage(
                        image: controller.profileImage!,
                        fit: BoxFit.cover,
                      ),
              ),
              child: controller.profileImage == null
                  ? Center(
                      child: Text(
                        controller.userInitials,
                        style: const TextStyle(
                          color: HomePalette.deepText,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.userLabel,
            style: const TextStyle(
              color: HomePalette.deepText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            controller.currentUser?.email ?? 'Conta MesclaInvest',
            textAlign: TextAlign.center,
            style: const TextStyle(color: HomePalette.mutedText, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomePalette.panel,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: HomePalette.deepText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: HomePalette.mutedText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomePalette.brandPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
