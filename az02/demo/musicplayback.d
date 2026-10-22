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
module demo.musicplayback;

import audio.all;

import audio.modules.oggplayer;
import audio.modules.dac;
import util.all;
import audio.portaudiorenderer;

class MusicPlayback
{
	private
	{
		OGGFile m_oggFile; // whole decrunched audio
		OGGPlayer m_oggPlayer; // audio module
		
		PortAudioRenderer m_audioRenderer;
		
		bool m_musicEnabled;
		double m_initStreamTime;
	}
	
	public
	{
		this(char[] musicFile, bool musicEnabled) // should be an OGG file
		{
			m_musicEnabled = musicEnabled;
			if (musicEnabled)
			{
				scope auto music = new OGGFile(musicFile);
				auto oggBuffer = new OGGBuffer(music); // this is long
				m_oggPlayer = new OGGPlayer(oggBuffer);	
				m_oggPlayer.pause();
				
				m_audioRenderer = new PortAudioRenderer();
				InputPin inp = m_audioRenderer.dac.input("IN");
				inp.connectTo(m_oggPlayer);
			}
		}
		
		void play()
		{
			if (m_musicEnabled)
			{
				m_audioRenderer.play(); // begin music (but ogg is paused)
				m_oggPlayer.play();
				
				m_initStreamTime = m_audioRenderer.streamTime;
			}
		}
		
		void timeTravel(double diffSec)
		{
			if (m_musicEnabled)
			{
				m_oggPlayer.timeTravel(diffSec);
				
			}
		}
		
		void stopMusicPlayback()
		{
			if (m_musicEnabled)
			{
				delete m_audioRenderer; 
			}
		}
		
		double streamTimeOffset(double globalTime)
		{
			if (m_musicEnabled)
			{
				version(Capped)
				{
					return m_audioRenderer.streamTime() - m_initStreamTime - globalTime;				
				} 
				else version(linux)
				{
					return (- m_audioRenderer.latency);				
				} 
				else version(Windows)
				{
					return (m_audioRenderer.streamTime() - m_initStreamTime - m_audioRenderer.latency) - globalTime;				
				} 
				else
				{
					static assert("Must decide how to do sync it for this system");	
					// return 0.f;
				}
			} 
			else 
			{
				return 0;	
			}
		}
	}
}

