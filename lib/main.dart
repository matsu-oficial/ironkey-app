import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ironkey/app_theme.dart';
import 'package:ironkey/models/password_complexity.dart';
import 'package:ironkey/password_generator.dart';
import 'package:ironkey/pin_password_generator.dart';
import 'package:ironkey/standard_password_generator.dart';

void main() {
  runApp(IronKeyApp());
}

class IronKeyApp extends StatelessWidget {
  const IronKeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      title: "IronKey",
      home: IronKeyScreen(),
    );
  }
}

class IronKeyScreen extends StatefulWidget {
  const IronKeyScreen({super.key});

  @override
  State<IronKeyScreen> createState() => _IronKeyScreenState();
}

class _IronKeyScreenState extends State<IronKeyScreen> {
  final TextEditingController _passwordController = TextEditingController();

  PasswordType passwordSelectedType = PasswordType.pin;
  bool isEditable = false;

  bool includeUppercase = false;
  bool includeLowercase = false;
  bool includeNumbers = false;
  bool includeSymbols = false;
  int passwordLength = 16;

  PasswordComplexity selectedComplexity = PasswordComplexity.low;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void copyPassword(String password) {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Senha copiada!')));
  }

  void generatePassword() {
    late final PasswordGenerator generator;

    switch (passwordSelectedType) {
      case PasswordType.pin:
        generator = PinPasswordGenerator();
        break;
      case PasswordType.standard:
        generator = StandardPasswordGenerator(
          includeLowercase: includeLowercase,
          includeUppercase: includeUppercase,
          includeNumbers: includeNumbers,
          includeSymbols: includeSymbols
        );
        break;
    }

    setState(() {
      _passwordController.text = generator.generate(passwordLength);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    ClipOval(
                      child: Container(
                        color: Colors.red,
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: Image.asset(
                            "assets/images/ironman-logo.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Sua senha como você nunca viu!!!",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      enabled: isEditable,
                      controller: _passwordController,
                      maxLength: 16,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        prefix: Icon(Icons.lock),
                        suffix: _passwordController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  copyPassword(_passwordController.text);
                                },
                                icon: Icon(Icons.copy),
                              )
                            : null,
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Tipo de senha"),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            value: PasswordType.pin,
                            groupValue: passwordSelectedType,
                            title: Text("Pin"),
                            onChanged: (value) {
                              setState(() {
                                passwordSelectedType = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            value: PasswordType.standard,
                            groupValue: passwordSelectedType,
                            title: Text("Senha padrão"),
                            onChanged: (value) {
                              setState(() {
                                passwordSelectedType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Divider(color: colorScheme.outline),

                    Row(
                      children: [
                        Icon(isEditable ? Icons.lock_open : Icons.lock),
                        SizedBox(width: 8),
                        Expanded(child: Text("Permitir editar a senha?")),
                        Switch(
                          value: isEditable,
                          onChanged: (value) {
                            setState(() {
                              isEditable = value;
                            });
                          },
                        ),
                      ],
                    ),

                    Divider(color: colorScheme.outline),
                    const SizedBox(height: 20),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            DropdownButtonFormField<PasswordComplexity>(
                              value: selectedComplexity,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Complexidade da senha',
                                border: OutlineInputBorder(),
                              ),
                              items: PasswordComplexity.values.map((
                                complexity,
                              ) {
                                return DropdownMenuItem(
                                  value: complexity,
                                  child: Text(complexity.title),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedComplexity = value!;
                                  passwordLength = selectedComplexity.length;
                                });
                              },
                            ),
                            if (isEditable) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Tamanho da senha $passwordLength"),
                              ),

                              Slider(
                                value: passwordLength.toDouble(),
                                min: 4,
                                max: 16,
                                onChanged: (value) {
                                  setState(() {
                                    passwordLength = value.toInt();
                                  });
                                  generatePassword();
                                },
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: CheckboxListTile(
                                      value: includeUppercase,
                                      onChanged: (value) {
                                        setState(() {
                                          includeUppercase = value ?? false;
                                        });
                                      },
                                      title: Text("Maiúsculas"),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  ),
                                  Expanded(
                                    child: CheckboxListTile(
                                      value: includeLowercase,
                                      onChanged: (value) {
                                        setState(() {
                                          includeLowercase = value ?? false;
                                        });
                                      },
                                      title: Text("Minusculas"),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: CheckboxListTile(
                                      value: includeNumbers,
                                      onChanged: (value) {
                                        setState(() {
                                          includeNumbers = value ?? false;
                                        });
                                      },
                                      title: Text("Números"),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  ),
                                  Expanded(
                                    child: CheckboxListTile(
                                      value: includeSymbols,
                                      onChanged: (value) {
                                        setState(() {
                                          includeSymbols = value ?? false;
                                        });
                                      },
                                      title: Text("Simbolos"),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: generatePassword,
                        child: Text("Gerar senha"),
                      ),
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
}

enum PasswordType { pin, standard }
