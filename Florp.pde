/*********************************
 
 Florp: Queue of Destruction
 V1
 David Goldfuss and Joshua Harroff
 
 *********************************/

// This file is the main game loop //
import java.util.*;

int levelNum;
int GRIDSCALE=30;
boolean activeClient=false;
boolean activeConnection=false;
float TANKSIZE =GRIDSCALE;
int SIZEMOD = 70;
List<Character>keyList=new ArrayList<>();
float bulletScale=10;
Integer mainID = 0;
Menu activeMenu;
boolean gameRunning;
int gameMode;
board gameBoard;

// Resets the  main game variables //
void resetVars() {
  gameRunning=false;
}

// Resst the game to the begininng //
void resetToStart() {
  //loadBoard();
  resetVars();
  activeMenu = createMainMenu();
}

// Check the game mode and then runs the correct game creation function //
void gameSetup(int mode) {
  resetVars();
  rectMode(CENTER);
  gameBoard=new board();
  gameRunning = true;
  if (mode==0) {
    startLocalComp();
  } else if (mode == 1) {
    createNetworkGame();
  } else if (mode==2) {
    joinNetworkGame();
  }
}

// Run to create a new client class that will join a game //
void joinNetworkGame() {
  client = new localClient(this, getIP(), 64444);
}

// Creates a new network game, gameBoard, and server //
void createNetworkGame() {
  gameBoard.playerAmount = 1;
  gameBoard.readBoardString(levels[levelNum]);
  new Tank(gameBoard.tankContents[0]);
  gameBoard.buildBoard();
  server = new localServer(this, 64444);
}

// Starts a local game and board and creates all the tanks //
void startLocalComp() {
  gameBoard.playerAmount = 2;
  gameBoard.readBoardString(levels[levelNum]);
  gameBoard.buildBoard();
  for (String tank : gameBoard.tankContents) {
    new Tank(tank);
  }
  gameBoard.drawBoard();
}


// Main setup funcitons //
void settings() {
  GRIDSCALE = displayWidth/70;
  TANKSIZE=GRIDSCALE*.7;
  size(GRIDSCALE*20, GRIDSCALE*25);
}
void setup() {
  resetToStart();
}

// Loops through possible keys pressed and runs the appropriate functions //
void keyPressed() {
  if (activeMenu.running) {
    if (keyCode==UP) {
      activeMenu.up();
    }
    if (keyCode==DOWN) {
      activeMenu.down();
    }
    if (keyCode==ENTER) {

      activeMenu.running=false;
      if (activeMenu.name == "modeMenu") {
        gameMode = activeMenu.returnIndex();
        if (gameMode != 2) {
          activeMenu = createLevelMenu();
        } else {
          gameSetup(gameMode);
        }
      } else if (activeMenu.name == "levelMenu") {
        levelNum = activeMenu.returnIndex();
        gameSetup(gameMode);
      }
    }
  } else if (gameRunning) {
    if (!keyList.contains(key)) {
      keyList.add(key);
    }
  }
  if (key == 'r') {
    resetToStart();
  }
}

// If a key is released remove it from the KeyList //
void keyReleased() {
  int z=0;
  for (Character k : keyList) {
    if (k==key) {
      keyList.remove(z);
      break;
    }
    z++;
  }
}

// runs the correct main loop for each game mode //
void draw() {
  if (gameRunning) {
    if (gameMode==0) {
      localCompDraw();
    } else if (gameMode==1) {
      networkCompServerDraw();
    } else if (gameMode==2) {
      networkCompClientDraw();
    }
  }
}

// The main  draw that moves and exlodes the object; It also animates the board //
void mainDraw() {
  moveObjects();
  explodeObjects();
  gameBoard.drawBoard();
}

// Moves tanks and bullets //
void moveObjects() {
  for (Tank tank : gameBoard.tankList.values()) {
    tank.move();
  }
  for (Bullet bullet : gameBoard.bulletList.values()) {
    bullet.move();
  }
  for (Tank tank : gameBoard.tankList.values()) {
    tank.checkBulletCollision();
  }
}

// Checks to see if objects need to be removed //
void explodeObjects() {
  for (Bullet bullet : gameBoard.bulletToSelfDestruct) {
    bullet.explode();
  }
  gameBoard.bulletToSelfDestruct=new ArrayList<>();
  for (Tank tank : gameBoard.tankToSelfDestruct) {
    tank.explode();
  }
  gameBoard.tankToSelfDestruct=new ArrayList<>();
}

// Run for the local game //
void localCompDraw() {
  mainDraw();
}

// Run as the server //
void networkCompServerDraw() {
  server.checkKeys();
  mainDraw();
  server.checkConnection();
}

// Run as the client //
void networkCompClientDraw() {
  client.checkConnection();
  if (activeConnection) {
    explodeObjects();
    gameBoard.drawBoard();
  }
}
