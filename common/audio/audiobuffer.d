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
module audio.audiobuffer;

import audio.types;
import audio.errors;
import util.math;
import sdl.all;
import util.common;
import std.string;
import std.stdio;

enum SamplingMode { NEAREST = 1, 
                    LINEAR = 2 }; 
                    
enum BorderMode { REPEAT = 1, 
                  LOOP = 2 }; 	

// any-length audio buffer
struct AudioBuffer
{
	public
	{
		float[] data;
		
		static AudioBuffer opCall(int l)
		{
			AudioBuffer b;
			b.length = l;
			return b;	
		}
		
		static AudioBuffer opCall(float[] data)
		{
			AudioBuffer b;
			b.data = data.dup;
			return b;	
		}
		
		
		void fill(float value) 
		{ 
			version(UseArrayOperations)
			{
				data[] = value;				
			} 
			else
			{
				for (int i = 0; i < data.length; ++i)
				{
					data[i] = value;
				}
			}
		}	
		
		void clear() 
		{ 
			fill(0.f);
		}	
			
		float * ptr() 
		{
			return data.ptr; 
		}
		
		int length() 
		{ 
			return data.length; 
		}
		
		int length(int l) 
		{ 
			data.length = l; 
			clear();
			return l;
		}
		
		bool inBuffer(int index)
		{
			return ((index >= 0) && (index < data.length));
		}
		
		int getIndex(int i, BorderMode bmode)
		{
			int res = i;
			if (!inBuffer(i)) 
			{
				switch(bmode)
				{
					case BorderMode.LOOP:
						
						res = i % data.length;
						if (res < 0) res += data.length;
						break;
						
					case BorderMode.REPEAT:
						if (i > data.length) 
						{
							res = data.length - 1;
						} else 
						{
							res = 0;						
						}
						break;
												
					default: res = -1;
				}
			}
			assert(res >= 0);
			assert(res < data.length);
			return res;
		}
		
		float sample(float x, SamplingMode smode, BorderMode bmode)
		{
			switch(smode)
			{
				
				case SamplingMode.NEAREST:	
				{			
					final int i = cast(int) x;	
					return data[getIndex(i, bmode)];
				}
					
				case SamplingMode.LINEAR:
				{				
					final int i_part = trunc(x);	
					final float f_part = x - i_part;
					final float d1 = data[getIndex(i_part, bmode)];
					final float d2 = data[getIndex(i_part + 1, bmode)];
					return d1 + (d2 - d1) * f_part;
				}
				
				default: ;
			}
			return float.nan;
		}	
		
		
		// load a WAV file and returns a float array with it
		// warning : merge all channels
		//           does not consider sample rate
		static AudioBuffer opCall(char[] fileName)
		{
			// ensure SDL is loaded
			scope SDL sdl_instance = SDL.instance;
			
			SDL_AudioSpec wav_spec;
			Uint32 wav_length;
			Uint8 *wav_buffer;
			
			/* Load the WAV */
			if( SDL_LoadWAV(toCString(fileName), &wav_spec, &wav_buffer, &wav_length) == null )
			{
				throw new SDLError(format("Could not open %s : %s\n", fileName, toDString(SDL_GetError())));
			}
			
			scope(exit) SDL_FreeWAV(wav_buffer);
			
			float data[];
			int channels = wav_spec.channels;
			
			switch ( wav_spec.format )
			{
				case AUDIO_S16LSB:
				{
					data.length	= wav_length / (channels * short.sizeof);
					short * p = cast(short *) wav_buffer;
					for (int i = 0; i < data.length; ++i)
					{
						real acc = 0;
						for (int j = 0; j < channels; ++j)
						{	
							acc += *p++ / (cast(real)short.max);	
						}
						data[i] = acc / (cast(real)channels);						
					}
					
					break;					
				}
				
				default:
				{
					throw new AudioError("WAV format not supported");
				}
			}
			
			
			
			return AudioBuffer(data);
		}	
	}
}





/*
static AudioBuffer[] readWAV(int channels = 1)
{
	Uint8 *originalBuffer;
	Uint32 origLength;
	SDL_AudioSpec origFormat;			
			
	if( SDL_LoadWAV(toStringz(filename), &origFormat, &originalBuffer, &origLength) is null )
	{
		throw new CouldNotOpenSample(filename);
	}
			
	SDL_AudioCVT cvt;
			
			
	int res = SDL_BuildAudioCVT(&cvt, 
	                            origFormat.format, 
	                            origFormat.channels, 
	                            origFormat.freq, 
	                            AUDIO_S16SYS, 
	                            channels, 
	                            SAMPLE_RATE);
	if (-1 == res)
	{
		throw new CouldNotConvertData( std.string.toString(SDL_GetError()));				
	}
			
	cvt.buf = cast(Uint8 *) malloc(origLength * cvt.len_mult);
	cvt.len = origLength;
	memcpy(cvt.buf, originalBuffer, origLength);
	SDL_FreeWAV(originalBuffer);
			
	this.buffer = cvt.buf;
	this.length = cast(Uint32) lrint(cvt.len * cvt.len_ratio);
	SDL_ConvertAudio(&cvt);	
			
}
*/