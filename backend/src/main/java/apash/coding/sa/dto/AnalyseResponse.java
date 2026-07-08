package apash.coding.sa.dto;

import java.util.List;

public class AnalyseResponse {

    private boolean estMais;
    private String saison;
    private String messagePrincipal;
    private List<MaladieDetectee> maladies;
    private List<String> risquesSaisonniers;
    private String questionSuivi; // "Voulez-vous les solutions ?"

    public AnalyseResponse() {}

    public AnalyseResponse(
            boolean estMais,
            String saison,
            String messagePrincipal,
            List<MaladieDetectee> maladies,
            List<String> risquesSaisonniers,
            String questionSuivi) {
        this.estMais = estMais;
        this.saison = saison;
        this.messagePrincipal = messagePrincipal;
        this.maladies = maladies;
        this.risquesSaisonniers = risquesSaisonniers;
        this.questionSuivi = questionSuivi;
    }

    // ── Getters & Setters ──────────────────────────────────
    public boolean isEstMais() { return estMais; }
    public void setEstMais(boolean estMais) { this.estMais = estMais; }

    public String getSaison() { return saison; }
    public void setSaison(String saison) { this.saison = saison; }

    public String getMessagePrincipal() { return messagePrincipal; }
    public void setMessagePrincipal(String messagePrincipal) { this.messagePrincipal = messagePrincipal; }

    public List<MaladieDetectee> getMaladies() { return maladies; }
    public void setMaladies(List<MaladieDetectee> maladies) { this.maladies = maladies; }

    public List<String> getRisquesSaisonniers() { return risquesSaisonniers; }
    public void setRisquesSaisonniers(List<String> risquesSaisonniers) { this.risquesSaisonniers = risquesSaisonniers; }

    public String getQuestionSuivi() { return questionSuivi; }
    public void setQuestionSuivi(String questionSuivi) { this.questionSuivi = questionSuivi; }

    // ── Classe interne : maladie détectée ─────────────────
    public static class MaladieDetectee {
        private String nom;
        private String nomScientifique;
        private double probabilite; // 0.0 à 1.0
        private String gravite;     // Faible / Modérée / Élevée
        private Treatment treatment; // ✅ Traitement fourni par crop.health

        public MaladieDetectee() {}

        public MaladieDetectee(String nom, String nomScientifique,
                               double probabilite, String gravite) {
            this.nom = nom;
            this.nomScientifique = nomScientifique;
            this.probabilite = probabilite;
            this.gravite = gravite;
        }

        public String getNom() { return nom; }
        public void setNom(String nom) { this.nom = nom; }

        public String getNomScientifique() { return nomScientifique; }
        public void setNomScientifique(String nomScientifique) { this.nomScientifique = nomScientifique; }

        public double getProbabilite() { return probabilite; }
        public void setProbabilite(double probabilite) { this.probabilite = probabilite; }

        public String getGravite() { return gravite; }
        public void setGravite(String gravite) { this.gravite = gravite; }

        public Treatment getTreatment() { return treatment; }
        public void setTreatment(Treatment treatment) { this.treatment = treatment; }
    }

    // ── Classe interne : traitement (biologique / chimique / prévention) ─────
    public static class Treatment {
        private List<String> biological;
        private List<String> chemical;
        private List<String> prevention;

        public Treatment() {}

        public Treatment(List<String> biological, List<String> chemical, List<String> prevention) {
            this.biological = biological;
            this.chemical = chemical;
            this.prevention = prevention;
        }

        public List<String> getBiological() { return biological; }
        public void setBiological(List<String> biological) { this.biological = biological; }

        public List<String> getChemical() { return chemical; }
        public void setChemical(List<String> chemical) { this.chemical = chemical; }

        public List<String> getPrevention() { return prevention; }
        public void setPrevention(List<String> prevention) { this.prevention = prevention; }
    }
}