//feito por Marcelo Zarpelon - RA: 25015323 , Abdallah Ali Borges El-Khatib - RA: 25018711 e Gabriel Scolfaro de Azeredo - RA: 25006194
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
      height: 54,
      child: Stack(
        alignment: Alignment.centerLeft,
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
                    child: const SizedBox(width: 18, height: 18),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            left: 58,
            right: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                controller.greetingLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: HomePalette.deepText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
