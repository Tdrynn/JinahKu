import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jinahku/models/modelUser.dart';
import 'package:jinahku/l10n/app_localizations.dart';

class Page1 extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback onNext;

  const Page1({super.key, required this.data, required this.onNext});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
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
      backgroundColor: const Color(0xFF000C2C),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [

              SizedBox(
                height: 490.h,
                child: Padding(
                  padding: const EdgeInsets.only(top: 45),
                  child: Image.asset(
                    'assets/images/BG_P1.webp',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    alignment: .topCenter,
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: 445.h),
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B263B),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Nama Pengguna",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "Nama ini akan digunakan di aplikasi",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: controller,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama wajib diisi';
                        }
                        return null;
                      },
                      style: const TextStyle(
                        color: Colors.white
                      ),

                      decoration: InputDecoration(
                        hintText: l10n.namaP,
                        hintStyle: const TextStyle(
                          color: Colors.white54
                        ),
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

                    const SizedBox(height: 18),

                    Text(
                      "Pilih Avatar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

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

                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F6BFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          widget.data.username = controller.text;
                          widget.onNext();
                        },

                        child: Text(
                          l10n.lanjutkan,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

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
