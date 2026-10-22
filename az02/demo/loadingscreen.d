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
module demo.loadingscreen;

import util.math;
import util.all;
import util.geometry.all;
import gl.all;
import demo.demo;
import sdl.all;


/**
 * Loading screen : post-processing is redone (yeah, it seems overkill)
 */
final class LoadingScreen
{
	private
	{
		Shader m_loadingShader, m_blitShader, m_progressShader;
		
		float m_blurAmount = 1.5f;
		int m_width, m_height;
		
		Texture2D m_mainTexture, m_logoTexture, m_pinkNoiseTexture;
		Texture3D m_gammaCorrectionTexture; // a gamma ramp texture	
		
		float m_blurType = 0.f; // 0 => "normalized blur"   /   1 => "more dreamy, more light"	
		recti m_viewport, m_finalViewport;
		
		FBO m_mainFBO;
		
	}
	
	public
	{
		this(recti viewport, recti finalViewport, float gamma)
		{
			m_viewport = viewport;
			m_finalViewport = finalViewport;
			
			
			m_mainTexture = new Texture2D(Texture.IFormat.RGBA8, false); 
			
			
			m_logoTexture = Demo.loadTexture2D("data/tex/loading.jpg", Texture.IFormat.RGB8, Texture.Filter.LINEAR_MIPMAP_LINEAR, Texture.Filter.LINEAR, 
			                                   Texture.Wrap.CLAMP_TO_EDGE, true, false);
			                                   
			m_pinkNoiseTexture = Demo.loadTexture2D("data/tex/pinknoise.png", Texture.IFormat.I8, Texture.Filter.LINEAR_MIPMAP_LINEAR, Texture.Filter.LINEAR, 
			                                   Texture.Wrap.REPEAT, true, false);
			GL.check();
			m_mainTexture.minFilter = Texture.Filter.LINEAR;
			m_mainTexture.magFilter = Texture.Filter.LINEAR;
			m_mainTexture.wrapS = Texture.Wrap.CLAMP_TO_EDGE;
			m_mainTexture.wrapT = Texture.Wrap.CLAMP_TO_EDGE;
			m_mainTexture.setImage(0, m_viewport.width, m_viewport.height, Texture.Format.RGBA, Texture.Type.UBYTE, null, false);
			GL.check();
			m_mainFBO = new FBO();
			m_mainFBO.color[0].setTarget(m_mainTexture, 0);
			m_mainFBO.setDrawBuffers([0]);
			m_mainFBO.setWrite(FBO.Component.COLORS); // no depth buffer for now
			m_mainFBO.check();
			GL.check();
			
			m_blitShader = Demo.loadShader("blit");
			m_blitShader.setSampler("tex", m_logoTexture, 0);
			m_progressShader = Demo.loadShader("progress");
			m_progressShader.setSampler("tex", m_pinkNoiseTexture, 0);
			
			
			// construct gamma ramp ( a 3D texture )
			{
				m_gammaCorrectionTexture = new Texture3D(Texture.IFormat.RGBA8, false); // no compression
				m_gammaCorrectionTexture.wrapS = Texture.Wrap.CLAMP_TO_EDGE;
				m_gammaCorrectionTexture.wrapT = Texture.Wrap.CLAMP_TO_EDGE;
				m_gammaCorrectionTexture.wrapR = Texture.Wrap.CLAMP_TO_EDGE;
				m_gammaCorrectionTexture.minFilter = Texture.Filter.LINEAR;
				m_gammaCorrectionTexture.magFilter = Texture.Filter.LINEAR; 			
				
				float[] gammaRampDataTmp;
				auto const GAMMA_RAMP_SIZE = 32; // should be a power-of-2 and not too large
				gammaRampDataTmp.length = GAMMA_RAMP_SIZE;
				
				for (int i = 0; i < GAMMA_RAMP_SIZE; ++i)
				{
					gammaRampDataTmp[i] = pow((i / (GAMMA_RAMP_SIZE - 1.0)), 1.0 / gamma);					
				}
				
				float[] gammaRampData3D;
				gammaRampData3D.length = 4 * GAMMA_RAMP_SIZE * GAMMA_RAMP_SIZE * GAMMA_RAMP_SIZE;
				int index = 0;
				
				for (int i = 0; i < GAMMA_RAMP_SIZE; ++i)
				{
					for (int j = 0; j < GAMMA_RAMP_SIZE; ++j)
					{
						for (int k = 0; k < GAMMA_RAMP_SIZE; ++k)
						{
							gammaRampData3D[index++] = gammaRampDataTmp[k];
							gammaRampData3D[index++] = gammaRampDataTmp[j];
							gammaRampData3D[index++] = gammaRampDataTmp[i];
							gammaRampData3D[index++] = 1.f;
						}
					}
				}
				m_gammaCorrectionTexture.setImage(0, GAMMA_RAMP_SIZE, GAMMA_RAMP_SIZE, GAMMA_RAMP_SIZE,
				                                     Texture.Format.RGBA, Texture.Type.FLOAT, gammaRampData3D.ptr, false);	
				GL.check();
				
			}
			m_loadingShader = Demo.loadShader("loading");
			m_loadingShader.setSampler("gammaRamp", m_gammaCorrectionTexture, 1);	
			m_loadingShader.setSampler("tex", m_mainTexture, 0);	
			
			trace("<LoadingScreen.this");
		}
		
		~this()
		{
			delete m_blitShader;
			delete m_progressShader;
			delete m_loadingShader;
			delete m_mainFBO;
			delete m_mainTexture;
			delete m_logoTexture;
			delete m_gammaCorrectionTexture;			
		}
		
		/**
		 * draw the screen et fait de petites pauses
		 */
		void progress(float progression)
		{
			
			GL.disable(GL_BLEND, GL_ALPHA_TEST, GL_DEPTH_TEST, GL_CULL_FACE);
				
			m_mainTexture.minFilter = Texture.Filter.LINEAR;
			m_mainFBO.use();
				
			GL.viewport = m_viewport;
			
			
			GL.projectionMatrix = mat4f.scale(vec3f(m_viewport.height / cast(double)(m_viewport.width), 1, 1)); 
			GL.modelviewMatrix = mat4f.identity;
			
			glClearColor(0,0,0,1);
			glClear(GL_COLOR_BUFFER_BIT);
			
			m_blitShader.use();
			auto imageRatio = m_logoTexture.width / cast(float)m_logoTexture.height;
			auto ratio =m_viewport.width / cast(double)(m_viewport.height);
			
			
			GL.enable(GL_BLEND);
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
		
			
			vec2f lpos = vec2f(0.f,0.f);
			vec2f lsize = vec2f(imageRatio * 2.f,2.f);
			const int SUBDIV = 64;
			const float SUBDIVF = 64.f;
			for (int i = 0; i < SUBDIV; ++i)
			{
				glBegin(GL_QUAD_STRIP);	
				for (int j = 0; j <= SUBDIV; ++j)
				{
					float ti = i / SUBDIVF;
					float ti2 = ti + 1.f / SUBDIVF;
					float tj = j / SUBDIVF;
					
					
					float x1 = lerp(lpos.x - lsize.x * 0.5f, lpos.x + lsize.x * 0.5f, ti);
					float x2 = lerp(lpos.x - lsize.x * 0.5f, lpos.x + lsize.x * 0.5f, ti + 1 / SUBDIVF);
					float y = lerp(lpos.y - lsize.y * 0.5f, lpos.y + lsize.y * 0.5f, tj);
					float alpha = max(0.f, 1.f - 3.f * ((ti-0.5f) * (ti - 0.5f) * imageRatio * imageRatio + (tj - 0.5f) * (tj - 0.5f)));
					glColor4f(1,1,1,alpha);			
				
					glTexCoord2f(ti, 1.f - tj); 
					GL.vertex(vec2f(x1, y));
					float alpha2 = max(0.f, 1.f - 3.f * ((ti2-0.5f) * (ti2 - 0.5f) * imageRatio * imageRatio + (tj - 0.5f) * (tj - 0.5f)));
					glColor4f(1,1,1,alpha2);			
					glTexCoord2f(ti2, 1.f - tj); 
					GL.vertex(vec2f(x2, y));
				}
				glEnd();
			}
			
			
			
	
			
			m_progressShader.set1f("progression", progression * 0.01 );
			m_progressShader.use();
			            
			glBegin(GL_QUADS);	
			
			
				glColor4f(1,0.9,0.8,1);	
				
				glTexCoord2f(-1,0); glVertex2f(-imageRatio - 0.25, -0.5f );	
				glTexCoord2f(2,0); glVertex2f(+imageRatio - 0.25, -0.5);
				glColor4f(0.8,0.9,1,0.8);	
				glTexCoord2f(2,1); glVertex2f(+imageRatio - 0.25, -0.75);
				glTexCoord2f(-1,1); glVertex2f(-imageRatio  - 0.25,  -0.75);				
				
				
			glEnd();			            
			            
			
			m_mainTexture.minFilter = Texture.Filter.LINEAR_MIPMAP_LINEAR;
			
			m_mainTexture.generateMipmaps();
			
			GL.disable(GL_BLEND);
			
			FBO.getDefault().use(); 
			
			
			glClear(GL_COLOR_BUFFER_BIT);
			
			m_loadingShader.set1f("blurAmount", 0.2);
			m_loadingShader.set1f("blurType", 0.0f);
			m_loadingShader.use();
	
			GL.viewport = m_finalViewport;
			
			GL.clearColor = vec4f(0,0,0,1);
			glClear(GL_COLOR_BUFFER_BIT);
		
			
			GL.disable(GL_DEPTH_TEST, GL_ALPHA_TEST, GL_CULL_FACE, GL_BLEND);
			
		
				
			glBegin(GL_QUADS);	
				glColor4f(1,1,1,1);				
				
				glTexCoord2f(0,0); glVertex2f(-1,-1);	
				glTexCoord2f(1,0); glVertex2f(+1,-1);
				glTexCoord2f(1,1); glVertex2f(+1,+1);
				glTexCoord2f(0,1); glVertex2f(-1,+1);				
			glEnd();
			SDL_GL_SwapBuffers();
			
			SDL_Delay(30);			
		}
	}
}

