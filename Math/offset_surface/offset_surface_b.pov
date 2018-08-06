// Caption: Offset surface example
// Authors: Michael Horvath, with formulas by Tor Olav Kristensen
// Website: http://isometricland.net
// Created: 2018-07-28
// Updated: 2018-07-30
// This file is licensed under the terms of the CC-LGPL.

#version 3.7;


#include "math.inc"
#include "glass.inc"
#include "axes_macro.inc"		// http://lib.povray.org/searchcollection/index2.php?objectName=AxesAndGridMacro&contributorTag=SharkD
#include "MakeGradientMagnitudeFunction.inc"		// http://news.povray.org/povray.binaries.images/message/%3Cweb.5b5e768edce0719a79917fa00%40news.povray.org%3E/#%3Cweb.5b5e768edce0719a79917fa00%40news.povray.org%3E


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


#local cam_aspc = image_width/image_height;
#local cam_dist = 8;
#local cam_area = 2;
#local cam_loca = -z * cam_dist;
#local cam_dirc = +z * cam_dist;
#local cam_rgvc = +x * cam_area;
#local cam_upvc = +y * cam_area / cam_aspc;
#local cam_tran = transform
{
//	rotate +x * 90
//	rotate +x * atand(sind(45))
	rotate +x * 30
	rotate +y * 45
	scale 1/sind(45)
}


camera
{
//	orthographic
	location	cam_loca				// position
	direction	cam_dirc				// direction of view
	right		cam_rgvc				// horizontal size of view
	up			cam_upvc				// vertical size of view
	transform {cam_tran}				// transforms
}


background {color srgb <192,212,255,>/255}
light_source {<30, 30, -30> color rgb 1 parallel point_at 0}


#declare surf_thick = 1/8;
#declare H = 1e-4;


#declare A = 1;
#declare B = 1;
#declare C = 1;
#declare D = 1/2;

#undef f_test
#declare f_test = function {pow(x/A,2) + pow(y/B,2) + pow(z/C,2) - 1 - 0.5 * f_noise3d(x/D,y/D,z/D)}

#undef f_gradient_magnitude
#declare f_gradient_magnitude = MakeGradientMagnitudeFunction_3b(f_test, H)

#undef f_normalized
#declare f_normalized = function(x,y,z) {f_test(x,y,z)/f_gradient_magnitude(x,y,z)}


#declare MyGlassMat1 = material
{
	texture
	{
		pigment {Col_Glass_Ruby}
		finish {F_Glass5}
	}
	interior {I_Glass_Caustics1}
}

#declare MyGlassMat2 = material
{
	texture
	{
		pigment {srgbt 1}
		finish {F_Glass7}
	}
	interior
	{
		ior 1.5
//		dispersion 1.05
		fade_colour Col_Ruby
		fade_distance 0.1
		fade_power 1001
		caustics 1.0
	}
}

#declare MyCutoutMat1 = material
{
	texture
	{
		pigment {color Col_Ruby}
	}
}


difference
{
	isosurface
	{
		function {f_normalized(x,y,z)}
		accuracy		0.0001
		max_gradient	4
		all_intersections
		//evaluate P0, P1, min (P2, 1)
		contained_by {sphere {0, 2}}
		material {MyGlassMat2}
	}
	isosurface
	{
		function {f_normalized(x,y,z)+surf_thick}
		accuracy		0.0001
		max_gradient	4
		all_intersections
		//evaluate P0, P1, min (P2, 1)
		contained_by {sphere {0, 2}}
		material {MyGlassMat2}
	}
	plane
	{
		-z, 0
	}
	rotate +y * 202.5
	bounded_by {sphere {0, 2}}
	material {MyCutoutMat1}
}


// the coordinate grid and axes
Axes_Macro
(
	16,		// Axes_axesSize,	The distance from the origin to one of the grid's edges. (float)
	1/2,	// Axes_majUnit,	The size of each large-unit square. (float)
	8,		// Axes_minUnit,	The number of small-unit squares that make up a large-unit square. (integer)
	1/1024,	// Axes_thickRatio,	The thickness of the grid lines (as a factor of axesSize). (float)
	off,	// Axes_aBool,		Turns the axes on/off. (boolian)
	off,	// Axes_mBool,		Turns the minor units on/off. (boolian)
	off,	// Axes_xBool,		Turns the plane perpendicular to the x-axis on/off. (boolian)
	on,		// Axes_yBool,		Turns the plane perpendicular to the y-axis on/off. (boolian)
	off		// Axes_zBool,		Turns the plane perpendicular to the z-axis on/off. (boolian)
)


union
{
	object
	{
		Axes_Object
		translate +y * 1/4096
	}
	plane
	{
		+y, 0
		pigment {color srgb 1}
	}
	translate -y * 5/4
}
