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
module demo.fx2.kaleidoscopefx;

import demo.whatfxneed;
import sdl.all;

// make a kaleidoscope with the texture
class KaleidoscopeFX : Effect
{
	private
	{
		Shader m_shader;
		Shader m_shader2;
		double m_angle;		
	}
	
	public
	{
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "KaleidoscopeFX", timeSpan, priority);
			
			m_angle = 0.0;
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
			
			
			auto const PI_2_ON_3 = 2 * PI_F / 3.0;
			
			GL.projectionMatrix = mat4f.scale(vec3f(1 / ratio, 1, 1)); 
			GL.modelviewMatrix = mat4f.IDENTITY;
			
			float EVENT1 = pulse(0,16,lb) * exp3(-lb * 0.1f);
			float EVENT2 = pulse(32,32+16,lb) * exp3(-(lb - 32) * 0.1f);
			float EVENT2bis = pulse(30,32,lb) * step(30,32,lb);
			float EVENT3 = smoothStep(32, 64, lb);
			float EVENT3_fast = smoothStep(32, 33, lb);
			float EVENT3_not_so_fast = smoothStep(32, 35, lb);
			float EVENT4 = step(56, 64, lb);
			float EVENT5 = step(64, 72, lb);
			
			
			auto size = 10.f * sqr(sqr((1.f - step(0,8,lb)))) + 0.5f + 0.5f * EVENT4 + 1.f * EVENT5;
			
			float zelrkjzrehg = step(32, 48, lb) - step(56,64,lb);
			float oscAmp = 0.1f * zelrkjzrehg;
			float oscFreq = 3.f;
			float oscPhase = pulse(32,endBeat,lb) * lt * (3.f + 0.4f * zelrkjzrehg * volumeN(Track.KICK));		
			float angleDist = sin(lb / 4.f) * 0.6f;
				
			vec2f pos(float i, float j)
			{
				vec2f p = vec2f((i - j * 0.5f) * size * 1.11803f, -j * size);				
				
				float distCenter = p.length;
				float fact = 1.f + oscAmp * sin(oscPhase + oscFreq * distCenter);
				float angle = angleDist * distCenter;
				float cosa = cos(angle);
				float sina = sin(angle);				
				p = vec2f(p.x * cosa - sina * p.y, p.x * sina + cosa * p.y);
				return p * fact;
			}
			
			vec2f camDisp = EVENT4 * (pos(0,0));
			
			int coord(int i, int j)
			{
				return (i + j + 333) % 3;
			}
			
			GL.disable(GL_DEPTH_TEST, GL_ALPHA_TEST);
			
			GL.enable(GL_BLEND);
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			            
			glClear(GL_COLOR_BUFFER_BIT);
			
		
				
			
			float kf = smoothStep(0, 4, lb);
			float imgf = 1.f - kf;			
			float origf = imgf;
			float lastf = EVENT3 * 0.9f;
						
			
			vec2f kcenter = vec2f(0.5f + cos(lt * 1.2) * 0.2f, 0.5f + 0.25f * sin(lt * 1.2));
			
			vec2f tex[3];
			auto angle = m_angle + EVENT1 + EVENT2;
					 
			tex[0] = kcenter + 0.25f * vec2f(cos(angle - PI_2_ON_3) / ratio,  sin(angle - PI_2_ON_3));
			tex[1] = kcenter + 0.25f * vec2f( cos(angle) / ratio,  sin(angle));
			tex[2] = kcenter + 0.25f * vec2f( cos(angle + PI_2_ON_3) / ratio,  sin(angle + PI_2_ON_3));
			
			m_shader2.setSampler("tex", lastInterTexture, 0);
	
				
			glPushMatrix();
				float rot = 360.f * smoothStep(0,8,lb) * step(0,64,lb);
				glRotatef(rot,0,0,1);
				
				
		//		glTranslatef(-camDisp.x, -camDisp.y, 0.f);
				
				m_shader.use();
				
				
				void triangle(int i1, int j1, int i2, int j2, int i3, int j3)
				{
					float alpha = kf;
					
					if (   ((i1 == 0) && (j1 == 0))
					    || ((i2 == 0) && (j2 == 0))
					    || ((i3 == 0) && (j3 == 0)))
				    {
					 	alpha -= EVENT4;   
				    } else 
				    {
				//	 	alpha -= EVENT5 ;//- EVENT2bis;   
					 	//if (alpha < 0.f) alpha = 0.f;
				    }

				    glColor4f(1,1,1,alpha);	
							
					glTexCoord2fv(tex[coord(i1,j1)].ptr);
					GL.vertex(pos(i1,j1));	
					glTexCoord2fv(tex[coord(i2,j2)].ptr);
					GL.vertex(pos(i2,j2));				 
					glTexCoord2fv(tex[coord(i3,j3)].ptr);
					GL.vertex(pos(i3,j3));						
				}
				
				glBegin(GL_TRIANGLES);				
				{
					for (int i = -12; i <= 12; ++i)
					{
						for (int j = -12; j <= 12; ++j)
						{								
							triangle(i,j,i+1,j+1,i+1,j);							
							triangle(i,j,i,j+1,i+1,j+1);							 							
						}
					}
				}
				glEnd();
				
				
				
			glPopMatrix();
				
			m_shader.use();
			glBegin(GL_QUADS);	
				glColor4f(1,1,1,origf + EVENT2bis + EVENT4);
				glTexCoord2f(0,0); glVertex2f(-ratio,-1);	
				glTexCoord2f(1,0); glVertex2f(+ratio,-1);
				glTexCoord2f(1,1); glVertex2f(+ratio,+1);
				glTexCoord2f(0,1); glVertex2f(-ratio,+1);	
			glEnd();	         
					            
			// mid-transition
			m_shader2.use();
			
			auto event1_color = vec3f(0.7f,0.7f,0.3f);
			auto event2_color = lerp(vec3f(0.5f,0.0f,1.0f), vec3f(1.0f,0.0f,0.5f), step(32,64,lb));
				
			glBegin(GL_QUADS);	
				GL.color = vec4f(event1_color * EVENT1 + event2_color * EVENT2,  EVENT1 + lastf + EVENT2);
				glTexCoord2f(0,0); glVertex2f(-ratio,-1);	
				glTexCoord2f(1,0); glVertex2f(+ratio,-1);
				glTexCoord2f(1,1); glVertex2f(+ratio,+1);
				glTexCoord2f(0,1); glVertex2f(-ratio,+1);	
			glEnd();
		
			 
			{
				blurAmount = 3.f + 4.5f * EVENT3_not_so_fast - 5.f * EVENT5 + volumeN(Track.PERCUS);
				blurType = 0.6f - EVENT3_fast * 0.3f - 0.2f * EVENT5;
			}
		}
			
		
		override void onMove()
		{
			m_angle += smoothStep(7,9,lb) * dt * 0.5f * ((lb <= 32) ? 1.f : -1.f);			
		}
	}
}

