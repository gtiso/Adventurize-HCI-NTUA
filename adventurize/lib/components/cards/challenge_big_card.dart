import 'package:adventurize/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:adventurize/models/challenge_model.dart';
import 'package:adventurize/utils/navigation_utils.dart';

class BigChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onClose;
  final User user;
  final int challStatus;

  const BigChallengeCard({
    required this.challenge,
    required this.onClose,
    super.key,
    required this.user,
    required this.challStatus,
  });

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.asset(
        challenge.photoPath ?? "assets/images/placeholder.png",
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      challenge.title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'SansitaOne',
        color: Colors.white,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      challenge.desc,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPointsInfo() {
    return Text(
      "Upload your picture to the app and earn ${challenge.points ?? 0} XP.",
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (challStatus == 0) {
            NavigationUtils.navigateToCamera(context, user, challenge);
          } else {
            NavigationUtils.navigateToMemoryHistory(context, user);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          challStatus == 0 ? "START CHALLENGE" : "VIEW MEMORIES",
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'SansitaOne',
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildImage(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                const SizedBox(height: 8),
                _buildDescription(),
                const SizedBox(height: 12),
                _buildPointsInfo(),
                const SizedBox(height: 16),
                _buildActionButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
