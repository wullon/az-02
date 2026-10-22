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
module demo.postprocess;

import util.math;
import util.all;
import util.geometry.all;
import gl.all;
import demo.demo;


/**
 * Handle the demo post-processing
 * AZ02 specific
 */
final class PostProcess
{
	private
	{
		Demo m_demo; 
		recti m_viewport;
		
		Shader m_finalShader;
		
		float m_blurAmount = 1.5f;
		int m_width, m_height;
		
		Texture3D m_gammaCorrectionTexture; // a gamma ramp texture	
		
		float m_blurType = 0.f; // 0 => "normalized blur"   /   1 => "more dreamy, more light"	
		
		debug
		{
			bool m_visualRatioCue = false;	
		}
	}
	
	public
	{
		this(Demo demo, recti viewport, float gamma)
		{
			m_demo = demo;
			m_viewport = viewport;
			
			m_finalShader = Demo.loadShader("final");
			m_width = viewport.width;
			m_height = viewport.height;
			
			
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
				
				m_finalShader.setSampler("gammaRamp", m_gammaCorrectionTexture, 1);	
			}
			
		}
		
		float blurAmount() { return m_blurAmount; }
		float blurType() { return m_blurType; }
		
		float blurAmount(float amt) { return m_blurAmount = amt; }
		float blurType(float amt) { return m_blurType = amt; }
		
		
		
		debug
		{
			bool visualRatioCue() { return m_visualRatioCue; }	
			bool visualRatioCue(bool c) { return m_visualRatioCue = c; }	
		}
		
		void render(Texture2D unprocessedTexture)
		{
			FBO.getDefault().use(); // render now !
			
			
			m_finalShader.setSampler("tex", unprocessedTexture, 0);
			m_finalShader.set1f("blurAmount", m_blurAmount);
			m_finalShader.set1f("blurType", m_blurType);
			
	//		m_finalShader.set1f("invWidth", 1.0 / m_width);
	//		m_finalShader.set1f("invHeight", 1.0 / m_height);
			
			m_finalShader.use();
			
	
			GL.viewport = m_viewport;
			
			GL.clearColor = vec4f(0,0,0,1);
			glClear(GL_COLOR_BUFFER_BIT);
		
			
			GL.disable(GL_DEPTH_TEST, GL_ALPHA_TEST, GL_CULL_FACE, GL_BLEND);
			
			GL.projectionMatrix = mat4f.identity;
			GL.modelviewMatrix = mat4f.identity;
				
			glBegin(GL_QUADS);	
				glColor4f(1,1,1,1);				
				
				glTexCoord2f(0,0); glVertex2f(-1,-1);	
				glTexCoord2f(1,0); glVertex2f(+1,-1);
				glTexCoord2f(1,1); glVertex2f(+1,+1);
				glTexCoord2f(0,1); glVertex2f(-1,+1);				
			glEnd();		
			
			
			// visual cue for different ratios (useful to place something)
			debug
			{
				if (m_visualRatioCue)
				{
					m_demo.putShader.use();
					float invRatio = m_height / cast(float)m_width;
					GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1,1));
					GL.modelviewMatrix = mat4f.identity;
					GL.disable(GL_BLEND, GL_ALPHA_TEST, GL_DEPTH_TEST, GL_CULL_FACE);
					glLineWidth(1);
					glColor4f(1,0,0,1);
					void visualRatioCue(float ratio)
					{
						glBegin(GL_LINE_LOOP);
							glVertex2f(-ratio,-1);	
							glVertex2f(+ratio,-1);
							glVertex2f(+ratio,+1);
							glVertex2f(-ratio,+1);
						glEnd();
					}
					
					visualRatioCue(5.f / 4.f);
					visualRatioCue(4.f / 3.f);
					visualRatioCue(16.f / 10.f);
					visualRatioCue(16.f / 9.f);
				}
			}
		}
	}
}

