// Title: CIE Color Conversion Formulas
// Authors: Michael Horvath, Christoph Lipka
// Website: http://isometricland.net
// Created: 2016-11-20
// Updated: 2017-03-25
// This file is licensed under the terms of the CC-GNU LGPL.
// http://www.gnu.org/licenses/lgpl-2.1.html
// Illuminant =  D65
// Observer   =  2° (1931)
// +kfi0 +kff63 +kc
// +k0.25

#version 3.7;
#include "math.inc"
//#include "cie.inc"			// http://www.ignorancia.org/en/index.php?page=Lightsys
//#include "lightsys.inc"			// http://www.ignorancia.org/en/index.php?page=Lightsys
//#include "lightsys_constants.inc"	// http://www.ignorancia.org/en/index.php?page=Lightsys

// constants
#declare cie_XYZWhiteReference1 =  95.047;
#declare cie_XYZWhiteReference2 = 100.000;
#declare cie_XYZWhiteReference3 = 108.883;
#declare cie_XYZEpsilon = 0.008856;
#declare cie_XYZKappa = 903.3;
#declare cie_uPrime = 4 * cie_XYZWhiteReference1/(cie_XYZWhiteReference1 + 15 * cie_XYZWhiteReference2 + 3 * cie_XYZWhiteReference3);
#declare cie_vPrime = 9 * cie_XYZWhiteReference2/(cie_XYZWhiteReference1 + 15 * cie_XYZWhiteReference2 + 3 * cie_XYZWhiteReference3);
#declare cie_fD_hack_mode = 2;


//------------------------------------------------------------------------------
// utility


#declare cie_selectRGBa = function(C,D) {select(C,-1,D)}
#declare cie_selectRGBb = function(C,D) {select(C-1,D,D,-1)}
#declare cie_linearRGBa = function(C) {C/12.92}
#declare cie_linearRGBb = function(C) {pow((C + 0.055)/(1 + 0.055), 2.4)}
#declare cie_linearRGBc = function(C) {select(C-0.04045,cie_linearRGBa(C),cie_linearRGBa(C),cie_linearRGBb(C))}

#declare cie_fDist = function(Dr,Dg,Db) {max(Dr,Dg,Db)}

#if (cie_fD_hack_mode = 2)
	// some isosurface scenes need this hack enabled
	#declare cie_fClip1 = function(X,A) {select(X-A,A,X)}
	#declare cie_fClip2 = function(X,A) {select(-(X-A),A,X)}
	#declare cie_fD = function(C) {abs(cie_fClip2(cie_fClip1(C,-0.1),1.1)-0.5)-0.5}
#elseif (cie_fD_hack_mode = 1)
	// regular behavior
	#declare cie_fD = function(C) {abs(C-0.5)-0.5}
#elseif (cie_fD_hack_mode = 0)
	// do nothing
	#declare cie_fD = function(C) {C}
#end

#macro cie_pivot_xyz(n)
	#if (n > cie_XYZEpsilon)
		#local nOut = pow(n, 1/3);
	#else
		#local nOut = (cie_XYZKappa * n + 16) / 116;
	#end
	nOut
#end

#macro cie_pivot_rgb(n)
            (n > 0.04045 ? pow((n + 0.055) / 1.055, 2.4) : n / 12.92) * 100;
#end


//------------------------------------------------------------------------------


// input L = between 0 and 100
// input C = between 0 and 128
// input H = between 0 and 360
// output L = between 0 and 100
// output A = usually between -128 and +128 or -200 and +200
// output B = usually between -128 and +128 or -200 and +200
#declare cie_funcLCHab2LABa1 = function(L,C,H) {L}
#declare cie_funcLCHab2LABa2 = function(L,C,H) {cosd(H) * C}
#declare cie_funcLCHab2LABa3 = function(L,C,H) {sind(H) * C}


// input H = between 0 and 360
// input C = between 0 and 128 or 0 and 200
// input L = between 0 and 100
// output L = between 0 and 100
// output U = usually between -128 and +128 or -200 and +200
// output V = usually between -128 and +128 or -200 and +200
#declare cie_funcLCHuv2LUVa1 = function(L,C,H) {L}
#declare cie_funcLCHuv2LUVa2 = function(L,C,H) {cosd(H) * C}
#declare cie_funcLCHuv2LUVa3 = function(L,C,H) {sind(H) * C}


