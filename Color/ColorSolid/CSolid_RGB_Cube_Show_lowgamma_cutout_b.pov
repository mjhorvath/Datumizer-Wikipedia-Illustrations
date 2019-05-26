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
#include "screen_new.inc"		// requires the updated version available here: http://news.povray.org/povray.binaries.scene-files/thread/%3C4afccd8a%241%40news.povray.org%3E/
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

#local CSolid_cam_aspc =	image_width/image_height;
#local CSolid_cam_dist =	10;
#local CSolid_cam_area =	2;
#local CSolid_cam_loca =	-z * CSolid_cam_dist;
#local CSolid_cam_dirc =	+z;
#local CSolid_cam_rgvc =	+x * CSolid_cam_area/CSolid_cam_dist * CSolid_cam_aspc;
#local CSolid_cam_upvc =	+y * CSolid_cam_area/CSolid_cam_dist;
#local CSolid_cam_tran = transform
{
	rotate		+x * 30
	rotate		+y * 30
}
Set_Camera_Transform(CSolid_cam_tran)
Set_Camera_Orthographic(0)
Set_Camera_Alt(CSolid_cam_loca, CSolid_cam_dirc, CSolid_cam_rgvc, CSolid_cam_upvc)

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
#declare CSolid_sCutout = <1,3,4,>/5 * CSolid_sRadius;

difference
{
	box {CSolid_sCenter, CSolid_sRadius}
	#if (CSolid_simple = false)
		object {CSolid_Grid}
	#end
	box {CSolid_sCutout, CSolid_sRadius*2}
	texture
	{
		pigment {CSolid_RGBCube_Pigment}
	}
	rotate y*180
}

#if (CSolid_simple = false)
	polygon
	{
		4, <0,0,>, <1,0,>, <1,1,>, <0,1,>
		pigment {image_map {png "CSolid_Red_Short_Below.png"}}
		translate	<-1/2,-1/2>
		scale		8/3
		rotate		z * 90
		rotate		x * 90
		translate	-z * 9/8
		translate	-x * 3/8
	}
	polygon
	{
		4, <0,0,>, <1,0,>, <1,1,>, <0,1,>
		pigment {image_map {png "CSolid_Green_Short_Below.png"}}
		translate	<-1/2,-1/2>
		scale		8/3
		rotate		z * 180
		rotate		y * 90
		translate	-z * 5/8
		translate	+x * 3/8
	}
	polygon
	{
		4, <0,0,>, <1,0,>, <1,1,>, <0,1,>
		pigment {image_map {png "CSolid_Blue_Short_Below.png"}}
		translate	<-1/2,-1/2>
		scale		8/3
		rotate		z * 90
		rotate		x * 90
		rotate		y * 90
		translate	-x * 9/8
		translate	-z * 3/8
		translate	-y * 0.001
	}
	#local CSolid_diagram_overlay = polygon
	{
		4, <0,0,>, <1,0,>, <1,1,>, <0,1,>
		texture
		{
			pigment {image_map {png "CSolid_RGB_Coordinate_Inkscape.png"}}
			finish {ambient 1}
		}
		translate	<-1/2,-1/2>
		scale		3/4
	}
	#local CSolid_CameraVector = vrotate(vrotate(-z,<30,0,0,>),<0,30,0,>);
	#local CSolid_PointVector = vrotate(CSolid_sCutout,<0,180,0,>);
	#local CSolid_ScreenVector = Get_Screen_XY(CSolid_PointVector) / <image_width,image_height,>;
	#local CSolid_ScreenVector = <CSolid_ScreenVector.x, 1 - CSolid_ScreenVector.y,>;
	Screen_Object(CSolid_diagram_overlay, CSolid_ScreenVector, <0,0,>, false, 1)
#end
