ArrayList<Mass> masses;
ArrayList<Spring> springs;
ArrayList<Constraint> constraints;
float constraintY;
float damping = 0.98;
PVector wind = new PVector(0.1, 0);


void setup() {
  size(800, 800);
  masses = new ArrayList<Mass>();
  springs = new ArrayList<Spring>();

  for (int y = 0; y < 10; y++) {
    for (int x = 0; x < 10; x++) {
      Mass m = new Mass(x*50+25, y*50+25, 1);
      masses.add(m);
      if (x > 0) {
        Spring s = new Spring(m, masses.get(masses.size()-2), 0.1);
        springs.add(s);
      }
      if (y > 0) {
        Spring s = new Spring(m, masses.get(masses.size()-11), 0.1);
        springs.add(s);
      }
    }
    
    for (int x = 0; x < 10; x++) {
        masses.get(x).isConstrained = true;
    }
    
    constraintY = 25;
    
  }
  /*
  constraints = new ArrayList<Constraint>();
   for (int x = 0; x < 10; x++) {
      Constraint c = new Constraint(new PVector(x*50+25, 25), masses.get(x), 0);
      constraints.add(c);
  }
  */
}

void draw() {
  background(255);
  /*
  for (Constraint c: constraints) {
    c.applyConstraint();
  }
  */
  
  wind.x = map(noise(frameCount*0.01), 0, 1, -0.2, 0.2);
  wind.y = map(noise(1000+frameCount*0.01), 0, 1, -0.2, 0.2);
  
  for (Mass m : masses) {
    m.applyForce(new PVector(0, 0.1*m.mass));
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


/*
  void update() {
    if(isConstrained) return;
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
}
*/

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

class Constraint {
    PVector position;
    Mass mass;
    float restLength;

    Constraint(PVector position, Mass mass, float restLength) {
        this.position = position;
        this.mass = mass;
        this.restLength = restLength;
    }

    void applyConstraint() {
      PVector delta = PVector.sub(position, mass.position);
      PVector tempPosition = PVector.add(mass.position,mass.velocity);
      delta = PVector.sub(position, tempPosition);
      float deltaLength = delta.mag();
      float ratio = (deltaLength - restLength) / deltaLength;
      mass.position = PVector.add(tempPosition,PVector.mult(delta,ratio));
      mass.velocity = PVector.sub(mass.position,tempPosition);
  }

}
