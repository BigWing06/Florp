import javax.swing.JOptionPane;
import processing.core.PApplet;
import processing.net.*;
localServer server;
String IP;
localClient client;

// Asks the user to enter the IP they want to connect to //
String getIP() {
  return JOptionPane.showInputDialog("Enter the connection IP");
}

// The client class //
class localClient extends Client {
  String ip;
  String inData;
  boolean clientSetup=false;
  int id;

  // Creates the Client, sets the ip variable, and sends a connection message to the server //
  localClient(PApplet parent, String ip, int port) {
    super(parent, ip, port);
    this.ip = ip;
    super.write("jfhkjshdfdhkjhdskjfdshkjff");
  }

  // This is looped on a consistant basis to check if information is being recieved //
  void checkConnection() {

    // If there is not a connection sends 'FLORP' to try to establish one //
    if (super.available()>0) {
      inData = super.readString();
    } else if (!activeConnection) {
      inData = "NO_RESPONSE";
      super.write("FLORP");
    } else {
      inData = "NO_RESPONSE";
    }

    // If data was sent, then process it; it takes in the board, tanks, bullets and creates them, then sends key presses //
    if (inData!="NO_RESPONSE") {
      String[] initialSplit = inData.split("@");
      String[] inDataSplit = initialSplit[initialSplit.length-1].split("%");
      if (activeConnection) {
        if (inDataSplit[0].equals("SERVER_LOOP_SEND")) {
          String[] canvasObjects = inDataSplit[1].split("!");
          ArrayList<Integer> ids = new ArrayList<Integer>();
          for (String obj : canvasObjects) {
            String[] splitObj = obj.split(",");
            ids.add(Integer.valueOf(splitObj[1]));
            if (splitObj[0].equals("tank")) {
              gameBoard.tankList.get(Integer.valueOf(splitObj[1])).updateSelf(splitObj);
            } else if (splitObj[0].equals("bullet")) {
              if (!(gameBoard.bulletList.keySet().contains(Integer.valueOf(splitObj[1])))) {
                Bullet newBullet = new Bullet(Float.valueOf(splitObj[2])/*x*/,
                  Float.valueOf(splitObj[3])/*y*/, 5 /*velocity*/, roundString(splitObj[4]), gameBoard.tankList.get(Integer.valueOf(splitObj[5])), 5 /*damage*/);
                gameBoard.bulletList.put(newBullet.id, newBullet);
                //create bullet
              } else {
                gameBoard.bulletList.get(Integer.valueOf(splitObj[1])).updateSelf(splitObj);
              }
            }
          }
          for (Integer i : gameBoard.bulletList.keySet()) {
            if (!ids.contains(i)) {
              gameBoard.bulletToSelfDestruct.add(gameBoard.bulletList.get(i));
            }
          }
          for (Integer i : gameBoard.tankList.keySet()) {
            if (!ids.contains(i)) {
              gameBoard.tankToSelfDestruct.add(gameBoard.tankList.get(i));
            }
          }
          String writeString = "";
          if (keyList.contains('w')) {
            writeString+="w";
          }
          if (keyList.contains('a')) {
            writeString+="a";
          }
          if (keyList.contains('s')) {
            writeString+="s";
          }
          if (keyList.contains('d')) {
            writeString+="d";
          }
          if (keyList.contains('c')) {
            writeString+="c";
          }
          super.write("@KEYS"+this.id+"!"+writeString);
        }
      } else {
        if (inDataSplit[0].equals("SERVER_INITIAL_SEND")) {
          String[] dataContents = inDataSplit[1].split("/LEVELINFO/");
          gameBoard.readBoardString(dataContents[0]);
          gameBoard.buildBoard();
          this.id = Integer.valueOf(dataContents[1]);
          for (String tank : gameBoard.tankContents) {
            new Tank(tank);
          }
          gameBoard.drawBoard();
          activeConnection = true;
        }
      }
    }
  }
} //Class

