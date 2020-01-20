// Caption: Shape grid macro
// Version: 1.17
// Authors: Michael Horvath, with formulas by And and Tor Olav Kristensen
// Website: http://isometricland.net
// Created: 2008-06-22
// Updated: 2018-08-23
// This file is licensed under the terms of the CC-LGPL.

#version 3.7;

#include "math.inc"
#include "shapes.inc"
#include "MakeGradientMagnitudeFunction.inc"		// http://news.povray.org/povray.binaries.images/message/%3Cweb.5b5e768edce0719a79917fa00%40news.povray.org%3E/#%3Cweb.5b5e768edce0719a79917fa00%40news.povray.org%3E


//--------------------------------------Debug

#declare SGrid_Debug_Flag = true;

#ifndef (SGrid_Debug_Flag) #declare SGrid_Debug_Flag = false; #end

#macro SGrid_Debug_Macro(In_Text)
	#if (SGrid_Debug_Flag = true)
		#debug In_Text
	#end
#end

#declare point_count = 1;
#declare point_array = array[point_count];

#macro SGrid_Display_Points()
	SGrid_Debug_Macro(concat("point_count = ", str(point_count,0,0), "\n"))
	#for (i, 0, point_count-1)
		#local xy_coords = point_array[i];
   		#debug concat("xy_coords: <", vstr(2,xy_coords,",",0,5), ">\n")
		sphere
		{
			<xy_coords.x,xy_coords.y,0>, 0.01
			rotate y * 90
			pigment {color rgb x+y}
		}
	#end
	SGrid_Debug_Macro("\n")
#end


//--------------------------------------Line intersection, adapted from https://stackoverflow.com/questions/20677795

#macro SGrid_Line(p1, p2)
	#local A = p1.y - p2.y;
	#local B = p2.x - p1.x;
	#local C = p1.x * p2.y - p2.x * p1.y;
	<A,B,-C>
#end

#macro SGrid_Line_Intersection(l1, l2)
	#local D  = l1.x * l2.y - l1.y * l2.x;
	#local Dx = l1.z * l2.y - l1.y * l2.z;
	#local Dy = l1.x * l2.z - l1.z * l2.x;
	#if (D != 0)
		#local out_x = Dx / D;
		#local out_y = Dy / D;
		#local out_value = <out_x,out_y,1>;
	#else
		#local out_value = <0,0,0>;
	#end
	out_value
#end


//--------------------------------------Ellipsoid latitudes

#macro SGrid_convert_geodetic_to_geocentric(radius_major, radius_minor, lat_geodetic)
	#local ellipseF = (1 - radius_minor/radius_major) / 1;
	atand(pow(1 - ellipseF, 2) * tand(lat_geodetic));
#end

#macro SGrid_convert_geodetic_to_reduced(radius_major, radius_minor, lat_geodetic)
	#local ellipseF = (1 - radius_minor/radius_major) / 1;
	atand((1 - ellipseF) * tand(lat_geodetic));
#end


//--------------------------------------Cone

#macro SGrid_Cone_Macro
	(
		SGrid_Cone_radii,	// The number of radial divisions.		(integer)
		SGrid_Cone_longt,	// The number of longitudinal divisions.	(integer)
		SGrid_Cone_latit,	// The number of lattitudinal divisions.	(integer)
		SGrid_Cone_radius,	// The radius of each cone.			(float)
		SGrid_Cone_height,	// The height of each cone.			(float)
		SGrid_Cone_center,	// The center coordinates of the double-cone.	(vector)
		SGrid_Cone_thickness,	// The thickness of the grid lines.		(float)
		SGrid_Cone_offset,	// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
		SGrid_Cone_endcap,	// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
	)

	#local SGrid_Cone_bounds = cone {0, SGrid_Cone_radius, <0,SGrid_Cone_height,0,>, 0}

	union
	{

		#local SGrid_Cone_increment = 1/SGrid_Cone_radii;
		#local SGrid_Cone_i = 0;
		#local SGrid_Cone_start = 0;
		#if (SGrid_Cone_offset = on)
			#local SGrid_Cone_start = SGrid_Cone_increment/2;
		#end
		#while (SGrid_Cone_i < SGrid_Cone_radii)
			#local SGrid_Cone_value = SGrid_Cone_radius * (SGrid_Cone_start + SGrid_Cone_i * SGrid_Cone_increment);
			#local SGrid_Cone_angle = atan2d(SGrid_Cone_value, SGrid_Cone_height);
			#local SGrid_Cone_offsl = SGrid_Cone_thickness/2 * 1/cosd(SGrid_Cone_angle);
			#local SGrid_Cone_offsv = SGrid_Cone_thickness/2 * 1/cosd(90 - SGrid_Cone_angle);
			difference
			{
				cone {0, SGrid_Cone_value + SGrid_Cone_offsl, <0,SGrid_Cone_height+SGrid_Cone_offsv,0,>, 0}
				cone {0, SGrid_Cone_value - SGrid_Cone_offsl, <0,SGrid_Cone_height-SGrid_Cone_offsv,0,>, 0}
				bounded_by {SGrid_Cone_bounds}
			}
			SGrid_Debug_Macro(concat("cone_radii_value = ", str(SGrid_Cone_value, 0, -1),"\n"))
			#local SGrid_Cone_i = SGrid_Cone_i + 1;
		#end

		#local SGrid_Cone_increment = 1/SGrid_Cone_longt;
		#local SGrid_Cone_i = 0;
		#local SGrid_Cone_start = 0;
		#if (SGrid_Cone_offset = on)
			#local SGrid_Cone_start = SGrid_Cone_increment/2;
		#end
		#while (SGrid_Cone_i < SGrid_Cone_longt)
			#local SGrid_Cone_value = 360 * (SGrid_Cone_start + SGrid_Cone_i * SGrid_Cone_increment);
			box
			{
				<2*SGrid_Cone_radius, 2*SGrid_Cone_radius, SGrid_Cone_thickness/2,>,
				<0, -2*SGrid_Cone_radius, -SGrid_Cone_thickness/2,>
				rotate y * SGrid_Cone_value
				bounded_by {SGrid_Cone_bounds}
			}
			SGrid_Debug_Macro(concat("cone_longt_value = ", str(SGrid_Cone_value, 0, -1),"\n"))
			#local SGrid_Cone_i = SGrid_Cone_i + 1;
		#end

		#local SGrid_Cone_increment = 1/SGrid_Cone_latit;
		#local SGrid_Cone_i = 0;
		#if (SGrid_Cone_endcap = on)
			#local SGrid_Cone_start = 0;
			#local SGrid_Cone_finish = SGrid_Cone_radii + 1;
		#else
			#local SGrid_Cone_start = SGrid_Cone_increment;
			#local SGrid_Cone_finish = SGrid_Cone_latit - 1;
		#end
		#if (SGrid_Cone_offset = on)
			#local SGrid_Cone_start = SGrid_Cone_increment/2;
			#local SGrid_Cone_finish = SGrid_Cone_latit;
		#end
		#while (SGrid_Cone_i < SGrid_Cone_finish)
			#local SGrid_Cone_value = SGrid_Cone_height * (SGrid_Cone_start + SGrid_Cone_i * SGrid_Cone_increment);
			box
			{
				<SGrid_Cone_radius,SGrid_Cone_thickness/2,SGrid_Cone_radius,>,
				<-SGrid_Cone_radius,-SGrid_Cone_thickness/2,-SGrid_Cone_radius,>
				bounded_by {SGrid_Cone_bounds}
				translate y * SGrid_Cone_value
			}
			SGrid_Debug_Macro(concat("cone_latit_value = ", str(SGrid_Cone_value, 0, -1),"\n"))
			#local SGrid_Cone_i = SGrid_Cone_i + 1;
		#end
		translate SGrid_Cone_center
	}
#end


//--------------------------------------Cylinder

