// +kfi0 +kff9
// +ki0.1111 +kf1
// +k1
#include "Axes_macro.inc"
#include "math.inc"
#include "finish.inc"
#include "transforms.inc"

global_settings
{
	assumed_gamma	1.8
	adc_bailout	0.005
	max_trace_level	50
	radiosity
	{
		pretrace_start	0.08
		pretrace_end	0.01
		count		50
		error_bound	0.1
		recursion_limit	1
		normal		on
		brightness	0.8
		always_sample	yes
		gray_threshold	0.8
		media		on
	}
}

#declare Jitter = 0.001;
// distance from the center to a corner of the cube
// (radius of the sphere circumscribing the cube)
#declare CircumsphereRadius = (sqrt(3) * 1 / 2) + Jitter;
#declare StartDistance = CircumsphereRadius;
// begin the animation with the proper angle starting
// at the corner of the cube (otherwise, the camera
// will lie inside the object)
#declare StartAngle = atan2d(StartDistance, 1);
// do a linear interpolation between the start
// angle and the final angle (a tiny bit less than
// 90 degrees)
#declare AngleOfView = StartAngle + clock * (90 - StartAngle - Jitter);
// calculate the distance based on the angle (the
// distance corresponds to the exsecant of the angle)
#declare CameraDistance = tand(AngleOfView);

camera
{
	location	-z*(CameraDistance)
	direction	+z*(CameraDistance)
	up		+y*5/2
	right		+x*5/2
	// rotate the camera so that it lies along
	// the vector starting at the origin and
	// passing through the cube's corner
	rotate		<asind(tand(30)),45,0,>
	aperture	0.00001
	blur_samples	100
	focal_point	0
}

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
		translate	1
	}
}

light_source
{
	<+000,+000,-100,>
	color rgb	<1,1,1,>
	rotate		<60,30,00,>
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

// the coordinate grid and axes
// available from the POV-Ray Object Collection
Axes_Macro
(
	10000,		// Axes_axesSize,	The distance from the origin to one of the grid's edges.		(float)
	.1,		// Axes_majUnit,	The size of each large-unit square.					(float)
	10,		// Axes_minUnit,	The number of small-unit squares that make up a large-unit square.	(integer)
	0.000001,	// Axes_thickRatio,	The thickness of the grid lines (as a factor of axesSize).		(float)
	on,		// Axes_aBool,		Turns the axes on/off.							(boolian)
	off,		// Axes_mBool,		Turns the minor units on/off.						(boolian)
	off,		// Axes_xBool,		Turns the plane perpendicular to the x-axis on/off.			(boolian)
	on,		// Axes_yBool,		Turns the plane perpendicular to the y-axis on/off.			(boolian)
	off		// Axes_zBool,		Turns the plane perpendicular to the z-axis on/off.			(boolian)
)

object
{
	Axes_Object
	translate	-0.0001
	no_reflection
	no_shadow
}
