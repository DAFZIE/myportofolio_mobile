/// Android emulator default; override with --dart-define=API_BASE_URL=...
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