#macro SGrid_Cylinder_Macro
	(
		SGrid_Cylinder_radii,		// The number of radial divisions.		(integer)
		SGrid_Cylinder_longt,		// The number of longitudinal divisions.	(integer)
		SGrid_Cylinder_latit,		// The number of lattitudinal divisions.	(integer)
		SGrid_Cylinder_radius,		// The radius of the cylinder.			(float)
		SGrid_Cylinder_height,		// The height of the cylinder.			(float)
		SGrid_Cylinder_center,		// The center coordinates of the cylinder.	(vector)
		SGrid_Cylinder_thickness,		// The thickness of the grid lines.		(float)
		SGrid_Cylinder_offset,		// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
		SGrid_Cylinder_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
	)

	#local SGrid_Cylinder_bounds = cylinder {0, <0,SGrid_Cylinder_height,0,>, SGrid_Cylinder_radius}

	union
	{

		#local SGrid_Cylinder_increment = 1/SGrid_Cylinder_radii;
		#local SGrid_Cylinder_i = 0;
		#local SGrid_Cylinder_start = 0;
		#if (SGrid_Cylinder_offset = on)
			#local SGrid_Cylinder_start = SGrid_Cylinder_increment/2;
		#end
		#while (SGrid_Cylinder_i < SGrid_Cylinder_radii)
			#local SGrid_Cylinder_value = SGrid_Cylinder_radius * (SGrid_Cylinder_start + SGrid_Cylinder_i * SGrid_Cylinder_increment);
			difference
			{
				cylinder {0, y, SGrid_Cylinder_value + SGrid_Cylinder_thickness/2}
				cylinder {0, y, SGrid_Cylinder_value - SGrid_Cylinder_thickness/2}
				bounded_by {SGrid_Cylinder_bounds}
			}
			SGrid_Debug_Macro(concat("cylinder_radii_value = ", str(SGrid_Cylinder_value, 0, -1),"\n"))
			#local SGrid_Cylinder_i = SGrid_Cylinder_i + 1;
		#end

		#local SGrid_Cylinder_increment = 1/SGrid_Cylinder_longt;
		#local SGrid_Cylinder_i = 0;
		#local SGrid_Cylinder_start = 0;
		#if (SGrid_Cylinder_offset = on)
			#local SGrid_Cylinder_start = SGrid_Cylinder_increment/2;
		#end
		#while (SGrid_Cylinder_i < SGrid_Cylinder_longt)
			#local SGrid_Cylinder_value = 360 * (SGrid_Cylinder_start + SGrid_Cylinder_i * SGrid_Cylinder_increment);
			box
			{
				<2*SGrid_Cylinder_radius, 2*SGrid_Cylinder_radius, SGrid_Cylinder_thickness/2,>,
				<0, -2*SGrid_Cylinder_radius, -SGrid_Cylinder_thickness/2,>
				rotate y * SGrid_Cylinder_value
			}
			SGrid_Debug_Macro(concat("cylinder_logt_value = ", str(SGrid_Cylinder_value, 0, -1),"\n"))
			#local SGrid_Cylinder_i = SGrid_Cylinder_i + 1;
		#end

		#local SGrid_Cylinder_increment = 1/SGrid_Cylinder_latit;
		#local SGrid_Cylinder_i = 0;
		#if (SGrid_Cylinder_endcap = on)
			#local SGrid_Cylinder_start = 0;
			#local SGrid_Cylinder_finish = SGrid_Cylinder_latit + 1;
		#else
			#local SGrid_Cylinder_start = SGrid_Cylinder_increment;
			#local SGrid_Cylinder_finish = SGrid_Cylinder_latit - 1;
		#end
		#if (SGrid_Cylinder_offset = on)
			#local SGrid_Cylinder_start = SGrid_Cylinder_increment/2;
			#local SGrid_Cylinder_finish = SGrid_Cylinder_latit;
		#end
		#while (SGrid_Cylinder_i < SGrid_Cylinder_finish)
			#local SGrid_Cylinder_value = SGrid_Cylinder_height * (SGrid_Cylinder_start + SGrid_Cylinder_i * SGrid_Cylinder_increment);
			box
			{
				<-2*SGrid_Cylinder_radius, -SGrid_Cylinder_thickness/2, -2*SGrid_Cylinder_radius,>,
				<2*SGrid_Cylinder_radius, SGrid_Cylinder_thickness/2, 2*SGrid_Cylinder_radius,>
				translate y * SGrid_Cylinder_value
				bounded_by {SGrid_Cylinder_bounds}
			}
			SGrid_Debug_Macro(concat("cylinder_latit_value = ", str(SGrid_Cylinder_value, 0, -1),"\n"))
			#local SGrid_Cylinder_i = SGrid_Cylinder_i + 1;
		#end
		translate SGrid_Cylinder_center
	}
#end


//--------------------------------------Double cone

#macro SGrid_DblCone_Macro
	(
		SGrid_DblCone_radii,		// The number of radial divisions.		(integer)
		SGrid_DblCone_longt,		// The number of longitudinal divisions.	(integer)
		SGrid_DblCone_latit,		// The number of lattitudinal divisions.	(integer)
		SGrid_DblCone_radius,		// The radius of each cone.			(float)
		SGrid_DblCone_height,		// The height of each cone.			(float)
		SGrid_DblCone_center,		// The center coordinates of the double-cone.	(vector)
		SGrid_DblCone_thickness,	// The thickness of the grid lines.		(float)
		SGrid_DblCone_offset,		// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
		SGrid_DblCone_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
	)

	#local SGrid_DblCone_bounds = union
	{
		cone {0, SGrid_DblCone_radius, <0,+SGrid_DblCone_height,0,>, 0}
		cone {0, SGrid_DblCone_radius, <0,-SGrid_DblCone_height,0,>, 0}
	}

	union
	{

		#local SGrid_DblCone_increment = 1/SGrid_DblCone_radii;
		#local SGrid_DblCone_i = 0;
		#local SGrid_DblCone_start = 0;
		#if (SGrid_DblCone_offset = on)
			#local SGrid_DblCone_start = SGrid_DblCone_increment/2;
		#end
		#while (SGrid_DblCone_i < SGrid_DblCone_radii)
			#local SGrid_DblCone_value = SGrid_DblCone_radius * (SGrid_DblCone_start + SGrid_DblCone_i * SGrid_DblCone_increment);
			#local SGrid_DblCone_angle = atan2d(SGrid_DblCone_value, SGrid_DblCone_height);
			#local SGrid_DblCone_offsl = SGrid_DblCone_thickness/2 * 1/cosd(SGrid_DblCone_angle);
			#local SGrid_DblCone_offsv = SGrid_DblCone_thickness/2 * 1/cosd(90 - SGrid_DblCone_angle);
			difference
			{
				union
				{
					cone {0, SGrid_DblCone_value + SGrid_DblCone_offsl, <0,+SGrid_DblCone_height+SGrid_DblCone_offsv,0,>, 0}
					cone {0, SGrid_DblCone_value + SGrid_DblCone_offsl, <0,-SGrid_DblCone_height-SGrid_DblCone_offsv,0,>, 0}
				}
				union
				{
					cone {0, SGrid_DblCone_value - SGrid_DblCone_offsl, <0,+SGrid_DblCone_height-SGrid_DblCone_offsv,0,>, 0}
					cone {0, SGrid_DblCone_value - SGrid_DblCone_offsl, <0,-SGrid_DblCone_height+SGrid_DblCone_offsv,0,>, 0}
				}
				bounded_by {SGrid_DblCone_bounds}
			}
			SGrid_Debug_Macro(concat("radii_value = ", str(SGrid_DblCone_value, 0, -1),"\n"))
			#local SGrid_DblCone_i = SGrid_DblCone_i + 1;
		#end

		#local SGrid_DblCone_increment = 1/SGrid_DblCone_longt;
		#local SGrid_DblCone_i = 0;
		#local SGrid_DblCone_start = 0;
		#if (SGrid_DblCone_offset = on)
			#local SGrid_DblCone_start = SGrid_DblCone_increment/2;
		#end
		#while (SGrid_DblCone_i < SGrid_DblCone_longt)
			#local SGrid_DblCone_value = 360 * (SGrid_DblCone_start + SGrid_DblCone_i * SGrid_DblCone_increment);
			box
			{
				<2*SGrid_DblCone_radius, 2*SGrid_DblCone_radius, SGrid_DblCone_thickness/2,>,
				<0, -2*SGrid_DblCone_radius, -SGrid_DblCone_thickness/2,>
				rotate y * SGrid_DblCone_value
				bounded_by {SGrid_DblCone_bounds}
			}
			SGrid_Debug_Macro(concat("longt_value = ", str(SGrid_DblCone_value, 0, -1),"\n"))
			#local SGrid_DblCone_i = SGrid_DblCone_i + 1;
		#end

		#local SGrid_DblCone_increment = 1/SGrid_DblCone_latit;
		#local SGrid_DblCone_i = 0;
		#if (SGrid_DblCone_endcap = on)
			#local SGrid_DblCone_start = 0;
			#local SGrid_DblCone_finish = SGrid_DblCone_latit + 1;
		#else
			#local SGrid_DblCone_start = SGrid_DblCone_increment;
			#local SGrid_DblCone_finish = SGrid_DblCone_latit - 1;
		#end
		#if (SGrid_DblCone_offset = on)
			#local SGrid_DblCone_start = SGrid_DblCone_increment/2;
			#local SGrid_DblCone_finish = SGrid_DblCone_latit;
		#end
		#while (SGrid_DblCone_i < SGrid_DblCone_finish)
			#local SGrid_DblCone_value = -SGrid_DblCone_height + 2*SGrid_DblCone_height * (SGrid_DblCone_start + SGrid_DblCone_i * SGrid_DblCone_increment);
			box
			{
				<SGrid_DblCone_radius,SGrid_DblCone_thickness/2,SGrid_DblCone_radius,>,
				<-SGrid_DblCone_radius,-SGrid_DblCone_thickness/2,-SGrid_DblCone_radius,>
				bounded_by {SGrid_DblCone_bounds}
				translate y * SGrid_DblCone_value
			}
			SGrid_Debug_Macro(concat("lattt_value = ", str(SGrid_DblCone_value, 0, -1),"\n"))
			#local SGrid_DblCone_i = SGrid_DblCone_i + 1;
		#end
		translate SGrid_DblCone_center
	}
