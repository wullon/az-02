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
module sdl.sdlimage;

import util.common;
import derelict.sdl.sdl;
import derelict.sdl.image;
import sdl.state;

import std.string;


final class SDLImage 
{
	
	private
	{		
		SDL_Surface * m_handle = null;		
		SDL m_libInstance;		
	}
	
	public
	{
		
		this()
		{
			m_libInstance = SDL.instance;
			DerelictSDLImage.load();
		
		}
		
		this(char[] filename)
		{
			this();
			loadImage(filename);
		}
		
		~this()
		{
			/* free the loaded image */
			if (m_handle !is null) SDL_FreeSurface(m_handle);
		}
		
		void loadImage(char[] filename)
		{
			m_handle = IMG_Load(toCString(filename));
			if (m_handle is null) throw new SDLError(format("Unable to load image %s", filename));
			
			SDL_PixelFormat RGBAformat;
			
			RGBAformat.palette = null;
			RGBAformat.BitsPerPixel = 32;
			RGBAformat.BytesPerPixel = 4;
			RGBAformat.Rloss = 0;
			RGBAformat.Gloss = 0;
			RGBAformat.Bloss = 0;
			RGBAformat.Aloss = 0;
			RGBAformat.Rmask = 0x000000ff;
			RGBAformat.Gmask = 0x0000ff00;
			RGBAformat.Bmask = 0x00ff0000;
			RGBAformat.Amask = 0xff000000;
			RGBAformat.Rshift = 0;
			RGBAformat.Gshift = 8;
			RGBAformat.Bshift = 16;
			RGBAformat.Ashift = 24;
			RGBAformat.colorkey = 0xff000000;
			RGBAformat.alpha = 255;
						
			SDL_Surface * convertedSurface = SDL_ConvertSurface(m_handle, &RGBAformat, SDL_SWSURFACE);
			
			if (convertedSurface is null) throw new SDLError(format("Cannor convert %s in proper RGBA format", filename));
			
			SDL_FreeSurface(m_handle);
			
			m_handle = convertedSurface;
		}
		
		void * data()
		{
			return m_handle.pixels;
		}	
		
		int height()
		{
			return m_handle.h;
		}		
		
		int width()
		{
			return m_handle.w;
		}
		
		void lock()
		{
			if (SDL_MUSTLOCK(m_handle))
			{
				SDL_LockSurface(m_handle);	 // unsafe, suppose it works
			}
		}
		
		void unlock()
		{
			if (SDL_MUSTLOCK(m_handle))
			{
				SDL_UnlockSurface(m_handle);	 // quite unsafe too
			}
		}
	}
}
