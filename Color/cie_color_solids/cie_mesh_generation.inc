// Title: CIE Mesh Generation Routines
// Authors: Michael Horvath, Bruce Lindbloom
// Website: http://isometricland.net
// Created: 2017-03-21
// Updated: 2017-03-30
// This file is licensed under the terms of the CC-GNU LGPL.
// http://www.gnu.org/licenses/lgpl-2.1.html
// Illuminant =  D65
// Observer   =  2° (1931)
// +kfi0 +kff191 +kc
// +k0.25

#version 3.7;
#ifndef (cie_pre_xyz_visible)	#declare cie_pre_xyz_visible = false;	#end
#ifndef (cie_pre_mesh_visible)	#declare cie_pre_mesh_visible = false;	#end
#ifndef (cie_pre_xyz_srgb)	#declare cie_pre_xyz_srgb = false;	#end
#ifndef (cie_pre_mesh_srgb)	#declare cie_pre_mesh_srgb = false;	#end


//------------------------------------------------------------------------------
// visible gamut


#declare cie_sample_count_visible = 95;	// number of samples across the spectrum
#declare cie_point_count_visible = 1;
#declare cie_point_total_visible = (cie_sample_count_visible+1) * cie_sample_count_visible;
#declare cie_point_array_visible = array[cie_sample_count_visible+1][cie_sample_count_visible];

#macro cie_wrap_index_visible(iIndex)
	mod(iIndex + cie_sample_count_visible * 2, cie_sample_count_visible)
#end

#macro cie_clip_index_visible(iIndex)
	#if (iIndex < 0)
		#local oIndex = 0;
	// an additional row has been added to the end of the table for the white point
	#elseif (iIndex > cie_sample_count_visible)
		#local oIndex = cie_sample_count_visible;
	#else
		#local oIndex = iIndex;
	#end
	oIndex
#end


// calulcate outer XYZ coordinates of visible gamut, thanks to Bruce Lindbloom
#macro cie_calc_gamut_xyz_visible(cie_color_space, cie_white_table)
	// temporary container for XYZ points
	#local cie_temp_array = array[cie_sample_count_visible][cie_sample_count_visible];

	// un-normalized XYZ of pure white (arbitrary units)
	#local cie_xyzSumW = <0,0,0>;
	#for (j, 0, cie_sample_count_visible - 1)
		#local cie_xyzSumW =
		<
			cie_xyzSumW.x + cie_xyz_table[j].x * cie_white_table[j],
			cie_xyzSumW.y + cie_xyz_table[j].y * cie_white_table[j],
			cie_xyzSumW.z + cie_xyz_table[j].z * cie_white_table[j]
		>;
	#end

	// loop for pulse width (should start with 1)
	#for (i_pulse_width, 1, cie_sample_count_visible - 1)
		// loop for shift of the pulse
		#for (i_start, 0, cie_sample_count_visible - 1)
			// create a spectrum that lies on the gamut surface
			#local cie_temp_sample = array[cie_sample_count_visible];
			#for (i, 0, cie_sample_count_visible - 1)
				#local cie_temp_sample[i] = 0;
			#end
			#for (i_pulse, 0, i_pulse_width - 1)
				#local i = mod(i_pulse + i_start, cie_sample_count_visible);
				#local cie_temp_sample[i] = 1;
			#end
			// measure the XYZ of that spectrum
			#local cie_xyzSum = <0,0,0>;
			#for (j, 0, cie_sample_count_visible - 1)
				#local cie_xyzSum =
				<
					cie_xyzSum.x + cie_xyz_table[j].x * cie_white_table[j] * cie_temp_sample[j],
					cie_xyzSum.y + cie_xyz_table[j].y * cie_white_table[j] * cie_temp_sample[j],
					cie_xyzSum.z + cie_xyz_table[j].z * cie_white_table[j] * cie_temp_sample[j]
				>;
			#end
			// store the result in temporary table
			#local cie_temp_array[i_pulse_width][i_start] = cie_xyzSum/cie_xyzSumW.y;
		#end
	#end
	// bottom row (black), identical in shape to two-dimensional xy chromaticity diagram, only needed for xyY space
	#if (cie_color_space = 0)
		#for (j, 0, cie_sample_count_visible - 1)
			#declare cie_point_array_visible[0][j] = cie_xyz_table[j]*100;
			// print coordinates to log
	//		#debug concat(vstr(3, cie_point_array_visible[0][j], "\t", 0, 8), "\n")
			// print how many points plotted so far
	//		#debug concat(str(cie_point_count_visible, 0, 0), "\n")
	//		#declare cie_point_count_visible = cie_point_count_visible + 1;
		#end
	// bottom row (black), all the same point, use this for spaces other than xyY
	#else
		#for (j, 0, cie_sample_count_visible - 1)
			#declare cie_point_array_visible[0][j] = <0,0,0>*100;
			// print coordinates to log
	//		#debug concat(vstr(3, cie_point_array_visible[0][j], "\t", 0, 8), "\n")
			// print how many points plotted so far
	//		#debug concat(str(cie_point_count_visible, 0, 0), "\n")
	//		#declare cie_point_count_visible = cie_point_count_visible + 1;
		#end
	#end
	// middle rows
	#for (i, 1, cie_sample_count_visible - 1)
		#for (j, 0, cie_sample_count_visible - 1)
			#declare cie_point_array_visible[i][j] = cie_temp_array[i][j]*100;
			// print XYZ value to log
//			#debug concat(vstr(3, cie_point_array_visible[i][j], "\t", 0, 8), "\n")
			// print how many points plotted so far
//			#debug concat(str(cie_point_count_visible, 0, 0), "\n")
//			#declare cie_point_count_visible = cie_point_count_visible + 1;
		#end
	#end
	// top row (white), all the same point
	#for (j, 0, cie_sample_count_visible - 1)
		#declare cie_point_array_visible[cie_sample_count_visible][j] = cie_xyzSumW/cie_xyzSumW.y*100;
		// print coordinates to log
//		#debug concat(vstr(3, cie_point_array_visible[cie_sample_count_visible][j], "\t", 0, 8), "\n")
		// print how many points plotted so far
//		#debug concat(str(cie_point_count_visible, 0, 0), "\n")
//		#declare cie_point_count_visible = cie_point_count_visible + 1;
	#end
#end

// print XYZ coordinates to file as text
#macro cie_write_XYZ_coordinates_visible(cie_filename)
	#fopen cie_write_handle cie_filename write
	#write (cie_write_handle, "// Don't use this table in xyY space since the first row is degenerate in that space. (But other spaces are okay.)\n")
	#write (cie_write_handle, "#declare cie_point_array_visible = array[", cie_sample_count_visible+1, "][", cie_sample_count_visible, "]\n{\n")
	#for (i, 0, cie_sample_count_visible)
		#write (cie_write_handle, "\t{\n")
		#for (j, 0, cie_sample_count_visible - 1)
			#write (cie_write_handle, "\t\t<", vstr(3, cie_point_array_visible[i][j], ",", 0, 9), ">")
			#if (j < cie_sample_count_visible - 1)
				#write (cie_write_handle, ",")
			#end
			#write (cie_write_handle, "\t// ", str(i,2,0), ",", str(j,2,0), "\n")
		#end
		#write (cie_write_handle, "\t}")
		#if (i < cie_sample_count_visible)
			#write (cie_write_handle, ",")
		#end
		#write (cie_write_handle, "\n")
	#end
	#write (cie_write_handle, "}\n")
	#fclose cie_write_handle
#end

// black grid lines
#macro cie_plot_gridlines_visible(color_space)
	#local sph_rad = 1/512;
	// includes an extra row for the white point
	#for (i, 0, cie_sample_count_visible)
		#for (j, 0, cie_sample_count_visible - 1)
			#if (mod(i, 5) = 0)
				// get XYZ values
				#local currXYZ = cie_point_array_visible[i][cie_wrap_index_visible(j-0)];
				#local lastXYZ = cie_point_array_visible[i][cie_wrap_index_visible(j-1)];
				#switch (color_space)
					// xyY
					#case (0)
						// convert XYZ to xyY
						#local currPlot = cie_convXYZ2XYY(currXYZ);
						#local lastPlot = cie_convXYZ2XYY(lastXYZ);
						// first row should be perfectly flat
						#if (i = 0)
							#local currPlot = <currPlot.x,currPlot.y,0>;
							#local lastPlot = <lastPlot.x,lastPlot.y,0>;
						#end
						// switch y and z and normalize Y
						#local currPlot = <currPlot.x,currPlot.z/100,currPlot.y>;
						#local lastPlot = <lastPlot.x,lastPlot.z/100,lastPlot.y>;
					#break
					#else
						#error "Have only done xyY color space so far."
				#end
				// plot cylinder
				#if (VEq(currPlot, lastPlot) = false)
					cylinder
					{
						currPlot, lastPlot, sph_rad
						finish {cie_isoFinish}
					}
				#end
				// plot sphere
				sphere
				{
					currPlot, sph_rad
					pigment {color rgb 0}
					finish {cie_isoFinish}
				}
			#end
			#if (mod(j, 5) = 0)
				// get XYZ value
				#local currXYZ = cie_point_array_visible[cie_clip_index_visible(i-0)][j];
				#local lastXYZ = cie_point_array_visible[cie_clip_index_visible(i-1)][j];
				#switch (color_space)
					// xyY
					#case (0)
						// convert XYZ to xyY
						#local currPlot = cie_convXYZ2XYY(currXYZ);
						#local lastPlot = cie_convXYZ2XYY(lastXYZ);
						// first row should be perfectly flat
						#if (cie_clip_index_visible(i-0) = 0)
							#local currPlot = <currPlot.x,currPlot.y,0>;
						#end
						#if (cie_clip_index_visible(i-1) = 0)
							#local lastPlot = <lastPlot.x,lastPlot.y,0>;
						#end
						// switch y and z and normalize Y
						#local currPlot = <currPlot.x,currPlot.z/100,currPlot.y>;
						#local lastPlot = <lastPlot.x,lastPlot.z/100,lastPlot.y>;
					#break
					#else
						#error "Have only done xyY color space so far."
				#end
				// plot cylinder
				#if (VEq(currPlot, lastPlot) = false)
					cylinder
					{
						currPlot, lastPlot, sph_rad
						pigment {color rgb 0}
						finish {cie_isoFinish}
					}
				#end
				// plot sphere
				sphere
				{
					currPlot, sph_rad
					finish {cie_isoFinish}
				}
			#end
		#end
	#end
#end

// colored dots
#macro cie_plot_polkadots_visible(color_space)
	#local sph_rad = 1/128;
	// add extra rows for the black and white points
	#for (i, 0, cie_sample_count_visible)
		#for (j, 0, cie_sample_count_visible - 1)
			// get XYZ values
			#local currXYZ = cie_point_array_visible[i][j];
			// get colors
			#local currColr = cie_convXYZ2RGB(currXYZ);
			#switch (color_space)
				// xyY
				#case (0)
					// convert XYZ to xyY
					#local currPlot = cie_convXYZ2XYY(currXYZ);
					// first row should be perfectly flat and black
					#if (i = 0)
						#local currPlot = <currPlot.x,currPlot.y,0>;
						#local currColr = <0,0,0>;
					#end
					// switch y and z and normalize Y
					#local currPlot = <currPlot.x,currPlot.z/100,currPlot.y>;
				#break
				#else
					#error "Have only done xyY color space so far."
			#end
			// plot sphere
			sphere
			{
				currPlot, sph_rad
				pigment {color srgb currColr}
				finish {cie_isoFinish}
			}
		#end
	#end
#end

// flat triangle mesh
// change this so it writes to a file instead
#macro cie_plot_flatmesh_visible(color_space)
	mesh
	{
		// includes an extra row for the white point
		// skip the first row since you can't build a mesh from it all by itself
		#for (i, 1, cie_sample_count_visible)
			#for (j, 0, cie_sample_count_visible - 1)
				// get XYZ values
				#local XYZa1 = cie_point_array_visible[cie_clip_index_visible(i-0)][cie_wrap_index_visible(j-1)];
				#local XYZb1 = cie_point_array_visible[cie_clip_index_visible(i-0)][cie_wrap_index_visible(j-0)];
				#local XYZa2 = cie_point_array_visible[cie_clip_index_visible(i-1)][cie_wrap_index_visible(j-1)];
				#local XYZb2 = cie_point_array_visible[cie_clip_index_visible(i-1)][cie_wrap_index_visible(j-0)];
				// get colors
				#local cola1 = cie_convXYZ2RGB(XYZa1);
				#local colb1 = cie_convXYZ2RGB(XYZb1);
				#local cola2 = cie_convXYZ2RGB(XYZa2);
				#local colb2 = cie_convXYZ2RGB(XYZb2);
				#switch (color_space)
					// xyY
					#case (0)
						// convert XYZ to xyY
						#local cooa1 = cie_convXYZ2XYY(XYZa1);
						#local coob1 = cie_convXYZ2XYY(XYZb1);
						#local cooa2 = cie_convXYZ2XYY(XYZa2);
						#local coob2 = cie_convXYZ2XYY(XYZb2);
						// first row should be perfectly flat and black
						#if (cie_clip_index_visible(i-0) = 0)
							#local cooa1 = <cooa1.x,cooa1.y,0>;
							#local coob1 = <coob1.x,coob1.y,0>;
							#local cola1 = <0,0,0>;
							#local colb1 = <0,0,0>;
						#end
						#if (cie_clip_index_visible(i-1) = 0)
							#local cooa2 = <cooa2.x,cooa2.y,0>;
							#local coob2 = <coob2.x,coob2.y,0>;
							#local cola2 = <0,0,0>;
							#local colb2 = <0,0,0>;
						#end
						// switch y and z and normalize Y
						#local cooa1 = <cooa1.x,cooa1.z/100,cooa1.y>;
						#local coob1 = <coob1.x,coob1.z/100,coob1.y>;
						#local cooa2 = <cooa2.x,cooa2.z/100,cooa2.y>;
						#local coob2 = <coob2.x,coob2.z/100,coob2.y>;
					#break
					#else
						#error "Have only done xyY color space so far."
				#end
				// create textures
				#local coltri1 = (cola2 + cola1 + colb1)/3;
				#local coltri2 = (colb1 + colb2 + cola2)/3;
				#local textri1 = texture {pigment {color srgb coltri1} finish {cie_isoFinish}}
				#local textri2 = texture {pigment {color srgb coltri2} finish {cie_isoFinish}}
				// plot triangles
				triangle
				{
					cooa2, cooa1, coob1
					#if (cie_paint_triangles = true)
						texture {textri1}
					#end
				}
				triangle
				{
					coob1, coob2, cooa2
					#if (cie_paint_triangles = true)
						texture {textri2}
					#end
				}
			#end
		#end
	}
#end

