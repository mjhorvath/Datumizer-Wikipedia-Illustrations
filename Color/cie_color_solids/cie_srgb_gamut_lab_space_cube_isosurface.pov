// Title: CIE LAB Color Solid Cube Isosurface
// Authors: Michael Horvath, Christoph Lipka
// Website: http://isometricland.net
// Created: 2016-11-20
// Updated: 2017-03-27
// This file is licensed under the terms of the CC-GNU LGPL.
// http://www.gnu.org/licenses/lgpl-2.1.html
// Illuminant =  D65
// Observer   =  2° (1931)
// +kfi0 +kff191 +kc

#version 3.7;
#declare cie_ScaleAmount	= 200;
#declare cie_RotateAmount	= 30;
#declare cie_TransAmount	= <-1/2,-1/2,-1/2>;
#declare cie_AxesScale		= 8/8;
#declare cie_cam_distance	= 17;
#declare cie_cam_planesize	= cie_cam_distance/10;
#declare cie_cam_aspectratio	= image_width/image_height;
#declare cie_paint_triangles	= true;

#include "cie_color_conversion_formulas.inc"
#include "cie_basic_scene_settings.inc"

#declare cie_fOutR = function(L,A,B) {cie_funcLAB2RGBa1(L,A,B)}
#declare cie_fOutG = function(L,A,B) {cie_funcLAB2RGBa2(L,A,B)}
#declare cie_fOutB = function(L,A,B) {cie_funcLAB2RGBa3(L,A,B)}
#declare cie_fInpX = function(x,y,z) {y*100}
#declare cie_fInpY = function(x,y,z) {x*400-200}
#declare cie_fInpZ = function(x,y,z) {z*400-200}

#include "cie_common_functions.inc"

#declare cie_isoShape = isosurface
{
	function {cie_fFinal(cie_fInpX(x,y,z),cie_fInpY(x,y,z),cie_fInpZ(x,y,z))}
	threshold	0
	accuracy	0.001
	contained_by
	{
		box {-0.00001,+1.00001}
	}
	max_gradient	50	// was 20000
}

union
{
	polygon
	{
		4, <0, 0,>, <1, 0,>, <1, 1,>, <0, 1,>
		pigment {image_map {png "cie_axis_a200_b200_cub_sans.png"}}
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
		pigment {image_map {png "cie_axis_L100_cub_sans.png"}}
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
	//	pigment {cie_pigmentGradY}
		pigment {color rgbt  7/8}
		finish {cie_boxFinish}
	}
	translate	cie_TransAmount
	scale		cie_ScaleAmount
	rotate		+y * cie_RotateAmount
	rotate		+y * clock * 360
}