// input L = between 0 and 100
// input A = usually between -128 and +128 or -200 and +200
// input B = usually between -128 and +128 or -200 and +200
// output X = between 0 and 100
// output Y = between 0 and 100
// output Z = between 0 and 100
// Note that some of these cie_functions are out of order.
#declare cie_funcLAB2XYZa2 = function(L,A,B) {(L + 16) / 116}
#declare cie_funcLAB2XYZa1 = function(L,A,B) {cie_funcLAB2XYZa2(L,A,B) + A / 500}
#declare cie_funcLAB2XYZa3 = function(L,A,B) {cie_funcLAB2XYZa2(L,A,B) - B / 200}
#declare cie_funcLAB2XYZb1 = function(L,A,B) {cie_XYZWhiteReference1 * select(pow(cie_funcLAB2XYZa1(L,A,B), 3) - cie_XYZEpsilon, (cie_funcLAB2XYZa1(L,A,B) - 16.0 / 116.0) / 7.787, (cie_funcLAB2XYZa1(L,A,B) - 16.0 / 116.0) / 7.787, pow(cie_funcLAB2XYZa1(L,A,B), 3))}
#declare cie_funcLAB2XYZb2 = function(L,A,B) {cie_XYZWhiteReference2 * select(L - cie_XYZKappa * cie_XYZEpsilon, L / cie_XYZKappa, L / cie_XYZKappa, pow(((L + 16) / 116), 3))}
#declare cie_funcLAB2XYZb3 = function(L,A,B) {cie_XYZWhiteReference3 * select(pow(cie_funcLAB2XYZa3(L,A,B), 3) - cie_XYZEpsilon, (cie_funcLAB2XYZa3(L,A,B) - 16.0 / 116.0) / 7.787, (cie_funcLAB2XYZa3(L,A,B) - 16.0 / 116.0) / 7.787, pow(cie_funcLAB2XYZa3(L,A,B), 3))}


// input L = between 0 and 100
// input U = usually between -128 and +128 or -200 and +200
// input V = usually between -128 and +128 or -200 and +200
// output X = between 0 and 100
// output Y = between 0 and 100
// output Z = between 0 and 100
#declare cie_funcLUV2XYZu1 = function(L,U,V) {U/13/L + cie_uPrime}
#declare cie_funcLUV2XYZv1 = function(L,U,V) {V/13/L + cie_vPrime}
#declare cie_funcLUV2XYZa2 = function(L,U,V) {cie_XYZWhiteReference2 * select(8 - L, pow((L + 16)/116, 3), L * pow(3/29, 3))}
#declare cie_funcLUV2XYZa1 = function(L,U,V) {cie_funcLUV2XYZa2(L,U,V) * 9/4 * cie_funcLUV2XYZu1(L,U,V)/cie_funcLUV2XYZv1(L,U,V)}
#declare cie_funcLUV2XYZa3 = function(L,U,V) {cie_funcLUV2XYZa2(L,U,V) * (12 - 3 * cie_funcLUV2XYZu1(L,U,V) - 20 * cie_funcLUV2XYZv1(L,U,V))/4/cie_funcLUV2XYZv1(L,U,V)}


// input X = between 0 and 1
// input Y2 = between 0 and 1
// input Y1 = between 0 and 100
// output X = between 0 and 100
// output Y = between 0 and 100
// output Z = between 0 and 100
#declare cie_funcXYY2XYZ1 = function(X,Y2,Y1) {(Y1/Y2) * X}
#declare cie_funcXYY2XYZ2 = function(X,Y2,Y1) {Y1}
#declare cie_funcXYY2XYZ3 = function(X,Y2,Y1) {(Y1/Y2) * (1 - X - Y2)}


