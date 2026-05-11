// service/EmailService.java
package apash.coding.sa.service;

import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    private final JavaMailSender mailSender;

    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public void envoyerResetPassword(String email, String token) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(email);
        message.setSubject("Réinitialisation de votre mot de passe — Agriscan");
        message.setText(
            "Bonjour,\n\n" +
            "Vous avez demandé une réinitialisation de mot de passe.\n\n" +
            "Votre code de réinitialisation : " + token + "\n\n" +
            "Ce code expire dans 15 minutes.\n\n" +
            "Si vous n'avez pas fait cette demande, ignorez cet email.\n\n" +
            "— L'équipe Agriscan"
        );
        mailSender.send(message);
    }
}