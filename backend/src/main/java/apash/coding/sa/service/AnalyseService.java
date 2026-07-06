package apash.coding.sa.service;

import apash.coding.sa.dto.AnalyseResponse;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.net.URI;
import java.net.http.*;
import java.net.http.HttpRequest.BodyPublishers;
import java.time.Month;
import java.util.*;

@Service
public class AnalyseService {

    @Value("${crophealth.api.key}")
    private String apiKey;

    private static final String CROP_HEALTH_URL =
            "https://crop.kindwise.com/api/v1/identification";

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    // ── Mots-clés qui indiquent que c'est du maïs ──────────
    private static final List<String> MOTS_CLES_MAIS = List.of(
            "maize", "corn", "zea mays", "zea", "maïs",
            "mais", "corn leaf", "maize leaf"
    );

    // ── Risques par saison pour le maïs ────────────────────
    private static final Map<String, List<String>> RISQUES_PAR_SAISON = Map.of(
            "Printemps", List.of(
                    "🌱 Fonte des semis (Pythium) : humidité élevée au sol favorise la pourriture des jeunes plants",
                    "🪲 Vers gris : attaques nocturnes sur les plantules à la levée",
                    "🌧️ Excès d'eau : risque d'asphyxie racinaire lors des pluies abondantes",
                    "❄️ Gelées tardives : risque de brûlures des jeunes feuilles si températures < 0°C"
            ),
            "Été", List.of(
                    "🍄 Rouille commune (Puccinia sorghi) : pustules orange sur feuilles, favorisée par chaleur humide",
                    "🦗 Pyrale du maïs : chenilles qui creusent les tiges, affaiblissent la plante",
                    "🌿 Helminthosporiose (Exserohilum turcicum) : grandes taches grises allongées sur feuilles",
                    "💧 Stress hydrique : manque d'eau pendant la floraison réduit le rendement",
                    "🔥 Charbon des épis (Ustilago maydis) : tumeurs noires sur épis par temps chaud et sec"
            ),
            "Automne", List.of(
                    "🍂 Pourriture des tiges (Fusarium) : tiges fragiles, verse de la plante avant récolte",
                    "🤎 Anthracnose (Colletotrichum graminicola) : noircissement des tiges à maturité",
                    "🌫️ Pourriture des épis (Gibberella) : moisissures rosées sur épis, mycotoxines",
                    "🐛 Aflatoxines : contamination des grains par champignons en fin de saison sèche"
            ),
            "Hiver", List.of(
                    "❄️ Période de repos végétatif : pas de culture active mais risques de stock",
                    "🏚️ Pourriture des résidus de récolte : source d'inoculum pour la saison suivante",
                    "🐭 Rongeurs : dommages sur grains stockés",
                    "💨 Érosion éolienne : perte de sol agricole sans couverture végétale"
            )
    );

    // ── Analyser une image ─────────────────────────────────
    public AnalyseResponse analyserImage(MultipartFile image,
                                          Integer clientId) throws Exception {

        // 1. Encoder l'image en base64
        String imageBase64 = Base64.getEncoder()
                .encodeToString(image.getBytes());

        // 2. Construire la requête JSON pour crop.health
        String requestBody = objectMapper.writeValueAsString(Map.of(
                "images", List.of("data:image/jpeg;base64," + imageBase64),
                "latitude", 0.0,
                "longitude", 0.0
        ));

        // 3. Appeler l'API crop.health
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(CROP_HEALTH_URL))
                .header("Content-Type", "application/json")
                .header("Api-Key", apiKey)
                .POST(BodyPublishers.ofString(requestBody))
                .build();

        HttpResponse<String> response = httpClient.send(
                request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 201 && response.statusCode() != 200) {
            throw new RuntimeException(
                    "crop.health API error: " + response.body());
        }

        // 4. Parser la réponse
        JsonNode root = objectMapper.readTree(response.body());
        JsonNode result = root.path("result");

        // 5. Vérifier si c'est du maïs
        boolean estMais = verifierSiMais(result);

        if (!estMais) {
            throw new IllegalArgumentException(
                    "⚠️ Cette plante ne semble pas être du maïs. " +
                    "Veuillez photographier une feuille de maïs pour obtenir une analyse.");
        }

        // 6. Extraire les maladies détectées
        List<AnalyseResponse.MaladieDetectee> maladies =
                extraireMaladies(result);

        // 7. Détecter la saison automatiquement
        String saison = detecterSaison();

        // 8. Risques liés à la saison
        List<String> risques = RISQUES_PAR_SAISON.getOrDefault(
                saison, List.of());

