class ApiConfig {
  static const String baseUrl =
      'https://agriscan-backend-04bd.onrender.com';

  // ── Auth ────────────────────────────────────────────────
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String forgotPassword = '$baseUrl/api/auth/forgot-password';
  static const String resetPassword = '$baseUrl/api/auth/reset-password';
  static const String changePassword = '$baseUrl/api/auth/change-password';
  static const String health = '$baseUrl/actuator/health';

  // ── Clients ─────────────────────────────────────────────
  static String client(int id) => '$baseUrl/api/clients/$id';

  // ✅ Upload photo profil
  static String uploadPhoto(int id) => '$baseUrl/api/clients/$id/photo';

  // ── Conversations ───────────────────────────────────────
  static const String conversations = '$baseUrl/api/conversations';
  static String historique(int clientId) =>
      '$baseUrl/api/conversations/client/$clientId';
  static String conversation(int id) => '$baseUrl/api/conversations/$id';
  static String ajouterMessage(int id) =>
      '$baseUrl/api/conversations/$id/messages';

  // ✅ Analyse image maïs
  static const String analyseImage = '$baseUrl/api/analyse';
}