package apash.coding.sa.dto;

public class ConversationSummary {
    private Integer id;
    private String titre;
    private String saison;
    private String dateCreation;
    private int nombreMessages;

    public ConversationSummary(Integer id, String titre,
                               String saison, String dateCreation,
                               int nombreMessages) {
        this.id = id;
        this.titre = titre;
        this.saison = saison;
        this.dateCreation = dateCreation;
        this.nombreMessages = nombreMessages;
    }

    public Integer getId() { return id; }
    public String getTitre() { return titre; }
    public String getSaison() { return saison; }
    public String getDateCreation() { return dateCreation; }
    public int getNombreMessages() { return nombreMessages; }
}