// smooth triangle mesh
#macro cie_write_smoothmesh_visible(color_space, cie_filename)
	#fopen cie_write_handle cie_filename write
	#write (cie_write_handle, "mesh\n{\n")

	// includes an extra row for the white point
	// skip the first row since you can't build a mesh from it all by itself
	#for (i, 1, cie_sample_count_visible)
		#for (j, 0, cie_sample_count_visible - 1)
			// get XYZ values
			#local XYZA = cie_point_array_visible[cie_clip_index_visible(i+1)][cie_wrap_index_visible(j-2)];
			#local XYZB = cie_point_array_visible[cie_clip_index_visible(i+1)][cie_wrap_index_visible(j-1)];
			#local XYZC = cie_point_array_visible[cie_clip_index_visible(i+1)][cie_wrap_index_visible(j+0)];
			#local XYZD = cie_point_array_visible[cie_clip_index_visible(i+1)][cie_wrap_index_visible(j+1)];
			#local XYZE = cie_point_array_visible[cie_clip_index_visible(i+0)][cie_wrap_index_visible(j-2)];
			#local XYZF = cie_point_array_visible[cie_clip_index_visible(i+0)][cie_wrap_index_visible(j-1)];
			#local XYZG = cie_point_array_visible[cie_clip_index_visible(i+0)][cie_wrap_index_visible(j+0)];
			#local XYZH = cie_point_array_visible[cie_clip_index_visible(i+0)][cie_wrap_index_visible(j+1)];
			#local XYZI = cie_point_array_visible[cie_clip_index_visible(i-1)][cie_wrap_index_visible(j-2)];
			#local XYZJ = cie_point_array_visible[cie_clip_index_visible(i-1)][cie_wrap_index_visible(j-1)];
			#local XYZK = cie_point_array_visible[cie_clip_index_visible(i-1)][cie_wrap_index_visible(j+0)];
			#local XYZL = cie_point_array_visible[cie_clip_index_visible(i-1)][cie_wrap_index_visible(j+1)];
			#local XYZM = cie_point_array_visible[cie_clip_index_visible(i-2)][cie_wrap_index_visible(j-2)];
			#local XYZN = cie_point_array_visible[cie_clip_index_visible(i-2)][cie_wrap_index_visible(j-1)];
			#local XYZO = cie_point_array_visible[cie_clip_index_visible(i-2)][cie_wrap_index_visible(j+0)];
			#local XYZP = cie_point_array_visible[cie_clip_index_visible(i-2)][cie_wrap_index_visible(j+1)];
			// get colors
			#local colA = cie_convXYZ2RGB(XYZA);
			#local colB = cie_convXYZ2RGB(XYZB);
			#local colC = cie_convXYZ2RGB(XYZC);
			#local colD = cie_convXYZ2RGB(XYZD);
			#local colE = cie_convXYZ2RGB(XYZE);
			#local colF = cie_convXYZ2RGB(XYZF);
			#local colG = cie_convXYZ2RGB(XYZG);
			#local colH = cie_convXYZ2RGB(XYZH);
			#local colI = cie_convXYZ2RGB(XYZI);
			#local colJ = cie_convXYZ2RGB(XYZJ);
			#local colK = cie_convXYZ2RGB(XYZK);
			#local colL = cie_convXYZ2RGB(XYZL);
			#local colM = cie_convXYZ2RGB(XYZM);
			#local colN = cie_convXYZ2RGB(XYZN);
			#local colO = cie_convXYZ2RGB(XYZO);
			#local colP = cie_convXYZ2RGB(XYZP);
			// convert XYZ to other color spaces and store coordinates
			#switch (color_space)
				// CIExyY (cube)
				#case (0)
					// convert XYZ to xyY
					#local cooA = cie_convXYZ2XYY(XYZA);
					#local cooB = cie_convXYZ2XYY(XYZB);
					#local cooC = cie_convXYZ2XYY(XYZC);
					#local cooD = cie_convXYZ2XYY(XYZD);
					#local cooE = cie_convXYZ2XYY(XYZE);
					#local cooF = cie_convXYZ2XYY(XYZF);
					#local cooG = cie_convXYZ2XYY(XYZG);
					#local cooH = cie_convXYZ2XYY(XYZH);
					#local cooI = cie_convXYZ2XYY(XYZI);
					#local cooJ = cie_convXYZ2XYY(XYZJ);
					#local cooK = cie_convXYZ2XYY(XYZK);
					#local cooL = cie_convXYZ2XYY(XYZL);
					#local cooM = cie_convXYZ2XYY(XYZM);
					#local cooN = cie_convXYZ2XYY(XYZN);
					#local cooO = cie_convXYZ2XYY(XYZO);
					#local cooP = cie_convXYZ2XYY(XYZP);
					// first row should be perfectly flat and black
					#if (cie_clip_index_visible(i+1) = 0)
						#local cooA = <cooA.x,cooA.y,0>;
						#local cooB = <cooB.x,cooB.y,0>;
						#local cooC = <cooC.x,cooC.y,0>;
						#local cooD = <cooD.x,cooD.y,0>;
						#local colA = <0,0,0>;
						#local colB = <0,0,0>;
						#local colC = <0,0,0>;
						#local colD = <0,0,0>;
					#end
					#if (cie_clip_index_visible(i+0) = 0)
						#local cooE = <cooE.x,cooE.y,0>;
						#local cooF = <cooF.x,cooF.y,0>;
						#local cooG = <cooG.x,cooG.y,0>;
						#local cooH = <cooH.x,cooH.y,0>;
						#local colE = <0,0,0>;
						#local colF = <0,0,0>;
						#local colG = <0,0,0>;
						#local colH = <0,0,0>;
					#end
					#if (cie_clip_index_visible(i-1) = 0)
						#local cooI = <cooI.x,cooI.y,0>;
						#local cooJ = <cooJ.x,cooJ.y,0>;
						#local cooK = <cooK.x,cooK.y,0>;
						#local cooL = <cooL.x,cooL.y,0>;
						#local colI = <0,0,0>;
						#local colJ = <0,0,0>;
						#local colK = <0,0,0>;
						#local colL = <0,0,0>;
					#end
					#if (cie_clip_index_visible(i-2) = 0)
						#local cooM = <cooM.x,cooM.y,0>;
						#local cooN = <cooN.x,cooN.y,0>;
						#local cooO = <cooO.x,cooO.y,0>;
						#local cooP = <cooP.x,cooP.y,0>;
						#local colM = <0,0,0>;
						#local colN = <0,0,0>;
						#local colO = <0,0,0>;
						#local colP = <0,0,0>;
					#end
					// switch y and z and normalize Y
					// make sure the denominators here match the axes labels
					#local cooA = <cooA.x,cooA.z/100,cooA.y>;
					#local cooB = <cooB.x,cooB.z/100,cooB.y>;
					#local cooC = <cooC.x,cooC.z/100,cooC.y>;
					#local cooD = <cooD.x,cooD.z/100,cooD.y>;
					#local cooE = <cooE.x,cooE.z/100,cooE.y>;
					#local cooF = <cooF.x,cooF.z/100,cooF.y>;
					#local cooG = <cooG.x,cooG.z/100,cooG.y>;
					#local cooH = <cooH.x,cooH.z/100,cooH.y>;
					#local cooI = <cooI.x,cooI.z/100,cooI.y>;
					#local cooJ = <cooJ.x,cooJ.z/100,cooJ.y>;
					#local cooK = <cooK.x,cooK.z/100,cooK.y>;
					#local cooL = <cooL.x,cooL.z/100,cooL.y>;
					#local cooM = <cooM.x,cooM.z/100,cooM.y>;
					#local cooN = <cooN.x,cooN.z/100,cooN.y>;
					#local cooO = <cooO.x,cooO.z/100,cooO.y>;
					#local cooP = <cooP.x,cooP.z/100,cooP.y>;
				#break
				// CIEXYZ (cube)
				#case (1)
					// don't do anything but normalize
					// make sure the denominators here match the axes labels
					#local cooA = XYZA/100;
					#local cooB = XYZB/100;
					#local cooC = XYZC/100;
					#local cooD = XYZD/100;
					#local cooE = XYZE/100;
					#local cooF = XYZF/100;
					#local cooG = XYZG/100;
					#local cooH = XYZH/100;
					#local cooI = XYZI/100;
					#local cooJ = XYZJ/100;
					#local cooK = XYZK/100;
					#local cooL = XYZL/100;
					#local cooM = XYZM/100;
					#local cooN = XYZN/100;
					#local cooO = XYZO/100;
					#local cooP = XYZP/100;
				#break
				// CIELAB (cube)
				#case (2)
					// convert XYZ to LAB step 1: get un-normalized values
					#local cooA = cie_convXYZ2LAB(XYZA);
					#local cooB = cie_convXYZ2LAB(XYZB);
					#local cooC = cie_convXYZ2LAB(XYZC);
					#local cooD = cie_convXYZ2LAB(XYZD);
					#local cooE = cie_convXYZ2LAB(XYZE);
					#local cooF = cie_convXYZ2LAB(XYZF);
					#local cooG = cie_convXYZ2LAB(XYZG);
					#local cooH = cie_convXYZ2LAB(XYZH);
					#local cooI = cie_convXYZ2LAB(XYZI);
					#local cooJ = cie_convXYZ2LAB(XYZJ);
					#local cooK = cie_convXYZ2LAB(XYZK);
					#local cooL = cie_convXYZ2LAB(XYZL);
					#local cooM = cie_convXYZ2LAB(XYZM);
					#local cooN = cie_convXYZ2LAB(XYZN);
					#local cooO = cie_convXYZ2LAB(XYZO);
					#local cooP = cie_convXYZ2LAB(XYZP);
					// convert XYZ to LAB step 2: normalize and swap x and y
					// make sure the denominators here match the axes labels
					#local cooA = <cooA.y/400,cooA.x/100,cooA.z/400>;
					#local cooB = <cooB.y/400,cooB.x/100,cooB.z/400>;
					#local cooC = <cooC.y/400,cooC.x/100,cooC.z/400>;
					#local cooD = <cooD.y/400,cooD.x/100,cooD.z/400>;
					#local cooE = <cooE.y/400,cooE.x/100,cooE.z/400>;
					#local cooF = <cooF.y/400,cooF.x/100,cooF.z/400>;
					#local cooG = <cooG.y/400,cooG.x/100,cooG.z/400>;
					#local cooH = <cooH.y/400,cooH.x/100,cooH.z/400>;
					#local cooI = <cooI.y/400,cooI.x/100,cooI.z/400>;
					#local cooJ = <cooJ.y/400,cooJ.x/100,cooJ.z/400>;
					#local cooK = <cooK.y/400,cooK.x/100,cooK.z/400>;
					#local cooL = <cooL.y/400,cooL.x/100,cooL.z/400>;
					#local cooM = <cooM.y/400,cooM.x/100,cooM.z/400>;
					#local cooN = <cooN.y/400,cooN.x/100,cooN.z/400>;
					#local cooO = <cooO.y/400,cooO.x/100,cooO.z/400>;
					#local cooP = <cooP.y/400,cooP.x/100,cooP.z/400>;
				#break
				// CIELCHab (cylinder)
				#case (3)		
					// convert XYZ to LAB to LCHab step 1: get un-normalized values
					#local cooA = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZA));
					#local cooB = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZB));
					#local cooC = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZC));
					#local cooD = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZD));
					#local cooE = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZE));
					#local cooF = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZF));
					#local cooG = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZG));
					#local cooH = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZH));
					#local cooI = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZI));
					#local cooJ = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZJ));
					#local cooK = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZK));
					#local cooL = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZL));
					#local cooM = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZM));
					#local cooN = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZN));
					#local cooO = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZO));
					#local cooP = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZP));
					// convert XYZ to LAB to LCHab step 2: normalize and convert to cartesian coordinates
					// make sure the denominators here match the axes labels
					#local cooA = <cooA.y/400*cosd(cooA.z),cooA.x/100,cooA.y/400*sind(cooA.z)>;
					#local cooB = <cooB.y/400*cosd(cooB.z),cooB.x/100,cooB.y/400*sind(cooB.z)>;
					#local cooC = <cooC.y/400*cosd(cooC.z),cooC.x/100,cooC.y/400*sind(cooC.z)>;
					#local cooD = <cooD.y/400*cosd(cooD.z),cooD.x/100,cooD.y/400*sind(cooD.z)>;
					#local cooE = <cooE.y/400*cosd(cooE.z),cooE.x/100,cooE.y/400*sind(cooE.z)>;
					#local cooF = <cooF.y/400*cosd(cooF.z),cooF.x/100,cooF.y/400*sind(cooF.z)>;
					#local cooG = <cooG.y/400*cosd(cooG.z),cooG.x/100,cooG.y/400*sind(cooG.z)>;
					#local cooH = <cooH.y/400*cosd(cooH.z),cooH.x/100,cooH.y/400*sind(cooH.z)>;
					#local cooI = <cooI.y/400*cosd(cooI.z),cooI.x/100,cooI.y/400*sind(cooI.z)>;
					#local cooJ = <cooJ.y/400*cosd(cooJ.z),cooJ.x/100,cooJ.y/400*sind(cooJ.z)>;
					#local cooK = <cooK.y/400*cosd(cooK.z),cooK.x/100,cooK.y/400*sind(cooK.z)>;
					#local cooL = <cooL.y/400*cosd(cooL.z),cooL.x/100,cooL.y/400*sind(cooL.z)>;
					#local cooM = <cooM.y/400*cosd(cooM.z),cooM.x/100,cooM.y/400*sind(cooM.z)>;
					#local cooN = <cooN.y/400*cosd(cooN.z),cooN.x/100,cooN.y/400*sind(cooN.z)>;
					#local cooO = <cooO.y/400*cosd(cooO.z),cooO.x/100,cooO.y/400*sind(cooO.z)>;
					#local cooP = <cooP.y/400*cosd(cooP.z),cooP.x/100,cooP.y/400*sind(cooP.z)>;
				#break
				// CIELCHab (sphere)
				#case (4)		
					// convert XYZ to LAB to LCHab step 1: get un-normalized values
					#local cooA = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZA));
					#local cooB = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZB));
					#local cooC = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZC));
					#local cooD = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZD));
					#local cooE = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZE));
					#local cooF = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZF));
					#local cooG = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZG));
					#local cooH = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZH));
					#local cooI = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZI));
					#local cooJ = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZJ));
					#local cooK = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZK));
					#local cooL = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZL));
					#local cooM = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZM));
					#local cooN = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZN));
					#local cooO = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZO));
					#local cooP = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZP));
					// convert XYZ to LAB to LCHab step 2: normalize and convert to cartesian coordinates
					// make sure the denominators here match the axes labels
					#local cooA = <(cooA.y/400*7/8+1/8)*cosd(cooA.z)*sind(180-cooA.x/100*180),(cooA.y/400*7/8+1/8)*cosd(180-cooA.x/100*180),(cooA.y/400*7/8+1/8)*sind(cooA.z)*sind(180-cooA.x/100*180)>;
					#local cooB = <(cooB.y/400*7/8+1/8)*cosd(cooB.z)*sind(180-cooB.x/100*180),(cooB.y/400*7/8+1/8)*cosd(180-cooB.x/100*180),(cooB.y/400*7/8+1/8)*sind(cooB.z)*sind(180-cooB.x/100*180)>;
					#local cooC = <(cooC.y/400*7/8+1/8)*cosd(cooC.z)*sind(180-cooC.x/100*180),(cooC.y/400*7/8+1/8)*cosd(180-cooC.x/100*180),(cooC.y/400*7/8+1/8)*sind(cooC.z)*sind(180-cooC.x/100*180)>;
					#local cooD = <(cooD.y/400*7/8+1/8)*cosd(cooD.z)*sind(180-cooD.x/100*180),(cooD.y/400*7/8+1/8)*cosd(180-cooD.x/100*180),(cooD.y/400*7/8+1/8)*sind(cooD.z)*sind(180-cooD.x/100*180)>;
					#local cooE = <(cooE.y/400*7/8+1/8)*cosd(cooE.z)*sind(180-cooE.x/100*180),(cooE.y/400*7/8+1/8)*cosd(180-cooE.x/100*180),(cooE.y/400*7/8+1/8)*sind(cooE.z)*sind(180-cooE.x/100*180)>;
					#local cooF = <(cooF.y/400*7/8+1/8)*cosd(cooF.z)*sind(180-cooF.x/100*180),(cooF.y/400*7/8+1/8)*cosd(180-cooF.x/100*180),(cooF.y/400*7/8+1/8)*sind(cooF.z)*sind(180-cooF.x/100*180)>;
					#local cooG = <(cooG.y/400*7/8+1/8)*cosd(cooG.z)*sind(180-cooG.x/100*180),(cooG.y/400*7/8+1/8)*cosd(180-cooG.x/100*180),(cooG.y/400*7/8+1/8)*sind(cooG.z)*sind(180-cooG.x/100*180)>;
					#local cooH = <(cooH.y/400*7/8+1/8)*cosd(cooH.z)*sind(180-cooH.x/100*180),(cooH.y/400*7/8+1/8)*cosd(180-cooH.x/100*180),(cooH.y/400*7/8+1/8)*sind(cooH.z)*sind(180-cooH.x/100*180)>;
					#local cooI = <(cooI.y/400*7/8+1/8)*cosd(cooI.z)*sind(180-cooI.x/100*180),(cooI.y/400*7/8+1/8)*cosd(180-cooI.x/100*180),(cooI.y/400*7/8+1/8)*sind(cooI.z)*sind(180-cooI.x/100*180)>;
					#local cooJ = <(cooJ.y/400*7/8+1/8)*cosd(cooJ.z)*sind(180-cooJ.x/100*180),(cooJ.y/400*7/8+1/8)*cosd(180-cooJ.x/100*180),(cooJ.y/400*7/8+1/8)*sind(cooJ.z)*sind(180-cooJ.x/100*180)>;
					#local cooK = <(cooK.y/400*7/8+1/8)*cosd(cooK.z)*sind(180-cooK.x/100*180),(cooK.y/400*7/8+1/8)*cosd(180-cooK.x/100*180),(cooK.y/400*7/8+1/8)*sind(cooK.z)*sind(180-cooK.x/100*180)>;
					#local cooL = <(cooL.y/400*7/8+1/8)*cosd(cooL.z)*sind(180-cooL.x/100*180),(cooL.y/400*7/8+1/8)*cosd(180-cooL.x/100*180),(cooL.y/400*7/8+1/8)*sind(cooL.z)*sind(180-cooL.x/100*180)>;
					#local cooM = <(cooM.y/400*7/8+1/8)*cosd(cooM.z)*sind(180-cooM.x/100*180),(cooM.y/400*7/8+1/8)*cosd(180-cooM.x/100*180),(cooM.y/400*7/8+1/8)*sind(cooM.z)*sind(180-cooM.x/100*180)>;
					#local cooN = <(cooN.y/400*7/8+1/8)*cosd(cooN.z)*sind(180-cooN.x/100*180),(cooN.y/400*7/8+1/8)*cosd(180-cooN.x/100*180),(cooN.y/400*7/8+1/8)*sind(cooN.z)*sind(180-cooN.x/100*180)>;
					#local cooO = <(cooO.y/400*7/8+1/8)*cosd(cooO.z)*sind(180-cooO.x/100*180),(cooO.y/400*7/8+1/8)*cosd(180-cooO.x/100*180),(cooO.y/400*7/8+1/8)*sind(cooO.z)*sind(180-cooO.x/100*180)>;
					#local cooP = <(cooP.y/400*7/8+1/8)*cosd(cooP.z)*sind(180-cooP.x/100*180),(cooP.y/400*7/8+1/8)*cosd(180-cooP.x/100*180),(cooP.y/400*7/8+1/8)*sind(cooP.z)*sind(180-cooP.x/100*180)>;
				#break
				// CIELUV (cube)
				#case (5)		
					// convert XYZ to LUV step 1: get un-normalized values
					#local cooA = cie_convXYZ2LUV(XYZA);
					#local cooB = cie_convXYZ2LUV(XYZB);
					#local cooC = cie_convXYZ2LUV(XYZC);
					#local cooD = cie_convXYZ2LUV(XYZD);
					#local cooE = cie_convXYZ2LUV(XYZE);
					#local cooF = cie_convXYZ2LUV(XYZF);
					#local cooG = cie_convXYZ2LUV(XYZG);
					#local cooH = cie_convXYZ2LUV(XYZH);
					#local cooI = cie_convXYZ2LUV(XYZI);
					#local cooJ = cie_convXYZ2LUV(XYZJ);
					#local cooK = cie_convXYZ2LUV(XYZK);
					#local cooL = cie_convXYZ2LUV(XYZL);
					#local cooM = cie_convXYZ2LUV(XYZM);
					#local cooN = cie_convXYZ2LUV(XYZN);
					#local cooO = cie_convXYZ2LUV(XYZO);
					#local cooP = cie_convXYZ2LUV(XYZP);
					// convert XYZ to LUV step 2: normalize and swap x and y
					// make sure the denominators here match the axes labels
					#local cooA = <cooA.y/400,cooA.x/100,cooA.z/400>;
					#local cooB = <cooB.y/400,cooB.x/100,cooB.z/400>;
					#local cooC = <cooC.y/400,cooC.x/100,cooC.z/400>;
					#local cooD = <cooD.y/400,cooD.x/100,cooD.z/400>;
					#local cooE = <cooE.y/400,cooE.x/100,cooE.z/400>;
					#local cooF = <cooF.y/400,cooF.x/100,cooF.z/400>;
					#local cooG = <cooG.y/400,cooG.x/100,cooG.z/400>;
					#local cooH = <cooH.y/400,cooH.x/100,cooH.z/400>;
					#local cooI = <cooI.y/400,cooI.x/100,cooI.z/400>;
					#local cooJ = <cooJ.y/400,cooJ.x/100,cooJ.z/400>;
					#local cooK = <cooK.y/400,cooK.x/100,cooK.z/400>;
					#local cooL = <cooL.y/400,cooL.x/100,cooL.z/400>;
					#local cooM = <cooM.y/400,cooM.x/100,cooM.z/400>;
					#local cooN = <cooN.y/400,cooN.x/100,cooN.z/400>;
					#local cooO = <cooO.y/400,cooO.x/100,cooO.z/400>;
					#local cooP = <cooP.y/400,cooP.x/100,cooP.z/400>;
				#break
				// CIELCHuv (cylinder)
				#case (6)		
					// convert XYZ to LUV to LCHuv step 1: get un-normalized values
					#local cooA = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZA));
					#local cooB = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZB));
					#local cooC = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZC));
					#local cooD = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZD));
					#local cooE = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZE));
					#local cooF = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZF));
					#local cooG = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZG));
					#local cooH = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZH));
					#local cooI = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZI));
					#local cooJ = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZJ));
					#local cooK = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZK));
					#local cooL = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZL));
					#local cooM = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZM));
					#local cooN = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZN));
					#local cooO = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZO));
					#local cooP = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZP));
					// convert XYZ to LUV to LCHuv step 2: normalize and convert to cartesian coordinates
					// make sure the denominators here match the axes labels
					#local cooA = <cooA.y/400*cosd(cooA.z),cooA.x/100,cooA.y/400*sind(cooA.z)>;
					#local cooB = <cooB.y/400*cosd(cooB.z),cooB.x/100,cooB.y/400*sind(cooB.z)>;
					#local cooC = <cooC.y/400*cosd(cooC.z),cooC.x/100,cooC.y/400*sind(cooC.z)>;
					#local cooD = <cooD.y/400*cosd(cooD.z),cooD.x/100,cooD.y/400*sind(cooD.z)>;
					#local cooE = <cooE.y/400*cosd(cooE.z),cooE.x/100,cooE.y/400*sind(cooE.z)>;
					#local cooF = <cooF.y/400*cosd(cooF.z),cooF.x/100,cooF.y/400*sind(cooF.z)>;
					#local cooG = <cooG.y/400*cosd(cooG.z),cooG.x/100,cooG.y/400*sind(cooG.z)>;
					#local cooH = <cooH.y/400*cosd(cooH.z),cooH.x/100,cooH.y/400*sind(cooH.z)>;
					#local cooI = <cooI.y/400*cosd(cooI.z),cooI.x/100,cooI.y/400*sind(cooI.z)>;
					#local cooJ = <cooJ.y/400*cosd(cooJ.z),cooJ.x/100,cooJ.y/400*sind(cooJ.z)>;
					#local cooK = <cooK.y/400*cosd(cooK.z),cooK.x/100,cooK.y/400*sind(cooK.z)>;
					#local cooL = <cooL.y/400*cosd(cooL.z),cooL.x/100,cooL.y/400*sind(cooL.z)>;
					#local cooM = <cooM.y/400*cosd(cooM.z),cooM.x/100,cooM.y/400*sind(cooM.z)>;
					#local cooN = <cooN.y/400*cosd(cooN.z),cooN.x/100,cooN.y/400*sind(cooN.z)>;
					#local cooO = <cooO.y/400*cosd(cooO.z),cooO.x/100,cooO.y/400*sind(cooO.z)>;
					#local cooP = <cooP.y/400*cosd(cooP.z),cooP.x/100,cooP.y/400*sind(cooP.z)>;
				#break
				// CIELCHuv (sphere)
				#case (7)		
					// convert XYZ to LUV to LCHuv step 1: get un-normalized values
					#local cooA = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZA));
					#local cooB = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZB));
					#local cooC = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZC));
					#local cooD = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZD));
					#local cooE = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZE));
					#local cooF = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZF));
					#local cooG = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZG));
					#local cooH = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZH));
					#local cooI = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZI));
					#local cooJ = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZJ));
					#local cooK = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZK));
					#local cooL = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZL));
					#local cooM = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZM));
					#local cooN = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZN));
					#local cooO = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZO));
					#local cooP = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZP));
					// convert XYZ to LUV to LCHuv step 2: normalize and convert to cartesian coordinates
					// make sure the denominators here match the axes labels
					#local cooA = <(cooA.y/400*7/8+1/8)*cosd(cooA.z)*sind(180-cooA.x/100*180),(cooA.y/400*7/8+1/8)*cosd(180-cooA.x/100*180),(cooA.y/400*7/8+1/8)*sind(cooA.z)*sind(180-cooA.x/100*180)>;
					#local cooB = <(cooB.y/400*7/8+1/8)*cosd(cooB.z)*sind(180-cooB.x/100*180),(cooB.y/400*7/8+1/8)*cosd(180-cooB.x/100*180),(cooB.y/400*7/8+1/8)*sind(cooB.z)*sind(180-cooB.x/100*180)>;
					#local cooC = <(cooC.y/400*7/8+1/8)*cosd(cooC.z)*sind(180-cooC.x/100*180),(cooC.y/400*7/8+1/8)*cosd(180-cooC.x/100*180),(cooC.y/400*7/8+1/8)*sind(cooC.z)*sind(180-cooC.x/100*180)>;
					#local cooD = <(cooD.y/400*7/8+1/8)*cosd(cooD.z)*sind(180-cooD.x/100*180),(cooD.y/400*7/8+1/8)*cosd(180-cooD.x/100*180),(cooD.y/400*7/8+1/8)*sind(cooD.z)*sind(180-cooD.x/100*180)>;
					#local cooE = <(cooE.y/400*7/8+1/8)*cosd(cooE.z)*sind(180-cooE.x/100*180),(cooE.y/400*7/8+1/8)*cosd(180-cooE.x/100*180),(cooE.y/400*7/8+1/8)*sind(cooE.z)*sind(180-cooE.x/100*180)>;
					#local cooF = <(cooF.y/400*7/8+1/8)*cosd(cooF.z)*sind(180-cooF.x/100*180),(cooF.y/400*7/8+1/8)*cosd(180-cooF.x/100*180),(cooF.y/400*7/8+1/8)*sind(cooF.z)*sind(180-cooF.x/100*180)>;
					#local cooG = <(cooG.y/400*7/8+1/8)*cosd(cooG.z)*sind(180-cooG.x/100*180),(cooG.y/400*7/8+1/8)*cosd(180-cooG.x/100*180),(cooG.y/400*7/8+1/8)*sind(cooG.z)*sind(180-cooG.x/100*180)>;
					#local cooH = <(cooH.y/400*7/8+1/8)*cosd(cooH.z)*sind(180-cooH.x/100*180),(cooH.y/400*7/8+1/8)*cosd(180-cooH.x/100*180),(cooH.y/400*7/8+1/8)*sind(cooH.z)*sind(180-cooH.x/100*180)>;
					#local cooI = <(cooI.y/400*7/8+1/8)*cosd(cooI.z)*sind(180-cooI.x/100*180),(cooI.y/400*7/8+1/8)*cosd(180-cooI.x/100*180),(cooI.y/400*7/8+1/8)*sind(cooI.z)*sind(180-cooI.x/100*180)>;
					#local cooJ = <(cooJ.y/400*7/8+1/8)*cosd(cooJ.z)*sind(180-cooJ.x/100*180),(cooJ.y/400*7/8+1/8)*cosd(180-cooJ.x/100*180),(cooJ.y/400*7/8+1/8)*sind(cooJ.z)*sind(180-cooJ.x/100*180)>;
					#local cooK = <(cooK.y/400*7/8+1/8)*cosd(cooK.z)*sind(180-cooK.x/100*180),(cooK.y/400*7/8+1/8)*cosd(180-cooK.x/100*180),(cooK.y/400*7/8+1/8)*sind(cooK.z)*sind(180-cooK.x/100*180)>;
					#local cooL = <(cooL.y/400*7/8+1/8)*cosd(cooL.z)*sind(180-cooL.x/100*180),(cooL.y/400*7/8+1/8)*cosd(180-cooL.x/100*180),(cooL.y/400*7/8+1/8)*sind(cooL.z)*sind(180-cooL.x/100*180)>;
					#local cooM = <(cooM.y/400*7/8+1/8)*cosd(cooM.z)*sind(180-cooM.x/100*180),(cooM.y/400*7/8+1/8)*cosd(180-cooM.x/100*180),(cooM.y/400*7/8+1/8)*sind(cooM.z)*sind(180-cooM.x/100*180)>;
					#local cooN = <(cooN.y/400*7/8+1/8)*cosd(cooN.z)*sind(180-cooN.x/100*180),(cooN.y/400*7/8+1/8)*cosd(180-cooN.x/100*180),(cooN.y/400*7/8+1/8)*sind(cooN.z)*sind(180-cooN.x/100*180)>;
					#local cooO = <(cooO.y/400*7/8+1/8)*cosd(cooO.z)*sind(180-cooO.x/100*180),(cooO.y/400*7/8+1/8)*cosd(180-cooO.x/100*180),(cooO.y/400*7/8+1/8)*sind(cooO.z)*sind(180-cooO.x/100*180)>;
					#local cooP = <(cooP.y/400*7/8+1/8)*cosd(cooP.z)*sind(180-cooP.x/100*180),(cooP.y/400*7/8+1/8)*cosd(180-cooP.x/100*180),(cooP.y/400*7/8+1/8)*sind(cooP.z)*sind(180-cooP.x/100*180)>;
				#break
				#else
					#error "Have not implemented this color space yet."
			#end
			// construct triangles (first and last are not used)
			#local triEAB = array[3] {cooE,cooA,cooB}	// not used
			#local triFBC = array[3] {cooF,cooB,cooC}
			#local triGCD = array[3] {cooF,cooB,cooC}
			#local triIEF = array[3] {cooF,cooB,cooC}
			#local triJFG = array[3] {cooF,cooB,cooC}
			#local triKGH = array[3] {cooF,cooB,cooC}
			#local triMIJ = array[3] {cooF,cooB,cooC}
			#local triNJK = array[3] {cooF,cooB,cooC}
			#local triOKL = array[3] {cooF,cooB,cooC}
			#local triBFE = array[3] {cooF,cooB,cooC}
			#local triCGF = array[3] {cooF,cooB,cooC}
			#local triDHG = array[3] {cooF,cooB,cooC}
			#local triFJI = array[3] {cooF,cooB,cooC}
			#local triGKJ = array[3] {cooF,cooB,cooC}
			#local triHLK = array[3] {cooF,cooB,cooC}
			#local triJNM = array[3] {cooF,cooB,cooC}
			#local triKON = array[3] {cooF,cooB,cooC}
			#local triLPO = array[3] {cooF,cooB,cooC}	// not used
			// calculate tangent vectors (first and last are not used)
			#local vecEAB = array[2] {triEAB[1]-triEAB[0],triEAB[2]-triEAB[0]}	// not used
			#local vecFBC = array[2] {triFBC[1]-triFBC[0],triFBC[2]-triFBC[0]}
			#local vecGCD = array[2] {triGCD[1]-triGCD[0],triGCD[2]-triGCD[0]}
			#local vecIEF = array[2] {triIEF[1]-triIEF[0],triIEF[2]-triIEF[0]}
			#local vecJFG = array[2] {triJFG[1]-triJFG[0],triJFG[2]-triJFG[0]}
			#local vecKGH = array[2] {triKGH[1]-triKGH[0],triKGH[2]-triKGH[0]}
			#local vecMIJ = array[2] {triMIJ[1]-triMIJ[0],triMIJ[2]-triMIJ[0]}
			#local vecNJK = array[2] {triNJK[1]-triNJK[0],triNJK[2]-triNJK[0]}
			#local vecOKL = array[2] {triOKL[1]-triOKL[0],triOKL[2]-triOKL[0]}
			#local vecBFE = array[2] {triBFE[1]-triBFE[0],triBFE[2]-triBFE[0]}
			#local vecCGF = array[2] {triCGF[1]-triCGF[0],triCGF[2]-triCGF[0]}
			#local vecDHG = array[2] {triDHG[1]-triDHG[0],triDHG[2]-triDHG[0]}
			#local vecFJI = array[2] {triFJI[1]-triFJI[0],triFJI[2]-triFJI[0]}
			#local vecGKJ = array[2] {triGKJ[1]-triGKJ[0],triGKJ[2]-triGKJ[0]}
			#local vecHLK = array[2] {triHLK[1]-triHLK[0],triHLK[2]-triHLK[0]}
			#local vecJNM = array[2] {triJNM[1]-triJNM[0],triJNM[2]-triJNM[0]}
			#local vecKON = array[2] {triKON[1]-triKON[0],triKON[2]-triKON[0]}
			#local vecLPO = array[2] {triLPO[1]-triLPO[0],triLPO[2]-triLPO[0]}	// not used
			// calculate normal vectors (first and last are not used)
			#local norEAB = <vecEAB[0].y*vecEAB[1].z-vecEAB[0].z*vecEAB[1].y,vecEAB[0].z*vecEAB[1].x-vecEAB[0].x*vecEAB[1].z,vecEAB[0].x*vecEAB[1].y-vecEAB[0].y*vecEAB[1].x>;	// not used
			#local norFBC = <vecFBC[0].y*vecFBC[1].z-vecFBC[0].z*vecFBC[1].y,vecFBC[0].z*vecFBC[1].x-vecFBC[0].x*vecFBC[1].z,vecFBC[0].x*vecFBC[1].y-vecFBC[0].y*vecFBC[1].x>;
			#local norGCD = <vecGCD[0].y*vecGCD[1].z-vecGCD[0].z*vecGCD[1].y,vecGCD[0].z*vecGCD[1].x-vecGCD[0].x*vecGCD[1].z,vecGCD[0].x*vecGCD[1].y-vecGCD[0].y*vecGCD[1].x>;
			#local norIEF = <vecIEF[0].y*vecIEF[1].z-vecIEF[0].z*vecIEF[1].y,vecIEF[0].z*vecIEF[1].x-vecIEF[0].x*vecIEF[1].z,vecIEF[0].x*vecIEF[1].y-vecIEF[0].y*vecIEF[1].x>;
			#local norJFG = <vecJFG[0].y*vecJFG[1].z-vecJFG[0].z*vecJFG[1].y,vecJFG[0].z*vecJFG[1].x-vecJFG[0].x*vecJFG[1].z,vecJFG[0].x*vecJFG[1].y-vecJFG[0].y*vecJFG[1].x>;
			#local norKGH = <vecKGH[0].y*vecKGH[1].z-vecKGH[0].z*vecKGH[1].y,vecKGH[0].z*vecKGH[1].x-vecKGH[0].x*vecKGH[1].z,vecKGH[0].x*vecKGH[1].y-vecKGH[0].y*vecKGH[1].x>;
			#local norMIJ = <vecMIJ[0].y*vecMIJ[1].z-vecMIJ[0].z*vecMIJ[1].y,vecMIJ[0].z*vecMIJ[1].x-vecMIJ[0].x*vecMIJ[1].z,vecMIJ[0].x*vecMIJ[1].y-vecMIJ[0].y*vecMIJ[1].x>;
			#local norNJK = <vecNJK[0].y*vecNJK[1].z-vecNJK[0].z*vecNJK[1].y,vecNJK[0].z*vecNJK[1].x-vecNJK[0].x*vecNJK[1].z,vecNJK[0].x*vecNJK[1].y-vecNJK[0].y*vecNJK[1].x>;
			#local norOKL = <vecOKL[0].y*vecOKL[1].z-vecOKL[0].z*vecOKL[1].y,vecOKL[0].z*vecOKL[1].x-vecOKL[0].x*vecOKL[1].z,vecOKL[0].x*vecOKL[1].y-vecOKL[0].y*vecOKL[1].x>;
			#local norBFE = <vecBFE[0].y*vecBFE[1].z-vecBFE[0].z*vecBFE[1].y,vecBFE[0].z*vecBFE[1].x-vecBFE[0].x*vecBFE[1].z,vecBFE[0].x*vecBFE[1].y-vecBFE[0].y*vecBFE[1].x>;
			#local norCGF = <vecCGF[0].y*vecCGF[1].z-vecCGF[0].z*vecCGF[1].y,vecCGF[0].z*vecCGF[1].x-vecCGF[0].x*vecCGF[1].z,vecCGF[0].x*vecCGF[1].y-vecCGF[0].y*vecCGF[1].x>;
			#local norDHG = <vecDHG[0].y*vecDHG[1].z-vecDHG[0].z*vecDHG[1].y,vecDHG[0].z*vecDHG[1].x-vecDHG[0].x*vecDHG[1].z,vecDHG[0].x*vecDHG[1].y-vecDHG[0].y*vecDHG[1].x>;
			#local norFJI = <vecFJI[0].y*vecFJI[1].z-vecFJI[0].z*vecFJI[1].y,vecFJI[0].z*vecFJI[1].x-vecFJI[0].x*vecFJI[1].z,vecFJI[0].x*vecFJI[1].y-vecFJI[0].y*vecFJI[1].x>;
			#local norGKJ = <vecGKJ[0].y*vecGKJ[1].z-vecGKJ[0].z*vecGKJ[1].y,vecGKJ[0].z*vecGKJ[1].x-vecGKJ[0].x*vecGKJ[1].z,vecGKJ[0].x*vecGKJ[1].y-vecGKJ[0].y*vecGKJ[1].x>;
			#local norHLK = <vecHLK[0].y*vecHLK[1].z-vecHLK[0].z*vecHLK[1].y,vecHLK[0].z*vecHLK[1].x-vecHLK[0].x*vecHLK[1].z,vecHLK[0].x*vecHLK[1].y-vecHLK[0].y*vecHLK[1].x>;
			#local norJNM = <vecJNM[0].y*vecJNM[1].z-vecJNM[0].z*vecJNM[1].y,vecJNM[0].z*vecJNM[1].x-vecJNM[0].x*vecJNM[1].z,vecJNM[0].x*vecJNM[1].y-vecJNM[0].y*vecJNM[1].x>;
			#local norKON = <vecKON[0].y*vecKON[1].z-vecKON[0].z*vecKON[1].y,vecKON[0].z*vecKON[1].x-vecKON[0].x*vecKON[1].z,vecKON[0].x*vecKON[1].y-vecKON[0].y*vecKON[1].x>;
			#local norLPO = <vecLPO[0].y*vecLPO[1].z-vecLPO[0].z*vecLPO[1].y,vecLPO[0].z*vecLPO[1].x-vecLPO[0].x*vecLPO[1].z,vecLPO[0].x*vecLPO[1].y-vecLPO[0].y*vecLPO[1].x>;	// not used
			// calculate vertex normals (only need four of these)
