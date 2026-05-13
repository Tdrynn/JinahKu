import 'package:flutter/material.dart';
import 'package:jinahku/models/modelUser.dart';
import 'package:jinahku/l10n/app_localizations.dart';

class page1 extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback onNext;

  const page1({super.key, required this.data, required this.onNext});

  @override
  State<page1> createState() => _page1State();
}

class _page1State extends State<page1> {
  final TextEditingController controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  int selectedAvatarIndex = 0;

  final avatars = [
    'assets/images/Male.webp',
    'assets/images/Female.webp',
    'assets/images/Male1.webp',
    'assets/images/Female1.webp',
    'assets/images/User1.webp',
  ];

  @override
  void initState() {
    super.initState();

    controller.text = widget.data.username;

    final index = avatars.indexOf(widget.data.avatar);

    if (index != -1) {
      selectedAvatarIndex = index;
    }
  }
  // widget.data.avatar = avatars[0];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF071739),

      body: SingleChildScrollView(
        child: Form(
          key: _formKey,

          child: Column(
            children: [
              /// IMAGE
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Image.asset(
                  'assets/images/BG_PG2.webp',
                  height: 350,
                  fit: BoxFit.contain,
                ),
              ),

              /// CARD FORM
              Container(
                width: double.infinity,

                margin: const EdgeInsets.only(top: 10),

                padding: const EdgeInsets.all(24),

                decoration: const BoxDecoration(
                  color: Color(0xFF1B263B),

                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// TITLE
                    const Text(
                      "Nama Pengguna",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Nama ini akan digunakan di aplikasi",

                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),

                    const SizedBox(height: 20),

                    /// TEXTFIELD
                    TextFormField(
                      controller: controller,

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama wajib diisi';
                        }

                        return null;
                      },

                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        hintText: l10n.namaP,

                        hintStyle: const TextStyle(color: Colors.white54),

                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.white70,
                        ),

                        filled: true,

                        fillColor: const Color(0xFF243B55),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),

                          borderSide: BorderSide(color: Colors.blue.shade400),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),

                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),

                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),

                          borderSide: const BorderSide(color: Colors.red),
                        ),

                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),

                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// AVATAR TITLE
                    const Text(
                      "Pilih Avatar",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// AVATAR LIST
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: List.generate(avatars.length, (index) {
                        final isSelected = selectedAvatarIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAvatarIndex = index;

                              widget.data.avatar = avatars[index];
                            });
                          },

                          child: Container(
                            padding: const EdgeInsets.all(3),

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              border: isSelected
                                  ? Border.all(color: Colors.blue, width: 3)
                                  : null,
                            ),

                            child: CircleAvatar(
                              radius: 28,

                              backgroundImage: AssetImage(avatars[index]),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 58,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F6BFF),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        onPressed: () {
                          /// VALIDASI
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          widget.data.username = controller.text;

                          widget.onNext();
                        },

                        child: Text(
                          l10n.lanjutkan,

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// INDICATOR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        buildDot(true),
                        buildDot(false),
                        buildDot(false),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),

      width: active ? 10 : 8,
      height: active ? 10 : 8,

      decoration: BoxDecoration(
        color: active ? Colors.blue : Colors.white54,

        shape: BoxShape.circle,
      ),
    );
  }
}
