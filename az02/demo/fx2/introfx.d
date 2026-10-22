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
module demo.fx2.introfx;

import demo.whatfxneed;

class IntroFX : Effect
{
	private
	{
		Shader m_blitShader;
		Shader m_blitShader2, m_recshader;
		
		
		Eye[] m_eyes;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "IntroFX", timeSpan, priority);			
			
		}
		
		override void onLoad()
		{
			
			
			auto eyeTexture = Demo.loadTexture2D("data/tex/smalleye.png", Texture.IFormat.RGBA8, Texture.Filter.LINEAR_MIPMAP_LINEAR, 
				                              Texture.Filter.LINEAR, Texture.Wrap.CLAMP_TO_EDGE, true, false);
				                              
			auto eyeTexture2 = Demo.loadTexture2D("data/tex/smalleye2.png", Texture.IFormat.RGBA8, Texture.Filter.LINEAR_MIPMAP_LINEAR, 
				                              Texture.Filter.LINEAR, Texture.Wrap.CLAMP_TO_EDGE, true, false);
				
			m_blitShader = Demo.loadShader("blit");
			m_blitShader.setSampler("tex", eyeTexture, 0);
			
			m_blitShader2 = Demo.loadShader("blit");			
			m_blitShader2.setSampler("tex", eyeTexture2, 0);
			
			m_recshader = Demo.loadShader("blit");			
			
			
			
			//scope auto extatiqueSDLImage = new SDLImage();
			scope auto extatiqueImage = new Image("data/tex/extatique.jpg");
			
			const STEP = 13;
			
			
			
			
			
			auto random = Random(687231);
			
			vec3f chooseColor()
			{
				switch (random.nextRange(4))
				{
					case 0: return rgb(	0x9252b7 );
					case 1: return rgb(	0xffffff );
					case 2: return rgb(	0xff00a2 );					
					case 3: 
					default: return rgb(	0x9da8e3 );
				}
			}
			
			{
				int k = 0;
				int count = 0;
				for (int j = 281 - STEP; j < 503 + STEP; j += STEP)
				{
					
					for (int i = 83 - STEP; i <= 954 + STEP; i += STEP)
					{
						int ii = i + (STEP >> 1) * k;// + random.nextRange(12) - 6;
						int jj = j;
						uint pix = extatiqueImage.getPixel(ii,jj);
						
						Eye leftNeighbour = null;
						
						if ((random.nextUint & 0xff00) < (pix & 0xff00))
						{
							float ti = ii / 1024.f;
							float tj = jj / 768.f;
							
							float sizef = ((pix & 0xff00) >> 8) / 255.f;
							Eye eye = new Eye(random, vec2f(lerp(-1.1f,1.1f,ti),
							                      lerp(1.1f,-1.1f,tj)),  sizef * STEP / 300.f, chooseColor(), count++);
							m_eyes ~= eye;
							
							if (leftNeighbour !is null) 
							{
								eye.setLeft(leftNeighbour);
								leftNeighbour.setRight(eye);
							}
							
							leftNeighbour = eye;
						} else
						{
							leftNeighbour = null;	
						}
					}
					k = 1 - k;
				}	
			}
			
			// randomize the array
			for (int i = 0; i < m_eyes.length; ++i)
			{
				if (random.nextRange(4) == 0)
				{
					int j = random.nextRange(m_eyes.length);
					swap(m_eyes[i].m_count, m_eyes[j].m_count);
					swap(m_eyes[i].m_random, m_eyes[j].m_random);
				}
			}
		}
		
		override void onDraw()
		{
			interFBO.use();
			
			GL.viewport = viewport;
			
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1.f, 1.f));
			GL.modelviewMatrix = mat4f.identity;
			
			GL.disable(GL_DEPTH_TEST, GL_CULL_FACE);
			
			GL.enable(GL_ALPHA_TEST);
			glAlphaFunc(GL_GREATER, 0.01f); 
			
			GL.enable(GL_BLEND);
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			
			float globalAlpha = (1 - step(28.f,30.f,lt));
			{           
				float alpha = globalAlpha;
				
				putShader.use();
				
				glBegin(GL_QUADS);	
					glColor4f(0,0,0,alpha);				
					glVertex2f(-ratio,-1);	
					glVertex2f(+ratio,-1);
					glVertex2f(+ratio,+1);
					glVertex2f(-ratio,+1);				
				glEnd();
			}		
			
			{
				GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
				// motion blur
				// previous (should make a blur) (FPS dependent !)
				m_recshader.setSampler("tex", lastInterTexture, 0);
				m_recshader.use();			
				float alpha = 0.9f * (1 - step(26.f,30.f,lt));
				const FACT = 1.003f;
				glBegin(GL_QUADS);	
					GL.color = vec4f(0.95f, 0.9f, 1.f, alpha);				
					glTexCoord2f(0,0); glVertex2f(-ratio * FACT,-1* FACT);	
					glTexCoord2f(1,0); glVertex2f(+ratio* FACT,-1* FACT);
					glTexCoord2f(1,1); glVertex2f(+ratio* FACT,+1* FACT);
					glTexCoord2f(0,1); glVertex2f(-ratio* FACT,+1* FACT);	
				glEnd();
			}            
			            
			            
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			            
			m_blitShader.use();
			
			float partAlpha = (1 - step(26.f,28.f,lt));
			
			
			glBegin(GL_QUADS);
			foreach (ref e; m_eyes)
			{
				e.draw(partAlpha);				
			}
			glEnd();			
			            
			m_blitShader2.use();
			
			glBegin(GL_QUADS);
			foreach (ref e; m_eyes)
			{
				e.draw(partAlpha);				
			}
			glEnd();
			
			
			{           
				float alpha = 1.f - step(0,4,lb);
				
				putShader.use();
				
				glBegin(GL_QUADS);	
					glColor4f(0,0,0,alpha);				
					glVertex2f(-ratio,-1);	
					glVertex2f(+ratio,-1);
					glVertex2f(+ratio,+1);
					glVertex2f(-ratio,+1);				
				glEnd();
			}		
			
			float changeBlur = step(28,30.f, lt);
			blurAmount = lerp(2.f + volumeN(Track.GRAINDO) * 4.f, blurAmount, changeBlur);
			blurType = lerp(0.5f, blurType, changeBlur);
		}
		
		override void onMove()
		{
			
			double viscoFactor = 1.f - exp(-dt * 3.f);
			double viscoPosFactor = 1.f - exp(-dt * 0.5f);
			
			float changeBlur = step(27,28.f, lt);
			
			float countOpen = m_eyes.length * (clamp(volumeN(Track.GRAINDO_ACCUM) * 2.2f, 0.f, 1.f) - changeBlur);
			foreach (ref e; m_eyes)
			{
				e.move(dt, viscoFactor, viscoPosFactor, countOpen);
			}
		}
	}
	
	private class Eye
	{
		private
		{
			vec2f m_pos;
			vec2f m_destPos;
			float m_size;	
			float m_destSize;
			Random m_random;			
			vec3f m_color;
			float m_closed;
			float m_alpha;
			float m_draw2Alpha;
			Eye m_right = null;
			Eye m_left = null;
			int m_count = 0;
		}
		
		public
		{
			
			void draw(float globalAlpha)
			{
				float xmin = m_pos.x - 0.5f * m_size;
				float xmax = m_pos.x + 0.5f * m_size;
				float ymin = m_pos.y - 0.5f * m_size;
				float ymax = m_pos.y + 0.5f * m_size;
				
				vec4f c = vec4f(m_color, m_alpha * globalAlpha);
				glColor4fv(c.ptr);
				glTexCoord2f(0,1);
				glVertex2f(xmin, ymin);
				glTexCoord2f(1,1);
				glVertex2f(xmax, ymin);
				glTexCoord2f(1,0);
				glVertex2f(xmax, ymax);
				glTexCoord2f(0,0);	
				glVertex2f(xmin, ymax);			
			}
			
			void draw2(float globalAlpha)
			{
				float xmin = m_pos.x - 0.5f * m_size;
				float xmax = m_pos.x + 0.5f * m_size;
				float ymin = m_pos.y - 0.5f * m_size;
				float ymax = m_pos.y + 0.5f * m_size;
				
				float xmin2 = m_pos.x - m_size;
				float xmax2 = m_pos.x + m_size;
				float ymin2 = m_pos.y - m_size;
				float ymax2 = m_pos.y + m_size;
				
				
				vec4f c = vec4f(m_color, m_draw2Alpha * globalAlpha);
				glColor4fv(c.ptr);
				
				glTexCoord2f(0,1);
				glVertex2f(xmin, ymin);
				glTexCoord2f(1,1);
				glVertex2f(xmax, ymin);
				glTexCoord2f(1,0);
				glVertex2f(xmax, ymax);
				glTexCoord2f(0,0);	
				glVertex2f(xmin, ymax);			
			}
			
			this(ref Random random, vec2f pos, float size, vec3f color, int count)
			{
				m_destPos = pos;// + size * 0.2 * random.nextGauss2f();
				
				m_closed = 1.f;
				
				m_destPos = pos;
				m_pos = pos * 3.f;
				
				m_color = color;
				m_destSize = size * pow(2.f, random.nextGaussf());
				m_size = m_destSize;
				m_random = Random(random.nextInt);
				m_alpha = 0.f;
				m_count = count;
			}
			
			void move(float dt, float viscoFactor, float viscoFactorPos, float countOpen)
			{
				if (countOpen < m_count)
				{
					m_closed = 1.f;
				} 
				else				
				{
					if (m_random.nextFloat < dt * 0.2f) 
					{
						m_closed = 1.f;
					}
					
					m_closed += (0.f - m_closed) * viscoFactor;
					
				}
				
				m_alpha = 1.f - max((m_closed - 0.5f) * 2.f, 0.f);
				m_draw2Alpha = m_alpha * min(1.f, 2.f * m_closed);
					
				auto dest = m_destPos + 0.05f * vec2f(m_random.nextGaussf, m_random.nextGaussf);
				
				if (m_right !is null) dest += 0.02f * (m_right.m_pos - m_pos);
				if (m_left !is null) dest += 0.02f * (m_left.m_pos - m_pos);
				  
				if (countOpen >= m_count)
				{         
					m_pos += (dest - m_pos) * viscoFactorPos;
				}
			}
			
			void setRight(Eye e)
			{
				m_right = e;
			}
			
			void setLeft(Eye e)
			{
				m_left = e;
			}
		}
			
	}
}

