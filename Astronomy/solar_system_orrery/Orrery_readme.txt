Caption:         Solar System Orrery
Version:         3.3
Authors:         Michael Horvath
Website:         http://isometricland.net
Created:         2018-09-15
Updated:         2018-10-06

License:
  This file is licensed under the terms of the CC-LGPL.
  http://www.gnu.org/licenses/lgpl-2.1.html

Description:
  A model of the solar system. Includes all eight planets. Can be animated by 
  tying the Orrery_StopDate parameter to the clock.

================================================================================

SOURCES

Orbital formulas and elements:
  "aprx_pos_planets.pdf"
Rotational formulas:
  "burmeister_steffi.pdf"
Rotational elements:
  "WGCCRE2009reprint.pdf"
Planetary textures:
  https://www.solarsystemscope.com/textures/
Text font:
  https://en.wikipedia.org/wiki/Open_Sans
Discussion threads:
  http://news.povray.org/povray.text.scene-files/thread/%3C5b9af9c7%241%40news.povray.org%3E/
  http://news.povray.org/povray.advanced-users/thread/%3C5b9d3c62%241%40news.povray.org%3E/

================================================================================

CHANGE LOG

3.3 - 2018-10-06
* Changed start and end dates of outer planet renders to coincide with Saturn 
  aphelion.
* Split stats and macros into separate "orrery_planet_stats.inc" file.
* Am now modeling planetary oblateness as well.
* Merged change log and to-do list into this readme.

3.2 - 2018-10-01
* Changed how start and stop dates are specified.
* Fixed orientation of Saturn's rings texture.

3.1 - 2018-09-29
* Update starting and ending dates for the orbits and trails.

3.0 - 2018-09-28
* Attempted to model the rotation and obliquity of the planets. Was only 
  partially successful. The poles are pointing in the correct direction, but 
  the planets are not rotated by the correct amounts around their axes.
* Added markers to gauge planet orientations.
* Renamed the scene files.
* Created another scene file just to monitor planet orientations.

2.2 - 2018-09-19
* Changed textures of planets.
* Tweak lighting.
* Tweak grid lines.
* Can now switch between inner and outer planets.

2.1 - 2018-09-16
* Added textures to planets.
* Tweak lighting.
* Can now switch between gray and black scenes.

2.0 - 2018-09-16
* Discovered that my calculations were all incorrect. Could not recall where I 
  got the original equations from, so I switched to a new set of formulas from 
  the JPL.

1.0 - 2018-09-15
* Initial release.
* Planets do not have texture maps.
* Planets are not tilted with respect to their orbital planes.
* Planets are not oriented such that the correct side of the planet is facing 
  the sun at a given moment.
* Does not include a realistic and accurate star field.
* Does not include Pluto, Ceres or any other dwarf planets.

================================================================================

TO-DO LIST

* Should maybe switch the reference frame from the ecliptic to the invariable 
  plane.
* Should maybe switch to using planet textures from here instead: 
    http://planetpixelemporium.com/planets.html
* Should add Ceres and some dwarf planets too. Maybe some moons. I haven't 
  worked out the math yet, however.
* Planet orientations using rotational elements are still not correct. Luckily, 
  the poles are at least pointing in the right directions. But the amounts of 
  rotation around the poles are off, with the exception of Earth and Neptune, 
  where I eyeballed the correct values (or nearly so).
* Should update to more recently measured planetary rotational elements. 
  However, the most recent tables omit Earth and Luna for some reason.
* Should maybe switch to using a large empty volume with interior media for the 
  sun's glow instead of just the current horizontal plane. But then you can't 
  see the planets' shadows on the plane which is something I like.
