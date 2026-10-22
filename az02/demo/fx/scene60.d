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
module demo.fx.scene60;

import demo.whatfxneed;
import demo.girl;

final class Scene60 : Effect
{
	private
	{
		Girl m_girl;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "Scene60", timeSpan, priority);			
			
		}
		
		
		override void onLoad()
		{
			m_girl = new Girl(vec2f(0,0), 3.f, commonTexture(CommonTexture.PINK_NOISE));
		}
		
		override void onDraw()
		{
			mainFBO.use();
			GL.viewport = viewport;
			
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1.f, 1.f));
			GL.modelviewMatrix = mat4f.identity;
			
			GL.disable(GL_BLEND, GL_DEPTH_TEST, GL_ALPHA_TEST);
 			
			glClearColor(1,1,1,1);
 			glClear(GL_COLOR_BUFFER_BIT);
 			
 			GL.enable(GL_BLEND);
 			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			           GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
 			
			final int a;
			final int * p = &a;
			*p = 4;
			           
			           
			m_girl.pos = vec2f(0.05f, 0.1f);           
 			m_girl.size = 2.5f;//lerp(3.f, 2.5f, progression);
 			auto look_ahead = 0.075f; // should be the attack of this track env
 			m_girl.mouthX = 0.5f + 0.5f * (-0.2f) - volume(Track.GIRL,look_ahead) * 2.f; // look ahead because of the env detector
 			m_girl.mouthY = 0.5f + 0.5f * (-0.9f) + volume(Track.GIRL,look_ahead) * 10.f; // look ahead because of the env detector
 			
 			float girlRotation = 0.f;
 			
 			if (slice == 3) girlRotation = -360.f * progression;
 			
			m_girl.draw(gt, girlRotation);
			
			
			
			
		
			// speech
			{
				GL.enable(GL_BLEND);
 				GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			           GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			           
				void parole(char s[], float x, float y, float width, float alpha, float prog)
				{
					
					auto color1 = vec4f(rgb(0xf86aca),alpha); // rose previously 0xf867ca
					//auto color1 = vec4f(vec3f(1, 0.35,0.5),alpha); // rose previously 0xf867ca
					auto color2 = vec4f(1.0,1.0,1.0, 0.0); // white
					auto color3 = vec4f(0.0,0.0,0.0, alpha); // black
					auto color4 = vec4f(0.0,0.0,0.0, 0.0); // black
			/*		
					auto color1 = vec4f((rgb(0xf80aea) + rgb(0xf86aca)) * 0.5f,alpha); // rose previously 0xf867ca
					auto color2 = vec4f(0.5,0.5,0.5, 1.0); // white
					auto color3 = vec4f(0.0,0.0,0.0, alpha); // black
					auto color4 = vec4f(0.0,0.0,0.0, 0.0); // black
			*/		
					auto const D = 0.014f;
					font.drawString(s, x + D, y - D, width, color3, color4, prog);
					
					font.drawString(s, x, y, width, color1, color2, prog);
					
				}
				
				if (slice == 0) 
				{
					float prog = step(0.444f, endTime, lt) * 1.2f;
					parole("Imaginez-vous", -0.f, -0.6f, 1.3f, 1.f, step(0.f,0.5f,prog));
					parole("sculpter votre corps", -0.f, -0.8f, 2.0f, 1.f, step(0.5f,1.f,prog));	
				}		
				else if (slice == 4) 
				{
					float progr = step(0.f,1.80f, lt) * 1.2f;
					parole("Imaginez-vous", -0.f, -0.6f, 1.3f, 1.f, step(0.f,0.5f,progr));
					parole("sculpter votre corps", -0.f, -0.8f, 2.0f, 1.f, step(0.5f,1.f,progr));	
				}		
				else if (slice == 1)
				{
					float alpha = 1.f - step(0, 2, lb);
					parole("Imaginez-vous", -0.f, -0.6f, 1.3f, alpha, 1.f);
					parole("sculpter votre corps", -0.f, -0.8f, 2.0f, alpha, 1.f);	
				}
				else if (slice == 2)
				{
					float prog = progression * 1.2f;
					parole("Un corps fait de courbes", 0.1f, -0.6f, 2.2f, 1.f, step(0.f,0.5f,prog));
					parole("et de douceur", -0.f, -0.8f, 1.3f, 1.f, step(0.5f,1.f,prog));						
				}
				else if (slice == 5)
				{
					float prog = step(4, endBeat - 4, lb) * 1.2f;
					parole("Un corps fait de courbes", 0.1f, -0.6f, 2.2f, 1.f, step(0.f,0.5f,prog));
					parole("et de douceur", -0.f, -0.8f, 1.3f, 1.f, step(0.5f,1.f,prog));						
				}
				else if (slice == 3)
				{
					float alpha = 1.f - step(0, 2, lb);
					parole("Un corps fait de courbes", 0.1f, -0.6f, 2.2f, alpha, 1.f);
					parole("et de douceur", -0.f, -0.8f, 1.3f, alpha, 1.f);
				}
				else if (slice == 6)
				{
					float prog = progression * 1.2f;
					parole("Imaginez un corps ", -0.f, -0.6f, 1.9f, 1.f, step(0.f,0.5f,prog));					
					parole("de r\x01ve", -0.1f, -0.8f, 0.75f, 1.f, step(0.5f,0.75f,prog));					
				}
				else if (slice == 7)
				{
					
					
					float limit1 = 0.384;
					float limit2 = limit1 + 0.286;
					float limit3 = 1;
					
					if (progression < limit1)
					{
						float prog = step(0,limit1,progression) * 1.2f;		
						
						parole("Des millions de micro-", -0.f, -0.6f, 2.0f, 1.f, step(0.f,0.5f,prog));					
						parole("capsules gorg\x02es d'actifs", -0.0f, -0.8f, 2.2f, 1.f, step(0.5f,0.75f,prog));		
					} else if (progression < limit2)
					{
						float prog = step(limit1,limit2,progression) * 1.2f;		
						
						parole("lib\x03rent progressivement", -0.f, -0.6f, 2.2f, 1.f, step(0.f,0.5f,prog));					
						parole("leur contenu", -0.0f, -0.8f, 1.2f, 1.f, step(0.5f,0.75f,prog));		
					} else if (progression < limit3)
					{
						float prog = step(limit2,limit3,progression) * 1.2f;		
						
						parole("au rythme des", -0.f, -0.6f, 1.5f, 1.f, step(0.f,0.5f,prog));					
						parole("mouvements du corps", -0.0f, -0.8f, 2.1f, 1.f, step(0.5f,0.75f,prog));		
					}								
				}
			}
			
			float eventStart = 0.f;
			if (/*(slice == 0) ||*/ (slice == 2) || (slice == 4) || (slice == 5)|| (slice == 6))
				eventStart = hit(0,1,lt,4);
			
			float event1 = (slice == 1) ? progression * progression * progression : 0.f;				
			float event2 = (slice == 3) ? progression : 0.f;
			float event3 = (slice == 3) ? step(endTime - 2, endTime, lt) : 0.f;
			
			float event6 = (slice == 6) ? sqr(sqr(progression)) : 0.f;
			float event7 = (slice == 7) ? 1.f : 0.f;
			
		//	display(axis(0), axis(1), axis(2));
			blurAmount = 0.5f + 5.f * eventStart + -4.f  * event1 + (event2 - event3) * -2 + event6 * 4 + event7 * -7;
			blurType = -0.4f + 1.4f * eventStart + 1.9f * event1 + event2 * 1.7 + event7 * 0.3;
			
		}
		
		override void onMove()
		{
		}
	}
}

