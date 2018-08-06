// +kfi0 +kff9
#declare VisibleAxes = 1;
#include "Axes.inc"
#include "math.inc"
#include "finish.inc"

global_settings
{
	assumed_gamma 1.0
	radiosity
	{
		brightness 0.3
	}
}

global_settings {
//ambient_light 0
   assumed_gamma 1.8
   radiosity {
      brightness 2
      count 100
      error_bound 0.15
      gray_threshold 0.0
      low_error_factor 0.2
      minimum_reuse 0.015
      nearest_count 10
      recursion_limit 5
      adc_bailout 0.01
      max_sample 0.5
//      media off
//      normal off
      always_sample 1
//      pretrace_start 0.08
//      pretrace_end 0.01
   }
}


#declare Jitter = 0.001;	
#declare CircumsphereRadius = (sqrt(3) * 1 / 2) + Jitter;	// distance from the center to a corner of the cube (radius of the sphere circumscribing the cube)
#declare StartDistance = CircumsphereRadius;
#declare StartAngle = atan2d(StartDistance,1);	// begin the animation with the proper angle starting at the corner of the cube (otherwise, the camera will lie inside the object)
#declare AngleOfView = StartAngle + clock * (90 - StartAngle - Jitter);	// do a linear interpolation between the start angle and the final angle (a tiny bit less than 90 degrees)
#declare CameraDistance = tand(AngleOfView);	// calculate the distance based on the angle (the distance corresponds to the exsecant of the angle)

camera
{
	location -z*(CameraDistance)
	direction z*(CameraDistance)
	up y*5/2
	right x*5/2
	rotate <asind(tand(30)),45,0>	//rotate the camera so that it lies along the vector starting at the origin and passing through the cube's corner
	aperture 0.00001
	blur_samples 100
	focal_point 0
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
		pigment {rgb 1}
		finish {Shiny}	//Dull Shiny Glossy Phong_Dull Phong_Shiny Phong_Glossy Luminous Mirror
	}
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
AxesParam(100, .1, 0.0001, 1, 0, 1, 0, 0)
