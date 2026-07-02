package apash.coding.sa.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@Service
public class EmailService {

    @Value("${brevo.api.key}")
    private String brevoApiKey;

    @Value("${brevo.sender.email:agriscantech@gmail.com}")
    private String senderEmail;

    @Value("${brevo.sender.name:Agriscan}")
    private String senderName;

    private final HttpClient httpClient = HttpClient.newHttpClient();

    public void envoyerResetPassword(String email, String code) {
        String body = """
            {
                "sender": {
                    "email": "%s",
                    "name": "%s"
                },
                "to": [{"email": "%s"}],
                "subject": "Réinitialisation de votre mot de passe — Agriscan",
                "textContent": "Bonjour,\\n\\nVous avez demandé une réinitialisation de mot de passe.\\n\\nVotre code de réinitialisation : %s\\n\\nCe code expire dans 15 minutes.\\n\\nSi vous n'avez pas fait cette demande, ignorez cet email.\\n\\n— L'équipe Agriscan"
            }
            """.formatted(senderEmail, senderName, email, code);

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.brevo.com/v3/smtp/email"))
                    .header("accept", "application/json")
                    .header("api-key", brevoApiKey)
                    .header("content-type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();

            HttpResponse<String> response = httpClient.send(
                    request,
                    HttpResponse.BodyHandlers.ofString()
            );

            if (response.statusCode() != 201) {
                throw new RuntimeException(
                        "Erreur envoi email Brevo : " + response.body()
                );
            }

        } catch (Exception e) {
            throw new RuntimeException("Impossible d'envoyer l'email : " + e.getMessage());
        }
    }
}