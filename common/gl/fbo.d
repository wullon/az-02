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
module gl.fbo;


import derelict.opengl.gl;	
import derelict.opengl.glu;	
import derelict.opengl.gl20;
import derelict.opengl.extension.ext.framebuffer_object;
import gl.renderbuffer;
import gl.texture;
import gl.state;
import util.all;

/**
 * Un FBO, c'est un objet auquel on dit dans quelle buffer/texture on va rendre
 * 
 */


class FBO 
{
	public
	{
		enum Component { NONE = 0,
		                 RED = 1, 
		                 GREEN = 2,
		                 BLUE = 4, 
		                 ALPHA = 8,
		                 COLORS = 15,
		                 DEPTH = 16,
		                 COLORS_AND_DEPTH = 31,
		                 ALL =  31}; // no stencil support now	
	}
	
	private 
	{
		
		final class Attachment 
		{
			
			private 
			{				
				FBO m_fbo;
				Texture m_tex = null;
				RenderBuffer m_rb = null;
				GLint m_type = -1;
				GLint m_target = -1;
				GLint m_level = -1;
				GLint m_offset = -1;
			}
			
			public 
			{				
				this(FBO fbo, GLint type) 
				{					
					m_fbo = fbo;
					m_type = type;	
				}		
				
				bool assigned()
				{
					return (m_tex !is null) || (m_rb !is null);
				}	
		
				void attach()
				{
//					trace(">FBO.Attachment.attach()");		
					if (assigned())
					{
						m_fbo.bind();
						switch(m_target)
						{						
							case GL_TEXTURE_1D:
//								trace("GL_TEXTURE_1D");
								glFramebufferTexture1DEXT(GL_FRAMEBUFFER_EXT, m_type, GL_TEXTURE_1D, m_tex.handle, m_level);
								break;
								
							case GL_TEXTURE_2D:
//								trace("GL_TEXTURE_2D");	
						    	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, m_type, GL_TEXTURE_2D, m_tex.handle, m_level);
//						    	trace("OK");		
						    	break;
						    	
						    case GL_TEXTURE_3D:
//						    	trace("GL_TEXTURE_3D");
						    	glFramebufferTexture3DEXT(GL_FRAMEBUFFER_EXT, m_type, GL_TEXTURE_3D, m_tex.handle, m_level, m_offset);
						    	break;
						    	
						   case GL_RENDERBUFFER_EXT:
//						   		trace("GL_RENDERBUFFER_EXT");
						    	glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, m_type, GL_RENDERBUFFER_EXT, m_rb.handle);
						    	break;
						    	
						   default:		
						   		assert(false, "not a target");
						}
						
					}
					GL.check();
//					trace("<FBO.Attachment.attach()");
				}
				
				final void setTarget(RenderBuffer rb) 
				{					
					m_rb = rb;
					m_tex = null;
					m_target = GL_RENDERBUFFER_EXT;
					attach();
				}
				
				final void setTarget(Texture1D t, int level) 
				{				
					m_level = level;
					m_tex = t;
					m_rb = null;
					m_target = GL_TEXTURE_1D;									
					attach();					
					
				}
				
				
				final void setTarget(Texture2D t, int level) 
				{
//					trace(">FBO.setTarget()");	
				
					m_level = level;
					m_tex = t;
					m_rb = null;
					m_target = GL_TEXTURE_2D;	
					attach();
//					trace("<FBO.setTarget()");
				}
				
				
				final void setTarget(Texture3D t, int level, int offset) {
					
					m_level = level;
					m_offset = offset;
					m_tex = t;
					m_rb = null;
					m_target = GL_TEXTURE_3D;		
					attach();		
					
				}
        	
			}
				
			
		}
		
		GLuint handle;
			
		static FBO binded = null;
		static FBO current = null;
		static FBO defaultInstance = null;
		
		Component toWrite;
		bool m_main;
				
		final void bind() 
		{
//			trace(format(">FBO.bind(%s)", handle));
			if (binded !is this) 
			{	
				glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, handle);	
				GL.check;
				binded = this;
			}