#end


//--------------------------------------Double cone inverted

#macro SGrid_DblConeInv_Macro
	(
		SGrid_DblConeInv_radii,		// The number of radial divisions.		(integer)
		SGrid_DblConeInv_longt,		// The number of longitudinal divisions.	(integer)
		SGrid_DblConeInv_latit,		// The number of lattitudinal divisions.	(integer)
		SGrid_DblConeInv_radius,	// The radius of each cone.			(float)
		SGrid_DblConeInv_height,	// The height of each cone.			(float)
		SGrid_DblConeInv_center,	// The center coordinates of the double-cone.	(vector)
		SGrid_DblConeInv_thickness,	// The thickness of the grid lines.		(float)
		SGrid_DblConeInv_offset,	// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
		SGrid_DblConeInv_endcap,	// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
	)

	#local SGrid_DblConeInv_bounds = union
	{
		cone {0, 0, <0,+SGrid_DblConeInv_height,0,>, SGrid_DblConeInv_radius}
		cone {0, 0, <0,-SGrid_DblConeInv_height,0,>, SGrid_DblConeInv_radius}
	}

	union
	{

		#local SGrid_DblConeInv_increment = 1/SGrid_DblConeInv_radii;
		#local SGrid_DblConeInv_i = 0;
		#local SGrid_DblConeInv_start = 0;
		#if (SGrid_DblConeInv_offset = on)
			#local SGrid_DblConeInv_start = SGrid_DblConeInv_increment/2;
		#end
		#while (SGrid_DblConeInv_i < SGrid_DblConeInv_radii)
			#local SGrid_DblConeInv_value = SGrid_DblConeInv_radius * (SGrid_DblConeInv_start + SGrid_DblConeInv_i * SGrid_DblConeInv_increment);
			#local SGrid_DblConeInv_angle = atan2d(SGrid_DblConeInv_value, SGrid_DblConeInv_height);
			#local SGrid_DblConeInv_offsl = SGrid_DblConeInv_thickness/2 * 1/cosd(SGrid_DblConeInv_angle);
			#local SGrid_DblConeInv_offsv = SGrid_DblConeInv_thickness/2 * 1/cosd(90 - SGrid_DblConeInv_angle);
			difference
			{
				union
				{
					cone {<0,-SGrid_DblConeInv_offsv,0,>, 0, <0,+SGrid_DblConeInv_height,0,>, SGrid_DblConeInv_value + SGrid_DblConeInv_offsl}
					cone {<0,+SGrid_DblConeInv_offsv,0,>, 0, <0,-SGrid_DblConeInv_height,0,>, SGrid_DblConeInv_value + SGrid_DblConeInv_offsl}
				}
				union
				{
					cone {<0,+SGrid_DblConeInv_offsv,0,>, 0, <0,+SGrid_DblConeInv_height,0,>, SGrid_DblConeInv_value - SGrid_DblConeInv_offsl}
					cone {<0,-SGrid_DblConeInv_offsv,0,>, 0, <0,-SGrid_DblConeInv_height,0,>, SGrid_DblConeInv_value - SGrid_DblConeInv_offsl}
				}
				bounded_by {SGrid_DblConeInv_bounds}
			}
			SGrid_Debug_Macro(concat("radii_value = ", str(SGrid_DblConeInv_value, 0, -1),"\n"))
			#local SGrid_DblConeInv_i = SGrid_DblConeInv_i + 1;
		#end

		#local SGrid_DblConeInv_increment = 1/SGrid_DblConeInv_longt;
		#local SGrid_DblConeInv_i = 0;
		#local SGrid_DblConeInv_start = 0;
		#if (SGrid_DblConeInv_offset = on)
			#local SGrid_DblConeInv_start = SGrid_DblConeInv_increment/2;
		#end
		#while (SGrid_DblConeInv_i < SGrid_DblConeInv_longt)
			#local SGrid_DblConeInv_value = 360 * (SGrid_DblConeInv_start + SGrid_DblConeInv_i * SGrid_DblConeInv_increment);
			box
			{
				<2*SGrid_DblConeInv_radius, 2*SGrid_DblConeInv_radius, SGrid_DblConeInv_thickness/2,>,
				<0, -2*SGrid_DblConeInv_radius, -SGrid_DblConeInv_thickness/2,>
				rotate y * SGrid_DblConeInv_value
				bounded_by {SGrid_DblConeInv_bounds}
			}
			SGrid_Debug_Macro(concat("longt_value = ", str(SGrid_DblConeInv_value, 0, -1),"\n"))
			#local SGrid_DblConeInv_i = SGrid_DblConeInv_i + 1;
		#end

		#local SGrid_DblConeInv_increment = 1/SGrid_DblConeInv_latit;
		#local SGrid_DblConeInv_i = 0;
		#if (SGrid_DblConeInv_endcap = on)
			#local SGrid_DblConeInv_start = 0;
			#local SGrid_DblConeInv_finish = SGrid_DblConeInv_latit + 1;
		#else
			#local SGrid_DblConeInv_start = SGrid_DblConeInv_increment;
			#local SGrid_DblConeInv_finish = SGrid_DblConeInv_latit - 1;
		#end
		#if (SGrid_DblConeInv_offset = on)
			#local SGrid_DblConeInv_start = SGrid_DblConeInv_increment/2;
			#local SGrid_DblConeInv_finish = SGrid_DblConeInv_latit;
		#end
		#while (SGrid_DblConeInv_i < SGrid_DblConeInv_finish)
			#local SGrid_DblConeInv_value = -SGrid_DblConeInv_height + 2*SGrid_DblConeInv_height * (SGrid_DblConeInv_start + SGrid_DblConeInv_i * SGrid_DblConeInv_increment);
			box
			{
				<SGrid_DblConeInv_radius,SGrid_DblConeInv_thickness/2,SGrid_DblConeInv_radius,>,
				<-SGrid_DblConeInv_radius,-SGrid_DblConeInv_thickness/2,-SGrid_DblConeInv_radius,>
				bounded_by {SGrid_DblConeInv_bounds}
				translate y * SGrid_DblConeInv_value
			}
			SGrid_Debug_Macro(concat("lattt_value = ", str(SGrid_DblConeInv_value, 0, -1),"\n"))
			#local SGrid_DblConeInv_i = SGrid_DblConeInv_i + 1;
		#end
		translate SGrid_DblConeInv_center
	}
#end


//--------------------------------------Sphere

