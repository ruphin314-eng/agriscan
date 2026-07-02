package apash.coding.sa.dto;

import java.util.List;

public class ConversationResponse {
    private Integer id;
    private String titre;
    private String saison;
    private String dateCreation;
    private List<MessageDto> messages;

    public ConversationResponse(Integer id, String titre,
                                String saison, String dateCreation,
                                List<MessageDto> messages) {
        this.id = id;
        this.titre = titre;
        this.saison = saison;
        this.dateCreation = dateCreation;
        this.messages = messages;
    }

    public Integer getId() { return id; }
    public String getTitre() { return titre; }
    public String getSaison() { return saison; }
    public String getDateCreation() { return dateCreation; }
    public List<MessageDto> getMessages() { return messages; }
}