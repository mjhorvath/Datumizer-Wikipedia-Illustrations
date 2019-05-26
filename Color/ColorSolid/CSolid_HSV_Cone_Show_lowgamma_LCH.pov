//This file is licensed under the terms of the CC-LGPL

//------------------------------------------------------------------------------Scenery

#version 3.7

global_settings
{
	assumed_gamma	2.2
	ambient_light	0.3
	radiosity
	{
		brightness	0.3
		always_sample	off
		count		100
	}
}

#include "ShapeGrid_macro.inc"
#include "ColorSolid_include.inc"
#include "functions.inc"
#include "math.inc"
#declare CSolid_simple = false;

background {rgb 3/4}

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
	location		-z * CSolid_CameraDistance
	direction		+z * CSolid_CameraDistance
	right			+x * CSolid_ScreenArea * CSolid_AspectRatio
	up				+y * CSolid_ScreenArea
	rotate			+x * asind(tand(30))
//	rotate			+x * 90
	rotate			+y * 45
	translate		+y * 1/2
}


//------------------------------------------------------------------------------CSG objects

#declare CSolid_sRadius = 1 ;
#declare CSolid_sCenter = 0 ;

#declare CSolid_Grid = object
{
/*
	SGrid_Cone_Macro
	(
		6,			// DoubleConeGrid_radii,	The number of radial divisions.			(integer)
		12,			// DoubleConeGrid_longt,	The number of longitudinal divisions.		(integer)
		6,			// DoubleConeGrid_lattt,	The number of latitudinal divisions.		(integer)
		1,			// DoubleConeGrid_radius,	The radius of the double-cone.			(float)
		1,			// DoubleConeGrid_height,	The height of each half of the double-cone.	(float)
		0,			// DoubleConeGrid_center,	The center coordinates of the double-cone.	(vector)
		0.01,			// DoubleConeGrid_thickness,	The thickness of the grid lines.		(float)
		off,			// DoubleConeGrid_offset,	Determines whether the divisions are offset by half the amount (sometimes necessary when doing cut-aways at intervals matching the grid's divisions).	(boolian)
		on,
	)
*/
	// uses a cylinder for units
	SGrid_Cylinder_Macro
	(
		6,		// CylinderGrid_radii,		The number of radial divisions.	(integer)                                                                                                                        //radii,		The number of radial divisions.	(integer)
		12,		// CylinderGrid_longt,		The number of longitudinal divisions.	(integer)                                                                                                                //longt,		The number of longitudinal divisions.	(integer)
		6,		// CylinderGrid_lattt,		The number of lattitudinal divisions.	(integer)                                                                                                                //lattt,		The number of lattitudinal divisions.	(integer)
		1,		// CylinderGrid_radius,		The radius of the sphere.	(float)                                                                                                                                  //ObjectRadius,		The radius of the sphere.	(float)
		1,		// CylinderGrid_height,		The height of the cylinder.	(float)
		0,		// CylinderGrid_center,		The center coordinates of the sphere. (vector)                                                                                                                        //ObjectCenter,		The center coordinates of the sphere. (vector)
		0.01,		// CylinderGrid_thickness,	The thickness of the grid lines. (float)                                                                                                                              //LineThickness,	The thickness of the grid lines. (float)
		off,		// CylinderGrid_offset,		Determines whether the divisions are offset by half the amount (sometimes necessary when doing cut-aways at intervals matching the grid's divisions).	(boolian)//OffsetBool		Determines whether the divisions are offset by half the amount (sometimes necessary when doing cut-aways at intervals matching the grid's divisions).	(boolian)
		on,
	)
}
difference
{
	cone {CSolid_sCenter, 0, CSolid_sCenter + y, CSolid_sRadius}
	intersection
	{
		plane {x, 0 rotate y * 0}
//		plane {-y, 0 Axis_Rotate_Trans(x-z, 0)}
		plane {z, 0 rotate y * 0}
	}
	#if (CSolid_simple = false)
	object
	{
		CSolid_Grid
		rotate z * 180
		translate y * 1
	}
	#end
	texture
	{
		pigment {CSolid_HSVCylinder_Pigment}
		finish {ambient 1}
	}
	translate y * -0.25
	no_shadow
}

#if (CSolid_simple = false)
	polygon
	{
		4, <0,0,>, <1,0,>, <1,1,>, <0,1,>
		pigment {image_map {png "CSolid_Hue_Round.png"}}
		translate	<-0.5,-0.5,>
		scale		8/3
		rotate		x * 90
		rotate		y * -45
		translate	y * 0.5
		no_shadow
	}
	polygon
	{
		4, <0, 0,>, <1, 0,>, <1, 1,>, <0, 1,>
		pigment {image_map {png "CSolid_Chroma_Straight.png"}}
		translate	<-0.5,-0.5,>
		scale		8/3
		translate	-z * 0.000001
		rotate		z * 45
		rotate		y * 90
		translate	y * 0.5
		no_shadow
	}
	polygon
	{
		4, <0, 0,>, <1, 0,>, <1, 1,>, <0, 1,>
		pigment {image_map {png "CSolid_Value_Straight.png"}}
		translate	<-0.5,-0.5,>
		scale		8/3
	//	translate	-z * 0.000001
		rotate		y * 60
		translate	y * 0.5
		no_shadow
	}
#end