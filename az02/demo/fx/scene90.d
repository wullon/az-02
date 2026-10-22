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
module demo.fx.scene90;

import demo.whatfxneed;
import demo.bitmapfont;

final class Scene90 : Effect
{
	private
	{
		float accum = 0.f;
		
		Plane m_logo;
		Shader m_putShader;
		BitmapFont m_font;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "Scene90", timeSpan, priority);			
			
		}
		
		override void onLoad()
		{
			
			Texture2D logotex = Demo.loadTexture2D("data/tex/logo03.jpg", Texture.IFormat.RGB8, Texture.Filter.LINEAR_MIPMAP_LINEAR, 
				                                  Texture.Filter.LINEAR, Texture.Wrap.CLAMP_TO_EDGE, true, false);
			
			auto blitlogo2 = Demo.loadShader("blit");
			m_logo = new Plane(logotex, blitlogo2);
			
			
			m_putShader = putShader;
			trace("load greetz font");
			m_font = greetzFont();
		}
		
		
		
		
		override void onDraw()
		{
			mainFBO.use();
			
			
			GL.viewport = viewport;
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1.f, 1.f));
			
			GL.modelviewMatrix = mat4f.identity;
			
			float event1 = pow(1.f - step(0,1,lb), 8.f);
			
			GL.scale(vec3f(1.f));
			glClear(GL_COLOR_BUFFER_BIT);
			
			GL.disable(GL_ALPHA_TEST, GL_DEPTH_TEST, GL_CULL_FACE);
			
			glEnable(GL_POINT_SPRITE);
			glTexEnvi(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);			
			
		   
            GL.pointSize = 30.f * width / 1024.f;
			
			m_logo.pos = vec2f(0,0);
			m_logo.size = ratio * vec2f(2.f, 2.f * 723.f / 1385.f);		
			m_logo.draw(); 
			
			double smoothPulse(double t1, double t2, double t)
			{
				return smoothStep(t1 - 1.5, t1 + 1.5, t) - smoothStep(t2 - 1.5, t2 + 1.5, t);
			}
			
			void showText(char s[], float x, float y, float width, float alpha, float prog)
			{
				auto color1 = vec4f(rgb(0xffffff),alpha); // rose previously 0xf867ca
				auto color2 = vec4f(1.0,1.0,1.0, 0.0); // white
				auto color3 = vec4f(0.0,0.0,0.0, alpha); // black
				auto color4 = vec4f(0.0,0.0,0.0, 0.0); // black
					
				auto const D = 0.010f;
				
				auto fac = 16.f * invRatio/9.f;
				x /= fac;
				y /= fac;
				width /= fac;
				
				m_font.drawString(s, x + D, y + D, width, color3, color4, prog);
				m_font.drawString(s, x - D, y + D, width, color3, color4, prog);
				m_font.drawString(s, x - D, y - D, width, color3, color4, prog);
				m_font.drawString(s, x + D, y - D, width, color3, color4, prog);					
				m_font.drawString(s, x, y, width, color1, color2, prog);					
				
			}
			
			const STR1 = "code, music, design, grumbles: #ponce";
			const STR2 = "pr0n gfx: pandafox";
			const STR3 = "existential help: Graindolium";
			const STR4 = "smoking crack, being picky: wullon";
				
			auto taille = 1.f * powf(2.f, 2.f * axis(0));
			auto bx = 0.2f;
			auto by = 0.2f - 0.29f;
			showText(STR1, bx-0.8 + 0.37 , by-0.14, 1.8, 1.f, step(8,11,lb) - step(28,31,lb));
			showText(STR2, bx-0.92+ 0.07 + 0.09 , by-0.29 ,        1.0, 1.f, step(9,12,lb) - step(29,32,lb));
			showText(STR3, bx-0.9f+ 0.3 + 0.16, by-0.44 ,       1.5, 1.f, step(10,13,lb) - step(30,33,lb));
			showText(STR4, bx-0.7f+ 0.25 + 0.21 ,by-0.59f, 1.77f, 1.f, step(11,14,lb) - step(31,34,lb));
			float eventFin = step(endTime - 16, endTime, lt);
		//	display(axis(0), axis(1));
		/*	
			{	
				GL.enable(GL_BLEND);
				GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
				            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
				            
				m_putShader.use();
				glBegin(GL_QUADS);
					float alpha = eventFin;
					glColor4f(0,0,0,alpha);
					glVertex2f(-ratio, -1.f);
					glVertex2f(+ratio, -1.f);
					glVertex2f(+ratio, +1.f);
					glVertex2f(-ratio, +1.f);
				glEnd();
			}
			
		*/	
			
		
			float logoHit = hit(0,16,lb,4);
			blurAmount = 1.f + 3.f * logoHit - 1.f * eventFin;
			blurType = 0.1 + 0.9 * logoHit - 0.1f * eventFin;
			
		}
		
		vec4f chooseColor()
		{
			return vec4f(1.f, 0.9f, 1.f, 0.03f);
		}
		
		
		override void onMove()
		{
		}
	}
	
	
}

