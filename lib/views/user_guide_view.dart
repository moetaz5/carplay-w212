import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/car_state.dart';

class UserGuideView extends StatelessWidget {
  const UserGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    final car = context.watch<CarState>();

    return Scaffold(
      backgroundColor: car.bgMain,
      appBar: AppBar(
        backgroundColor: car.bgHeader,
        elevation: car.isLightMode ? 1 : 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: car.accentBlue, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: car.accentBlue.withValues(alpha: car.isLightMode ? 0.15 : 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_book, color: car.accentBlue, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'GUIDE D\'UTILISATION',
              style: TextStyle(
                color: car.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Mode Clair / Sombre',
            icon: Icon(
              car.isLightMode ? Icons.light_mode : Icons.dark_mode,
              color: car.isLightMode ? const Color(0xFFD97706) : Colors.cyanAccent,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              car.toggleThemeMode();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Banner Welcome
          _buildWelcomeBanner(context, car),

          const SizedBox(height: 18),

          // Section 1: Branchement & Câble
          _buildGuideSection(
            car,
            stepNumber: '1',
            title: 'Branchement du Câble & Connexion',
            icon: Icons.cable,
            badgeText: 'CÂBLE OU SANS FIL',
            badgeColor: car.accentBlue,
            content: [
              _guideBullet(car, 'Mercedes W212 (NTG 4.5/4.7)', 'Connectez votre adaptateur Lightning/USB-C vers HDMI ou boîtier vidéo sur l\'entrée auxiliaire vidéo de la voiture.'),
              _guideBullet(car, 'Écran TV / Moniteur PC', 'Branchez directement le câble HDMI sur votre TV ou écran d\'ordinateur en Full HD ou 4K.'),
              _guideBullet(car, 'Détection Automatique', 'L\'application active immédiatement l\'écran externe dès que le signal vidéo est détecté.'),
            ],
          ),

          const SizedBox(height: 16),

          // Section 2: Autorisations Matérielles Réelles
          _buildGuideSection(
            car,
            stepNumber: '2',
            title: 'Autorisations iPhone & Capteurs Réels',
            icon: Icons.verified_user,
            badgeText: 'ZÉRO DONNÉE VIRTUELLE',
            badgeColor: car.isLightMode ? const Color(0xFF059669) : Colors.greenAccent,
            content: [
              _guideBullet(car, 'Position GPS Satellite', 'Permet de mesurer la vitesse réelle en KM/H, l\'altitude satellite et le cap.'),
              _guideBullet(car, 'Galerie & Vidéothèque', 'Permet de sélectionner vos vidéos réelles stockées sur votre iPhone pour les projeter sur l\'écran.'),
              _guideBullet(car, 'Microphone', 'Permet de déclencher les commandes vocales en direct.'),
              _guideBullet(car, 'Accéléromètre Physique', 'Mesure les forces G d\'accélération, de freinage et de virage en temps réel.'),
            ],
          ),

          const SizedBox(height: 16),

          // Section 3: Modes d'Affichage sur l'Écran
          _buildGuideSection(
            car,
            stepNumber: '3',
            title: 'Modes d\'Affichage & Projection',
            icon: Icons.dashboard,
            badgeText: '6 MODES DISPONIBLES',
            badgeColor: Colors.purpleAccent,
            content: [
              _guideBullet(car, 'AMG Telemetry', 'Compteurs haute performance avec vitesse GPS, compte-tours, puissance CH et G-mètre physique.'),
              _guideBullet(car, 'CarPlay 2.0 Split', 'Tableau de bord multi-widgets affichant la navigation satellite et le lecteur vidéo côte à côte.'),
              _guideBullet(car, 'Vidéos HD iPhone', 'Lecteur vidéo plein écran avec barre de progression et commandes de lecture.'),
              _guideBullet(car, 'Navigation Satellite', 'Carte GPS en direct avec vitesse autorisée et position en temps réel.'),
              _guideBullet(car, 'Diagnostics TPMS', 'Vérification en direct de la pression des pneus (BAR/PSI), température et tension batterie.'),
            ],
          ),

          const SizedBox(height: 16),

          // Section 4: Comment diffuser une vidéo
          _buildGuideSection(
            car,
            stepNumber: '4',
            title: 'Diffuser une Vidéo depuis l\'iPhone',
            icon: Icons.video_collection,
            badgeText: 'LECTURE HD',
            badgeColor: Colors.redAccent,
            content: [
              _guideBullet(car, 'Étape A', 'Sur la télécommande iPhone, appuyez sur "Choisir une vidéo iPhone".'),
              _guideBullet(car, 'Étape B', 'Sélectionnez un film, clip ou vidéo dans la galerie de votre téléphone.'),
              _guideBullet(car, 'Étape C', 'La vidéo démarre automatiquement en haute définition sur l\'écran de votre voiture ou TV.'),
              _guideBullet(car, 'Étape D', 'Contrôlez la lecture (Play, Pause, Avance rapide) directement depuis votre iPhone.'),
            ],
          ),

          const SizedBox(height: 16),

          // Section 5: Multi-Écran et Personnalisation
          _buildGuideSection(
            car,
            stepNumber: '5',
            title: 'Multi-Écran & Personnalisation',
            icon: Icons.palette,
            badgeText: 'CLAIR & SOMBRE',
            badgeColor: const Color(0xFFEA580C),
            content: [
              _guideBullet(car, 'Format Écran Cible', 'Sélectionnez votre type d\'écran (Mercedes W212 800x480, Tablette 4:3, TV 16:9, PC Ultra-Wide 21:9).'),
              _guideBullet(car, 'Thème Clair ☀️ / Sombre 🌙', 'Basculez entre le style clair éclatant de jour et le style stealth AMG de nuit.'),
              _guideBullet(car, 'Ambiance Lumineuse LED', 'Personnalisez les couleurs de l\'éclairage d\'ambiance (Cyber Blue, AMG Red, Solar Orange, etc.).'),
              _guideBullet(car, 'Profil Audio', 'Adaptez la restitution sonore (Burmester 3D Surround, Harman Kardon Logic7, AMG Performance).'),
            ],
          ),

          const SizedBox(height: 20),

          // FAQ Quick Card
          _buildFaqCard(context, car),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, CarState car) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: car.isLightMode
              ? [const Color(0xFFE0F2FE), const Color(0xFFF0FDF4)]
              : [const Color(0xFF1E2D4A), const Color(0xFF151D2A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: car.accentBlue.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: car.accentBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_car, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MERCEDES W212 CARPLAY SMART LINK',
                  style: TextStyle(
                    color: car.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transformez votre écran Mercedes, TV ou Tablette en un tableau de bord intelligent connecté à votre iPhone.',
                  style: TextStyle(color: car.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(
    CarState car, {
    required String stepNumber,
    required String title,
    required IconData icon,
    required String badgeText,
    required Color badgeColor,
    required List<Widget> content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: car.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: car.borderGlow),
        boxShadow: car.isLightMode
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: car.accentBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        stepNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, color: car.accentBlue, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: car.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: car.isLightMode ? 0.12 : 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(color: badgeColor, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...content,
        ],
      ),
    );
  }

  Widget _guideBullet(CarState car, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(Icons.check_circle, color: car.accentBlue, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: car.textSecondary, fontSize: 11, fontFamily: 'Roboto'),
                children: [
                  TextSpan(
                    text: '$title : ',
                    style: TextStyle(color: car.textPrimary, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard(BuildContext context, CarState car) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: car.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: car.borderGlow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 8),
              Text(
                'QUESTIONS FRÉQUENTES & CONSEILS',
                style: TextStyle(
                  color: car.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _faqItem(
            car,
            'Que faire si l\'écran indique "En attente du signal" ?',
            'Vérifiez que le câble HDMI / adaptateur est bien branché sur votre iPhone et sur l\'entrée vidéo du véhicule ou de votre TV.',
          ),
          _faqItem(
            car,
            'Comment avoir la vitesse GPS la plus précise ?',
            'Autorisez l\'accès à la localisation "Toujours" ou "Lorsque l\'app est active". Placez l\'iPhone sur un support pare-brise ou tableau de bord.',
          ),
          _faqItem(
            car,
            'Puis-je utiliser cette application sur ma TV de salon ?',
            'Oui ! Il suffit de brancher un câble HDMI ou d\'utiliser la recopie d\'écran AirPlay/Miracast pour transformer votre TV en écran multimédia.',
          ),
        ],
      ),
    );
  }

  Widget _faqItem(CarState car, String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q : $question',
            style: TextStyle(color: car.accentBlue, fontWeight: FontWeight.bold, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            'R : $answer',
            style: TextStyle(color: car.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
