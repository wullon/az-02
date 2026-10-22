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
module audio.waveguidemesh;

import audio.delayline;
import audio.waveguide;
import audio.waveguidenode;


class WaveguideMesh
{
	private
	{
		Waveguide[] m_waveguides;
		// the node 0 is the input, the node m_nodes.length - 1 is the output
		WaveguideNode[] m_nodes; 
		
		
	}	
		
	public
	{
		this()
		{
			m_waveguides.length = 0;
			m_nodes.length = 0;
		}
		
		void addNode(WaveguideNode node)
		{
			m_nodes.length = m_nodes.length + 1;
			m_nodes[m_nodes.length - 1] = node;
		}
		
		void addWaveguide(int ia, int ib, float impedance, float ms)
		{
			auto w = new Waveguide(m_nodes[ia], m_nodes[ib], impedance, ms);
			
			m_waveguides.length = m_waveguides.length + 1;
			m_waveguides[m_waveguides.length - 1] = w;
		}
		
		float nextSample(float incomingEnergy)
		{
			for (int i = 0; i < m_nodes.length; ++i)
			{
				m_nodes[i].energy = 0.f;
				m_nodes[i].accumulate();
			}
			
			m_nodes[0].energy += incomingEnergy;
			
			for (int i = 0; i < m_nodes.length - 1; ++i)
			{
				m_nodes[i].distribute();
			}
			
			return m_nodes[m_nodes.length - 1].energy;			
		}
	}
}