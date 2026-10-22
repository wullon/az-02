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
module audio.analogbuffer;

import audio.types;
import audio.errors;
import audio.constants;
import util.math;
import sdl.all;


// BUFFER_SIZE audio buffer
struct AnalogBuffer
{
	public
	{
		float[BUFFER_SIZE] data;
		
		void fill(float value) 
		{ 
			version(UseArrayOperations)
			{
				data[] = value;	
				
			} else
			{
				for (int i = 0; i < BUFFER_SIZE; ++i)
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
		
		void copy(AnalogBuffer * b) 
		{
			version(UseArrayOperations)
			{
				data[] = b.data[];				
			} 
			else
			{
				for (int i = 0; i < BUFFER_SIZE; ++i)
				{
					data[i] = b.data[i];
				}		
			}			
		}	
		
		void copy(AnalogBuffer * b, float factor) 
		{
			version(UseArrayOperations)
			{
				data[] = b.data[] * factor;	
			} 
			else
			{				
				for (int i = 0; i < BUFFER_SIZE; ++i)
				{
					data[i] = b.data[i] * factor;
				}
			}
		}	
		
		void copy(AnalogBuffer * b, AnalogBuffer * volume) 
		{
			version(UseArrayOperations)
			{
				data[] = b.data[] * volume.data[];				
			} 
			else
			{
				for (int i = 0; i < BUFFER_SIZE; ++i)
				{
					data[i] = b.data[i] * volume.data[i];
				}	
			}
		}
		
		void add(AnalogBuffer * src) 
		{
			version(UseArrayOperations)
			{
				data[] += src.data[];
				
			} 
			else
			{
				for (int i = 0; i < BUFFER_SIZE; ++i)
				{
					data[i] += src.data[i];
				}	
			}
		}	
		
		void accumulate(AnalogBuffer * b, float volume) 
		{
			version(UseArrayOperations)
			{
				data[] += b.data[] * volume;				
			} 
			else
			{
				for (int i = 0; i < BUFFER_SIZE; ++i)
				{
					data[i] += b.data[i] * volume;
				}	
			}
		}	
		
		void accumulate(AnalogBuffer * b, AnalogBuffer * volume) 
		{
			version(UseArrayOperations)
			{
				data[] += b.data[] * volume.data[];				
			} 
			else
			{
				for (int i = 0; i < BUFFER_SIZE; ++i)
				{
					data[i] += b.data[i] * volume.data[i];
				}		
			}
		}
		
		void multiply(AnalogBuffer * b) 
		{
			version(UseArrayOperations)
			{
				data[] *= b.data[];	
			} 
			else
			{
				for (int i = 0; i < BUFFER_SIZE; ++i)
				{
					data[i] *= b.data[i];
				}
			}
			
		}
	}
}
