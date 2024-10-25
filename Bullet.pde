// Bullet class //
public class Bullet extends CanvasObject {
  float angle;
  float velocity;
  Tank owner;
  float damage;
  Integer id;

  // Sets the variables on creation //
  Bullet(float x, float y, float velocity, float angle, Tank owner, float damage) {
    super();
    this.id = super.getID();
    this.damage = damage;
    this.owner = owner;
    super.x = x;
    super.y = y;
    this.velocity = velocity;
    this.angle = angle;
    this.draw();
  }

  // Draws the bullet //
  void draw() {
    fill(owner.tankColor);
    ellipse(super.x, super.y, bulletScale, bulletScale);
  }

  // Does math and moves the bullet //
  void move() {
    super.x = super.x + cos(this.angle) * this.velocity;
    super.y = super.y + sin(this.angle) * this.velocity;
    float[][] collisionPoints = {{super.x-(bulletScale/2), super.y}, {super.x+(bulletScale/2), super.y}, {super.x, super.y-(bulletScale/2)}, {super.x, super.y+(bulletScale/2)}};
    if (super.checkCollision(collisionPoints, super.getSelf(), new boolean[]{true, false})) {
      gameBoard.bulletToSelfDestruct.add(this);
    }
  }

  // Add the bullet to the queue of destruction //
  void explode() {
    gameBoard.bulletList.remove(this.id);
  }

  // Checks to see if a point falls within the bullet //
  boolean checkCollision(float x, float y) {
    if (sqrt(pow(x-super.x, 2)+pow(y-super.y, 2))<bulletScale) {
      return true;
    }
    return false;
  }

  // Updates the variables of the bullet //
  void updateSelf(String[] data) {
    super.x = roundString(data[2]);
    super.y = roundString(data[3]);
    this.angle = roundString(data[4]);
  }
}