// input X = between 0 and 100
// input Y = between 0 and 100
// input Z = between 0 and 100
// output R = between 0 and 1
// output G = between 0 and 1
// output B = between 0 and 1
// Note that out-of-range colors are *NOT* corrected. You will have to do this yourself.
#declare cie_funcXYZ2RGBa1 = function(X,Y,Z) {X/100 *  3.2406 + Y/100 * -1.5372 + Z/100 * -0.4986}
#declare cie_funcXYZ2RGBa2 = function(X,Y,Z) {X/100 * -0.9689 + Y/100 *  1.8758 + Z/100 *  0.0415}
#declare cie_funcXYZ2RGBa3 = function(X,Y,Z) {X/100 *  0.0557 + Y/100 * -0.2040 + Z/100 *  1.0570}
#declare cie_funcXYZ2RGBb1 = function(X,Y,Z) {select(cie_funcXYZ2RGBa1(X,Y,Z) - 0.0031308, 12.92 * cie_funcXYZ2RGBa1(X,Y,Z), 12.92 * cie_funcXYZ2RGBa1(X,Y,Z), 1.055 * pow(cie_funcXYZ2RGBa1(X,Y,Z), 1 / 2.4) - 0.055)}
#declare cie_funcXYZ2RGBb2 = function(X,Y,Z) {select(cie_funcXYZ2RGBa2(X,Y,Z) - 0.0031308, 12.92 * cie_funcXYZ2RGBa2(X,Y,Z), 12.92 * cie_funcXYZ2RGBa2(X,Y,Z), 1.055 * pow(cie_funcXYZ2RGBa2(X,Y,Z), 1 / 2.4) - 0.055)}
#declare cie_funcXYZ2RGBb3 = function(X,Y,Z) {select(cie_funcXYZ2RGBa3(X,Y,Z) - 0.0031308, 12.92 * cie_funcXYZ2RGBa3(X,Y,Z), 12.92 * cie_funcXYZ2RGBa3(X,Y,Z), 1.055 * pow(cie_funcXYZ2RGBa3(X,Y,Z), 1 / 2.4) - 0.055)}


// input R = between 0 and 1
// input G = between 0 and 1
// input B = between 0 and 1
// output R = between 0 and 1
// output G = between 0 and 1
// output B = between 0 and 1
// only uses these when converting individual values, not inside isosurfaces or cie_function patterns
#declare cie_correctRGBa1 = function(R,G,B) {cie_selectRGBa(R,cie_selectRGBa(G,cie_selectRGBa(B,R)))}
#declare cie_correctRGBa2 = function(R,G,B) {cie_selectRGBa(R,cie_selectRGBa(G,cie_selectRGBa(B,G)))}
#declare cie_correctRGBa3 = function(R,G,B) {cie_selectRGBa(R,cie_selectRGBa(G,cie_selectRGBa(B,B)))}
#declare cie_correctRGBb1 = function(R,G,B) {cie_selectRGBb(R,cie_selectRGBb(G,cie_selectRGBb(B,cie_correctRGBa1(R,G,B))))}
#declare cie_correctRGBb2 = function(R,G,B) {cie_selectRGBb(R,cie_selectRGBb(G,cie_selectRGBb(B,cie_correctRGBa2(R,G,B))))}
#declare cie_correctRGBb3 = function(R,G,B) {cie_selectRGBb(R,cie_selectRGBb(G,cie_selectRGBb(B,cie_correctRGBa3(R,G,B))))}


// input L = between 0 and 100
// input A = usually between -128 and +128 or -200 and +200
// input B = usually between -128 and +128 or -200 and +200
// output R = between 0 and 1
// output G = between 0 and 1
// output B = between 0 and 1
#declare cie_funcLAB2RGBa1 = function(L,A,B) {cie_funcXYZ2RGBb1(cie_funcLAB2XYZb1(L,A,B),cie_funcLAB2XYZb2(L,A,B),cie_funcLAB2XYZb3(L,A,B))}
#declare cie_funcLAB2RGBa2 = function(L,A,B) {cie_funcXYZ2RGBb2(cie_funcLAB2XYZb1(L,A,B),cie_funcLAB2XYZb2(L,A,B),cie_funcLAB2XYZb3(L,A,B))}
#declare cie_funcLAB2RGBa3 = function(L,A,B) {cie_funcXYZ2RGBb3(cie_funcLAB2XYZb1(L,A,B),cie_funcLAB2XYZb2(L,A,B),cie_funcLAB2XYZb3(L,A,B))}


