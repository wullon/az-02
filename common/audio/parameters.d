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
module audio.parameters;

import audio.types;
import std.conv, std.string;

struct AudioParameter
{
	private
	{
		AudioParameterType m_type;	
	
		union
		{
			char[] m_dataString;	
			int m_dataInt;
			float m_dataFloat;
		}	
	}
	
	public
	{
		static AudioParameter opCall(int i)
		{
			AudioParameter p;
			p.m_dataInt = i;
			p.m_type = AudioParameterType.INTEGER;
			return p;
		}
		
		static AudioParameter opCall(char[] c)
		{
			AudioParameter p;
			p.m_dataString = c;
			p.m_type = AudioParameterType.STRING;
			return p;
		}
		
		static AudioParameter opCall(float f)
		{
			AudioParameter p;
			p.m_dataFloat = f;
			p.m_type = AudioParameterType.FLOAT;
			return p;
		}
		
		AudioParameterType type()
		{
			return m_type;	
		}
		
		int asInt()
		{
			return m_dataInt;
		}
		
		char[] asString()
		{
			return m_dataString;
		}
		
		float asFloat()
		{
			return m_dataFloat;
		}
		
		char[] toString()
		{
			switch(m_type)
			{
				case AudioParameterType.INTEGER:
					return format("%s", asInt());
				
				case AudioParameterType.FLOAT:
					return format("%s", asFloat());				
					
				case AudioParameterType.STRING:
				default:
					return asString();
			}
		}
		
		static AudioParameter fromString(char[] s)
		{
			try
			{
				int i = toInt(s);
				return AudioParameter(i);
			} 
			catch(ConvError e)
			{
				try
				{
					float f = toFloat(s);
					return AudioParameter(f);
				} catch(ConvError e)
				{
					return AudioParameter(s);
				}
			}
		}
	}
}

