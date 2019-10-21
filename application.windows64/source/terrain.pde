PGraphics d3;
int w = 500;
int radius = 225;
float scale = 8;
float rate = 4;
float depth = 100;
color grass = color(64, 227, 102);
color rock = color(122, 112, 103);
color snow = color(224, 221, 218);
float gh = 0;
float rh = 28;
float sh = 58;
PVector[] trees;
PShape fog;
class chunk{
  PShape terrain;
  chunk(PVector pos){
    float[][] values = new float[w+1][w+1];
    PImage texture = createImage(w+1,w+1,RGB);
    texture.loadPixels();
    for(int x = 0; x < w; x++){
      for(int y = 0; y < w; y++){
        values[x][y] = nval(pos.x/scale+x,pos.y/scale+y);
        int index = x + y * (w+1);
        if(values[x][y] < rh){
          texture.pixels[index] = color(red(grass)+random(-10,10),green(grass)+random(-30,30),blue(grass)+random(-30,30));
        }else if(values[x][y] >= rh && values[x][y] < sh){
          texture.pixels[index] = color(red(rock)+random(-5,5),green(rock)+random(-5,5),blue(rock)+random(-5,5));
        }else if(values[x][y] >= sh){
          texture.pixels[index] = color(red(snow)+random(-2,2),green(snow)+random(-2,2),blue(snow)+random(-2,2));
        }
      }
    }
    int index = (w) + (w) * (w+1);
    texture.pixels[index-1] = color(10,255,80);
    index = (w-1) + (w) * (w+1);
    texture.pixels[index-1] = color(117,59,0);
    for(int r = radius-50; r > radius-52; r--){
      for(float d = 0; d < 360; d+=0.25){
        int x = w/2 + int(r * cos(radians(d)));
        int y = w/2 + int(r * sin(radians(d)));
        index = x + y * (w+1);
        texture.pixels[index] = color(255,20,20);
      }
    }
    texture.updatePixels();
    terrain = createShape();
    terrain.beginShape(TRIANGLES);
    terrain.ambient(255,255,255);
    terrain.specular(255,255,255);
    terrain.textureMode(IMAGE);
    terrain.noFill();
    terrain.noStroke();
    terrain.texture(texture);
    for(int x = 0; x < w-1; x++){
      for(int y = 0; y < w-1; y++){
        if(dist(x,y,w/2,w/2) < radius){
          int index1 = x + y * (w+1);
          index1 = constrain(index1,0,texture.pixels.length-1);
          if(texture.pixels[index1] == color(255,20,20)){
            terrain.emissive(color(255,80,80));
          }else{
            terrain.emissive(color(0,0,0));
          }
          terrain.vertex(x,y,values[x][y],x,y);
          terrain.vertex(x+1,y,values[x+1][y],x,y);
          terrain.vertex(x+1,y+1,values[x+1][y+1],x,y);
          terrain.vertex(x,y,values[x][y],x,y);
          terrain.vertex(x+1,y+1,values[x+1][y+1],x,y);
          terrain.vertex(x,y+1,values[x][y+1],x,y);
          
          if(x > 0 && y > 0 && nval(x*1000,y*1000)/depth > 0.4){
            int rndx = round(random(-1,1));
            int rndy = round(random(-1,1));
            if(rndx == 0){
              rndx = 1;
            }
            if(rndy == 0){
              rndy = 1;
            }
            if(values[x][y] < rh){
              terrain.vertex(x,y,values[x][y],x,y);
              terrain.vertex(x+rndx/4.0,y+rndy/4.0,values[x][y]+1,x,y);
              terrain.vertex(x+rndx/2.0,y+rndy/2.0,(values[x][y]+values[x+rndx][y+rndy])/2.0,x,y);
            }else if(values[x][y] >=rh && nval(x*200,y*200)/depth > 0.55){
              terrain.vertex(x,y,values[x][y],x,y);
              terrain.vertex(x+1,y,values[x+1][y]+0.5,x,y);
              terrain.vertex(x+1,y+1,values[x+1][y+1],x,y);
              terrain.vertex(x+1,y,values[x+1][y]+0.5,x,y);
              terrain.vertex(x+2,y,values[x+2][y],x,y);
              terrain.vertex(x+1,y+1,values[x+1][y+1],x,y);
              terrain.vertex(x+1,y,values[x+1][y]+0.5,x,y);
              terrain.vertex(x+1,y-1,values[x+1][y-1],x,y);
              terrain.vertex(x+2,y,values[x+2][y],x,y);
              terrain.vertex(x,y,values[x][y],x,y);
              terrain.vertex(x+1,y-1,values[x+1][y-1],x,y);
              terrain.vertex(x+1,y,values[x+1][y]+0.5,x,y);
            }
          }
        }
      }
    }
    int count = 0;
    for(int x = 0; x < w; x+=5){
      for(int y = 0; y < w; y+=5){
        if(nval(x*1000,y*1000)/depth > 0.5 && dist(x,y,w/2,w/2) < radius){
          trees[count] = new PVector(x*scale,y*scale);
          count++;
          float h = values[x][y]-1;
          for(int l = 0; l < 6; l++){
            for(int r = 0; r < 360; r+=72){
              float x1 = cos(radians(r));
              float y1 = sin(radians(r));
              float x2 = cos(radians(r+72));
              float y2 = sin(radians(r+72));
              terrain.vertex(x+x1,y+y1,h+l,w-2,w+1);
              terrain.vertex(x+x2,y+y2,h+l,w-2,w+1);
              terrain.vertex(x+x1,y+y1,h+l+1,w-2,w+1);
              terrain.vertex(x+x1,y+y1,h+l+1,w-2,w+1);
              terrain.vertex(x+x2,y+y2,h+l,w-2,w+1);
              terrain.vertex(x+x2,y+y2,h+l+1,w-2,w+1);
            }
          }
          for(int l = 0; l < 6; l+=2){
            for(int r = 0; r < 360; r+=72){
              float x1 = cos(radians(r))*(3-l/2);
              float y1 = sin(radians(r))*(3-l/2);
              float x2 = cos(radians(r+72))*(3-l/2);
              float y2 = sin(radians(r+72))*(3-l/2);
              terrain.vertex(x+x1,y+y1,h+l+3-0.5,w-1,w+1);
              terrain.vertex(x+x2,y+y2,h+l+3-0.5,w-1,w+1);
              terrain.vertex(x,y,h+l+6,w-1,w);
            }
          }
        }
      }
    }
    for(float i = 0; i < 360; i+=0.25){
      float x = cos(radians(i))*(radius+random(-50,0))+w/2;
      float y = sin(radians(i))*(radius+random(-50,0))+w/2;
      float h = values[int(x)][int(y)]-1;
      for(int l = 0; l < 6; l++){
        for(int r = 0; r < 360; r+=72){
          float x1 = cos(radians(r));
          float y1 = sin(radians(r));
          float x2 = cos(radians(r+72));
          float y2 = sin(radians(r+72));
          terrain.vertex(x+x1,y+y1,h+l,w-2,w+1);
          terrain.vertex(x+x2,y+y2,h+l,w-2,w+1);
          terrain.vertex(x+x1,y+y1,h+l+1,w-2,w+1);
          terrain.vertex(x+x1,y+y1,h+l+1,w-2,w+1);
          terrain.vertex(x+x2,y+y2,h+l,w-2,w+1);
          terrain.vertex(x+x2,y+y2,h+l+1,w-2,w+1);
        }
      }
      for(int l = 0; l < 6; l+=2){
        for(int r = 0; r < 360; r+=72){
          float x1 = cos(radians(r))*(3-l/2);
          float y1 = sin(radians(r))*(3-l/2);
          float x2 = cos(radians(r+72))*(3-l/2);
          float y2 = sin(radians(r+72))*(3-l/2);
          terrain.vertex(x+x1,y+y1,h+l+3-0.5,w-1,w+1);
          terrain.vertex(x+x2,y+y2,h+l+3-0.5,w-1,w+1);
          terrain.vertex(x,y,h+l+6,w-1,w);
        }
      }
    }
    terrain.endShape();
    terrain.scale(scale,scale,scale);
    PVector[] treescopy = new PVector[count];
    for(int i = 0; i < count; i++){
      treescopy[i] = trees[i];
    } 
    trees = treescopy;
  }
}
void treehitboxes(){
  for(int i = 0; i < trees.length; i++){
    float d = dist(player.x,player.y,trees[i].x,trees[i].y);
    if(d < 3*scale+2){
      PVector resist = vectortowards(trees[i],player);
      float t = 1.0/(sqrt(pow(resist.x,2)+pow(resist.y,2)));
      player.x = lerp(player.x,player.x+resist.x*movespeed/speed*t,(3*scale+2)/10.0-d/10.0);
      player.y = lerp(player.y,player.y+resist.y*movespeed/speed*t,(3*scale+2)/10.0-d/10.0);
    }
  }
}
void bullethittree(int index, int count){
  particlesystems.add(new particlesystem(new PVector(trees[index].x,trees[index].y,trees[index].z+5),new PVector(0,0,5),0.025,0.01,color(194, 100, 0),10,count,4,(count-(count-1))));            
}
float nval(float x, float y){
  float h = noise(x/w*rate,y/w*rate);
  h*=h*0.9;
  h*=depth*0.8;
  h+=noise(x/w*rate,y/w*rate)*depth*0.15 + noise(x/w*rate,y/w*rate)*depth*0.05;
  return h;
}
