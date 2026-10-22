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
module demo.fx.scene40;

import demo.whatfxneed;
import demo.sphere;

final class Scene40 : Effect
{
	private
	{
		Shader m_skyboxShader;
		Shader m_objectShader;
		Texture2D m_walls;
		
		Sphere[] sphere;
		
		const int NSPHERE = 20;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "Scene40", timeSpan, priority);			
			
		}
		
		
		override void onLoad()
		{
			m_walls = commonTexture(CommonTexture.CHECKERS);
			
			m_skyboxShader = Demo.loadShader("skybox2");
			m_skyboxShader.setSampler("tex", m_walls,0);
			
			m_objectShader = Demo.loadShader("scene40");
			m_objectShader.setSampler("tex", m_walls,0);
			sphere.length = NSPHERE;
			
			float prec = 20;
			for (int i = 0; i < NSPHERE; ++i)
			{
				sphere[i] = new Sphere(m_objectShader, round(prec), round(prec) * 2, true);
				prec *= 0.92f;
			}
		}
		
		override void onDraw()
		{
			mainFBO.use();
			
			GL.viewport = viewport;
			
			auto fov = 10  + /*smoothStep(0,4,lb) **/ 79.5f - 30 * smoothStep(4,8,lb);
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1.f, 1.f)) * mat4f.perspective( fov, 1.f, 0.01, 400.f);
			
			vec3f viewerPos()
			{
				auto phi = lt;
				auto theta = sin(lt * 0.2f) * 1.0f;
				auto dist = 7.f;
				return dist * vec3f(cos(phi) * cos(theta), sin(theta), sin(phi) * cos(theta));
			}
			
			mat4f camMat()
			{
				auto cpos = viewerPos();
				auto cup = vec3f(0,1,0);
				return mat4f.lookAt(cpos , vec3f(0,0,0), cup);
			}
		
			GL.modelviewMatrix = camMat;
			
			glClearColor(0,0,0,1);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			
			auto eyePos = viewerPos();
			m_skyboxShader.set3f("eyePos", eyePos);		
			
			float light_hue_base = (lb / 8.f);
			float LI = 0.9f + 0.2f * volumeN(Track.KICK);
			vec3f light1 = LI * hsl(light_hue_base , 0.6, 0.7);
			vec3f light2 = LI * hsl(light_hue_base + 0.25f, 0.6, 0.7);
			vec3f light3 = LI * hsl(light_hue_base + 0.5f, 0.6, 0.7);
			vec3f light4 = LI * hsl(light_hue_base + 0.75f, 0.6, 0.7);				
			
			m_skyboxShader.set3f("light1", light1);
			m_skyboxShader.set3f("light2", light2);
			m_skyboxShader.set3f("light3", light3);
			m_skyboxShader.set3f("light4", light4);
			
			m_skyboxShader.use();
		
			auto dist = 10.f; // do not change
			
			GL.disable(GL_BLEND,GL_ALPHA_TEST, GL_CULL_FACE);
			GL.enable(GL_DEPTH_TEST);
			glDepthFunc(GL_LEQUAL);
			drawCube(vec3f(dist), false);
			
			
			m_objectShader.set3f("eyePos", eyePos);
			
			m_objectShader.use();
			
		//	glEnable(GL_CULL_FACE);
		//	glCullFace(GL_BACK);
		
			glColor3f(1.0,1.0,1.0);
			
			m_objectShader.set3f("light1", light1);
			m_objectShader.set3f("light2", light2);
			m_objectShader.set3f("light3", light3);
			m_objectShader.set3f("light4", light4);
			
			for (int i = 0; i < NSPHERE; ++i)
			{
				m_objectShader.set1f("radius", sphere[i].radius);
				m_objectShader.set1f("medium", 2.0);
				m_objectShader.set3f("center", sphere[i].pos);
				sphere[i].draw;	
			}
			
			auto event2 = 0.f;//sqr(sqr(1.f - step(0,4,lt)));
			blurType = 0.1f + 0.9 * event2;
			blurAmount = 2.5f + event2 * 5f;
			
			
		}
		
		override void onMove()
		{
			float rad = 1.f;
			
			vec3f trajet( float t)
			{
				return vec3f(3.f * sin(t), 3.f * cos(t),3.f * sin(t) * cos(t * 2.f));
			}
			float decal = 0.f;
			
			for (int i = 0; i < NSPHERE; ++i)
			{
				sphere[i].pos = trajet(lt * 0.75 + decal);
				sphere[i].radius = rad - volumeN(Track.KICK, decal) * 0.15f * smoothStep(0,8,lb);
				rad *= 0.9f;
				decal -= 0.3 * rad;
			}
			
		}
	}
}

