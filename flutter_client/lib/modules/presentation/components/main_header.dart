//feito por marcelo, abdallah, gabriel
import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/home/home_palette.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';

class MainHeader extends StatelessWidget {
  const MainHeader({required this.controller, this.onProfileTap, super.key});

  final HomeController controller;
  final VoidCallback? onProfileTap;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(1.6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF243645), Color(0xFF182632)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF4EEF8),
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 18,
                      height: 18
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Text(
            'MesclaInvest',
            style: TextStyle(
              color: HomePalette.brandPink,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
