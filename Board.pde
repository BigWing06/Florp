// Variables used to create the levels //
color boardBgColor = color(96, 108, 56);
color boardWallColor = hexToRGB("#DCCEA2");
String[] tankColors = new String[]{"#AD231F", "#FFAD0A"};
String[] levels ={"11111111111111111111~10000000000000000001~10000000000000000001~10000000000000000001~10000000000000000001~10000000000111000001~10000000000000000001~10000000000000000001~10000000000000000001~10000000000111111101~10000000000000000001~10000000000000000001~10000000000000000001~10000000000000000001~10000111111100000001~10000000000100000001~10000000000000000001~10000000000000000001~10000000000000000001~11111111111111111111\n10~2~90~40~100~wasdc~"+tankColors[0]+"~100/TANKSPLIT/10~2~150~40~100~ijkln~"+tankColors[1]+"~100\nFlorp: Queue of Destruction Part One", "11111111111111111111~10000000000000000001~10000000000000000001~10000000000000000001~10000000000000000001~10000000000111000001~10000000000000000001~10000000000000000001~10000000000000000001~10000000000111111101~10000000000000000001~10011100000000000001~10000000000000001101~1000111100000000000001~10000111111100010001~10000001110100000001~10000000000000000001~10000000000011100001~10000000000000000001~11111111111111111111\n10~2~90~40~100~wasdc~"+tankColors[0]+"~100/TANKSPLIT/10~2~150~40~100~ijkln~"+tankColors[1]+"~100\nFlorp: Queue of Destruction Part Two"};

// The main gameboard class //
public class board {
  int playerAmount;
  String[] tankStarts;
  String[] boardLayout;
  int width;
  int height;
  String boardString;
  HashMap<Integer, CanvasObject> canvasObjectList;
  List<Bullet> bulletToSelfDestruct;
  List<Tank> tankToSelfDestruct;
  List<BoardSquare> squareList;
  List<BoardSquare> boarderList;
  HashMap<Integer, Tank> tankList;
  HashMap<Integer, Bullet> bulletList;
  String[] tankContents;
  int currentLevel;
  String[]levels;

  // Initiation function that  creates object lists //
  public board() {
    this.tankList = new HashMap<Integer, Tank>();
    this.bulletList = new HashMap<Integer, Bullet>();
    this.canvasObjectList = new HashMap<Integer, CanvasObject>();
  }

  // Reads in the level strings //
  void readBoardString(String boardString) {
    String[] boardContents = boardString.split("\n");
    this.boardLayout = boardContents[0].split("~");
    this.tankContents = boardContents[1].split("/TANKSPLIT/");
    this.height = boardLayout.length;
    this.width = boardLayout[0].length();
  }

  // Creates the board //
  void buildBoard() {
    GRIDSCALE = displayWidth/SIZEMOD;
    TANKSIZE=GRIDSCALE;
    bulletScale = GRIDSCALE/3;
    surface.setSize((int)GRIDSCALE*this.width, (int)GRIDSCALE*this.height);
    surface.setLocation(round((displayWidth/2)-(GRIDSCALE*this.width/2)), round((displayHeight/2)-(GRIDSCALE*this.height/2)));
    //surface.setLocation(0, 0);
    this.squareList = new ArrayList<>();
    this.boarderList = new ArrayList<>();
    this.bulletToSelfDestruct = new ArrayList<>();
    this.tankToSelfDestruct = new ArrayList<>();
    for (int x = 0; x < this.width; x++) {
      for (int y = 0; y < this.height; y++) {
        BoardSquare tempSquare = new BoardSquare(x, y, Integer.parseInt(this.boardLayout[y].substring(x, x + 1)));
        this.squareList.add(tempSquare);
        if (tempSquare.squareType == 1) {
          boarderList.add(tempSquare);
        }
      }
    }
  }

  // Draws every square, tank and bullet that is being used //
  void drawBoard() {
    for (BoardSquare square : gameBoard.squareList) {
      square.draw();
    }
    for (Tank tank : gameBoard.tankList.values()) {
      tank.draw();
    }
    for (Bullet bullet : gameBoard.bulletList.values()) {
      bullet.draw();
    }
  }
  void endGame() {
    gameRunning=false;
  }
}

// The board square class that is every tile in the game //
public class BoardSquare {
  int xPos;
  int yPos;
  int squareType;
  float collisionAngle;

  // Generates the visual for the tile //
  void draw() {
    noStroke();
    if (squareType == 0) {
      fill(boardBgColor);
    } else if (squareType == 1) {
      fill(boardWallColor);
    }
    rect(this.xPos, this.yPos, GRIDSCALE, GRIDSCALE);
  }

  // Checks to see if the coordinate being inputed is inside of the tile //
  boolean checkCollision(float x, float y) {
    if (x > this.xPos - GRIDSCALE / 2 && x < this.xPos + GRIDSCALE / 2) {
      if (y > this.yPos - GRIDSCALE / 2 && y < this.yPos + GRIDSCALE / 2) {
        return true;
      }
    }
    return false;
  }

  //  Generates the tile on creation //
  BoardSquare(int x, int y, int type) {
    this.xPos = x * GRIDSCALE + GRIDSCALE / 2;
    this.yPos = y * GRIDSCALE + GRIDSCALE / 2;
    this.squareType = type;
    draw();
  }
}
