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
module demo.fx.scene50;

import demo.whatfxneed;

final class Scene50 : Effect
{
	private
	{
		Texture2D m_skin;
		Texture2D m_eye;
		Texture2D m_pupil;
		
		Shader m_skinShader;
		Shader m_eyeShader;
		Shader m_pupilShader;
		
		Eye[] m_eyes;
		const int N_EYES = 10;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "Scene50", timeSpan, priority);		
		}
		
		
		override void onLoad()
		{
			bool compression = true;
			
			m_skin = Demo.loadTexture2D("data/tex/skin.jpg", Texture.IFormat.RGB8, Texture.Filter.LINEAR_MIPMAP_LINEAR, 
				                        Texture.Filter.LINEAR, Texture.Wrap.REPEAT, true, compression);
			m_eye = Demo.loadTexture2D("data/tex/eyep.png", Texture.IFormat.RGBA8, Texture.Filter.LINEAR_MIPMAP_LINEAR, 
				                        Texture.Filter.LINEAR, Texture.Wrap.CLAMP_TO_EDGE, true, false);				                        
			m_pupil = Demo.loadTexture2D("data/tex/pupilp.png", Texture.IFormat.RGBA8, Texture.Filter.LINEAR_MIPMAP_LINEAR, 
				                        Texture.Filter.LINEAR, Texture.Wrap.CLAMP_TO_EDGE, true, false);				                        
			m_pupilShader = Demo.loadShader("blit");			
			m_pupilShader.setSampler("tex", m_pupil, 0);
			m_eyeShader = Demo.loadShader("blit");
			m_eyeShader.setSampler("tex", m_eye, 0);
			m_skinShader = Demo.loadShader("blit");
			m_skinShader.setSampler("tex", m_skin, 0);
			
			m_eyes.length = 11;
			
			
			m_eyes[0] = new Eye(vec2f(0.f,0.f), bpm2time(2.f),0);
			m_eyes[0].rotation = 0.f;
			m_eyes[0].size = 1.4f;
			
			m_eyes[1] = new Eye(vec2f(-0.5f,0.52f), bpm2time(10.2f),1);
			m_eyes[1].rotation = 90.f;
			m_eyes[1].size = 0.8f;
			
			m_eyes[2] = new Eye(vec2f(0.7f,0.55f), bpm2time(11.f),2);
			m_eyes[2].rotation = 180.f;
			m_eyes[2].size = 1.f;
			
			m_eyes[3] = new Eye(vec2f(-0.05f,0.75f), bpm2time(10.4f),3);
			m_eyes[3].rotation = 0.f;
			m_eyes[3].size = 0.6f;
			
			m_eyes[4] = new Eye(vec2f(-0.8f,-0.1f), bpm2time(10.47f),4);
			m_eyes[4].rotation = 45.f;
			m_eyes[4].size = 0.6f;
			
			m_eyes[5] = new Eye(vec2f(+0.8f,-0.3f), bpm2time(10.7f),5);
			m_eyes[5].rotation = -90.f;
			m_eyes[5].size = 1.2f;
			
			m_eyes[6] = new Eye(vec2f(-0.53f,-0.53f), bpm2time(10.8f),6);
			m_eyes[6].rotation = 0.f;
			m_eyes[6].size = 0.9f;
			
			m_eyes[7] = new Eye(vec2f(-1.2f,0.35f), bpm2time(10.0f),7);
			m_eyes[7].rotation = 45.f;
			m_eyes[7].size = 1.f;
			
			m_eyes[8] = new Eye(vec2f(-1.4f,-0.6f), bpm2time(10.31f),8);
			m_eyes[8].rotation = -45.f;
			m_eyes[8].size = 1.5f;
			
			m_eyes[9] = new Eye(vec2f(+0.2f,-0.65f), bpm2time(10.844f),9);
			m_eyes[9].rotation = 0.f;
			m_eyes[9].size = 0.6f;
			
			m_eyes[10] = new Eye(vec2f(+1.4f,0.2f), bpm2time(10.72f),9);
			m_eyes[10].rotation = 90.f;
			m_eyes[10].size = 1.9f;
		}
		
		override void onDraw()
		{
			mainFBO.use();
			GL.viewport = viewport;
			
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1.f, 1.f));
			GL.modelviewMatrix = mat4f.identity;
			float scaleF = pow(2.f, lerp(2.f, 0.f, progression));
			GL.scale(vec3f(scaleF));
			//GL.rotate(lerp(0.f, 20.f, progression),0,0,1);
			
			GL.disable(GL_BLEND, GL_DEPTH_TEST, GL_CULL_FACE);
			
			GL.enable(GL_ALPHA_TEST);
 			glAlphaFunc(GL_GREATER, 0.01f); 
 			           
 			// draw eyes
			GL.enable(GL_BLEND);			
			
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA,
 			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
 			
 			float globalAlpha = 1.f - smoothStep(endBeat - 1, endBeat, lb);
 			{
				m_skinShader.use();
				            
				glColor4f(1, 1, 1, globalAlpha);
				
				float xm = width / 1024.f;
				float ym = height / 1024.f;
				
				glBegin(GL_QUADS);
					glTexCoord2f(-xm,-ym); glVertex2f(-ratio,-1);	
					glTexCoord2f(+xm,-ym); glVertex2f(+ratio,-1);
					glTexCoord2f(+xm,+ym); glVertex2f(+ratio,+1);
					glTexCoord2f(-xm,+ym); glVertex2f(-ratio,+1);				
				glEnd();
			}
			
			
			auto emAmp = 0.001f / scaleF;
				
			Random random = Random();
			
 			for (int i = m_eyes.length - 1; i >= 0; --i) 
			{
				m_eyes[i].seek = random.nextFloat() * emAmp;
				m_pupilShader.use();
				m_eyes[i].drawPupil(globalAlpha);	
				m_eyeShader.use();
				m_eyes[i].drawEye(globalAlpha);	
			}
			            
			float eventStart = hit(0,endTime,lt,2);
			blurAmount = lerp(blurAmount, 1.5f + 3.f * eventStart, globalAlpha);			
			blurType = lerp(blurType, -0.4f + 1.4f * eventStart, globalAlpha);
		
		}
		
		override void onMove()
		{
			
			foreach(e ; m_eyes) 
			{
				e.move(dt);
				
			}
		}
		
		
	}
	
	private class Eye
	{
		public
		{
			vec2f pos;
			
			float size = 1.f;
			float rotation = 0.f;
			float open = 0.f;	
			
			float alpha = 1.f;	
			float m_time;	
			float destOpen = 1.1f;
			float seek = 0.f;
			Random random;
			bool revertX = false;
			bool revertY = false;
			int m_index;
			
			this(vec2f pos, float time, int index)
			{
				this.pos = pos;
				random = Random();
				m_time = time;
				if (index != 0)
				{
					revertX = random.nextBool();
					revertY = random.nextBool();
				}
				m_index = index;
			}
			
			void move(float dt)
			{
				if (lt < m_time) return;
				if (alpha < 0.9999f) 
				{
					alpha += dt;
					alpha = min(1.f, alpha);
				} else
				{	
					if (m_index == 0)
					{
						double lastTime = gt - dt;
						double event1 = minsec(4,37.325);
						if ((event1 < gt) && (event1 > lastTime))
						{
							open = 0.f;	
						}
					}	
					else if (random.nextFloat < dt * 0.2f) 
					{
						open = 0.f;
						
						
					}
					
					
					open += (destOpen - open) * (1.f - exp(-dt * 10.f));
					
				}
			}
			
			void drawPupil(float globalAlpha)
			{
				glPushMatrix();
				glTranslatef(pos.x, pos.y, 0.f);
				auto scaleX = revertX ? -1.f : 1.f;
				auto scaleY = revertY ? -1.f : 1.f;
				float scaleF = 1.f + 0.03f * sin(m_time + lt * 0.4f);
				glScalef(size * scaleX * scaleF, size * scaleY * scaleF, 1.f);
				glRotatef(rotation, 0,0,1);		
			
				float xm = (0.7 + open * 0.3f) * 200.f / 645.f;
				float ym = (0.2 + open * 0.8f) * 0.5f * 387f / 645.f;
				float xdisp = seek;
				float c = 1.f - 0.5f * (1.f - open) * (1.f - open);
				GL.color = vec4f(c,c,c,alpha * globalAlpha);
				glBegin(GL_QUADS);
					
					glTexCoord2f(0.15 - 0.15 * open,0.6f + 0.4f * open);
					glVertex2f(xdisp-xm, -ym);
					glTexCoord2f(0.15 - 0.15 * open,0.4f - 0.4f * open);
					glVertex2f(xdisp-xm, +ym);
					glTexCoord2f(0.85 + 0.15 * open,0.4f - 0.4f * open);
					glVertex2f(xdisp+xm, ym);
					glTexCoord2f(0.85 + 0.15 * open,0.6f + 0.4f * open);
					glVertex2f(xdisp+xm, -ym);		
				glEnd();
				glPopMatrix();
			}
			
			void drawEye(float globalAlpha)
			{
				if (alpha < 0.001f) return;
				glPushMatrix();
				glTranslatef(pos.x, pos.y, 0.f);
				glScalef(size, size, 1.f);
				glRotatef(rotation, 0,0,1);		
				
				
				vec2f mapTexCoord(float x, float y)
				{
					vec2f orig = vec2f(x,y);
					float t = clamp( (x - 0.2f) / (0.8f - 0.2f), 0.f, 1.f);
					float tu = sin(PI_F * t);
					
					float limit = lerp(0.55f, 0.5f, tu);
					
					
					float yup = y * (1.f - 0.25f * 1.f * tu);
					float ydown = y * (1.f + 0.35f * 1.f* tu * (1.f - y));
					
					vec2f cor = vec2f(x, lerp(yup, ydown, smoothStep(limit - 0.01f, limit + 0.01f, y)));
					
					return lerp(cor, orig, open);
				}
				
				float xm = 400.f / 645.f;
				float ym = 0.5f;
				GL.color = vec4f(1,1,1,alpha * globalAlpha);	
				 
			
			
				const int SUBDIV_X = 16;
				const float SUBDIV_X_F = SUBDIV_X;
				const int SUBDIV_Y = 64;
				const float SUBDIV_Y_F = SUBDIV_Y;
				for (int i = 0; i < SUBDIV_X - 1; ++i)
				{
					float ti = i / SUBDIV_X_F;
					float posx = lerp(-xm, xm, ti);
					float posxp1 = lerp(-xm, xm, ti + 1.f / SUBDIV_X_F);
					
					glBegin(GL_QUAD_STRIP);
					for (int j = 0; j <= SUBDIV_Y; ++j)
					{
						float tj = j / SUBDIV_Y_F;
						tj = 4.f * (tj-0.5f)*(tj-0.5f)*(tj-0.5f) + 0.5f;						
						float posy = lerp(ym, -ym, tj);
						vec2f ta = mapTexCoord(ti, tj);
						vec2f td = mapTexCoord(ti + 1.f / SUBDIV_X_F, tj);
						
						glTexCoord2f(ta.x,ta.y);
						glVertex2f(posx, posy);
						glTexCoord2f(td.x,td.y);
						glVertex2f(posxp1, posy);	
					
					}
					glEnd();
				}
				
				glPopMatrix();
			}
		}
	}
}



