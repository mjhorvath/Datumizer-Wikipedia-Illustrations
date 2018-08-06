//------------------------------------------------------------------------------Scenery

#include "axes_macro.inc"		// http://lib.povray.org/searchcollection/index2.php?objectName=AxesAndGridMacro&contributorTag=SharkD
#include "functions.inc"
#include "math.inc"


global_settings
{
	assumed_gamma	1.0
	ambient_light	2/3
	radiosity {brightness 0.3}
}

background {rgb 1}

light_source
{
	<0,0,0>
	color rgb <1,1,1>
	translate <-30,+30,-30>
	shadowless
}

light_source
{
	<0,0,0>
	color rgb <1,1,1>
	translate <-30,+30,-30>
	rotate y * 90
	shadowless
}

#declare screen_scale = 1;
#local CameraDistance = 16;
#local ScreenArea = 1/3;
#local AspectRatio = image_width/image_height;
camera
{
	location	-z*CameraDistance
	direction	+z*1.5
	right		+x*AspectRatio*ScreenArea
	up			+y*ScreenArea
	rotate		+x*30
	rotate		+y*(-65-90)
//	translate	1/2
	translate	<1/2,0,1>
}

/*
sky_sphere
{
	pigment
	{
		gradient y
		color_map {[0.0 rgb <0.6,0.7,1.0>][0.7 rgb <0.0,0.1,0.8>]}
	}
}
*/

//------------------------------------------------------------------------------CSG objects

#declare sRadius = 1;
#declare sCenter = 0;
#declare MarkersScale = 1;

box
{
	sCenter, sRadius
	pigment {color rgbt <1,1,1,1/2>}
//	hollow
//	no_shadow
}

// the coordinate grid and axes
Axes_Macro
(
	10,		// Axes_axesSize,	The distance from the origin to one of the grid's edges.	(float)
	0.1,	// Axes_majUnit,	The size of each large-unit square.	(float)
	10,		// Axes_minUnit,	The number of small-unit squares that make up a large-unit square.	(integer)
	0.0005,	// Axes_thickRatio,	The thickness of the grid lines (as a factor of axesSize).	(float)
	on,		// Axes_aBool,		Turns the axes on/off. (boolian)
	off,	// Axes_mBool,		Turns the minor units on/off. (boolian)
	off,	// Axes_xBool,		Turns the plane perpendicular to the x-axis on/off.	(boolian)
	on,		// Axes_yBool,		Turns the plane perpendicular to the y-axis on/off.	(boolian)
	off		// Axes_zBool,		Turns the plane perpendicular to the z-axis on/off.	(boolian)
)

object
{
	Axes_Object
	translate -0.0001
	no_shadow
}

cylinder
{
	+z * 3 * MarkersScale, 0, 1/80
	pigment {color rgbt <0,0,0,0>}
	rotate		-x * 35.264
	rotate		+y * 45
}

sphere
{
	+z * 3 * MarkersScale, 1/20
	pigment {color rgbt <0,0,0,0>}
	rotate		-x * 35.264
	rotate		+y * 45
}

polygon
{
	4, <0,1>, <1,1>, <1,0>, <0,0>
	pigment
	{
		image_map {png "rotation_y_45_degrees_line.png"}
	}
	translate	<-1/2,-1/2,0>
	translate	-z * 0.0001
	scale		8 * MarkersScale
	rotate		x * 90
	rotate		y * 90
}

polygon
{
	4, <0,1>, <1,1>, <1,0>, <0,0>
	pigment
	{
		image_map {png "rotation_x_35.264_degrees_line.png"}
	}
	translate	<-1/2,-1/2,0>
	translate	-z * 0.0001
	scale		8 * MarkersScale
	rotate		y * 135
}
