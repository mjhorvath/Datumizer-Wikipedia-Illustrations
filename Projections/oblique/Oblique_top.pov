// +kfi0 +kff9
// +k1
#include "Axes.inc"
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
	orthographic
	location -z*(CameraDistance)
	direction z*(CameraDistance)
	up y*5/2   *sind(45)  //stretch to square top for 45deg rotation
	right x*5/2     //no need to stretch in this direction
	rotate <45,45,0>       //rotate up 45 degrees
//	Axis_Rotate_Trans(<-1,1,-1,>, 30)
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
}

// the coordinate grid and axes
//		axesSize,			// The distance from the origin to one of the grid's edges.	(float)
//		majUnit,			// The size of each large-unit square.	(float)
//		minUnit,			// The number of small-unit squares that make up a large-unit square.	(integer)
//		thickRatio,			// The thickness of the grid lines (as a factor of axesSize).	(float)
//		aBool,				// Turns the axes on/off. (boolian)
//		xBool,				// Turns the plane perpendicular to the x-axis on/off.	(boolian)
//		yBool,				// Turns the plane perpendicular to the y-axis on/off.	(boolian)
//		zBool,				// Turns the plane perpendicular to the z-axis on/off.	(boolian)
//		offsetBool,			// Offsets the grid and axes by thickRatio in all directions (in case of obstructions).	(boolian)
AxesParam(100, .5, 5, 0.0001, 1, 0, 1, 0, 0)
