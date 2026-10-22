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
module demo.fx.scene49;

import demo.whatfxneed;

final class Scene49 : Effect
{
	private
	{
		ParticleSystem m_particleSystem;
		
		float accum = 0.f;
		
		Random random;
		
		Plane m_logo;
		Shader m_putShader;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "Scene49", timeSpan, priority);			
			
		}
		
		auto const N = 4000;
		
		override void onLoad()
		{
			random = Random();
			
			
			m_particleSystem = new ParticleSystem(N, "data/tex/particle.png");			
			
			with (m_particleSystem)
			{
				viscosityForce = 0.1f;
				intensity = 2.f;
				minDist = 1;
				maxDist = 0;
				minSize = 1;
				maxSize = 30;
			}
			
			Texture2D logotex = Demo.loadTexture2D("data/tex/logo2b.jpg", Texture.IFormat.RGB8, Texture.Filter.LINEAR_MIPMAP_LINEAR, 
				                                  Texture.Filter.LINEAR, Texture.Wrap.CLAMP_TO_EDGE, true, false);
			
			auto blitlogo2 = Demo.loadShader("blit");
			m_logo = new Plane(logotex, blitlogo2);
			m_logo.pos = vec2f(0,0);
			m_logo.size = vec2f(2.f * 1024.f / 869.f, 2.f);		
			
			
			for (int i = 0; i < 5 * 60; ++i)
			{
				createAndMoveParticles(1.0 / 60.0, 2.f);
			}
			
			m_putShader = putShader;
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
			
			m_logo.draw(); 
			
			
			GL.enable(GL_BLEND);
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			            
			m_putShader.use();
	/*		glBegin(GL_QUADS);
				glColor4f(0,0,0,0);
				glVertex2f(-1024.f / 869.f + m_logo.pos.x, 2);
				glVertex2f(-1024.f / 869.f + m_logo.pos.x, -2);
				glColor4f(0,0,0,1);
				glVertex2f(-1024.f / 869.f + 0.3f+ m_logo.pos.x, -2);
				glVertex2f(-1024.f / 869.f + 0.3f+ m_logo.pos.x, 2);
			glEnd();	
			
			glBegin(GL_QUADS);
				glColor4f(0,0,0,0);
				glVertex2f(+1024.f / 869.f+ m_logo.pos.x, 2);
				glVertex2f(+1024.f / 869.f+ m_logo.pos.x, -2);
				glColor4f(0,0,0,1);
				glVertex2f(+1024.f / 869.f - 0.3f+ m_logo.pos.x, -2);
				glVertex2f(+1024.f / 869.f - 0.3f+ m_logo.pos.x, 2);
			glEnd();		
		
	*/		
			GL.enable(GL_BLEND);
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			m_particleSystem.draw();	
			
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			
			m_putShader.use();
			glBegin(GL_QUADS);
				float alpha = hit(0,32,lb,4);
				glColor4f(1,1,1,alpha);
				glVertex2f(-ratio, -1.f);
				glVertex2f(+ratio, -1.f);
				glVertex2f(+ratio, +1.f);
				glVertex2f(-ratio, +1.f);
				
				
			glEnd();
		
			blurAmount = 1.f;
			blurType = 0.1;			
		}
		
		vec4f chooseColor()
		{
			return vec4f(1.f, 0.9f, 1.f, 0.03f);
		}
		
		void createAndMoveParticles(double dt, float qty)
		{
			accum += dt * qty;
			while( accum > 0.001f)
			{
				bool b = random.nextBool;
				float angle = random.nextFloat * TWO_PI_F;
				float speed = 0.4f + 0.2f * random.nextFloat;
				
				auto which = random.nextFloat();
				
				
				m_particleSystem.addParticle(vec3f(-0.1,0.2,0), 
				                             vec3f(sin(angle) * speed, cos(angle) * speed,0.0), 
				                             chooseColor(),
				                             2.f + random.nextFloat() * 4.f );
				accum -= 0.001f;
			}
			
			m_particleSystem.move(dt);
		}
		
		override void onMove()
		{
			
			createAndMoveParticles(dt, volumeN(Track.PAD1) * 2.f);
		}
	}
}

