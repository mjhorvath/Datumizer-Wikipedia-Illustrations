// +kfi0 +kff9
// +k1
//#include "Axes.inc"
#include "math.inc"
#include "finish.inc"
#include "transforms.inc"

global_settings
{
	assumed_gamma 1.0
//	radiosity
//	{
//		brightness 0.3
//	}
}

#declare Jitter = 0.001;	
#declare CircumsphereRadius = (sqrt(3) * 1 / 2) + Jitter;	// distance from the center to a corner of the cube (radius of the sphere circumscribing the cube)
#declare StartDistance = CircumsphereRadius;
#declare StartAngle = atan2(StartDistance, 1);	// begin the animation with the proper angle starting at the corner of the cube (otherwise, the camera will lie inside the object)
#declare AngleOfView = StartAngle + clock * (90 - StartAngle - Jitter);	// do a linear interpolation between the start angle and the final angle (a tiny bit less than 90 degrees)
#declare CameraDistance = tand(AngleOfView);	// calculate the distance based on the angle (the distance corresponds to the exsecant of the angle)

camera
{
	#local diff = (45 - asind(tand(30)));	// the difference between a 45 degree angle and the vertical angle required to view from one corner of a cube to the opposite corner
	#local angl = 30;	// the angle required to rotate the hexagonal outline of the isometric cube so that one of its bottom sides is parallel with the bottom of the image
	#local dimm = 5/2;	// the width and height of the output image (assuming a square image)
	#local quadrantangle = (90 - diff * 2) / 2;	// an angle used to determine the length of the segment, below.
	#local leng = tand(quadrantangle) + 1/tand(quadrantangle);	// the length of a side of the parallelogram defined by the (unit length) up and right vectors
	#local AspectRatio = image_width/image_height;
	orthographic
	location -z*(CameraDistance)
	up vaxis_rotate(y,z,-(angl - diff)/2) * dimm * leng/2
	right vaxis_rotate(x,z,+(angl - diff)/2) * dimm * leng/2 * AspectRatio
	rotate z*angl/2
	rotate x*(45 - diff)
	rotate y*45
	Axis_Rotate_Trans(<1,1,0,>, -diff)
//	aperture 0.00001
//	blur_samples 100
//	focal_point 0
}
/*
camera
{
	location <10,0,0,>
	look_at <10,10,0,>
}
*/
sky_sphere
{
	pigment
	{
		gradient y
		color_map
		{
			[0.0 rgb <0.6,0.7,1.0>]		//153, 178.5, 255	//150, 240, 192
			[0.7 rgb <0.0,0.1,0.8>]		//  0,  25.5, 204	//155, 240, 96
//			[1.0 rgb <000/255,008/255,117/255>]	//0, 8, 117	//157.14, 240, 54.86
//			[1.0 rgb <-65.57/255, -40.07/255, 182.16/255>]
//			[1.0 rgb <-285/255, -259.5/255, 109.03/255>]
		}
		scale 2
		translate 1
	}
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
//		pigment {rgbt <1,1,1,0.5,>}
		pigment {rgb 1}
		finish {Phong_Glossy}
	}
//	scale y *  tand(30) * (tand(45)/sind(45))/(tand(30)/sind(30))
}

// the coordinate grid and axes
//		axesSize,			// The distance from the origin to one of the grid's edges.	(float)
//		minUnit,			// The size of each small-unit square.	(float)
//		thickRatio,			// The thickness of the grid lines (as a factor of axesSize).	(float)
//		aBool,				// Turns the axes on/off. (boolian)
//		xBool,				// Turns the plane perpendicular to the x-axis on/off.	(boolian)
//		yBool,				// Turns the plane perpendicular to the y-axis on/off.	(boolian)
//		zBool,				// Turns the plane perpendicular to the z-axis on/off.	(boolian)
//		offsetBool,			// Offsets the grid and axes by thickRatio in all directions (in case of obstructions).	(boolian)
//AxesParam(100, .1, 0.0001, 1, 0, 1, 0, 0)
