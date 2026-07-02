package apash.coding.sa.controller;

import apash.coding.sa.entites.Client;
import apash.coding.sa.repository.ClientRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/clients")
@CrossOrigin(origins = "*")
public class ImageUploadController {

    private final ClientRepository clientRepository;

    // Dossier où sauvegarder les images (configurable dans application.properties)
    @Value("${upload.dir:uploads/photos}")
    private String uploadDir;

    // URL de base du serveur (configurable dans application.properties)
    @Value("${server.base-url:https://agriscan-backend-04bd.onrender.com}")
    private String baseUrl;

    public ImageUploadController(ClientRepository clientRepository) {
        this.clientRepository = clientRepository;
    }

    // POST /api/clients/{id}/photo
    @PostMapping("/{id}/photo")
    public ResponseEntity<?> uploadPhoto(
            @PathVariable Integer id,
            @RequestParam("file") MultipartFile file) {

        // ── Vérifications ──────────────────────────────────
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("Fichier vide");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return ResponseEntity.badRequest().body("Seules les images sont acceptées");
        }

        // Limite 5 Mo
        if (file.getSize() > 5 * 1024 * 1024) {
            return ResponseEntity.badRequest().body("Image trop volumineuse (max 5 Mo)");
        }

        try {
            // ── Créer le dossier si inexistant ─────────────
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // ── Nom de fichier unique ───────────────────────
            String extension = getExtension(file.getOriginalFilename());
            String fileName = "client_" + id + "_" + UUID.randomUUID() + extension;
            Path filePath = uploadPath.resolve(fileName);

            // ── Sauvegarder le fichier ──────────────────────
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            // ── Construire l'URL publique ───────────────────
            String photoUrl = baseUrl + "/uploads/photos/" + fileName;

            // ── Mettre à jour le client en base ────────────
            Client client = clientRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Client introuvable"));
            client.setPhotoUrl(photoUrl);
            clientRepository.save(client);

            return ResponseEntity.ok(Map.of(
                    "photoUrl", photoUrl,
                    "message", "Photo mise à jour avec succès"
            ));

        } catch (IOException e) {
            return ResponseEntity.internalServerError()
                    .body("Erreur lors de l'upload : " + e.getMessage());
        }
    }

    // ── Helper : extraire l'extension ──────────────────────
    private String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) return ".jpg";
        return filename.substring(filename.lastIndexOf(".")).toLowerCase();
    }
}
