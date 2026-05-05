// feito por abdallah e marcelo
import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';

class MainHeader extends StatelessWidget {

  const MainHeader({super.key, required this.controller});

  final HomeController controller;

  static const Color shellBackground = Color(0xFF1F1E24);
  static const Color pageBackground = Color(0xFFFCF9FF);
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color panel = Color(0xFFF4EEFB);
  static const Color dividerBlue = Color(0xFF3C9BFF);
  static const Color brandPink = Color(0xFFD4147A);
  static const Color brandPurple = Color(0xFF655AC4);
  static const Color deepText = Color(0xFF241B60);
  static const Color mutedText = Color(0xFF756E93);
  static const Color softYellow = Color(0xFFFFDE74);
  static const Color activeNavBackground = Color(0xFFECE4FF);

  @override
  Widget build(BuildContext context){
    return SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: null, //TODO: levar para as configurações
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
                                    color: deepText,
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
                        height: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              'MesclaInvest',
              style: TextStyle(
                color: brandPink,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }
}