//			#debug concat("i = ", str(i, 0, 0), "; j = ", str(j, 0, 0), "\n")
			#local norJ = vnormalize(norJFG+norGKJ+norNJK+norJNM+norMIJ+norFJI);
			#local norF = vnormalize(norFBC+norCGF+norJFG+norFJI+norIEF+norBFE);
			#local norG = vnormalize(norGCD+norDHG+norKGH+norGKJ+norJFG+norCGF);
			#local norK = vnormalize(norKGH+norHLK+norOKL+norKON+norNJK+norGKJ);
			// create textures (only need two of these)
			#local colJFG = (colJ + colF + colG)/3;
			#local colGKJ = (colG + colK + colJ)/3;
			// write stuff to log
			#write (cie_write_handle, "\t#local temp_texture = texture {pigment {color srgb ", colJFG, "} finish {cie_isoFinish}}\n")
			#write (cie_write_handle, "\tsmooth_triangle {", cooJ, ",", norJ, ",", cooF, ",", norF, ",", cooG, ",", norG, " texture {temp_texture}}\n")
			#write (cie_write_handle, "\t#local temp_texture = texture {pigment {color srgb ", colGKJ, "} finish {cie_isoFinish}}\n")
			#write (cie_write_handle, "\tsmooth_triangle {", cooG, ",", norG, ",", cooK, ",", norK, ",", cooJ, ",", norJ, " texture {temp_texture}}\n")
		#end
	#end
	#write (cie_write_handle, "}\n")
	#fclose cie_write_handle
