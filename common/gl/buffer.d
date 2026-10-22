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
module gl.buffer;

import derelict.opengl.gl;
import derelict.opengl.gl20;
import gl.state;

class GLBuffer
{
	public
	{
		enum Storage { STATIC,   // data does not change over time
		               DYNAMIC,  // data change over time and is used several times per frame
		               STREAM }; // data used one time per frame
		               
		enum Usage { READ, 
		             COPY, 
		             DRAW }; // used by VBO
		
		GLenum getGLConstantForStorageAndUsage(Storage storage, Usage usage)
		{
			switch(storage)
			{
				case Storage.STATIC:
					switch(usage)
					{
						case Usage.READ: return GL_STATIC_READ;	
						case Usage.COPY: return GL_STATIC_COPY;
						case Usage.DRAW: return GL_STATIC_DRAW;
						default: assert(false);
					}
				case Storage.DYNAMIC:
				
					switch(usage)
					{
						case Usage.READ: return GL_DYNAMIC_READ;	
						case Usage.COPY: return GL_DYNAMIC_COPY;
						case Usage.DRAW: return GL_DYNAMIC_DRAW;
						default: assert(false);
					}
				
				case Storage.STREAM:
				
					switch(usage)
					{
						case Usage.READ: return GL_STREAM_READ;	
						case Usage.COPY: return GL_STREAM_COPY;
						case Usage.DRAW: return GL_STREAM_DRAW;
						default: assert(false);
					}
				default: assert(false);
			}
		}
	}
	
	private
	{
		GLuint m_handle;	
		GLenum m_target;
		static GLBuffer binded = null;
	}	
	
	protected
	{
		void bind()
		{
			if (this !is binded)
			{
				glBindBuffer(m_target, m_handle);
				GL.check;
				binded = this;
			}
		}
		
		void unbind()
		{
			if (this is binded)
			{
				glBindBuffer(m_target, 0);
				binded = null;
			}	
		}
	}
	
	public
	{
		this(GLenum target)
		{
			m_target = target;
			glGenBuffers(1, &m_handle);
			GL.check;
		}
		
		~this()
		{
			 glDeleteBuffers(1, &m_handle);
			 GL.check;
		}
		
		void setData(int size, Storage storage, Usage usage, void * data)
		{
			bind();
			glBufferData(m_target, size, data, getGLConstantForStorageAndUsage(storage, usage));			
		}
		
		void setSubData(int offset, int size, void * data)
		{
			bind();
			glBufferSubData(m_target, offset, size, data);
		}
	}
}