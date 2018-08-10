#declare AR=image_width/image_height; //Image aspect ratio (square pixels)
#declare VW=5;                        //Viewing width
#declare CD=6;                        //Cameras distance

#declare DPTH=1/(2*sqrt(2)); //Cabinet projection:  Depth = 0.5:1
#declare DPTH=1/(sqrt(2));   //Cavalier projection: Depth = 1:1

camera{
  orthographic
  location -z*CD
  up y*VW
  right x*VW*AR
  direction <-DPTH,-DPTH,1>
  translate  <DPTH,DPTH,0>*CD
}

light_source{<100,300,-200> rgb 1}

box{-1,1 pigment {rgb 1}}

union{cylinder{0,x*2,0.02} cone{x*2,0.1,x*2.25,0} pigment{rgb <1,0,0>}}
union{cylinder{0,y*2,0.02} cone{y*2,0.1,y*2.25,0} pigment{rgb <0,1,0>}}
union{cylinder{0,-z*2,0.02} cone{-z*2,0.1,-z*2.25,0} pigment{rgb <0,0,1>}}