#macro SGrid_Sphere_Macro
	(
		SGrid_Sphere_radii,		// The number of radial divisions.		(integer)
		SGrid_Sphere_longt,		// The number of longitudinal divisions.	(integer)
		SGrid_Sphere_latit,		// The number of lattitudinal divisions.	(integer)
		SGrid_Sphere_radius,		// The radius of the sphere.			(float)
		SGrid_Sphere_center,		// The center coordinates of the sphere.	(vector)
		SGrid_Sphere_thickness,		// The thickness of the grid lines.		(float)
		SGrid_Sphere_offset,		// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
		SGrid_Sphere_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
		SGrid_Sphere_hole,		// Put a hole in the middle?	(boolean)
	)

	#local SGrid_Sphere_bounds = sphere {0, SGrid_Sphere_radius}

	union
	{
		// radii
		#local SGrid_Sphere_increment = 1/SGrid_Sphere_radii;
		#if (SGrid_Sphere_offset = off)
			#local SGrid_Sphere_start = 0;
		#else
			#local SGrid_Sphere_start = SGrid_Sphere_increment/2;
		#end
		#for (SGrid_Sphere_i, 0, SGrid_Sphere_radii - 1)
			#local SGrid_Sphere_value = SGrid_Sphere_radius * (SGrid_Sphere_start + SGrid_Sphere_i * SGrid_Sphere_increment);
			difference
			{
				sphere {0, SGrid_Sphere_value + SGrid_Sphere_thickness/2}
				sphere {0, SGrid_Sphere_value - SGrid_Sphere_thickness/2}
				bounded_by {SGrid_Sphere_bounds}
			}
			SGrid_Debug_Macro(concat("radii_value = ", str(SGrid_Sphere_value, 0, -1),"\n"))
		#end

		// longitude
		#local SGrid_Sphere_increment = 1/SGrid_Sphere_longt;
		#if (SGrid_Sphere_offset = off)
			#local SGrid_Sphere_start = 0;
		#else
			#local SGrid_Sphere_start = SGrid_Sphere_increment/2;
		#end
		#for (SGrid_Sphere_i, 0, SGrid_Sphere_longt - 1)
			#local SGrid_Sphere_value = 360 * (SGrid_Sphere_start + SGrid_Sphere_i * SGrid_Sphere_increment);
			box
			{
				<2*SGrid_Sphere_radius, 2*SGrid_Sphere_radius, SGrid_Sphere_thickness/2,>,
				<0, -2*SGrid_Sphere_radius, -SGrid_Sphere_thickness/2,>
				rotate y * SGrid_Sphere_value
//				bounded_by {SGrid_Sphere_bounds}
			}
			SGrid_Debug_Macro(concat("longt_value = ", str(SGrid_Sphere_value, 0, -1),"\n"))
		#end

		// latitude
		#local SGrid_Sphere_increment = 1/SGrid_Sphere_latit;
		#if (SGrid_Sphere_endcap = on)
			#local SGrid_Sphere_start = 0;
			#local SGrid_Sphere_finish = SGrid_Sphere_latit + 1;
			#local SGrid_Sphere_center_gap = 0;
		#else
			#local SGrid_Sphere_start = SGrid_Sphere_increment;
			#local SGrid_Sphere_finish = SGrid_Sphere_latit - 1;
		#end
		#if (SGrid_Sphere_offset = on)
			#local SGrid_Sphere_start = SGrid_Sphere_increment/2;
			#local SGrid_Sphere_finish = SGrid_Sphere_latit;
		#end
		#for (SGrid_Sphere_i, 0, SGrid_Sphere_finish - 1)
			#local SGrid_Sphere_value = 180 * (SGrid_Sphere_start + SGrid_Sphere_i * SGrid_Sphere_increment);
			#if (SGrid_Sphere_i < (SGrid_Sphere_finish - 1)/2)
				difference
				{
					cone
					{
						0, 0, 2*SGrid_Sphere_radius*y, 2*SGrid_Sphere_radius*abs(tand(SGrid_Sphere_value))
						translate SGrid_Sphere_radius*-y * 1/abs(sind(SGrid_Sphere_value)) * SGrid_Sphere_thickness/2
					}
					cone
					{
						0, 0, 2*SGrid_Sphere_radius*y, 2*SGrid_Sphere_radius*abs(tand(SGrid_Sphere_value))
						translate SGrid_Sphere_radius*+y * 1/abs(sind(SGrid_Sphere_value)) * SGrid_Sphere_thickness/2
					}
					bounded_by {SGrid_Sphere_bounds}
				}
			#elseif (SGrid_Sphere_i = (SGrid_Sphere_finish - 1)/2)
				cylinder
				{
					<0,-SGrid_Sphere_thickness/2,0,>, <0,+SGrid_Sphere_thickness/2,0,>, 2*SGrid_Sphere_radius
					bounded_by {SGrid_Sphere_bounds}
				}
			#else
				difference
				{
					cone
					{
						0, 0, 2*SGrid_Sphere_radius*-y, 2*SGrid_Sphere_radius*abs(tand(SGrid_Sphere_value))
						translate SGrid_Sphere_radius*+y * 1/abs(sind(SGrid_Sphere_value)) * SGrid_Sphere_thickness/2
					}
					cone
					{
						0, 0, 2*SGrid_Sphere_radius*-y, 2*SGrid_Sphere_radius*abs(tand(SGrid_Sphere_value))
						translate SGrid_Sphere_radius*-y * 1/abs(sind(SGrid_Sphere_value)) * SGrid_Sphere_thickness/2
					}
					bounded_by {SGrid_Sphere_bounds}
				}
			#end
			SGrid_Debug_Macro(concat("lattt_value = ", str(SGrid_Sphere_value, 0, -1),"\n"))
		#end
		translate SGrid_Sphere_center
	}
#end


//--------------------------------------Ellipsoid (parametric)

