package apash.coding.sa.dto;

public class MessageDto {
    private String role;    // "user" ou "assistant"
    private String contenu;
    private String type;    // "text" ou "image"
    private String imageUrl;

    public MessageDto() {}

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getContenu() { return contenu; }
    public void setContenu(String contenu) { this.contenu = contenu; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}