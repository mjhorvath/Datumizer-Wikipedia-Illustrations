//This file is licensed under the terms of the CC-LGPL

//------------------------------------------------------------------------------Scenery

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
#include "functions.inc"
#include "math.inc"
#declare CSolid_simple = false;

background {rgb 3/4}

default
{
	finish {ambient 1 diffuse 1}
}

light_source
{
	<-1,+1,+1,> * 100
	color rgb	1
	parallel
	shadowless
}

light_source
{
	<-1,+1,-1,> * 100
	color rgb	1
	parallel
	shadowless
}

camera
{
	#local CSolid_CameraDistance	= 10;
	#local CSolid_ScreenArea	= 2;
	#local CSolid_AspectRatio	= image_width/image_height;
//	orthographic
	location	-z * CSolid_CameraDistance
	direction	z * CSolid_CameraDistance
	right		x * CSolid_ScreenArea*CSolid_AspectRatio
	up			y * CSolid_ScreenArea
//	rotate		x * asind(tand(30))
	rotate		x * 30
//	rotate		x * 90
	rotate		y * 30
}


//------------------------------------------------------------------------------CSG objects

#declare CSolid_Grid = object
{
	SGrid_Cube_Macro
	(
		<5,5,5,>,		// SGrid_Cube_sectors,		// The number of sections along each axis.	(integer vector)
		<1,1,1,>,		// SGrid_Cube_width,		// The width of the cuboid along each axis.	(float vector)
		<0,0,0,>,		// SGrid_Cube_corner,		// The coordinates of the bottom corner.	(float vector)
		0.01,			// SphereGrid_thickness,	// The thickness of the grid lines.		(float)
		off,			// SphereGrid_offset,		// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
		off,			// SGrid_Cube_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
	)
}

#declare CSolid_sRadius = 1 ;
#declare CSolid_sCenter = 0 ;

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
	rotate y*180
}

#if (CSolid_simple = false)
	polygon
	{
		4, <0, 0,>, <1, 0,>, <1, 1,>, <0, 1,>
		pigment {image_map {png "CSolid_Red_Short_Below.png"}}
		translate <-0.5, -0.5>
		scale 8/3
		rotate z * 90
		rotate x * 90
		translate -z * 9/8
		translate -x * 3/8
	//	translate y * 1/2
	}
	polygon
	{
		4, <0, 0,>, <1, 0,>, <1, 1,>, <0, 1,>
		pigment {image_map {png "CSolid_Green_Short_Below.png"}}
		translate <-0.5, -0.5>
		scale 8/3
		rotate z * 180
		rotate y * 90
		translate -z * 5/8
		translate +x * 3/8
	//	rotate z * 75
	//	rotate y * 90
	}
	polygon
	{
		4, <0, 0,>, <1, 0,>, <1, 1,>, <0, 1,>
		pigment {image_map {png "CSolid_Blue_Short_Below.png"}}
		translate <-0.5, -0.5>
		scale 8/3
		rotate z * 90
		rotate x * 90
		rotate y * 90
		translate -x * 9/8
		translate -z * 3/8
		translate -y * 0.001
	//	rotate z * -15
	//	rotate y * 60
	}
#end