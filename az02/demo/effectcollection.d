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
module demo.effectcollection;

import demo.effect;
import util.all;

// manage effects

class EffectCollection
{
	private
	{
		Vector!(Effect) m_effects;
		auto const MAX_CONCURRENT_EFFECTS = 4;
		Effect[MAX_CONCURRENT_EFFECTS] m_activeEffects;
		int m_nActiveEffects = 0;
		char[] m_name;
		
		void updateTimingsAndSortEffects(double globalTime, double dt)
		{
			m_nActiveEffects = 0;
			
			foreach (Effect e; m_effects)
			{
				e.updateTiming(globalTime, dt);
				
				if (e.isActive())
				{
					m_activeEffects[m_nActiveEffects++] = e;
					if (m_nActiveEffects >= MAX_CONCURRENT_EFFECTS) 
					{
						assert(false, "Too much concurrent effects, increase MAX_CONCURRENT_EFFECTS");	
					}
				}
			}
			
			// sort active effects to draw with the right order
			// we use a bubble sort since there is few effect at the same time
			for (int i = 0; i < m_nActiveEffects - 1; ++i)
			{
				for (int j = i+1; j < m_nActiveEffects; ++j)
				{	
					if (m_activeEffects[j] < m_activeEffects[i])
					{
						swap(m_activeEffects[j], m_activeEffects[i]);
					}
				}
			}
		} 
	}
	
	public
	{
		this(char[] name)
		{
			m_effects = new Vector!(Effect)();			
			m_name = name;
		}
		
		int opApply(int delegate(ref Effect) dg) 
		{	
			return m_effects.opApply(dg);
		}	
		
		// add an Effect to the demo
		void add(Effect e)
		{
			
			m_effects.add(e);
		}	
		
		int length() { return m_effects.length; }
		
		
		void move(double globalTime, double dt) // find active effects and move them
		{
			updateTimingsAndSortEffects(globalTime, dt);
	//		debug(2) trace(format("move effects from %s (%s of them)", m_name, m_nActiveEffects)); 
			
			// move effects in order
			for (int i = 0; i < m_nActiveEffects; ++i)
			{
				m_activeEffects[i].move();
			}
		}
		
		
		void draw() // draw active effects
		{
	//		debug(2) trace(format("draw effects (%s of them)", m_nActiveEffects)); 
			
			// draw effects in order
			for (int i = 0; i < m_nActiveEffects; ++i)
			{
				m_activeEffects[i].draw();
			}
		}
		
		
	}
}