#end


// Original CIE 1931 2-degree color matching functions (CMFs).
// Copied from "ciexyz31.csv" available at "http://www.cvrl.org/cmfs.htm".
// Note that there are "updated" versions of these color functions at that site, too.
#declare cie_xyz_table = array[95]
{
	<0.000129900000,0.000003917000,0.000606100000>,//360
	<0.000232100000,0.000006965000,0.001086000000>,//365
	<0.000414900000,0.000012390000,0.001946000000>,//370
	<0.000741600000,0.000022020000,0.003486000000>,//375
	<0.001368000000,0.000039000000,0.006450001000>,//380
	<0.002236000000,0.000064000000,0.010549990000>,//385
	<0.004243000000,0.000120000000,0.020050010000>,//390
	<0.007650000000,0.000217000000,0.036210000000>,//395
	<0.014310000000,0.000396000000,0.067850010000>,//400
	<0.023190000000,0.000640000000,0.110200000000>,//405
	<0.043510000000,0.001210000000,0.207400000000>,//410
	<0.077630000000,0.002180000000,0.371300000000>,//415
	<0.134380000000,0.004000000000,0.645600000000>,//420
	<0.214770000000,0.007300000000,1.039050100000>,//425
	<0.283900000000,0.011600000000,1.385600000000>,//430
	<0.328500000000,0.016840000000,1.622960000000>,//435
	<0.348280000000,0.023000000000,1.747060000000>,//440
	<0.348060000000,0.029800000000,1.782600000000>,//445
	<0.336200000000,0.038000000000,1.772110000000>,//450
	<0.318700000000,0.048000000000,1.744100000000>,//455
	<0.290800000000,0.060000000000,1.669200000000>,//460
	<0.251100000000,0.073900000000,1.528100000000>,//465
	<0.195360000000,0.090980000000,1.287640000000>,//470
	<0.142100000000,0.112600000000,1.041900000000>,//475
	<0.095640000000,0.139020000000,0.812950100000>,//480
	<0.057950010000,0.169300000000,0.616200000000>,//485
	<0.032010000000,0.208020000000,0.465180000000>,//490
	<0.014700000000,0.258600000000,0.353300000000>,//495
	<0.004900000000,0.323000000000,0.272000000000>,//500
	<0.002400000000,0.407300000000,0.212300000000>,//505
	<0.009300000000,0.503000000000,0.158200000000>,//510
	<0.029100000000,0.608200000000,0.111700000000>,//515
	<0.063270000000,0.710000000000,0.078249990000>,//520
	<0.109600000000,0.793200000000,0.057250010000>,//525
	<0.165500000000,0.862000000000,0.042160000000>,//530
	<0.225749900000,0.914850100000,0.029840000000>,//535
	<0.290400000000,0.954000000000,0.020300000000>,//540
	<0.359700000000,0.980300000000,0.013400000000>,//545
	<0.433449900000,0.994950100000,0.008749999000>,//550
	<0.512050100000,1.000000000000,0.005749999000>,//555
	<0.594500000000,0.995000000000,0.003900000000>,//560
	<0.678400000000,0.978600000000,0.002749999000>,//565
	<0.762100000000,0.952000000000,0.002100000000>,//570
	<0.842500000000,0.915400000000,0.001800000000>,//575
	<0.916300000000,0.870000000000,0.001650001000>,//580
	<0.978600000000,0.816300000000,0.001400000000>,//585
	<1.026300000000,0.757000000000,0.001100000000>,//590
	<1.056700000000,0.694900000000,0.001000000000>,//595
	<1.062200000000,0.631000000000,0.000800000000>,//600
	<1.045600000000,0.566800000000,0.000600000000>,//605
	<1.002600000000,0.503000000000,0.000340000000>,//610
	<0.938400000000,0.441200000000,0.000240000000>,//615
	<0.854449900000,0.381000000000,0.000190000000>,//620
	<0.751400000000,0.321000000000,0.000100000000>,//625
	<0.642400000000,0.265000000000,0.000049999990>,//630
	<0.541900000000,0.217000000000,0.000030000000>,//635
	<0.447900000000,0.175000000000,0.000020000000>,//640
	<0.360800000000,0.138200000000,0.000010000000>,//645
	<0.283500000000,0.107000000000,0.000000000000>,//650
	<0.218700000000,0.081600000000,0.000000000000>,//655
	<0.164900000000,0.061000000000,0.000000000000>,//660
	<0.121200000000,0.044580000000,0.000000000000>,//665
	<0.087400000000,0.032000000000,0.000000000000>,//670
	<0.063600000000,0.023200000000,0.000000000000>,//675
	<0.046770000000,0.017000000000,0.000000000000>,//680
	<0.032900000000,0.011920000000,0.000000000000>,//685
	<0.022700000000,0.008210000000,0.000000000000>,//690
	<0.015840000000,0.005723000000,0.000000000000>,//695
	<0.011359160000,0.004102000000,0.000000000000>,//700
	<0.008110916000,0.002929000000,0.000000000000>,//705
	<0.005790346000,0.002091000000,0.000000000000>,//710
	<0.004109457000,0.001484000000,0.000000000000>,//715
	<0.002899327000,0.001047000000,0.000000000000>,//720
	<0.002049190000,0.000740000000,0.000000000000>,//725
	<0.001439971000,0.000520000000,0.000000000000>,//730
	<0.000999949300,0.000361100000,0.000000000000>,//735
	<0.000690078600,0.000249200000,0.000000000000>,//740
	<0.000476021300,0.000171900000,0.000000000000>,//745
	<0.000332301100,0.000120000000,0.000000000000>,//750
	<0.000234826100,0.000084800000,0.000000000000>,//755
	<0.000166150500,0.000060000000,0.000000000000>,//760
	<0.000117413000,0.000042400000,0.000000000000>,//765
	<0.000083075270,0.000030000000,0.000000000000>,//770
	<0.000058706520,0.000021200000,0.000000000000>,//775
	<0.000041509940,0.000014990000,0.000000000000>,//780
	<0.000029353260,0.000010600000,0.000000000000>,//785
	<0.000020673830,0.000007465700,0.000000000000>,//790
	<0.000014559770,0.000005257800,0.000000000000>,//795
	<0.000010253980,0.000003702900,0.000000000000>,//800
	<0.000007221456,0.000002607800,0.000000000000>,//805
	<0.000005085868,0.000001836600,0.000000000000>,//810
	<0.000003581652,0.000001293400,0.000000000000>,//815
	<0.000002522525,0.000000910930,0.000000000000>,//820
	<0.000001776509,0.000000641530,0.000000000000>,//825
	<0.000001251141,0.000000451810,0.000000000000>,//830
}