#macro SGrid_Ellipsoid_Macro
	(
		SGrid_Ellipsoid_radii,			// The number of radial divisions.			(integer)
		SGrid_Ellipsoid_longt,			// The number of longitudinal divisions.	(integer)
		SGrid_Ellipsoid_latit,			// The number of lattitudinal divisions.	(integer)
		SGrid_Ellipsoid_radius_major,	// The radius of the sphere.				(float)
		SGrid_Ellipsoid_radius_minor,	// The radius of the sphere.				(float)
		SGrid_Ellipsoid_center,			// The center coordinates of the sphere.	(vector)
		SGrid_Ellipsoid_thickness,		// The thickness of the grid lines.			(float)
		SGrid_Ellipsoid_offset,			// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
		SGrid_Ellipsoid_endcap,			// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 		(boolian)
	)

	#local SGrid_Ellipsoid_ratio = SGrid_Ellipsoid_radius_minor/SGrid_Ellipsoid_radius_major;
	#local SGrid_Ellipsoid_bounds = sphere {0, SGrid_Ellipsoid_radius_major scale <1,SGrid_Ellipsoid_ratio,1>}
	#local SGrid_Ellipsoid_focal_distance = cosd(asind(SGrid_Ellipsoid_ratio)) * SGrid_Ellipsoid_radius_major;
	#local SGrid_Ellipsoid_H = 1e-4;

	union
	{

		// radius
		#local SGrid_Ellipsoid_increment = 1/SGrid_Ellipsoid_radii;
		#local SGrid_Ellipsoid_i = 0;
		#if (SGrid_Ellipsoid_offset = on)
			#local SGrid_Ellipsoid_start = SGrid_Ellipsoid_increment/2;
			#local SGrid_Ellipsoid_finish = SGrid_Ellipsoid_radii;
		#elseif (SGrid_Ellipsoid_endcap = on)
			#local SGrid_Ellipsoid_start = 0;
			#local SGrid_Ellipsoid_finish = SGrid_Ellipsoid_radii + 1;
		#else
			#local SGrid_Ellipsoid_start = SGrid_Ellipsoid_increment;
			#local SGrid_Ellipsoid_finish = SGrid_Ellipsoid_radii - 1;
		#end
		#while (SGrid_Ellipsoid_i < SGrid_Ellipsoid_finish)
			// formula: x^2 / (c^2 + b^2) + y^2 / b^2 = 1
			// formula: b = sinh(mu) * c
			// to do: do something when endcap is enabled and SGrid_Ellipsoid_i = 0
			#if (SGrid_Ellipsoid_i != 0)
				#local SGrid_Ellipsoid_step = SGrid_Ellipsoid_start + SGrid_Ellipsoid_i * SGrid_Ellipsoid_increment;
				#local SGrid_Ellipsoid_vert = sinh(SGrid_Ellipsoid_step) * SGrid_Ellipsoid_focal_distance;
				#local SGrid_Ellipsoid_b_sq = pow(SGrid_Ellipsoid_vert,2);
				#local SGrid_Ellipsoid_c_sq = pow(SGrid_Ellipsoid_focal_distance,2);
				#undef SGrid_Ellipsoid_func_ellipsoid
				#local SGrid_Ellipsoid_func_ellipsoid = function(x,y,z) {pow(x,2)/(SGrid_Ellipsoid_c_sq+SGrid_Ellipsoid_b_sq)+pow(y,2)/SGrid_Ellipsoid_b_sq+pow(z,2)/(SGrid_Ellipsoid_c_sq+SGrid_Ellipsoid_b_sq)-1}
				#undef SGrid_Ellipsoid_func_gradient_magnitude
				#local SGrid_Ellipsoid_func_gradient_magnitude = MakeGradientMagnitudeFunction_3b(SGrid_Ellipsoid_func_ellipsoid, SGrid_Ellipsoid_H)
				#undef SGrid_Ellipsoid_func_normalized
				#local SGrid_Ellipsoid_func_normalized = function(x,y,z) {SGrid_Ellipsoid_func_ellipsoid(x,y,z)/SGrid_Ellipsoid_func_gradient_magnitude(x,y,z)}
	
				#local SGrid_Ellipsoid_Iso_1 = isosurface
				{
					function {SGrid_Ellipsoid_func_normalized(x,y,z)-SGrid_Ellipsoid_thickness/2}
					accuracy		0.001
					max_gradient	4
					all_intersections
					//evaluate P0, P1, min (P2, 1)
					contained_by {sphere {0, SGrid_Ellipsoid_radius_major}}
				}
				#local SGrid_Ellipsoid_Iso_2 = isosurface
				{
					function {SGrid_Ellipsoid_func_normalized(x,y,z)+SGrid_Ellipsoid_thickness/2}
					accuracy		0.001
					max_gradient	4
					all_intersections
					//evaluate P0, P1, min (P2, 1)
					contained_by {sphere {0, SGrid_Ellipsoid_radius_major}}
				}
	
				difference
				{
					object {SGrid_Ellipsoid_Iso_1}
					object {SGrid_Ellipsoid_Iso_2}
					bounded_by {SGrid_Ellipsoid_bounds}
				}
			#end
			#local SGrid_Ellipsoid_i = SGrid_Ellipsoid_i + 1;
		#end

		// longitude
		#local SGrid_Ellipsoid_increment = 1/SGrid_Ellipsoid_longt;
		#local SGrid_Ellipsoid_i = 0;
		#local SGrid_Ellipsoid_start = 0;
		#if (SGrid_Ellipsoid_offset = on)
			#local SGrid_Ellipsoid_start = SGrid_Ellipsoid_increment/2;
		#end
		#while (SGrid_Ellipsoid_i < SGrid_Ellipsoid_longt)
			#local SGrid_Ellipsoid_value = 360 * (SGrid_Ellipsoid_start + SGrid_Ellipsoid_i * SGrid_Ellipsoid_increment);
			box
			{
				<2*SGrid_Ellipsoid_radius_major, 2*SGrid_Ellipsoid_radius_major, SGrid_Ellipsoid_thickness/2,>,
				<0, -2*SGrid_Ellipsoid_radius_major, -SGrid_Ellipsoid_thickness/2,>
				rotate y * SGrid_Ellipsoid_value
				bounded_by {SGrid_Ellipsoid_bounds}
			}
			SGrid_Debug_Macro(concat("longt_value = ", str(SGrid_Ellipsoid_value, 0, -1),"\n"))
			#local SGrid_Ellipsoid_i = SGrid_Ellipsoid_i + 1;
		#end

		// latitude
		#local SGrid_Ellipsoid_increment = 1/SGrid_Ellipsoid_latit;
		#local SGrid_Ellipsoid_i = 0;
		#if (SGrid_Ellipsoid_offset = on)
			#local SGrid_Ellipsoid_start = SGrid_Ellipsoid_increment/2;
			#local SGrid_Ellipsoid_finish = SGrid_Ellipsoid_latit;
		#elseif (SGrid_Ellipsoid_endcap = on)
			#local SGrid_Ellipsoid_start = 0;
			#local SGrid_Ellipsoid_finish = SGrid_Ellipsoid_latit + 1;
		#else
			#local SGrid_Ellipsoid_start = SGrid_Ellipsoid_increment;
			#local SGrid_Ellipsoid_finish = SGrid_Ellipsoid_latit - 1;
		#end
		#while (SGrid_Ellipsoid_i < SGrid_Ellipsoid_finish)
			// formula: x^2 / a^2 - y^2 / (c^2 - a^2) = 1
			// formula: a = cos(nu) * c
			// to do: do something when endcap is enabled and SGrid_Ellipsoid_i = 0
			#if (SGrid_Ellipsoid_i != 0)
				#local SGrid_Ellipsoid_step = SGrid_Ellipsoid_start + SGrid_Ellipsoid_i * SGrid_Ellipsoid_increment;
				#local SGrid_Ellipsoid_horz = cosd(90 * SGrid_Ellipsoid_step) * SGrid_Ellipsoid_focal_distance;
				#local SGrid_Ellipsoid_a_sq = pow(SGrid_Ellipsoid_horz,2);
				#local SGrid_Ellipsoid_c_sq = pow(SGrid_Ellipsoid_focal_distance,2);
				#undef SGrid_Ellipsoid_func_hyperboloid
				#local SGrid_Ellipsoid_func_hyperboloid = function(x,y,z) {pow(x,2)/SGrid_Ellipsoid_a_sq-pow(y,2)/(SGrid_Ellipsoid_c_sq-SGrid_Ellipsoid_a_sq)+pow(z,2)/SGrid_Ellipsoid_a_sq-1}
				#undef SGrid_Ellipsoid_func_gradient_magnitude
				#local SGrid_Ellipsoid_func_gradient_magnitude = MakeGradientMagnitudeFunction_3b(SGrid_Ellipsoid_func_hyperboloid, SGrid_Ellipsoid_H)
				#undef SGrid_Ellipsoid_func_normalized
				#local SGrid_Ellipsoid_func_normalized = function(x,y,z) {SGrid_Ellipsoid_func_hyperboloid(x,y,z)/SGrid_Ellipsoid_func_gradient_magnitude(x,y,z)}
	
				#local SGrid_Ellipsoid_Iso_1 = isosurface
				{
					function {SGrid_Ellipsoid_func_normalized(x,y,z)-SGrid_Ellipsoid_thickness/2}
					accuracy		0.001
					max_gradient	4
					all_intersections
					//evaluate P0, P1, min (P2, 1)
					contained_by {sphere {0, SGrid_Ellipsoid_radius_major}}
				}
				#local SGrid_Ellipsoid_Iso_2 = isosurface
				{
					function {SGrid_Ellipsoid_func_normalized(x,y,z)+SGrid_Ellipsoid_thickness/2}
					accuracy		0.001
					max_gradient	4
					all_intersections
					//evaluate P0, P1, min (P2, 1)
					contained_by {sphere {0, SGrid_Ellipsoid_radius_major}}
				}
	
				difference
				{
					object {SGrid_Ellipsoid_Iso_1}
					object {SGrid_Ellipsoid_Iso_2}
					bounded_by {SGrid_Ellipsoid_bounds}
				}
			#end
			#local SGrid_Ellipsoid_i = SGrid_Ellipsoid_i + 1;
		#end

		translate SGrid_Ellipsoid_center
	}
#end


//--------------------------------------Ellipsoid (geodetic)

