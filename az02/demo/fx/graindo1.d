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
module demo.fx.graindo1;

import demo.whatfxneed;
import demo.fx.scene80;
import demo.torus;

// also named Scene85 in design
final class Graindo1 : Effect
{
	private
	{
		Shader m_shader;
		Texture1D m_distMap;
		float[] m_distMapData;
		const int DISTMAP_SIZE = 512;
		Scene80 m_scene80;		
		
		Torus torus;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority, Scene80 scene80)
		{
			super(demo, "Graindo1", timeSpan, priority);				
			m_scene80 = scene80; // bacause we reuse the torus
		}
		
		override void onLoad()
		{
			
			{
				m_distMap = new Texture1D(Texture.IFormat.I16F, false);
				m_distMap.minFilter = Texture.Filter.LINEAR;
				m_distMap.magFilter = Texture.Filter.LINEAR;
				m_distMap.wrapS = Texture.Wrap.CLAMP_TO_EDGE;
				m_distMap.wrapT = Texture.Wrap.CLAMP_TO_EDGE;
				m_distMap.setImage(0, DISTMAP_SIZE, Texture.Format.INTENSITY, Texture.Type.FLOAT, null, false);
				m_distMapData.length = DISTMAP_SIZE;
			}
			
			m_shader = Demo.loadShader("graindo12");
			m_shader.setSampler("distRamp", m_distMap, 0);
			
			torus = new Torus(100,50);
		}
	
		
		override void onDraw()
		{
			mainFBO.use();
			
			
			
			GL.viewport = viewport;
			
			GL.projectionMatrix = mat4f.scale(vec3f(1 / ratio, 1, 1)); 
			GL.modelviewMatrix = mat4f.identity;
			
			GL.rotate(lt * 0.3,0,0,1);
			
			GL.disable(GL_ALPHA_TEST, GL_CULL_FACE, GL_DEPTH_TEST);
			
			
			
			
			glClearColor(0,0,0,1);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			
			GL.enable(GL_BLEND);
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			
			
			for (int i = 0; i < DISTMAP_SIZE; ++i)
			{
				Random r =  Random(6546);
				auto f = i / cast(float)(DISTMAP_SIZE - 1);
				auto trou = 0.5 / (1.0f + 200 * abs(f - 0.08));
				m_distMapData[i] = pow(0.5f, f * 10.f) * (1.f + 0.2f * min(0.L, sin(lt * 1.f)) * sin(f * 30.f + lt * 10.f)) - trou;
			}
			
			
			m_distMap.setImage(0, DISTMAP_SIZE, Texture.Format.INTENSITY, Texture.Type.FLOAT, m_distMapData.ptr, false);
				
			m_shader.use();
			
			void drawSun(vec2f pos, vec2f size, float angle, vec3f color, float param1, float time)
			{
				m_shader.set1f("time", time);
				
				m_shader.set1f("param1", param1);
				
				m_shader.set3f("matColor", color * 0.8);
			
				glPushMatrix();
				glTranslatef(pos.x, pos.y, 0);
				glScalef(size.x, size.y, 1.f);
				glRotatef(angle,0,0,1);
				
							
				glBegin(GL_QUADS);	
					glColor4f(1,1,1,1);
					auto zoom = 5.f;
					auto xcm = zoom;
					auto ycm = zoom;
					glTexCoord2f(-xcm,-ycm); 
					glVertex2f(-1,-1);	
					glTexCoord2f(xcm,-ycm); 
					glVertex2f(+1,-1);
					glTexCoord2f(xcm,ycm); 
					glVertex2f(+1,+1);
					glTexCoord2f(-xcm,ycm); 
					glVertex2f(-1,+1);	
				glEnd();
				glPopMatrix();
			}
			
			glDepthMask(GL_FALSE);
			auto s1 = 2.f;
			auto param1 = powf(2.f, 7.f * (1.f - progressionf) * (1.f - progressionf));	
			
			drawSun(vec2f(0,0.0), vec2f(s1,s1), 0.f, rgb(0x42c657), param1, -lt * 0.2);
			
			auto s2 = s1 * 0.7f;
			drawSun(vec2f(0,0.7), vec2f(s2,s2), 38.4f, rgb(0x8f80a1), param1, lt * 0.2 + 3);
			
			drawSun(vec2f(-0.6,-0.5), vec2f(s2,s2), 170.f, rgb(0xe599c3), param1, lt * 0.2 + 1);
			
			drawSun(vec2f(+0.6,-0.5), vec2f(s2,s2), -71.f, rgb(0xd59d55), param1, lt * 0.2 + 2);
			
			{
				Shader torusShader = m_scene80.maleShader;	
			//	torusShader.setSampler("tex", commonTexture(CommonTexture.PINK_NOISE), 1);
				float fov = 60.f;
				
				
			
				GL.disable(GL_BLEND);
				
				GL.enable(GL_DEPTH_TEST);
				GL.enable(GL_RESCALE_NORMAL);
				glDepthMask(GL_TRUE);
				
				mat4f cameraMatrix = mat4f.lookAt(vec3f(0,0,-1), vec3f(0,0,0), vec3f(0,1,0));
				GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1.f, 1.f)) * mat4f.perspective( fov, 1.f, 0.01, 100.f);
				GL.modelviewMatrix = cameraMatrix;
	 			
				torusShader.set3f("ambientColor", vec3f(progression * 0.5));
				torusShader.set3f("light1Color",  rgb(0x8f80a1));
				torusShader.set3f("light2Color",  rgb(0xe599c3));
				torusShader.set3f("light3Color",  rgb(0xd59d55));
				
				
				torusShader.set3f("light1Pos", vec3f(-2,-2,0.5));
				torusShader.set3f("light2Pos",  vec3f(-2,2,-5));
				torusShader.set3f("light3Pos",  vec3f(+2,2,-10));
				
				auto specularF = 4.5f;
				torusShader.set1f("light1Specular", specularF);
				torusShader.set1f("light2Specular", specularF);
				torusShader.set1f("light3Specular", specularF);
	
				torusShader.use();
				GL.color = rgb(0x8fef8f) + rgb(0x200000) * sqr(progression);
				torus.draw();
				
				GL.disable(GL_RESCALE_NORMAL);
			}
			
			auto bt = -0.04;
			auto ba = lerp(0.f,-6.f, progressionf);
			
			
			blurType = bt;
			blurAmount = ba;
			
		}
		
		override void onMove()
		{
			{
				
				torus.pos = vec3f(0,0,-0.5 + lt);
				torus.matrix = mat4f.rotateZ(progression * 8.f * PI_F) * mat4f.rotateX(progression * 2.f * PI_F); 
				
				torus.smallRadius = 0.30 + 0.1 * 0.5f;//volumeN(Track.MB, 0.075f);
				torus.largeRadius = 0.7;
				
				
				
				float boom1 = smoothStep(16,16.25, lb);
				float boom2 = smoothStep(32,32.25, lb);
				float boom3 = smoothStep(48,48.25, lb);
				
				torus.size = vec3f(2.f - sqr(pulse(15.5,16,lb)) * 0.2f - sqr(pulse(31.5,32,lb)) * 0.2f - sqr(pulse(47.5,48,lb)) * 0.2f );
				
				torus.peakAmount = +(boom1 * 0.4 + boom2 * 0.6f + boom3 * 10.f);
				
				torus.peakY = 4 * boom1 + 4 * boom2;
				torus.peakX = 2.f * boom1 + 13 * boom2 + 15 * boom3;
			}
		}
	}
}

