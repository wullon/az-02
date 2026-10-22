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
module audio.modules.dac;	

private import audio.allwhatmodulesneed;

// basically do nothing, just here to let the renderer have a module front-end
// and use AudioData auto-conversion
class DAC : AudioModule
{		
	private
	{
		float m_totalStat = 0.f;	
		AnalogBuffer m_left;
		AnalogBuffer m_right;
		int m_currentCycle;		
	}
	
	protected
	{	
		override void doProcess()
		{
			auto inData = input(0).data;
			m_left.clear();
			m_right.clear();
			
			if (inData !is null)
			{
				auto buffers = cast(StereoAnalogData)inData;
				if (buffers !is null)
				{				
					m_left.copy(buffers.left);
					m_right.copy(buffers.right);	
				}
			} else
			{
				m_left.clear();
				m_right.clear();
			}
			
		}
	}
	
	public
	{
		this()
		{
			addInput("IN", AudioDataType.STEREO_ANALOG | AudioDataType.UNASSIGNED);
			m_currentCycle = 0;
			m_left.clear();
			m_right.clear();
		}
		
		float * left()
		{
			return m_left.ptr;			
		}
		
		float * right()
		{
			return m_right.ptr;				
		}
		
		void nextBuffer() // warning : there is two types of "cycle"
		{
			final long startCPUCycles = rdtsc();
			updateTo(currentCycle);	
			final long stopCPUCycles = rdtsc();
			final long CPUcycles = stopCPUCycles - startCPUCycles;
			m_totalStat = m_totalStat * 0.99 + CPUcycles * 0.01;
			m_currentCycle++;		
		}
		
		float totalCycles()
		{
			return m_totalStat;
		}		
		
		int currentCycle()
		{
			return m_currentCycle;
		}
		
		double playTime()
		{
			return m_currentCycle * TIME_PER_CYCLE_D;
		}	
	}
}
