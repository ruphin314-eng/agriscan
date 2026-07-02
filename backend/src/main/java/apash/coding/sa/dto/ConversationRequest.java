package apash.coding.sa.dto;

import java.util.List;

public class ConversationRequest {
    private Integer clientId;
    private String titre;
    private String saison;
    private List<MessageDto> messages;

    public ConversationRequest() {}

    public Integer getClientId() { return clientId; }
    public void setClientId(Integer clientId) { this.clientId = clientId; }

    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }

    public String getSaison() { return saison; }
    public void setSaison(String saison) { this.saison = saison; }

    public List<MessageDto> getMessages() { return messages; }
    public void setMessages(List<MessageDto> messages) {
        this.messages = messages;
    }
}