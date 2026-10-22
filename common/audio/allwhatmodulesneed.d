/*     DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2009 Adinpsz contributors
  7 chemin Villebois 38100 Grenoble
 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO. */
/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */ 
module audio.allwhatmodulesneed;

public
{
	import std.stdio, std.string;
	
	import util.math;
	import util.random;
	import util.common;	
	import util.spinlock;
	
	import audio.types;
	import audio.constants;
	import audio.utils;
	import audio.audiodata;	
	import audio.audiomodule;	
	import audio.audiobuffer;	
	import audio.analogbuffer;
	import audio.delayline;
	import audio.message;
	import audio.errors;
	import audio.expslope;
	import audio.parameters;
	import audio.parametersinfo;
}

