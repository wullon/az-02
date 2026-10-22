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
module util.tokenstream;

import util.vector, util.token;
import std.stream;

class TokenStreamException : Exception
{	
	this(char[] msg)
	{
		super(msg);
	}
}

class TokenStream
{
	private
	{
		Vector!(Token) m_tokens;
		int m_index;	
		
	}
	
	public
	{
		this(char[] filename)
		{
			m_tokens = new Vector!(Token)();
			
			try
			{
				auto scope file = new BufferedFile(filename);
				int nol = 0;			
			
				while (!file.eof()) 
				{
					char[] line = file.readLine();	
					++nol;
				
					foreach (s; std.regexp.split(line, "\\s+"))
					{		 			
						// eliminate empty token
						if (s != "") m_tokens.add(new Token(s, nol));
					}
				}
				file.close();
			} catch(StreamException e)
			{
				throw new TokenStreamException(e.msg);
			}
			m_index = 0;
		}	
		
		Token nextToken()
		{
			if(m_index < m_tokens.length)
			{
				Token t = m_tokens[m_index++];
				return t;
			}	
			return null;                            
		}
		
		Token currentToken()
		{
			if(m_index < m_tokens.length)
			{
				Token t = m_tokens[m_index];
				return t;
			}	
			return null;                            
		}		
	}

}