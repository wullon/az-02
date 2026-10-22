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
module demo.girl;

import gl.all;
import util.all;
import util.geometry.all;
import demo.demo;

class Girl
{
	private
	{
		const WIDTH = 1120;
		const HEIGHT = 1268;
		int N_PARTS = 9;
		
		GirlPart[] m_parts;
		float m_size;
		vec2f m_pos;
		const PAINTED = true;
		
		float m_mouthX = 0.f, m_mouthY = 0.f;
		Shader m_blitShader, m_blitSimple;
	}
	
	public
	{
		this(vec2f pos, float size, Texture2D noiseTexture)
		{
			m_pos = pos;
			m_size = size;
			m_parts.length = N_PARTS;	
			Shader shader = Demo.loadShader("blitgirl");
			m_blitSimple = Demo.loadShader("blitsquare");
			m_parts[0] = new GirlPart(0, 557, 442, 500, 232, shader);
			m_parts[1] = new GirlPart(1, 45, 432, 533, 270, shader);
			m_parts[2] = new GirlPart(2, 195, 1010, 885, 348, shader);
			m_parts[3] = new GirlPart(3, 174, 695, 398, 348, shader);
			m_parts[4] = new GirlPart(4, 333, 0, 450, 449, shader);
			m_parts[5] = new GirlPart(5, 562, 809, 412, 210, shader);
			m_parts[6] = new GirlPart(6, 754, 12, 268, 442, shader);
			m_parts[7] = new GirlPart(7, 41, 35, 312, 423, shader);
			m_parts[8] = new GirlPart(8, 262, 657, 640, 164, shader);
			m_blitShader = shader;
			
			m_blitShader.setSampler("noise", noiseTexture, 1);
		}
		
		void draw(double gt, float rot)
		{
			glPushMatrix();
				
				
				
				auto random = Random(3232);
				Shader.useDefault();
				m_blitSimple.setSampler("tex", m_parts[1].m_tex, 0);	
				m_blitSimple.set2f("size", vec2f(m_parts[1].m_size.x / 1024.f, m_parts[1].m_size.y / 1024.f));				
				m_blitSimple.set1f("border", 0.02);		
				m_blitSimple.use(); // draw some squares
				float cosgt = cos(gt);
				
				glBegin(GL_QUADS);
				for (int i = 0; i < 1000; ++i)
				{
					float x = 16.f / 9.f * random.nextFloat2;
					float y = 16.f / 9.f * random.nextFloat2;
					if (abs(x) < 0.8f) continue;
					
					float rotation = random.nextFloat * TWO_PI_F + cosgt;
					
					float size = 0.1f + 0.3 * random.nextFloat;
					float sine = sin(rotation) * size;
					float cose = cos(rotation) * size;
					glColor4f(1,1,1,0.5f);
					glTexCoord2f(0,0); glVertex2f(x + sine, y + cose);
					glTexCoord2f(0.5f,0); glVertex2f(x - cose, y + sine);
					glTexCoord2f(0.5f,1); glVertex2f(x - sine, y - cose);
					glTexCoord2f(0,1); glVertex2f(x + cose, y - sine);				
					
				}				
				glEnd();
				
				glTranslatef(m_pos.x, m_pos.y, 0);
				glScalef(m_size / 1200.f, -m_size / 1200.f, 1.f);
				glTranslatef(- 600.f, -600.f, 0.f);
				/*
				glColor4f(0,0,0,1);
				foreach(p ; m_parts)
				{
					p.draw(rot);
				}
				*/
				
				glColor4f(1,1,1,1);
				
				foreach(p ; m_parts)
				{
					p.draw(rot);
				}
			glPopMatrix();
			
		}
		
		float size() { return m_size; }
		float size(float s) { return m_size = s; }
		
		vec2f pos() { return m_pos; }
		vec2f pos(vec2f s) { return m_pos = s; }
		
		float mouthX() { return m_mouthX; }
		float mouthX(float s) { return m_mouthX = s; }
		
		float mouthY() { return m_mouthY; }
		float mouthY(float s) { return m_mouthY = s; }
	}
	
	private class GirlPart
	{
		private
		{
			Texture2D m_tex;
			Shader m_shader;
			vec2i m_pos; 
			vec2i m_size;
			
			const bool COMPRESSION = false;
			
			int index;
		}
		
