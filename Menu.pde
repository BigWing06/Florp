// Function to create a new main menu //
Menu createMainMenu() {
  return new Menu("modeMenu",
    color(0, 0, 0)/*BG Color*/,
    color(255, 255, 255)/*Text Color*/,
    color(255, 255, 0)/*Highligh Color*/,
    30.0/*Font Size*/, "Welcome to Florp!",
    new String[] {"Competitive local", "Competitive network (Host)", "Competitive network (Join)"});
}

// Function to create a new level menu //
Menu createLevelMenu() {
  ArrayList<String> levelMenuList = new ArrayList<String>();

  for (String level : levels) {
    levelMenuList.add(level.split("\n")[2]);
  }
  String[] arr = new String[levelMenuList.size()];
  arr = levelMenuList.toArray(arr);
  return new Menu("levelMenu",
    color(0, 0, 0)/*BG Color*/,
    color(255, 255, 255)/*Text Color*/,
    color(255, 255, 0)/*Highligh Color*/,
    30.0/*Font Size*/, "Select One",
    arr);
}

// The menu class //
public class Menu {
  String name;
  String[] options;
  color textColor;
  color bgColor;
  Float startY;
  Float x = width*.025;
  Float lastY = height*.025;
  Float fontSize;
  boolean running=false;
  int index = 0;
  int maxLimit;
  int indexOffset=0;
  color highlightColor;
  String selectionText;

  // Sets the menu variables //
  Menu(String name, color backgroundColor, color textColor, color highlightColor, float fontSize, String selectionText, String[] options) {
    this.name = name;
    this.startY = ((width*.05)+(fontSize*1.5));
    this.textColor =textColor;
    this.highlightColor = highlightColor;
    this.bgColor = backgroundColor;
    this.options = options;
    this.fontSize = fontSize;
    this.selectionText = selectionText;
    maxLimit = (int)Math.floor((height-(((width*.05)+(fontSize*1.5))))/fontSize);
    this.build();
    this.running=true;
    surface.setLocation(round((displayWidth/2)-(width/2)), round((displayHeight/2)-(height/2)));
  }

  // Draws the menu and tries to find the next index //
  void build() {

    this.lastY=startY;
    fill(this.bgColor);
    background(this.bgColor);
    rect(0, 0, width, height);

    textSize(fontSize);
    textAlign(LEFT, TOP);

    if (index+1>(maxLimit+indexOffset)) {
      indexOffset+=1;
    } else if (index<maxLimit*indexOffset&&index+2<=options.length) {
      indexOffset-=1;
    }


    for (int i=0; i<maxLimit; i++) {
      if (i<options.length) {
        if (i+indexOffset==index) {
          fill(highlightColor);
        } else {
          fill(textColor);
        }

        text(options[i+indexOffset], x, lastY);
        lastY+=(float)fontSize;
      }
    }
    textSize(fontSize*1.5);
    fill(textColor);
    textAlign(LEFT, CENTER);
    text(selectionText, width/40, ((width*.05)+(fontSize*1.5))/2);
  }

  // Moves to the previous selected option //
  void up() {

    index-=1;
    if (index<0) {
      index=0;
    }
    this.build();
  }

  // Moves to the next selected object //
  void down() {
    index+=1;
    if (index>options.length-1) {
      index=options.length-1;
    }
    this.build();
  }

  // Returns the currently selected index //
  int returnIndex() {
    return index;
  }
}
