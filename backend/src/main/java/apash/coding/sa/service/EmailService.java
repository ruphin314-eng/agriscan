package apash.coding.sa.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;
import java.util.Map;

@Service
public class EmailService {

    @Value("${mailjet.api.key}")
    private String mailjetApiKey;

    @Value("${mailjet.api.secret}")
    private String mailjetApiSecret;

    @Value("${mailjet.sender.email:agriscantech@gmail.com}")
    private String senderEmail;

    @Value("${mailjet.sender.name:Agriscan}")
    private String senderName;

    private final HttpClient httpClient = HttpClient.newHttpClient();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public void envoyerResetPassword(String email, String code) {
        try {
            // ── Construire le corps JSON attendu par Mailjet (API v3.1) ──
            Map<String, Object> message = Map.of(
                    "From", Map.of(
                            "Email", senderEmail,
                            "Name", senderName
                    ),
                    "To", List.of(
                            Map.of("Email", email)
                    ),
                    "Subject", "Réinitialisation de votre mot de passe — Agriscan",
                    "TextPart",
                    "Bonjour,\n\n" +
                            "Vous avez demandé une réinitialisation de mot de passe.\n\n" +
                            "Votre code de réinitialisation : " + code + "\n\n" +
                            "Ce code expire dans 15 minutes.\n\n" +
                            "Si vous n'avez pas fait cette demande, ignorez cet email.\n\n" +
                            "— L'équipe Agriscan"
            );

            Map<String, Object> body = Map.of("Messages", List.of(message));
            String jsonBody = objectMapper.writeValueAsString(body);

            // ── Authentification Basic (API Key : Secret Key) ──
            String credentials = mailjetApiKey + ":" + mailjetApiSecret;
            String encodedCredentials = Base64.getEncoder()
                    .encodeToString(credentials.getBytes(StandardCharsets.UTF_8));

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.mailjet.com/v3.1/send"))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Basic " + encodedCredentials)
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                    .build();

            HttpResponse<String> response = httpClient.send(
                    request, HttpResponse.BodyHandlers.ofString());

            // Mailjet renvoie 200 en cas de succès
            if (response.statusCode() != 200) {
                throw new RuntimeException(
                        "Erreur envoi email Mailjet : " + response.body());
            }

        } catch (Exception e) {
            throw new RuntimeException("Impossible d'envoyer l'email : " + e.getMessage());
        }
    }
}