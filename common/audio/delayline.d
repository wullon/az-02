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
module audio.delayline;

import audio.types;
import audio.audiobuffer;
import std.stdio;
import util.math;

// delay line struct (with fractionnal delay)
struct DelayLine 
{
	private
	{
		AudioBuffer m_buffer;		
		
		const int TOO_MUCH_DELAY = 1048576; // what would be the point of such a delay ?
		
		int m_writeIndex; // where to write
		int m_mask;
		float m_maxDelay;
		
		int requiredLength(float samples) // return the first n with 2^n >= samples
		{
			int i = 1;
			while (i < samples + 4) 
			{
				i <<= 1;
			}
			return i;
		}
	}
	
	public
	{
		static DelayLine opCall(float maxDelay)
		{
			DelayLine line;
			line.maxDelay = maxDelay;
			return line;
		}
		
		static DelayLine opCall() 
		{
			return DelayLine(0);	
		}
		
		float maxDelay(float l) 
		{ 
			m_maxDelay = l;
			auto realLength = requiredLength(l);
			assert(realLength <= TOO_MUCH_DELAY);
			m_buffer.length = realLength;
			m_mask = realLength - 1;	
			return m_maxDelay;
		}
		
		float maxDelay()
		{
			return m_maxDelay;	
		}
		
		void clear()
		{
			m_buffer.clear();	
		}
		
		void fill(float x)
		{
			m_buffer.fill(x);	
		}
		
		void feed(float x)
		{			
			m_buffer.data[m_writeIndex = (m_writeIndex + 1) & m_mask] = x;
		}
		
		// read t samples before m_writeIndex
		// WARNING : t cannot be between 0 and 1
		float read(float t) 
		{	
			float x = m_writeIndex - t;
			int ix = trunc(x);
			auto mask = m_mask;
			float x_p_1 = m_buffer.data[(ix + 1) & mask];
			float x_m_0 = m_buffer.data[(ix ) & mask];
			float x_m_1 = m_buffer.data[(ix - 1) & mask];
			float x_m_2 = m_buffer.data[(ix - 2) & mask];		
			return hermite(x - ix, x_p_1, x_m_0, x_m_1, x_m_2);
		}
	}
}

