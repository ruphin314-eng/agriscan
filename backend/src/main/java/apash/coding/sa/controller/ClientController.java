package apash.coding.sa.controller;

import apash.coding.sa.dto.ClientResponse;
import apash.coding.sa.entites.Client;
import apash.coding.sa.service.ClientService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/clients")
@CrossOrigin(origins = "*")
public class ClientController {

    private final ClientService clientService;

    public ClientController(ClientService clientService) {
        this.clientService = clientService;
    }

    // GET /api/clients/{id}
    @GetMapping("/{id}")
    public ResponseEntity<?> getProfil(@PathVariable Integer id) {
        try {
            Client client = clientService.lire(id);
            String date = client.getDateInscription() != null
                    ? client.getDateInscription().toLocalDate().toString()
                    : "Inconnue";

            return ResponseEntity.ok(
                    new ClientResponse(
                            client.getId(),
                            client.getName(),
                            client.getEmail(),
                            client.getTelephone(),
                            client.getProfil(),
                            client.getPhotoUrl(),
                            date
                    )
            );
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // PUT /api/clients/{id}
    @PutMapping("/{id}")
    public ResponseEntity<?> modifier(@PathVariable Integer id,
                                      @RequestBody Client client) {
        try {
            clientService.modifier(id, client);
            return ResponseEntity.ok("Profil mis à jour");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // DELETE /api/clients/{id}
    @DeleteMapping("/{id}")
    public ResponseEntity<?> supprimer(@PathVariable Integer id) {
        try {
            clientService.supprimer(id);
            return ResponseEntity.ok("Compte supprimé");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}