// input L = between 0 and 100
// input U = usually between -128 and +128 or -200 and +200
// input V = usually between -128 and +128 or -200 and +200
// output R = between 0 and 1
// output G = between 0 and 1
// output B = between 0 and 1
#declare cie_funcLUV2RGBa1 = function(L,U,V) {cie_funcXYZ2RGBb1(cie_funcLUV2XYZa1(L,U,V),cie_funcLUV2XYZa2(L,U,V),cie_funcLUV2XYZa3(L,U,V))}
#declare cie_funcLUV2RGBa2 = function(L,U,V) {cie_funcXYZ2RGBb2(cie_funcLUV2XYZa1(L,U,V),cie_funcLUV2XYZa2(L,U,V),cie_funcLUV2XYZa3(L,U,V))}
#declare cie_funcLUV2RGBa3 = function(L,U,V) {cie_funcXYZ2RGBb3(cie_funcLUV2XYZa1(L,U,V),cie_funcLUV2XYZa2(L,U,V),cie_funcLUV2XYZa3(L,U,V))}


// input L = between 0 and 100
// input C = between 0 and 128 or 0 and 200
// input H = between 0 and 360
// output R = between 0 and 1
// output G = between 0 and 1
// output B = between 0 and 1
#declare cie_funcLCHab2RGBa1 = function(L,C,H) {cie_funcXYZ2RGBb1(cie_funcLAB2XYZb1(cie_funcLCHab2LABa1(L,C,H),cie_funcLCHab2LABa2(L,C,H),cie_funcLCHab2LABa3(L,C,H)),cie_funcLAB2XYZb2(cie_funcLCHab2LABa1(L,C,H),cie_funcLCHab2LABa2(L,C,H),cie_funcLCHab2LABa3(L,C,H)),cie_funcLAB2XYZb3(cie_funcLCHab2LABa1(L,C,H),cie_funcLCHab2LABa2(L,C,H),cie_funcLCHab2LABa3(L,C,H)))}
#declare cie_funcLCHab2RGBa2 = function(L,C,H) {cie_funcXYZ2RGBb2(cie_funcLAB2XYZb1(cie_funcLCHab2LABa1(L,C,H),cie_funcLCHab2LABa2(L,C,H),cie_funcLCHab2LABa3(L,C,H)),cie_funcLAB2XYZb2(cie_funcLCHab2LABa1(L,C,H),cie_funcLCHab2LABa2(L,C,H),cie_funcLCHab2LABa3(L,C,H)),cie_funcLAB2XYZb3(cie_funcLCHab2LABa1(L,C,H),cie_funcLCHab2LABa2(L,C,H),cie_funcLCHab2LABa3(L,C,H)))}
#declare cie_funcLCHab2RGBa3 = function(L,C,H) {cie_funcXYZ2RGBb3(cie_funcLAB2XYZb1(cie_funcLCHab2LABa1(L,C,H),cie_funcLCHab2LABa2(L,C,H),cie_funcLCHab2LABa3(L,C,H)),cie_funcLAB2XYZb2(cie_funcLCHab2LABa1(L,C,H),cie_funcLCHab2LABa2(L,C,H),cie_funcLCHab2LABa3(L,C,H)),cie_funcLAB2XYZb3(cie_funcLCHab2LABa1(L,C,H),cie_funcLCHab2LABa2(L,C,H),cie_funcLCHab2LABa3(L,C,H)))}
#declare cie_funcLCHab2RGBb1 = function(L,C,H) {cie_correctRGBb1(cie_funcLCHab2RGBa1(L,C,H),cie_funcLCHab2RGBa2(L,C,H),cie_funcLCHab2RGBa3(L,C,H))}
#declare cie_funcLCHab2RGBb2 = function(L,C,H) {cie_correctRGBb2(cie_funcLCHab2RGBa1(L,C,H),cie_funcLCHab2RGBa2(L,C,H),cie_funcLCHab2RGBa3(L,C,H))}
#declare cie_funcLCHab2RGBb3 = function(L,C,H) {cie_correctRGBb3(cie_funcLCHab2RGBa1(L,C,H),cie_funcLCHab2RGBa2(L,C,H),cie_funcLCHab2RGBa3(L,C,H))}


