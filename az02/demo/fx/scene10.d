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
module demo.fx.scene10;

import demo.whatfxneed;

final class Scene10 : Effect
{
	private
	{
		NuageRouge m_NuageRouge;
		Shader m_put;
		Shader m_glow;
		Texture1D m_glowTex;
		float[] m_glotTexData;
		const int GLOWTEX_SIZE = 256;
		Plane plan1, plan2, plan3, plan4;
		
	}
	
	public
	{
		const double TIME1 = 1.0 * 60 + 11;
		const double TIME2 = 1.0 * 60 + 39.65;
		const double TIME3 = 1.0 * 60 + 25.43;
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "Scene10", timeSpan, priority);
		}
		
		
		override void onLoad()
		{
			m_NuageRouge = new NuageRouge();
			bool compression = true;
			
			{
				Texture2D t1 = Demo.loadTexture2D("data/tex/plan1.tif", Texture.IFormat.RGBA8, Texture.Filter.LINEAR_MIPMAP_LINEAR, 
				                                  Texture.Filter.LINEAR, Texture.Wrap.CLAMP_TO_EDGE, true, compression);
				plan1 = new Plane(t1);
				plan1.pos = vec2f(0,0);
				plan1.size = vec2f(32.f / 9.f, 2.f);				
			}
			
			{
				Texture2D t2 = Demo.loadTexture2D("data/tex/plan2.png", Texture.IFormat.RGBA8, Texture.Filter.LINEAR_MIPMAP_LINEAR, 
				                                  Texture.Filter.LINEAR, Texture.Wrap.CLAMP_TO_EDGE, true, false);
				plan2 = new Plane(t2);
			}
			
			{
				Texture2D t3 = Demo.loadTexture2D("data/tex/plan3.tif", Texture.IFormat.RGBA8, Texture.Filter.LINEAR_MIPMAP_LINEAR, 
				                                  Texture.Filter.LINEAR, Texture.Wrap.CLAMP_TO_EDGE, true, compression);
				plan3 = new Plane(t3);
			
			}
			
			{
				Texture2D t4 = Demo.loadTexture2D("data/tex/plan4.jpg", Texture.IFormat.RGBA8, Texture.Filter.LINEAR_MIPMAP_LINEAR, 
				                                  Texture.Filter.LINEAR, Texture.Wrap.CLAMP_TO_EDGE, true, compression);
				plan4 = new Plane(t4);
				plan4.pos = vec2f(0,0);
				plan4.size = vec2f(32.f / 9.f, 2.f);
			}
			
			{
				m_glowTex = new Texture1D(Texture.IFormat.I16F, false);
				m_glowTex.minFilter = Texture.Filter.LINEAR;
				m_glowTex.magFilter = Texture.Filter.LINEAR;
				m_glowTex.wrapS = Texture.Wrap.CLAMP_TO_EDGE;
				m_glowTex.wrapT = Texture.Wrap.CLAMP_TO_EDGE;
				m_glowTex.setImage(0, GLOWTEX_SIZE, Texture.Format.INTENSITY, Texture.Type.FLOAT, null, false);
				m_glotTexData.length = GLOWTEX_SIZE;
			}
			
			m_put = putShader;
			
			m_glow = Demo.loadShader("glow");
			m_glow.setSampler("tex", m_glowTex, 0);
			
		}
		
		override void onDraw()
		{
			mainFBO.use();
			
			GL.viewport = viewport;
			
			
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio,1.f,1.f));
			vec2f movCam = void;
			float camScale = void;
			
			if (slice == 0)
			{
				float prog = smoothStep(minsec(1,11), 1.0 * 60 + 39.65, lt );
				float prog2 = smoothStep(minsec(0,0), minsec(1,11), lt );
				
				movCam = -plan2.pos * prog;
				camScale = 0.4f * prog2 + prog * 1.5f + 1.0f;
				GL.modelviewMatrix = mat4f.scale(vec3f(camScale)) *  mat4f.translate(vec3f(movCam, 0.f));
			}
			else
			{
				float prog = smoothStep(4,endTime, lt);
				
				movCam = -plan2.pos * (1.0 - prog);
				camScale = lerp(3.f, 1.f, prog);
				GL.modelviewMatrix = mat4f.scale(vec3f(camScale)) *  mat4f.translate(vec3f(movCam, 0.f));
			}
			
			
