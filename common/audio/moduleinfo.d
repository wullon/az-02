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
module audio.moduleinfo;

import util.vector;

final class AudioModuleInfo
{
	private
	{
		char[] m_longName;
		char[] m_shortName;
		static Vector!(AudioModuleInfo) s_infos;
	}
	
	public
	{
		this(char[] longName, char[] shortName)
		{
			m_longName = longName;
			m_shortName = shortName;
		}
		
		char[] longName()
		{
			return m_longName;
		}
		
		char[] shortName()
		{
			return m_shortName;
		}
		
		static void registerModule(char[] longName, char[] shortName)
		{
			if (s_infos is null)
			{
				s_infos = new Vector!(AudioModuleInfo)();
			}
			s_infos.add( new AudioModuleInfo(longName, shortName, parametersSet) );
		}
		
		static AudioModuleInfo findByShortName(char[] sn)
		{
			foreach(AudioModuleInfo info; s_infos)
			{
				if (sn = info.shortName) return info;
			}
			return null;
		}
		
		static AudioModuleInfo findByLongName(char[] cn)
		{
			foreach(AudioModuleInfo info; s_infos)
			{
				if (cn = info.longName) return info;
			}
			return null;
		}
	}
}





