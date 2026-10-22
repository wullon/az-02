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
module audio.waveguidenode;

import audio.delayline;
import audio.waveguidenode;
import audio.constants;


class WaveguideNode
{
	private
	{
		DelayLine * [] m_inputs;
		DelayLine * [] m_outputs;	
		float m_energyLossFactor;	
	}	
		
	public
	{
		float energy = 0.f;	
		
		this(float lossFactor)
		{
			m_inputs.length = 0;
			m_outputs.length = 0;
			m_energyLossFactor = lossFactor;
		}
		
		void addInput(DelayLine * d)
		{
			m_inputs.length = m_inputs.length + 1;
			m_inputs[m_inputs.length - 1] = d;
		}
		
		void addOutput(DelayLine * d)
		{
			m_outputs.length = m_outputs.length + 1;
			m_outputs[m_outputs.length - 1] = d;
		}
		
		void accumulate()
		{
			for (int i = 0; i < m_inputs.length; ++i)
			{
				energy += m_inputs[i].read(m_inputs[i].maxDelay);
			}
		}
		
		void clear()
		{
			energy = 0.f;
		}
		
		void distribute()
		{
			energy *= m_energyLossFactor;
			for (int i = 0; i < m_outputs.length; ++i)
			{
				m_outputs[i].feed( energy / cast(float)m_outputs.length );
			}
		}
	}
}