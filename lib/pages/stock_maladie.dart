import 'package:flutter/material.dart';
import '../models/maladie.dart';
import 'detail_maladie.dart';

class StockPlante extends StatelessWidget {
  const StockPlante({Key? key}) : super(key: key);

  static final Map<String, List<Maladie>> stock = {
    "Maïs": [
      Maladie(
        nom: "Maladies fongiques : rouille, pourritures et taches",
        image: "assets/images/mais_en_fleur_2_.webp",
        description:
            " Les maladies fongiques comme la rouille et les pourritures représentent 80% des problèmes sanitaires du maïs. La rouille commune, reconnaissable à ses pustules orange-brun sur les feuilles, apparaît généralement en conditions humides et chaudes. Elle peut réduire la photosynthèse de 50% si elle n'est pas contrôlée.\n"
              """Les pourritures des tiges et des racines, causées par différents champignons comme Fusarium ou Pythium, attaquent la base de la plante. Ces maladies du maïs se manifestent par :
    - Un brunissement des tissus internes
    - Un affaiblissement de la tige
    - Une verse prématurée des plants
    - Des racines nécrosées et fragiles""",
        solution:
            "-  Choisissez des variétés hybrides résistantes aux pourritures et aux maladies foliaires.\n-  Pratiquez une rotation des cultures, en évitant le maïs consécutif, et travaillez le sol pour décomposer les résidus végétaux.\n-  Arrosez uniquement le matin pour réduire l'humidité prolongée autour des racines et favorisez un bon drainage du sol.\n-  Appliquez des fongicides naturels ou biologiques, comme Trichoderma spp. ou Pseudomonas fluorescens, en traitement des semences ou du sol.\n-  Pour les infections avancées, utilisez des fongicides ciblés (ex. : oxychlorure de cuivre) en complément d'une fertilisation adaptée (ex. : 80 kg/ha de MOP).\n-  Éliminez les plantes touchées pour limiter la propagation et désinfectez les racines saines avec du charbon actif ou du permanganate de potassium si repiquage nécessaire.",
      ),

      Maladie(
        nom: "Anthracnose",
        image: "assets/images/anthracnose_leaf.jpg",
        description:
            "L'anthracnose du maïs est une maladie cryptogamique qui affecte les cultures de maïs. Elle est due à une espèce de champignons du groupe des ascomycètes, Colletotrichum graminicola, qui se manifeste d'abord par des taches brunes sur la face inférieure des feuilles, puis qui s'étend dans les tiges et finit par provoquer la verse de la culture. Un climat chaud, humide et pluvieux favorise l'extension de cette maladie, contre laquelle il n'existe pas de traitement fongicide efficace.\nL'anthracnose du maïs s'attaque à la fois aux feuilles et aux tiges et se manifeste par des taches foliaires et par la pourriture de la tige.",
        solution:
            "Les applications de fongicides ne sont pas efficaces contre cette maladie. La lutte repose essentiellement su des méthodes préventives, par des pratiques culturales appropriées ou par le choix de cultivar résistants.\n-  Pratiques culturales : des labours profonds qui permettent d'enfouir les résidus de maïs limitent fortement les infections foliaires en début de croissance.\n-  Rotation culturale : une rotation des cultures laissant au moins deux années sans maïs, ni culture sensible à l'anthracnose, est recommandée, surtout lorsque l'on pratique le semis direct ou un labour léger.\n-  Fertilisation : un programme de fertilisation équilibré est nécessaire pour limiter le stress des plantes qui favorise la propagation de la maladie.",
      ),

      Maladie(
        nom: "Le Charbon de la panicule",
        image: "assets/images/le-charbon-du-mais.jpg",
        description:
            "L'abrûlure des feuilles et tiges du maïs, causée par Physoderma zeae-maydis (ou Physoderma maydis), est une maladie fongique affectant principalement les feuilles, gaines et tiges.\nLes symptômes apparaissent sous forme de petites taches rondes ou ovales (environ 6 mm), jaune pâle à brunâtres, souvent disposées en bandes alternées sur les feuilles du milieu de la plante ; elles peuvent fusionner et couvrir de larges zones.Des taches pourpres à noires ovales se forment sur la nervure centrale des feuilles, et les lésions touchent aussi les tiges, gaines foliaires et rarely les épis ; la maladie est favorisée par des étés chauds et humides (25-30°C, eau stagnante).",
        solution:
            "- Optez pour des variétés hybrides résistantes et pratiquez une rotation des cultures (évitez le maïs consécutif) pour réduire les résidus infectés dans le sol, où le champignon persiste jusqu'à 7 ans.\n-  Évitez les excès d'azote, drainez bien les champs pour limiter l'humidité prolongée, et enterrez les débris de récolte par un labour profond.\n\nAucun fongicide curatif n'est homologué ; la lutte repose sur la prévention culturelle et les semences saines.\nEn cas d'infestation, supprimez manuellement les plantes sévèrement touchées pour limiter la dissémination des sporanges par l'eau de pluie.",
      ),

      Maladie(
        nom: "Pourritures des racines et tiges (Fusarium, Pythium)",
        image: "assets/images/fusae1p-du-mais.jpg",
        description:
            "Les pourritures des racines et tiges du maïs, causées principalement par Fusarium spp. et Pythium spp., sont des maladies fongiques affectant les plantules, racines et parties basses des tiges, souvent en conditions humides et froides.",
        solution:
            "-  Appliquez des fongicides foliaires ou au sol (ex. : azoxystrobine, propiconazole pour Fusarium ; méfenoxam pour Pythium) dès les premiers symptômes, en alternant modes d'action pour éviter les résistances.\n-  Détruisez manuellement les plants gravement atteints et surveillez les mycotoxines (Fusarium) dans le grain pour la sécurité alimentaire.",
      ),

      Maladie(
        nom: "Maladie des stries du maïs (virus)",
        image: "assets/images/maize-leaf-streak-virus.jpg",
        description:
            "La maladie des stries du maïs est causée principalement par le virus de la striure du maïs (MSV, Maize Streak Virus), un geminivirus transmis par la cicadelle Cicadulina mbila.\nLes symptômes débutent par de petites taches chlorotiques à la base des jeunes feuilles, évoluant en stries fines, blanches à jaunes, parallèles aux nervures, couvrant parfois toute la feuille en cas d'infection précoce.La plante présente un nanisme, un retard de croissance, des inflorescences incomplètes et un faible remplissage des grains, avec des pertes de rendement jusqu\'à 100% selon la précocité de l\'attaque.",
        solution:
            "-  Plantez des variétés résistantes ou tolérantes au MSV et surveillez hebdomadairement les cicadelles vectrices dès la levée ; arrêtez la culture si plus de 5% des plants sont touchés.\n-  Détruisez les mauvaises herbes hôtes (sorgho,Panicum) autour des champs, pratiquez un désherbage précoce et utilisez des pièges à cicadelles ou des insecticides ciblés en début de saison.\n\nAucun traitement curatif n'existe contre ce virus ; la lutte repose sur le contrôle du vecteur (insecticides comme imidaclopride si infestation >10 cicadelles/m²).\nÉliminez et brûlez immédiatement les plants symptomatiques pour limiter la propagation.",
      ),
    ],


    "Manioc": [
      Maladie(
        nom: "Mosaïque",
        image: "assets/images/cassava-mosaic-disease-manioc-1561129470.jpg",
        description:
            "La mosaïque du manioc est une maladie virale grave affectant les cultures de manioc (Manihot esculenta), particulièrement en Afrique, en Inde et en Amérique centrale et du Sud, causant des pertes de rendement jusqu'à 70% ou plus. Elle est provoquée par des begomovirus comme l'African Cassava Mosaic Virus (ACMV) ou East African Cassava Mosaic Virus (EACMV), transmis principalement par la mouche blanche Bemisia tabaci et par boutures infectées. Les signes incluent une chlorose formant un motif en mosaïque jaune-vert pâle sur les feuilles, des déformations foliaires, un froissement, un rabougrissement des plants et une réduction des tubercules. Les symptômes apparaissent 3-5 semaines après infection, variant selon la variété et les conditions environnementales.",
        solution:
            "-  Utilisez exclusivement des boutures saines provenant de plants non infectés, idéalement certifiées et issues de champs témoins.\n-  Évitez les rotations courtes avec manioc et éliminez les plants infectés pour réduire les sources virales.\n-  Détruisez immédiatement les plants symptomatiques par arrachage et brûlage pour limiter la propagation.\n-  Appliquez des insecticides biologiques (ex. : azadirachtine, huile de neem) contre la mouche blanche en prévention précoce, sans excès pour éviter les résistances.",
      ),


      Maladie(
        nom: "Maladie à phytoplasme",
        image: "assets/images/cassava-phytoplasma-disease-manioc-1.jpg",
        description:
            "La maladie à phytoplasme du manioc, aussi appelée \"maladie du balai de sorcière\" (cassava witches' broom disease), est causée par des phytoplasmes (bactéries sans paroi cellulaire) vivant dans le phloème des tiges. Elle provoque une prolifération excessive de petites feuilles jaunes en forme de balai au sommet des plants, une activation de bourgeons dormants, un rabougrissement, des gonflements aux tiges basses, un enroulement foliaire, des motifs mouchetés vert-jaune et des racines fines, boisées avec fissures.",
        solution:
            "-  Utilisez uniquement du matériel végétal sain certifié et évitez le transport de boutures d'aires infestées.\n-  Ne plantez pas près de champs infectés et contrôlez les adventices hôtes alternatives.\n-  Plantez des variétés résistantes si disponibles et contrôlez les vecteurs insectes (cicadelles, cochenilles) par méthodes intégrées.",
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock des Plantes"),
        centerTitle: true,
      ),
      body: ListView(
        children: stock.entries.map((plante) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Titre plante
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  plante.key,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 🔹 Maladies (COLUMN)
              ...plante.value.map((maladie) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DetailMaladie(maladie: maladie),
                      ),
                    );
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.asset(
                            maladie.image,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            maladie.nom,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }
}
