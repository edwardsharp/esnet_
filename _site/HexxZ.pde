/**
 * Hexxing 
 * http://micronemez.com 
 *
 */
 
/**
 * An improvisation of Daniel Shiffman and of Craig Reynold's Boids program to simulate
 * the flocking behavior of birds. Each boid steers itself based on 
 * rules of avoidance, alignment, and coherence.
 * 
 * Click the mouse to add a new boid.
 */

Flock flock;

int nx = -10, ny = -10;
int cx = -10, cy = -10;

String message;



void setup() {
  
  sketch_width = displayWidth;
  sketch_height = displayHeight;

  size(sketch_width, sketch_height);
  
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 1; i++) {
    flock.addBoid(new Boid(width/2,height/2));
  }
}

void draw() {
  background(0);
  fill(#ff6600);
  flock.run();
  
  //dragg'r
  noStroke();
  
  cx += (nx-cx) / 10.0;
  cy += (ny-cy) / 10.0;
  //ellipse( cx, cy, 7, 7 );
  //text( message, cx+7.5, cy+2.5 );
    
}

void mousePressed(){
   //new boiiiiid!
   //need to account for 
    flock.addBoid(new Boid(constrain(mouseX,30,width-30), constrain(mouseY, 30, height-30)));
}
// The Boid class

class Boid {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  Boid(float x, float y) {
    acceleration = new PVector(0,0);
    velocity = new PVector(random(-1,1),random(-1,1));
    location = new PVector(x,y);
    //#TODO: external config.
    float maxr = random(0.9, 1.5);
    r = maxr;
    maxspeed = maxr;
    maxforce = random(0.01, 0.06);
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    //#TODO: external config.
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update location
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target,location);  // A vector pointing from the location to the target
    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  
  void render() {
    // Draw a hexagon rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    fill(#ff6600);
    stroke(#ff6600);
    pushMatrix();
    translate(location.x,location.y);
    rotate(theta);
    
    strokeWeight(6);
    strokeJoin(ROUND);
    strokeCap(ROUND);
    noFill();
    stroke(255,102,0);
    beginShape();
    int rad = 20;
     for (int rr=90; rr<=450; rr+=60) {
        vertex (rad*cos(radians(rr)),rad*sin(radians(rr)));
      }
    endShape();
    popMatrix();
  }

  // Wraparound?
  // bounce.
  void borders() {
//    if (location.x < -r) location.x = width+r;
//    if (location.y < -r) location.y = height+r;
//    if (location.x > width+r) location.x = -r;
//    if (location.y > height+r) location.y = -r;
    //acceleration.mult(0.9);
    
//    if (location.x < -r) {velocity.mult(random(-1, -0.5)); }
//    if (location.y < -r) {velocity.mult(random(-1, -0.5));}
//    if (location.x > width+r){ velocity.mult(random(-1, -0.5));}
//    if (location.y > height+r){ velocity.mult(random(-1, -0.5));}
    int buff = 30;
    if (location.x < buff) {velocity.mult(random(-1, -1.5)); }
    if (location.y < buff ) {velocity.mult(random(-1, -1.5));}
    if (location.x > width-buff){ velocity.mult(random(-1, -1.5));}
    if (location.y > height-buff){ velocity.mult(random(-1, -1.5));}   
    
    
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    //#TODO: external config.
    float desiredseparation = 55.0f;
    PVector steer = new PVector(0,0,0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(location,other.location);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location,other.location);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 150;
    PVector sum = new PVector(0,0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location,other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum,velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0,0);
    }
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 150;
    PVector sum = new PVector(0,0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location,other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.location); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the location
    } else {
      return new PVector(0,0);
    }
  }
}


// The Flock (a list of Boid objects)

class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

}