		public
		{
			this(int n, int x, int y, int width, int height, Shader blit)
			{
				char[] filename = format("data/tex/girl%s%s.jpg", n, PAINTED ? "p" : "");
				m_tex = Demo.loadTexture2D(filename, Texture.IFormat.RGB8, Texture.Filter.LINEAR_MIPMAP_LINEAR, 
				                           Texture.Filter.LINEAR, Texture.Wrap.CLAMP_TO_EDGE, true, COMPRESSION);
				m_pos = vec2i(x, y);
				m_size = vec2i(width, height);
				m_shader = blit;
				
				
				index = n;
			}
			
			void draw(float rotation)
			{
		//		glPushMatrix();
		//		glRotatef(rotation, 0, 0, 1);
				Shader.useDefault();
				m_shader.setSampler("tex", m_tex, 0);
				m_blitShader.set2f("size", vec2f(m_size.x / 1024.f, m_size.y / 1024.f));				
				m_blitShader.set1f("border", 0.01);				
				
				m_shader.use();	
				
				float x1 = m_pos.x;
				float x2 = m_pos.x + m_size.x;
				float y1 = m_pos.y;
				float y2 = m_pos.y + m_size.y;
				auto mouthY = -0.1f + 0.7f * clamp(m_mouthY,0.f, 1.f);
				auto mouthX = -0.5 + 0.8 * clamp(m_mouthX,0.f, 1.f);
				
				if ((index == 3) || (index == 5) || (index == 8))
				{
					vec2f mapTexCoord(float x, float y)
					{
						if (index == 3)
						{
							const float MID = 0.5f;
							float ty = clamp( (x - 0.5f) / (1.0f - 0.5f), 0.f, 1.f) * max(0.f, 1.f - 2.f * abs(y - MID));
							
							float ymod = MID + (y - MID) * (1.f - ty);
							float xmod = 1.f + (x - 1.f) * (1.f - ty);
							
							return vec2f(lerp(x, xmod, mouthX), lerp(y, ymod, mouthY));
						} 
						else if (index == 5)
						{
							const float MID = 0.33f;
							float ty = clamp( (x - 0.5f) / (0.f - 0.5f), 0.f, 1.f) * max(0.f, 1.f - 2.f * abs(y - MID));

							
							float ymod = MID + (y - MID) * (1.f - ty);
							float xmod = 0.f + (x - 0.f) * (1.f - ty);
							
							return vec2f(lerp(x, xmod, mouthX), lerp(y, ymod, mouthY));
						} 
						else // if (index == 8)
						{
							const float MID = 0.5f;
							float ty = clamp( (y - 0.5f) / (1.0f - 0.5f), 0.f, 1.f) * max(0.f, 1.f - 3.f * abs(x - MID));
							float xmod = 0.5f + (x - 0.5f) * (1.f - ty);
							
							float ymod = y + ty * 0.2;
							
							return vec2f(lerp(x, xmod, mouthX), lerp(y, ymod, mouthY));
						}
					}
					
					const int SUBDIV_X = 32;
					const float SUBDIV_X_F = SUBDIV_X;
					const int SUBDIV_Y = 32;
					const float SUBDIV_Y_F = SUBDIV_Y;
					for (int i = 0; i < SUBDIV_X; ++i)
					{
						float ti = i / SUBDIV_X_F;
						float posx = lerp(x1, x2, ti);
						float posxp1 = lerp(x1, x2, ti + 1.f / SUBDIV_X_F);
						
						glBegin(GL_QUAD_STRIP);
						for (int j = 0; j <= SUBDIV_Y; ++j)
						{
							float tj = j / SUBDIV_Y_F;
							float posy = lerp(y1, y2, tj);
							
							vec2f ta = mapTexCoord(ti, tj);
							vec2f td = mapTexCoord(ti + 1.f / SUBDIV_X_F, tj);
							
							glTexCoord2f(ta.x,ta.y);
							glVertex2f(posx, posy);
							glTexCoord2f(td.x,td.y);
							glVertex2f(posxp1, posy);	
						
						}
						glEnd();
					}
					
				} 
				else
				{
					glBegin(GL_QUADS);
						glTexCoord2f(0,0); glVertex2f(x1,y1);
						glTexCoord2f(1,0); glVertex2f(x2,y1);
						glTexCoord2f(1,1); glVertex2f(x2,y2);
						glTexCoord2f(0,1); glVertex2f(x1,y2);				
					glEnd();
				} 
			//	glPopMatrix();
			}
		}
	}
}