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
module demo.trackinfo;

import demo.azcurve;


// holds volume information about the individual tracks

enum Track
{
	KICK,
	BASS1,
	L303,
	R303,
	PAD1,	
	GRAINDO,
	GRAINDO_ACCUM,
	CHOIR,
	PERCUS,
	GIRL,
	MB
}

class TrackInfo
{
	const char[] DIRECTORY = "data/tracks/";
	
	private
	{
		const string[Track.max + 1] volumeFiles = 
		[
			"kick.azc",
			"bass1.azc",
			"l303.azc",
			"r303.azc",
			"pad1.azc",
			"graindo.azc",
			"graindo_accum.azc",
			"choir.azc",
			"percus.azc",
			"girl.azc",
			"mb.azc",
		];
		
		AZCurve[Track.max + 1] m_volume;
//		AZCurve[Track.max + 1] m_pitch;
	}
	
	public
	{
		this()
		{
			for(Track t = Track.min; t <= Track.max; ++t)
			{
				m_volume[t] = new AZCurve(DIRECTORY ~ volumeFiles[t]);
			}
		}
		
		float volume(Track t, double time)
		{
			return 	m_volume[t].sample(time);
		}
		
		float volumeNormalized(Track t, double time)
		{
			return 	m_volume[t].sampleNormalized(time);
		}
	}
}
