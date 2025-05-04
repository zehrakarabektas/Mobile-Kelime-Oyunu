import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/services.dart';
import 'game_board_viewmodel.dart';

class GameBoardView extends StackedView<GameBoardViewModel> {
  const GameBoardView({super.key});

  @override
  Widget builder(
    BuildContext context,
    GameBoardViewModel viewModel,
    Widget? child,
  ) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFF2A939F),
        body: Column(
          children: [
            SizedBox(height: 260, child: buildTopBar(viewModel)),
            Flexible(
              fit: FlexFit.loose,
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: viewModel.boardSize * viewModel.boardSize,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: viewModel.boardSize,
                  ),
                  itemBuilder: (context, index) {
                    int row = index ~/ viewModel.boardSize;
                    int col = index % viewModel.boardSize;
                    final cell = viewModel.board[row][col];
                    if (cell.isClosed == true) {
                      return Padding(
                        padding: const EdgeInsets.all(1),
                        child: buildClosedTile(cell.letter, cell.score),
                      );
                    }

                    return DragTarget<Map<String, dynamic>>(
                      onAcceptWithDetails: (details) async {
                        final incomingData = details.data;
                        final character = incomingData['character'];
                        final letterId = incomingData['letterId'];
                        final score = incomingData["score"];
                        final fromRow = incomingData['fromRow'];
                        final fromCol = incomingData['fromCol'];

                        if (fromRow != null && fromCol != null) {
                          viewModel.removeLetter(fromRow, fromCol);
                        }

                        if (viewModel.board[row][col].letter.isEmpty) {
                          if (score == 0) {
                            final selected =
                                await viewModel.selectJokerLetter(context);
                            if (selected == null) return;

                            viewModel.jokerOverrides[letterId] = selected;
                            viewModel.placeLetter(
                                row, col, selected, score, letterId);
                          } else {
                            viewModel.placeLetter(
                                row, col, character, score, letterId);
                          }
                        }

                        viewModel.notifyListeners();
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: viewModel.intToBonusColor(cell.bonusCode),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Stack(
                            children: [
                              if (cell.letter.isEmpty)
                                Center(
                                  child: Text(
                                    viewModel.intToBonusText(cell.bonusCode),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              if (cell.letter.isNotEmpty)
                                Positioned.fill(
                                  child: Builder(
                                    builder: (context) {
                                      final isValid = cell.isWord;

                                      return Draggable<Map<String, dynamic>>(
                                        data: {
                                          'letterId': cell.letterId,
                                          'character': cell.letter,
                                          'score': cell.score,
                                          'fromRow': row,
                                          'fromCol': col,
                                        },
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: buildPlacedTile(
                                              cell.letter,
                                              cell.score,
                                              isWord: isValid,
                                            ),
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.3,
                                          child: buildPlacedTile(
                                            cell.letter,
                                            cell.score,
                                            isWord: isValid,
                                          ),
                                        ),
                                        child: buildPlacedTile(
                                          cell.letter,
                                          cell.score,
                                          isWord: isValid,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              if (viewModel.BolgeYasagiActive &&
                                  viewModel.userId == viewModel.turnUserId &&
                                  col < 8)
                                Positioned.fill(
                                  child: Image.asset(
                                    'lib/assets/images/buzCercevesi.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            buildBonusBar(viewModel),
            buildLetterBar(viewModel),
            const SizedBox(height: 12),
            buildControlBar(viewModel),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  @override
  GameBoardViewModel viewModelBuilder(BuildContext context) {
    return GameBoardViewModel();
  }

  @override
  void onViewModelReady(GameBoardViewModel viewModel) {
    viewModel.initializeBoard();
    viewModel.fetchGamerLetters();
    viewModel.fetchUserRewards();
    viewModel.gamesLettersToBoard();
    viewModel.initSignalR();
    if (viewModel.turnUserId == viewModel.userId) {
      viewModel.startTimer();
    }
  }

  Widget buildTopBar(GameBoardViewModel viewModel) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Image.asset(
          'lib/assets/images/oyunboardsayfalogo.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: buildPlayerInfo(
                    isLeft: true,
                    username: viewModel.usersName,
                    score: viewModel.usersScore,
                    bgColor: Colors.transparent),
              ),
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  (viewModel.gameLetterCount).toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: buildPlayerInfo(
                    isLeft: false,
                    username: viewModel.rivalName,
                    score: viewModel.rivalScore,
                    bgColor: Colors.transparent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPlayerInfo(
      {required bool isLeft,
      required String username,
      required int score,
      required Color bgColor}) {
    return SizedBox(
      width: 160,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      color: bgColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.center,
                  child: Text(
                    username,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLeft)
            const Positioned(
                left: -6,
                top: -3,
                child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF53C0C8),
                    child: Icon(Icons.person, size: 16, color: Colors.white))),
          if (isLeft)
            Positioned(right: -2, top: 0, child: buildScoreBox(score)),
          if (!isLeft)
            const Positioned(
                right: -6,
                top: -3,
                child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFF7681B),
                    child: Icon(Icons.person, size: 16, color: Colors.white))),
          if (!isLeft)
            Positioned(left: -2, top: 0, child: buildScoreBox(score)),
        ],
      ),
    );
  }

  Widget buildScoreBox(int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: const Color(0xFF2C1655),
          borderRadius: BorderRadius.circular(20)),
      child: Text(
        score.toString(),
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget buildLetterBar(GameBoardViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: 48,
        child: DragTarget<Map<String, dynamic>>(
          onAcceptWithDetails: (details) {
            final data = details.data;
            final letterId = data['letterId'];

            if (data.containsKey('fromRow') && data.containsKey('fromCol')) {
              final fromRow = data['fromRow'];
              final fromCol = data['fromCol'];

              viewModel.removeLetter(fromRow, fromCol);
              viewModel.usedLetterIndexes.remove(letterId);
              viewModel.notifyListeners();
            }
          },
          builder: (context, candidateData, rejectedData) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: viewModel.letterObjects.asMap().entries.map((entry) {
                final index = entry.key;
                final letterObj = entry.value;
                final letterId = letterObj['letterId'];
                final character = letterObj['character'];
                final score = letterObj['score'];

                final isUsed = viewModel.usedLetterIndexes.contains(letterId);
                final HarfYasak = viewModel.harfYasagi.contains(index);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: isUsed
                      ? const SizedBox(width: 50)
                      : HarfYasak
                          ? Stack(
                              children: [
                                buildLetterTile(character, score),
                                Positioned.fill(
                                  child: Image.asset(
                                    'lib/assets/images/buzCercevesi.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            )
                          : Draggable<Map<String, dynamic>>(
                              data: {
                                'letterId': letterId,
                                'character': character,
                                'score': score,
                              },
                              feedback: Material(
                                color: Colors.transparent,
                                child: buildLetterTile(character, score,
                                    shadow: true),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.4,
                                child: buildLetterTile(character, score),
                              ),
                              child: buildLetterTile(character, score),
                            ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget buildLetterTile(String letter, int score, {bool shadow = false}) {
    final isJoker = letter.toUpperCase() == 'JOKER';
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF5E8D3),
                  Color(0xFFE0C8A7),
                  Color(0xFFB88B5B),
                  Color(0xFF7A5C3E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
              border: Border.all(color: Color(0xFF5C3B26), width: 1.2),
              boxShadow: shadow
                  ? [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(2, 2))
                    ]
                  : [],
            ),
          ),
          Center(
            child: isJoker
                ? Image.asset('lib/assets/images/joker.png',
                    width: 32, height: 32)
                : Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B2F2F),
                      shadows: [
                        Shadow(
                            color: Colors.white,
                            blurRadius: 4,
                            offset: Offset(1, 1))
                      ],
                    ),
                  ),
          ),
          Positioned(
            top: 4,
            right: 6,
            child: Text(
              score.toString(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildControlBar(GameBoardViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 12, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildGameButton(
            Icons.undo,
            "Geri Al",
            Colors.blueGrey,
            onPressed: () {
              debugPrint("Geri Al butonuna tıklandı");
            },
          ),
          buildGameButton(
            Icons.refresh,
            "Pas",
            Colors.deepOrangeAccent,
            badgeCount: viewModel.usersPassCount,
            badgeCountPassbutton: true,
            onPressed: () {
              viewModel.userPassTurn();
            },
          ),
          buildGameButton(
            Icons.flag,
            "Teslim Ol",
            Colors.amber.shade400,
            onPressed: () {
              debugPrint("Teslim Ol butonuna tıklandı");
              viewModel.userSurrender();
            },
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.sendWordButton();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade500,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 3,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.send, size: 20, color: Colors.white),
                SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: viewModel.userId == viewModel.turnUserId,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer, color: Colors.white70, size: 14),
                          SizedBox(width: 4),
                          Text(
                            viewModel.leftTimeString,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.goToGameHome();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 3,
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.exit_to_app, size: 20, color: Colors.white),
                SizedBox(height: 4),
                Text(
                  "Çıkış",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGameButton(IconData icon, String label, Color color,
      {int? badgeCount,
      required VoidCallback onPressed,
      bool badgeCountPassbutton = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (badgeCount != null && badgeCount > 0 || badgeCountPassbutton)
          Positioned(
            right: 0,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 182, 0, 0),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 3,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildPlacedTile(String letter, int point, {bool isWord = false}) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF5E8D3),
            Color(0xFFE0C8A7),
            Color(0xFFB88B5B),
            Color(0xFF7A5C3E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
        border: Border.all(
          color: isWord ? Colors.green : Colors.red,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(2, 2))
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B2F2F),
                shadows: [
                  Shadow(
                      color: Colors.white, blurRadius: 4, offset: Offset(1, 1))
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Text(
              point.toString(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildClosedTile(String letter, int point) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF5E0),
            Color(0xFFEFE2CC),
            Color(0xFFD4BA96),
            Color.fromARGB(255, 180, 153, 118),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B2F2F),
                shadows: [
                  Shadow(
                    color: Colors.white,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Text(
              point.toString(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBonusBar(GameBoardViewModel viewModel) {
    final oduller = viewModel.aktifOdulSay;
    final bonuses = [
      {
        'type': 'ekstraHamle',
        'imagePath': 'lib/assets/images/ekstrahamle2.png',
        'count': oduller['ekstraHamle'] ?? 0,
      },
      {
        'type': 'bolgeYasagi',
        'imagePath': 'lib/assets/images/bolgeyasagi2.png',
        'count': oduller['bolgeYasagi'] ?? 0,
      },
      {
        'type': 'harfYasagi',
        'imagePath': 'lib/assets/images/harfyasagi2.png',
        'count': oduller['harfYasagi'] ?? 0,
      },
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: bonuses.map((bonus) {
          final int count = bonus['count'] as int;
          final String imagePath = bonus['imagePath'] as String;
          final String type = bonus['type'] as String;
          final bool isDisabled = count == 0;
          final bool isSelected = viewModel.isBonusSelected(type);

          return GestureDetector(
            onTap: () {
              if (!isDisabled) {
                viewModel.UserSelectBonus(type);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Container(
                      width: 70,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                            color: Color(0xFFE6BE8A),
                            width: 2), // Şampanya rengi
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFE6BE8A)
                                .withOpacity(0.6), // Şampanya gölgesi
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  Transform.scale(
                    scale: isSelected ? 0.92 : 1.0,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Opacity(
                          opacity: isDisabled ? 0.4 : 1.0,
                          child: Image.asset(
                            imagePath,
                            width: 70,
                            height: 40,
                          ),
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDisabled
                                  ? Colors.grey
                                  : const Color.fromARGB(255, 182, 0, 0),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 3,
                                  offset: const Offset(1, 1),
                                )
                              ],
                            ),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