        // 9. Construire le message principal
        String messagePrincipal = construireMessage(maladies, saison);

        return new AnalyseResponse(
                true,
                saison,
                messagePrincipal,
                maladies,
                risques,
                "Voulez-vous que je vous donne les solutions pour traiter ces problèmes ? 🌿"
        );
    }

    // ── Vérifier si la plante est du maïs ─────────────────
    private boolean verifierSiMais(JsonNode result) {
        // Chercher dans crop (type de culture)
        JsonNode crop = result.path("crop");
        if (!crop.isMissingNode()) {
            JsonNode suggestions = crop.path("suggestions");
            if (suggestions.isArray()) {
                for (JsonNode suggestion : suggestions) {
                    String name = suggestion.path("name")
                            .asText("").toLowerCase();
                    String scientific = suggestion
                            .path("scientific_name")
                            .asText("").toLowerCase();
                    double probability = suggestion
                            .path("probability").asDouble(0);

                    if (probability > 0.3) {
                        for (String mot : MOTS_CLES_MAIS) {
                            if (name.contains(mot) ||
                                scientific.contains(mot)) {
                                return true;
                            }
                        }
                    }
                }
            }
        }

        // Chercher aussi dans disease/pest (si la plante hôte est maïs)
        JsonNode disease = result.path("disease");
        if (!disease.isMissingNode()) {
            JsonNode suggestions = disease.path("suggestions");
            if (suggestions.isArray()) {
                for (JsonNode suggestion : suggestions) {
                    JsonNode hosts = suggestion.path("host");
                    if (hosts.isArray()) {
                        for (JsonNode host : hosts) {
                            String hostName = host.asText("").toLowerCase();
                            for (String mot : MOTS_CLES_MAIS) {
                                if (hostName.contains(mot)) {
                                    return true;
                                }
                            }
                        }
                    }
                }
            }
        }

        return false;
    }

    // ── Extraire les maladies détectées ───────────────────
    private List<AnalyseResponse.MaladieDetectee> extraireMaladies(
            JsonNode result) {

        List<AnalyseResponse.MaladieDetectee> maladies = new ArrayList<>();

        JsonNode disease = result.path("disease");
        if (disease.isMissingNode()) return maladies;

        JsonNode suggestions = disease.path("suggestions");
        if (!suggestions.isArray()) return maladies;

        for (JsonNode suggestion : suggestions) {
            double probabilite = suggestion.path("probability").asDouble(0);
            if (probabilite < 0.1) continue; // Ignorer < 10%

            String nom = suggestion.path("name").asText("Inconnue");
            String nomScientifique = suggestion
                    .path("scientific_name").asText("");

            // Déterminer la gravité selon la probabilité
            String gravite;
            if (probabilite >= 0.7) gravite = "Élevée 🔴";
            else if (probabilite >= 0.4) gravite = "Modérée 🟡";
            else gravite = "Faible 🟢";

            maladies.add(new AnalyseResponse.MaladieDetectee(
                    nom, nomScientifique, probabilite, gravite));
        }

        // Trier par probabilité décroissante
        maladies.sort((a, b) ->
                Double.compare(b.getProbabilite(), a.getProbabilite()));

        return maladies;
    }

    // ── Détecter la saison automatiquement ────────────────
    private String detecterSaison() {
        Month month = java.time.LocalDate.now().getMonth();
        return switch (month) {
            case MARCH, APRIL, MAY -> "Printemps";
            case JUNE, JULY, AUGUST -> "Été";
            case SEPTEMBER, OCTOBER, NOVEMBER -> "Automne";
            default -> "Hiver";
        };
    }

    // ── Construire le message principal ───────────────────
    private String construireMessage(
            List<AnalyseResponse.MaladieDetectee> maladies,
            String saison) {

        if (maladies.isEmpty()) {
            return "🌿 Bonne nouvelle ! Aucune maladie significative " +
                   "n'a été détectée sur votre plant de maïs. " +
                   "Votre culture semble en bonne santé pour la saison " +
                   saison + ".";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("🔍 Analyse terminée pour votre plant de maïs ")
          .append("(").append(saison).append(") :\n\n");

        for (int i = 0; i < maladies.size(); i++) {
            var m = maladies.get(i);
            sb.append(i + 1).append(". **").append(m.getNom()).append("**");
            if (!m.getNomScientifique().isEmpty()) {
                sb.append(" (").append(m.getNomScientifique()).append(")");
            }
            sb.append("\n   Probabilité : ")
              .append(Math.round(m.getProbabilite() * 100))
              .append("% | Gravité : ").append(m.getGravite())
              .append("\n\n");
        }

        return sb.toString();
    }
}
