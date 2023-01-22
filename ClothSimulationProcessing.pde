ArrayList<Mass> masses;
ArrayList<Spring> springs;
float constraintY = 100;
float damping = 1;
PVector wind = new PVector(0.1, 0);
float gravity = 1;


void setup() {
  size(800, 800);
  masses = new ArrayList<Mass>();
  springs = new ArrayList<Spring>();

  for (int y = 0; y < 10; y++) {
    for (int x = 0; x < 10; x++) {
      Mass m = new Mass(x*50+width / 4, y*50+25, 1);
      masses.add(m);
    }
  }
  
  for (int y = 0; y < 10; y++) {
        for (int x = 0; x < 10; x++) {
            if (x > 0) {
                Spring s = new Spring(masses.get(x + y*10), masses.get(x - 1 + y*10), 0.1);
                springs.add(s);
            }
            if (y > 0) {
                Spring s = new Spring(masses.get(x + y*10), masses.get(x + (y-1)*10), 0.1);
                springs.add(s);
            }
            if(x<9 && y<9){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x + 1 + (y+1)*10), 0.05);
                springs.add(s);
            }
            if(x>0 && y<9){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x - 1 + (y+1)*10), 0.05);
                springs.add(s);
            }
            if(x<9 && y>0){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x + 1 + (y-1)*10), 0.05);
                springs.add(s);
            }
            if(x>0 && y>0){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x - 1 + (y-1)*10), 0.05);
                springs.add(s);
            }
            if(x<8){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x + 2 + y*10), 0.01);
                springs.add(s);
            }
            if(x>1){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x - 2 + y*10), 0.01);
                springs.add(s);
            }
            if(y<8){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x + (y+2)*10), 0.01);
                springs.add(s);
            }
            if(y>1){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x + (y-2)*10), 0.01);
                springs.add(s);
            }
        }
    }


    for (int x = 0; x < 10; x++) {
        masses.get(x).isConstrained = true;
    }

}

void draw() {
  background(255);
  
  wind.x = map(noise(frameCount*0.01), 0, 1, -0.2, 0.2);
  wind.y = map(noise(10000 + frameCount*0.01), 0, 1, -0.2, 0.2);
  
  for (Mass m : masses) {
    m.applyForce(new PVector(0, gravity*m.mass));
    m.update();
    m.display();
  }
  for (Spring s : springs) {
    s.update();
    s.display();
  }
}



class Mass {
  PVector position;
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  float mass;
  boolean isConstrained = false;

  Mass(float x, float y, float m) {
    position = new PVector(x, y);
    mass = m;
  }
  
  void applyForce(PVector force) {
    if(isConstrained) return;
    acceleration.add(PVector.div(force, mass));
    acceleration.add(wind);
}

void update() {
    acceleration.add(PVector.mult(velocity,-damping));
    velocity.add(acceleration);
    position.add(velocity);
    if(isConstrained){
        position.y = constraintY;
        velocity.y = 0;
    }
    acceleration.mult(0);
}

  void display() {
    stroke(0);
    fill(175);
    ellipse(position.x, position.y, mass*10, mass*10);
  }
}


class Spring {
  Mass m1;
  Mass m2;
  float restLength;
  float k;

  Spring(Mass m1, Mass m2, float k) {
    this.m1 = m1;
    this.m2 = m2;
    this.k = k;
    restLength = PVector.dist(m1.position, m2.position);
  }

  void update() {
    PVector force = PVector.sub(m2.position, m1.position);
    float currentLength = force.mag();
    force.normalize();
    force.mult((currentLength - restLength) * k);
    m1.applyForce(force);
    m2.applyForce(force.mult(-1));
  }

  void display() {
    stroke(0);
    line(m1.position.x, m1.position.y, m2.position.x, m2.position.y);
  }
}
