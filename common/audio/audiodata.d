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
module audio.audiodata;

import audio.types;
import audio.pin;
import audio.outputpin;
import audio.inputpin;
import audio.analogbuffer;
import audio.constants;
import audio.message;
import audio.audiomodule;

import std.string, std.math;
import util.logger;


class AudioData // audio buffer
{
	private
	{
	//	AudioModule m_writer;	
		OutputPin m_owner; // the pin "owner" of the data
		InputPin[] m_listeners; // the pin listening to the data
		AudioCycle m_lastCycle;
		AudioDataType m_type;
	}
	
	public
	{
		this(AudioDataType type, OutputPin owner)
		{
			m_owner = owner;
			m_lastCycle = -1;
			m_type = type;
			clear();
			m_listeners.length = 0;
		}
		
		abstract void clear();	
		abstract bool hasNaNs();
		abstract bool hasDenormals();	
	
		
		final OutputPin owner()
		{
			return m_owner;
		}		
		
		final void updateTo(AudioCycle currentCycle)
		{
			if (lastCycle < currentCycle)
			{
				if (m_owner !is null)
				{
					m_owner.owner.updateTo(currentCycle);
				}
				lastCycle = currentCycle; // to prevent cycles
			}	
		}
		
		final AudioCycle lastCycle(AudioCycle last)
		{
			return m_lastCycle = last;
		}
		
		final AudioCycle lastCycle()
		{
			return m_lastCycle;
		}
		
		final AudioDataType type()
		{
			return m_type;	
		}
		
		final float asFloat()
		{
			auto u = (cast(FloatData)this);
			return u.value;
		}
		
/*		int asInt()
		{
			if (auto d = cast(IntegerData)this)
			{
				return d.data;	
			}
			
		}
*/		
		final float * asBuffer()
		{
			return (cast(AnalogData)this).buffer.ptr;
		}
		
		final float * asLeftBuffer()
		{
			return (cast(StereoAnalogData)this).left.ptr;
		}
		
		final float * asRightBuffer()
		{
			return (cast(StereoAnalogData)this).right.ptr;
		}
		
		final InputPin[] listeners()
		{
			return m_listeners;	
		}	
		
		final bool addListener(InputPin pin)
		{
			trace(format("%s.addListener", this));
			for (int i = 0; i < m_listeners.length; ++i)
			{
				if (m_listeners[i] is pin) // already a listener
				{
					return false;
				}
			}
			m_listeners.length = m_listeners.length + 1;
			m_listeners[m_listeners.length - 1] = pin;
			return true;
		}
		
		final bool removeListener(InputPin pin)
		{
			trace(format("%s.removeListener", this));
			for (int i = 0; i < m_listeners.length; ++i)
			{
				if (m_listeners[i] is pin) 
				{
					// remove listener 
					for (int j = i; j < m_listeners.length - 1; ++j)
					{
						m_listeners[j] = m_listeners[j+1];
					}
					m_listeners.length = m_listeners.length - 1;
					return true;
				}
			}
			// not present
			return false;
		}
		
		// disconnect all listeners
		final void disconnect()
		{
			InputPin[] listeners = m_listeners.dup;
			for (int i = 0; i < listeners.length; ++i)
			{
				listeners[i].disconnect();
			}
		}
		
		
	}
}

final class FloatData : AudioData
{
	private
	{
		float m_value;	
	}
	
	public
	{
		this(OutputPin owner)
		{
			super(AudioDataType.FLOAT, owner);
		}	
		
		void value(float _value)
		{
			m_value = _value;
		}	
		
		float value()
		{
			return m_value;
		}
		
		override void clear() 
		{
			m_value = 0.f;	
		}
		
		override bool hasNaNs()
		{
			return 0 != isnan(m_value);
		}
		
		override bool hasDenormals()
		{
			return 0 != issubnormal(m_value);
		}
	}
}

final class AnalogData : AudioData
{
	private
	{
		AnalogBuffer m_buffer;
	}
	
