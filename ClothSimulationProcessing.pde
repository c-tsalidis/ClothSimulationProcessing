ArrayList<Mass> masses;
ArrayList<Spring> springs;
float constraintY = 100;
float damping = 5;
float structuralSpringConstant = 0.1;
float shearSpringConstant = 0.05;
float bendSpringConstant = 0.01;
PVector wind = new PVector(0.1, 0);
float gravity = 2;
ArrayList<Collider> colliders;
float dt = 0;
float prevTime = 0;
boolean allowStretch = false;


void setup() {
  size(800, 800);
  masses = new ArrayList<Mass>();
  springs = new ArrayList<Spring>();
  
  colliders = new ArrayList<Collider>();
  colliders.add(new Collider(200, 200, 100, 100));

  for (int y = 0; y < 10; y++) {
    for (int x = 0; x < 10; x++) {
      Mass m = new Mass(x*50+width / 4, y*50+25, 0.01);
      masses.add(m);
    }
  }
  
  for (int y = 0; y < 10; y++) {
        for (int x = 0; x < 10; x++) {
          // structural springs
            if (x > 0) {
                Spring s = new Spring(masses.get(x + y*10), masses.get(x - 1 + y*10), structuralSpringConstant);
                springs.add(s);
            }
            if (y > 0) {
                Spring s = new Spring(masses.get(x + y*10), masses.get(x + (y-1)*10), structuralSpringConstant);
                springs.add(s);
            }
            // shear springs
            if(x<9 && y<9){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x + 1 + (y+1)*10), shearSpringConstant);
                springs.add(s);
            }
            if(x>0 && y<9){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x - 1 + (y+1)*10), shearSpringConstant);
                springs.add(s);
            }
            if(x<9 && y>0){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x + 1 + (y-1)*10), shearSpringConstant);
                springs.add(s);
            }
            if(x>0 && y>0){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x - 1 + (y-1)*10), shearSpringConstant);
                springs.add(s);
            }
            // bend (flexion) springs
            if(x<8){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x + 2 + y*10), bendSpringConstant);
                springs.add(s);
            }
            if(x>1){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x - 2 + y*10), bendSpringConstant);
                springs.add(s);
            }
            if(y<8){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x + (y+2)*10), bendSpringConstant);
                springs.add(s);
            }
            if(y>1){
                Spring s = new Spring(masses.get(x + y*10), masses.get(x + (y-2)*10), bendSpringConstant);
                springs.add(s);
            }
        }
    }

    /*
    for (int x = 0; x < 10; x++) {
        masses.get(x).isConstrained = true;
    }
    */

    masses.get(0).isConstrained = true;
    masses.get(9).isConstrained = true;

}

void draw() {
  background(255);
  
  float currentTime = millis();
  float deltaTime = currentTime - prevTime; //time in milliseconds
  prevTime = currentTime;
  dt = deltaTime / 1000; // convert milliseconds to seconds
  //dt = 1.0 / frameRate;
  dt = 0.01;

  
  wind.x = map(noise(dt*0.01), 0, 1, -0.2, 0.2);
  wind.y = map(noise(dt*0.01), 0, 1, -0.2, 0.2);
  
  for (Mass m : masses) {
    /*
    for(Collider c: colliders) {
      
      c.position.x = mouseX;
      c.position.y = mouseY;
      if (c.collidesWith(m)) {
          PVector collisionNormal = PVector.sub(m.position, c.position);
          collisionNormal.normalize();
          collisionNormal.mult(0.1);
          PVector repulsion = PVector.mult(c.velocity, 0.1);
          m.applyForce(PVector.sub(repulsion, collisionNormal));
      }
      c.display();
    }
    */
    
    m.update(dt);
    m.applyForce(new PVector(0, gravity));
    m.update(dt);
    m.display();
    
  }
  for (Spring s : springs) {
    s.update(dt);
    s.display();
  }
}



class Mass {
  PVector position;
  PVector prevPosition;
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  float mass;
  boolean isConstrained = false;

  Mass(float x, float y, float m) {
    position = new PVector(x, y);
    prevPosition = new PVector(x, y);
    mass = m;
  }
  
  void applyForce(PVector force) {
    if(isConstrained) return;
    force.add(wind);
    acceleration.add(PVector.div(force, mass));
}

/*
void update(float dt) {
    acceleration.add(PVector.mult(velocity,-damping));
    velocity.add(acceleration);
    position.add(PVector.mult(velocity, dt));
    if(isConstrained){
        position.y = constraintY;
        velocity.y = 0;
    }
    acceleration.mult(0);
}
*/

void update(float dt) {
    PVector temp = new PVector(position.x, position.y);
    position.add(PVector.add(
      PVector.sub(position, prevPosition)
              //.mult(damping),
              ,
      PVector.mult(acceleration, dt * dt))
    );
    prevPosition = temp;
    acceleration.mult(0);
}


  void display() {
    stroke(0);
    fill(175);
    ellipse(position.x, position.y, mass*100, mass*100);
  }
}


class Spring {
  Mass m1;
  Mass m2;
  float restLength;
  float k;
  // boolean allowStretch;

  Spring(Mass m1, Mass m2, float k) {
    this.m1 = m1;
    this.m2 = m2;
    this.k = k;
    restLength = PVector.dist(m1.position, m2.position);
  }

  void update(float dt) {
    m1.update(dt);
    m2.update(dt);
    PVector force = PVector.sub(m2.position, m1.position);
    float currentLength = force.mag();
    
    // if(!allowStretch && currentLength < restLength) return;
    // if(!allowStretch) return;
    
    force.normalize();
    force.mult((currentLength - restLength) * k);
    force.mult(damping);
    m1.applyForce(force);
    m2.applyForce(force.mult(-1));
}

  void display() {
    stroke(0);
    line(m1.position.x, m1.position.y, m2.position.x, m2.position.y);
  }
}


class Collider {
  PVector position;
  PVector velocity;
  float width, height;

  Collider(float x, float y, float w, float h) {
    position = new PVector(x, y);
    width = w;
    height = h;
    velocity = new PVector(0,0);
  }

  boolean collidesWith(Mass m) {
    return (m.position.x > position.x && m.position.x < position.x + width &&
            m.position.y > position.y && m.position.y < position.y + height);
  }
  
  void update(float dt) {
    PVector prevPosition = position.copy(); //store the previous position
    position.x = mouseX;
    position.y = mouseY;
    velocity = PVector.sub(position, prevPosition);
    velocity.div(dt); //delta time is the time passed since the last frame
  }
  
  void display() {
    noStroke();
    fill(0);
    rect(position.x, position.y, width, height);
  }
}
