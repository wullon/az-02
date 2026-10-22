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
module demo.fx.pandazoom;

import demo.whatfxneed;
import demo.azrfile;
import demo.bitmapfont;
import std.string;


final class Pandazoom : Effect
{
	private
	{
		AZRAnimation m_animation;	
		double m_state = 1.0;
		
		char[][] m_greetz;
		BitmapFont m_font;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "Pandazoom", timeSpan, priority);
		}
		
		override void onLoad()
		{
			m_animation = new AZRAnimation("data/zoom.azr");
			
			m_greetz ~= "MAIN ORGAS";
			m_greetz ~= "UNITED FORCE";
			m_greetz ~= "FAIRLIGHT";
			m_greetz ~= "BLOCKOS";
			m_greetz ~= "CONSPIRACY";
			m_greetz ~= "PORTAL PROCESS";
			m_greetz ~= "TROLLS IN THE SHADOWS";
			m_greetz ~= "ASD";
			m_greetz ~= "NORTHERN DRAGONS";
			m_greetz ~= "mfx";
			m_greetz ~= "REBELS";
			m_greetz ~= "DIVISION ZERO";
			m_greetz ~= "FARBRAUSCH";
			m_greetz ~= "ADAPT";
			m_greetz ~= "ALCATRAZ";
			m_greetz ~= "RGBA";
			m_greetz ~= "GLENZ";
			m_greetz ~= "COCOON";
			m_greetz ~= "NoOoN";
			m_greetz ~= "ORB";
			m_greetz ~= "POPSY TEAM";
			m_greetz ~= "QUITE";
			m_greetz ~= "FREQUENCY";
			m_greetz ~= "EINKLANG.NET";
			
			m_font = greetzFont();			
			
		}
		
		override void onDraw()
		{
			mainFBO.use();
			
			
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			
			GL.viewport = viewport;
			
			GL.projectionMatrix = mat4f.scale(0.99f * vec3f(invRatio, 1.f, 1.f)); // to span all the screen
			
			auto decal = step(endTime - 5, endTime - 4, lt) * 0.168;
			
			GL.modelviewMatrix = mat4f.identity * mat4f.translate(vec3f(decal, 0,0));
			
			
			
			GL.disable( GL_DEPTH_TEST, GL_ALPHA_TEST );
		    GL.enable(GL_BLEND);
		    GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
		                GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			
			
			m_animation.draw(m_state, 0);
			
			
			float EVENT1 = minsec(6,38.323);			
			float EVENT2 = minsec(7,6.776);
			float EVENT3 = minsec(7,35.207);
			
			float hit1 = hit(EVENT1, EVENT1 + 4, gt, 4.f);
			float hit2 = hit(EVENT2, EVENT2 + 4, gt, 4.f);
			float hit3 = hit(EVENT3, EVENT3 + 4, gt, 4.f);
			
			// greetz
			{
				void showText(char s[], float x, float y, float alpha, float prog, float size, float letterSize)
				{
					auto color1 = vec4f(rgb(0xffffff),alpha); // rose previously 0xf867ca
					auto color2 = vec4f(1.0,1.0,1.0, 0.0); // white
					auto color3 = vec4f(0.0,0.0,0.0, alpha); // black
					auto color4 = vec4f(0.0,0.0,0.0, 0.0); // black
						
					auto const D = 0.006f;
					
					float width = m_font.getStringWidth(s) * size / 200.f;
					
					auto fac = 16.f * invRatio/9.f;
					x /= fac;
					y /= fac;
					width /= fac;
					
					m_font.drawString(s, x + D, y + D, width, color3, color4, prog, letterSize);	
					m_font.drawString(s, x - D, y + D, width, color3, color4, prog, letterSize);	
					m_font.drawString(s, x - D, y - D, width, color3, color4, prog, letterSize);	
					m_font.drawString(s, x + D, y - D, width, color3, color4, prog, letterSize);						
					m_font.drawString(s, x, y, width, color1, color2, prog, letterSize);					
					
				}
			
				float greetz = step(128, 128 + 2 * m_greetz.length, lb) * m_greetz.length;
				
				glEnable(GL_ALPHA_TEST);
				glAlphaFunc(GL_GREATER, 0.01f);
				
				for(int i = 0; i < m_greetz.length; ++i)
				{
					int remain = i % 4;
					float beatStart = 128 + i * 2;
					
					float prog = smoothStep(beatStart, beatStart + 1, lb);// - smoothStep(beatStart + 7, beatStart + 8, lb);
					
					if ((prog > 1e-7) && (lb < beatStart + 8))
					{
						float bump = 1.f + 4.f * hit(beatStart, beatStart + 1.f, lb, 2.f);
						vec2f pos = vec2f( 0.f, lerp(1.f, -1.f, (1 + i % 4) / 5.f));
						
						showText(m_greetz[i], pos.x, pos.y, 1.f, prog, bump, (1.f - smoothStep(beatStart + 7, beatStart + 8, lb)) );
					}
				}
			}
						
			blurAmount = 1.5 + 2.f * hit1 + 2.f * hit3 + 2.f * hit2;			
			blurType = 0.05 + 1.f * (hit1 + hit2 + hit3);
			
			
		}
		
		override void onMove()
		{
			//float max = m_animation.length;
			
			float EVENT1 = minsec(6,38.323);
			
			float EVENT3 = minsec(7,35.207);
			
			
			float EVENT4 = minsec(8,3.65); // end
			
			if (gt < EVENT3)
			{
				double prog1 = step(EVENT1, EVENT3, gt);
				
				m_state = 0.5 + prog1 * 34.5;
			}
			else // if (gt < EVENT4)
			{
				double prog = step(EVENT3, EVENT4, gt);
				m_state = 35 + (m_animation.length - 35) * prog;				
			} 
			
			//assert(m_state >= 0.0);
			//assert(m_state < m_animation.length);
			
			m_state = m_animation.length - m_state;
			
			m_state = min(m_state, m_animation.length - 1e-2);
			m_state = max(m_state, 0.0);
			
		}
	}
}

