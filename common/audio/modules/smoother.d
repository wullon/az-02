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
module audio.modules.smoother;	

import audio.audiomodule;
import audio.allwhatmodulesneed;


// transforms a FLOAT data in ANALOG data (with linear interpolation)
final class Smoother : AudioModule
{
	private
	{
		float m_lastData = 0.f;
	}
			
	protected
	{
		override void doProcess()
		{
			float newdata = (cast(FloatData)(input(0).data)).value;
			
			float * output = (cast(AnalogData)(output(0).data)).buffer.ptr;
			
			float current = m_lastData;			
			
			final float step = (newdata - current) * BUFFER_SIZE_INV_F;
			
			for (int i = 0; i < BUFFER_SIZE; ++i )
			{
				current += step;
				output[i] = current;				
			}
			m_lastData = current;
		}	
	}
	
	public
	{
		override char[] label()
		{
			return "s";
		}
		
		this()
		{
			addOutput("OUT", AudioDataType.ANALOG); // output						
			addInput("IN", AudioDataType.FLOAT);						
		}	
		
	}	
	
}