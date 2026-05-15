// dto/ClientResponse.java  ← profil sans le password !
package apash.coding.sa.dto;

public class ClientResponse {
    private Integer id;
    private String name;
    private String email;
    private String telephone;
    private String profil;
    private String photoUrl;
    private String dateInscription;

    public ClientResponse(Integer id, String name, String email,
                          String telephone, String profil, String photoUrl, String dateInscription) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.telephone = telephone;
        this.profil = profil;
        this.photoUrl = photoUrl;
        this.dateInscription = dateInscription;
    }

    public Integer getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public String getTelephone() { return telephone; }
    public String getProfil() { return profil; }
    public String getPhotoUrl() { return photoUrl; }
    public String getDateInscription() { return dateInscription; }
}