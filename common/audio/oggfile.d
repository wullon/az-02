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
module audio.oggfile;

import std.c.stdio;
import derelict.ogg.vorbisfile;
import derelict.ogg.vorbiscodec;
import util.all;
import audio.errors;

// BUG : does not support multiple instance of OGGFile

class OGGFile
{
	private
	{
		OggVorbis_File m_file;
		int m_currentSection;
		vorbis_info * m_info;
		vorbis_comment * m_comment;
		
		FILE * m_f;
		char[] m_filename;
		
		bool m_opened;
		bool m_terminated;
		
			
		int section = 0;
		double m_totalTime;
	}	
	
	public
	{
	
		this(char[] filename)
		{
			DerelictVorbisFile.load();
			m_filename = filename;
			m_opened = false;
		}
		
		void open() // load OGG
		{
			if (!m_opened)
			{
				m_f = fopen(toCString(m_filename), toCString("rb"));
				if (m_f is null) 
				{
					throw new AudioError("Cannot open a .ogg with fopen");
				}
				
				int res = ov_open(m_f, &m_file, null, 0);
				if (res == OV_EREAD) throw new AudioError("A read from media returned an error");
				if (res == OV_ENOTVORBIS) throw new AudioError("Bitstream does not contain any Vorbis data");
				if (res == OV_EVERSION) throw new AudioError("Vorbis version mismatch");
				if (res == OV_EBADHEADER) throw new AudioError("Invalid Vorbis bitstream header");
				if (res == OV_EFAULT) throw new AudioError("Vorbis Internal Error");
				m_opened = true;
				m_currentSection = 0;
				m_info = ov_info(&m_file, -1);
				m_comment = ov_comment(&m_file, -1);		
				
				m_totalTime = ov_time_total(&m_file, -1);

				
				trace(format("  total time = %s sec", m_totalTime));
			}
			m_terminated = false;
		}	
		
		int feedBuffer(byte * buffer, int bytes) // returns the amount of 
		{
			// should be open
			if (!m_opened) return -1;
		
			
			auto ret = ov_read(handle, 
			                   buffer,
			                   bytes,
			                   0, // little-endian
			                   2, // 16-bits
			                   1, // signed
			                   &section);
								
			if ((ret == 0) || (section != 0))
	   		{
		   		m_terminated  = true; // terminated
		   		return -1;
	    	} 
	    	else if (ret < 0) 
	    	{      
		    	m_terminated  = true; // error
		    	return -1;
	    	} else 
	    	{
		    	return ret;
			}					
		}
		
		// ask for samples float of data
		void feedBufferAndFillZero(float[] left, float[] right, byte[] buffer, int samples)
		{
			int current = 0;
			byte * ptr = buffer.ptr;
			short * data = cast(short*)(buffer.ptr);
			int i = 0;
			
			while (ptr < ptr + buffer.length)
			{
				int count = feedBuffer(ptr, (buffer.ptr - ptr) + buffer.length); // attempt to read it all
				
				if (count > 0)
				{
					int read = count / 4;
					for (int j = 0; j < read; ++j)
					{
						short l = *data++;
						short r = *data++;
						left[i] = l / 32767.0f;
						right[i] = r / 32767.0f;
						i++;
					}
					ptr = ptr + count;
				} else
				{
					
				/*	for (; i < left.length; ++i)
					{
						left[i] = 0.f;
						right[i] = 0.f;
					}
					return;*/
				}	
			}
		}
				
		~this()
		{
			if (m_opened)
			{
				close();	
			}
		}
		
		void close()
		{
			auto res = ov_clear(&m_file);
			assert(res == 0);
		}	
		
		OggVorbis_File * handle()
		{
			return &m_file;
		}
		
		int numChannels()
		{
			return m_info.channels;
		}
		
		int sampleRate()
		{
			return m_info.rate;
		}
		
		bool terminated()
		{
			return m_terminated;	
		}
		
		char[] filename()
		{
			return m_filename;
		}
		
		int requiredSamplesAt44100hz() // approximation, take more
		{
			return round(44100.0 * m_totalTime);
		}
	}
	
}