// Converts a hex string to an RGB color //
color hexToRGB(String hex) {
  HashMap<String, Integer> hexReference = new HashMap<>();
  hexReference.put("0", 0);
  hexReference.put("1", 1);
  hexReference.put("2", 2);
  hexReference.put("3", 3);
  hexReference.put("4", 4);
  hexReference.put("5", 5);
  hexReference.put("6", 6);
  hexReference.put("7", 7);
  hexReference.put("8", 8);
  hexReference.put("9", 9);
  hexReference.put("A", 10);
  hexReference.put("B", 11);
  hexReference.put("C", 12);
  hexReference.put("D", 13);
  hexReference.put("E", 14);
  hexReference.put("F", 15);
  hex = hex.substring(1);
  String[] hexList = hex.split("");
  int r = hexReference.get(hexList[0])*16+hexReference.get(hexList[1]);
  int g = hexReference.get(hexList[2])*16+hexReference.get(hexList[3]);
  int b = hexReference.get(hexList[4])*16+hexReference.get(hexList[5]);
  return color(r, g, b);
}

// The server class //
class localServer extends Server {

  // Creates the server and sends a confirmation message //
  localServer(PApplet pApp, int port) {
    super(pApp, port);
    JOptionPane.showMessageDialog(null, "Server started on "  + ":" +  "64444");
  }

  // Checks to see if it is recived keyboard presses from the client and then uses them to drive the tank //
  void checkKeys() {
    Client c = super.available();
    if (c!=null) {
      String input = c.readString();
      if (input.contains("@KEYS")) {
        //@KEYSid!WASDSPACE
        String splitInput = input.split("@KEYS")[input.split("@KEYS").length-1];
        Integer id = Integer.valueOf(splitInput.split("!")[0]);
        String keyPresses;
        if (splitInput.split("!").length>1) {
          keyPresses = splitInput.split("!")[1];
        } else {
          keyPresses = "";
        }
        if (gameBoard.tankList.keySet().contains(id)) {
          gameBoard.tankList.get(id).setMoveBools(keyPresses);
        }
      }
    }
  }

  // If there is a connection to a client send the data of what to display on the screen //
  void checkConnection() {
    Client c = super.available();
    if (!activeConnection && c!=null) {
      this.initialClientConnect();
      activeConnection = true;
    } else if (activeConnection) {
      sendScreenLoop();
    }
  }

  // Send the intial data to draw; This includes the board //
  void initialClientConnect() {
    gameBoard.playerAmount ++;
    Tank clientTank = new Tank(gameBoard.tankContents[1]);
    String[] levelComponents = levels[levelNum].split("\n");
    String[] tankComponents = levelComponents[1].split("/TANKSPLIT/");
    String tankString = "";
    for (int i=0; i<gameBoard.playerAmount; i++) {
      tankString += tankComponents[i];
      tankString += "/TANKSPLIT/";
    }
    /////***************************************////////////
    tankString+="/LEVELINFO/"+clientTank.id;
    tankString = tankString/*.substring(0, tankString.length()-1)*/;
    String sendString = levels[levelNum] + "\n" + tankString;
    super.write("@SERVER_INITIAL_SEND%"+sendString);
  }

  // Sends the data to loop through for the client to draw //
  void sendScreenLoop() {
    String sendString = "";
    for (Tank tank : gameBoard.tankList.values()) {
      String temp="!tank,"+tank.id+","+String.valueOf(tank.x)+","+String.valueOf(tank.y)+","+String.valueOf(tank.angle)+","+String.valueOf(tank.health);
      sendString+=temp;
    }
    for (Bullet bullet : gameBoard.bulletList.values()) {
      String temp="!bullet,"+bullet.id+","+String.valueOf(bullet.x)+","+String.valueOf(bullet.y)+","+String.valueOf(bullet.angle)+","+String.valueOf(bullet.owner.id);
      sendString+=temp;
    }
    sendString=sendString.substring(1);
    super.write("@SERVER_LOOP_SEND%"+sendString);
  }
}