// Relative spectral power distribution of CIE Standard Illuminant D65.
// Copied from "204.xls" available at "http://www.cie.co.at/index.php/LEFTMENUE/index.php?i_ca_id=298".
#declare cie_D65_table = array[95]
{
//	  0.034100,//300
//	  1.664300,//305
//	  3.294500,//310
//	 11.765200,//315
//	 20.236000,//320
//	 28.644700,//325
//	 37.053500,//330
//	 38.501100,//335
//	 39.948800,//340
//	 42.430200,//345
//	 44.911700,//350
//	 45.775000,//355
	 46.638300,//360
	 49.363700,//365
	 52.089100,//370
	 51.032300,//375
	 49.975500,//380
	 52.311800,//385
	 54.648200,//390
	 68.701500,//395
	 82.754900,//400
	 87.120400,//405
	 91.486000,//410
	 92.458900,//415
	 93.431800,//420
	 90.057000,//425
	 86.682300,//430
	 95.773600,//435
	104.865000,//440
	110.936000,//445
	117.008000,//450
	117.410000,//455
	117.812000,//460
	116.336000,//465
	114.861000,//470
	115.392000,//475
	115.923000,//480
	112.367000,//485
	108.811000,//490
	109.082000,//495
	109.354000,//500
	108.578000,//505
	107.802000,//510
	106.296000,//515
	104.790000,//520
	106.239000,//525
	107.689000,//530
	106.047000,//535
	104.405000,//540
	104.225000,//545
	104.046000,//550
	102.023000,//555
	100.000000,//560
	 98.167100,//565
	 96.334200,//570
	 96.061100,//575
	 95.788000,//580
	 92.236800,//585
	 88.685600,//590
	 89.345900,//595
	 90.006200,//600
	 89.802600,//605
	 89.599100,//610
	 88.648900,//615
	 87.698700,//620
	 85.493600,//625
	 83.288600,//630
	 83.493900,//635
	 83.699200,//640
	 81.863000,//645
	 80.026800,//650
	 80.120700,//655
	 80.214600,//660
	 81.246200,//665
	 82.277800,//670
	 80.281000,//675
	 78.284200,//680
	 74.002700,//685
	 69.721300,//690
	 70.665200,//695
	 71.609100,//700
	 72.979000,//705
	 74.349000,//710
	 67.976500,//715
	 61.604000,//720
	 65.744800,//725
	 69.885600,//730
	 72.486300,//735
	 75.087000,//740
	 69.339800,//745
	 63.592700,//750
	 55.005400,//755
	 46.418200,//760
	 56.611800,//765
	 66.805400,//770
	 65.094100,//775
	 63.382800,//780
	 63.843400,//785
	 64.304000,//790
	 61.877900,//795
	 59.451900,//800
	 55.705400,//805
	 51.959000,//810
	 54.699800,//815
	 57.440600,//820
	 58.876500,//825
	 60.312500 //830
}

// pre-populate XYZ tables on disk
#if (cie_pre_xyz_visible = true)
	cie_calc_gamut_xyz_visible()
	cie_write_XYZ_coordinates_visible("cie_xyz_data_visible.inc")
#end
// pre-populate mesh geometry on disk
#if (cie_pre_mesh_visible = true)
	#include "cie_xyz_data_visible.inc"
	cie_write_flatmesh_visible(cie_cspace_visible, cie_mesh_file_visible)
#end


//------------------------------------------------------------------------------
// srgb gamut


#declare cie_sample_count_srgb = 192/6;	// needs to be divisible by 6!!!
#declare cie_point_count_srgb = 1;
#declare cie_point_total_srgb = 6 * (cie_sample_count_srgb+1) * (cie_sample_count_srgb+1);
#declare cie_point_array_srgb = array[6][cie_sample_count_srgb+1][cie_sample_count_srgb+1];



#macro cie_clip_index_other(iIndex)
	// note that additional rows have been added for white and black
	#if (iIndex < 0)
		#local oIndex = 0;
	#elseif (iIndex > cie_sample_count_srgb)
		#local oIndex = cie_sample_count_srgb;
	#else
		#local oIndex = iIndex;
	#end
	oIndex
#end

#macro cie_calc_gamut_xyz_srgb()
	// should handle black in the xyY space separately, but am unsure how
	#for (i, 0, cie_sample_count_srgb)
		#for (j, 0, cie_sample_count_srgb)
			// side 0 & 3
			#local cooRGB = <i/cie_sample_count_srgb,j/cie_sample_count_srgb,0>;
			#local cooXYZ = cie_convRGB2XYZ(cooRGB);
			#declare cie_point_array_srgb[0][i][j] = cooXYZ;
			#local cooRGB = <i/cie_sample_count_srgb,j/cie_sample_count_srgb,1>;
			#local cooXYZ = cie_convRGB2XYZ(cooRGB);
			#declare cie_point_array_srgb[3][i][j] = cooXYZ;
			// side 1 & 4
			#local cooRGB = <i/cie_sample_count_srgb,0,j/cie_sample_count_srgb>;
			#local cooXYZ = cie_convRGB2XYZ(cooRGB);
			#declare cie_point_array_srgb[1][i][j] = cooXYZ;
			#local cooRGB = <i/cie_sample_count_srgb,1,j/cie_sample_count_srgb>;
			#local cooXYZ = cie_convRGB2XYZ(cooRGB);
			#declare cie_point_array_srgb[4][i][j] = cooXYZ;
			// side 2 & 5
			#local cooRGB = <0,i/cie_sample_count_srgb,j/cie_sample_count_srgb>;
			#local cooXYZ = cie_convRGB2XYZ(cooRGB);
			#declare cie_point_array_srgb[2][i][j] = cooXYZ;
			#local cooRGB = <1,i/cie_sample_count_srgb,j/cie_sample_count_srgb>;
			#local cooXYZ = cie_convRGB2XYZ(cooRGB);
			#declare cie_point_array_srgb[5][i][j] = cooXYZ;
		#end
	#end
#end

// print XYZ coordinates to file as text
#macro cie_write_XYZ_coordinates_srgb(cie_filename)
	#fopen cie_write_handle cie_filename write
	#write (cie_write_handle, "#declare cie_point_array_srgb = array[6][", cie_sample_count_srgb+1, "][", cie_sample_count_srgb+1, "]\n{\n")
	#for (k, 0, 5)
		#write (cie_write_handle, "\t{\n")
		#for (i, 0, cie_sample_count_srgb)
			#write (cie_write_handle, "\t\t{\n")
			#for (j, 0, cie_sample_count_srgb)
				#write (cie_write_handle, "\t\t\t<", vstr(3, cie_point_array_srgb[k][i][j], ",", 0, 9), ">")
				#if (j < cie_sample_count_srgb)
					#write (cie_write_handle, ",")
				#else
					#write (cie_write_handle, " ")
				#end
				#write (cie_write_handle, "\t// ", str(k,2,0), ",", str(i,2,0), ",", str(j,2,0), "\n")
			#end
			#write (cie_write_handle, "\t\t}")
			#if (i < cie_sample_count_srgb)
				#write (cie_write_handle, ",")
			#end
			#write (cie_write_handle, "\n")
		#end
		#write (cie_write_handle, "\t}")
		#if (k < 5)
			#write (cie_write_handle, ",")
		#end
		#write (cie_write_handle, "\n")
	#end
	#write (cie_write_handle, "}\n")
	#fclose cie_write_handle
#end

// flat triangle mesh
#macro cie_write_flatmesh_srgb(color_space, cie_filename)
	#fopen cie_write_handle cie_filename write
	#write (cie_write_handle, "mesh\n{\n")
	// once per each "face" of the figure
	#for (k, 0, 5)
		// skip the first row since you can't build a mesh from it all by itself
		#for (i, 1, cie_sample_count_srgb)
			// skip the first column since you can't build a mesh from it all by itself
			#for (j, 1, cie_sample_count_srgb)
				// flag to skip this loop
				#local pass_me = true;
				// get XYZ values
				#local XYZa1 = cie_point_array_srgb[k][cie_clip_index_other(i-0)][cie_clip_index_other(j-1)];
				#local XYZb1 = cie_point_array_srgb[k][cie_clip_index_other(i-0)][cie_clip_index_other(j-0)];
				#local XYZa2 = cie_point_array_srgb[k][cie_clip_index_other(i-1)][cie_clip_index_other(j-1)];
				#local XYZb2 = cie_point_array_srgb[k][cie_clip_index_other(i-1)][cie_clip_index_other(j-0)];
				// get colors
				#local cola1 = cie_convXYZ2RGB(XYZa1);
				#local colb1 = cie_convXYZ2RGB(XYZb1);
				#local cola2 = cie_convXYZ2RGB(XYZa2);
				#local colb2 = cie_convXYZ2RGB(XYZb2);
				#switch (color_space)
					// xyY
					#case (0)
						// zeroes are degenerate in this color space
						#if (VEq(XYZa1, <0,0,0>) | VEq(XYZb1, <0,0,0>) | VEq(XYZa2, <0,0,0>) | VEq(XYZb2, <0,0,0>))
							#local pass_me = false;
						#end
						// convert XYZ to xyY
						#local cooa1 = cie_convXYZ2XYY(XYZa1);
						#local coob1 = cie_convXYZ2XYY(XYZb1);
						#local cooa2 = cie_convXYZ2XYY(XYZa2);
						#local coob2 = cie_convXYZ2XYY(XYZb2);
						// switch y and z and normalize Y
						#local cooa1 = <cooa1.x,cooa1.z/100,cooa1.y>;
						#local coob1 = <coob1.x,coob1.z/100,coob1.y>;
						#local cooa2 = <cooa2.x,cooa2.z/100,cooa2.y>;
						#local coob2 = <coob2.x,coob2.z/100,coob2.y>;
					#break
					// CIEXYZ (cube)
					#case (1)
						// don't do anything but normalize
						// make sure the denominators here match the axes labels
						#local cooa1 = XYZa1/100;
						#local coob1 = XYZb1/100;
						#local cooa2 = XYZa2/100;
						#local coob2 = XYZb2/100;
					#break
					// CIELAB (cube)
					#case (2)
						// convert XYZ to LAB step 1: get un-normalized values
						#local cooa1 = cie_convXYZ2LAB(XYZa1);
						#local coob1 = cie_convXYZ2LAB(XYZb1);
						#local cooa2 = cie_convXYZ2LAB(XYZa2);
						#local coob2 = cie_convXYZ2LAB(XYZb2);
						// convert XYZ to LAB step 2: normalize and swap x and y
						// make sure the denominators here match the axes labels
						#local cooa1 = <cooa1.y/400,cooa1.x/100,cooa1.z/400>;
						#local coob1 = <coob1.y/400,coob1.x/100,coob1.z/400>;
						#local cooa2 = <cooa2.y/400,cooa2.x/100,cooa2.z/400>;
						#local coob2 = <coob2.y/400,coob2.x/100,coob2.z/400>;
					#break
					// CIELCHab (cylinder)
					#case (3)		
						// convert XYZ to LAB to LCHab step 1: get un-normalized values
						#local cooa1 = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZa1));
						#local coob1 = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZb1));
						#local cooa2 = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZa2));
						#local coob2 = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZb2));
						// convert XYZ to LAB to LCHab step 2: normalize and convert to cartesian coordinates
						// make sure the denominators here match the axes labels
						#local cooa1 = <cooa1.y/400*cosd(cooa1.z),cooa1.x/100,cooa1.y/400*sind(cooa1.z)>;
						#local coob1 = <coob1.y/400*cosd(coob1.z),coob1.x/100,coob1.y/400*sind(coob1.z)>;
						#local cooa2 = <cooa2.y/400*cosd(cooa2.z),cooa2.x/100,cooa2.y/400*sind(cooa2.z)>;
						#local coob2 = <coob2.y/400*cosd(coob2.z),coob2.x/100,coob2.y/400*sind(coob2.z)>;

					#break
					// CIELUV (cube)
					#case (5)		
						// convert XYZ to LUV step 1: get un-normalized values
						#local cooa1 = cie_convXYZ2LUV(XYZa1);
						#local coob1 = cie_convXYZ2LUV(XYZb1);
						#local cooa2 = cie_convXYZ2LUV(XYZa2);
						#local coob2 = cie_convXYZ2LUV(XYZb2);
						// convert XYZ to LUV step 2: normalize and swap x and y
						// make sure the denominators here match the axes labels
						#local cooa1 = <cooa1.y/400,cooa1.x/100,cooa1.z/400>;
						#local coob1 = <coob1.y/400,coob1.x/100,coob1.z/400>;
						#local cooa2 = <cooa2.y/400,cooa2.x/100,cooa2.z/400>;
						#local coob2 = <coob2.y/400,coob2.x/100,coob2.z/400>;
					#break
					// CIELCHuv (cylinder)
					#case (6)		
						// convert XYZ to LUV to LCHuv step 1: get un-normalized values
						#local cooa1 = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZa1));
						#local coob1 = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZb1));
						#local cooa2 = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZa2));
						#local coob2 = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZb2));
						// convert XYZ to LUV to LCHuv step 2: normalize and convert to cartesian coordinates
						// make sure the denominators here match the axes labels
						#local cooa1 = <cooa1.y/400*cosd(cooa1.z),cooa1.x/100,cooa1.y/400*sind(cooa1.z)>;
						#local coob1 = <coob1.y/400*cosd(coob1.z),coob1.x/100,coob1.y/400*sind(coob1.z)>;
						#local cooa2 = <cooa2.y/400*cosd(cooa2.z),cooa2.x/100,cooa2.y/400*sind(cooa2.z)>;
						#local coob2 = <coob2.y/400*cosd(coob2.z),coob2.x/100,coob2.y/400*sind(coob2.z)>;
					#break
					#else
						#error "Have only done xyY color space so far."
				#end
				// create textures
				#local coltri1 = (cola2 + cola1 + colb1)/3;
				#local coltri2 = (colb1 + colb2 + cola2)/3;
				// if no problems encountered...
				#if (pass_me = true)
					// write stuff to log
					#write (cie_write_handle, "\t#local temp_texture = texture {pigment {color srgb ", coltri1, "} finish {cie_isoFinish}}\n")
					#write (cie_write_handle, "\ttriangle {", cooa2, ",", cooa1, ",", coob1, " texture {temp_texture}}\n")
					#write (cie_write_handle, "\t#local temp_texture = texture {pigment {color srgb ", coltri2, "} finish {cie_isoFinish}}\n")
					#write (cie_write_handle, "\ttriangle {", coob1, ",", coob2, ",", cooa2, " texture {temp_texture}}\n")
				#end
			#end
		#end
	#end
	#write (cie_write_handle, "}\n")
	#fclose cie_write_handle
