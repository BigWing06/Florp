// This is the class that all tanks and bullets are build of off //
public class CanvasObject {
  float x;
  float y;
  Integer id;

  // Sets the variables upon creation //
  CanvasObject() {
    this.id = mainID;
    mainID++;
    gameBoard.canvasObjectList.put(this.id, this);
  }

  // Checks and see if it is colliding with things //
  boolean checkCollision(float[][] collisionPoints, CanvasObject self, boolean[] collisionMode /*[Square, Tank]*/) {
    for (float[] point : collisionPoints) {
      if (collisionMode[0]) {
        for (BoardSquare square : gameBoard.boarderList) {
          if (square.checkCollision(point[0], point[1])) {
            return true;
          }
        }
      }
      if (collisionMode[1]) {
        for (Tank tank : gameBoard.tankList.values()) {
          if (tank.id-self.id!=0) {
            if (tank.checkSelfCollision(point[0], point[1])) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  //Returns itself (for getting data types of match correctly) //
  CanvasObject getSelf() {
    return this;
  }

  // Checks to see if there are more than one points colliding //
  boolean multipleCollisions(float[][] collisionPoints, CanvasObject self, boolean[] collisionMode) {
    int collisionCounter = 0;
    for (float[] point : collisionPoints) {
      if (this.checkCollision(new float[][]{point}, self, collisionMode)) {
        collisionCounter++;
      }
    }
    return collisionCounter > 1;
  }

  // Returns the ID of the object //
  Integer getID() {
    return this.id;
  }
}