// input L = between 0 and 100
// input C = between 0 and 128 or 0 and 200
// input H = between 0 and 360
// output R = between 0 and 1
// output G = between 0 and 1
// output B = between 0 and 1
#declare cie_funcLCHuv2RGBa1 = function(L,C,H) {cie_funcXYZ2RGBb1(cie_funcLUV2XYZa1(cie_funcLCHuv2LUVa1(L,C,H),cie_funcLCHuv2LUVa2(L,C,H),cie_funcLCHuv2LUVa3(L,C,H)),cie_funcLUV2XYZa2(cie_funcLCHuv2LUVa1(L,C,H),cie_funcLCHuv2LUVa2(L,C,H),cie_funcLCHuv2LUVa3(L,C,H)),cie_funcLUV2XYZa3(cie_funcLCHuv2LUVa1(L,C,H),cie_funcLCHuv2LUVa2(L,C,H),cie_funcLCHuv2LUVa3(L,C,H)))}
#declare cie_funcLCHuv2RGBa2 = function(L,C,H) {cie_funcXYZ2RGBb2(cie_funcLUV2XYZa1(cie_funcLCHuv2LUVa1(L,C,H),cie_funcLCHuv2LUVa2(L,C,H),cie_funcLCHuv2LUVa3(L,C,H)),cie_funcLUV2XYZa2(cie_funcLCHuv2LUVa1(L,C,H),cie_funcLCHuv2LUVa2(L,C,H),cie_funcLCHuv2LUVa3(L,C,H)),cie_funcLUV2XYZa3(cie_funcLCHuv2LUVa1(L,C,H),cie_funcLCHuv2LUVa2(L,C,H),cie_funcLCHuv2LUVa3(L,C,H)))}
#declare cie_funcLCHuv2RGBa3 = function(L,C,H) {cie_funcXYZ2RGBb3(cie_funcLUV2XYZa1(cie_funcLCHuv2LUVa1(L,C,H),cie_funcLCHuv2LUVa2(L,C,H),cie_funcLCHuv2LUVa3(L,C,H)),cie_funcLUV2XYZa2(cie_funcLCHuv2LUVa1(L,C,H),cie_funcLCHuv2LUVa2(L,C,H),cie_funcLCHuv2LUVa3(L,C,H)),cie_funcLUV2XYZa3(cie_funcLCHuv2LUVa1(L,C,H),cie_funcLCHuv2LUVa2(L,C,H),cie_funcLCHuv2LUVa3(L,C,H)))}
#declare cie_funcLCHuv2RGBb1 = function(L,C,H) {cie_correctRGBb1(cie_funcLCHuv2RGBa1(L,C,H),cie_funcLCHuv2RGBa2(L,C,H),cie_funcLCHuv2RGBa3(L,C,H))}
#declare cie_funcLCHuv2RGBb2 = function(L,C,H) {cie_correctRGBb2(cie_funcLCHuv2RGBa1(L,C,H),cie_funcLCHuv2RGBa2(L,C,H),cie_funcLCHuv2RGBa3(L,C,H))}
#declare cie_funcLCHuv2RGBb3 = function(L,C,H) {cie_correctRGBb3(cie_funcLCHuv2RGBa1(L,C,H),cie_funcLCHuv2RGBa2(L,C,H),cie_funcLCHuv2RGBa3(L,C,H))}


// input X = between 0 and 1
// input Y2 = between 0 and 1
// input Y1 = between 0 and 100
// output R = between 0 and 1
// output G = between 0 and 1
// output B = between 0 and 1
#declare cie_funcXYY2RGB1 = function(X,Y2,Y1) {cie_funcXYZ2RGBb1(cie_funcXYY2XYZ1(X,Y2,Y1),cie_funcXYY2XYZ2(X,Y2,Y1),cie_funcXYY2XYZ3(X,Y2,Y1))}
#declare cie_funcXYY2RGB2 = function(X,Y2,Y1) {cie_funcXYZ2RGBb2(cie_funcXYY2XYZ1(X,Y2,Y1),cie_funcXYY2XYZ2(X,Y2,Y1),cie_funcXYY2XYZ3(X,Y2,Y1))}
#declare cie_funcXYY2RGB3 = function(X,Y2,Y1) {cie_funcXYZ2RGBb3(cie_funcXYY2XYZ1(X,Y2,Y1),cie_funcXYY2XYZ2(X,Y2,Y1),cie_funcXYY2XYZ3(X,Y2,Y1))}


