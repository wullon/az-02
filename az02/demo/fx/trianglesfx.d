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
module demo.fx.trianglesfx;

import demo.whatfxneed;

class TrianglesFX  :Effect
{
	private
	{
		Shader m_shader;	
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "TrianglesFX", timeSpan, priority);
		}
		
		override void onLoad()
		{
			m_shader = putShader;
		}
		
		override void onDraw()
		{
			mainFBO.use();
			m_shader.use();
			
			Random random = Random(46578);
		
			
			GL.viewport = viewport;
			
			
			GL.projectionMatrix = mat4f.scale(vec3f(1 / ratio, 1, 1)); // to span all the screen
			GL.modelviewMatrix = mat4f.IDENTITY;
			
			GL.disable(GL_DEPTH_TEST, GL_ALPHA_TEST, GL_CULL_FACE);
			GL.enable(GL_BLEND);
		    GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
		                GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
		     
			float globalAlpha = pow(step( 0, 8, lb), 4.f) * 0.5;
			auto range = max(0.05, sqr(progression)) * 2.f;
			
			vec2f pos = vec2f(0.f);
		/*	{
				float prog = step(40,minsec(1,11), gt);
				vec2f plan2pos = lerp( vec2f(+1.f, 0.5f), vec2f(0.0, 0.4f), prog);				
				float prog2 = smoothStep(minsec(1,11), 1.0 * 60 + 39.65, gt );
				pos = plan2pos * prog2;
			}
		*/	
			vec4f colorBorder = vec4f(16.f / 255.f, 16.f / 255.f, 30.f / 255.f, 0.f);
			vec4f colorCenter = vec4f(16.f / 255.f, 16.f / 255.f, 30.f / 255.f,globalAlpha);
			glBegin(GL_TRIANGLES);
			
			for( auto i = 0; i < 1000; i++ )
			{
				
				float angle = random.nextFloat * TWO_PI_F;
				float dist = random.nextFloat * range;
				vec2f p = pos + vec2f(dist * cos(angle), dist * sin(angle));
				
				vec2f a = p + 0.1f * vec2f(random.nextFloat2, random.nextFloat2);
				vec2f b = p + 0.1f * vec2f(random.nextFloat2, random.nextFloat2);
				vec2f c = p + 0.1f * vec2f(random.nextFloat2, random.nextFloat2);
				
				vec2f d = (a + b + c) * 0.33333f;
				float t = random.nextFloat;
			
				
				
				{
					glColor4fv(colorCenter.ptr);
					GL.vertex(d);
					
					glColor4fv(colorBorder.ptr);
					GL.vertex(b);
					GL.vertex(c);
					
					glColor4fv(colorCenter.ptr);
					GL.vertex(d);
					
					glColor4fv(colorBorder.ptr);
					GL.vertex(a);
					GL.vertex(c);
					
					glColor4fv(colorCenter.ptr);
					GL.vertex(d);
					
					glColor4fv(colorBorder.ptr);
					GL.vertex(a);
					GL.vertex(b);
				}
				

			}
			glEnd();
			
		}
		
		override void onMove()
		{
		}
	}
}

