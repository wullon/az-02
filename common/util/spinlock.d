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
module util.spinlock;

// a sort of fast mutex, intended to SMALL DELAYS only
// spin-wait loop
// NOT re-entrant !!!

import std.cpuid;

final struct Spinlock
{
	enum { UNLOCKED, LOCKED };
	
	private
	{
		int m_counter; 
		
		bool trylock() 
		{
			bool res;
			int * p = &m_counter;
			asm
			{
				mov EAX, UNLOCKED;
				mov ECX, p;
				mov EDX, LOCKED;
				//lock; // not mandatory on mono-processor ! improve speed
				lock;
				cmpxchg [ECX], EDX;
				setz res;		
			}
			return res;
		}
	}
	
	public
	{
		static Spinlock opCall()
		{
			Spinlock res;
			res.m_counter = UNLOCKED;	
			return res;
		}		
		
		void lock()
		{
			while(true)
			{
				if (trylock()) break;				
				if (sse2())
				asm 
				{
					rep; nop; // PAUSE should improve spin-wait loops
				}
			}
		}
		
		void unlock()
		{
			m_counter = UNLOCKED; // no need to lock
		}
	}
}