//------------------------------------------------------------------------------


// testing
#local VLCH = <25,50,270>;
#local VLAB = <cie_funcLCHab2LABa1(VLCH.x,VLCH.y,VLCH.z), cie_funcLCHab2LABa2(VLCH.x,VLCH.y,VLCH.z), cie_funcLCHab2LABa3(VLCH.x,VLCH.y,VLCH.z)>;
#local VXYZ = <cie_funcLAB2XYZb1(VLAB.x,VLAB.y,VLAB.z), cie_funcLAB2XYZb2(VLAB.x,VLAB.y,VLAB.z), cie_funcLAB2XYZb3(VLAB.x,VLAB.y,VLAB.z)>;
#local VRGB = <cie_funcXYZ2RGBb1(VXYZ.x,VXYZ.y,VXYZ.z), cie_funcXYZ2RGBb2(VXYZ.x,VXYZ.y,VXYZ.z), cie_funcXYZ2RGBb3(VXYZ.x,VXYZ.y,VXYZ.z)>;
#local VCOR = < cie_correctRGBb1(VRGB.x,VRGB.y,VRGB.z),  cie_correctRGBb2(VRGB.x,VRGB.y,VRGB.z),  cie_correctRGBb3(VRGB.x,VRGB.y,VRGB.z)>;
#debug concat("VLCH = <", vstr(3, VLCH, ", ", 0, 5), ">\n")
#debug concat("VLAB = <", vstr(3, VLAB, ", ", 0, 5), ">\n")
#debug concat("VXYZ = <", vstr(3, VXYZ, ", ", 0, 5), ">\n")
#debug concat("VRGB = <", vstr(3, VRGB, ", ", 0, 5), ">\n")
#debug concat("VCOR = <", vstr(3, VCOR, ", ", 0, 5), ">\n")


//------------------------------------------------------------------------------


// input X = between 0 and 100
// input Y = between 0 and 100
// input Z = between 0 and 100
// output R = between 0 and 1
// output G = between 0 and 1
// output B = between 0 and 1
// Note that out-of-gamut colors are *NOT* corrected.
#macro cie_convXYZ2RGB(Color)
	#local XYZFT = color Color;
	#local X = XYZFT.red/100;
	#local Y = XYZFT.green/100;
	#local Z = XYZFT.blue/100;
	#local R = X *  3.2406 + Y * -1.5372 + Z * -0.4986;
	#local G = X * -0.9689 + Y *  1.8758 + Z *  0.0415;
	#local B = X *  0.0557 + Y * -0.2040 + Z *  1.0570;
	#local R = (R > 0.0031308 ? 1.055 * pow(R, 1 / 2.4) - 0.055 : 12.92 * R);
	#local G = (G > 0.0031308 ? 1.055 * pow(G, 1 / 2.4) - 0.055 : 12.92 * G);
	#local B = (B > 0.0031308 ? 1.055 * pow(B, 1 / 2.4) - 0.055 : 12.92 * B);
	<R,G,B>
#end


// input X = between 0 and 100
// input Y = between 0 and 100
// input Z = between 0 and 100
// output x = between 0 and 1
// output y = between 0 and 1
// output Y = between 0 and 100
#macro cie_convXYZ2XYY(Color)
	#local xyYSum = Color.x + Color.y + Color.z;
//	#if (xyYSum = 0)
//		#local xyYSum = 0.00001;
//	#end
	#local Y1 = Color.y;
	#local X = Color.x/xyYSum;
	#local Y2 = Color.y/xyYSum;
	<X,Y2,Y1>
#end


// input X = between 0 and 100
// input Y = between 0 and 100
// input Z = between 0 and 100
// output L = between 0 and 100
// output A = usually between -128 and +128 or -200 and +200
// output B = usually between -128 and +128 or -200 and +200
#macro cie_convXYZ2LAB(Color)
	#local X = cie_pivot_xyz(Color.x/cie_XYZWhiteReference1);
	#local Y = cie_pivot_xyz(Color.y/cie_XYZWhiteReference2);
	#local Z = cie_pivot_xyz(Color.z/cie_XYZWhiteReference3);
	#local L = max(0, 116 * Y - 16);
	#local A = 500 * (X - Y);
	#local B = 200 * (Y - Z);
	<L,A,B>
