package apash.coding.sa.controller;

import apash.coding.sa.service.AnalyseService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/analyse")
@CrossOrigin(origins = "*")
public class AnalyseController {

    private static final int MIN_IMAGES = 2;
    private static final int MAX_IMAGES = 5;

    private final AnalyseService analyseService;

    public AnalyseController(AnalyseService analyseService) {
        this.analyseService = analyseService;
    }

    // POST /api/analyse
    // Reçoit 2 à 5 images (champ "images"), appelle crop.health en
    // UNE SEULE identification (1 crédit), retourne l'analyse.
    @PostMapping
    public ResponseEntity<?> analyser(
            @RequestParam("images") List<MultipartFile> images,
            @RequestParam(value = "clientId", required = false) Integer clientId) {

        if (images == null || images.size() < MIN_IMAGES) {
            return ResponseEntity.badRequest()
                    .body("Veuillez envoyer au moins " + MIN_IMAGES + " photos pour l'analyse.");
        }
        if (images.size() > MAX_IMAGES) {
            return ResponseEntity.badRequest()
                    .body("Maximum " + MAX_IMAGES + " photos par analyse.");
        }

        try {
            var result = analyseService.analyserImage(images, clientId);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            // Image(s) non reconnue(s) comme maïs
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body("Erreur lors de l'analyse : " + e.getMessage());
        }
    }
}