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
module util.logger;

import std.stream, std.stdio, std.string;
import util.singleton;


final private class Logger
{
	mixin Singleton;	
	
	private
	{
		Stream m_logFile;

		this()
		{
			try
			{
				m_logFile = new File("log.txt", FileMode.OutNew);
			} catch(StreamException e)
			{
				writefln(e.msg);
				m_logFile = null;	
			}
		}
		
		~this()
		{
			if (m_logFile !is null)
			{
				m_logFile.close();					
			}
		}
	}
	
	
	public
	{
		void trace(char[] message)
		{
			if (m_logFile !is null)
			{
				try
				{
					m_logFile.writefln(message);
				} catch(WriteException e)
				{
					writefln(e.msg);					
				}
			}
		}
	}
}

public static void trace(char[] s)
{
	Logger.instance.trace(s);	
	debug(2) writefln(s);
}
