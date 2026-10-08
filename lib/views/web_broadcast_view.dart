import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/car_state.dart';

class WebBroadcastView extends StatelessWidget {
  const WebBroadcastView({super.key});

  @override
  Widget build(BuildContext context) {
    final car = context.watch<CarState>();

    return Scaffold(
      backgroundColor: car.bgMain,
      appBar: AppBar(
        backgroundColor: car.bgHeader,
        elevation: car.isLightMode ? 1 : 0,
        title: Text(
          'DIFFUSION PC, TV & CÂBLE',
          style: TextStyle(
            color: car.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: car.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. LIVE SERVER STATUS CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: car.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: car.isWebServerRunning ? car.accentGreen : car.accentRed,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (car.isWebServerRunning ? car.accentGreen : car.accentRed).withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (car.isWebServerRunning ? car.accentGreen : car.accentRed).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          car.isWebServerRunning ? Icons.wifi_tethering : Icons.portable_wifi_off,
                          color: car.isWebServerRunning ? car.accentGreen : car.accentRed,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.isWebServerRunning ? 'SERVEUR WEB LOCAL ACTIF' : 'SERVEUR ARRÊTÉ',
                              style: TextStyle(
                                color: car.isWebServerRunning ? car.accentGreen : car.accentRed,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${car.connectedWebClients} écran(s) PC / TV connecté(s)',
                              style: TextStyle(
                                color: car.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: car.bgCardSubtle,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: car.borderGlow),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SelectableText(
                            car.webServerUrl,
                            style: TextStyle(
                              color: car.accentBlue,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              fontFamily: 'RobotoMono',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: 'Copier l\'adresse',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: car.webServerUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Adresse URL copiée dans le presse-papier !'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_browser, size: 22),
                          tooltip: 'Ouvrir dans le navigateur',
                          onPressed: () async {
                            final uri = Uri.parse(car.webServerUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. HOW TO CONNECT ON PC / LAPTOP (USB or WI-FI)
            _buildSectionHeader(car, '1. CONNEXION SUR PC / MAC / TABLETTE / SMART TV', Icons.laptop_mac),
            const SizedBox(height: 12),
            _buildInstructionCard(
              car: car,
              stepNum: 'A',
              title: 'Par Câble USB (Partage de connexion)',
              description:
                  '1. Branchez votre iPhone au PC avec le câble USB.\n2. Sur votre iPhone, activez "Partage de connexion" (via USB).\n3. Sur votre PC, ouvrez Google Chrome / Edge et tapez :\n   http://172.20.10.1:8080 ou ${car.webServerUrl}\n4. L\'écran Mercedes W212 AMG s\'affiche immédiatement en plein écran 60 FPS synchronisé avec l\'iPhone !',
            ),
            const SizedBox(height: 12),
            _buildInstructionCard(
              car: car,
              stepNum: 'B',
              title: 'Par Wi-Fi (Sans fil)',
              description:
                  '1. Connectez votre PC/TV/Tablette au même réseau Wi-Fi que l\'iPhone (ou au partage Wi-Fi de l\'iPhone).\n2. Ouvrez le navigateur sur votre PC/TV et allez sur :\n   ${car.webServerUrl}\n3. Tout le tableau de bord est pilotable et synchronisé en temps réel.',
            ),

            const SizedBox(height: 24),

            // 3. MERCEDES W212 (2014) EXPLANATION
            _buildSectionHeader(car, '2. FONCTIONNEMENT SUR MERCEDES CLASSE E (W212 2014)', Icons.directions_car),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
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
                      Icon(Icons.info_outline, color: car.accentBlue, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pourquoi le câble USB d\'origine ne réagit pas sur W212 2014 ?',
                          style: TextStyle(
                            color: car.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sur les Mercedes W212 de 2014 équipées du système NTG 4.5 / 4.7 d\'origine :\n'
                    '• Apple CarPlay natif n\'existait pas encore en 2014 chez Mercedes (apparu fin 2015/2016 sur NTG 5.1).\n'
                    '• La prise USB sous l\'accoudoir ne transmet que la musique MP3 / iPod, pas de signal vidéo.',
                    style: TextStyle(
                      color: car.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    'Les 3 solutions pour utiliser cette application en voiture :',
                    style: TextStyle(
                      color: car.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSolutionItem(
                    car: car,
                    num: '1',
                    title: 'Mode Autonome sur Support (100% Gratuit & Recommandé)',
                    desc: 'Placez votre iPhone ou iPad en paysage sur un support tableau de bord. Passez l\'app en "Mode Écran Complet" : vous avez le compteur AMG avec vitesse GPS réelle, la carte satellite, la radio en direct et la télémétrie.',
                  ),
                  _buildSolutionItem(
                    car: car,
                    num: '2',
                    title: 'Câble Vidéo AUX / Media Interface',
                    desc: 'Utilisez un adaptateur Lightning vers HDMI/RCA branché sur la prise Media Interface Mercedes (dans la boîte à gants) et sélectionnez "AUX Vidéo" sur l\'écran NTG.',
                  ),
                  _buildSolutionItem(
                    car: car,
                    num: '3',
                    title: 'Boîtier Décodeur CarPlay W212 NTG 4.5',
                    desc: 'Si vous installez un boîtier décodeur CarPlay (ex: RoadTop / Carlinkit), l\'application se projette directement sur l\'écran d\'origine.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(CarState car, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: car.accentBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: car.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionCard({
    required CarState car,
    required String stepNum,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: car.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: car.borderGlow),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: car.accentBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              stepNum,
              style: TextStyle(
                color: car.accentBlue,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: car.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: car.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionItem({
    required CarState car,
    required String num,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: car.accentBlue,
              shape: BoxShape.circle,
            ),
            child: Text(
              num,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: car.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: car.textSecondary,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
