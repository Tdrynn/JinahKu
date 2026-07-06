import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final paddingTop = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1B263B),
        body: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Container(
                          color: const Color(0xFF000C2C),
                          width: double.infinity,
                          padding: EdgeInsets.only(top: paddingTop + 15),
                          child: Image.asset(
                            'assets/images/BG_P1.webp',
                            fit: BoxFit.cover,
                          ),
                        ),

                        Expanded(
                          child: Transform.translate(
                            offset: const Offset(0, -15),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
                                  Text(
                                    l10n.namaP,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    l10n.namaI,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: controller,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return l10n.namaWajib;
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
                                        borderSide: BorderSide(
                                          color: Colors.blue.shade400,
                                        ),
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
                                    l10n.pilihA,
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
                                  
                                  const Spacer(),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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