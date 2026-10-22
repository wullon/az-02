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
module audio.sdlrenderer;

import sdl.all;
import std.stdio;

import audio.all;
import audio.modules.dac;
import util.all;


extern(C)
{
	private void sdlaudio_callback(void *userdata, Uint8 *stream, int len)
	{
		SDLRenderer renderer = cast(SDLRenderer) userdata;		
		renderer.process(stream, len);
	}
}

// Added the shit to prevent SDL audio deadlock

final class SDLRenderer
{
	private
	{	
		DAC m_dac;
		SDL_AudioSpec mixerAudioFormat;
		bool initialized;
		int currentBuffer;
		SDL m_sdl; 
		
		final void process(Uint8 *stream, int len)
		{	
			if (mixerAudioFormat.channels != 2) return;
			if (mixerAudioFormat.format != AUDIO_S16LSB) return;
			
			int requiredSamples = len >> 2; // 2 bytes per samples, stereo
			int requiredBuffers = requiredSamples >> BUFFER_SIZE_BITS;		
			
			float * L = m_dac.left;
			float * R = m_dac.right;
			
			Sint16 * dest = cast(Sint16 *) stream;
			for (int i = 0; i < requiredBuffers; ++i)
			{
				dac.nextBuffer();				
				
				for (int j = 0; j < BUFFER_SIZE; ++j)
				{					
					*dest++ = float_to_short(L[j]);
					*dest++ = float_to_short(R[j]);
				}
			}	
			currentBuffer++;
		}	
		
		final short float_to_short(float x)
		{
			return cast(short) trunc(short.max * audioClip(x));
		}
	}
	
	public
	{	
		this()
		{			
			trace(format(">SDLRenderer.this()"));
			this.initialized = false;			
			m_sdl = SDL.instance;	
			m_sdl.subSystemInit(SDL_INIT_AUDIO);
			
			SDL_AudioSpec desired;
			
			desired.freq = SAMPLE_RATE;
			desired.format = AUDIO_S16SYS;
			desired.channels = 2;
			desired.samples = 1024;	
			desired.callback = &sdlaudio_callback;
			desired.userdata = cast(void *)this;
			
			
			
			m_dac = new DAC();
			
			if ( SDL_OpenAudio(&desired, &mixerAudioFormat) < 0 )
			{
				char[] msg = format("Unable to open audio : %s", std.string.toString(SDL_GetError()));
				throw new SDLError(msg);  				
			}

			this.initialized = true;
			this.currentBuffer = 0;
			
			trace("<SDLRenderer.this()");
			
//			m_mutex = new Mutex();

//			m_exit = false;
		}		
		
		~this()
		{	
			trace(">SDLRenderer.~this()");
			
			if (initialized)
			{	
				
	//			m_exit = true;
				
	//			m_mutex.lock();
				SDL_PauseAudio(1);				
				SDL_Delay(100);
				SDL_CloseAudio();				
				
	//			m_mutex.unlock();
	//			initialized = false;
			}
			
	//		delete m_mutex;
			
			trace("<SDLRenderer.~this()");
		}
		
		void play()
		{
			trace(">SDLRenderer.play()");
			assert(SDL_PauseAudio !is null);
			SDL_PauseAudio(0);
			trace("<SDLRenderer.play()");
		}
		
		void pause()
		{
			trace(">SDLRenderer.pause()");		
			assert(SDL_PauseAudio !is null);	
			SDL_PauseAudio(1);
			trace("<SDLRenderer.pause()");
		}
		
		double playTime()
		{
			return dac.playTime();	
		}
		
		final DAC dac()
		{
			return m_dac;	
		}
		
	}
	
}