// +kfi0 +kff100
#include "Axes.inc"
#include "math.inc"

global_settings
{
	assumed_gamma 1.0
}

#declare Jitter = 1;
#declare AngleOfView = Jitter + frame_number/final_frame * (90 - Jitter * 2);
#declare Exsecant = 1/cosd(AngleOfView) - 1;
#declare CircumsphereRadius = (sqrt(3) * 1 / 2);	// distance from the center to a corner of the cube (radius of the sphere circumscribing the cube)
#declare CircumsphereRadius = 0;	// distance from the center to a corner of the cube (radius of the sphere circumscribing the cube)
#declare CameraDistance = CircumsphereRadius + Exsecant;
//#declare CameraDistance = 2 + CameraDistance + 0.0001;
//#declare CameraDistance = CameraDistance + 0.0001;

camera
{
	location -z*(CameraDistance)
	look_at 0
	direction z*(CameraDistance)
	up y*5/2
	right x*5/2
	rotate <asind(tand(30)),45,0>
}

sky_sphere {
  pigment {
    gradient y
    color_map {
      [0.0 rgb <0.6,0.7,1.0>]
      [1 rgb <0.0,0.1,0.8>]
    }
	scale 2
      translate -1
  }
}

light_source {
  <0, 0, -100>            // light's position (translated below)
  color rgb <1, 1, 1>  // light's color
  rotate <60,30,0>
  parallel
}
/*
box
{
	-0.5,0.5
	texture
	{
		pigment {rgb 1}
	}
}
*/

AxesParam(10, .1, 0.001, 0, 1, 0, 0)