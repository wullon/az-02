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
module demo.fx2.tunnelizefx;

import demo.whatfxneed;
import sdl.all;

// make a tunnel with the texture
class TunnelizeFX : Effect
{
	private
	{
		Shader m_shader;
		Shader m_shader2;
		double m_angle;		
		float last;
	}
	
	public
	{
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "TunnelizeFX", timeSpan, priority);			
			m_angle = 0.0;
			last = 0.f;
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
			
			m_shader.use();
			
			GL.viewport = viewport;
			
			auto size = 0.8f + volume(Track.KICK) * 5.f;//0.8f * pow!(float)(2.f, -0.8f * sin(globalTime));
			auto angle = m_angle;
			auto const PI_2_ON_3 = 2 * PI_F / 3.0;
			
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1, 1)); // to span all the screen
			GL.modelviewMatrix = mat4f.IDENTITY;
			glClearColor(0,0,0,1);
			glClear(GL_COLOR_BUFFER_BIT);	
			
			float fin = smoothStep(endTime-4, endTime, lt);		
			float amount = smoothStep(0,6,lt);
			float border = 0.022f * (amount - fin);	
			
			
			{
				float inverse = Random().nextBool() ? -1 : 1;
				last += (inverse - last) * 0.002f;
				float an = 60;
				glRotatef( amount * ( an * amount + 60.f * amplify(sin(lt * PI_F * 0.05)) ) * (1.f - fin),0,0,1);
			}
			{
				GL.scale(vec3f(1.f - 0.3 * smoothStep(5, endTime, lt) + fin * 0.3));	
			}
			m_shader.use();
			
			GL.disable(GL_BLEND);
			
			glBegin(GL_QUADS);	
				glColor4f(1,1,1,1);				
				auto MAG = lerp(1.f, 1.50f * 16.f / 9.f, pow(amount - fin,0.7f));
				glTexCoord2f(0,0); glVertex2f(-ratio * MAG , -1 * MAG );	
				glTexCoord2f(1,0); glVertex2f(+ratio * MAG , -1 * MAG );
				glTexCoord2f(1,1); glVertex2f(+ratio * MAG , +1 * MAG );
				glTexCoord2f(0,1); glVertex2f(-ratio * MAG , +1 * MAG );				
			glEnd();
			
			GL.enable(GL_BLEND);
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			           GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			m_shader2.setSampler("tex", lastInterTexture, 0);
			m_shader2.use();
			glBegin(GL_QUADS);	
				glColor4f(0.94,0.95,0.96,amount * (1.f - fin));				
				glTexCoord2f(0,0); glVertex2f(-ratio + ratio * border, -1 + border);	
				glTexCoord2f(1,0); glVertex2f(+ratio - ratio * border, -1 + border);
				glTexCoord2f(1,1); glVertex2f(+ratio - ratio * border, +1 - border);
				glTexCoord2f(0,1); glVertex2f(-ratio + ratio * border, +1 - border);				
			glEnd();
		
		}
		
		override void onMove()
		{
//			m_angle += dt * PI_D * 2.0 * 0.06;
		}
	}
}

