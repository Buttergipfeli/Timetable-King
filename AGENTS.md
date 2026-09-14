# Repository instructions

- Use `@AppStorage` for simple settings and state values stored in `UserDefaults` whenever technically possible. Access `UserDefaults` directly only when `@AppStorage` does not meet the requirements.
- Test only regular Debug builds by default. Run Release builds only when the user explicitly requests it.