#macro SGrid_Geodetic_Macro
	(
		SGrid_Geodetic_radii,			// The number of radial divisions.			(integer)
		SGrid_Geodetic_longt,			// The number of longitudinal divisions.	(integer)
		SGrid_Geodetic_latit,			// The number of lattitudinal divisions.	(integer)
		SGrid_Geodetic_radius_major,	// The radius of the sphere.				(float)
		SGrid_Geodetic_radius_minor,	// The radius of the sphere.				(float)
		SGrid_Geodetic_center,		// The center coordinates of the sphere.	(vector)
		SGrid_Geodetic_thickness,		// The thickness of the grid lines.			(float)
		SGrid_Geodetic_offset,		// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
		SGrid_Geodetic_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 		(boolian)
	)

	#local SGrid_Geodetic_ratio = SGrid_Geodetic_radius_minor/SGrid_Geodetic_radius_major;
	#local SGrid_Geodetic_bounds = sphere {0, SGrid_Geodetic_radius_major scale <1,SGrid_Geodetic_ratio,1>}
	#local f_spheroid = function(var1,var2,var3, a,b,c) {var1*var1/a/a+var2*var2/b/b+var3*var3/c/c-1}
	#local f_spheroid_normalized = function(var1,var2,var3, a,b,c) {f_spheroid(var1,var2,var3, a,b,c)/sqrt(4*var1*var1/pow(a,4)+4*var2*var2/pow(b,4)+4*var3*var3/pow(c,4))}

	union
	{
		// radius
		#local SGrid_Geodetic_increment = 1/SGrid_Geodetic_radii;
		#local SGrid_Geodetic_i = 0;
		#local SGrid_Geodetic_start = 0;
		#if (SGrid_Geodetic_offset = on)
			#local SGrid_Geodetic_start = SGrid_Geodetic_increment/2;
		#end
		#while (SGrid_Geodetic_i < SGrid_Geodetic_radii)
			#local SGrid_Geodetic_value_maj = SGrid_Geodetic_radius_major * (SGrid_Geodetic_start + SGrid_Geodetic_i * SGrid_Geodetic_increment);
			#local SGrid_Geodetic_value_min = SGrid_Geodetic_radius_minor * (SGrid_Geodetic_start + SGrid_Geodetic_i * SGrid_Geodetic_increment);

			#local SGrid_Iso_1 = isosurface
			{
				function {f_spheroid_normalized(x,y,z,SGrid_Geodetic_value_maj,SGrid_Geodetic_value_min,SGrid_Geodetic_value_maj)-SGrid_Geodetic_thickness/2}
				accuracy		0.001
				max_gradient	4
				all_intersections
				//evaluate P0, P1, min (P2, 1)
				contained_by {sphere {0, SGrid_Geodetic_radius_major}}
			}
			#local SGrid_Iso_2 = isosurface
			{
				function {f_spheroid_normalized(x,y,z,SGrid_Geodetic_value_maj,SGrid_Geodetic_value_min,SGrid_Geodetic_value_maj)+SGrid_Geodetic_thickness/2}
				accuracy		0.001
				max_gradient	4
				all_intersections
				//evaluate P0, P1, min (P2, 1)
				contained_by {sphere {0, SGrid_Geodetic_radius_major}}
			}

			difference
			{
				object {SGrid_Iso_1}
				object {SGrid_Iso_2}
				bounded_by {SGrid_Geodetic_bounds}
			}
    		SGrid_Debug_Macro("\n")
			SGrid_Debug_Macro(concat("radii_value_maj = ", str(SGrid_Geodetic_value_maj, 0, -1),"\n"))
			SGrid_Debug_Macro(concat("radii_value_min = ", str(SGrid_Geodetic_value_min, 0, -1),"\n"))
			#local SGrid_Geodetic_i = SGrid_Geodetic_i + 1;
		#end

		// longitude
		#local SGrid_Geodetic_increment = 1/SGrid_Geodetic_longt;
		#local SGrid_Geodetic_i = 0;
		#local SGrid_Geodetic_start = 0;
		#if (SGrid_Geodetic_offset = on)
			#local SGrid_Geodetic_start = SGrid_Geodetic_increment/2;
		#end
		#while (SGrid_Geodetic_i < SGrid_Geodetic_longt)
			#local SGrid_Geodetic_value = 360 * (SGrid_Geodetic_start + SGrid_Geodetic_i * SGrid_Geodetic_increment);
			box
			{
				<2*SGrid_Geodetic_radius_major, 2*SGrid_Geodetic_radius_major, SGrid_Geodetic_thickness/2,>,
				<0, -2*SGrid_Geodetic_radius_major, -SGrid_Geodetic_thickness/2,>
				rotate y * SGrid_Geodetic_value
				bounded_by {SGrid_Geodetic_bounds}
			}
			SGrid_Debug_Macro(concat("longt_value = ", str(SGrid_Geodetic_value, 0, -1),"\n"))
			#local SGrid_Geodetic_i = SGrid_Geodetic_i + 1;
		#end

		// latitude
		#local SGrid_Geodetic_increment = 1/SGrid_Geodetic_latit;
		#local SGrid_Geodetic_i = 0;
		#if (SGrid_Geodetic_endcap = on)
			#local SGrid_Geodetic_start = 0;
			#local SGrid_Geodetic_finish = SGrid_Geodetic_latit + 1;
			#local SGrid_Geodetic_center_gap = 0;
		#else
			#local SGrid_Geodetic_start = SGrid_Geodetic_increment;
			#local SGrid_Geodetic_finish = SGrid_Geodetic_latit - 1;
		#end
		#if (SGrid_Geodetic_offset = on)
			#local SGrid_Geodetic_start = SGrid_Geodetic_increment/2;
			#local SGrid_Geodetic_finish = SGrid_Geodetic_latit;
		#end
		#while (SGrid_Geodetic_i < SGrid_Geodetic_finish)
			// all variable names are supposed to match those in the accompanying GeoGebra worksheet
			#local SGrid_Geodetic_lat_geodet = 180 * (SGrid_Geodetic_start + SGrid_Geodetic_i * SGrid_Geodetic_increment) - 90;												// theta_3
			#local SGrid_Geodetic_lat_geocen = SGrid_convert_geodetic_to_geocentric(SGrid_Geodetic_radius_major, SGrid_Geodetic_radius_minor, SGrid_Geodetic_lat_geodet);		// phi_3
			#local SGrid_Geodetic_lat_reduce = SGrid_convert_geodetic_to_reduced(SGrid_Geodetic_radius_major, SGrid_Geodetic_radius_minor, SGrid_Geodetic_lat_geodet);		// beta_3
			#local SGrid_Geodetic_lat_oppose = asind(cosd(SGrid_Geodetic_lat_geodet));
			#local SGrid_Geodetic_point_A = <0,0>;
			#local SGrid_Geodetic_point_E = <0,+SGrid_Geodetic_radius_minor>;
			#local SGrid_Geodetic_point_R = <0,-SGrid_Geodetic_radius_minor>;
			#local SGrid_Geodetic_point_M = <cosd(SGrid_Geodetic_lat_geocen),sind(SGrid_Geodetic_lat_geocen)> * SGrid_Geodetic_radius_major;
			#local SGrid_Geodetic_point_K = <cosd(SGrid_Geodetic_lat_reduce),0> * SGrid_Geodetic_radius_major;
			#local SGrid_Geodetic_point_O = <cosd(SGrid_Geodetic_lat_reduce),sind(SGrid_Geodetic_lat_reduce)> * SGrid_Geodetic_radius_major;
			#local SGrid_Geodetic_line_i = SGrid_Line(SGrid_Geodetic_point_A, SGrid_Geodetic_point_M);
			#local SGrid_Geodetic_line_n = SGrid_Line(SGrid_Geodetic_point_K, SGrid_Geodetic_point_O);
			#local SGrid_Geodetic_point_F = SGrid_Line_Intersection(SGrid_Geodetic_line_i, SGrid_Geodetic_line_n);
			#local SGrid_Geodetic_distance_IK = tand(SGrid_Geodetic_lat_oppose) * abs(SGrid_Geodetic_point_F.y);
			#local SGrid_Geodetic_distance_AI = abs(SGrid_Geodetic_point_F.x) - SGrid_Geodetic_distance_IK;
			#local SGrid_Geodetic_distance_AE = SGrid_Geodetic_radius_minor;
			#local SGrid_Geodetic_distance_AR = SGrid_Geodetic_radius_minor;
			#local SGrid_Geodetic_distance_AFocus1 = cosd(asind(SGrid_Geodetic_distance_AE));
			#local SGrid_Geodetic_point_N = <SGrid_Geodetic_distance_AFocus1,+SGrid_Geodetic_distance_AE>;
			#local SGrid_Geodetic_point_Q = <SGrid_Geodetic_distance_AFocus1,-SGrid_Geodetic_distance_AR>;
			#local SGrid_Geodetic_point_I = <SGrid_Geodetic_distance_AI,0>;
			#local SGrid_Geodetic_line_b = SGrid_Line(SGrid_Geodetic_point_E, SGrid_Geodetic_point_N);
			#local SGrid_Geodetic_line_p = SGrid_Line(SGrid_Geodetic_point_I, SGrid_Geodetic_point_F);
			#local SGrid_Geodetic_point_G = SGrid_Line_Intersection(SGrid_Geodetic_line_b, SGrid_Geodetic_line_p);
			#local SGrid_Geodetic_line_s = SGrid_Line(SGrid_Geodetic_point_R, SGrid_Geodetic_point_Q);
			#local SGrid_Geodetic_point_S = SGrid_Line_Intersection(SGrid_Geodetic_line_s, SGrid_Geodetic_line_p);
			#local SGrid_Geodetic_line_h = SGrid_Line(SGrid_Geodetic_point_A,SGrid_Geodetic_point_E);
			#local SGrid_Geodetic_point_L = SGrid_Line_Intersection(SGrid_Geodetic_line_h, SGrid_Geodetic_line_p);
			#local SGrid_Geodetic_distance_EG = abs(SGrid_Geodetic_point_G.x);
			#local SGrid_Geodetic_distance_RS = abs(SGrid_Geodetic_point_S.x);

//			#declare point_array[point_count] = SGrid_Geodetic_point_F;
//			#declare point_count = point_count + 1;

			#if (SGrid_Geodetic_lat_geodet = -60)
	    		SGrid_Debug_Macro("\n")
	    		SGrid_Debug_Macro(concat("SGrid_Geodetic_lat_geodet (theta_3): ", str(SGrid_Geodetic_lat_geodet,0,5), "\n"))
	    		SGrid_Debug_Macro(concat("SGrid_Geodetic_lat_geocen (phi_3): ", str(SGrid_Geodetic_lat_geocen,0,5), "\n"))
	    		SGrid_Debug_Macro(concat("SGrid_Geodetic_lat_reduce (beta_3): ", str(SGrid_Geodetic_lat_reduce,0,5), "\n"))
	    		SGrid_Debug_Macro(concat("SGrid_Geodetic_lat_oppose: ", str(SGrid_Geodetic_lat_oppose,0,5), "\n"))
    			SGrid_Debug_Macro(concat("SGrid_Geodetic_point_F: <", vstr(3,SGrid_Geodetic_point_F,",",0,5), ">\n"))
	    		SGrid_Debug_Macro(concat("SGrid_Geodetic_distance_IK: ", str(SGrid_Geodetic_distance_IK,0,5), "\n"))
	    		SGrid_Debug_Macro(concat("SGrid_Geodetic_distance_AI: ", str(SGrid_Geodetic_distance_AI,0,5), "\n"))
	    		SGrid_Debug_Macro(concat("SGrid_Geodetic_distance_AE: ", str(SGrid_Geodetic_distance_AE,0,5), "\n"))
	    		SGrid_Debug_Macro(concat("SGrid_Geodetic_distance_AFocus1: ", str(SGrid_Geodetic_distance_AFocus1,0,5), "\n"))
    			SGrid_Debug_Macro(concat("SGrid_Geodetic_point_G: <", vstr(3,SGrid_Geodetic_point_G,",",0,5), ">\n"))
    			SGrid_Debug_Macro(concat("SGrid_Geodetic_point_L: <", vstr(3,SGrid_Geodetic_point_L,",",0,5), ">\n"))
	    		SGrid_Debug_Macro(concat("SGrid_Geodetic_distance_EG: ", str(SGrid_Geodetic_distance_EG,0,5), "\n"))
	    		SGrid_Debug_Macro("\n")
			#end

			#if (SGrid_Geodetic_i < (SGrid_Geodetic_finish - 1)/2)
				difference
				{
					cone
					{
						SGrid_Geodetic_point_L * <1,1,0>, 0, SGrid_Geodetic_point_R * <1,1,0>, SGrid_Geodetic_distance_RS
						translate +y * SGrid_Geodetic_radius_major/abs(sind(SGrid_Geodetic_lat_oppose)) * SGrid_Geodetic_thickness/2
					}
					cone
					{
						SGrid_Geodetic_point_L * <1,1,0>, 0, SGrid_Geodetic_point_R * <1,1,0>, SGrid_Geodetic_distance_RS
						translate -y * SGrid_Geodetic_radius_major/abs(sind(SGrid_Geodetic_lat_oppose)) * SGrid_Geodetic_thickness/2
					}
					plane {-y, 0}
					bounded_by {SGrid_Geodetic_bounds}
				}
			#elseif (SGrid_Geodetic_i = (SGrid_Geodetic_finish - 1)/2)
				cylinder
				{
					<0,-SGrid_Geodetic_thickness/2,0,>, <0,+SGrid_Geodetic_thickness/2,0,>, 2*SGrid_Geodetic_radius_major
					bounded_by {SGrid_Geodetic_bounds}
				}
			#elseif (SGrid_Geodetic_i > (SGrid_Geodetic_finish - 1)/2)
				difference
				{
					cone
					{
						SGrid_Geodetic_point_L * <1,1,0>, 0, SGrid_Geodetic_point_E * <1,1,0>, SGrid_Geodetic_distance_EG
						translate -y * SGrid_Geodetic_radius_major/abs(sind(SGrid_Geodetic_lat_oppose)) * SGrid_Geodetic_thickness/2
					}
					cone
					{
						SGrid_Geodetic_point_L * <1,1,0>, 0, SGrid_Geodetic_point_E * <1,1,0>, SGrid_Geodetic_distance_EG
						translate +y * SGrid_Geodetic_radius_major/abs(sind(SGrid_Geodetic_lat_oppose)) * SGrid_Geodetic_thickness/2
					}
					plane {+y, 0}
					bounded_by {SGrid_Geodetic_bounds}
				}
			#end
			#local SGrid_Geodetic_i = SGrid_Geodetic_i + 1;
		#end
		translate SGrid_Geodetic_center
	}
