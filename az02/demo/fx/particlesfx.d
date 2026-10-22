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
module demo.fx.particlesfx;

import demo.whatfxneed;

final class ParticlesFX : Effect
{
	private
	{
		ParticleSystem m_particleSystem;
		
		float accum = 0.f;
		
		Random random;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "ParticleFX", timeSpan, priority);			
			
		}
		
		auto const N = 100000;
		
		override void onLoad()
		{
			random = Random();
			
			
			m_particleSystem = new ParticleSystem(N, "data/tex/particle.png");			
			
			with (m_particleSystem)
			{
				viscosityForce = 1.f;
				intensity = 2.f;
				minDist = 1;
				maxDist = 0;
				minSize = 1;
				maxSize = 30;
			}
		}
		
		override void onDraw()
		{
			mainFBO.use();
			
			
			GL.viewport = viewport;
			GL.projectionMatrix = mat4f.perspective(89.f, ratio, 0.1, 1000.f);
			
			{
				vec3f viewer = vec3f(0, 0.f, 1);			
				vec3f target = vec3f(0.f);
				vec3f up = vec3f(sin(localTime * 0.1),cos(localTime * 0.1), 0.f);
			
				GL.modelviewMatrix = mat4f.lookAt(viewer, target, up);
			}
			
			glClear(GL_COLOR_BUFFER_BIT);
			
			
			GL.disable(GL_ALPHA_TEST, GL_DEPTH_TEST, GL_BLEND, GL_CULL_FACE);
			
			glEnable(GL_POINT_SPRITE);
			glTexEnvi(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);			
			
		   
            GL.pointSize = 10.f;
			
			
			GL.enable(GL_BLEND);
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			
			GL.enable(GL_ALPHA_TEST);
			glAlphaFunc(GL_GREATER, 0.05f);
			
		
			            
			m_particleSystem.draw();	
			
			
			blurAmount = 6.0;			
			blurType = 1.0;
		}
		
		vec4f chooseColor()
		{
			float t = random.nextFloat;
			return vec4f(0.4f + t * 0.6f, 0.4f + t * 0.6f, 0.2 + t * 0.7f, 1.f);
		}
		
		override void onMove()
		{
			
			accum += dt;
			while( accum > 0.001f)
			{
				bool b = random.nextBool;
				m_particleSystem.addParticle(vec3f(random.nextFloat2,random.nextFloat2,-1.0f-random.nextFloat), 
				                             vec3f(random.nextFloat2 * 0.1f,random.nextFloat2 * 0.1f,2.0), 
				                             chooseColor(),
				                             5.f);
				accum -= 0.001f;
			}
			
			m_particleSystem.move(dt);
		}
	}
}

