int kills = 0;
float points = 1000;
PVector player = new PVector(2000+random(-100,100),2000+random(-100,100),50);
float health = 100;
boolean alive = true;
PShape pmodel;
PShape pistol1;
PShape pistol2;
PShape smg1;
PShape smg2;
PShape sniper1;
PShape sniper2;
PShape[][] weapons = new PShape[3][2];
float[][] weaponstats = new float[3][5];
int weapon = 2;
int gunstate = 0;
float bulletcount = 0;
float scopelerp = 0;
boolean scoping = false;
void setupweapons(){
  weapons[0][0] = pistol1;
  weapons[0][1] = pistol2;
  weapons[1][0] = smg1;
  weapons[1][1] = smg2;
  weapons[2][0] = sniper1;
  weapons[2][1] = sniper2;
  createweapon(0,40,0.25,30,16,0.75);
  createweapon(1,20,0.125,30,60,0.25);
  createweapon(2,200,0.6,40,8,1.0);
}
void createweapon(int index, int damage, float firerate, float bulletspeed, float bulletcount, float reloadtimer){
  weaponstats[index][0] = damage;
  weaponstats[index][1] = firerate;
  weaponstats[index][2] = bulletspeed;
  weaponstats[index][3] = bulletcount;
  weaponstats[index][4] = reloadtimer;
}
void displayweapon(){
  if(scoping && scopelerp < 1){
    scopelerp+=0.1;
    if(scopelerp > 1){
      scopelerp = 1;
    }
  }else if(scoping == false && scopelerp > 0){
    scopelerp-=0.1;
    if(scopelerp < 0){
      scopelerp = 0;
    }
  }
  d3.translate(player.x,player.y,player.z);
  d3.rotateZ(radians(mouse.x)+PI/2);
  d3.rotateX(-sin(radians(mouse.y))-map(reloadtimer,0,weaponstats[weapon][4],0,PI));
  d3.translate(lerp(5,0,scopelerp),lerp(-10-shottimer*2.5,-6-shottimer*1.5,scopelerp),lerp(0,-0.2,scopelerp)); //5
  d3.shape(weapons[weapon][gunstate]);
  d3.translate(-lerp(5,0,scopelerp),-lerp(-10-shottimer*2.5,-6-shottimer*1.5,scopelerp),-lerp(0,-0.2,scopelerp));
  d3.rotateX(sin(radians(mouse.y))+map(reloadtimer,0,weaponstats[weapon][4],0,PI));
  d3.rotateZ(-(radians(mouse.x)+PI/2));
  d3.translate(-player.x,-player.y,-player.z);
}
