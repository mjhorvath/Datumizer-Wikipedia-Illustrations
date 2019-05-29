#version 3.7;


//------------------------------------------------------------------------------Scenery

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

#include "ShapeGrid_macro.inc"				// http://lib.povray.org/
#include "ColorSolid_include.inc"			// http://lib.povray.org/
#include "Axes_macro.inc"					// http://lib.povray.org/
#include "functions.inc"
#include "math.inc"

background {srgb 1}

light_source
{
	<0, 0, 0>
	color rgb <1, 1, 1>/4
	translate <-30, +30, -30>
}

light_source
{
	<0, 0, 0>
	color rgb <1, 1, 1>/4
	translate <-30, +30, -30>
	rotate y * 90
}

#declare CameraDistance	= 8;
#declare ScreenArea		= 2/3;
#declare AspectRatio	= image_width/image_height;
camera
{
	location	-z*CameraDistance
	direction	+z*1.5
	right		+x*ScreenArea*AspectRatio
	up			+y*ScreenArea
	rotate		-y*90
	rotate		+z*30
	rotate		-y*65
}


sky_sphere
{
	pigment
	{
		gradient y
		color_map
		{
			[0.0 rgb <0.6,0.7,1.0>]
			[0.7 rgb <0.0,0.1,0.8>]
		}
	}
}


//------------------------------------------------------------------------------CSG objects

#declare sRadius = 1 ;
#declare sCenter = 0 ;

difference
{
	box {sCenter, sRadius}
	box {sRadius/2, sRadius}
	texture
	{
		//pigment {CSolid_HSLCube_Pigment}
		//pigment {CSolid_HSVCube_Pigment}
		pigment {CSolid_RGBCube_Pigment}
	}
}

#declare Axes_Color = <1,1,1>;
// the coordinate grid and axes
Axes_Macro
(
	5,	// Axes_axesSize,	The distance from the origin to one of the grid's edges.	(float)
	0.1,	// Axes_majUnit,	The size of each large-unit square.	(float)
	10,	// Axes_minUnit,	The number of small-unit squares that make up a large-unit square.	(integer)
	0.001,	// Axes_thickRatio,	The thickness of the grid lines (as a factor of axesSize).	(float)
	on,	// Axes_aBool,		Turns the axes on/off. (boolian)
	off,	// Axes_mBool,		Turns the minor units on/off. (boolian)
	off,	// Axes_xBool,		Turns the plane perpendicular to the x-axis on/off.	(boolian)
	on,	// Axes_yBool,		Turns the plane perpendicular to the y-axis on/off.	(boolian)
	off	// Axes_zBool,		Turns the plane perpendicular to the z-axis on/off.	(boolian)
)

object
{
	Axes_Object
	translate +0.000001
}
