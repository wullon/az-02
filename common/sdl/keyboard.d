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
module sdl.keyboard;

private import derelict.sdl.sdl;

class SDLKeyboard
{
	private
	{
		bool[SDLK_LAST] key_pressed;
		
		const PRESSED = true, 
		      RELEASED = false;
	}
	
	public
	{
		this()
		{
			key_pressed[] = RELEASED;
		}	
		
		bool isPressed(SDLKey key)
		{
			return (key_pressed[key] == PRESSED);	
		}
		
		void markAsPressed(SDLKey key)
		{
			key_pressed[key] = PRESSED;
		}
		
		void markAsReleased(SDLKey key)
		{
			key_pressed[key] = RELEASED;
		}		
	}
	
}