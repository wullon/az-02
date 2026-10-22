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
module demo.fx2.motionblur;

import demo.whatfxneed;
import sdl.all;

// blit the previous image
class MotionBlurFX : Effect
{
	private
	{
		Shader m_shader;
		Shader m_shader2;	
	}
	
	public
	{
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "MotionBlurFX", timeSpan, priority);
			
		}
		
		override void onLoad()
		{
			m_shader = Demo.loadShader("blit");			
			m_shader.setSampler("tex", mainTexture, 0);
			
			m_shader2 = Demo.loadShader("blit");
				
		}
		
		override void onDraw()
		{
			interFBO.use();
			
			
			GL.viewport = viewport;
			
			GL.projectionMatrix = mat4f.scale(vec3f(1 / ratio, 1, 1)); 
			GL.modelviewMatrix = mat4f.IDENTITY;
			
			GL.disable(GL_DEPTH_TEST, GL_ALPHA_TEST, GL_CULL_FACE);
			
			GL.disable(GL_BLEND);
			            
			// current
			m_shader.use();			
					
			glBegin(GL_QUADS);	
				GL.color = vec4f(1.f);
				glTexCoord2f(0,0); glVertex2f(-ratio,-1);	
				glTexCoord2f(1,0); glVertex2f(+ratio,-1);
				glTexCoord2f(1,1); glVertex2f(+ratio,+1);
				glTexCoord2f(0,1); glVertex2f(-ratio,+1);	
			glEnd();
			
			GL.enable(GL_BLEND);
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
					            
			// previous (should make a blur) (FPS dependent !)
			m_shader2.use();			
			float alpha = 0.7f;
			glBegin(GL_QUADS);	
				GL.color = vec4f(1.f, 1.f, 1.f, alpha);				
				glTexCoord2f(0,0); glVertex2f(-ratio,-1);	
				glTexCoord2f(1,0); glVertex2f(+ratio,-1);
				glTexCoord2f(1,1); glVertex2f(+ratio,+1);
				glTexCoord2f(0,1); glVertex2f(-ratio,+1);	
			glEnd();
		}
			
		
		override void onMove()
		{		
		}
	}
}

