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
module demo.fx2.squarify;

import demo.whatfxneed;
import demo.sphere;


final class SquarifyFX : Effect
{
	private
	{
		Shader m_shader;
		Shader m_shaderRec;
		Shader m_shaderWhite;
		float m_rot = 0.f;
		
	}
	
	public
	{
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "SquarifyFX", timeSpan, priority);
		}
		
		override void onLoad()
		{
			m_shader = Demo.loadShader("blit");			
			m_shader.setSampler("tex", mainTexture, 0);
			
			m_shaderRec = Demo.loadShader("blit");
		}
		
		override void onDraw()
		{
			interFBO.use();
			
			m_shader.use();
			
			GL.viewport = viewport;
			
			float amount = smoothStep(0, 4, lt) - smoothStep(endTime-1,endTime,lt);
			
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1.f, 1.f));
			GL.modelviewMatrix = mat4f.identity;
			
			
			
			GL.disable(GL_BLEND, GL_DEPTH_TEST, GL_ALPHA_TEST, GL_CULL_FACE);
			
			glClearColor(1,1,1,1);
			glClear(GL_COLOR_BUFFER_BIT);
			
			GL.scale(vec3f(powf(2.7f, sin(progressionf * TWO_PI_F))));
			glRotatef(progression * 360.f * 2.f,0,0,1);
			
			
			vec2f tileSize = vec2f(lerp(2.f * ratio, 2.f, amount), 2.f); 			
			
			void quad(Shader shader, vec2f center, vec2f size)
			{
				shader.use();
				float texx = lerp(0.5f, 0.5f * invRatio, amount);
				
				vec2f a = center + size * vec2f(0.5f, 0.5f);
				vec2f b = center + size * vec2f(-0.5f, 0.5f);
				vec2f c = center + size * vec2f(-0.5f, -0.5f);
				vec2f d = center + size * vec2f(0.5f, -0.5f);
				
				vec2f ta = vec2f(0.5 + texx, 1.f);
				vec2f tb = vec2f(0.5 - texx, 1.f);
				vec2f tc = vec2f(0.5 - texx, 0.f);
				vec2f td = vec2f(0.5 + texx, 0.f);
				
				if (shader == m_shader)
				{
					glColor4f(1,1,1,1);	
				} else
				{
					glColor4f(0.85f,0.83f,0.83f,1);	
				}
				
				glBegin(GL_QUADS);	
									
					glTexCoord2fv(ta.ptr);
					GL.vertex(a);
					glTexCoord2fv(tb.ptr);
					GL.vertex(b);
					glTexCoord2fv(tc.ptr);
					GL.vertex(c);
					glTexCoord2fv(td.ptr);
					GL.vertex(d);
				glEnd();
			}
			
			m_shaderRec.setSampler("tex", lastInterTexture, 0);
			
			vec2f origin = vec2f(0.f);
			
			for (int i = -1; i < 2; ++i)
				for (int j = -1; j < 2; ++j)
				{
					vec2f pos = vec2f(i,j) * tileSize;
					Shader shader = (((i % 3) == 0) && ((j % 3) == 0)) ? m_shader : m_shaderRec;
					quad(shader, pos, tileSize);
				}
				
			// more squares
			for (int i = -1; i < 2; ++i)
				for (int j = -1; j < 2; ++j)
				if ((i != 0) || (j != 0))
				{
					vec2f pos = vec2f(i,j) * tileSize * 3.f;					
					quad(m_shader, pos, tileSize * 3.f);
				}
		}
		
		override void onMove()
		{
		}
	}
}

