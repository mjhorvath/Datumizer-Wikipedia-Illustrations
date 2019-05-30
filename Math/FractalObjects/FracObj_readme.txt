// Title: Fractal Objects Include v1.11
// Authors: Michael Horvath, http://isometricland.net
// Created: 2008/11/26
// Updated: 2019/05/30
// This file is licensed under the terms of the CC-LGPL.

DESCRIPTION
This is a collection of fractal objects. In the future I hope to incorporate 
patterns as well. There are three fractals to choose from at the moment: the 
Menger Sponge, the Sierpinski Pyramid and the Sierpinski Tetrahedron. All three 
objects can be used in CSG operations.

All three shapes take the same three paramaters: 1) recursion depth, 2) scaling 
vector and 3) gap width. The only difference is that, in the case of the 
Sierpinski Tetrahedron, only the x- and y-components of the scaling vector are 
considered. In all three cases the gap width is measured irrespective of the 
scaling vector or recursion depth. That means that you can scale the shapes or 
increase the recursion depth, and the gap will always be the same size.

Note that the rendering speed can slow down considerably if you set the 
recursion depth top a high value.