	public
	{
		this(OutputPin owner)
		{
			super(AudioDataType.ANALOG, owner);			
		}
		
		final AnalogBuffer * buffer()
		{
			return &m_buffer;
		}
		
		override bool hasNaNs()
		{
			for (int i = 0; i < BUFFER_SIZE; ++i)
			{
				if ( 0 != isnan(m_buffer.data[i]) ) return true;
			}
			return false;
		}
		
		override bool hasDenormals()
		{
			for (int i = 0; i < BUFFER_SIZE; ++i)
			{
				if ( 0 != issubnormal(m_buffer.data[i]) ) return true;
			}
			return false;
		}	
		
		override void clear() 
		{
			m_buffer.clear();
		}
	}
}

final class StereoAnalogData : AudioData
{
	private
	{
		AnalogBuffer m_left;
		AnalogBuffer m_right;
	}
	
	public
	{
		this(OutputPin owner)
		{
			super(AudioDataType.STEREO_ANALOG, owner);			
		}
		
		final AnalogBuffer * left()
		{
			return &m_left;
		}	
		
		final AnalogBuffer * right()
		{
			return &m_right;
		}	
		
		override void clear() 
		{
			m_left.clear();
			m_right.clear();
		}
		
		override bool hasNaNs()
		{
			for (int i = 0; i < BUFFER_SIZE; ++i)
			{
				if ( 0 != isnan(m_left.data[i])) return true;
				if ( 0 != isnan(m_right.data[i])) return true;
			}
			return false;
		}
		
		override bool hasDenormals()
		{
			for (int i = 0; i < BUFFER_SIZE; ++i)
			{
				if ( 0 != issubnormal(m_left.data[i])) return true;
				if ( 0 != issubnormal(m_right.data[i])) return true;
			}
			return false;
		}	
	}
}
/*
final class IntegerData : AudioData
{
	private
	{
		int m_value;	
	}
	
	public
	{
		this(OutputPin owner)
		{
			super(AudioDataType.INTEGER, owner);
		}		
		
		int value(int _value)
		{
			return m_value = _value;
		}	
		
		int value()
		{
			return m_value;
		}		
	}
}*/

final class MessageData : AudioData
{
	private
	{
		const int MAX_MESSAGES = 16;
		const int MESSAGES_MASK = MAX_MESSAGES - 1;
		
		Message[MAX_MESSAGES] m_messages;	
		
		int m_read, m_write;
		
		int next(int index)
		{
			return (index + 1) & MESSAGES_MASK;
		}
	}
	
	public
	{
		this(OutputPin owner)
		{
			super(AudioDataType.MESSAGE, owner);
			m_read = 0;
			m_write = 0;
		}		
		
		int opApply(int delegate(ref Message) dg) 
		{	
			int result = 0;
			for (int i = m_read; i != m_write; i = next(i))
			{
				result = dg(m_messages[i]);	
			}
			return result;
		}
		
		void post(Message m)
		{
			auto n = next(m_write);
			if ( n == m_read) // full
			{
				return; // do nothing
			}
			
			m_messages[m_write] = m;
			m_write = n;
		}	
		
		int count()
		{
			return (MAX_MESSAGES + m_write - m_read) & MESSAGES_MASK;
		}
		
		override void clear()
		{
			m_write = m_read;
		}
		
		override bool hasNaNs()
		{
			return false;
		}
		
		override bool hasDenormals()
		{
			return false;
		}	
	}
}

final class AudioDataFactory
{
	static AudioData create(AudioDataType t, OutputPin owner)
	{
		switch (t)
		{
			case AudioDataType.ANALOG:
				return new AnalogData(owner);
				
			case AudioDataType.STEREO_ANALOG:
				return new StereoAnalogData(owner);
			
			case AudioDataType.FLOAT:
				return new FloatData(owner);
		/*	
			case AudioDataType.INTEGER:
				return new IntegerData(owner);
		*/	
			case AudioDataType.MESSAGE:
				return new MessageData(owner);
				
			default: ;
		}
		return null;
	}
}