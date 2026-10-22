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
module demo.timespan;

import util.geometry.vec2;
import util.vector;
import std.string;

// Represents a union of time interval
// used to determine if an effect must be active

class TimeSpan
{
	private
	{
		Vector!(vec2d) m_intervals;
	}
	
	public
	{
		this()
		{
			m_intervals = new Vector!(vec2d)();	
		}
		
		this(vec2d[] intervals ...)
		{
			m_intervals = new Vector!(vec2d)();				
			foreach(vec2d i; intervals)
			{
				m_intervals.add(i);
			}
		}
		
		void add(vec2d interval)
		{
			assert(interval.x < interval.y);
			m_intervals.add(interval);
		}
		
		// returns the index of the interval containing time
		// or -1 
		int search(double time)
		{
			for(int i = 0; i < m_intervals.length; ++i)
			{
				if( ( m_intervals[i].x <= time ) && ( time < m_intervals[i].y ) )
				{
					return i;
				}				
			}
			return -1;
		}
		
		vec2d interval(int i) { return m_intervals[i]; }
		
		char[] toString()
		{
			char[] res = "";
			for( int i = 0; i < m_intervals.length; ++i)
			{
				if( i > 0 )
				{
					res ~= " U ";	
				}
				res ~= format("%s", m_intervals[i]);
			}
			return res;
		}
	}
}
