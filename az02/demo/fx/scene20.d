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
module demo.fx.scene20;

import demo.whatfxneed;

private class CellSnake
{
	public
	{
		const int N = 6;	
		const float DIST_BETWEEN_RINGS = 0.001;
	}
	
	private struct RingVertex
	{
		vec3f pos, normal;
		
		void send()
		{
			glNormal3fv(normal.ptr);
			glVertex3fv(pos.ptr);			
		}
	}
	
	private struct Ring
	{
		float radius;
		vec3f pos;
		
		mat3f rot; // direction of the Cellsnake at this ring
		
		void orthonormalize()
		{
			rot.orthonormalize();
		}
		
	}	
	
	public
	{
		Ring m_rings[];
		RingVertex m_vertices[];
		RingVertex m_top;
		RingVertex m_bottom;
		Random random;
		float m_speed;
		vec3f m_mov;
		vec4f m_color;
		mat3f m_vrot;
		float m_alpha;
		float life;
		float m_vradius;
		float m_initRadius;
		
		float[] sinTable;
		float[] cosTable;
		
		bool mustBeRenewed()
		{
			return life < 0.f;
		}
		
	}
	
	public
	{
		this(vec3f pos, float radius, mat3f rot, int length, float speed, vec4f color)
		{
			random = Random();
			m_color = color;
			m_initRadius = radius;
			
			m_rings.length = length;
			m_mov = vec3f(0);
			m_speed = speed;
			m_alpha = 0.f;
			m_vradius = 0;
			m_vrot = mat3f.identity;
			life = 10.f + 5 * random.nextFloat();;
			
			rot.orthonormalize;
			
			for(int i = 0; i < length; ++i)
			{
				m_rings[i].radius = radius;	
				m_rings[i].pos = pos;
				m_rings[i].rot = rot;
			}
			
			m_vertices.length = length * N;
			
			sinTable.length = N;
			cosTable.length = N;
			
			for (int i = 0; i < N; ++i)
			{
				sinTable[i] = sin((2.0 * PI_D * i) / N);
				cosTable[i] = cos((2.0 * PI_D * i) / N);
			}
		}	
		
		void move(double dt, float turn_force, float speed_factor)
		{
			auto radiusAcc = 0.1 * random.nextGaussf() - m_rings[0].radius * 0.01 ;
			m_vradius = (m_vradius + (radiusAcc * dt)) * exp(-dt * 10);
			m_rings[0].radius += dt * m_vradius;
			
			m_rings[0].rot = m_rings[0].rot * mat3f.rotateZ(turn_force * dt * random.nextGaussf() ) * mat3f.rotateX(turn_force * dt * random.nextGaussf());
			m_rings[0].rot.orthonormalize();
			
			
			vec3f acc = m_speed * speed_factor * m_rings[0].rot * vec3f(0,0,1);
			m_mov = (m_mov + dt * acc) * exp(-dt * 0.1);			
			m_rings[0].pos += dt * m_mov;
			for (int i = m_rings.length - 2; i >= 0; --i)
			{
				m_rings[i+1].pos += (m_rings[i].pos - m_rings[i+1].pos) * (1.f - exp3(-dt * 20));
				m_rings[i+1].rot += (m_rings[i].rot - m_rings[i+1].rot) * (1.f - exp3(-dt * 20));
				m_rings[i+1].radius += (m_rings[i].radius - m_rings[i+1].radius) * (1.f - exp3(-dt * 30));
				m_rings[i+1].rot.orthonormalize();
			}
			if (m_alpha < 0.95f) m_alpha += dt * 2.0;
			
			// update positions
			for (int i = 0; i < m_rings.length; ++i)
			{
				for (int j = 0; j < N; j++)
				{				
					auto disp = m_rings[i].rot * vec3f(sinTable[j], cosTable[j], 0.f);	
					
					auto radius = m_rings[i].radius;
					m_vertices[j + i * N].pos = m_rings[i].pos + radius * disp;
					m_vertices[j + i * N].normal = disp;
				}
			}
			
			m_top.normal = m_rings[0].rot * vec3f(0,0,1);			
			m_top.pos = m_rings[0].pos + m_top.normal * m_rings[0].radius * 0.5f;
			
			m_bottom.normal = m_rings[m_rings.length-1].rot * vec3f(0,0,-1);			
			m_bottom.pos = m_rings[m_rings.length-1].pos + m_bottom.normal * m_rings[m_rings.length-1].radius * 0.5f;
			life -= dt;
		}
		
		void draw()
		{	
			// back and front
			GL.color = vec4f(m_color.xyz, m_color.w * m_alpha * clamp(life * 0.2f, 0.f, 1.f));
			
			glBegin(GL_TRIANGLE_FAN);
			m_top.send;
			for (int j = 0; j < N; j++)
			{
				m_vertices[0 * N + j].send;
			}
			m_vertices[0 * N + 0].send;
			glEnd();
			
			for (int j = 0; j < N - 1; j++)
			{
				glBegin(GL_QUAD_STRIP);
				for (int i = 0; i < m_rings.length - 1; ++i)
				{	
					m_vertices[i * N + j].send;
					m_vertices[i * N + (j+1)].send;
				}				
				glEnd();				
			}
			
			glBegin(GL_QUAD_STRIP);
			for (int i = 0; i < m_rings.length - 1; ++i)
			{	
				m_vertices[i * N + N-1].send;
				m_vertices[i * N + 0].send;
			}				
			glEnd();	
			
			glBegin(GL_TRIANGLE_FAN);
			m_bottom.send;
			for (int j = 0; j < N; j++)
			{
				m_vertices[(m_rings.length - 1) * N + j].send;
			}
			m_vertices[(m_rings.length - 1) * N].send;
			glEnd();
		}
	}
}