#end


//--------------------------------------Itten's color sphere

#macro SGrid_Itten_Macro
	(
		SGrid_Itten_radii,		// The number of radial divisions.		(integer)
		SGrid_Itten_longt,		// The number of longitudinal divisions.	(integer)
		SGrid_Itten_latit,		// The number of lattitudinal divisions.	(integer)
		SGrid_Itten_radius,		// The radius of the sphere.			(float)
		SGrid_Itten_center,		// The center coordinates of the sphere.	(vector)
		SGrid_Itten_thickness,	// The thickness of the grid lines.		(float)
		SGrid_Itten_offset,		// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
		SGrid_Itten_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
	)

	#local SGrid_Itten_bounds = sphere {0, SGrid_Itten_radius}

	union
	{

		#local SGrid_Itten_increment = 1/SGrid_Itten_radii;
		#local SGrid_Itten_i = 0;
		#local SGrid_Itten_start = 0;
		#if (SGrid_Itten_offset = on)
			#local SGrid_Itten_start = SGrid_Itten_increment/2;
		#end
		#while (SGrid_Itten_i < SGrid_Itten_radii)
			#local SGrid_Itten_value = SGrid_Itten_radius * (SGrid_Itten_start + SGrid_Itten_i * SGrid_Itten_increment);
			difference
			{
				object {Spheroid(0, <SGrid_Itten_value + SGrid_Itten_thickness/2,SGrid_Itten_radius,SGrid_Itten_value + SGrid_Itten_thickness/2,>)}
				object {Spheroid(0, <SGrid_Itten_value - SGrid_Itten_thickness/2,SGrid_Itten_radius,SGrid_Itten_value - SGrid_Itten_thickness/2,>)}
				bounded_by {SGrid_Itten_bounds}
			}
			SGrid_Debug_Macro(concat("radii_value = ", str(SGrid_Itten_value, 0, -1),"\n"))
			#local SGrid_Itten_i = SGrid_Itten_i + 1;
		#end

		#local SGrid_Itten_increment = 1/SGrid_Itten_longt;
		#local SGrid_Itten_i = 0;
		#local SGrid_Itten_start = 0;
		#if (SGrid_Itten_offset = on)
			#local SGrid_Itten_start = SGrid_Itten_increment/2;
		#end
		#while (SGrid_Itten_i < SGrid_Itten_longt)
			#local SGrid_Itten_value = 360 * (SGrid_Itten_start + SGrid_Itten_i * SGrid_Itten_increment);
			box
			{
				<2*SGrid_Itten_radius, 2*SGrid_Itten_radius, SGrid_Itten_thickness/2,>,
				<0, -2*SGrid_Itten_radius, -SGrid_Itten_thickness/2,>
				bounded_by {SGrid_Itten_bounds}
				rotate y * SGrid_Itten_value
			}
			SGrid_Debug_Macro(concat("longt_value = ", str(SGrid_Itten_value, 0, -1),"\n"))
			#local SGrid_Itten_i = SGrid_Itten_i + 1;
		#end

		#local SGrid_Itten_increment = 1/SGrid_Itten_latit;
		#local SGrid_Itten_i = 0;
		#if (SGrid_Itten_endcap = on)
			#local SGrid_Itten_start = 0;
			#local SGrid_Itten_finish = SGrid_Itten_latit + 1;
		#else
			#local SGrid_Itten_start = SGrid_Itten_increment;
			#local SGrid_Itten_finish = SGrid_Itten_latit - 1;
		#end
		#if (SGrid_Itten_offset = on)
			#local SGrid_Itten_start = SGrid_Itten_increment/2;
			#local SGrid_Itten_finish = SGrid_Itten_latit;
		#end
		#while (SGrid_Itten_i < SGrid_Itten_finish)
			#local SGrid_Itten_value = -SGrid_Itten_radius + 2*SGrid_Itten_radius*(SGrid_Itten_start + SGrid_Itten_i * SGrid_Itten_increment);
			box
			{
				<SGrid_Itten_radius,SGrid_Itten_thickness/2,SGrid_Itten_radius,>,
				<-SGrid_Itten_radius,-SGrid_Itten_thickness/2,-SGrid_Itten_radius,>
				bounded_by {SGrid_Itten_bounds}
				translate y * SGrid_Itten_value
			}
			SGrid_Debug_Macro(concat("lattt_value = ", str(SGrid_Itten_value, 0, -1),"\n"))
			#local SGrid_Itten_i = SGrid_Itten_i + 1;
		#end
		translate SGrid_Itten_center
	}
