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
module audio.inputpin;

import audio.types;
import audio.audiodata : AudioData;
import audio.pin : Pin;
import audio.outputpin : OutputPin;
import audio.audiomodule : AudioModule;
import audio.modules.smoother : Smoother;
import audio.modules.doubler : Doubler;
import audio.modules.variable : Variable;
import audio.errors;
import util.logger;

final class InputPin : Pin
{
	private
	{
		AudioDataTypeSet m_expectedType;
		
		void setData(AudioData audioData)
		{
			if (data !is null) data.removeListener(this);
			
			{
				m_owner.lock(); // because the poor owner could be processing
				scope(exit) m_owner.unlock();
				m_data = audioData; 
			}
			
			if (data !is null) data.addListener(this);			
		}
		
		void connectToData(AudioData audioData)
		{
			if (audioData is null)
			{
				setData(null);
			} else
			{			
				auto type = audioData.type();
				
				if (type & m_expectedType)
				{
					setData(audioData); // OK, one of the expected types
				} else
				{
					const BOXING_ENABLED = false;
					
					// the input is not accepted, but we try to "box" it with some convenient modules
					
					// FLOAT => ANALOG 
					// boxing the input into a Smoother	
					if ((BOXING_ENABLED) 
					 && (type == AudioDataType.FLOAT) 
					 && ((m_expectedType & AudioDataType.ANALOG) != 0))
					{
						auto smoother = new Smoother();
						smoother.input("IN").setData(audioData);
						connectToData(smoother.output("OUT").data);
					} else 
					
					// ANALOG => STEREO_ANALOG
					// boxing the input into a Doubler				
					if ((BOXING_ENABLED) 
					&& (type == AudioDataType.ANALOG) 
					&& ((m_expectedType & AudioDataType.STEREO_ANALOG) != 0))
					{
						auto doubler = new Doubler();
						doubler.input("IN").setData(audioData);
						connectToData(doubler.output("OUT").data);
					} else 
					{
						throw new BadInputTypeError(owner.className, name, m_expectedType);
					}
				}			
			}	
		}	
	}
	
	protected
	{
		override bool canBeLinkedTo(Pin pin)
		{
			InputPin inputPin = cast(InputPin)pin;
			
			if (inputPin !is null)
			{
				// pin must not support data types not supported by this
				AudioDataTypeSet src = inputPin.m_expectedType;
				AudioDataTypeSet dest = m_expectedType;
				return (0 == (AudioDataType.ALL & ( src & (!dest))));
				
			} else return false; // linked pin should also be an InputPin
		}
	}
	
	public
	{
		this(AudioModule owner, char[] name, AudioDataTypeSet expectedType)
		{
			super(owner, name, null); // not connected yet
			m_expectedType = expectedType;
		}
		
		AudioDataTypeSet expectedType()
		{
			return m_expectedType;	
		}	
		
		bool isValid()
		{
			if (m_expectedType & AudioDataType.UNASSIGNED)
			{
				return true;
			}			
			return assigned();
		}
		
		void check()
		{
			auto d = data();
			if (d !is null)
			{
				if (!( d.type & m_expectedType ))
				{
					trace("BadInputTypeError");
					throw new BadInputTypeError(owner.className, name, m_expectedType);
				}
			} else
			{
				if (! m_expectedType & AudioDataType.UNASSIGNED)
				{
					trace("UnconnectedPinError");
					throw new UnconnectedPinError(owner.className, name, m_expectedType);
				}
			}
		}
		
		void updateTo(AudioCycle targetCycle)
		{
			debug(2) check;
			auto d = data();
			if (d !is null) d.updateTo(targetCycle);			
		}
		
		void connectTo(OutputPin outputPin)
		{
			connectToData(outputPin.data);			
		}
		
		void connectTo(AudioModule m)
		{
			connectTo(m.output());
		}
		
		void connectTo(float x)
		{
			auto var = new Variable();
			var.value = x;
			connectTo(var.output());
		}
		
		void connectTo(int x)
		{
			connectTo(cast(float)x);	
		}
		
		override void disconnect()
		{
			connectToData(null);	
		}
		
		// description about the pin type
		override char[] typeLabel()
		{
			if (assigned())
			{
				return AudioDataType_to_string(data.type());
			} else
			{
				return AudioDataTypeSet_to_string(m_expectedType);	
			}
		}
	}
}