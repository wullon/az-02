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
module audio.oggbuffer;

// a buffer which contains the decoded OGG

import util.all;
import audio.oggfile;
import derelict.ogg.vorbisfile;
import derelict.ogg.vorbiscodec;

class OGGBuffer
{
	private
	{
		ubyte[] m_data;
		int m_channels;
		int m_length;
		short * m_ptr;
		
	}
	
	public
	{
		this(OGGFile oggFile)
		{
			load(oggFile);
			m_channels = oggFile.numChannels();
			
		}	
		
		void load(OGGFile oggFile)
		{
			trace(format(">OGGBUffer.load(%s)", oggFile));
			const OGG_BUFFER_SIZE = 1024 * 4;
			
			int p = 0;
			
			int section = 0;
			oggFile.open();
			m_data.length = 44100 + oggFile.requiredSamplesAt44100hz() * 4;
			m_data[] = 0; // fill with zero
			while(true)
			{
				auto ret = ov_read(oggFile.handle, 
							       cast(byte*)(m_data.ptr + p), 
							       OGG_BUFFER_SIZE, 
							       0, // little-endian
							       2, // 16-bits
							       1, // signed
							       &section);
							       
				if ((ret == 0) || (section != 0))
		   		{
			   		debug(1) std.stdio.writefln("OGG buffering finished");
			   		break;	      					
		    	} else if (ret < 0) 
		    	{      
			    	std.stdio.writefln("error decoding OGG = %s", ret);		
			    	break;
		    	} else 
		    	{
			    	p += ret;
			    	//m_data.addArray(buf[0..ret]);	    				
				}
			}		
			oggFile.close();	
			m_length = (p >> 1);
			m_ptr = cast(short*) m_data.ptr;
			trace(format("<OGGBUffer.load(%s)", oggFile));
		}
		
		int numChannels()
		{
			return m_channels;
		}
		 
		// length in samples (does'nt account for mono/stereo)
		int length()
		{
			return m_length;	
		}
		
		void sample(int index, out float lsample, out float rsample)
		{
			if (m_channels == 1)
			{	
				if (cast(uint) index >= m_length)
				{
					lsample = 0.f;	
					rsample = 0.f;	
				} else
				{
					short sample = m_ptr[index];
					rsample = lsample = sample / 32767.0;
				}							   	
			} 
			else // nchannels == 2
			{
				if (cast(uint)(index) >= m_length)
				{
					lsample = 0.f;	
					rsample = 0.f;	
				} else
				{
					lsample = m_ptr[2 * index] / 32767.0;
					rsample = m_ptr[2 * index + 1] / 32767.0;					
				}		
			}   
		}
	}
}
