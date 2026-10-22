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
module audio.waveguide;

// digital waveguide structure
import audio.delayline;
import audio.waveguidenode;
import audio.constants;
import util.math;

class Waveguide
{
	private
	{
		float m_impedance;
		
		DelayLine m_ab;
		DelayLine m_ba;	
		WaveguideNode m_a;
		WaveguideNode m_b;
	}
	
	public
	{
		this(WaveguideNode a, WaveguideNode b, float impedance, float ms)
		{
			m_a = a;
			m_b = b;
			m_impedance = impedance;
			
			m_ab = DelayLine(round(ms * 0.001 * SAMPLE_RATE));
			m_ba = DelayLine(round(ms * 0.001 * SAMPLE_RATE));
			
			m_a.addInput(&m_ba);
			m_b.addInput(&m_ab);
			
			m_a.addOutput(&m_ab);
			m_b.addOutput(&m_ba);
		}		
		
		DelayLine * ab() { return &m_ab; }	
		DelayLine * ba() { return &m_ba; }
		WaveguideNode a() { return a; }
		WaveguideNode b() { return b; }
		
	}
}

