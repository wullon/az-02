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
module audio.idelayline;

import audio.types;
import audio.audiobuffer;
import std.stdio;
import util.math;

// delay line struct (only with integer delays)
// no resampling, faster
struct IDelayLine 
{
	private
	{
		AudioBuffer m_buffer;		
		
		const int TOO_MUCH_DELAY = 1048576; // what would be the point of such a delay ?
		
		int m_writeIndex; // where to write
		int m_mask;
		int m_maxDelay;
		
		int requiredLength(int samples) // return the first n with 2^n >= samples
		{
			int i = 1;
			while (i < samples) 
			{
				i <<= 1;
			}
			return i;
		}
	}
	
	public
	{
		static IDelayLine opCall(int maxDelay)
		{
			IDelayLine line;
			line.maxDelay = maxDelay;
			return line;
		}
		
		static IDelayLine opCall() 
		{
			return IDelayLine(0);	
		}
		
		int maxDelay(int l) 
		{ 
			m_maxDelay = l;
			auto realLength = requiredLength(l);
			if (realLength > TOO_MUCH_DELAY)
			{
				realLength = TOO_MUCH_DELAY;
			}
			
			m_buffer.length = realLength;
			m_mask = realLength - 1;
			
			return m_maxDelay;
		}
		
		int maxDelay()
		{
			return m_maxDelay;	
		}
		
		void clear()
		{
			m_buffer.clear();	
		}
		
		void feed(float x)
		{			
			m_buffer.data[m_writeIndex = (m_writeIndex + 1) & m_mask] = x;
		}
		
		// read t samples before m_writeIndex
		// t is integer
		float read(int t) 
		{	
			float x = m_writeIndex - t;
			return m_buffer.data[(m_writeIndex - t) & m_mask];
		}
	}
}

