// +kfi0 +kff15
// +K0.5
#version 3.7
#include "axes_macro.inc"		// http://lib.povray.org/searchcollection/index2.php?objectName=AxesAndGridMacro&contributorTag=SharkD
#include "screen.inc"		// requires the updated version available here: http://news.povray.org/povray.binaries.scene-files/thread/%3C4afccd8a%241%40news.povray.org%3E/
#include "math.inc"
#include "finish.inc"
#include "transforms.inc"

global_settings
{
	assumed_gamma	1.0
	adc_bailout		0.005
	max_trace_level	50
	charset			utf8
	ambient_light	0
	radiosity
	{
		pretrace_start	0.08
		pretrace_end	0.01
		count			50
		error_bound		0.1
		recursion_limit	1
		normal			on
		brightness		0.8
		always_sample	yes
		gray_threshold	0.8
		media			on
	}
}

background {color srgb <096,144,255,>/255}

#declare Jitter				= 0.001;
#declare CircumsphereRadius	= sqrt(3) * 2/3;						// distance from the center to a corner of the cube (radius of the sphere circumscribing the cube)
#declare StartDistance		= CircumsphereRadius;
#declare StartAngle			= atan2d(StartDistance, 1);		// begin the animation with the proper angle starting at the corner of the cube (otherwise, the camera will lie inside the object)
#declare AngleOfView		= StartAngle + clock * (90 - StartAngle) - Jitter;	// do a linear interpolation between the start angle and the final angle (a tiny bit less than 90 degrees)
#declare CameraDistance		= tand(AngleOfView);			// calculate the distance based on the angle (the distance corresponds to the exsecant of the angle)
#declare CameraLocation		= -z * CameraDistance;
#declare CameraDirection	= +z * CameraDistance;
#declare CameraRight		= +x * 5/2;
#declare CameraUp			= +y * 5/2;
#declare CameraTransform	= transform
{
	rotate	<atand(sind(45)),135,0>
}
//#declare CameraAngle		= (90 - AngleOfView) * 2;
//#declare CameraAngle		= StartAngle;
#declare CameraAngle		= degrees(2 * atan(vlength(CameraRight)/vlength(CameraDirection)/2));
#declare CameraText_1		= text
{
	ttf "verdana.ttf" concat("", str(CameraAngle,0,1), "°") 0.01, <0,0>
	scale 0.05
}
#declare CameraText_2		= text
{
	ttf "verdana.ttf" concat("", str(vlength(CameraLocation)*10,0,1), "m") 0.01, <0,0>
	scale 0.05
}

Set_Camera_Alt(CameraLocation, CameraDirection, CameraRight, CameraUp)

/*
union
{
	Screen_Object(CameraText_1, <1,0>, <0.04,0.07>, true, 0.01)
	Screen_Object(CameraText_2, <1,0>, <0.04,0.02>, true, 0.01)
	transform {CameraTransform}
}
*/

camera
{
	location		CameraLocation
	direction		CameraDirection
	up				CameraUp
	right			CameraRight
	transform {CameraTransform}
//	aperture		0.00001
//	blur_samples	100
//	focal_point		0
}
/*
sky_sphere
{
	pigment
	{
		gradient	y
		color_map
		{
			[0.0 rgb <0.6,0.7,1.0,>]
			[0.7 rgb <0.0,0.1,0.8,>]
		}
		scale		2
		translate	y
	}
}

light_source
{
	<0, 0, -100>            // light's position (translated below)
	color srgb <1, 1, 1>  // light's color
	rotate <60,30,0>
	parallel
	shadowless
}
*/
light_source
{
	<-30,+30,-30,>
	color srgb	1
	rotate		y * 330
	parallel
	shadowless
}

light_source
{
	<-30,+30,-30,>
	color srgb	1
	rotate		y * 090
	parallel
	shadowless
}

box
{
	-0.5,0.5
	texture
	{
		pigment {color srgbt <1,1,1,0>}
//		finish {Phong_Glossy}
	}
}

// the coordinate grid and axes
// available from the POV-Ray Object Collection
Axes_Macro
(
	10000,		// Axes_axesSize,	The distance from the origin to one of the grid's edges.	(float)
	.1,		// Axes_majUnit,	The size of each large-unit square.	(float)
	10,		// Axes_minUnit,	The number of small-unit squares that make up a large-unit square.	(integer)
	0.000001,	// Axes_thickRatio,	The thickness of the grid lines (as a factor of axesSize).	(float)
	on,		// Axes_aBool,		Turns the axes on/off. (boolian)
	off,		// Axes_mBool,		Turns the minor units on/off. (boolian)
	off,		// Axes_xBool,		Turns the plane perpendicular to the x-axis on/off.	(boolian)
	on,		// Axes_yBool,		Turns the plane perpendicular to the y-axis on/off.	(boolian)
	off,		// Axes_zBool,		Turns the plane perpendicular to the z-axis on/off.	(boolian)
	3/4
)

object
{
	Axes_Object
	translate	-0.0001
//	no_reflection
//	no_shadow
}
