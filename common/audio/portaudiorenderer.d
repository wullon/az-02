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
module audio.portaudiorenderer;

import derelict.portaudio.pa;
import std.stdio;
import std.string;

import audio.all;
import audio.modules.dac;
import util.all;
import std.c.stdio;
import sdl.all;

extern(C)
{
	int paCallback( void * inputBuffer, 
	                void *outputBuffer,
	                uint framesPerBuffer,
	                PaStreamCallbackTimeInfo* timeInfo,
	                PaStreamCallbackFlags statusFlags,
	                void *userData )
	{
	    PortAudioRenderer renderer = cast(PortAudioRenderer ) userData; 
	    
//	    renderer.setLatency(timeInfo.outputBufferDacTime - timeInfo.currentTime); // update latency information	    


	    renderer.process(outputBuffer, framesPerBuffer);
	    
	/*    if (renderer.m_finished) 
	    {
		    return PaStreamCallbackResult.paAbort;
	    } 
	    else
	    {
	  */  	return PaStreamCallbackResult.paContinue;
   // 	}
	}
}

final class PortAudioRenderer
{
	private
	{	
		DAC m_dac;
		SDL m_sdl;
//		Spinlock m_latencyLock;
		
//		Spinlock m_callbackLock;

		bool m_finished = false;
		
		int m_currentBuffer;
		PaStream * m_stream = null;	
		
	/*	double m_latency = 0.0;
		
		void setLatency(double l)
		{
			m_latencyLock.lock();
			m_latency = l;
			m_latencyLock.unlock();
		}
	*/	
		final void process(void *stream, int len)
		{	
	//		m_callbackLock.lock();
			int requiredSamples = len; 
			int requiredBuffers = requiredSamples >> BUFFER_SIZE_BITS;		
			
			float * L = m_dac.left;
			float * R = m_dac.right;
			
			auto dest = cast(float *) stream;
			for (int i = 0; i < requiredBuffers; ++i)
			{
				dac.nextBuffer();				
				
				for (int j = 0; j < BUFFER_SIZE; ++j)
				{					
					*dest++ = L[j];
					*dest++ = R[j];
				}
			}	
			m_currentBuffer++;
	//		m_callbackLock.unlock();
		}	
		
		void throwPAError(PaError err)
		{
			throw new PortAudioError(format("PortAudio error: %s\n", toDString(Pa_GetErrorText(err))));
		}
		
		void PAcheck(PaError err)
		{
			if (err != PaError.paNoError) throwPAError(err);
		}		
	}
	
	public
	{	
		this()
		{			
			trace(format(">PortAudioRenderer.this()"));
			DerelictPA.load();
			
			auto err = Pa_Initialize();
			PAcheck(err);
			
	//		m_latencyLock = Spinlock();
	//		m_callbackLock = Spinlock();
			
			m_dac = new DAC();
			m_currentBuffer = 0;
			
			err = Pa_OpenDefaultStream( &m_stream,
			                            0,          /* no input channels */
			                            2,          /* stereo output */
			                            paFloat32,  /* 32 bit floating point output */
			                            SAMPLE_RATE,
			                            1024, // or 0 ?
			                            &paCallback, 
			                            cast(void *)this);
			PAcheck(err);
			
			m_sdl = SDL.instance;
			
			trace("<PortAudioRenderer.this()");
		}	
		
		~this()
		{	
			trace(">PortAudioRenderer.~this()");
			m_finished = true;
		//	SDL_Delay(500);
			// Audacity does like that with V19
			// but maybe V19 is broken
			trace("Pa_AbortStream");
			Pa_AbortStream(m_stream);
		//	SDL_Delay(500);
			trace("Pa_CloseStream");
			Pa_CloseStream(m_stream);
		//	SDL_Delay(500);
		//	trace("Pa_Terminate");
			auto err = Pa_Terminate();
			PAcheck(err);
			
			trace("<PortAudioRenderer.~this()");
		}
		
		void play()
		{
			trace(">PortAudioRenderer.play()");
			auto err = Pa_StartStream(m_stream);

			PAcheck(err);
			trace("<PortAudioRenderer.play()");
		}
/*		
		void pause()
		{
			trace(">PortAudioRenderer.pause()");		
			auto err = Pa_AbortStream(m_stream);
			PAcheck(err);
			trace("<PortAudioRenderer.pause()");
		}
*/		
		double playTime()
		{
			return dac.playTime();	
		}
		
		final DAC dac()
		{
			return m_dac;	
		}		
		
		double streamTime()
		{
			return Pa_GetStreamTime(m_stream);
		}
		
		double latency()
		{
/*			m_latencyLock.lock();
			auto res = m_latency;
			//m_latencyLock.unlock();
			//trace(format("latency = %s", res / SAMPLE_RATE_D));
			return res / SAMPLE_RATE_D;
*/			
			PaStreamInfo * info = Pa_GetStreamInfo(m_stream);
			if (info is null) 
			{
				return 0.f;	
			} 
			else
			{
				return info.outputLatency;
				
			}
		}
	}	
}