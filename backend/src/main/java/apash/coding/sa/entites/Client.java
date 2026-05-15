package apash.coding.sa.entites;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "CLIENT")
public class Client {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String name;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String telephone;

    @Column(nullable = false)
    private String profil;

    @Column(nullable = false)
    private String password; // sera hashé avec BCrypt

    @Column
    private String photoUrl;

    @Column
    private LocalDateTime dateInscription;

    public Client() {}

    public Client(String name, String email, String telephone, String profil, String password) {
        this.name = name;
        this.email = email;
        this.telephone = telephone;
        this.profil = profil;
        this.password = password;
        this.dateInscription = LocalDateTime.now();
    }

    // Getters & Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }

    public String getProfil() { return profil; }
    public void setProfil(String profil) { this.profil = profil; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }

    public LocalDateTime getDateInscription() { return dateInscription; }
    public void setDateInscription(LocalDateTime d) { this.dateInscription = d; }
}