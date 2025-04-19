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
            SizedBox(height: 260, child: buildTopBar()),
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

                    return DragTarget<String>(
                      onAccept: (letter) {
                        viewModel.placeLetter(row, col, letter);
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
                                Center(
                                  child: Text(
                                    cell.letter,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
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
            const SizedBox(height: 24),
            buildLetterBar(viewModel),
            const SizedBox(height: 24),
            buildControlBar(),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  @override
  GameBoardViewModel viewModelBuilder(BuildContext context) {
    final model = GameBoardViewModel();
    model.initializeBoard();
    return model;
  }

  Widget buildTopBar() {
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
              Expanded(child: buildPlayerInfo(isLeft: true, username: "Sen", score: 35, bgColor: Colors.transparent)),
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('86', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
              ),
              Expanded(child: buildPlayerInfo(isLeft: false, username: "Rakip", score: 28, bgColor: Colors.transparent)),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPlayerInfo({required bool isLeft, required String username, required int score, required Color bgColor}) {
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
                  decoration: BoxDecoration(color: bgColor.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
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
            const Positioned(left: -6, top: -3, child: CircleAvatar(radius: 20, backgroundColor: Color(0xFF53C0C8), child: Icon(Icons.person, size: 16, color: Colors.white))),
          if (isLeft)
            Positioned(right: -2, top: 0, child: buildScoreBox(score)),
          if (!isLeft)
            const Positioned(right: -6, top: -3, child: CircleAvatar(radius: 20, backgroundColor: Color(0xFFF7681B), child: Icon(Icons.person, size: 16, color: Colors.white))),
          if (!isLeft)
            Positioned(left: -2, top: 0, child: buildScoreBox(score)),
        ],
      ),
    );
  }

  Widget buildScoreBox(int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF2C1655), borderRadius: BorderRadius.circular(20)),
      child: Text(
        score.toString(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget buildLetterBar(GameBoardViewModel viewModel) {
    List<String> letters = ['A', 'I', 'İ', 'L', 'T', 'R', 'N'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: letters.map((letter) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Draggable<String>(
                data: letter,
                feedback: Material(
                  color: Colors.transparent,
                  child: buildLetterTile(letter, viewModel, shadow: true),
                ),
                childWhenDragging: Opacity(opacity: 0.4, child: buildLetterTile(letter, viewModel)),
                child: buildLetterTile(letter, viewModel),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildLetterTile(String letter, GameBoardViewModel viewModel, {bool shadow = false}) {
    final point = viewModel.getLetterPoint(letter);

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
              boxShadow: shadow ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: Offset(2, 2))] : [],
            ),
          ),
          Center(
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B2F2F),
                shadows: [Shadow(color: Colors.white, blurRadius: 4, offset: Offset(1, 1))],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 6,
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

  Widget buildControlBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 12, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildGameButton(Icons.undo, "Geri Al", Colors.blueGrey),
          buildGameButton(Icons.shuffle, "Karıştır", Colors.amber.shade400),
          buildGameButton(Icons.refresh, "Pas (2)", Colors.deepOrangeAccent),
          buildGameButton(Icons.send, "Gönder", Colors.green.shade500),
          const Text("⏱ 00:35", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildGameButton(IconData icon, String label, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}