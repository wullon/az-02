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
module demo.fx.scene45;

import demo.whatfxneed;
import demo.flame.all;

// scene PTFF

final class Scene45 : Effect
{
	private
	{
		Flame[4] m_flame;
		Shader m_scene45Shader;
		Shader m_whiteShader;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "Scene45", timeSpan, priority);			
			
		}
		
		
		override void onLoad()
		{
			Texture2D partex = Demo.loadTexture2D("data/tex/particle3.png", Texture.IFormat.RGBA8, Texture.Filter.LINEAR_MIPMAP_LINEAR,
			                                      Texture.Filter.LINEAR, Texture.Wrap.CLAMP_TO_EDGE, true, false);
			                                      
			{			                                      
				WeightedVariation[] variations;
				variations.length = 3;
				
				variations[0] = new WeightedVariation(new LinearVariation(), vec4f(0.f), 2.f, new AffineTransform(1,0,0,0,1,0), new AffineTransform(1,0,0,0,1,0));			
				variations[1] = new WeightedVariation(new LinearVariation(), vec4f(0.f), 2.f, new AffineTransform(1,0,0,0,1,0), new AffineTransform(1,0,0,0,1,0));			
				variations[2] = new WeightedVariation(new LinearVariation(), vec4f(0.f), 2.f, new AffineTransform(1,0,0,0,1,0), new AffineTransform(1,0,0,0,1,0));			
				
				m_flame[0] = new Flame(variations, partex);
			}
			
			{			                                      
				WeightedVariation[] variations;
				variations.length = 3;
				
				variations[0] = new WeightedVariation(new SphericalVariation(), vec4f(0.f), 2.f, new AffineTransform(1,0,0,0,1,0), new AffineTransform(1,0,0,0,1,0));			
				variations[1] = new WeightedVariation(new SphericalVariation(), vec4f(0.f), 2.f, new AffineTransform(1,0,0,0,1,0), new AffineTransform(1,0,0,0,1,0));			
				variations[2] = new WeightedVariation(new SphericalVariation(), vec4f(0.f), 2.f, new AffineTransform(1,0,0,0,1,0), new AffineTransform(1,0,0,0,1,0));			
				
				m_flame[1] = new Flame(variations, partex);
			}
			
			{			                                      
				WeightedVariation[] variations;
				variations.length = 3;
				
				variations[0] = new WeightedVariation(new EyefishVariation(), vec4f(0.f), 2.f, new AffineTransform(1,0,0,0,1,0), new AffineTransform(1,0,0,0,1,0));			
				variations[1] = new WeightedVariation(new EyefishVariation(), vec4f(0.f), 2.f, new AffineTransform(1,0,0,0,1,0), new AffineTransform(1,0,0,0,1,0));			
				variations[2] = new WeightedVariation(new EyefishVariation(), vec4f(0.f), 2.f, new AffineTransform(1,0,0,0,1,0), new AffineTransform(1,0,0,0,1,0));			
				
				m_flame[2] = new Flame(variations, partex);
			}
			
			{			                                      
				WeightedVariation[] variations;
				variations.length = 3;
				
				variations[0] = new WeightedVariation(new HorseShoeVariation(), vec4f(0.f), 2.f, new AffineTransform(1,0,0,0,1,0), new AffineTransform(1,0,0,0,1,0));			
				variations[1] = new WeightedVariation(new HorseShoeVariation(), vec4f(0.f), 2.f, new AffineTransform(1,0,0,0,1,0), new AffineTransform(1,0,0,0,1,0));			
				variations[2] = new WeightedVariation(new HorseShoeVariation(), vec4f(0.f), 2.f, new AffineTransform(1,0,0,0,1,0), new AffineTransform(1,0,0,0,1,0));			
				
				m_flame[3] = new Flame(variations, partex);
			}
			
			m_scene45Shader = Demo.loadShader("scene45");
			m_scene45Shader.setSampler("tex", commonTexture(CommonTexture.STARS), 0);
			m_whiteShader = Demo.loadShader("blit");
		}
		
		override void onDraw()
		{
			mainFBO.use();
			
			
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			GL.viewport = viewport;
			
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1, 1)); 
			GL.modelviewMatrix = mat4f.identity;
			
			
			           
			
			m_scene45Shader.set1f("time", lt);
			m_scene45Shader.use();
			
			GL.disable(GL_BLEND, GL_DEPTH_TEST, GL_ALPHA_TEST);
			
			glBegin(GL_QUADS);	
				glColor4f(1,1,1,1);
				glTexCoord2f(-ratio,-1); glVertex2f(-ratio,-1);	
				glTexCoord2f(ratio,-1); glVertex2f(+ratio,-1);
				glTexCoord2f(ratio,1); glVertex2f(+ratio,+1);
				glTexCoord2f(-ratio,1); glVertex2f(-ratio,+1);	
			glEnd();;
			
			
			
			
			GL.enable(GL_BLEND, GL_ALPHA_TEST);
			glAlphaFunc(GL_GREATER, 0.001f);
			GL.disable(GL_DEPTH_TEST, GL_STENCIL_TEST);
			
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE, 
			           GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			GL.pointSize = 15.f * width / 1024.f; 
			
			
			
			
			auto alpha = 0.25f;	      
			
			int current = void;
			float prog = 0.f;
			
			if ((lb >= 16) && (lb < 32)) 
			{
				current = 1;
				prog = step(16,32,lb);
			}
			else if ((lb >= 32) && (lb < 48)) 
			{
				current = 2;
				prog = step(32,48,lb);
			}
			else if (lb >= 48) 
			{
				current = 3;
				prog = step(48,64,lb);
			} 
			else
			{
				current = 0;	
				prog = step(0,16,lb);
			}
			
			m_flame[current].variations[0].color = vec4f(hsl(lt * 0.2f, 1, 0.5),alpha);
			m_flame[current].variations[1].color = vec4f(hsl(lt * 0.2f + 0.33f, 1, 0.5),alpha);
			m_flame[current].variations[2].color = vec4f(hsl(lt * 0.2f + 0.66f, 1, 0.5),alpha);
	
			if (current == 0)
			{
				auto t = lt * 1.3f;
				GL.rotate(360 * prog,0,0,1);
				GL.scale(vec3f(0.5) + 0.5f * prog);
				m_flame[current].variations[0].postTransform.setRotationtranslate(0.f - t, 0.898, vec2f(1, 0.5f));
				m_flame[current].variations[1].postTransform.setRotationtranslate(4.54 + t * 0.1f, 0.5, vec2f(-2.f, -1.5f));
				m_flame[current].variations[2].postTransform.setRotationtranslate(1.5 - t, 0.44 , vec2f(-0.039f, -0.039f));
				m_flame[current].variations[0].preTransform.setRotationtranslate(-1.f, 0.41f , vec2f(1.f - 0.125f, -0.39f));
				m_flame[current].variations[1].preTransform.setRotationtranslate(10.f, 2.f, vec2f(-1.f, -1.f));
				m_flame[current].variations[2].preTransform.setRotationtranslate(0,  1.f , vec2f(0.f, 0.f));
			} 
			
				
			if (current == 1)
			{
				auto t = lt * 2.f;
				GL.rotate(90,0,0,1);
				GL.scale(vec3f(1.0) + 0.6f * sin(prog * PI_F) + 1.f - exp(-prog * 30));
				m_flame[current].variations[0].postTransform.setRotationtranslate(-10.f - 0.4 * t, 0.89f, vec2f(0.71f, 0.49f));
				m_flame[current].variations[1].postTransform.setRotationtranslate(5 + 1.1 * t * 0.5f, -1.5, vec2f(-0.43, -1));
				m_flame[current].variations[2].postTransform.setRotationtranslate(7 - 0.4 *t, 0.44 + 0.5 * sin(dt), vec2f(-0.039, -0.029));
				m_flame[current].variations[0].preTransform.setRotationtranslate(-1.f, 0.41f , vec2f(1.f - 0.125f, -0.39f));
				m_flame[current].variations[1].preTransform.setRotationtranslate(10.f, 2.f, vec2f(-1.f, -1.f));
				m_flame[current].variations[2].preTransform.setRotationtranslate(0,1,vec2f(0,0));
			}
			
			
			
			if (current == 2)
			{
				
			//	GL.rotate(sin(prog * TWO_PI_F) * -30.f,0,0,1);
				GL.scale(vec3f(0.5) + 0.5f * prog + 1.f - exp(-prog * 30));
				m_flame[current].variations[0].postTransform.setRotationtranslate(0.f + lt, 0.99, vec2f(2.19, 0.345));
				m_flame[current].variations[1].postTransform.setRotationtranslate(1.0 + lt * 0.1f, 1.f, vec2f(-1.5, -0.6));
				m_flame[current].variations[2].postTransform.setRotationtranslate(0.0 + lt *-2, 1 , vec2f(0.6, -0.9));
				m_flame[current].variations[0].preTransform.setRotationtranslate(-1.f, 1.f , vec2f(-1.05, 1.61));
				m_flame[current].variations[1].preTransform.setRotationtranslate(10.f, 1.f, vec2f(-1.f, -1.f));
				m_flame[current].variations[2].preTransform.setRotationtranslate(1,1 , vec2f(0,0));				
			}
			
			if (current == 3)
			{
				auto t = lt * 2.f;
				GL.scale(vec3f(1.f + 1.f - exp(-prog * 20)));
				m_flame[current].variations[0].postTransform.setRotationtranslate(2.f * t,0.12,vec2f(-0.7 * prog,-0.07));
				m_flame[current].variations[1].postTransform.setRotationtranslate(t * 0.19,1.5,vec2f(-0.27 ,-0.34   ));
				m_flame[current].variations[2].postTransform.setRotationtranslate(t * -0.5,1,vec2f(0,-0.754));
				m_flame[current].variations[0].preTransform.setRotationtranslate(0,1,vec2f(0,0));
				m_flame[current].variations[1].preTransform.setRotationtranslate(0,1,vec2f(0,0));
				m_flame[current].variations[2].preTransform.setRotationtranslate(0,1 , vec2f(0,0));				
			}
			           
			m_flame[current].draw();		
			
			{
				m_whiteShader.use();
				
				GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
				           GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
				           
				float l = 1.f;           
				auto lb = localBeat;
				float eventFlash = step(0, 0+l, lb) * pulse(0,0+l,lb) + step(16, 16+l, lb) * pulse(16,16+l,lb) 
				                 + step(32, 32+l, lb) * pulse(32,32+l,lb) + step(48, 48+l, lb) * pulse(48,48+l,lb);
				
				glColor4f(1.f,1.f,1.f,eventFlash * eventFlash);
				
				glBegin(GL_QUADS);
					glVertex2f(-ratio, -1);
					glVertex2f(+ratio, -1);
					glVertex2f(+ratio, +1);
					glVertex2f(-ratio, +1);
				glEnd();
			}
			
			
			blurAmount = 3.f;			
			blurType = 0.6;
		}
		
		override void onMove()
		{
			
		}
	}
}