#end

// smooth triangle mesh (might be a bad idea since there are usually some very sharp corners)
#macro cie_write_smoothmesh_srgb(color_space, cie_filename)
	#fopen cie_write_handle cie_filename write
	#write (cie_write_handle, "mesh\n{\n")
	// once per each "face" of the figure
	#for (k, 0, 5)
		// skip the first row since you can't build a mesh from it all by itself
		#for (i, 1, cie_sample_count_srgb)
			// skip the first column since you can't build a mesh from it all by itself
			#for (j, 1, cie_sample_count_srgb)
				// get XYZ values
				#local XYZA = cie_point_array_srgb[k][cie_clip_index_other(i+1)][cie_clip_index_other(j-2)];
				#local XYZB = cie_point_array_srgb[k][cie_clip_index_other(i+1)][cie_clip_index_other(j-1)];
				#local XYZC = cie_point_array_srgb[k][cie_clip_index_other(i+1)][cie_clip_index_other(j+0)];
				#local XYZD = cie_point_array_srgb[k][cie_clip_index_other(i+1)][cie_clip_index_other(j+1)];
				#local XYZE = cie_point_array_srgb[k][cie_clip_index_other(i+0)][cie_clip_index_other(j-2)];
				#local XYZF = cie_point_array_srgb[k][cie_clip_index_other(i+0)][cie_clip_index_other(j-1)];
				#local XYZG = cie_point_array_srgb[k][cie_clip_index_other(i+0)][cie_clip_index_other(j+0)];
				#local XYZH = cie_point_array_srgb[k][cie_clip_index_other(i+0)][cie_clip_index_other(j+1)];
				#local XYZI = cie_point_array_srgb[k][cie_clip_index_other(i-1)][cie_clip_index_other(j-2)];
				#local XYZJ = cie_point_array_srgb[k][cie_clip_index_other(i-1)][cie_clip_index_other(j-1)];
				#local XYZK = cie_point_array_srgb[k][cie_clip_index_other(i-1)][cie_clip_index_other(j+0)];
				#local XYZL = cie_point_array_srgb[k][cie_clip_index_other(i-1)][cie_clip_index_other(j+1)];
				#local XYZM = cie_point_array_srgb[k][cie_clip_index_other(i-2)][cie_clip_index_other(j-2)];
				#local XYZN = cie_point_array_srgb[k][cie_clip_index_other(i-2)][cie_clip_index_other(j-1)];
				#local XYZO = cie_point_array_srgb[k][cie_clip_index_other(i-2)][cie_clip_index_other(j+0)];
				#local XYZP = cie_point_array_srgb[k][cie_clip_index_other(i-2)][cie_clip_index_other(j+1)];
				// get colors
				#local colA = cie_convXYZ2RGB(XYZA);
				#local colB = cie_convXYZ2RGB(XYZB);
				#local colC = cie_convXYZ2RGB(XYZC);
				#local colD = cie_convXYZ2RGB(XYZD);
				#local colE = cie_convXYZ2RGB(XYZE);
				#local colF = cie_convXYZ2RGB(XYZF);
				#local colG = cie_convXYZ2RGB(XYZG);
				#local colH = cie_convXYZ2RGB(XYZH);
				#local colI = cie_convXYZ2RGB(XYZI);
				#local colJ = cie_convXYZ2RGB(XYZJ);
				#local colK = cie_convXYZ2RGB(XYZK);
				#local colL = cie_convXYZ2RGB(XYZL);
				#local colM = cie_convXYZ2RGB(XYZM);
				#local colN = cie_convXYZ2RGB(XYZN);
				#local colO = cie_convXYZ2RGB(XYZO);
				#local colP = cie_convXYZ2RGB(XYZP);
				// convert XYZ to other color spaces and store coordinates
				#switch (color_space)
					// CIExyY (cube)
					#case (0)
						// convert XYZ to xyY
						#local cooA = cie_convXYZ2XYY(XYZA);
						#local cooB = cie_convXYZ2XYY(XYZB);
						#local cooC = cie_convXYZ2XYY(XYZC);
						#local cooD = cie_convXYZ2XYY(XYZD);
						#local cooE = cie_convXYZ2XYY(XYZE);
						#local cooF = cie_convXYZ2XYY(XYZF);
						#local cooG = cie_convXYZ2XYY(XYZG);
						#local cooH = cie_convXYZ2XYY(XYZH);
						#local cooI = cie_convXYZ2XYY(XYZI);
						#local cooJ = cie_convXYZ2XYY(XYZJ);
						#local cooK = cie_convXYZ2XYY(XYZK);
						#local cooL = cie_convXYZ2XYY(XYZL);
						#local cooM = cie_convXYZ2XYY(XYZM);
						#local cooN = cie_convXYZ2XYY(XYZN);
						#local cooO = cie_convXYZ2XYY(XYZO);
						#local cooP = cie_convXYZ2XYY(XYZP);
						// switch y and z and normalize Y
						// make sure the denominators here match the axes labels
						#local cooA = <cooA.x,cooA.z/100,cooA.y>;
						#local cooB = <cooB.x,cooB.z/100,cooB.y>;
						#local cooC = <cooC.x,cooC.z/100,cooC.y>;
						#local cooD = <cooD.x,cooD.z/100,cooD.y>;
						#local cooE = <cooE.x,cooE.z/100,cooE.y>;
						#local cooF = <cooF.x,cooF.z/100,cooF.y>;
						#local cooG = <cooG.x,cooG.z/100,cooG.y>;
						#local cooH = <cooH.x,cooH.z/100,cooH.y>;
						#local cooI = <cooI.x,cooI.z/100,cooI.y>;
						#local cooJ = <cooJ.x,cooJ.z/100,cooJ.y>;
						#local cooK = <cooK.x,cooK.z/100,cooK.y>;
						#local cooL = <cooL.x,cooL.z/100,cooL.y>;
						#local cooM = <cooM.x,cooM.z/100,cooM.y>;
						#local cooN = <cooN.x,cooN.z/100,cooN.y>;
						#local cooO = <cooO.x,cooO.z/100,cooO.y>;
						#local cooP = <cooP.x,cooP.z/100,cooP.y>;
					#break
					// CIEXYZ (cube)
					#case (1)
						// don't do anything but normalize
						// make sure the denominators here match the axes labels
						#local cooA = XYZA/100;
						#local cooB = XYZB/100;
						#local cooC = XYZC/100;
						#local cooD = XYZD/100;
						#local cooE = XYZE/100;
						#local cooF = XYZF/100;
						#local cooG = XYZG/100;
						#local cooH = XYZH/100;
						#local cooI = XYZI/100;
						#local cooJ = XYZJ/100;
						#local cooK = XYZK/100;
						#local cooL = XYZL/100;
						#local cooM = XYZM/100;
						#local cooN = XYZN/100;
						#local cooO = XYZO/100;
						#local cooP = XYZP/100;
					#break
					// CIELAB (cube)
					#case (2)
						// convert XYZ to LAB step 1: get un-normalized values
						#local cooA = cie_convXYZ2LAB(XYZA);
						#local cooB = cie_convXYZ2LAB(XYZB);
						#local cooC = cie_convXYZ2LAB(XYZC);
						#local cooD = cie_convXYZ2LAB(XYZD);
						#local cooE = cie_convXYZ2LAB(XYZE);
						#local cooF = cie_convXYZ2LAB(XYZF);
						#local cooG = cie_convXYZ2LAB(XYZG);
						#local cooH = cie_convXYZ2LAB(XYZH);
						#local cooI = cie_convXYZ2LAB(XYZI);
						#local cooJ = cie_convXYZ2LAB(XYZJ);
						#local cooK = cie_convXYZ2LAB(XYZK);
						#local cooL = cie_convXYZ2LAB(XYZL);
						#local cooM = cie_convXYZ2LAB(XYZM);
						#local cooN = cie_convXYZ2LAB(XYZN);
						#local cooO = cie_convXYZ2LAB(XYZO);
						#local cooP = cie_convXYZ2LAB(XYZP);
						// convert XYZ to LAB step 2: normalize and swap x and y
						// make sure the denominators here match the axes labels
						#local cooA = <cooA.y/400,cooA.x/100,cooA.z/400>;
						#local cooB = <cooB.y/400,cooB.x/100,cooB.z/400>;
						#local cooC = <cooC.y/400,cooC.x/100,cooC.z/400>;
						#local cooD = <cooD.y/400,cooD.x/100,cooD.z/400>;
						#local cooE = <cooE.y/400,cooE.x/100,cooE.z/400>;
						#local cooF = <cooF.y/400,cooF.x/100,cooF.z/400>;
						#local cooG = <cooG.y/400,cooG.x/100,cooG.z/400>;
						#local cooH = <cooH.y/400,cooH.x/100,cooH.z/400>;
						#local cooI = <cooI.y/400,cooI.x/100,cooI.z/400>;
						#local cooJ = <cooJ.y/400,cooJ.x/100,cooJ.z/400>;
						#local cooK = <cooK.y/400,cooK.x/100,cooK.z/400>;
						#local cooL = <cooL.y/400,cooL.x/100,cooL.z/400>;
						#local cooM = <cooM.y/400,cooM.x/100,cooM.z/400>;
						#local cooN = <cooN.y/400,cooN.x/100,cooN.z/400>;
						#local cooO = <cooO.y/400,cooO.x/100,cooO.z/400>;
						#local cooP = <cooP.y/400,cooP.x/100,cooP.z/400>;
					#break
					// CIELCHab (cylinder)
					#case (3)		
						// convert XYZ to LAB to LCHab step 1: get un-normalized values
						#local cooA = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZA));
						#local cooB = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZB));
						#local cooC = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZC));
						#local cooD = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZD));
						#local cooE = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZE));
						#local cooF = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZF));
						#local cooG = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZG));
						#local cooH = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZH));
						#local cooI = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZI));
						#local cooJ = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZJ));
						#local cooK = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZK));
						#local cooL = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZL));
						#local cooM = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZM));
						#local cooN = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZN));
						#local cooO = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZO));
						#local cooP = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZP));
						// convert XYZ to LAB to LCHab step 2: normalize and convert to cartesian coordinates
						// make sure the denominators here match the axes labels
						#local cooA = <cooA.y/400*cosd(cooA.z),cooA.x/100,cooA.y/400*sind(cooA.z)>;
						#local cooB = <cooB.y/400*cosd(cooB.z),cooB.x/100,cooB.y/400*sind(cooB.z)>;
						#local cooC = <cooC.y/400*cosd(cooC.z),cooC.x/100,cooC.y/400*sind(cooC.z)>;
						#local cooD = <cooD.y/400*cosd(cooD.z),cooD.x/100,cooD.y/400*sind(cooD.z)>;
						#local cooE = <cooE.y/400*cosd(cooE.z),cooE.x/100,cooE.y/400*sind(cooE.z)>;
						#local cooF = <cooF.y/400*cosd(cooF.z),cooF.x/100,cooF.y/400*sind(cooF.z)>;
						#local cooG = <cooG.y/400*cosd(cooG.z),cooG.x/100,cooG.y/400*sind(cooG.z)>;
						#local cooH = <cooH.y/400*cosd(cooH.z),cooH.x/100,cooH.y/400*sind(cooH.z)>;
						#local cooI = <cooI.y/400*cosd(cooI.z),cooI.x/100,cooI.y/400*sind(cooI.z)>;
						#local cooJ = <cooJ.y/400*cosd(cooJ.z),cooJ.x/100,cooJ.y/400*sind(cooJ.z)>;
						#local cooK = <cooK.y/400*cosd(cooK.z),cooK.x/100,cooK.y/400*sind(cooK.z)>;
						#local cooL = <cooL.y/400*cosd(cooL.z),cooL.x/100,cooL.y/400*sind(cooL.z)>;
						#local cooM = <cooM.y/400*cosd(cooM.z),cooM.x/100,cooM.y/400*sind(cooM.z)>;
						#local cooN = <cooN.y/400*cosd(cooN.z),cooN.x/100,cooN.y/400*sind(cooN.z)>;
						#local cooO = <cooO.y/400*cosd(cooO.z),cooO.x/100,cooO.y/400*sind(cooO.z)>;
						#local cooP = <cooP.y/400*cosd(cooP.z),cooP.x/100,cooP.y/400*sind(cooP.z)>;
					#break
					// CIELCHab (sphere)
					#case (4)		
						// convert XYZ to LAB to LCHab step 1: get un-normalized values
						#local cooA = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZA));
						#local cooB = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZB));
						#local cooC = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZC));
						#local cooD = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZD));
						#local cooE = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZE));
						#local cooF = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZF));
						#local cooG = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZG));
						#local cooH = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZH));
						#local cooI = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZI));
						#local cooJ = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZJ));
						#local cooK = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZK));
						#local cooL = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZL));
						#local cooM = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZM));
						#local cooN = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZN));
						#local cooO = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZO));
						#local cooP = cie_convLAB2LCHab(cie_convXYZ2LAB(XYZP));
						// convert XYZ to LAB to LCHab step 2: normalize and convert to cartesian coordinates
						// make sure the denominators here match the axes labels
						#local cooA = <(cooA.y/400*7/8+1/8)*cosd(cooA.z)*sind(180-cooA.x/100*180),(cooA.y/400*7/8+1/8)*cosd(180-cooA.x/100*180),(cooA.y/400*7/8+1/8)*sind(cooA.z)*sind(180-cooA.x/100*180)>;
						#local cooB = <(cooB.y/400*7/8+1/8)*cosd(cooB.z)*sind(180-cooB.x/100*180),(cooB.y/400*7/8+1/8)*cosd(180-cooB.x/100*180),(cooB.y/400*7/8+1/8)*sind(cooB.z)*sind(180-cooB.x/100*180)>;
						#local cooC = <(cooC.y/400*7/8+1/8)*cosd(cooC.z)*sind(180-cooC.x/100*180),(cooC.y/400*7/8+1/8)*cosd(180-cooC.x/100*180),(cooC.y/400*7/8+1/8)*sind(cooC.z)*sind(180-cooC.x/100*180)>;
						#local cooD = <(cooD.y/400*7/8+1/8)*cosd(cooD.z)*sind(180-cooD.x/100*180),(cooD.y/400*7/8+1/8)*cosd(180-cooD.x/100*180),(cooD.y/400*7/8+1/8)*sind(cooD.z)*sind(180-cooD.x/100*180)>;
						#local cooE = <(cooE.y/400*7/8+1/8)*cosd(cooE.z)*sind(180-cooE.x/100*180),(cooE.y/400*7/8+1/8)*cosd(180-cooE.x/100*180),(cooE.y/400*7/8+1/8)*sind(cooE.z)*sind(180-cooE.x/100*180)>;
						#local cooF = <(cooF.y/400*7/8+1/8)*cosd(cooF.z)*sind(180-cooF.x/100*180),(cooF.y/400*7/8+1/8)*cosd(180-cooF.x/100*180),(cooF.y/400*7/8+1/8)*sind(cooF.z)*sind(180-cooF.x/100*180)>;
						#local cooG = <(cooG.y/400*7/8+1/8)*cosd(cooG.z)*sind(180-cooG.x/100*180),(cooG.y/400*7/8+1/8)*cosd(180-cooG.x/100*180),(cooG.y/400*7/8+1/8)*sind(cooG.z)*sind(180-cooG.x/100*180)>;
						#local cooH = <(cooH.y/400*7/8+1/8)*cosd(cooH.z)*sind(180-cooH.x/100*180),(cooH.y/400*7/8+1/8)*cosd(180-cooH.x/100*180),(cooH.y/400*7/8+1/8)*sind(cooH.z)*sind(180-cooH.x/100*180)>;
						#local cooI = <(cooI.y/400*7/8+1/8)*cosd(cooI.z)*sind(180-cooI.x/100*180),(cooI.y/400*7/8+1/8)*cosd(180-cooI.x/100*180),(cooI.y/400*7/8+1/8)*sind(cooI.z)*sind(180-cooI.x/100*180)>;
						#local cooJ = <(cooJ.y/400*7/8+1/8)*cosd(cooJ.z)*sind(180-cooJ.x/100*180),(cooJ.y/400*7/8+1/8)*cosd(180-cooJ.x/100*180),(cooJ.y/400*7/8+1/8)*sind(cooJ.z)*sind(180-cooJ.x/100*180)>;
						#local cooK = <(cooK.y/400*7/8+1/8)*cosd(cooK.z)*sind(180-cooK.x/100*180),(cooK.y/400*7/8+1/8)*cosd(180-cooK.x/100*180),(cooK.y/400*7/8+1/8)*sind(cooK.z)*sind(180-cooK.x/100*180)>;
						#local cooL = <(cooL.y/400*7/8+1/8)*cosd(cooL.z)*sind(180-cooL.x/100*180),(cooL.y/400*7/8+1/8)*cosd(180-cooL.x/100*180),(cooL.y/400*7/8+1/8)*sind(cooL.z)*sind(180-cooL.x/100*180)>;
						#local cooM = <(cooM.y/400*7/8+1/8)*cosd(cooM.z)*sind(180-cooM.x/100*180),(cooM.y/400*7/8+1/8)*cosd(180-cooM.x/100*180),(cooM.y/400*7/8+1/8)*sind(cooM.z)*sind(180-cooM.x/100*180)>;
						#local cooN = <(cooN.y/400*7/8+1/8)*cosd(cooN.z)*sind(180-cooN.x/100*180),(cooN.y/400*7/8+1/8)*cosd(180-cooN.x/100*180),(cooN.y/400*7/8+1/8)*sind(cooN.z)*sind(180-cooN.x/100*180)>;
						#local cooO = <(cooO.y/400*7/8+1/8)*cosd(cooO.z)*sind(180-cooO.x/100*180),(cooO.y/400*7/8+1/8)*cosd(180-cooO.x/100*180),(cooO.y/400*7/8+1/8)*sind(cooO.z)*sind(180-cooO.x/100*180)>;
						#local cooP = <(cooP.y/400*7/8+1/8)*cosd(cooP.z)*sind(180-cooP.x/100*180),(cooP.y/400*7/8+1/8)*cosd(180-cooP.x/100*180),(cooP.y/400*7/8+1/8)*sind(cooP.z)*sind(180-cooP.x/100*180)>;
					#break
					// CIELUV (cube)
					#case (5)		
						// convert XYZ to LUV step 1: get un-normalized values
						#local cooA = cie_convXYZ2LUV(XYZA);
						#local cooB = cie_convXYZ2LUV(XYZB);
						#local cooC = cie_convXYZ2LUV(XYZC);
						#local cooD = cie_convXYZ2LUV(XYZD);
						#local cooE = cie_convXYZ2LUV(XYZE);
						#local cooF = cie_convXYZ2LUV(XYZF);
						#local cooG = cie_convXYZ2LUV(XYZG);
						#local cooH = cie_convXYZ2LUV(XYZH);
						#local cooI = cie_convXYZ2LUV(XYZI);
						#local cooJ = cie_convXYZ2LUV(XYZJ);
						#local cooK = cie_convXYZ2LUV(XYZK);
						#local cooL = cie_convXYZ2LUV(XYZL);
						#local cooM = cie_convXYZ2LUV(XYZM);
						#local cooN = cie_convXYZ2LUV(XYZN);
						#local cooO = cie_convXYZ2LUV(XYZO);
						#local cooP = cie_convXYZ2LUV(XYZP);
						// convert XYZ to LUV step 2: normalize and swap x and y
						// make sure the denominators here match the axes labels
						#local cooA = <cooA.y/400,cooA.x/100,cooA.z/400>;
						#local cooB = <cooB.y/400,cooB.x/100,cooB.z/400>;
						#local cooC = <cooC.y/400,cooC.x/100,cooC.z/400>;
						#local cooD = <cooD.y/400,cooD.x/100,cooD.z/400>;
						#local cooE = <cooE.y/400,cooE.x/100,cooE.z/400>;
						#local cooF = <cooF.y/400,cooF.x/100,cooF.z/400>;
						#local cooG = <cooG.y/400,cooG.x/100,cooG.z/400>;
						#local cooH = <cooH.y/400,cooH.x/100,cooH.z/400>;
						#local cooI = <cooI.y/400,cooI.x/100,cooI.z/400>;
						#local cooJ = <cooJ.y/400,cooJ.x/100,cooJ.z/400>;
						#local cooK = <cooK.y/400,cooK.x/100,cooK.z/400>;
						#local cooL = <cooL.y/400,cooL.x/100,cooL.z/400>;
						#local cooM = <cooM.y/400,cooM.x/100,cooM.z/400>;
						#local cooN = <cooN.y/400,cooN.x/100,cooN.z/400>;
						#local cooO = <cooO.y/400,cooO.x/100,cooO.z/400>;
						#local cooP = <cooP.y/400,cooP.x/100,cooP.z/400>;
					#break
					// CIELCHuv (cylinder)
					#case (6)		
						// convert XYZ to LUV to LCHuv step 1: get un-normalized values
						#local cooA = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZA));
						#local cooB = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZB));
						#local cooC = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZC));
						#local cooD = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZD));
						#local cooE = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZE));
						#local cooF = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZF));
						#local cooG = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZG));
						#local cooH = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZH));
						#local cooI = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZI));
						#local cooJ = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZJ));
						#local cooK = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZK));
						#local cooL = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZL));
						#local cooM = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZM));
						#local cooN = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZN));
						#local cooO = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZO));
						#local cooP = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZP));
						// convert XYZ to LUV to LCHuv step 2: normalize and convert to cartesian coordinates
						// make sure the denominators here match the axes labels
						#local cooA = <cooA.y/400*cosd(cooA.z),cooA.x/100,cooA.y/400*sind(cooA.z)>;
						#local cooB = <cooB.y/400*cosd(cooB.z),cooB.x/100,cooB.y/400*sind(cooB.z)>;
						#local cooC = <cooC.y/400*cosd(cooC.z),cooC.x/100,cooC.y/400*sind(cooC.z)>;
						#local cooD = <cooD.y/400*cosd(cooD.z),cooD.x/100,cooD.y/400*sind(cooD.z)>;
						#local cooE = <cooE.y/400*cosd(cooE.z),cooE.x/100,cooE.y/400*sind(cooE.z)>;
						#local cooF = <cooF.y/400*cosd(cooF.z),cooF.x/100,cooF.y/400*sind(cooF.z)>;
						#local cooG = <cooG.y/400*cosd(cooG.z),cooG.x/100,cooG.y/400*sind(cooG.z)>;
						#local cooH = <cooH.y/400*cosd(cooH.z),cooH.x/100,cooH.y/400*sind(cooH.z)>;
						#local cooI = <cooI.y/400*cosd(cooI.z),cooI.x/100,cooI.y/400*sind(cooI.z)>;
						#local cooJ = <cooJ.y/400*cosd(cooJ.z),cooJ.x/100,cooJ.y/400*sind(cooJ.z)>;
						#local cooK = <cooK.y/400*cosd(cooK.z),cooK.x/100,cooK.y/400*sind(cooK.z)>;
						#local cooL = <cooL.y/400*cosd(cooL.z),cooL.x/100,cooL.y/400*sind(cooL.z)>;
						#local cooM = <cooM.y/400*cosd(cooM.z),cooM.x/100,cooM.y/400*sind(cooM.z)>;
						#local cooN = <cooN.y/400*cosd(cooN.z),cooN.x/100,cooN.y/400*sind(cooN.z)>;
						#local cooO = <cooO.y/400*cosd(cooO.z),cooO.x/100,cooO.y/400*sind(cooO.z)>;
						#local cooP = <cooP.y/400*cosd(cooP.z),cooP.x/100,cooP.y/400*sind(cooP.z)>;
					#break
					// CIELCHuv (sphere)
					#case (7)		
						// convert XYZ to LUV to LCHuv step 1: get un-normalized values
						#local cooA = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZA));
						#local cooB = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZB));
						#local cooC = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZC));
						#local cooD = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZD));
						#local cooE = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZE));
						#local cooF = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZF));
						#local cooG = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZG));
						#local cooH = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZH));
						#local cooI = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZI));
						#local cooJ = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZJ));
						#local cooK = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZK));
						#local cooL = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZL));
						#local cooM = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZM));
						#local cooN = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZN));
						#local cooO = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZO));
						#local cooP = cie_convLUV2LCHuv(cie_convXYZ2LUV(XYZP));
						// convert XYZ to LUV to LCHuv step 2: normalize and convert to cartesian coordinates
						// make sure the denominators here match the axes labels
						#local cooA = <(cooA.y/400*7/8+1/8)*cosd(cooA.z)*sind(180-cooA.x/100*180),(cooA.y/400*7/8+1/8)*cosd(180-cooA.x/100*180),(cooA.y/400*7/8+1/8)*sind(cooA.z)*sind(180-cooA.x/100*180)>;
						#local cooB = <(cooB.y/400*7/8+1/8)*cosd(cooB.z)*sind(180-cooB.x/100*180),(cooB.y/400*7/8+1/8)*cosd(180-cooB.x/100*180),(cooB.y/400*7/8+1/8)*sind(cooB.z)*sind(180-cooB.x/100*180)>;
						#local cooC = <(cooC.y/400*7/8+1/8)*cosd(cooC.z)*sind(180-cooC.x/100*180),(cooC.y/400*7/8+1/8)*cosd(180-cooC.x/100*180),(cooC.y/400*7/8+1/8)*sind(cooC.z)*sind(180-cooC.x/100*180)>;
						#local cooD = <(cooD.y/400*7/8+1/8)*cosd(cooD.z)*sind(180-cooD.x/100*180),(cooD.y/400*7/8+1/8)*cosd(180-cooD.x/100*180),(cooD.y/400*7/8+1/8)*sind(cooD.z)*sind(180-cooD.x/100*180)>;
						#local cooE = <(cooE.y/400*7/8+1/8)*cosd(cooE.z)*sind(180-cooE.x/100*180),(cooE.y/400*7/8+1/8)*cosd(180-cooE.x/100*180),(cooE.y/400*7/8+1/8)*sind(cooE.z)*sind(180-cooE.x/100*180)>;
						#local cooF = <(cooF.y/400*7/8+1/8)*cosd(cooF.z)*sind(180-cooF.x/100*180),(cooF.y/400*7/8+1/8)*cosd(180-cooF.x/100*180),(cooF.y/400*7/8+1/8)*sind(cooF.z)*sind(180-cooF.x/100*180)>;
						#local cooG = <(cooG.y/400*7/8+1/8)*cosd(cooG.z)*sind(180-cooG.x/100*180),(cooG.y/400*7/8+1/8)*cosd(180-cooG.x/100*180),(cooG.y/400*7/8+1/8)*sind(cooG.z)*sind(180-cooG.x/100*180)>;
						#local cooH = <(cooH.y/400*7/8+1/8)*cosd(cooH.z)*sind(180-cooH.x/100*180),(cooH.y/400*7/8+1/8)*cosd(180-cooH.x/100*180),(cooH.y/400*7/8+1/8)*sind(cooH.z)*sind(180-cooH.x/100*180)>;
						#local cooI = <(cooI.y/400*7/8+1/8)*cosd(cooI.z)*sind(180-cooI.x/100*180),(cooI.y/400*7/8+1/8)*cosd(180-cooI.x/100*180),(cooI.y/400*7/8+1/8)*sind(cooI.z)*sind(180-cooI.x/100*180)>;
						#local cooJ = <(cooJ.y/400*7/8+1/8)*cosd(cooJ.z)*sind(180-cooJ.x/100*180),(cooJ.y/400*7/8+1/8)*cosd(180-cooJ.x/100*180),(cooJ.y/400*7/8+1/8)*sind(cooJ.z)*sind(180-cooJ.x/100*180)>;
						#local cooK = <(cooK.y/400*7/8+1/8)*cosd(cooK.z)*sind(180-cooK.x/100*180),(cooK.y/400*7/8+1/8)*cosd(180-cooK.x/100*180),(cooK.y/400*7/8+1/8)*sind(cooK.z)*sind(180-cooK.x/100*180)>;
						#local cooL = <(cooL.y/400*7/8+1/8)*cosd(cooL.z)*sind(180-cooL.x/100*180),(cooL.y/400*7/8+1/8)*cosd(180-cooL.x/100*180),(cooL.y/400*7/8+1/8)*sind(cooL.z)*sind(180-cooL.x/100*180)>;
						#local cooM = <(cooM.y/400*7/8+1/8)*cosd(cooM.z)*sind(180-cooM.x/100*180),(cooM.y/400*7/8+1/8)*cosd(180-cooM.x/100*180),(cooM.y/400*7/8+1/8)*sind(cooM.z)*sind(180-cooM.x/100*180)>;
						#local cooN = <(cooN.y/400*7/8+1/8)*cosd(cooN.z)*sind(180-cooN.x/100*180),(cooN.y/400*7/8+1/8)*cosd(180-cooN.x/100*180),(cooN.y/400*7/8+1/8)*sind(cooN.z)*sind(180-cooN.x/100*180)>;
						#local cooO = <(cooO.y/400*7/8+1/8)*cosd(cooO.z)*sind(180-cooO.x/100*180),(cooO.y/400*7/8+1/8)*cosd(180-cooO.x/100*180),(cooO.y/400*7/8+1/8)*sind(cooO.z)*sind(180-cooO.x/100*180)>;
						#local cooP = <(cooP.y/400*7/8+1/8)*cosd(cooP.z)*sind(180-cooP.x/100*180),(cooP.y/400*7/8+1/8)*cosd(180-cooP.x/100*180),(cooP.y/400*7/8+1/8)*sind(cooP.z)*sind(180-cooP.x/100*180)>;
					#break
					#else
						#error "Have not implemented this color space yet."
				#end
				// construct triangles (first and last are not used)
				#local triEAB = array[3] {cooE,cooA,cooB}	// not used
				#local triFBC = array[3] {cooF,cooB,cooC}
				#local triGCD = array[3] {cooF,cooB,cooC}
				#local triIEF = array[3] {cooF,cooB,cooC}
				#local triJFG = array[3] {cooF,cooB,cooC}
				#local triKGH = array[3] {cooF,cooB,cooC}
				#local triMIJ = array[3] {cooF,cooB,cooC}
				#local triNJK = array[3] {cooF,cooB,cooC}
				#local triOKL = array[3] {cooF,cooB,cooC}
				#local triBFE = array[3] {cooF,cooB,cooC}
				#local triCGF = array[3] {cooF,cooB,cooC}
				#local triDHG = array[3] {cooF,cooB,cooC}
				#local triFJI = array[3] {cooF,cooB,cooC}
				#local triGKJ = array[3] {cooF,cooB,cooC}
				#local triHLK = array[3] {cooF,cooB,cooC}
				#local triJNM = array[3] {cooF,cooB,cooC}
				#local triKON = array[3] {cooF,cooB,cooC}
				#local triLPO = array[3] {cooF,cooB,cooC}	// not used
				// calculate tangent vectors (first and last are not used)
				#local vecEAB = array[2] {triEAB[1]-triEAB[0],triEAB[2]-triEAB[0]}	// not used
				#local vecFBC = array[2] {triFBC[1]-triFBC[0],triFBC[2]-triFBC[0]}
				#local vecGCD = array[2] {triGCD[1]-triGCD[0],triGCD[2]-triGCD[0]}
				#local vecIEF = array[2] {triIEF[1]-triIEF[0],triIEF[2]-triIEF[0]}
				#local vecJFG = array[2] {triJFG[1]-triJFG[0],triJFG[2]-triJFG[0]}
				#local vecKGH = array[2] {triKGH[1]-triKGH[0],triKGH[2]-triKGH[0]}
				#local vecMIJ = array[2] {triMIJ[1]-triMIJ[0],triMIJ[2]-triMIJ[0]}
				#local vecNJK = array[2] {triNJK[1]-triNJK[0],triNJK[2]-triNJK[0]}
				#local vecOKL = array[2] {triOKL[1]-triOKL[0],triOKL[2]-triOKL[0]}
				#local vecBFE = array[2] {triBFE[1]-triBFE[0],triBFE[2]-triBFE[0]}
				#local vecCGF = array[2] {triCGF[1]-triCGF[0],triCGF[2]-triCGF[0]}
				#local vecDHG = array[2] {triDHG[1]-triDHG[0],triDHG[2]-triDHG[0]}
				#local vecFJI = array[2] {triFJI[1]-triFJI[0],triFJI[2]-triFJI[0]}
				#local vecGKJ = array[2] {triGKJ[1]-triGKJ[0],triGKJ[2]-triGKJ[0]}
				#local vecHLK = array[2] {triHLK[1]-triHLK[0],triHLK[2]-triHLK[0]}
				#local vecJNM = array[2] {triJNM[1]-triJNM[0],triJNM[2]-triJNM[0]}
				#local vecKON = array[2] {triKON[1]-triKON[0],triKON[2]-triKON[0]}
				#local vecLPO = array[2] {triLPO[1]-triLPO[0],triLPO[2]-triLPO[0]}	// not used
				// calculate normal vectors (first and last are not used)
				#local norEAB = <vecEAB[0].y*vecEAB[1].z-vecEAB[0].z*vecEAB[1].y,vecEAB[0].z*vecEAB[1].x-vecEAB[0].x*vecEAB[1].z,vecEAB[0].x*vecEAB[1].y-vecEAB[0].y*vecEAB[1].x>;	// not used
				#local norFBC = <vecFBC[0].y*vecFBC[1].z-vecFBC[0].z*vecFBC[1].y,vecFBC[0].z*vecFBC[1].x-vecFBC[0].x*vecFBC[1].z,vecFBC[0].x*vecFBC[1].y-vecFBC[0].y*vecFBC[1].x>;
				#local norGCD = <vecGCD[0].y*vecGCD[1].z-vecGCD[0].z*vecGCD[1].y,vecGCD[0].z*vecGCD[1].x-vecGCD[0].x*vecGCD[1].z,vecGCD[0].x*vecGCD[1].y-vecGCD[0].y*vecGCD[1].x>;
				#local norIEF = <vecIEF[0].y*vecIEF[1].z-vecIEF[0].z*vecIEF[1].y,vecIEF[0].z*vecIEF[1].x-vecIEF[0].x*vecIEF[1].z,vecIEF[0].x*vecIEF[1].y-vecIEF[0].y*vecIEF[1].x>;
				#local norJFG = <vecJFG[0].y*vecJFG[1].z-vecJFG[0].z*vecJFG[1].y,vecJFG[0].z*vecJFG[1].x-vecJFG[0].x*vecJFG[1].z,vecJFG[0].x*vecJFG[1].y-vecJFG[0].y*vecJFG[1].x>;
				#local norKGH = <vecKGH[0].y*vecKGH[1].z-vecKGH[0].z*vecKGH[1].y,vecKGH[0].z*vecKGH[1].x-vecKGH[0].x*vecKGH[1].z,vecKGH[0].x*vecKGH[1].y-vecKGH[0].y*vecKGH[1].x>;
				#local norMIJ = <vecMIJ[0].y*vecMIJ[1].z-vecMIJ[0].z*vecMIJ[1].y,vecMIJ[0].z*vecMIJ[1].x-vecMIJ[0].x*vecMIJ[1].z,vecMIJ[0].x*vecMIJ[1].y-vecMIJ[0].y*vecMIJ[1].x>;
				#local norNJK = <vecNJK[0].y*vecNJK[1].z-vecNJK[0].z*vecNJK[1].y,vecNJK[0].z*vecNJK[1].x-vecNJK[0].x*vecNJK[1].z,vecNJK[0].x*vecNJK[1].y-vecNJK[0].y*vecNJK[1].x>;
				#local norOKL = <vecOKL[0].y*vecOKL[1].z-vecOKL[0].z*vecOKL[1].y,vecOKL[0].z*vecOKL[1].x-vecOKL[0].x*vecOKL[1].z,vecOKL[0].x*vecOKL[1].y-vecOKL[0].y*vecOKL[1].x>;
				#local norBFE = <vecBFE[0].y*vecBFE[1].z-vecBFE[0].z*vecBFE[1].y,vecBFE[0].z*vecBFE[1].x-vecBFE[0].x*vecBFE[1].z,vecBFE[0].x*vecBFE[1].y-vecBFE[0].y*vecBFE[1].x>;
				#local norCGF = <vecCGF[0].y*vecCGF[1].z-vecCGF[0].z*vecCGF[1].y,vecCGF[0].z*vecCGF[1].x-vecCGF[0].x*vecCGF[1].z,vecCGF[0].x*vecCGF[1].y-vecCGF[0].y*vecCGF[1].x>;
				#local norDHG = <vecDHG[0].y*vecDHG[1].z-vecDHG[0].z*vecDHG[1].y,vecDHG[0].z*vecDHG[1].x-vecDHG[0].x*vecDHG[1].z,vecDHG[0].x*vecDHG[1].y-vecDHG[0].y*vecDHG[1].x>;
				#local norFJI = <vecFJI[0].y*vecFJI[1].z-vecFJI[0].z*vecFJI[1].y,vecFJI[0].z*vecFJI[1].x-vecFJI[0].x*vecFJI[1].z,vecFJI[0].x*vecFJI[1].y-vecFJI[0].y*vecFJI[1].x>;
				#local norGKJ = <vecGKJ[0].y*vecGKJ[1].z-vecGKJ[0].z*vecGKJ[1].y,vecGKJ[0].z*vecGKJ[1].x-vecGKJ[0].x*vecGKJ[1].z,vecGKJ[0].x*vecGKJ[1].y-vecGKJ[0].y*vecGKJ[1].x>;
				#local norHLK = <vecHLK[0].y*vecHLK[1].z-vecHLK[0].z*vecHLK[1].y,vecHLK[0].z*vecHLK[1].x-vecHLK[0].x*vecHLK[1].z,vecHLK[0].x*vecHLK[1].y-vecHLK[0].y*vecHLK[1].x>;
				#local norJNM = <vecJNM[0].y*vecJNM[1].z-vecJNM[0].z*vecJNM[1].y,vecJNM[0].z*vecJNM[1].x-vecJNM[0].x*vecJNM[1].z,vecJNM[0].x*vecJNM[1].y-vecJNM[0].y*vecJNM[1].x>;
				#local norKON = <vecKON[0].y*vecKON[1].z-vecKON[0].z*vecKON[1].y,vecKON[0].z*vecKON[1].x-vecKON[0].x*vecKON[1].z,vecKON[0].x*vecKON[1].y-vecKON[0].y*vecKON[1].x>;
				#local norLPO = <vecLPO[0].y*vecLPO[1].z-vecLPO[0].z*vecLPO[1].y,vecLPO[0].z*vecLPO[1].x-vecLPO[0].x*vecLPO[1].z,vecLPO[0].x*vecLPO[1].y-vecLPO[0].y*vecLPO[1].x>;	// not used
				// calculate vertex normals (only need four of these)
