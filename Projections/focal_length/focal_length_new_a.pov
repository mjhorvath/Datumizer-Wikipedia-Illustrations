// Title: Camera focal length animation
// Author: Michael Horvath, http://isometricland.net
// Created: 2015-11-19
// Updated: 2019-05-19
// This file is licensed under the terms of the GFDL.
// +kfi0 +kff18 +a0.0
// +kfi0 +kff30
// +K0.5

#version 3.7
#include "axes_macro.inc"		// Available from the POV-Ray Object Collection.
#include "screen.inc"			// Requires the updated version available here: http://news.povray.org/povray.binaries.scene-files/thread/%3C4afccd8a%241%40news.povray.org%3E/
#include "math.inc"
#include "Transforms.inc"
#declare SceneUnits = 8;

global_settings
{
	assumed_gamma	1.0
	adc_bailout	0.005
	max_trace_level	50
	charset		utf8
	ambient_light	0
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

background {color srgb <096,144,255,>/255}

#if (frame_number = 1)
	#debug "frame\tangle\tdistance\n"
#end

#if (clock = 0)
	#declare CameraAngle		= 0;
	#declare CameraRightLength	= 5/2;
	#declare CameraRight		= +x * CameraRightLength;
	#declare CameraUp		= +y * CameraRightLength;
	#declare CameraDistance		= 1024;
	#declare CameraLocation		= -z * CameraDistance;
	#declare CameraDirection	= +z * CameraDistance;
	#declare CameraString0		= str(frame_number,0,0);
	#declare CameraString1		= concat("0",chr(0176));
	#declare CameraString2		= concat(chr(8734),"m");
	#declare CameraTransform	= transform
	{
		rotate	<atand(sind(45)),45,0>
		translate y/4
	}
	#declare CameraText1		= text
	{
		ttf "verdana.ttf" CameraString1 0.01, <0,0>
		scale 0.05
	}
	#declare CameraText2		= text
	{
		ttf "verdana.ttf" CameraString2 0.01, <0,0>
		scale 0.05
	}
	Set_Camera_Orthographic(1)
	Set_Camera_Alt(CameraLocation, CameraDirection, CameraRight, CameraUp)
	Set_Camera_Transform(CameraTransform)
	#debug concat("", CameraString0, "\t", CameraString1, "\t", CameraString2, "\n")
#else
	#declare CameraAngle		= clock * 90;
	#declare CameraRightLength	= 5/2;
	#declare CameraRight		= +x * CameraRightLength;
	#declare CameraUp		= +y * CameraRightLength;
	#declare CameraDistance		= CameraRightLength/tand(CameraAngle/2)/2;
	#declare CameraLocation		= -z * CameraDistance;
	#declare CameraDirection	= +z * CameraDistance;
	#declare CameraString0		= str(frame_number,0,0);
	#declare CameraString1		= concat("", str(CameraAngle,0,0), chr(0176));
	#declare CameraString2		= concat("", str(CameraDistance*SceneUnits,0,3), "m");
	#declare CameraTransform	= transform
	{
		rotate	<atand(sind(45)),45,0>
		translate y/4
	}
	#declare CameraText1		= text
	{
		ttf "verdana.ttf" CameraString1 0.01, <0,0>
		scale 0.05
	}
	#declare CameraText2		= text
	{
		ttf "verdana.ttf" CameraString2 0.01, <0,0>
		scale 0.05
	}
	Set_Camera_Orthographic(0)
	Set_Camera_Alt(CameraLocation, CameraDirection, CameraRight, CameraUp)
	Set_Camera_Transform(CameraTransform)
	#debug concat("", CameraString0, "\t", CameraString1, "\t", CameraString2, "\n")
#end

union
{
	Screen_Object(CameraText1, <1,0>, <0.04,0.07>, true, 0.01)
	Screen_Object(CameraText2, <1,0>, <0.04,0.02>, true, 0.01)
}

camera
{
	#if (clock = 0)
		orthographic
	#end
	location		CameraLocation
	direction		CameraDirection
	up			CameraUp
	right			CameraRight
/*
	// causes screen text to disappear
	#if (clock != 0)
		focal_point		-z * sqrt(3)/2
//		focal_point		<0,0,0>
		aperture		1/16	// 0.05 ~ 1.5; // more = more blurring 
		blur_samples		128	// 4 ~ 100, more = higher quality; fewer = faster
		confidence		0.9	// how close to the correct color, 0 ~ 1, default 0.9
		variance		1/128	//(default) smallest displayable color difference
	#end
*/
	transform {CameraTransform}
}

light_source
{
	<-32,+32,-32,>
	color		rgb 1
	rotate		y * 330
	parallel
	point_at	0
	shadowless
}

light_source
{
	<-32,+32,-32,>
	color		rgb 1
	rotate		y * 090
	parallel
	point_at	0
//	shadowless
}

// the coordinate grid and axes
#declare Axes_Color = 3/4;		// Axes_color: 1/4 for dark, 3/4 for light
#declare Axes_Infinite = false;	// Axes_Infinite: are the planes infinite in every direction?

Axes_Macro
(
	50000,			// Axes_axesSize,	The distance from the origin to one of the grid's edges.			(float)
	1/SceneUnits,	// Axes_majUnit,	The size of each large-unit square.									(float)
	10,				// Axes_minUnit,	The number of small-unit squares that make up a large-unit square.	(integer)
	0.0000001,		// Axes_thickRatio,	The thickness of the grid lines, as a factor of axesSize.			(float)
	off,			// Axes_aBool,		Turns the axes on/off. 												(boolian)
	off,			// Axes_mBool,		Turns the minor units on/off. 										(boolian)
	off,			// Axes_xBool,		Turns the plane perpendicular to the x-axis on/off.					(boolian)
	on,				// Axes_yBool,		Turns the plane perpendicular to the y-axis on/off.					(boolian)
	off				// Axes_zBool,		Turns the plane perpendicular to the z-axis on/off.					(boolian)
)

object
{
	Axes_Object
//	translate -0.000001
}

merge
{
	// main structure
	intersection
	{
		plane {+x + y,0 translate +y * 3/4}
		plane {-x + y,0 translate +y * 3/4}
		box {-1, +1}
		translate	+y
		scale		1/2
	}
	// chimney
	box {<0,0,0,>,<+1/8,+8/8,+1/8>}
	// doorway and floor clip
	clipped_by
	{
		merge
		{
			box {<-1/8, +0/8, -8/8,>, <+1/8, +2/8, +8/8> inverse}
			plane {+y, -0.1}
		}
	}
	hollow
	pigment {color srgbt <1/1,1/1,1/1,1/2>}
}
