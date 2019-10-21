ArrayList<particlesystem> particlesystems = new ArrayList<particlesystem>();
class particle{
  PShape p;
  PImage t;
  PVector pos;
  PVector dir;
  color col;
  float drag;
  float gravity;
  int lifetime;
  particle(PVector pos_, PVector dir_, float gravity_, float drag_, color col_, int lifetime_){
    pos = pos_.copy();
    dir = dir_.copy();
    gravity = gravity_;
    drag = drag_;
    col = col_;
    lifetime = lifetime_;
    t = createImage(1,1,RGB);
    t.loadPixels();
    t.pixels[0] = col_;
    t.updatePixels();
    p = createShape();
    p.beginShape(QUAD);
    p.noStroke();
    p.noFill();
    p.texture(t);
    p.emissive(255,255,255);
    p.vertex(0,0,0,0);
    p.vertex(1,0,1,0);
    p.vertex(1,1,1,1);
    p.vertex(0,1,0,1);
    p.endShape();
  }
  void move(){
    lifetime--;
    if(lifetime > 0){
      dir.x = lerp(dir.x,0,drag*0.016);
      dir.y = lerp(dir.y,0,drag*0.016);
      dir.z = lerp(dir.z,0,drag*0.016);
      dir.z -= gravity*0.016;
      pos.x+=dir.x;
      pos.y+=dir.y;
      pos.z+=dir.z;
      p.resetMatrix();
      p.rotateY(PI/2);
      p.rotateZ(radians(bearing(pos,player))+PI/2);
      p.translate(pos.x,pos.y,pos.z);
    }
  }
  void display(){
    if(lifetime > 0){
      d3.shape(p);
    }
  }
}

class particlesystem{
  particle[] particles;
  int lifetime;
  particlesystem(PVector pos, PVector dire, float gravity, float drag, color col, int count,int lifetime_,float var_,int lsv_){
    lifetime = lifetime_;
    particles = new particle[count];
    for(int i = 0; i < count; i++){
      PVector dir = dire.copy();
      particles[i] = new particle(pos,new PVector(dir.x+random(-var_,var_),dir.y+random(-var_,var_),dir.z+random(-var_,var_)),gravity,drag,col,int(lifetime-random(lsv_)));                       
    }
  }
  void updateparticles(){
    lifetime--;
    for(int i = 0; i < particles.length; i++){
      particles[i].move();
      particles[i].display();
    }
  }
}

void manageparticles(){
  for(int i = particlesystems.size()-1; i > -1; i--){
    particlesystem current = particlesystems.get(i);
    if(current.lifetime < 0){
      particlesystems.remove(i);
      continue;
    }
    current.updateparticles();
  }
}