#end


// input X = between 0 and 100
// input Y = between 0 and 100
// input Z = between 0 and 100
// output L = between 0 and 100
// output U = usually between -128 and +128 or -200 and +200
// output V = usually between -128 and +128 or -200 and +200
#macro cie_convXYZ2LUV(Color)
	#local Y = Color.y / cie_XYZWhiteReference2;
	#local L = (Y > cie_XYZEpsilon ? 116 * pow(Y, 1 / 3) - 16 : cie_XYZKappa * Y);
	#local targetDenominator = Color.x + 15 * Color.y + 3 * Color.z;
	#local referenceDenominator = cie_XYZWhiteReference1 + 15 * cie_XYZWhiteReference2 + 3 * cie_XYZWhiteReference3;
	#local xTarget = (targetDenominator = 0 ? 0 : ((4 * Color.x / targetDenominator) - (4 * cie_XYZWhiteReference1 / referenceDenominator)));
	#local yTarget = (targetDenominator = 0 ? 0 : ((9 * Color.y / targetDenominator) - (9 * cie_XYZWhiteReference2 / referenceDenominator)));
	#local U = 13 * L * xTarget;
	#local V = 13 * L * yTarget;
	<L,U,V>
#end


// input x = between 0 and 1
// input y = between 0 and 1
// input Y = between 0 and 100
// output X = between 0 and 100
// output Y = between 0 and 100
// output Z = between 0 and 100
#macro cie_convXYY2XYZ(Color)
	#local X = Color.x * (Color.z / Color.y);
	#local Y = Color.z;
	#local Z = (1.0 - Color.x - Color.y) * (Color.z / Color.y)
	<X,Y,Z>
#end


// input L = between 0 and 100
// input A = usually between -128 and +128 or -200 and +200
// input B = usually between -128 and +128 or -200 and +200
// output L = between 0 and 100
// output C = between 0 and 128 or 0 and 200
// output H = between 0 and 360
#macro cie_convLAB2LCHab(Color)
	#local H = atan2d(Color.z, Color.y);
//	#if (H > 0)
//		#local H = (h / pi) * 180;
//	#else
//		#local H = 360 - (abs(H) / pi) * 180;
//	#end
	#if (H < 0)
		#local H = H + 360;	// should use modulos instead
	#elseif (H >= 360)
		#local H = H - 360;	// should use modulos instead
	#end
	#local L = Color.x;
	#local C = sqrt(Color.y * Color.y + Color.z * Color.z);
	<L,C,H>
#end


// input L = between 0 and 100
// input U = usually between -128 and +128 or -200 and +200
// input V = usually between -128 and +128 or -200 and +200
// output L = between 0 and 100
// output C = between 0 and 128 or 0 and 200
// output H = between 0 and 360
#macro cie_convLUV2LCHuv(Color)
	#local H = atan2d(Color.z, Color.y);
//	#if (H > 0)
//		#local H = (h / pi) * 180;
//	#else
//		#local H = 360 - (abs(H) / pi) * 180;
//	#end
	#if (H < 0)
		#local H = H + 360;	// should use modulos instead
	#elseif (H >= 360)
		#local H = H - 360;	// should use modulos instead
	#end
	#local L = Color.x;
	#local C = sqrt(Color.y * Color.y + Color.z * Color.z);
	<L,C,H>
#end


// input R = between 0 and 1
// input G = between 0 and 1
// input B = between 0 and 1
// output X = between 0 and 100
// output Y = between 0 and 100
// output Z = between 0 and 100
#macro cie_convRGB2XYZ(Color)
	#local R = cie_pivot_rgb(Color.x);
	#local G = cie_pivot_rgb(Color.y);
	#local B = cie_pivot_rgb(Color.z);
	#local X = R * 0.4124 + G * 0.3576 + B * 0.1805;
	#local Y = R * 0.2126 + G * 0.7152 + B * 0.0722;
	#local Z = R * 0.0193 + G * 0.1192 + B * 0.9505;
	<X,Y,Z>
#end
