// Pentatope of 70 spheres POV-Ray source by Blotwell
// Uploaded to Wikimedia Commons
// and released under GPL
// +KC +KFI0 +KFF43
// +KC +KFI0 +KFF21 +KI0 +KI0.5
// +KC +KFI22 +KFF43 +KI0.5 +KI1
// Render frames 0 through 43 (43 is blank)

#include "Axes_macro.inc"
Axes_Macro
(
	1000,	// Axes_axesSize,	The distance from the origin to one of the grid's edges.		(float)
	1,	// Axes_majUnit,	The size of each large-unit square.					(float)
	10,	// Axes_minUnit,	The number of small-unit squares that make up a large-unit square.	(integer)
	0.0001,	// Axes_thickRatio,	The thickness of the grid lines (as a factor of axesSize).		(float)
	off,	// Axes_aBool,		Turns the axes on/off.							(boolian)
	off,	// Axes_mBool,		Turns the minor units on/off. 						(boolian)
	off,	// Axes_xBool,		Turns the plane perpendicular to the x-axis on/off.			(boolian)
	on,	// Axes_yBool,		Turns the plane perpendicular to the y-axis on/off.			(boolian)
	off	// Axes_zBool,		Turns the plane perpendicular to the z-axis on/off.			(boolian)
)
object {Axes_Object}

plane
{
	-y,0.00001
	pigment {color rgbt <0,0,0,3/4>}
}

global_settings
{
	assumed_gamma	1.8
	adc_bailout	0.005
	max_trace_level	50
	radiosity
	{
		pretrace_start	0.08
		pretrace_end	0.01
		count		50
		error_bound	0.1
		recursion_limit	1
		normal		on
		brightness	0.8
		always_sample	yes
		gray_threshold	0.8
		media		on
	}
}

sky_sphere
{
	pigment
	{
		gradient y
		color_map
		{
			[0.0 rgb <0.6,0.7,1.0>*2]
			[0.7 rgb <0.0,0.1,0.8>*4]
//			[0.0 rgb <0.6,0.7,1.0>/2 + 2/4]
//			[0.7 rgb <0.0,0.1,0.8>/2 + 2/4]
		}
	}
}

background {rgb 1}

light_source
{
	<0, 0, 0>
	color rgb <1, 1, 1>
	translate <-30, 30, -30>
	parallel
}

light_source
{
	<0, 0, 0>
	color rgb <1, 1, 1>
	translate <-30, 30, -30>
	rotate y * 90
	parallel
}

#declare sq = 1/sqrt(2);
#declare T = ((frame_number - 5)/4) * sq;
#declare vx = <+2,+0,+0,>;
#declare vy = <+1,+0,+1,>;
#declare vw = <+1,+0,-1,>;
#declare vz = <+1,sqrt(5/2),+0,>;

camera
{
	location	<-08,+15,-12,> - 4 * vz
	up		<+0,+1/2,+0,>
	right		<+2/3,+0,+0,>
	look_at		4 * vz - y * 3

	focal_point	4 * vz - y * 3
	aperture	1/2
	blur_samples	20
}

#declare my_sphere_1 = sphere
{
	<0,0,0,>, 1
	pigment {color rgbf <0.9,1.0,0.9,0.9,>}
	finish {refraction 1 ior 1.2}
}
#declare my_sphere_2 = sphere
{
	<0,0,0,>, 1
	pigment {color rgbf <0.9,0.9,1.0,0.9,>}
	finish {refraction 1 ior 1.2}
}
#declare my_sphere_3 = sphere
{
	<0,0,0,>, 1
	pigment {color rgbf <1.0,1.0,0.8,0.9,>}
	finish {refraction 1 ior 1.2}
}
#declare my_sphere_4 = sphere
{
	<0,0,0,>, 1
	pigment {color rgbf <1.0,0.9,0.9,0.9,>}
	finish {refraction 1 ior 1.2}
}
#declare my_sphere_5 = sphere
{
	<0,0,0,>, 1
	pigment {color rgbf <0.9,0.9,0.9,0.9,>}
	finish {refraction 1 ior 1.2}
}

#declare my_sphere_6 = union
{
	#declare www = 0;
	#while (www < 5)
		#declare exe = 0;
		#while (exe < 5 - www)
			#declare wye = 0;
			#while (wye < 5 - www - exe)
				#declare tee = (www + wye) * sq * 2;
				#if (tee - 1 < T)
					#if (tee + 1 > T)
						object
						{
							my_sphere_1
							scale		sqrt(1 - (T - tee) * (T - tee))
							translate	y + www * vw + exe * vx + wye * vy
						}
					#end
				#end
				#declare wye = wye + 1;
			#end
			#declare exe = exe + 1;
		#end
		#declare www = www + 1;
	#end
	#declare www = 0;
	#while (www < 4)
		#declare exe = 0;
		#while (exe < 4 - www)
			#declare wye = 0;
			#while (wye < 4 - www - exe)
				#declare tee = (www + wye) * sq * 2 + sq;
				#if (tee - 1 < T)
					#if (tee + 1 > T)
						object
						{
							my_sphere_2
							scale		sqrt(1 - (T - tee) * (T - tee))
							translate	y + vz + www * vw + exe * vx + wye * vy
						}
					#end
				#end
				#declare wye = wye + 1;
			#end
			#declare exe = exe + 1;
		#end
		#declare www = www + 1;
	#end
	#declare www = 0;
	#while (www < 3)
		#declare exe = 0;
		#while (exe < 3 - www)
			#declare wye = 0;
			#while (wye < 3 - www - exe)
				#declare tee = (www + wye) * sq * 2 + 2 * sq;
				#if (tee - 1 < T)
					#if (tee + 1 > T)
						object
						{
							my_sphere_3
							scale		sqrt(1 - (T - tee) * (T - tee))
							translate	y + 2 * vz + www * vw + exe * vx + wye * vy
						}
					#end
				#end
				#declare wye = wye + 1;
			#end
			#declare exe = exe + 1;
		#end
		#declare www = www + 1;
	#end
	#declare www = 0;
	#while (www < 2)
		#declare exe = 0;
		#while (exe < 2 - www)
			#declare wye = 0;
			#while (wye < 2 - www - exe)
				#declare tee = (www + wye) * sq * 2 + 3 * sq;
				#if (tee - 1 < T)
					#if (tee + 1 > T)
						object
						{
							my_sphere_4
							scale		sqrt(1 - (T - tee) * (T - tee))
							translate	y + 3 * vz + www * vw + exe * vx + wye * vy
						}
					#end
				#end
				#declare wye = wye + 1;
			#end
			#declare exe = exe + 1;
		#end
		#declare www = www + 1;
	#end
	#declare www = 0;
	#while (www < 1)
		#declare exe = 0;
		#while (exe < 1 - www)
			#declare wye = 0;
			#while (wye < 1 - www - exe)
				#declare tee = (www + wye) * sq * 2 + 4 * sq;
				#if (tee - 1 < T)
					#if (tee + 1 > T)
						object
						{
							my_sphere_5
							scale		sqrt(1 - (T - tee) * (T - tee))
							translate	y + 4 * vz + www * vw + exe * vx + wye * vy
						}
					#end
				#end
				#declare wye = wye + 1;
			#end
			#declare exe = exe + 1;
		#end
		#declare www = www + 1;
	#end
}

object {my_sphere_6}
