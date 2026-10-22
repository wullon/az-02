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
module demo.fx2.squarify2;

import demo.whatfxneed;
import demo.sphere;


final class Squarify2FX : Effect
{
	private
	{
		Shader m_shader;
		Shader m_shaderRec;
		Shader m_shaderWhite;
		float m_rot = 0.f;
		
		int frames = 0;
	}
	
	public
	{
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "Squarify2FX", timeSpan, priority);
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
			
			float amount = smoothStep(0, 4, lt) - smoothStep(endTime-3,endTime,lt);
			
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1.f, 1.f));
			GL.modelviewMatrix = mat4f.identity;
			
			
			
			GL.disable(GL_BLEND, GL_CULL_FACE, GL_DEPTH_TEST, GL_ALPHA_TEST);
			
			glClearColor(1,1,1,1);
			glClear(GL_COLOR_BUFFER_BIT);
			
			float zoom = powf(3.0f, -sin(progressionf * PI_F));
			GL.scale(vec3f( zoom ));
			GL.rotate(-(90 + 90 * smoothStep(0.25,0.75f, progression)) *  progressionf,0,0,1);
			
			
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
			
			auto fin = step(endTime - 2, endTime, lt);
			
			m_shaderRec.setSampler("tex", lastInterTexture, 0);
			
			vec2f origin = vec2f(0.f);
			
			vec3f getColor(int i, int j)
			{
				int k = (i+1) + (j+1) * 3;
				
				float t = lt * 0.5f;
				
				auto lum = 0.9f + 0.1f * fin;
				auto sat = 0.7f + 0.3f * fin;
				
				switch(k)
				{
					case 0: return hsl(0.f + t, sat, lum);
					case 1: return hsl(0.125f + t, sat, lum);
					case 2: return hsl(0.250f + t, sat, lum);
					case 3: return hsl(-0.125f + t, sat, lum);
					case 4: return vec3f(1.0f, 1.0f, 1.0f);
					case 5: return hsl(0.375f + t, sat, lum);
					case 6: return hsl(0.75f + t, sat, lum);
					case 7: return hsl(0.625f + t, sat, lum);
					case 8: 
					default: return hsl(0.5f + t, sat, lum);
					
				}
			}
			
			for (int i = -50; i < 51; ++i)
				for (int j = -50; j < 51; ++j)
				{
					vec2f pos = vec2f(i,j) * tileSize;
					vec3f c = getColor(i,j);
					Shader shader = (((i % 3) == 0) || ((j % 3) == 0)) ? m_shaderRec : m_shader;
					glColor3fv(c.ptr);
					quad(shader, pos, tileSize);
				}
				
			glColor4f(1,1,1,1);				
			// more squares
			for (int i = -40; i < 5; ++i)
				for (int j = -4; j < 5; ++j)
				if ((i != 0) || (j != 0))
				{
					vec2f pos = vec2f(i,j) * tileSize * 3.f;					
					quad(m_shaderRec, pos, tileSize * 3.f);
				}
		}
		
		override void onMove()
		{
		}
	}
}

