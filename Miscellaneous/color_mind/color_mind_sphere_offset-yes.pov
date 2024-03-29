//This file is licensed under the terms of the CC-LGPL

#version 3.7

global_settings
{
	assumed_gamma	2.2
	adc_bailout		0.005
	max_trace_level	50
	charset			utf8
	ambient_light	1
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
#include "functions.inc"
#include "math.inc"
#declare CSolid_cutout	= true;
#declare CSolid_labels	= false;
#declare CSolid_axes	= false;
#declare CSolid_cuthalf	= false;


//------------------------------------------------------------------------------Scenery

default
{
	finish {ambient 1 diffuse 0}
}

background {color srgb 1}

/*
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
*/
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
	#local CSolid_ScreenArea		= 2.125;
	#local CSolid_AspectRatio		= image_width/image_height;
//	orthographic
	location	-z * CSolid_CameraDistance
	direction	+z * CSolid_CameraDistance
	right		+x * CSolid_ScreenArea * CSolid_AspectRatio
	up		+y * CSolid_ScreenArea
	rotate		+x * asind(tand(30))
//	rotate		+y * 45
//	rotate		+x * 30
	rotate		+y * 60
}


//------------------------------
// HSL Parametric Sphere

#declare CSolid_Offset = 0.000001;

#declare CSolid_Div = 6;
#declare CSolid_HSLSphere_Hue = pigment
{
	function {-(f_th(x,y,z)+pi/2/CSolid_Div)/pi/2}
	color_map
	{
		[00/12 srgb <1.0,0.0,0.0>]
		[01/12 srgb <1.0,0.0,0.0>]
		[01/12 srgb <1.0,0.5,0.0>]
		[02/12 srgb <1.0,0.5,0.0>]
		[02/12 srgb <1.0,1.0,0.0>]
		[03/12 srgb <1.0,1.0,0.0>]
		[03/12 srgb <0.5,1.0,0.0>]
		[04/12 srgb <0.5,1.0,0.0>]
		[04/12 srgb <0.0,1.0,0.0>]
		[05/12 srgb <0.0,1.0,0.0>]
		[05/12 srgb <0.0,1.0,0.5>]
		[06/12 srgb <0.0,1.0,0.5>]
		[06/12 srgb <0.0,1.0,1.0>]
		[07/12 srgb <0.0,1.0,1.0>]
		[07/12 srgb <0.0,0.5,1.0>]
		[08/12 srgb <0.0,0.5,1.0>]
		[08/12 srgb <0.0,0.0,1.0>]
		[09/12 srgb <0.0,0.0,1.0>]
		[09/12 srgb <0.5,0.0,1.0>]
		[10/12 srgb <0.5,0.0,1.0>]
		[10/12 srgb <1.0,0.0,1.0>]
		[11/12 srgb <1.0,0.0,1.0>]
		[11/12 srgb <1.0,0.0,0.5>]
		[12/12 srgb <1.0,0.0,0.5>]
	}
}

#declare CSolid_Div = 6;
#declare CSolid_HSLSphere_Saturation_stepped = function { floor(CSolid_Div * (f_r(x,y,z)+1/12))/CSolid_Div };
#declare CSolid_HSLSphere_Saturation = pigment
{
	function {CSolid_HSLSphere_Saturation_stepped(x,y,z)}
	pigment_map
	{
		[0 color srgb 1/2]
		[1 CSolid_HSLSphere_Hue]
	}
	scale	(1 + CSolid_Offset)
}

#declare CSolid_Div = 6;
#declare CSolid_HSLSphere_Lightness_stepped = function { floor(CSolid_Div * (f_ph(x,y,z)+pi/2/CSolid_Div)/pi)/CSolid_Div};
#declare CSolid_HSLSphere_Lightness = pigment
{
	function {CSolid_HSLSphere_Lightness_stepped(x,y,z)}
	pigment_map
	{
		[0/2 color srgb 1]
		[1/2 CSolid_HSLSphere_Saturation]
		[2/2 color srgb 0]
	}
}
#declare CSolid_HSLSphere_Pigment = pigment {CSolid_HSLSphere_Lightness}


//------------------------------------------------------------------------------CSG objects

#declare CSolid_Grid = object
{
	SGrid_Sphere_Macro
	(
		6,			// SphereGrid_radii,		// The number of radial divisions.	(integer)
		12,			// SphereGrid_longt,		// The number of longitudinal divisions.	(integer)
		6,			// SphereGrid_lattt,		// The number of lattitudinal divisions.	(integer)
		1,			// SphereGrid_radius,		// The radius of the sphere.	(float)
		0,			// SphereGrid_center,		// The center coordinates of the sphere. (vector)
		0.01,		// SphereGrid_thickness,	// The thickness of the grid lines. (float)
		on,			// SphereGrid_offset,		// Determines whether the divisions are offset by half the amount (sometimes necessary when doing cut-aways at intervals matching the grid's divisions).	(boolian)
		off,		// SGrid_Sphere_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
	)
}

union
{
	difference
	{
		sphere {0, 1}
		#if (CSolid_cuthalf = true)
			box {0, <-1,+1,-1,>}
		#else
			box {<+0,+1,+0,>, <-1,-1,-1,>}
		#end
		texture
		{
			pigment {CSolid_HSLSphere_Pigment}
		}
		#if (CSolid_cutout = true)
			texture
			{
				pigment
				{
					object
					{
						CSolid_Grid
						color srgbt 1
						color srgb 1
					}
				}
			}
		#end
	}
}
