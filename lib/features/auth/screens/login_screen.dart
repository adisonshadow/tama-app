import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../providers/auth_provider.dart';
import '../../../shared/utils/error_utils.dart';
import '../../../shared/widgets/language_selector.dart';
import '../../../shared/providers/language_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // 在调试模式下自动填充测试账号
    if (!const bool.fromEnvironment('dart.vm.product')) {
      _emailController.text = 'yoyo@love.com';
      _passwordController.text = '123456';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      ErrorUtils.showError(
        context,
        authProvider.error ?? FlutterI18n.translate(context, 'auth.login.login_failed'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Lottie 背景动画 - 占满整个屏幕
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Lottie.asset(
              'assets/images/lottie-bg.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          // 半透明遮罩层 - 占满整个屏幕
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),
          // 主要内容 - 占满整个屏幕高度
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SafeArea(
              child: Column(
                children: [
                  // 语言选择器 - 右上角
                  const Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(top: 16, right: 16),
                      child: LanguageSelector(),
                    ),
                  ),
                  // 主要内容
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 26),
                          
                          // Logo
                          const Image(
                            image: AssetImage('assets/images/logo.png'),
                            width: 68,
                            height: 68,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // 标题
                          Consumer<LanguageProvider>(
                            builder: (context, languageProvider, _) {
                              return Text(
                                FlutterI18n.translate(context, 'auth.login.title'),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          
                          // const SizedBox(height: 8),
                          //
                          // // 副标题
                          // Consumer<LanguageProvider>(
                          //   builder: (context, languageProvider, _) {
                          //     return Text(
                          //       FlutterI18n.translate(context, 'auth.login.subtitle'),
                          //       style: const TextStyle(
                          //         fontSize: 16,
                          //         color: Colors.grey,
                          //       ),
                          //     );
                          //   },
                          // ),
                          
                          const SizedBox(height: 40),
                          
                          // 登录表单
                          Consumer<LanguageProvider>(
                            builder: (context, languageProvider, _) {
                              return Form(
                                key: _formKey,
                                child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(context, 'auth.login.email'),
                                    labelStyle: const TextStyle(color: Colors.grey),
                                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return FlutterI18n.translate(context, 'auth.login.email_required');
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return FlutterI18n.translate(context, 'auth.login.email_invalid');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 30),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: FlutterI18n.translate(context, 'auth.login.password'),
                                    labelStyle: const TextStyle(color: Colors.grey),
                                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return FlutterI18n.translate(context, 'auth.login.password_required');
                                    }
                                    if (value.length < 6) {
                                      return FlutterI18n.translate(context, 'auth.login.password_min_length');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),

                                // 登录按钮
                                Consumer<AuthProvider>(
                                  builder: (context, authProvider, child) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: authProvider.isLoading ? null : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: authProvider.isLoading
                                            ? const CircularProgressIndicator(color: Colors.white)
                                            : Text(
                                                FlutterI18n.translate(context, 'auth.login.login_button'),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                            },
                          ),

                          const SizedBox(height: 24),

                          // 注册链接
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                FlutterI18n.translate(context, 'auth.login.no_account'),
                                style: const TextStyle(color: Colors.grey),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.go('/auth/register');
                                },
                                child: Text(
                                  FlutterI18n.translate(context, 'auth.login.sign_up'),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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
}
