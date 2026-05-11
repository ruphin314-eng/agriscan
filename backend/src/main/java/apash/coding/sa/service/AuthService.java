package apash.coding.sa.service;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import apash.coding.sa.dto.AuthResponse;
import apash.coding.sa.entites.Client;
import apash.coding.sa.entites.PasswordResetToken;
import apash.coding.sa.repository.ClientRepository;
import apash.coding.sa.repository.PasswordResetTokenRepository;

import java.util.UUID;

@Service
public class AuthService {

    private final ClientRepository clientRepository;
    private final PasswordResetTokenRepository tokenRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailService emailService;

    public AuthService(ClientRepository clientRepository,
                       PasswordResetTokenRepository tokenRepository,
                       BCryptPasswordEncoder passwordEncoder,
                       JwtService jwtService,
                       EmailService emailService) {
        this.clientRepository = clientRepository;
        this.tokenRepository = tokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.emailService = emailService;
    }

    // ── Register ──────────────────────────────────────────────
    public AuthResponse register(String name, String email,
                                 String telephone, String profil,
                                 String rawPassword) {
        if (clientRepository.existsByEmail(email)) {
            throw new RuntimeException("Email déjà utilisé");
        }

        Client client = new Client(name, email, telephone, profil,
                                   passwordEncoder.encode(rawPassword));
        clientRepository.save(client);

        String token = jwtService.generateToken(email);
        return new AuthResponse(client.getId(), token, client.getEmail(), client.getName());
    }

    // ── Login ─────────────────────────────────────────────────
    public AuthResponse login(String email, String rawPassword) {
        Client client = clientRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        if (!passwordEncoder.matches(rawPassword, client.getPassword())) {
            throw new RuntimeException("Mot de passe incorrect");
        }

        String token = jwtService.generateToken(email);
        return new AuthResponse(client.getId(), token, client.getEmail(), client.getName());
    }

    // ── Mot de passe oublié → envoie un code par email ───────
    @Transactional
    public void forgotPassword(String email) {
        // Vérifier que l'email existe
        clientRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("Aucun compte avec cet email"));

        // Supprimer les anciens tokens pour cet email
        tokenRepository.deleteByEmail(email);

        // Générer un code court à 6 chiffres (plus pratique sur mobile)
        String code = String.valueOf((int)(Math.random() * 900000) + 100000);

        // Sauvegarder en BDD
        tokenRepository.save(new PasswordResetToken(code, email));

        // Envoyer par email
        emailService.envoyerResetPassword(email, code);
    }

    // ── Reset mot de passe avec le code reçu par email ───────
    @Transactional
    public void resetPassword(String code, String newPassword) {
        PasswordResetToken resetToken = tokenRepository.findByToken(code)
            .orElseThrow(() -> new RuntimeException("Code invalide"));

        if (resetToken.isExpired()) {
            tokenRepository.delete(resetToken);
            throw new RuntimeException("Code expiré, veuillez recommencer");
        }

        // Mettre à jour le mot de passe
        Client client = clientRepository.findByEmail(resetToken.getEmail())
            .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        client.setPassword(passwordEncoder.encode(newPassword));
        clientRepository.save(client);

        // Supprimer le token utilisé
        tokenRepository.delete(resetToken);
    }

    // ── Changer mot de passe (utilisateur connecté) ───────────
    public void changePassword(String email, String oldPassword, String newPassword) {
        Client client = clientRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        if (!passwordEncoder.matches(oldPassword, client.getPassword())) {
            throw new RuntimeException("Ancien mot de passe incorrect");
        }

        client.setPassword(passwordEncoder.encode(newPassword));
        clientRepository.save(client);
    }
}