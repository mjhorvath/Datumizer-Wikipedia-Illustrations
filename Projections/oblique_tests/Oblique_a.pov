#include "math.inc"

#declare CameraDistance = 100;

camera{
 orthographic
 location -z*(CameraDistance)
 direction z*(CameraDistance)
 up y*5/2   *sind(45)  //stretch to square top for 45deg rotation
 right x*5/2           //no need to stretch in this direction
 rotate <45,45,0>       //rotate up 45 degrees
}

light_source{
 -100*z
 rgb 1
 rotate <60,30,0>
 parallel
 shadowless
}

box{
 -0.5,0.5
 pigment {rgb 1}
}