#end


//--------------------------------------Cube

#macro SGrid_Cube_Macro
	(
		SGrid_Cube_sectors,		// The number of sections along each axis.	(integer vector)
		SGrid_Cube_width,		// The width of the cuboid along each axis.	(float vector)
		SGrid_Cube_corner,		// The coordinates of the bottom corner.	(float vector)
		SGrid_Cube_thickness,	// The thickness of the grid lines.			(float)
		SGrid_Cube_offset,		// Determines whether the divisions are offset by half the amount. Sometimes necessary when doing cut-aways.	(boolian)
		SGrid_Cube_endcap,		// Determines whether borders are created at each end of the object. Ignored if the offset is turned on. 	(boolian)
	)

	#local SGrid_Cube_bounds = box {0, SGrid_Cube_width}

	union
	{

		#local SGrid_Cube_increment = 1/SGrid_Cube_sectors.x;
		#local SGrid_Cube_i = 0;
		#local SGrid_Cube_start = 0;
		#if (SGrid_Cube_endcap = on)
			#local SGrid_Cube_start = 0;
			#local SGrid_Cube_finish = SGrid_Cube_sectors.x + 1;
		#else
			#local SGrid_Cube_start = SGrid_Cube_increment;
			#local SGrid_Cube_finish = SGrid_Cube_sectors.x - 1;
		#end
		#if (SGrid_Cube_offset = on)
			#local SGrid_Cube_start = SGrid_Cube_increment/2;
			#local SGrid_Cube_finish = SGrid_Cube_sectors.x;
		#end
		#while (SGrid_Cube_i < SGrid_Cube_finish)
			#local SGrid_Cube_value = SGrid_Cube_width.x * (SGrid_Cube_start + SGrid_Cube_i * SGrid_Cube_increment);
			box
			{
				<-SGrid_Cube_thickness/2, +2*SGrid_Cube_width.y, +2*SGrid_Cube_width.z,>,
				<+SGrid_Cube_thickness/2, -1*SGrid_Cube_width.y, -1*SGrid_Cube_width.z,>
				translate x * SGrid_Cube_value
				bounded_by {SGrid_Cube_bounds}
			}
			SGrid_Debug_Macro(concat("sectorx_value = ", str(SGrid_Cube_value, 0, -1),"\n"))
			#local SGrid_Cube_i = SGrid_Cube_i + 1;
		#end

		#local SGrid_Cube_increment = 1/SGrid_Cube_sectors.y;
		#local SGrid_Cube_i = 0;
		#local SGrid_Cube_start = 0;
		#if (SGrid_Cube_endcap = on)
			#local SGrid_Cube_start = 0;
			#local SGrid_Cube_finish = SGrid_Cube_sectors.y + 1;
		#else
			#local SGrid_Cube_start = SGrid_Cube_increment;
			#local SGrid_Cube_finish = SGrid_Cube_sectors.y - 1;
		#end
		#if (SGrid_Cube_offset = on)
			#local SGrid_Cube_start = SGrid_Cube_increment/2;
			#local SGrid_Cube_finish = SGrid_Cube_sectors.y;
		#end
		#while (SGrid_Cube_i < SGrid_Cube_finish)
			#local SGrid_Cube_value = SGrid_Cube_width.y * (SGrid_Cube_start + SGrid_Cube_i * SGrid_Cube_increment);
			box
			{
				<+2*SGrid_Cube_width.x, -SGrid_Cube_thickness/2, +2*SGrid_Cube_width.z,>,
				<-1*SGrid_Cube_width.x, +SGrid_Cube_thickness/2, -1*SGrid_Cube_width.z,>
				translate y * SGrid_Cube_value
				bounded_by {SGrid_Cube_bounds}
			}
			SGrid_Debug_Macro(concat("sectory_value = ", str(SGrid_Cube_value, 0, -1),"\n"))
			#local SGrid_Cube_i = SGrid_Cube_i + 1;
		#end

		#local SGrid_Cube_increment = 1/SGrid_Cube_sectors.z;
		#local SGrid_Cube_i = 0;
		#local SGrid_Cube_start = 0;
		#if (SGrid_Cube_endcap = on)
			#local SGrid_Cube_start = 0;
			#local SGrid_Cube_finish = SGrid_Cube_sectors.z + 1;
		#else
			#local SGrid_Cube_start = SGrid_Cube_increment;
			#local SGrid_Cube_finish = SGrid_Cube_sectors.z - 1;
		#end
		#if (SGrid_Cube_offset = on)
			#local SGrid_Cube_start = SGrid_Cube_increment/2;
			#local SGrid_Cube_finish = SGrid_Cube_sectors.z;
		#end
		#while (SGrid_Cube_i < SGrid_Cube_finish)
			#local SGrid_Cube_value = SGrid_Cube_width.z * (SGrid_Cube_start + SGrid_Cube_i * SGrid_Cube_increment);
			box
			{
				<+2*SGrid_Cube_width.x, +2*SGrid_Cube_width.y, -SGrid_Cube_thickness/2,>,
				<-1*SGrid_Cube_width.x, -1*SGrid_Cube_width.y, +SGrid_Cube_thickness/2,>
				translate z * SGrid_Cube_value
				bounded_by {SGrid_Cube_bounds}
			}
			SGrid_Debug_Macro(concat("sectorz_value = ", str(SGrid_Cube_value, 0, -1),"\n"))
			#local SGrid_Cube_i = SGrid_Cube_i + 1;
		#end
		translate SGrid_Cube_corner
	}
#end
