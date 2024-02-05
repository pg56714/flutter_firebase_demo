import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  String _email = '';
  String _password = '';

  // void _register() async {
  //   try {
  //     final newUser = await _auth.createUserWithEmailAndPassword(
  //       email: _email,
  //       password: _password,
  //     );
  //     if (newUser.user != null) {
  //       // 註冊成功，導航到主頁面
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // void _login() async {
  //   try {
  //     final user = await _auth.signInWithEmailAndPassword(
  //       email: _email,
  //       password: _password,
  //     );
  //     if (user.user != null) {
  //       // 登入成功，導航到主頁面
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  void _register() async {
    if (!isEmail(_email)) {
      // 電子郵件格式不正確，彈出提示對話框
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('錯誤'),
          content: const Text('請輸入有效的電子郵件地址。'),
          actions: <Widget>[
            TextButton(
              child: const Text('確定'),
              onPressed: () {
                Navigator.of(ctx).pop(); // 關閉對話框
              },
            ),
          ],
        ),
      );
      return; // 中斷函數執行
    }
    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      if (newUser.user != null) {
        // 發送認證郵件
        await newUser.user!.sendEmailVerification();
        // 檢查 Widget 是否仍然掛載
        if (!mounted) return; // 如果 Widget 已經卸載，則直接返回

        // 提示用戶檢查他們的郵箱
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('註冊成功'),
            content:
                const Text('我們已向您的電子郵件發送了一封認證郵件，請檢查您的郵箱並按照郵件中的指示進行操作以完成註冊。'),
            actions: <Widget>[
              TextButton(
                child: const Text('好的'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
        // 可選擇導航到登入頁面或其他頁面
      }
    } catch (e) {
      print(e);
      // 處理錯誤，例如顯示錯誤提示
      if (!mounted) return; // 同樣，確保在操作前組件仍然掛載
      // 在這裡可以安全地使用 context 顯示錯誤提示等
    }
  }

  void _login() async {
    if (!isEmail(_email)) {
      // 電子郵件格式不正確，彈出提示對話框
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('錯誤'),
          content: const Text('請輸入有效的電子郵件地址。'),
          actions: <Widget>[
            TextButton(
              child: const Text('確定'),
              onPressed: () {
                Navigator.of(ctx).pop(); // 關閉對話框
              },
            ),
          ],
        ),
      );
      return; // 中斷函數執行
    }
    try {
      final user = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      if (user.user != null) {
        // 使用 mounted 屬性檢查 State 是否還掛載
        if (!mounted) return; // 如果不再掛載，則直接返回

        // 檢查郵箱是否已驗證
        if (user.user!.emailVerified) {
          // 郵箱已驗證，導航到主頁面
        } else {
          // 郵箱未驗證，提示用戶檢查郵箱
          // 使用 mounted 檢查確保 showDialog 調用是安全的
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('警告'),
                content: const Text('您的電子郵件尚未認證。請檢查您的郵箱並點擊認證連結，然後再試一次登入。'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('好的'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      print(e);
      // 處理登入錯誤
      if (!mounted) return; // 檢查 State 是否還掛載
      // 可以安全地使用 context 進行 UI 更新或彈窗
    }
  }

  void _logout() async {
    await _auth.signOut();
  }

  bool isEmail(String input) {
    // 正則表達式匹配電子郵件地址的模式
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );

    return emailRegExp.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登入註冊範例'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            onChanged: (value) {
              _email = value.trim();
            },
            decoration: const InputDecoration(
              labelText: '電子郵件',
            ),
          ),
          TextField(
            obscureText: true,
            onChanged: (value) {
              _password = value.trim();
            },
            decoration: const InputDecoration(
              labelText: '密碼',
            ),
          ),
          ElevatedButton(
            onPressed: _register,
            child: const Text('註冊'),
          ),
          ElevatedButton(
            onPressed: _login,
            child: const Text('登入'),
          ),
          ElevatedButton(
            onPressed: _logout,
            child: const Text('登出'),
          ),
        ],
      ),
    );
  }
}
