// Title: Fractal Objects Include v1.10
// Author: Michael Horvath
// Homepage: http://www.geocities.com/Area51/Quadrant/3864/povray.htm
// Created: 2008/11/26
// Last Updated: 2008/11/26
// This file is licensed under the terms of the CC-LGPL.

#include "math.inc"
#include "FracObj_include.inc"


//------------------------------
// Scenery

global_settings
{
	assumed_gamma 1.0
	ambient_light 0.3
//	radiosity {brightness 0.3}
}

//background {rgb 0}

light_source
{
	x*-100
	color rgb 2/4
//	shadowless
	parallel
	rotate		z*-60
	rotate		y*-30
}

light_source
{
	x*-100
	color rgb 2/4
//	shadowless
	parallel
	rotate		z*-60
	rotate		y*+60
}

camera
{
	#local CameraDistance = 20;
//	#local ScreenArea = cosd(45) * 2;
	#local ScreenArea = cosd(45) * tand(30) * 4 * 2;
	#local AspectRatio = image_width/image_height;
	orthographic
	location -z*CameraDistance
	direction z//*CameraDistance
	right     x*ScreenArea*AspectRatio
	up        y*ScreenArea
	rotate x*asind(tand(30))
//	rotate x*30
	rotate y*45
}


//------------------------------
// CSG objects

#local Default_Texture = texture
{
	pigment {color rgb 1}
	finish {ambient 1/2}
}

// Menger Sponge
object
{
	FracObj_Menger_Sponge(2, <1,1,1,>, 0.01)
	texture {Default_Texture}
	rotate y * 180
	translate -x * 2
}

// Sierpinski Pyramid
// The pyramid is 1 unit high by default; if you want the faces to be equilateral triangles, then scale the y-axis by FracObj_Sierpinski_Pyramid_Eql_Hgh.
// Scaling by the same amount again also produces interesting results.
object
{
	FracObj_Sierpinski_Pyramid(2, <1,FracObj_Sierpinski_Pyramid_Eql_Hgh,1,>, 0.01)
	texture {Default_Texture}
	rotate y * 180
	translate -x * 2
	translate (x-z) * 1
}

// Sierpinski Tetrahedron
// The tetrahedron is 1 unit high by default; if you want the faces to be equilateral triangles, then scale the y-axis by FracObj_Sierpinski_Tetrahedron_Eql_Hgh.
// Scaling by the same amount again also produces interesting results.
object
{
	FracObj_Sierpinski_Tetrahedron(2, <1,FracObj_Sierpinski_Tetrahedron_Eql_Hgh,1,>, 0.01)
	texture {Default_Texture}
	rotate y * 180
	translate -x * 2
	translate (x-z) * 2
//	scale y * FracObj_Eql_Hgh
}
