// entites/PasswordResetToken.java
package apash.coding.sa.entites;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "PASSWORD_RESET_TOKEN")
public class PasswordResetToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(unique = true, nullable = false)
    private String token;

    @Column(nullable = false)
    private String email;

    @Column(nullable = false)
    private LocalDateTime expiration; // expire dans 15 minutes

    public PasswordResetToken() {}

    public PasswordResetToken(String token, String email) {
        this.token = token;
        this.email = email;
        this.expiration = LocalDateTime.now().plusMinutes(15);
    }

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(this.expiration);
    }

    // Getters & Setters
    public Integer getId() { return id; }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public LocalDateTime getExpiration() { return expiration; }
    public void setExpiration(LocalDateTime expiration) { this.expiration = expiration; }
}