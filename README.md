jamirdochegal
=============

[![Build Status](https://img.shields.io/github/actions/workflow/status/mmitch/jamirdochegal/build.yml?branch=master)](https://github.com/mmitch/jamirdochegal/actions?query=branch%3Amaster)
[![GPL 2+](https://img.shields.io/badge/license-GPL%202%2B-blue.svg)](http://www.gnu.org/licenses/gpl-2.0-standalone.html)

jamirdochegal is a simple Perl script to listen to web radios via
mplayer.  The project homepage is at <https://github.com/mmitch/jamirdochegal>.

jamirdochegal needs to call curl(1) to parse playlists

usage
-----

    jamirdochegal [-h | -l | -r | <station> [<additional-mplayer-arguments>]]
    
    -h   print this help
    -l   list all stations
    -r   tune into a random station (default with no arguments given)


features
--------

* jamirdochegal will read additional stations from `~/.jamirdochegalrc`
  (see end of script for station list format)


todos
-----

* document station list format in here
* add jamirdochegal etymology (why do I keep thinking that I have
  already written about that?  if it's not in here, where else?)


license
-------

jamirdochegal  -  listen to web radios via mplayer  
Copyright (C) 2009-2022  Christian Garbs <mitch@cgarbs.de>  
Licensed under GNU GPL v2 (or later)  

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
