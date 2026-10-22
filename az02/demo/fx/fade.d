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
module demo.fx.fade;

import demo.whatfxneed;

class Fade : Effect
{
	private 
	{
		Curve!(vec4f) m_sequence; 
		
		Shader m_shader;
		
		final vec4f getColor(float t)
		{
			 return m_sequence.sampleSecure(t *  (m_sequence.length - 1.f), Curve!(vec4f).Sampling.LINEAR);
		}
	}
	
	public
	{
		this(Demo demo, TimeSpan timeSpan, int priority, vec4f[] sequence)
		{
			super(demo, "Fade", timeSpan, priority);			
			m_sequence = new Curve!(vec4f)(sequence);		
		}
		
		override void onLoad()
		{	
			m_shader = putShader();
		}
		
		override void onDraw() // draw effect
		{
			
			mainFBO.use();
			
			GL.viewport = viewport;
			
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1.f, 1.f));
			GL.modelviewMatrix = mat4f.identity;
			
			GL.disable(GL_DEPTH_TEST, GL_CULL_FACE);
			
			GL.enable(GL_BLEND);			
			
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA,
 			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
 			GL.enable(GL_ALPHA_TEST);
 			glAlphaFunc(GL_GREATER, 0.001f);            
 			
 			m_shader.use();            
 			auto c = getColor(progression);
 			glColor4fv(c.ptr);
 			
 			
 			glBegin(GL_QUADS);
				glVertex2f(-ratio,-1);	
				glVertex2f(+ratio,-1);
				glVertex2f(+ratio,+1);
				glVertex2f(-ratio,+1);				
			glEnd();			
		}		
		
		override void onMove() // move effect
		{
			
		}
	}
	
	
}
