// The tank class //
public class Tank extends CanvasObject {
  float bulletOffset;
  float angle;
  float velocity;
  int bulletSpeed;
  boolean canMove;
  boolean canLayMine;
  boolean canShoot;
  color tankColor;
  float maxHealth;
  float health;
  char[] controls;
  float lastShootTime;
  float bulletDelay;
  float speedMod;
  float bulletVelocity;
  float playerNum;
  float angularVelocity;
  int id;
  int startLocation;
  float shadeMod;
  boolean forward;
  boolean backward;
  boolean right;
  boolean left;
  boolean shoot;
  boolean isClient;

  // Sets the starting variables for the tank based off of the input string //
  Tank(String tankInputString) {
    super();
    this.id = super.getID();
    this.shadeMod=15;
    gameBoard.tankList.put(this.id, this);
    String[] tankParams = tankInputString.split("~");
    this.bulletVelocity = Float.parseFloat(tankParams[0]);
    this.speedMod = Float.parseFloat(tankParams[1]);
    this.startLocation = Integer.parseInt(tankParams[2]);
    this.maxHealth = Float.parseFloat(tankParams[4]);
    this.health = this.maxHealth;
    this.controls = tankParams[5].toCharArray();
    this.tankColor = hexToRGB(tankParams[6]);
    this.bulletDelay = Float.parseFloat(tankParams[7]);
    this.angle = 0;
    this.bulletOffset = 40;
    this.playerNum = gameBoard.tankList.size();
    this.lastShootTime = millis();
    super.x = (this.startLocation%gameBoard.height)*GRIDSCALE;
    super.y = floor(this.startLocation/gameBoard.height)*GRIDSCALE;
    this.velocity = 0;
    this.angularVelocity = 0;

    this.left=false;
    this.right=false;
    this.forward=false;
    this.backward = false;
    this.shoot=false;
    isClient = !(gameBoard.tankList.keySet().size() == 1 || gameMode == 0);
    if (isClient) {
      this.controls = new char[] {'w', 'a', 's', 'd', 'c'};
    }
    this.draw();
  }

  // Fires a bullet //
  void fire() {
    if (millis()-lastShootTime>this.bulletDelay) {
      Bullet newBullet = new Bullet(this.x + cos(this.angle) * this.bulletOffset/*x*/,
        this.y + sin(this.angle) * this.bulletOffset/*y*/, bulletVelocity /*velocity*/, this.angle, this, 5 /*damage*/);
      gameBoard.bulletList.put(newBullet.id, newBullet);
      lastShootTime=millis();
    }
  }

  // Sets the booleans that control movement //
  void setMoveBools(String inputs) {
    this.forward = inputs.contains(String.valueOf(this.controls[0]));
    this.left = inputs.contains(String.valueOf(this.controls[1]));
    this.backward = inputs.contains(String.valueOf(this.controls[2]));
    this.right = inputs.contains(String.valueOf(this.controls[3]));
    this.shoot = inputs.contains(String.valueOf(this.controls[4]));
  }

