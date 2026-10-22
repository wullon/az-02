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
module sdl.semaphore;

import derelict.sdl.sdl;
import sdl.state;


final class Semaphore
{
	private
	{
		SDL_sem * m_handle;			
	}	
	
	public
	{
		this(Uint32 initial_value)
		{
			m_handle = SDL_CreateSemaphore(initial_value);			
			assert(m_handle !is null);
		}
		
		~this()
		{
			SDL_DestroySemaphore(m_handle);
		}
		
		void lock()
		{
			int r = SDL_SemWait(m_handle);
			assert(r == 0);			
		}
		
		void unlock()
		{
			int r = SDL_SemPost(m_handle);
			assert(r == 0);			
		}		
		
		Uint32 value()
		{
			return SDL_SemValue(m_handle);
		}
	
	
	}
	
}