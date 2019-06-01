// Title: Fractal Objects Include v1.11
// Authors: Michael Horvath, http://isometricland.net
// Created: 2008/11/26
// Updated: 2019/05/30
// This file is licensed under the terms of the CC-LGPL.
// +kfi0 +kff6

#version 3.7

#include "math.inc"
#include "FracObj_include.inc"
#include "rad_def.inc"
#include "colors.inc"
#include "stones.inc"
#include "textures.inc"

#declare FracObj_Iteration_Level = frame_number;
#declare my_seed = seed(32409832);


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
		Rad_Settings(Radiosity_Final, off, off)
//		brightness 1.0/2
	}
}

background {srgb 1/4}

#declare Metal_Floor_Texture = texture
{
	pigment {color srgb 1/4}
	normal
	{
		bumps 0.1
		scale 1/1000
	}
	finish
	{
		ambient		0.3
		diffuse		0.7
		reflection	0.15
		brilliance	8
		specular	0.8
		roughness	0.1
		phong		1
	}
}

#declare Orange_Object_Texture = texture
{
	pigment {color srgb <1,1/2,0>}
	normal { agate 0.25 scale 0.15 }
	finish { phong 1 } 
	scale 1/4
}

plane
{
	+y,0
//	pigment {color srgb 1/4}
	texture {Metal_Floor_Texture}
}

sphere
{
	0, 1e+6
	inverse
	texture
	{
		pigment {color srgb 1}
		finish {emission 1}
	}
	no_image
}

light_source
{
	-x*100
	color		rgb 1
//	shadowless
	parallel
	point_at	0
	rotate		-z*60
	rotate		-y*30
}

light_source
{
	-x*100
	color		rgb 1
//	shadowless
	parallel
	point_at	0
	rotate		-z*60
	rotate		+y*60
}
/*
light_source
{
	-x*100
	color		rgb 3
	parallel
	point_at	0
	rotate		-z*60
	rotate		+y*60
}
*/
camera
{
	#local CameraDistance	= 10;
	#local ScreenArea		= cosd(45) * 3/2;
	#local AspectRatio		= image_width/image_height;
	orthographic
	location	-z*CameraDistance
	direction	+z*CameraDistance
	right		+x*ScreenArea*AspectRatio
	up			+y*ScreenArea
	rotate		+x*30
	rotate		+y*30
	translate	+y/3
	translate	-z/8
}


//------------------------------------------------------------------------------CSG objects

#local FracObj_Default_Texture = texture
{
	pigment {color srgb <1,1/2,0>}
}

// Sierpinski Tetrahedron
// The tetrahedron is 1 unit high by default; if you want the faces to be equilateral triangles, then scale the y-axis by FracObj_Sierpinski_Tetrahedron_Eql_Hgh.
// Scaling by the same amount again also produces interesting results.
// The pyramid is 1 unit high by default; if you want the faces to look like equilateral triangles when viewed from the side along the x or z axes, then scale the y-axis by FracObj_Sierpinski_Tetrahedron_Eql2D_Hgh.
object
{
	FracObj_Sierpinski_Tetrahedron(FracObj_Iteration_Level, <1,FracObj_Sierpinski_Tetrahedron_Eql_Hgh,1,>, 0)
	translate	-x/2
	translate	-z/2 * tan(pi/6)
//	texture {FracObj_Default_Texture}
	texture {Orange_Object_Texture}
}

/*
cylinder
{
	0, +x*10, 0.01
	pigment {color srgb x}
}
cylinder
{
	0, +y*10, 0.01
	pigment {color srgb y}
}
cylinder
{
	0, +z*10, 0.01
	pigment {color srgb z}
}
*/
