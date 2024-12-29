import 'package:flutter/material.dart';
import 'package:adventurize/components/small_card.dart';
import 'package:adventurize/components/title.dart';
import 'package:adventurize/database/db_helper.dart';
import 'package:adventurize/models/challenge_model.dart';
import 'package:adventurize/components/big_card.dart';

class ChallengesPage extends StatefulWidget {
  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  List<Challenge> challenges = [];
  Challenge? selectedChallenge; // To hold the selected challenge for BigCard

  @override
  void initState() {
    super.initState();
    _addDummyData();
    _fetchChallenges();
  }

  final db = DatabaseHelper();

  Future<void> _addDummyData() async {
    await db.insDemoData();
  }

  Future<void> _fetchChallenges() async {
    List<Challenge> data = await db.getChalls();
    setState(() {
      challenges = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              TitleWidget(
                icon: Icons.diamond,
                text: "Challenges",
              ),
              Expanded(
                child: challenges.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: challenges.length,
                        itemBuilder: (context, index) {
                          final challenge = challenges[index];
                          return SmallCard(
                            challenge: challenge,
                            onTap: () {
                              setState(() {
                                selectedChallenge =
                                    challenge; // Set the selected challenge
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
          // Display BigCard if a challenge is selected
          if (selectedChallenge != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedChallenge = null; // Close the BigCard
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: BigCard(
                      challenge: selectedChallenge!,
                      onClose: () {
                        setState(() {
                          selectedChallenge = null; // Close the BigCard
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
