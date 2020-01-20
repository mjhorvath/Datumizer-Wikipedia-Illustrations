// Caption: Shape grid macro
// Version: 1.17
// Authors: Michael Horvath, with formulas by And and Tor Olav Kristensen
// Website: http://isometricland.net
// Created: 2008-06-22
// Updated: 2018-08-23
// This file is licensed under the terms of the CC-LGPL.

#version 3.7;

#include "ShapeGrid_macro.inc"
#include "functions.inc"
#include "math.inc"
#include "transforms.inc"


//------------------------------
// Scenery

global_settings
{
	assumed_gamma 1.0
	ambient_light 0.3
	radiosity
	{
		brightness 0.3
	}
}

background {srgb 1}

light_source
{
	<0, 0, 0>
	color rgb	<1, 1, 1>
	translate	-x * 30
	rotate		-z * 60
	rotate		-y * 30
	parallel
	point_at 0
	shadowless
}

light_source
{
	<0, 0, 0>
	color rgb	<1, 1, 1>
	translate	-x * 30
	rotate		-z * 60
	rotate		+y * 60
	parallel
	point_at 0
	shadowless
}

sky_sphere
{
	pigment
	{
		gradient y
		color_map
		{
			[0.0 srgb <0.6,0.7,1.0>]
			[0.7 srgb <0.0,0.1,0.8>]
		}
	}
}

#local cam_aspc = image_width/image_height;		// obsolete. render square images only!
#local cam_dist = 10;
#local cam_area = 3;
#local cam_loca = -x * cam_dist;
#local cam_dirc = +x * cam_dist;
#local cam_rgvc = +z * cam_area * cam_aspc;
#local cam_upvc = +y * cam_area;
#local cam_tran = transform
{
	rotate		-z * 30
	translate	+y * 1/2
}

camera
{
	orthographic
	location	cam_loca				// position
	direction	cam_dirc				// direction of view
	right		cam_rgvc				// horizontal size of view
	up			cam_upvc				// vertical size of view
	transform {cam_tran}				// transforms
}

//------------------------------
// CSG objects

#declare ConeObject_Object = cone
{
	<0,0,0,>, 1, <0,1,0,>, 0
	translate y*0.000001
}

#declare ConeObject_Intersection = intersection
{
	plane {-z, 0 rotate -y * 60}
//	plane {-y, 0 rotate +z * 15}
	plane {+z, 0 rotate +y * 60}
}

#declare CylinderObject_Object = cylinder
{
	<0,0,0,>, <0,1,0,>, 1
	scale 0.99999
	translate y*0.000001
}

#declare CylinderObject_Intersection = intersection
{
	plane {-z, 0 rotate -y * 60}
//	plane {-y, 0 rotate +z * 15}
	plane {+z, 0 rotate +y * 60}
}

#declare SphereObject_Object = sphere {0, 1}

#declare SphereObject_Intersection = intersection
{
	plane {-z, 0 rotate -y * 60}
	plane {-y, 0 rotate +z * 15}
	plane {+z, 0 rotate +y * 60}
}

#declare BasicObject_Pigment = pigment {color srgb <1,0,0,>}


//------------------------------
// Examples using an object pattern

difference
{
	object {ConeObject_Object}
	object {ConeObject_Intersection}
	texture {BasicObject_Pigment}
	texture
	{
		pigment
		{
			object
			{
				SGrid_Cone_Macro(6,12,6,1,1,0,0.01,on,off,)
				color srgbt 1
				color srgb z
			}
		}
	}
	scale 1
	translate <-1,0,0,>
}


//------------------------------
// Examples in a difference

difference
{
	object {CylinderObject_Object}
	object {CylinderObject_Intersection}
	object {SGrid_Cylinder_Macro(6,12,6,1,1,0,0.01,on,off,)}
	texture {BasicObject_Pigment}
	scale 1
	translate <1,0,-1,>
}


//------------------------------
// Examples in an intersection

difference
{
	intersection
	{
		object {SGrid_Sphere_Macro(6,12,6,1,0,0.01,on,off,)}
		object {SphereObject_Object}
	}
	object {SphereObject_Intersection}
	texture {BasicObject_Pigment}
	scale 1
	translate <1,1/2,1,>
}