//			trace("<FBO.bind");
		}
		
		
		this(bool main) 
		{
			assert(EXTFramebufferObject.isEnabled(), "require EXT_Framebuffer_Object extension");
			
			m_main = main;
			if (main) 
			{				
				handle = 0;
				color.length = 1;
				color[0] = new Attachment(this,  GL_BACK);
				stencil = null;
				depth = null;
				setWrite(Component.RED | Component.GREEN | Component.BLUE | Component.ALPHA);			
				
			} else 
			{				
				glGenFramebuffersEXT(1, &handle);
				GL.check();
				color.length = maxColorAttachments();
				
				for (int i = 0; i < color.length; i++) 
				{				
					color[i] = new Attachment(this,  GL_COLOR_ATTACHMENT0_EXT + i);					
				}							
				
				stencil = new Attachment(this, GL_STENCIL_ATTACHMENT_EXT);			
				depth = new Attachment(this, GL_DEPTH_ATTACHMENT_EXT);
				setWrite(Component.RED | Component.GREEN | Component.BLUE | Component.ALPHA);
			}
			
		}
		
	}
	
	public {
		
		Attachment[] color;
		Attachment stencil;
		Attachment depth;
		
		
		this() 
		{
			this(false);
			//check();				
		}		
		
		~this() {
			
			if (binded is this) binded = null;
			if (current is this) current = null;
    		
    		if (handle != 0) 
    		{
    			glDeleteFramebuffersEXT(1, &handle);
			}
			GL.check();
			
		}
		
		final void setWrite(Component c)
		{
			toWrite = c;	
		}
		
		static final FBO getDefault()
		{
			if (defaultInstance is null)
			{
				defaultInstance = new FBO(true);
			}
			return defaultInstance;	
		}
		
		
		static final int maxColorAttachments() 
		{			
			int max;
			glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS_EXT,&max);
			return max;			
		}
		
		final void use() 
		{
		//	trace(">FBO.use");
			bind();
			if (this !is current) 
			{
				current = this;
				
				glColorMask(cast(bool)(toWrite & Component.RED), 
				            cast(bool)(toWrite & Component.GREEN), 
				            cast(bool)(toWrite & Component.BLUE), 
				            cast(bool)(toWrite & Component.ALPHA)); 
				glDepthMask(cast(bool)(toWrite & Component.DEPTH));		
				glStencilMask(0);			
				
			}	
			
			check();
			GL.check();		
			//trace("<FBO.use");			
		}			
		
		final bool check()
		{
			GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
			switch(status)
			{
				case GL_FRAMEBUFFER_COMPLETE_EXT:
					return true;
				
				case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT:
					assert(false);
				
				case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT:
				    assert(false);
					
    			case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT:
    				assert(false);
					
    			case GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT:
    				assert(false);
					
    			case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT:
    				assert(false);
					
   				case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT:   					
					assert(false);
				
				case GL_FRAMEBUFFER_UNSUPPORTED_EXT:
					assert(false);
					
				default:
					assert(false);
				
			}
		}
		
		final GLenum getBuffer(int i)
		{
			if (m_main)
			{
				static auto const bufferLookup = [GL_BACK, GL_AUX0, GL_AUX1, GL_AUX2];
				return bufferLookup[i];
			} else
			{
				return ( GL_COLOR_ATTACHMENT0_EXT + i );				
			}
		}
		

		final void setDrawBuffers(int[] drawBuffers) // pass here which color buffers to write (in general : 0..3)
		{
			bind();
			assert(drawBuffers.length > 0);
			if (drawBuffers.length == 1)
			{
				glDrawBuffer(getBuffer(drawBuffers[0]));
			} else
			{			
    			GLenum ids[16];    		
    			int n = drawBuffers.length;    		
    			for (int i = 0; i < n; ++i) 
    			{
	    			ids[i] = getBuffer(drawBuffers[i]);
    			}
    			glDrawBuffers(n, ids.ptr);
			}

    		GL.check();
		}
	}
}