//				#debug concat("i = ", str(i, 0, 0), "; j = ", str(j, 0, 0), "\n")
				#local norJ = vnormalize(norJFG+norGKJ+norNJK+norJNM+norMIJ+norFJI);
				#local norF = vnormalize(norFBC+norCGF+norJFG+norFJI+norIEF+norBFE);
				#local norG = vnormalize(norGCD+norDHG+norKGH+norGKJ+norJFG+norCGF);
				#local norK = vnormalize(norKGH+norHLK+norOKL+norKON+norNJK+norGKJ);
				// create textures (only need two of these)
				#local colJFG = (colJ + colF + colG)/3;
				#local colGKJ = (colG + colK + colJ)/3;
				// write stuff to log
				#write (cie_write_handle, "\t#local temp_texture = texture {pigment {color srgb ", colJFG, "} finish {cie_isoFinish}}\n")
				#write (cie_write_handle, "\tsmooth_triangle {", cooJ, ",", norJ, ",", cooF, ",", norF, ",", cooG, ",", norG, " texture {temp_texture}}\n")
				#write (cie_write_handle, "\t#local temp_texture = texture {pigment {color srgb ", colGKJ, "} finish {cie_isoFinish}}\n")
				#write (cie_write_handle, "\tsmooth_triangle {", cooG, ",", norG, ",", cooK, ",", norK, ",", cooJ, ",", norJ, " texture {temp_texture}}\n")
			#end
		#end
	#end
	#write (cie_write_handle, "}\n")
	#fclose cie_write_handle
