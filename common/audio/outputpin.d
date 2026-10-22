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
module audio.outputpin;

import audio.types;
import audio.audiodata;
import audio.audiomodule;
import audio.pin;
import audio.modules.smoother;
import audio.modules.doubler;
import audio.modules.variable;
import audio.errors;
import util.logger;


final class OutputPin : Pin
{
	private
	{
		AudioDataType m_type;	
	}
		
	protected
	{
		override bool canBeLinkedTo(Pin pin)
		{
			OutputPin outputPin = cast(OutputPin)pin;
			
			if (outputPin !is null)
			{
				// pin data type must be the same as linked type				
				return (m_type == outputPin.m_type);
				
			} else return false; // linked pin should also be an Output pin
		}
		
	}
	
	public
	{
		this(AudioModule owner, char[] name, AudioDataType type)
		{
			auto data = AudioDataFactory.create(type, this);
			super(owner, name, data);
			m_type = type;
		}	
		
		void setLastCycle(AudioCycle targetCycle)
		{
			data.lastCycle = targetCycle;
		}
		
		// description about the pin type
		override char[] typeLabel()
		{
			return AudioDataType_to_string(m_type);
		}
		
		// disconnect all listening InputPin
		override void disconnect()
		{
			data.disconnect();
		}
	}
}