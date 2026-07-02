package apash.coding.sa.controller;

import apash.coding.sa.dto.*;
import apash.coding.sa.service.ConversationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/conversations")
@CrossOrigin(origins = "*")
public class ConversationController {

    private final ConversationService conversationService;

    public ConversationController(ConversationService conversationService) {
        this.conversationService = conversationService;
    }

    // POST /api/conversations ← créer une conversation
    @PostMapping
    public ResponseEntity<?> creer(
            @RequestBody ConversationRequest request) {
        try {
            return ResponseEntity.ok(
                    conversationService.creerConversation(request));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // POST /api/conversations/{id}/messages ← ajouter un message
    @PostMapping("/{id}/messages")
    public ResponseEntity<?> ajouterMessage(
            @PathVariable Integer id,
            @RequestBody MessageDto dto) {
        try {
            return ResponseEntity.ok(
                    conversationService.ajouterMessage(id, dto));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // GET /api/conversations/client/{clientId} ← historique
    @GetMapping("/client/{clientId}")
    public ResponseEntity<?> getHistorique(
            @PathVariable Integer clientId) {
        try {
            return ResponseEntity.ok(
                    conversationService.getHistorique(clientId));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // GET /api/conversations/{id} ← détail d'une conversation
    @GetMapping("/{id}")
    public ResponseEntity<?> getConversation(
            @PathVariable Integer id) {
        try {
            return ResponseEntity.ok(
                    conversationService.getConversation(id));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // DELETE /api/conversations/{id} ← supprimer
    @DeleteMapping("/{id}")
    public ResponseEntity<?> supprimer(@PathVariable Integer id) {
        try {
            conversationService.supprimer(id);
            return ResponseEntity.ok("Conversation supprimée");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}