final class Scene20 : Effect
{
	private
	{
		ParticleSystem m_particleSystem;
		
		float accum = 0.f;
		float lastBeat = -0.5f;
		
		Random random;
		
		CellSnake[] m_cellSnakes;
		
		Shader m_snakeShader;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "ParticleFX", timeSpan, priority);
		}
		
		auto const N = 10000;
		
		override void onLoad()
		{
			random = Random();
			
			
			m_particleSystem = new ParticleSystem(N, "data/tex/spore.png");			
			
			with (m_particleSystem)
			{
				viscosityForce = 1.f;
				intensity = 2.f;
				minDist = 1;
				maxDist = 0;
				minSize = 1;
				maxSize = 30;
			}
			
			m_cellSnakes.length = 150;
			for (int i = 0; i < m_cellSnakes.length; i++)
			{
				m_cellSnakes[i] = null;
			}
			
			m_snakeShader = Demo.loadShader("snake");
		}
		
		CellSnake newSnake(bool center)
		{
			vec3f pos = void;
			if (center)
			{
				pos = vec3f(0.f,0.f,-1.2f);
			} else
			{
				pos = vec3f(random.nextFloat2,random.nextFloat2,random.nextFloat2 - 1.2f);
			}
			
			auto rot = random.nextRotation3f();
			auto radius = 0.01 + 0.01 * random.nextFloat;	
			auto speed = 0.2 + 0.1 * random.nextFloat;	
			
			vec3f chooseColor2()
			{
				switch(random.nextRange(0,3))
				{
					case 0: return rgb(0xbeff8a);
					case 1: return rgb(0xeca3f9); 
					case 2: return rgb(0xefe431);
					case 3: 
					default: return rgb(0xff2498);
				}
			}		
			
			auto color = chooseColor2();				
	
			return new CellSnake( pos, radius, rot, random.nextRange(20,40), speed, vec4f(color,1.f));			
		}
		
		override void onDraw()
		{
			mainFBO.use();
			
			
			GL.viewport = viewport;
			GL.projectionMatrix = mat4f.perspective(89.f, ratio, 0.1, 5.f);
			
			{
				vec3f viewer = vec3f(0.f, 0.f, 1 - lt * 0.05);			
				vec3f target = viewer - vec3f(0.f, 0.f, 1.f);
				vec3f up = vec3f(0,1, 0.f);
			
				GL.modelviewMatrix = mat4f.lookAt(viewer, target, vec3f(sin(lt * 0.1), cos(lt * 0.1), 1));
			}
			
			auto red = 2.f; //lerp(0.55f,2.f,step(0,32,lb));
			auto green = 0.87f; //lerp(1.214f, 0.87f, step(0,32,lb));
			
			glClearColor(red * 16.f / 255.f, green * 16.f / 255.f, 30.f / 255.f, 1.f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			
			
			GL.disable(GL_ALPHA_TEST, GL_DEPTH_TEST, GL_CULL_FACE);
			
			glEnable(GL_POINT_SPRITE);
			glTexEnvi(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);			
			
		   
            GL.pointSize = 30.f * width / 1024.f; 
			
			
			GL.enable(GL_BLEND);
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			
			GL.enable(GL_ALPHA_TEST);
			glAlphaFunc(GL_GREATER, 0.05f);
			
			m_particleSystem.draw();	
			
//			glDisable(GL_TEXTURE_2D);			
			/*glEnable(GL_DEPTH_TEST);
			glDepthFunc(GL_LEQUAL);
			*/
			       
			m_snakeShader.use();
			
			
			for (int i = 0; i < m_cellSnakes.length; i++)
			{
				if (m_cellSnakes[i] !is null) m_cellSnakes[i].draw();
			}
			
			float mrflash = hit(minsec(2,8.08), minsec(2,8.08) + 2.f, gt, 4.f);
			blurAmount = 8.0;			
			blurType = 0.3 + 0.7 * step( 60.0, 63.5, lb) + mrflash;
		}
		
		vec4f chooseColor()
		{
			float t = random.nextFloat;
			return vec4f(0.4f + t * 0.6f, 0.4f + t * 0.6f, 0.2 + t * 0.7f, 1.f);
		}
		
		override void onMove()
		{
			
			accum += dt;
			while( accum > 0.0005f)
			{
				bool b = random.nextBool;
				m_particleSystem.addParticle(vec3f(random.nextFloat2,random.nextFloat2,-random.nextFloat * 6.f), 
				                             vec3f(random.nextFloat2 * 0.1,random.nextFloat2 * 0.1,1.0), 
				                             chooseColor(),
				                             random.nextFloat * 5.f);
				accum -= 0.0005f;
			}
			
			m_particleSystem.move(dt);
			
			// snakes
			
			{
				float turn_force = 20;
				auto speed_factor = 20.f * amplify(2.f * volume(Track.KICK));
				for (int i = 0; i < m_cellSnakes.length; i++)
				{
					//if (m_cellSnakes[i].mustBeRenewed()) m_cellSnakes[i] = newSnake();
					if (m_cellSnakes[i] !is null) m_cellSnakes[i].move(dt, turn_force, speed_factor);
					
					
				}
			}
			
			/*
			  renew snakes
			*/
			
			{
				void spawn(int max, bool center)
				{
					int count = 0;
					for (int i = 0; i < m_cellSnakes.length; i++)
					{
						if ((m_cellSnakes[i] is null) 
						|| (m_cellSnakes[i].mustBeRenewed())) 
						{
							m_cellSnakes[i] = newSnake(center);				
							if (++count >= max) return;
						}
					}					
				}
				
				if  (lastBeat < 16 && 16 < localBeat)
				{
					spawn(1, false);
				}
				
				if  (lastBeat < 24 && 24 < localBeat)
				{
					spawn(2, false);
				}
				
				if  (lastBeat < 32 && 32 < localBeat)
				{
					spawn(150, false);
				}
				
				if  ( localBeat >= 56 )
				{
					spawn(cast(int)(localBeat - 55) * 50, true);
				}
			}
			lastBeat = localBeat;
		}
	}
}