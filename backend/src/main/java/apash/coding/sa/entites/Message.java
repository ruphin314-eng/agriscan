package apash.coding.sa.entites;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "MESSAGE")
public class Message {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String role; // "user" ou "assistant"

    @Column(columnDefinition = "TEXT", nullable = false)
    private String contenu;

    @Column
    private String type; // "text" ou "image"

    @Column
    private String imageUrl; // URL de l'image si type = image

    @Column(nullable = false)
    private LocalDateTime dateEnvoi;

    @ManyToOne
    @JoinColumn(name = "conversation_id", nullable = false)
    private Conversation conversation;

    public Message() {}

    public Message(String role, String contenu,
                   String type, Conversation conversation) {
        this.role = role;
        this.contenu = contenu;
        this.type = type;
        this.conversation = conversation;
        this.dateEnvoi = LocalDateTime.now();
    }

    // Getters & Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getContenu() { return contenu; }
    public void setContenu(String contenu) { this.contenu = contenu; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public LocalDateTime getDateEnvoi() { return dateEnvoi; }
    public void setDateEnvoi(LocalDateTime d) { this.dateEnvoi = d; }

    public Conversation getConversation() { return conversation; }
    public void setConversation(Conversation c) { this.conversation = c; }
}