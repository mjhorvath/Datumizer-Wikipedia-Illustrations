#version 3.7

#include "math.inc"
#include "finish.inc"
#include "transforms.inc"

global_settings
{
	assumed_gamma	1.0
	radiosity {brightness 0.3}
}

camera
{
	location	-z * 3
	look_at		0
	up		y
	right		x
	rotate		<asind(tand(30)),45,0,>
}

light_source
{
	<0,0,-100,>
	color rgb	1
	rotate	<60,30,00,>
	parallel
	point_at 0
	shadowless
}

polygon
{
	4, <+0,-1,-1,>, <+0,+1,-1,>, <+0,+1,+1,>, <+0,-1,+1,>
	texture {pigment {srgbt 0.75}}
}

polygon
{
	4, <-1,+0,-1,>, <-1,+0,+1,>, <+1,+0,+1,>, <+1,+0,-1,>
	texture {pigment {srgbt 0.75}}
}

text
{
	ttf "TIMES.TTF" "II" 0.1, 0
	pigment { srgb 0 }
	rotate y*90
	scale 1/3
	translate <0.5,0.5,0,>
}

text
{
	ttf "TIMES.TTF" "I" 0.1, 0
	pigment { srgb 0 }
	rotate y*90
	scale 1/3
	translate <-0.5,0.5,0,>
}

text
{
	ttf "TIMES.TTF" "IV" 0.1, 0
	pigment { srgb 0 }
	rotate y*90
	scale 1/3
	translate <-0.5,-0.5,0,>
}

text
{
	ttf "TIMES.TTF" "III" 0.1, 0
	pigment { srgb 0 }
	rotate y*90
	scale 1/3
	translate <0.5,-0.5,0,>
}

#declare V_Text = text
{
	ttf "verdana.TTF" "V" 0.0001, 0
	pigment { srgbt <0,0,1,0.75> }
	rotate y*90
	scale 5/3
}

object
{
	V_Text
	Center_Trans(V_Text, x+y+z)
}

#declare H_Text = text
{
	ttf "verdana.TTF" "H" 0.0001, 0
	pigment { srgbt <0,0,1,0.75> }
	rotate y*90
	scale 5/3
}

object
{
	H_Text
	Center_Trans(V_Text, x+y+z)
	rotate z*90
}

background {color srgb 1}