//			GL.clearColor = vec4f(0.f,0.f,0.f,1.f);
//			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);			
		
			GL.disable(GL_DEPTH_TEST, GL_CULL_FACE);
			
	
			GL.enable(GL_ALPHA_TEST);
			glAlphaFunc(GL_GREATER, 0.005f);
			
			GL.enable(GL_BLEND);
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			           GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			           
			           
			float alpha = 1.f;
			if (slice == 1) alpha = step(0, 8, lb);
			plan1.color = vec4f(1.f,1.f,1.f,alpha);
			plan2.color = vec4f(1.f,1.f,1.f,alpha);
			plan3.color = vec4f(1.f,1.f,1.f,alpha);
			plan4.color = vec4f(1.f,1.f,1.f,alpha);
			
			// draw back planes
			{
				
				plan4.draw();
				
				plan3.draw();
			}
			
			// white glow
			if (slice == 0)
			{
				for (int i = 0; i < GLOWTEX_SIZE; ++i)
				{
					m_glotTexData[i] = 0.5f * volumeN(Track.KICK, - i * 0.003f + 0.15f);
				}
				m_glowTex.setImage(0, GLOWTEX_SIZE, Texture.Format.INTENSITY, Texture.Type.FLOAT, m_glotTexData.ptr, false);
				
				
				glPushMatrix();
					
					glTranslatef(plan2.pos.x, plan2.pos.y, 0.f);
					glScalef(plan2.size.x, plan2.size.y, 1.f);
					glRotatef(plan2.m_rotation, 0,0,1);					
					m_glow.use();
					glBegin(GL_QUADS);	
						glColor4f(1.f,1.f,1.f,smoothStep(minsec(1,10),minsec(1,11), lt));
						glTexCoord2f(-2,-2); glVertex2f(-2 , -2  );	
						glTexCoord2f(2,-2); glVertex2f(+2 , -2  );
						glTexCoord2f(+2,+2); glVertex2f(+2 , +2  );
						glTexCoord2f(-2,+2); glVertex2f(-2 , +2  );				
					glEnd();
				glPopMatrix();
			}
			
			
			plan2.draw();
			glColor4f(1.f,1.f,1.f,alpha);
			
			m_NuageRouge.alpha = alpha;
			m_NuageRouge.draw();
			
			plan1.draw();
			
				
			// red quad
			if (slice == 0)
			{
				float alphaRed = smoothStep(minsec(1,0), TIME2, gt) * 0.2f;
			
				m_put.use();
				
				glBegin(GL_QUADS);	
					glColor4f(1,0,0,alphaRed);				
					glVertex2f(-ratio , -1  );	
					glVertex2f(+ratio , -1  );
					glVertex2f(+ratio , +1  );
					glVertex2f(-ratio , +1  );				
				glEnd();
			}
			
			if (slice == 0)
			{
				float hit1 = hit(TIME1, TIME1 + 4, lt, 2.f);		
				float hit3 = hit(TIME3, TIME3 + 4, lt, 2.f);
				auto blurChange = smoothStep(endTime - 4, endTime, lt);			
				blurAmount = lerp(0.8, 8.0, blurChange) + 4.f * hit1 + 4.f * hit3;
				blurType = lerp(0.5, 0.3, blurChange);
			} 
			else
			{
				float prog = smoothStep(4,endTime, lt);
				float hit1 = hit(0, 4, lt, 2.f);	 
				blurAmount = lerp(1.5, 0.8, prog) + 4.f * hit1;
				blurType = lerp(0.05, 0.5, prog);
			}
		}
		
		override void onMove()
		{
			float speed = 0.01f;
			
			float end = 60.f + 53.8744f;
			
			plan1.size = vec2f(32.f / 9.f, 2.f);
			plan3.size = vec2f(0.671 * 32.f / 9.f, 2.f);
			if (slice == 0)
			{
				{
					float prog = step(28, end, lt);		
					plan3.pos = lerp(vec2f(0.2f, -0.2f), vec2f(-0.2, 0.2), prog);
					if (prog > 1.f) prog = 1.f;
					
				}			
				{
					float prog = lerp(0.f, 1.f, (lt - 40.f) / (minsec(1,11) - 40.f));				
					plan2.size = 2.f * vec2f(0.34537f, 0.3583f) * (1.f + prog * 0.1f) * (1.f - volumeN(Track.KICK) * 0.02f);				
					if (prog > 1.f) prog = 1.f;
					plan2.pos = lerp( vec2f(+1.f, 0.5f), vec2f(0.0, 0.4f), prog);
				}
			} 
			else
			{
				float prog = step(4.f, endTime, lt) * step(4,5,lt);
				plan3.pos = lerp(vec2f(0.f) , vec2f(-0.4, 0.4) * 0.125f, prog);
				plan2.pos = lerp( vec2f(0.0, 0.4f),  vec2f(0.125f * -1.f, 0.4 - 0.125f * 0.1f), prog);
			}
			m_NuageRouge.move(dt);
		
		}
	}
	
	
	
	private final class NuageRouge
	{
	
		private
		{
			ParticleSystem m_particleSystem;
			float accum = 0.f;
			Random random;	
			float alpha = 1.f;
		}	
		
		public
		{
			auto const N = 10000;
			
			this()
			{
				random = Random();
				
				
				m_particleSystem = new ParticleSystem(N, "data/tex/particle.png");			
				
				with (m_particleSystem)
				{
					viscosityForce = 0.f;
					intensity = 1.f;
					minDist = 1000;
					maxDist = 0;
					minSize = 10;
					maxSize = 10;
				}
			}
			
			void draw()
			{
				GL.disable(GL_DEPTH_TEST, GL_CULL_FACE);
				
				glEnable(GL_POINT_SPRITE);
				glTexEnvi(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);
			   
	            GL.pointSize = 10.f * width / 1024.f;
				
				
				GL.enable(GL_BLEND);
				GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
				            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
				
				GL.enable(GL_ALPHA_TEST);
				glAlphaFunc(GL_GREATER, 0.005f);
				
				m_particleSystem.draw(alpha);
			}
			
			vec4f chooseColor()
			{
				vec3f base = void;
				
				switch (random.nextRange(0,3))
				{
					case 0: base = rgb(0xefa3b0); break;
					case 1: base = rgb(0x5eabd9); break;
					case 2: base = rgb(0x0128bb); break;
					case 3: 
					default: base = rgb(0x8f676b); 
				}
				return vec4f(base, 1.f);
			}
			
			void move(float dt)
			{
				
				if (slice == 0)
				{
					accum += dt * volumeN(Track.PAD1);
				} else
				{
					accum += dt  * 0.3f;	
				}
				
				
				
				
				while( accum > 0.001f)
				{
					bool b = random.nextBool;
					
					{
						
						vec3f center = vec3f(plan2.pos, 0.f);
						auto rayon = plan2.size.y * 0.5f;
						
						
						float x = random.nextGaussf + random.nextGaussf;
						auto angle = x * 0.3;
						float speed = 0.08 + 0.02 * random.nextGaussf;
						m_particleSystem.addParticle(vec3f(x, -0.1, 0.f), 
						                             0.2f * vec3f(sin(angle) * speed,cos(angle) * speed,0.f), 
						                             chooseColor(),
						                             0.1f + 10.f * random.nextFloat);
						
						
					}
					accum -= 0.001f;
				}
				m_particleSystem.viscosityForce = -0.1;
				m_particleSystem.move(dt);
				
				
			}
			
		}
		
	}

}