#end

// pre-populate XYZ tables on disk
#if (cie_pre_xyz_srgb = true)
	cie_calc_gamut_xyz_srgb()
	cie_write_XYZ_coordinates_srgb("cie_xyz_data_srgb.inc")
#end
// pre-populate mesh geometry on disk
#if (cie_pre_mesh_srgb = true)
	#include "cie_xyz_data_srgb.inc"
	cie_write_flatmesh_srgb(cie_cspace_other, cie_mesh_file_other)
#end


//------------------------------------------------------------------------------
// cmyk gamut


#declare cie_sample_count_cmyk = 192/8;	// needs to be divisible by 8!!!
#declare cie_point_count_cmyk = 1;
#declare cie_point_total_cmyk = 8 * (cie_sample_count_srgb+1) * (cie_sample_count_srgb+1);
#declare cie_point_array_cmyk = array[8][cie_sample_count_srgb+1][cie_sample_count_srgb+1];

// needs work
#macro cie_calc_gamut_xyz_cmyk()
	// should handle black in the xyY space separately, but am unsure how
	#for (i, 0, cie_sample_count_cmyk)
		#for (j, 0, cie_sample_count_cmyk)
			#for (k, 0, cie_sample_count_cmyk)
				// side 0 & 4
				#local cooCMYK = <i/cie_sample_count_cmyk,j/cie_sample_count_cmyk,k/cie_sample_count_cmyk,0>;
				#local cooXYZ = cie_convCMYK2XYZ(cooCMYK);
				#declare cie_point_array_cmyk[0][i][j][k] = cooXYZ;
				#local cooCMYK = <i/cie_sample_count_cmyk,j/cie_sample_count_cmyk,k/cie_sample_count_cmyk,1>;
				#local cooXYZ = cie_convCMYK2XYZ(cooCMYK);
				#declare cie_point_array_cmyk[4][i][j][k] = cooXYZ;
			#end
		#end
	#end
#end
