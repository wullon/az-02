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
module demo.azcurve;

import std.stream;
import std.string;
import util.geometry.curve;
import util.math;


class AZCError : object.Exception
{	
	this(char[] filename, char[] msg)
	{
		super(format("%s : %s", filename, msg));
	}
}

enum AZCDataFormat
{
	UBYTE,
	BYTE,
	USHORT,
	SHORT,
	UINT,
	INT,
	FLOAT	
}

// contains a voilume/pitch envelope
final class AZCurve
{
	private
	{
		real m_sampleRate;
		Curvef m_curve;
		float m_minValue;
		float m_maxValue;
		float m_normalizeFactor;
		
	}
	public
	{
		this(char[] AZCFile)
		{
			auto f = new File(AZCFile, FileMode.In);	
			scope(exit) f.close;
			
			float[] data;
			data.length = 0;
			
			uint magic;
			uint ver;
			uint sample_rate_x1000;
			int number_of_chunks;
			uint data_format;
			float default_value;
			
			f.read(magic);
			
			if (magic != 0x31435A41) 	// check AZC1
			{
				throw new AZCError(	AZCFile, "magic number expected \"AZC1\"");
			}
			
			f.read(ver);
			
			if (ver != 1)
			{
				throw new AZCError(	AZCFile, "version not supported");
			}
			
			f.read(sample_rate_x1000);
			
			m_sampleRate = sample_rate_x1000 * 0.001L;
			
			f.read(number_of_chunks);
			
			f.read(data_format);
			
			if (data_format != AZCDataFormat.FLOAT)
			{
				throw new AZCError(	AZCFile, "data format not supported");
			}
			
			f.read(default_value);
			
			f.read(m_minValue);
			f.read(m_maxValue);
			
			// fuzzy, but useful
			m_normalizeFactor = (abs(m_minValue - m_maxValue) > 1e-10) ? (1.f / (m_maxValue - m_minValue)) : 0.f; 
			
			for (int i = 0; i < number_of_chunks; ++i)
			{
				uint chunk_magic;
				f.read(chunk_magic);
				
				switch (chunk_magic)
				{
					case 0x4D435043:  // "CPCM"
					
						uint offset;
						uint count;
						f.read(offset);
						f.read(count);
						
						int old_length = data.length;
						data.length = max(data.length, offset + count); // suboptimal !
						
						for (int j = old_length; j < offset; ++j)
						{
							data[j] = default_value;	
						}
						
						for (int j = 0; j < count; j++)
						{
							f.read(data[offset + j]);	
						}
						
						break;
						
					default:
						throw new AZCError(	AZCFile, "unrecognized chunk");					
				}				
			}
			
			m_curve = new Curvef(data);						
		}	
		
		float sample(float time)
		{
			return m_curve.sampleSecure(time * m_sampleRate, Curvef.Sampling.HERMITE);
		}
		
		float sampleNormalized(float time)
		{
			return (sample(time) - m_minValue) * m_normalizeFactor;
		}
	}
	
}