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
module demo.fx.scene30;

import demo.whatfxneed;
import demo.sphere;

// space scene

final class Scene30 : Effect
{
	private
	{
		Texture2D m_stars;
		Shader m_skyboxShader;
		Shader m_objectShader;
	
		SphereTree m_kick;
		
		auto const EVENT1 = minsec(2,50.75);
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "Scene30", timeSpan, priority);			
			
		}
		
		
		override void onLoad()
		{
			
			m_stars = commonTexture(CommonTexture.STARS);
			
			m_skyboxShader = Demo.loadShader("skybox");
			m_skyboxShader.setSampler("tex", m_stars, 0);
			
			m_objectShader = Demo.loadShader("scene30");
			m_objectShader.setSampler("tex", m_stars, 0);
			
			m_kick = new SphereTree(3, 20.f);
			
		}
		
		override void onDraw()
		{
			mainFBO.use();
			
			GL.viewport = viewport;
			
			auto fov = 20.f + 40.f * smoothStep(0, 32, lb);
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1.f, 1.f))  * mat4f.perspective( 50.f, 1.f, 0.01, 1000.f);
			
			mat4f idealCampos(vec3f disp)
			{
				auto cpos = disp;
				
				
		/*		auto boom = minsec(2,33.405);
			    auto boomLength = 2.656;
			    float rotate = TWO_PI_F * smoothStep(boom, boom + boomLength, gt);
		*/
				auto rotate = 0.f;	    
				
				auto cup = vec3f(0,cos(rotate),sin(rotate));
				auto dir = vec3f(0,-sin(rotate),cos(rotate));
			    
			    return mat4f.lookAt(cpos , cpos + dir, cup);
			    
			    
			}
			
		
			GL.modelviewMatrix = idealCampos(vec3f(0.f));
			
			glClearColor(0,0,0,1);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			
			GL.disable(GL_BLEND, GL_ALPHA_TEST, GL_DEPTH_TEST, GL_BLEND, GL_CULL_FACE);
			
			double fasterTime = lt * (1.0 + smoothStep(0,8,lt));
			m_skyboxShader.set1f("angle", 0.5f * sin(time2bpm(lt) * TWO_PI_D / 32.0 ));
			m_skyboxShader.set1f("time", fasterTime);
			m_skyboxShader.use();
		
			{
				auto dist = 0.1f;
				
				glBegin(GL_QUAD_STRIP);
				for (int i = 0; i <= 32; ++i)
				{
					auto angle = i * TWO_PI_F / 32.f;
					auto cosa = dist * cos(angle);
					auto sina = dist * sin(angle);
					auto a = vec3f(cosa, sina, 100.f);
					auto b = vec3f(cosa, sina, -100.f);
					GL.vertex(a,b);
				}
				glEnd();
			}
			
			{
				auto a = time2bpm(lt) * TWO_PI_D / 16.0;
				GL.modelviewMatrix = idealCampos(vec3f(0.f, 0.f, 0.1f * sin(a) ));				
			}
			
			m_objectShader.set1f("angle", 0.5f * sin(time2bpm(lt) * TWO_PI_D / 32.0 ));
			m_objectShader.set1f("time", fasterTime);
			m_objectShader.use();
	//		GL.enable(GL_DEPTH_TEST);
	/*		GL.enable(GL_CULL_FACE);
			glCullFace(GL_BACK);
	*/		
	
			m_kick.draw();
			
		
			auto event1 = pulse(31,32,lb) + pulse(63,64,lb);
			auto event2 = sqr(sqr(1.f - step(0,8,lt)));
		
			
			{
				blurAmount = 3.f + 60.f * event2 + event1 * 5.f * volumeN(Track.KICK);			
				blurType = 0.6f + 0.4f * event2 - 0.4f * event1;
			}
		}
		
		override void onMove()
		{
			vec3f center = vec3f(0,0,5 + 100.f * (1 - step(30,31,lb)));
			m_kick.move(center, 0.f, 1.2f, -lt * 1.125);
			m_kick.factor = 1.f + (-0.05f * smoothStep(31, 32, lb) - 0.5f * pulse(31,32,lb) ) 
			                        * volumeN(Track.KICK) * (1.f - 0.8f * step(EVENT1,EVENT1+1.f, gt)); 
			m_kick.cfactor = 1.f + sqr(1.f - step(34,41, localBeat)) * 100.f;
			m_kick.sphere.radius = m_kick.sphere.radius * 0.9f;
			m_kick.childs[0].factor = 1.f - 0.1f * volumeN(Track.BASS1);			
			m_kick.childs[1].factor = 1.f - 0.1f * volumeN(Track.L303);			
			m_kick.childs[2].factor = 1.f - 0.1f * volumeN(Track.R303);
			
		}
	}
	
	
	class SphereTree
	{
		public
		{
			Sphere sphere;
			SphereTree childs[3];
			float factor = 1.f;
			float cfactor = 1.f;
			
			this(int level, float resolution)
			{
				if (level > 0)
				{
					childs[0] = new SphereTree(level-1, 0.6f * resolution);
					childs[1] = new SphereTree(level-1, 0.6f * resolution);
					childs[2] = new SphereTree(level-1, 0.6f * resolution);
				} else
				{
					childs[0] = null;
					childs[1] = null;
					childs[2] = null;
				}
				int res = (level == 3) ? 40 : round(resolution);
				sphere = new Sphere(m_objectShader, res, res * 2, true);
				
				vec4f chooseColor(int level)
				{
					vec3f base = void;					
					switch (level)
					{
						case 0: base = rgb(0xffffff); break;
						case 1: base = rgb(0xff8080); break;
						case 2: base = rgb(0xebf84a); break;
						case 3: base = rgb(0xff9c00); break;
						case 4: 
						default: base = rgb(0xffffff); 
					}
					return vec4f(base, 1.f);
				}
				
				sphere.color = chooseColor(level);
				
			}
			
			void draw()
			{
				sphere.draw;
				if (childs[0] !is null) childs[0].draw();
				if (childs[1] !is null) childs[1].draw();
				if (childs[2] !is null) childs[2].draw();
			}
			
			void move(vec3f orig, float angle, float radius, float incAngle)
			{
				radius *= factor;	
				sphere.radius = radius;				
				
				angle += incAngle;
				vec3f p0 = orig + cfactor * 1.8f * radius * vec3f(sin(angle), cos(angle), 0);
				vec3f p1 = orig + cfactor * 1.8f * radius * vec3f(sin(angle+ TWO_PI_F / 3.f), cos(angle+ TWO_PI_F / 3.f), 0);
				vec3f p2 = orig + cfactor * 1.8f * radius * vec3f(sin(angle- TWO_PI_F / 3.f), cos(angle- TWO_PI_F / 3.f), 0);
				sphere.pos = orig;
				
				if (childs[0] !is null) childs[0].move(p0, angle , radius * 0.5f , incAngle);
				if (childs[1] !is null) childs[1].move(p1, angle + TWO_PI_F / 3.f , radius * 0.5f, incAngle);
				if (childs[2] !is null) childs[2].move(p2, angle - TWO_PI_F / 3.f , radius * 0.5f, incAngle);
			}
		}
		
	}
}
