package apash.coding.sa.entites;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "CONVERSATION")
public class Conversation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String titre;

    @Column(nullable = false)
    private LocalDateTime dateCreation;

    @Column
    private String saison; // Printemps, Été, Automne, Hiver

    @ManyToOne
    @JoinColumn(name = "client_id", nullable = false)
    private Client client;

    @OneToMany(mappedBy = "conversation",
            cascade = CascadeType.ALL,
            orphanRemoval = true)
    @OrderBy("dateEnvoi ASC")
    private List<Message> messages;

    public Conversation() {}

    public Conversation(String titre, String saison, Client client) {
        this.titre = titre;
        this.saison = saison;
        this.client = client;
        this.dateCreation = LocalDateTime.now();
    }

    // Getters & Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }

    public LocalDateTime getDateCreation() { return dateCreation; }
    public void setDateCreation(LocalDateTime d) { this.dateCreation = d; }

    public String getSaison() { return saison; }
    public void setSaison(String saison) { this.saison = saison; }

    public Client getClient() { return client; }
    public void setClient(Client client) { this.client = client; }

    public List<Message> getMessages() { return messages; }
    public void setMessages(List<Message> messages) { this.messages = messages; }
}