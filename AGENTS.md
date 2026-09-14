# Repository instructions

- Nutze `@AppStorage` für einfache Einstellungen und Statuswerte, die in `UserDefaults` gespeichert werden, sofern dies technisch möglich ist. Greife nur direkt auf `UserDefaults` zu, wenn `@AppStorage` die Anforderungen nicht abdeckt.
- Teste standardmässig nur normale Debug Builds. Führe Release Builds nur aus, wenn der Nutzer dies ausdrücklich verlangt.
