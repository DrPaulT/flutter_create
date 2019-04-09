import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
var p=Paint();
var gImg;var aImg;var sImg;var scImg;var tImg;var eImg;var drBd;var sta=0;
ByteData atlasBd;ByteData locationBd;
Matrix4 mv;Matrix4 mvp;
double cx=159;double cz=-168;double ca=0;double cao;
double cvx=0;double cvz=0;double cav=0;
bool dn=false;
void down(PointerDownEvent e){dn=true;if(sta==4){sta=5;}}
void move(PointerMoveEvent e){
cav-=e.delta.dx*0.0007;
if(cav>0.6){cav=0.6;}else if(cav<-0.6){cav=-0.6;}
}
void up(PointerUpEvent e){
dn=false;
if(sta==0){sta=1;}
if(sta==5){sta=1;cx=159;cz=-168;ca=0;cvx=0;cvz=0;cav=0;}
}

void main() {SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
runApp(MyApp());});
}

class MyApp extends StatelessWidget{
@override
Widget build(BuildContext context){
return Listener(onPointerDown:down,onPointerMove:move,onPointerUp:up,
child:CustomPaint(painter:BlitPainter()));
}
}

class BlitPainter extends CustomPainter{
BlitPainter():super(repaint:RepaintListenable()) {p
..strokeWidth=15.0
..filterQuality=FilterQuality.none
..isAntiAlias=false
..color=Color.fromARGB(255, 255, 0, 0);
_loadImage("assets/ground.png").then((i){gImg=i;});
_loadImage("assets/atlas.png").then((i){aImg=i;});
_loadImage("assets/sky.png").then((i){sImg=i;});
_loadImage("assets/scooter_sheet.png").then((i){scImg = i;});
_loadImage("assets/title.png").then((i){tImg = i;});
_loadImage("assets/endgame.png").then((i){eImg = i;});
_loadImage("assets/driveable.png").then((i) {i.toByteData().then((bd){drBd=bd;});});
rootBundle.load("assets/atlas_info.bin").then((bd){atlasBd=bd;});
rootBundle.load("assets/location_info.bin").then((bd){locationBd=bd;});
}

@override
void paint(Canvas c,Size s){
if(gImg==null||aImg==null||sImg==null||scImg==null||tImg==null||drBd==null||atlasBd==null||locationBd==null){return;}
var v=sqrt(cvx*cvx+cvz*cvz);
ca+=2*cav*v;
if(dn==true&&sta>0&&sta<4) {cvx+=0.03*sin(ca);cvz+=0.03*cos(ca);}else{cav*=0.9;}
cvx*=0.9;cvz*=0.9;var nx=cx+cvx;var nz=cz+cvz;
var drv=drBd.getUint8(((204.8-nz)*5).round()*2048*4+((204.8-nx)*5).round()*4);
if(drv==255||sta==0||sta>=4){cx=nx;cz=nz;
if(nz<-139&&nx>105&&nx<144&&sta<4){sta=4;}}
else if(drv>0){cx+=cvx*drv/255;cz+=cvz*drv/255;}
var v0=Vector3(cvx,0,cvz).normalized();
var v1=Vector3(sin(ca),0,cos(ca)).normalized();
var vn=Vector3(0,1,0).normalized();
cao = atan2((v0.cross(v1)).dot(vn), v0.dot(v1));
if(v<0.3) {cao*=v/0.3;}
var xo=-((ca+cao)/2/pi*270*7)%270;
var sr=Rect.fromLTRB(xo,0,xo+270,540);
var dr=Rect.fromLTRB(0,0,s.width,s.height);
c.drawImageRect(sImg,sr,dr,p);
mv=Matrix4.identity();
mv.translate(0.0,0.0,-10.0);
mv.rotateY(-(ca+cao));
mv.translate(cx,10.0,cz);
mv.rotateX(pi/2);
mv.scale(0.1,0.1,1.0);
mv.translate(-2048.0,-2048.0,0.0);
mvp=makePerspectiveMatrix(0.01,s.width/s.height,1,10);
mvp.multiply(mv);
mvp.leftTranslate(s.width/2,s.height/2,0);
c.save();c.transform(mvp.storage);c.drawImage(gImg,Offset(0,0),p);c.restore();

var l=locationBd.lengthInBytes~/360;
var a=((ca+cao)*180/pi).floor();
while(a<0){a+=360;}while (a>=360){a-=360;}
var k=a*l;
for (var i=0;i<l;i+=5){
var r=Vector4(locationBd.getUint16(k+i+1).toDouble(),
locationBd.getUint16(k+i+3).toDouble(),0,1);
var rr=Vector4.copy(r);
mv.transform(rr);
var zw=rr.z/rr.w;
mvp.transform(r);
var scale=40/-zw;
r.scale(1/r.w);
if (scale>0){
var n=locationBd.getUint8(k+i);
var width=atlasBd.getUint8(n*4+2)*8.0;
var height=atlasBd.getUint8(n*4+3)*8.0;
var left=r.x-width/2*scale;
var top= r.y-(height-2)*scale;
var right=left+width*scale;
var bottom=r.y+2*scale;
dr=Rect.fromLTRB(left,top,right,bottom);
c.drawImageRect(aImg,Rect.fromLTWH(atlasBd.getUint8(n*4)*8.0,atlasBd.getUint8(n*4+1)*8.0,width,height),dr,p);
}
}

var xoff;
var yoff=0.0;
var off=min((cao.abs()*180/pi/5).floor(),7);
xoff=off*109.0;
if(cao>0){yoff = 120;}
var top=1229/2160.0*s.height;
var bottom=1804/2160.0* s.height;
var left=s.width/2-(bottom-top)*109/120/2;
var right=s.width/2+(bottom-top)*109/120/2;
dr=Rect.fromLTRB(left,top,right,bottom);
c.drawImageRect(scImg,Rect.fromLTRB(xoff,yoff,109+xoff,120+yoff),dr,p);
if (sta == 0){c.drawImageRect(tImg,Rect.fromLTRB(0,0,224,336),Rect.fromLTWH(0,(s.height-s.width*336/224)/2,s.width,s.width*336/224),p);}
if(sta>=4){c.drawImageRect(eImg,Rect.fromLTRB(0,0,224,199),Rect.fromLTWH(0,(s.height-s.width*336/199)/2,s.width,s.width*199/224),p);}
}

@override
bool shouldRepaint(CustomPainter oldDelegate){return true;}

Future<ui.Image> _loadImage(String name)async{
var bd=await rootBundle.load(name);
var c=await ui.instantiateImageCodec(bd.buffer.asUint8List());
var fi=await c.getNextFrame();
return fi.image;
}
}
class RepaintListenable extends Listenable {
VoidCallback l;Ticker t;RepaintListenable(){t=Ticker(r);t.start();}
@override
void addListener(lr){l=lr;}
@override
void removeListener(lr){if (l==lr){l=null;}}
void r(Duration duration){if(l!=null){l();}}
}
