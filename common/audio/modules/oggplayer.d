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
module audio.modules.oggplayer;	

import audio.allwhatmodulesneed;
import audio.oggbuffer;
import derelict.ogg.vorbisfile;
import derelict.ogg.vorbiscodec;
import sdl.all;

// module that play an OGGFile
// the .ogg MUST be 1 or 2 channels and to the library same sample rate



final class OGGPlayer : AudioModule
{		
	private
	{
		OGGBuffer m_oggBuffer;
		int m_index;
		bool m_paused;
		Spinlock m_spinlock;
	}
	
	protected
	{	
		override void doProcess()
		{
			final auto outBuffers = cast(StereoAnalogData)output(0).data;
			
			float * left = outBuffers.left.ptr;
			float * right = outBuffers.right.ptr;
			
			if (!m_paused)
			{
				m_spinlock.lock();				
				for (int i = 0; i < BUFFER_SIZE; ++i)
				{
					float lsample = void, 
					      rsample = void;
					m_oggBuffer.sample(m_index++, lsample, rsample);
			    	left[i] = lsample;
					right[i] = rsample;
				}
				m_spinlock.unlock();
			} 
			else
			{
				for (int i = 0; i < BUFFER_SIZE; ++i)
				{
					left[i] = 0.f;
					right[i] = 0.f;
				}
			}
		}	
	}
	
	public
	{
		this(OGGBuffer buffer)
		{
			addOutput("OUT", AudioDataType.STEREO_ANALOG);			
			m_oggBuffer = buffer;
			m_paused = false;
			m_spinlock = Spinlock();
			m_index = 0;
		}	
		
		void pause()
		{
			m_paused = true;	
		}
		
		void play()
		{
			m_paused = false;	
		}
		
		void timeTravel(double sec)
		{
			int nchannels = m_oggBuffer.numChannels();
			m_spinlock.lock();
			m_index += round(SAMPLE_RATE * sec);
			m_spinlock.unlock();
		}
	}		
}

