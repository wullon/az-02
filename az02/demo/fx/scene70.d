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
module demo.fx.scene70;

import demo.whatfxneed;
import demo.shapes;

final class Scene70 : Effect
{
	private
	{
		Tube m_tube;
		Shader m_shader;
	

	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "Scene70", timeSpan, priority);			
			
		}
		
		
		override void onLoad()
		{
			m_tube = new Tube( 40, 100);
			
			
			m_shader = Demo.loadShader("lambert");
			m_shader.setSampler("noise", commonTexture(CommonTexture.PINK_NOISE),0 );
			
		}
		
		override void onDraw()
		{
			mainFBO.use();
			GL.viewport = viewport;
			
			float fov = 45.f;
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1.f, 1.f)) * mat4f.perspective( fov, 1.f, 0.01, 400.f);
			
			
			
			vec3f viewerPos()
			{
				float phi, theta, dist;
				
				if (slice == 0)
				{
					phi = lt;
					theta = -0.10f + 0.20f * sin(progression * PI_F);
					dist = 6.8f - 1.5f * sin(PI_F * 4.f * progression);
				}
				else
				{
					float cam1 = step(endBeat - 12, endBeat - 8, lb);
					float cam2 = step(endBeat - 8, endBeat - 4, lb);
 					float cam3 = step(endBeat - 4, endBeat , lb);
					
 					if (cam3 > 1e-7)
 					{
	 					phi = (PI_F / 180.f) * (630.f + (-90 - 630.f));
						theta = lerp(0.5,-0.2,cam3);
						dist = 5.f + 2.f * sin(cam3 * PI_F) - step(endBeat-1, endBeat, lb) * 6;
 					}
 					else 
 					if (cam2 > 1e-7)
 					{
	 					phi = (PI_F / 180.f) * (630.f + (-90 - 630.f)) + cam2 * TWO_PI_F * 0.5f;
						theta = lerp(0.1,-0.1,cam2);
						dist = 8.f - 5.f * sin(cam2 * PI_F);
 					}
 					else 
 					if (cam1 > 1e-7)
 					{
	 					phi = (PI_F / 180.f) * (630.f + (-90 - 630.f)) + PI_F;
						theta = - lerp(0.2,-0.5,cam1);
						dist = 5.f - 2.f * sin(cam1 * PI_F);
 					}
					else
					{
						phi = lt;
						theta = -0.10f + 0.20f * sin(progression * PI_F);
						dist = 6.8f - 1.5f * sin(PI_F * 4.f * progression);
					}
				}
				return dist * vec3f(cos(phi) * cos(theta), sin(theta), sin(phi) * cos(theta));
			}
			
			mat4f camMat()
			{
				auto cpos = viewerPos();
				auto cup = vec3f(0,1,0);
				return mat4f.lookAt(cpos , vec3f(0,0,0), cup);
			}
			mat4f cameraMatrix = camMat();
			GL.modelviewMatrix = cameraMatrix;
			
			GL.disable(GL_BLEND, GL_DEPTH_TEST, GL_ALPHA_TEST);
 			
			
			float thresholdZ = void;
			if (slice == 0) 
			{
				thresholdZ = step(0,8,lb) - step(endBeat-1,endBeat,lb);
				
			} 
			else
			{
				thresholdZ = step(0,4,lb);// - step(endBeat-4,endBeat,lb);
			}
			
			if (thresholdZ > 0.99f)
			{
				glClearColor(0,0,0,1);
 				glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			} 
			else
			{
				glClear(GL_DEPTH_BUFFER_BIT);				
			}

			GL.enable(GL_DEPTH_TEST);
			glDepthFunc(GL_LEQUAL);
			//glEnable(GL_CULL_FACE);
			
			
			m_shader.set3f("ambientColor", 0.5f * rgb(0x552b48));
			m_shader.set3f("light1Color", desaturate(rgb(0xff839a), 0.f));
			m_shader.set3f("light2Color", desaturate(rgb(0xfda8f6),0.f));
			m_shader.set3f("light3Color", desaturate(rgb(0xffdd9a),0.f));
			
			
			m_shader.set3f("light1Pos", vec3f(4,0,-2));
			m_shader.set3f("light2Pos", vec3f(-4,0,-2));
			m_shader.set3f("light3Pos", vec3f(0,0,5));
			
			auto specularF = 0.5f;
			m_shader.set1f("light1Specular", specularF);
			m_shader.set1f("light2Specular", specularF);
			m_shader.set1f("light3Specular", specularF);

			
			m_shader.setMat4f("invCamMat", cameraMatrix.inverse() );
			
		
			
			m_shader.set1f("thresholdZ", lerp(1.f,-1.02f, thresholdZ));
			m_shader.use();
			
			GL.color = rgb(0xa9a7d0);
			
			drawCube(vec3f(0,1,0), vec3f(10.f), 1.f, false);
			{
				auto sizeC = 3.5f;
				auto disp = 10.f - sizeC;
				drawCube(vec3f(-disp,-disp,+disp), vec3f(sizeC), sizeC * 0.1f, true);
				drawCube(vec3f(-disp,+disp,+disp), vec3f(sizeC), sizeC * 0.1f, true);
				drawCube(vec3f(+disp,+disp,+disp), vec3f(sizeC), sizeC * 0.1f, true);
				drawCube(vec3f(+disp,-disp,+disp), vec3f(sizeC), sizeC * 0.1f, true);
				drawCube(vec3f(-disp,-disp,-disp), vec3f(sizeC), sizeC * 0.1f, true);
				drawCube(vec3f(-disp,+disp,-disp), vec3f(sizeC), sizeC * 0.1f, true);
				drawCube(vec3f(+disp,+disp,-disp), vec3f(sizeC), sizeC * 0.1f, true);
				drawCube(vec3f(+disp,-disp,-disp), vec3f(sizeC), sizeC * 0.1f, true);
			}
		
			GL.color = rgb(0xff95ae);
			m_tube.size = vec3f(1.f, 4.f, 1.f);
			m_tube.draw;
			
		//	display(d1);
			
			float eventFin = 0.f;
			if (slice == 1) eventFin = step(endBeat - 1, endBeat, lb);
			
			
			blurAmount = 1.0 + 3.5f * hit(0,4,lb, 2.f) + volumeN(Track.KICK) * 0.5f + 20.f * eventFin;
			blurType = 1 - 0.5f * volumeN(Track.PERCUS);
		}
		
		override void onMove()
		{
			const int STEPS = 4;
			const INV_STEPS = 1.0 / STEPS;
			double time = lt - dt;
			for (int i = 0; i < STEPS; ++i)
			{
				m_tube.move(time, dt / STEPS);
				time += dt * INV_STEPS;
			}
		}
	}
	
	
	
	private class Tube
	{
		public
		{
			struct TubePoint
			{
				vec3f pos;
				vec3f nml;
				vec3f nmlAccum;
				vec3f vel;
				vec3f acc;
				
				void move(float dt, float visco)
				{
					vel	+= dt * acc;
					pos += dt * vel;
					vel *= visco;
					acc = vec3f(0.f);
				}
				
				void vertex() // p should be normalized
				{
					glNormal3fv(nml.ptr);
					glVertex3fv(pos.ptr);
				}
				
				static TubePoint opCall(vec3f pos, vec3f nml)
				{
					TubePoint tp = void;
					tp.pos = pos;
					tp.nml = nml;
					tp.vel = vec3f(0.f);
					tp.acc = vec3f(0.f);
					return tp;
				}
			}
		}
		private
		{
			
			
			vec3f m_pos;
			vec3f m_size;
			//Random random;
			double time = 0.0;
	
			float[] cosTable;
			float[] sinTable;
			
			int m_slices, m_stacks;		
			
			TubePoint[] m_points;
			
			void computeGeometry(int stacks, int slices, float radius)
			{
				m_slices = slices;
				m_stacks = stacks;
				
				m_points.length = m_stacks * m_slices;
				
				sinTable.length = m_slices;
				cosTable.length = m_slices;
				
				for (int j = 0; j < m_slices; ++j)
				{
					float phi = (j * TWO_PI_D) / m_slices;
					sinTable[j] = sin(phi);
					cosTable[j] = cos(phi);
				}
				
				for (int i = 0; i < m_stacks ; ++i)
				{
					for (int j = 0; j < m_slices; ++j)
					{
						float y = lerp(-1.f, 1.f, i / cast(float)(m_stacks - 1));
						float x = sinTable[j] * radius;
						float z = cosTable[j] * radius;
						m_points[j + i * m_slices] = TubePoint( vec3f(x,y,z), vec3f(x, 0, z).normalized);
					}
				}
			}
			
			TubePoint pt(int i, int j)
			{
				return m_points[j + i * m_slices];
			}
			
			void vertex(int i, int j)
			{
				m_points[j + i * m_slices].vertex();
			}
		}	
		
		public
		{
			this( /*Shader shader, */ int stacks, int slices)
			{
				m_pos = vec3f(0.f,0.f,0.f);
				//m_shader = shader;
				m_size = vec3f(1.f,1.f,1.f);
				
				computeGeometry(stacks, slices, 1.f);
				
//				random = Random();
			}
			
			vec3f pos() { return m_pos; }
			vec3f pos(vec3f p) { return m_pos = p; }
					
			vec3f size() { return m_size; }		
			vec3f size(vec3f p) { return m_size = p; }
			
			void draw()
			{
			//	m_shader.use();
				
				glPushMatrix();
				glTranslatef(pos.x, pos.y, pos.z);			
				glScalef(m_size.x, m_size.y, m_size.z);
			
				
				for (int i = 0; i < m_stacks - 1; ++i)
				{
					glBegin(GL_QUAD_STRIP);
					
					
					for (int j = 0; j < m_slices; ++j)
					{
						glTexCoord2f( (size.x * j) / m_slices,  (size.y * (i+1) / PI_F) / m_stacks);
						vertex(i+1,j);
						glTexCoord2f( (size.x * j) / m_slices,  (size.y * i  / PI_F) / m_stacks);
						vertex(i,j);
					}
					glTexCoord2f( 1,  (size.y * (i+1)  / PI_F) / m_stacks);
					vertex(i+1,0);
					glTexCoord2f( 1,  (size.y * i) / PI_F / m_stacks);
					vertex(i,0);
					glEnd();
				}
				
				
				glPopMatrix();			
			}
			
			float getIdealRadius(float time, float phi, float y)
			{
				if (slice == 0)
				{
					float a = 0.1f + 1.f * smoothStep(0, 2, time - y);
					
					
					return a * (0.7f + 0.2f * cos(phi * 3.f + y * 9.f - time * 4.f) + 0.5 * volumeN(Track.KICK, -y * 0.5f));
				} else
				{
					
					phi -= PI_F;
					const TAILLE = -0.1;
					const TAILLE2 = -0.2;
					const SEINS = 0.2;
					const HANCHE = -0.4;
					const SUBHANCHE = -0.8;
					const SUBNECK = 0.3;	
					const NECK = 0.35;					
					
					const HEAD = 0.55;
					const HEAD2 = 0.65;
					const TOPHEAD = 0.8;
					
					float cosphi = cos(phi);
					float cosphi2 = cos(phi * 2.f);
					
					float taille = 0.6f * (1.0f + 0.1 * cosphi2);						
					float taille2 = 0.6f * (1.0f - 0.1 * cosphi2);		
					float seins = (0.9f + 0.5f / (1.f + abs(0.6f - phi) * 10.f) + 0.5f / (1.f + abs(-0.6f - phi) * 10.f));
					float hanche = 0.9f * (1.5f - 0.1f * cosphi2 - 0.7f / (1.f + (PI_F - abs(phi))) - 0.2f * cosphi );
					float subhanche = 0.8f * (1.0f - 0.5 * cosphi2);	
					float neck = 0.0f;
					float subneck = 1.2f - 0.6f * cosphi2;
					float htmp = 1.f / (1.f + abs(phi));
					float head = 0.8f + 0.3f * htmp;
					float head2 = 0.9f + 0.2f * htmp;
					float tophead = 0.0f;
					
					
					if (y < SUBHANCHE) return subhanche;
					if (y < HANCHE) return lerp(subhanche, hanche, step(SUBHANCHE, HANCHE, y));
					if (y < TAILLE) return lerp(hanche, taille, step(HANCHE, TAILLE, y));
					if (y < TAILLE2) return lerp(taille, taille2, step(TAILLE, TAILLE2, y));
					if (y < SEINS) return lerp(taille2, seins, step(TAILLE2, SEINS, y));
					if (y < SUBNECK) return lerp(seins, subneck, step(SEINS, SUBNECK, y));
					if (y < NECK) return lerp(subneck, neck, step(SUBNECK, NECK, y));
					if (y < HEAD) return lerp(neck, head, step(NECK, HEAD, y));
					if (y < HEAD2) return lerp(head, head2, step(HEAD, HEAD2, y));
					if (y < TOPHEAD) return lerp(head2, tophead, step(HEAD2, TOPHEAD, y));
					return tophead;
				}
				
			}
			
			void move(double lt, double dt)
			{
				time += dt;
				
				foreach	(ref p; m_points) 
				{
					p.acc = vec3f(0.f);
				}
				
				auto j_to_angle = TWO_PI_F / m_slices;
				
				for (int i = 0; i < m_stacks ; ++i)
				{
					
					// radius
					
					float idy = lerp(-1.f, 1.f, i / cast(float)(m_stacks - 1));
					vec3f center = vec3f(0,idy,0);
					
					for (int j = 0; j < m_slices; ++j)
					{
						TubePoint* pt = &m_points[j + i * m_slices];		
						
						float wanted_radius = getIdealRadius(lt, j_to_angle * j, idy);			
						
						float x = sinTable[j] * wanted_radius;
						float z = cosTable[j] * wanted_radius;
						vec3f idnml = vec3f(x, 0.f, z);
						vec3f ideal = center + idnml * wanted_radius;
						
						pt.acc += 15.f * (ideal - pt.pos);
						
						// spring between neighbours
						const STIFNESS = 60.f;
						if (i > 0)
						{
							TubePoint* pt2 =  &m_points[j + (i-1) * m_slices];		
							pt.acc += (pt2.pos - pt.pos) * STIFNESS;						
						}
						
						if (i < m_stacks-1)
						{
							TubePoint* pt2 =  &m_points[j + (i+1) * m_slices];		
							pt.acc += (pt2.pos - pt.pos) * STIFNESS;						
						}
						
						{
							int jp1 = j + 1;
							if (jp1 >= m_slices) jp1 = 0;
							TubePoint* pt2 =  &m_points[jp1 + i * m_slices];		
							pt.acc += (pt2.pos - pt.pos) * STIFNESS;						
						}
						{
							int jp1 = j - 1;
							if (jp1 < 0) jp1 = m_slices - 1;
							TubePoint* pt2 =  &m_points[jp1 + i * m_slices];		
							pt.acc += (pt2.pos - pt.pos) * STIFNESS;						
						}
						
						pt.nmlAccum = idnml;
						
						// random excitation (prevent denormals)
//						pt.acc += 0.001f * (vec3f(random.nextFloat, random.nextFloat, random.nextFloat) - vec3f(0.5f));
					}
				}
				
				foreach	(ref p; m_points) 
				{
					auto viscosity = exp(-dt * 1);
					p.move(dt, viscosity); // apply forces				
				}
				
				
				// smooth normals
				for (int i = 0; i < m_stacks ; ++i)
				{
					for (int j = 0; j < m_slices; ++j)
					{
						TubePoint* pt = &m_points[j + i * m_slices];	
					
						if (i > 0)
						{
							TubePoint* pt2 =  &m_points[j + (i-1) * m_slices];		
							pt.nmlAccum += pt2.nml;
						}
						
						if (i < m_stacks-1)
						{
							TubePoint* pt2 =  &m_points[j + (i+1) * m_slices];
							pt.nmlAccum += pt2.nml;
						}
						
						{
							int jp1 = j + 1;
							if (jp1 >= m_slices) jp1 = 0;
							TubePoint* pt2 =  &m_points[jp1 + i * m_slices];		
							pt.nmlAccum += pt2.nml;	
						}
						{
							int jp1 = j - 1;
							if (jp1 < 0) jp1 = m_slices - 1;
							TubePoint* pt2 =  &m_points[jp1 + i * m_slices];		
							pt.nmlAccum += pt2.nml;
						}
						
						
						
						pt.nmlAccum.normalize;
					}
				}
				
				float normal_visc = (1.f - exp(-dt * 180.f));
				
				foreach	(ref p; m_points) 
				{
					p.nml += (p.nmlAccum - p.nml) * normal_visc;			
				}	 
			}
		}
		
	}
	
	
	
	private void drawCube(vec3f pos, vec3f size, float texF, bool outerNormal = true)
	{
		void quad(vec3f a, vec3f b, vec3f c, vec3f d, vec3f nml)
		{
			glNormal3fv(nml.ptr);
			glTexCoord2f(0,0);
			glVertex3fv(a.ptr);
			glTexCoord2f(texF * 1,0);
			glVertex3fv(b.ptr);
			glTexCoord2f(texF * 1,texF * 1);
			glVertex3fv(c.ptr);
			glTexCoord2f(0,texF * 1);
			glVertex3fv(d.ptr);
		}
		
		float nf = outerNormal ? 1.f : -1.f;
		auto a = pos + size * vec3f(-1.f, +1.f, +1.f);
		auto b = pos + size * vec3f(+1.f, +1.f, +1.f);
		auto c = pos + size * vec3f(-1.f, -1.f, +1.f);
		auto d = pos + size * vec3f(+1.f, -1.f, +1.f);
		auto e = pos + size * vec3f(-1.f, +1.f, -1.f);
		auto f = pos + size * vec3f(+1.f, +1.f, -1.f);
		auto g = pos + size * vec3f(-1.f, -1.f, -1.f);
		auto h = pos + size * vec3f(+1.f, -1.f, -1.f);
		
		glBegin(GL_QUADS);
		quad(a,b,d,c,vec3f(0,0,nf));
		quad(e,f,b,a,vec3f(0,nf,0));
		quad(b,f,h,d,vec3f(nf,0,0));
		quad(c,g,e,a,vec3f(-nf,0,0));
		quad(c,d,h,g,vec3f(0,-nf,0));
		quad(g,h,f,e,vec3f(0,0,-nf));
		glEnd();
	}
	
}

