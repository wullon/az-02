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
module gl.renderbuffer;

import derelict.opengl.gl;	
import derelict.opengl.gl20;
import derelict.opengl.extension.ext.framebuffer_object;


final class RenderBuffer {
	
	private 
	{
		GLuint m_handle;
		static RenderBuffer current = null;
	}
	
	public 
	{		
		enum Format 
		{
			RGB, 
			RGBA, 
			DEPTH, 
			DEPTH16, 
			DEPTH24, 
			DEPTH32 
		}
	}
	
	private
	{	
		static const GLint[Format.max + 1] convert_format = 
		[
			GL_RGB,
			GL_RGBA,
			GL_DEPTH_COMPONENT,
			GL_DEPTH_COMPONENT16,
			GL_DEPTH_COMPONENT24,
			GL_DEPTH_COMPONENT32			
		];
	}

	public
	{	
		this(Format fmt, int width, int height) 
		{			
			glGenRenderbuffersEXT( 1, &m_handle );
			assert(glGetError() == 0);			
			bind();			
			glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, convert_format[fmt], width, height);
			assert(glGetError() == 0);			
		}
		
		~this() 
		{			
			if (current is this) 
			{
        		current = null;
    		}    		
    		glDeleteRenderbuffersEXT( 1, &m_handle );
    		assert(glGetError() == 0);
		}		
		
		void bind() 
		{			
			if (current is this) return;
			glBindRenderbufferEXT( GL_RENDERBUFFER_EXT, m_handle );			
			current = this;
			assert(glGetError() == 0);		
		}	
		
		GLuint handle() 
		{		
			return m_handle;					
		}		
	}
}