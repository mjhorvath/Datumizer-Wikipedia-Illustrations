#version 3.7;


//------------------------------------------------------------------------------Scenery

global_settings
{
	assumed_gamma 1.0
	ambient_light 2/3
	radiosity {brightness 0.3}
}

#include "ShapeGrid_macro.inc"				// http://lib.povray.org/
#include "ColorSolid_include.inc"			// http://lib.povray.org/
#include "Axes_macro.inc"					// http://lib.povray.org/
#include "functions.inc"
#include "math.inc"

background {rgb 1}

light_source
{
	<0, 0, 0>
	color rgb <1, 1, 1>
	translate <-30, 30, -30>
}

light_source
{
	<0, 0, 0>
	color rgb <1, 1, 1>
	translate <-30, 30, -30>
	rotate y * 90
}

#declare screen_scale = 1;
camera
{
//	orthographic
	location x*8
	direction 1.5*z
	right     x*image_width/image_height*screen_scale
	up y*screen_scale
	look_at   <0.0, 0.0,  0.0>
	rotate z*30
	rotate y*-65
//	scale 1/2
}

#declare screen_scale = 1;
camera
{
	#local CameraDistance = 8;
	#local ScreenArea = 1/3;
	#local AspectRatio = image_width/image_height;
//	orthographic
	location -z*CameraDistance
	direction z*1.5
	right     x*AspectRatio*ScreenArea
	up y*ScreenArea
	rotate x*30
	rotate y*(-65-90)
	translate 1/2
//	scale 1/2
}

sky_sphere
{
	pigment
	{
		gradient y
		color_map {[0.0 rgb <0.6,0.7,1.0>][0.7 rgb <0.0,0.1,0.8>]}
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
		finish {ambient 1}
	}
}

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
//	translate -0.000001
}