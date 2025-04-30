import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'settings_viewmodel.dart';

class SettingsView extends StackedView<SettingsViewModel> {
  const SettingsView({super.key});

  @override
  Widget builder(
      BuildContext context, SettingsViewModel viewModel, Widget? child) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/anaSayfaTasarimi.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Profil Bilgileriniz",
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _editableField(
                    label: "Adınız",
                    controller: viewModel.nameController,
                    isEditing: viewModel.isEditingName,
                    onTapEdit: viewModel.toggleNameEdit,
                  ),
                  const SizedBox(height: 20),
                  _editableField(
                    label: "E-posta",
                    controller: viewModel.emailController,
                    isEditing: viewModel.isEditingEmail,
                    onTapEdit: viewModel.toggleEmailEdit,
                  ),
                  const SizedBox(height: 30),
                  Card(
                    color: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.bar_chart,
                                color: Colors.white,
                                size: 26,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Oyun İstatistiklerim",
                                style: GoogleFonts.rubik(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Column(
                            children: [
                              Image.asset(
                                'lib/assets/images/kazanilanicon.png',
                                height: 40,
                                width: 40,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Kazanılan: ${0}",
                                style: GoogleFonts.rubik(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Column(
                            children: [
                              Image.asset(
                                'lib/assets/images/kaybedilenicon.png',
                                height: 40,
                                width: 40,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Kaybedilen: ${0}",
                                style: GoogleFonts.rubik(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Column(
                            children: [
                              Image.asset(
                                'lib/assets/images/basarioraniicon.png',
                                height: 40,
                                width: 40,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Başarı: %${viewModel.successRate}",
                                style: GoogleFonts.rubik(
                                  color: Colors.amberAccent,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Spacer(),
                  GestureDetector(
                    onTap: viewModel.logout,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'lib/assets/images/cikisyap.png', 
                            height: 100,
                            width: 150,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onTapEdit,
  }) {
    return TextField(
      controller: controller,
      enabled: isEditing,
      style: GoogleFonts.rubik(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.rubik(
          color: Colors.white70,
          fontSize: 18,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: onTapEdit,
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  @override
  SettingsViewModel viewModelBuilder(BuildContext context) =>
      SettingsViewModel();
}
