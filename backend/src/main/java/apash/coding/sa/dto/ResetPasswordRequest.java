// dto/ResetPasswordRequest.java
package apash.coding.sa.dto;

public class ResetPasswordRequest {
    private String token;       // token reçu par email
    private String newPassword;

    public ResetPasswordRequest() {}

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
}