  // Moves the tank //
  void move() {
    float preAngle = this.angle;
    float[] prePos = {super.x, super.y};


    if (!isClient) {
      setMoveBools(String.valueOf(keyList));
    }
    if (this.shoot) {
      fire();
    }
    if (this.backward) {
      this.velocity = -1*speedMod;
    }
    if (this.left) {
      this.angularVelocity = -.05;
    }
    if (this.forward) {
      this.velocity = 2*speedMod;
    }
    if (this.right) {
      this.angularVelocity = .05;
    }
    if (!(this.forward) && !(this.backward)) {
      this.velocity = 0;
    }
    if (!this.left && !this.right) {
      this.angularVelocity = 0;
    }
    this.angle += this.angularVelocity;
    float[][] collisionList = this.getCollisionPoints(super.x, super.y);
    if (this.velocity==0&&this.angularVelocity!=0) {
      while (super.checkCollision(collisionList, super.getSelf(), new boolean[]{true, true})) {
        this.angle+=this.angularVelocity*-.1;
        collisionList = this.getCollisionPoints(super.x, super.y);
      }
    }
    if (this.velocity != 0) {

      if (super.multipleCollisions(this.getCollisionPoints(super.x+cos(this.angle)*this.velocity, super.y+sin(this.angle)*this.velocity), super.getSelf(), new boolean[] {true, true})&&degrees(preAngle)%90==0) {
        this.angle = preAngle;
      }
      super.x = super.x + cos(this.angle) * this.velocity;
      super.y = super.y + sin(this.angle) * this.velocity;

      collisionList = this.getCollisionPoints(super.x, super.y);
      while (super.checkCollision(collisionList, super.getSelf(), new boolean[]{true, true})) {
        if (super.multipleCollisions(collisionList, super.getSelf(), new boolean[]{true, true})) {
          this.angle = round(this.angle/(PI/2))*(PI/2);
        }
        //this.angle = round(this.angle/(PI/2))*(PI/2);
        super.x = super.x + cos(this.angle) * -.1 * this.velocity/abs(this.velocity);
        super.y = super.y + sin(this.angle) * -.1 * this.velocity/abs(this.velocity);
        collisionList = this.getCollisionPoints(super.x, super.y);
      }
    }
    if (super.x > width || super.x < 0 || super.y > height || super.y < 0) {
      this.angle = preAngle;
      super.x = prePos[0];
      super.y = prePos[1];
    }
    this.draw();
  }
  void checkBulletCollision() {
    for (Bullet bullet : gameBoard.bulletList.values()) {
      float[][] collisionPoints = this.getCollisionPoints(super.x, super.y);
      for (float[] point : collisionPoints) {
        if (bullet.checkCollision(point[0], point[1])) {
          this.health-=bullet.damage;
          gameBoard.bulletToSelfDestruct.add(bullet);
        }
      }
    }
    if (this.health<=0) {
      gameBoard.tankToSelfDestruct.add(this);
    }
  }
  boolean checkSelfCollision(float x, float y) {
    float[] rotatedPoint = {((x-super.x)*cos(-this.angle))-((y-super.y)*sin(-this.angle))+super.x, ((y-super.y)*cos(-this.angle))+((x-super.x)*sin(-this.angle))+super.y};
    if (rotatedPoint[0] > super.x-TANKSIZE*.8 && rotatedPoint[0]<super.x+TANKSIZE*.8) {
      if (rotatedPoint[1] > super.y-TANKSIZE*.8 && rotatedPoint[1]<super.y+TANKSIZE*.8) {
        return true;
      }
    }
    return false;
  }
  float[][] getCollisionPoints(float x, float y) {
    return new float[][] {
      new float[] {
        ((x - (x + TANKSIZE / 2)) * cos(this.angle)
        - (y - (y + TANKSIZE / 2)) * sin(this.angle)) + x,
        ((x - (x + TANKSIZE / 2)) * sin(this.angle)
        + (y - (y + TANKSIZE / 2)) * cos(this.angle)) + y },
      new float[] {
        ((x - (x - TANKSIZE / 2)) * cos(this.angle)
        - (y - (y + TANKSIZE / 2)) * sin(this.angle)) + x,
        ((x - (x - TANKSIZE / 2)) * sin(this.angle)
        + (y - (y + TANKSIZE / 2)) * cos(this.angle)) + y },
      new float[] {
        ((x - (x + TANKSIZE / 2)) * cos(this.angle)
        - (y - (y - TANKSIZE / 2)) * sin(this.angle)) + x,
        ((x - (x + TANKSIZE / 2)) * sin(this.angle)
        + (y - (y - TANKSIZE / 2)) * cos(this.angle)) + y },
      new float[] {
        ((x - (x - TANKSIZE / 2)) * cos(this.angle)
        - (y - (y - TANKSIZE / 2)) * sin(this.angle)) + x,
        ((x - (x - TANKSIZE / 2)) * sin(this.angle)
        + (y - (y - TANKSIZE / 2)) * cos(this.angle)) + y }, new float[]{x, y} };
  }

  // Draws the tank //
  void draw() {
    rectMode(CORNER);
    fill(150, 150, 150);
    rect(super.x-(TANKSIZE*1.25)/2, super.y-TANKSIZE-TANKSIZE*.25/2, TANKSIZE*1.25, TANKSIZE*.25);
    fill(tankColor);
    rect(super.x-(TANKSIZE*1.25)/2, super.y-TANKSIZE-TANKSIZE*.25/2, (this.health/this.maxHealth)*TANKSIZE*1.25, TANKSIZE*.25);
    rectMode(CENTER);
    pushMatrix();
    translate(super.x, super.y);
    rotate(this.angle + PI / 2);
    fill(this.tankColor);
    rect(0, 0, TANKSIZE, TANKSIZE);
    strokeWeight(.1*TANKSIZE);
    stroke(50);
    color darkTankColor = color(red(tankColor)+shadeMod, green(tankColor)+shadeMod, blue(tankColor)+shadeMod);
    fill(darkTankColor);
    rect(0, 0, TANKSIZE*.7, TANKSIZE*.7);
    stroke(50);
    strokeWeight(.15*TANKSIZE);
    line(0, TANKSIZE * -1, 0, 0);
    popMatrix();
    noStroke();
  }
  void explode() {
    gameBoard.tankList.remove(this.id);
    if (gameMode == 0) {
    }
  }

  // Updates the variables //
  void updateSelf(String[] data) {
    super.x = roundString(data[2]);
    super.y = roundString(data[3]);
    this.angle = roundString(data[4]);
    this.health = roundString(data[5]);
  }
}

// Rounds a string when it uses scientific notation and then converts it to a float //
Float roundString(String input) {
  if (input.contains("E")) {
    String[] inputSplit = input.split("E");
    return pow(Float.parseFloat(inputSplit[0]), Float.parseFloat(inputSplit[1]));
  } else {

    return Float.parseFloat(input);
  }
}
