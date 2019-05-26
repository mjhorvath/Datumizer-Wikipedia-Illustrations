//This file is licensed under the terms of the CC-LGPL

#version 3.7

global_settings
{
	assumed_gamma	2.2
	adc_bailout		0.005
	max_trace_level	50
	charset			utf8
	ambient_light	0.1
/*
	radiosity
	{
		pretrace_start	0.08
		pretrace_end	0.01
		count			50
		error_bound		0.1
		recursion_limit	1
		normal			on
		brightness		0.1
		always_sample	yes
		gray_threshold	0.8
		media			on
	}
*/
}

#include "ShapeGrid_macro.inc"
#include "ColorSolid_include.inc"
#include "Axes_macro.inc"
#include "functions.inc"
#include "math.inc"
#declare CSolid_simple = false;
#declare CSolid_cuthalf = false;
#declare CSolid_axes = false;


//------------------------------------------------------------------------------Scenery

default
{
	finish {ambient 1 diffuse 1}
}

//background {color srgb 3/4}

light_source
{
	<-1,+1,+1,> * 100
	color srgb	1
	parallel
	shadowless
	rotate -y * 15
}
light_source
{
	<-1,+1,+1,> * 100
	color srgb	1
	parallel
	shadowless
	rotate +y * 270
	rotate -y * 15
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

camera
{
	#local CSolid_CameraDistance	= 10;
	#local CSolid_ScreenArea		= 2;
	#local CSolid_AspectRatio		= image_width/image_height;
//	orthographic
	location	-z*CSolid_CameraDistance
	direction	+z*CSolid_CameraDistance
	right		+x*CSolid_ScreenArea*CSolid_AspectRatio
	up			+y*CSolid_ScreenArea
//	rotate		+x*asind(tand(30))
//	rotate		+y*45
	rotate		+x*30
	rotate		+y*60
}


//------------------------------------------------------------------------------CSG objects

#declare CSolid_sRadius = 1 ;
#declare CSolid_sCenter = 0 ;

#declare CSolid_Grid = object
{
	SGrid_Cube_Macro
	(
		<6,6,6,>,			// SGrid_Cube_sectors,		// The number of sections along each axis.	(integer vector)
		<1,1,1,>,			// SGrid_Cube_width,		// The width of the cuboid along each axis.	(float vector)
		<0,0,0,>,			// SGrid_Cube_corner,		// The coordinates of the bottom corner.	(float vector)
		0.01,				// SphereGrid_thickness,	// The thickness of the grid lines.		(float)
		off,				// SphereGrid_offset,		// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
		off,				// SGrid_Cube_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
	)
}

difference
{
	box {CSolid_sCenter, CSolid_sRadius}
	#if (CSolid_simple = false)
		object {CSolid_Grid}
	#end
	//box {sRadius/2, sRadius}
	texture
	{
		pigment {CSolid_RGBCube_Pigment}
	}
	translate	-1/2
	rotate		+y * 180
//	no_image
}

#if (CSolid_simple = false)
	polygon
	{
		4, <0, 0,>, <1, 0,>, <1, 1,>, <0, 1,>
		pigment {image_map {png "CSolid_Red_Short_Below.png"}}
		translate	<-0.5, -0.5>
		scale		8/3
		rotate		+z * 90
		rotate		+x * 90
		translate	+x * 1/8
		translate	-y * 4/8
		translate	-z * 5/8
		translate	+y * 0.0001
	}
	polygon
	{
		4, <0, 0,>, <1, 0,>, <1, 1,>, <0, 1,>
		pigment {image_map {png "CSolid_Green_Short_Below.png"}}
		translate	<-0.5, -0.5>
		scale		8/3
		rotate		+z * 180
		rotate		+y * 90
		translate	+x * 4/8
		translate	-y * 1/8
		translate	-z * 5/8
	}
	polygon
	{
		4, <0, 0,>, <1, 0,>, <1, 1,>, <0, 1,>
		pigment {image_map {png "CSolid_Blue_Short_Below.png"}}
		translate	<-0.5, -0.5>
		scale		8/3
		rotate		+z * 90
		rotate		+x * 90
		rotate		+y * 90
		translate	-x * 5/8
		translate	-y * 4/8
		translate	+z * 1/8
		translate	-y * 0.0001
	}
	#if (CSolid_axes)
		// the coordinate grid and axes
		Axes_Macro
		(
			10,	// Axes_axesSize,	The distance from the origin to one of the grid's edges.	(float)
			1,	// Axes_majUnit,	The size of each large-unit square.	(float)
			10,	// Axes_minUnit,	The number of small-unit squares that make up a large-unit square.	(integer)
			0.0005,	// Axes_thickRatio,	The thickness of the grid lines (as a factor of axesSize).	(float)
			off,	// Axes_aBool,		Turns the axes on/off. (boolian)
			on,	// Axes_mBool,		Turns the minor units on/off. (boolian)
			off,	// Axes_xBool,		Turns the plane perpendicular to the x-axis on/off.	(boolian)
			on,	// Axes_yBool,		Turns the plane perpendicular to the y-axis on/off.	(boolian)
			off	// Axes_zBool,		Turns the plane perpendicular to the z-axis on/off.	(boolian)
		)
		object
		{
			Axes_Object
			translate -0.000001
		}
	#end
#end