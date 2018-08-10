// Title: CIE XYZ Color Solid Cube Mesh
// Authors: Michael Horvath, with formulas by Christoph Lipka
// Website: http://isometricland.net
// Created: 2017-03-29
// Updated: 2017-03-29
// This file is licensed under the terms of the CC-GNU LGPL.
// http://www.gnu.org/licenses/lgpl-2.1.html
// Illuminant =  D65
// Observer   =  2° (1931)
// +kfi0 +kff191 +kc

#version 3.7;
#declare cie_ScaleAmount	= 400;
#declare cie_RotateAmount	= 30;
#declare cie_TransAmount	= <-1/2,-1/2,-1/2>;
#declare cie_AxesScale		= 8/8;
#declare cie_cam_distance	= 17;
#declare cie_cam_planesize	= cie_cam_distance/10;
#declare cie_cam_aspectratio	= image_width/image_height;
#declare cie_paint_triangles	= true;
#declare cie_pre_xyz_srgb	= false;	// pre-populate XYZ tables on disk
#declare cie_pre_mesh_srgb	= false;	// pre-populate mesh geometry on disk
#declare cie_cspace_other	= 1;		// which color space is this?
#declare cie_mesh_file_other	= "cie_other_xyz_cub_mesh.inc";

#include "cie_color_conversion_formulas.inc"
#include "cie_basic_scene_settings.inc"
#include "cie_mesh_generation.inc"

union
{
	polygon
	{
		4, <0, 0,>, <1, 0,>, <1, 1,>, <0, 1,>
		pigment {image_map {png "cie_axis_X100_Z100_cub_sans.png"}}	// need to replace this
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
		pigment {image_map {png "cie_axis_Y100_cub_sans.png"}}	// need to replace this
		scale		440/320
		translate	-y * ((440-320)/2 * 440/320)/440
		translate	-x * ((440-320)/2 * 440/320)/440
		scale		cie_AxesScale
		translate	-z * 0.00001
	}
	object
	{
		#include cie_mesh_file_other
		scale		0.9999
		translate	0.0001/2
	}
	object
	{
		cie_boxShape
	//	pigment {pigmentGradY}
		pigment {color rgbt  7/8}
		finish {cie_boxFinish}
	}
//	object {cie_axesShape}
	translate	cie_TransAmount
	scale		cie_ScaleAmount
	rotate		+y * cie_RotateAmount
	rotate		+y * clock * 360
}
