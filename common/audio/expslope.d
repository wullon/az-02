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
module audio.expslope;

import util.math;

final struct ExpSlope
{
	private
	{
		float m_current;
		float m_start;
		float m_stop;
		float m_yscale;
		float m_gain;
	}
	
	public
	{
		static ExpSlope opCall(float _start, float _stop, float _tau, float _duration)
		{
			ExpSlope slope;
			slope.setPath(_start, _stop);
			slope.setTimings(_tau, _duration);			
			return slope;
		}
		
		void setTarget(float target)
		{
			setPath(m_stop, target);
		}
		
		void setPath(float start, float stop)
		{
			m_start = start;
			m_stop = stop;
			m_current = 0;
		}
		
		void setTimings(float _tau, float _duration)
		{
			tau = _tau;
			duration = _duration;
		}
		
		
    	float current()
    	{
	    	return m_current;
    	}
    	
    	float current(float c)
    	{
	    	return m_current = c;
    	}
    	
    	float next()
    	{
	    	m_current = m_current + (1.0f - m_current) * m_gain;
	 		float ret = m_current * m_yscale;
    		if( ret >= 1.0f ) 
    		{
	    		return m_stop;
    		}
    		if( m_start < m_stop )  
    		{
	    		return m_start + (m_stop - m_start) * ret;
    		}
    		else 
    		{
	    		return (m_start - m_stop) * (1.0f - ret) + m_stop;
    		}
		}
		
		float stop(float e)
    	{
	    	return m_stop = e;
    	}
    	
    	float stop()
    	{
	    	return m_stop;
    	}
    	
    	float start(float e)
    	{
	    	return m_start = e;
    	}
    	
    	float start()
    	{
	    	return m_start;
    	}
    	
    	bool finished()
    	{
	    	return (m_current * m_yscale >= 1.0f); 	    		
		}
		
		float tau(float t)
		{
			m_gain = (t < 1.f) ? (1.f) : (1.f / t);		
			return t;
		}
		
		float duration(float t)
		{
			float target = 1.f - exp(-t);
			m_yscale = 1.f / target;
			return t;
		}
	}
}