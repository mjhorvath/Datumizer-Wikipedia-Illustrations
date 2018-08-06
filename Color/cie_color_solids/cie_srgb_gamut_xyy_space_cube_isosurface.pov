// Title: CIE XYY Color Solid Cube Isosurface
// Authors: Michael Horvath, Christoph Lipka
// Website: http://isometricland.net
// Created: 2017-03-10
// Updated: 2017-03-27
// This file is licensed under the terms of the CC-GNU LGPL.
// http://www.gnu.org/licenses/lgpl-2.1.html
// Illuminant =  D65
// Observer   =  2° (1931)
// +kfi0 +kff15 +kc

#version 3.7;
#declare cie_ScaleAmount	= 400;
#declare cie_RotateAmount	= 30;
#declare cie_TransAmount	= <-1/2,-1/2,-1/2>;
#declare cie_AxesScale		= 8/8;
#declare cie_cam_distance	= 17;
#declare cie_cam_planesize	= cie_cam_distance/10;
#declare cie_cam_aspectratio	= image_width/image_height;
#declare cie_paint_triangles	= true;

#include "cie_color_conversion_formulas.inc"
#include "cie_basic_scene_settings.inc"

#declare cie_fOutR = function(X,Y2,Y1) {cie_funcXYY2RGB1(X,Y2,Y1)}
#declare cie_fOutG = function(X,Y2,Y1) {cie_funcXYY2RGB2(X,Y2,Y1)}
#declare cie_fOutB = function(X,Y2,Y1) {cie_funcXYY2RGB3(X,Y2,Y1)}
#declare cie_fInpX = function(x,y,z) {x*1}
#declare cie_fInpY2 = function(x,y,z) {z*1}
#declare cie_fInpY1 = function(x,y,z) {y*100}

#declare cie_fFinal = function(X,Y2,Y1)
{
	cie_fDist
	(
		cie_fD(cie_fOutR(X,Y2,Y1)),
		cie_fD(cie_fOutG(X,Y2,Y1)),
		cie_fD(cie_fOutB(X,Y2,Y1))
	)
}

#declare cie_pigmentR = pigment
{
	function {cie_linearRGBc(cie_fOutR(cie_fInpX(x,y,z),cie_fInpY2(x,y,z),cie_fInpY1(x,y,z)))}
	color_map
	{
		[0 color rgb <0,0,0>]
		[1 color rgb <3,0,0>]
	}
}
#declare cie_pigmentG = pigment
{
	function {cie_linearRGBc(cie_fOutG(cie_fInpX(x,y,z),cie_fInpY2(x,y,z),cie_fInpY1(x,y,z)))}
	color_map
	{
		[0 color rgb <0,0,0>]
		[1 color rgb <0,3,0>]
	}
}
#declare cie_pigmentB = pigment
{
	function {cie_linearRGBc(cie_fOutB(cie_fInpX(x,y,z),cie_fInpY2(x,y,z),cie_fInpY1(x,y,z)))}
	color_map
	{
		[0 color rgb <0,0,0>]
		[1 color rgb <0,0,3>]
	}
}
#declare cie_pigmentRGB = pigment
{
	average
	pigment_map
	{
		[1 cie_pigmentR]
		[1 cie_pigmentG]
		[1 cie_pigmentB]
	}
}

#declare cie_MinFactor = 1;
#declare cie_isoShape = isosurface
{
	function {cie_fFinal(cie_fInpX(x,y,z),cie_fInpY2(x,y,z),cie_fInpY1(x,y,z))}
	threshold	0
	accuracy	0.001
	contained_by
	{
		box {-0.00001,+1.00001}
	}
//	max_gradient	50
	evaluate	15 * cie_MinFactor, 4 * cie_MinFactor, 0.7
//	all_intersections	// tried this, no help
//	max_trace	3	// tried this, no help
}

union
{
	polygon
	{
		4, <0, 0,>, <1, 0,>, <1, 1,>, <0, 1,>
		pigment {image_map {png "cie_axis_x1_y1_cube_sans.png"}}	// need to replace this
		scale		440/320
		translate	-y * ((440-320)/2 * 440/320)/440
		translate	-x * ((440-320)/2 * 440/320)/440
		rotate		+x * 90
		scale		cie_AxesScale
		translate	-y * 0.00001
	}
	polygon
	{
		4, <0, 0,>, <1, 0,>, <1, 1,>, <0, 1,>
		pigment {image_map {png "cie_axis_Y100_cube_sans.png"}}	// need to replace this
		scale		440/320
		translate	-y * ((440-320)/2 * 440/320)/440
		translate	-x * ((440-320)/2 * 440/320)/440
		scale		cie_AxesScale
		translate	-z * 0.00001
	}
	object
	{
		cie_isoShape
		pigment {cie_pigmentRGB}
		finish {cie_isoFinish}
		scale		0.9999
		translate	0.0001/2
	}
	object
	{
		cie_boxShape
//		pigment {pigmentGradY}
		pigment {color rgbt  7/8}
		finish {cie_boxFinish}
	}
//	object {cie_axesShape}
	translate	cie_TransAmount
	scale		cie_ScaleAmount
	rotate		+y * cie_RotateAmount
	rotate		+y * clock * 360
}
