//#include "Axes.inc"
#include "math.inc"
#include "finish.inc"
#include "transforms.inc"

camera
{
	#local CameraArea = 5/2;
	#local CameraDistance = 40;
	#local CameraSkewed = sind(45);
	#local CameraPosition = vnormalize(<-CameraSkewed,CameraSkewed,-1>)*CameraDistance;
	#local AspectRatio = image_width/image_height;
	orthographic
	location CameraPosition
	direction -CameraPosition
	up y*CameraArea
	right x*CameraArea*AspectRatio
}

light_source
{
	<0, 0, -100>            // light's position (translated below)
	color rgb <1, 1, 1>  // light's color
	rotate <60,30,0>
	parallel
	shadowless
}

box
{
	-0.5,0.5
	texture
	{
		pigment {rgb 1}
		finish {Phong_Glossy}
	}
}

//AxesParam(100, .1, 0.0001, 1, 0, 1, 0, 0)