#version 3.7

#include "axes_macro.inc"		// http://lib.povray.org/searchcollection/index2.php?objectName=AxesAndGridMacro&contributorTag=SharkD
#include "functions.inc"
#include "math.inc"
#include "screen_mjh.inc"			// requires the updated version available here: http://news.povray.org/povray.binaries.scene-files/thread/%3C4afccd8a%241%40news.povray.org%3E/

#declare sRadius = 1;
#declare sCenter = 0;
#declare MarkersScale = 6/5;
#declare OuterRadius = 3 * MarkersScale;
#declare InnerRadius = 0.02 * MarkersScale;
#declare ArrowRadius = 0.05 * MarkersScale;
#declare ArrowLength = 0.3 * MarkersScale;
#declare RotateVert = 45;
#declare RotateHorz = atand(sind(45));

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

background {color srgb <096,144,255,>/255}

light_source
{
	<-30,+30,-30,>
	color rgb	1
	rotate		y * 330
	parallel
	point_at 0
	shadowless
}

light_source
{
	<-30,+30,-30,>
	color rgb	1
	rotate		y * 090
	parallel
	point_at 0
	shadowless
}

#local cam_aspc =	image_width/image_height;		// obsolete. render square images only!
#local cam_dist =	16;
#local cam_area =	1/3;
#local cam_loca =	-z * cam_dist;
#local cam_dirc =	+z*1.5;
#local cam_rgvc =	+x * cam_area;
#local cam_upvc =	+y * cam_area;
#local cam_tran = transform
{
	rotate		+x*30
	rotate		+y*(-65-90)
//	translate	1/2
	translate	<2/5,0,1>
}

Set_Camera_Orthographic(false)
Set_Camera_Transform(cam_tran)
Set_Camera_Alt(cam_loca, cam_dirc, cam_rgvc, cam_upvc)

/*
sky_sphere
{
	pigment
	{
		gradient y
		color_map {[0.0 srgb <0.6,0.7,1.0>][0.7 srgb <0.0,0.1,0.8>]}
	}
}
*/

//------------------------------------------------------------------------------CSG objects

box
{
	sCenter, sRadius
	pigment {color srgbt <1,1,1,1/2>}
//	hollow
//	no_shadow
}

// the coordinate grid and axes
Axes_Macro
(
	8,		// Axes_axesSize,	The distance from the origin to one of the grid's edges.	(float)
	0.125,	// Axes_majUnit,	The size of each large-unit square.	(float)
	8,		// Axes_minUnit,	The number of small-unit squares that make up a large-unit square.	(integer)
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
//	no_shadow
}

cylinder
{
	+z * 3 * MarkersScale, 0, InnerRadius
	pigment {color srgbt <0,0,1,0>}
	rotate		-x * RotateHorz
	rotate		+y * RotateVert
}

sphere
{
	+z * 3 * MarkersScale, ArrowRadius
	pigment {color srgbt <0,0,1,0>}
	rotate		-x * RotateHorz
	rotate		+y * RotateVert
}

polygon
{
	4, <0,1>, <1,1>, <1,0>, <0,0>
	pigment
	{
		image_map {png "rotation_y_45_degrees_line_color.png"}
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
		image_map {png "rotation_x_35.264_degrees_line_color.png"}
	}
	translate	<-1/2,-1/2,0>
	translate	-z * 0.0001
	scale		8 * MarkersScale
	rotate		y * 135
}
