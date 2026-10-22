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
module audio.pin;

import audio.types;
import audio.audiodata : AudioData;
import audio.audiomodule : AudioModule;
import audio.modules.smoother : Smoother;
import audio.modules.doubler : Doubler;
import audio.modules.variable : Variable;
import audio.errors;
import util.logger;

class Pin
{
	protected
	{
		AudioData m_data;
		char[] m_name;	
		AudioModule m_owner;
		Pin m_linkedPin; // a pin can be "linked" to another pin (link !is null). "linking" is delegation.
		Object m_user; // "user" pointer
		
		this(AudioModule owner, char[] name, AudioData data)
		{
			m_name = name;
			m_data = data;
			m_owner = owner;
			m_user = null;
		}	
		
		// return true if this could be "linked" to pin 				
		abstract bool canBeLinkedTo(Pin pin);
		
		final void setLink(Pin linkedPin)
		{
			m_owner.lock();
			scope(exit) m_owner.unlock();
			m_linkedPin = linkedPin;
			
		}
	}
	
	public
	{
		final AudioData data()
		{
			if (m_linkedPin is null)
			{
				return m_data;	
			} else
			{
				return m_linkedPin.data();	// recursive call to "linked" pin if any
			}
		}
		
		final char[] name()
		{
			return m_name;	
		}
		
		// description about the pin type
		abstract char[] typeLabel(); 
		abstract void disconnect();
		
		final bool assigned()
		{
			auto d = data();
			return (d !is null);	
		}
		
		final AudioModule owner()
		{
			return m_owner; // owner do not change
		}
		
		final void link(Pin newLink) // link a pin to another pin (NOT a connection)
		{
			if (canBeLinkedTo(newLink))
			{
				setLink(newLink);
			} else
			{
				throw new LinkIsImpossible(this, newLink);
			}			
		}
		
		final void unlink() // erase a link
		{
			setLink(null);
		}
		
		final void clearData()
		{
			data.clear();	
		}
		
		final Object user() 
		{ 
			return m_user; 
		}
		
		final Object user(Object u) 
		{
			return m_user = u; 
		}
	}
}



