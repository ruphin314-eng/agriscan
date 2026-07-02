package apash.coding.sa.controller;

import apash.coding.sa.service.AnalyseService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/analyse")
@CrossOrigin(origins = "*")
public class AnalyseController {

    private final AnalyseService analyseService;

    public AnalyseController(AnalyseService analyseService) {
        this.analyseService = analyseService;
    }

    // POST /api/analyse
    // Reçoit une image, appelle crop.health, retourne l'analyse
    @PostMapping
    public ResponseEntity<?> analyser(
            @RequestParam("image") MultipartFile image,
            @RequestParam(value = "clientId", required = false) Integer clientId) {
        try {
            var result = analyseService.analyserImage(image, clientId);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            // Image non reconnue comme maïs
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body("Erreur lors de l'analyse : " + e.getMessage());
        }
    }
}
