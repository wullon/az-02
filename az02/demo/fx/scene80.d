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
module demo.fx.scene80;
import demo.whatfxneed;
import demo.torus;




final class Scene80 : Effect
{
	const enum Face { LEFT, RIGHT, UP, DOWN, FORWARD, BACKWARD };		
	const int NCUBES = 50;
	const double CUBE_SIZE = 3.0;
	
	static Face opposite(Face f)
	{
		switch (f)
		{
			case Face.LEFT: return Face.RIGHT;	
			case Face.RIGHT: return Face.LEFT;	
			case Face.UP: return Face.DOWN;	
			case Face.DOWN: return Face.UP;	
			case Face.FORWARD: return Face.BACKWARD;	
			case Face.BACKWARD: return Face.FORWARD;	
			default: assert(false);
		}
	}
	
	static vec3f faceDir(Face f)
	{
		switch (f)
		{
			case Face.LEFT: return vec3f(-1,0,0);
			case Face.RIGHT: return vec3f(+1,0,0);
			case Face.UP: return vec3f(0,1,0);
			case Face.DOWN: return vec3f(0,-1,0);
			case Face.FORWARD: return vec3f(0,0,-1);
			case Face.BACKWARD:  return vec3f(0,0,+1);
			default: assert(false);
		}
	}
	
	
	private class Cube
	{
		Face m_input;
		Face m_output;
		vec3f m_pos;
		vec3f m_midDir;
		
		this(vec3f pos, Face input, Face output)
		{
			m_input = input;
			m_output = output;
			m_pos = pos;
			assert(input != output);
			
			m_midDir = (inputDir() + outputDir()).normalized;
		}	
		
		bool isStraight()
		{
			return 	m_input == opposite(m_output);
		}
		
		bool isTurn()
		{
			return 	!isStraight;
		}
		
		
		vec3f inputDir()
		{
			return -faceDir(m_input);
		}
		
		vec3f outputDir()
		{
			return faceDir(m_output);
		}
		
		vec3f midDir()
		{
			return m_midDir;	
		}
		
		vec3f pos()
		{
			return m_pos;	
		}
		
		void quad(Face f, vec3f a, vec3f b, vec3f c, vec3f d, vec3f nml, float excursion)
		{
			if ((m_input != f) && ( m_output != f))
			{
				
				float excursion_max = excursion;
				vec3f nmodx = (d - a).normalized;
				vec3f nmody = (b - a).normalized;
				
				for (int i = 0; i < 16; ++i)
				{
					float ti = i / 16.f;
					float tip1 = (i + 1) / 16.f;
					vec3f pt = a * (1.f - ti) + d * ti;
					vec3f pt2 = a * (1.f - tip1) + d * tip1;
					vec3f pt3 = b * (1.f - ti) + c * ti;
					vec3f pt4 = b * (1.f - tip1) + c * tip1;
					
					for (int j = 0; j < 16; ++j)
					{
						
						float tj = j / 16.f;
						float tjp1 = (j + 1) / 16.f;
						
						float ea = excursion_max * max!(float)(0.f, 1.f - 4.f * (ti - 0.5f) * (ti - 0.5f) - 4.f * (tj - 0.5f) * (tj - 0.5f));
						float eb = excursion_max * max!(float)(0.f, 1.f - 4.f * (ti - 0.5f) * (ti - 0.5f) - 4.f * (tjp1 - 0.5f) * (tjp1 - 0.5f));
						float ec = excursion_max * max!(float)(0.f, 1.f - 4.f * (tip1 - 0.5f) * (tip1 - 0.5f) - 4.f * (tjp1 - 0.5f) * (tjp1 - 0.5f));
						float ed = excursion_max * max!(float)(0.f, 1.f - 4.f * (tip1 - 0.5f) * (tip1 - 0.5f) - 4.f * (tj - 0.5f) * (tj - 0.5f));
						
						
						vec3f pa = pt * (1.f - tj) + pt3 * tj + ea * nml;
						vec3f pb = pt * (1.f - tjp1) + pt3 * tjp1 + eb * nml;
						vec3f pd = pt2 * (1.f - tj) + pt4 * tj + ed * nml;
						vec3f pc = pt2 * (1.f - tjp1) + pt4 * tjp1 + ec * nml;
						
						vec3f na = nml + ea * (nmodx * (ti - 0.5f) + nmody * (tj - 0.5f));
						vec3f nb = nml + eb * (nmodx * (ti - 0.5f) + nmody * (tjp1 - 0.5f));
						vec3f nd = nml + ed * (nmodx * (tip1 - 0.5f) + nmody * (tjp1 - 0.5f));
						vec3f nc = nml + ec * (nmodx * (tip1 - 0.5f) + nmody * (tj - 0.5f));
						
						glNormal3fv(na.ptr);						
						glTexCoord2f(tip1,tj);
						glVertex3fv(pa.ptr);
						
						glNormal3fv(nb.ptr);						
						glTexCoord2f(tip1,tjp1);
						glVertex3fv(pb.ptr);
						
						glNormal3fv(nc.ptr);
						glTexCoord2f(ti,tjp1);
						glVertex3fv(pc.ptr);
						
						glNormal3fv(nd.ptr);
						glTexCoord2f(ti,tj);
						glVertex3fv(pd.ptr);
						
					}
				}
			}
		}
		
		void draw(float excursion)
		{
			
			auto a = m_pos + CUBE_SIZE * vec3f(-0.5f, +0.5f, +0.5f);
			auto b = m_pos + CUBE_SIZE * vec3f(+0.5f, +0.5f, +0.5f);
			auto c = m_pos + CUBE_SIZE * vec3f(-0.5f, -0.5f, +0.5f);
			auto d = m_pos + CUBE_SIZE * vec3f(+0.5f, -0.5f, +0.5f);
			auto e = m_pos + CUBE_SIZE * vec3f(-0.5f, +0.5f, -0.5f);
			auto f = m_pos + CUBE_SIZE * vec3f(+0.5f, +0.5f, -0.5f);
			auto g = m_pos + CUBE_SIZE * vec3f(-0.5f, -0.5f, -0.5f);
			auto h = m_pos + CUBE_SIZE * vec3f(+0.5f, -0.5f, -0.5f);
		
			
			glBegin(GL_QUADS);
				quad(Face.BACKWARD, a,b,d,c,vec3f(0,0,-1), excursion);
				quad(Face.UP, e,f,b,a,vec3f(0,-1,0), excursion);
				quad(Face.LEFT, c,g,e,a,vec3f(1,0,0), excursion);
				quad(Face.RIGHT, b,f,h,d,vec3f(-1,0,0), excursion);
				quad(Face.DOWN, c,d,h,g,vec3f(0,1,0), excursion);
				quad(Face.FORWARD, g,h,f,e,vec3f(0,0,1), excursion);
			glEnd();
			
			
			
		
		}
		
	}
	
	private // get the path to take
	{
		vec3f getPos(float prog)
		{
			
			float p = prog * (NCUBES - 2);
						
			int index = trunc(p);
			float fr = p - index;
			
			Cube c0 = getCube(index - 1);
			Cube c1 = getCube(index );
			Cube c2 = getCube(index + 1);
			Cube c3 = getCube(index + 2);
			
			return hermite!(vec3f)(fr, c0.pos, c1.pos, c2.pos, c3.pos);
		}
		
		Cube getCube(int index)
		{
			if (index < 0) index = 0;	
			if (index > NCUBES - 1) index = NCUBES - 1;
			return m_cubes[index];
		}
		
		vec3f getDir(float prog)
		{
			
			float p = prog * (NCUBES - 2) + 1; // tourne en avance
						
			int index = trunc(p);
			float fr = p - index;
			
			Cube c0 = getCube(index - 1);
			Cube c1 = getCube(index );
			Cube c2 = getCube(index + 1);
			Cube c3 = getCube(index + 2);
			
			return hermite!(vec3f)(fr, c0.midDir, c1.midDir, c2.midDir, c3.midDir).normalized;
		}
		
		
	}
	
	private class Entity // something in the tunnel
	{
		private
		{
			vec3f m_up, m_right, m_dir;
			vec3f m_pos;
			vec3f m_vel;
			float m_exponent;
			float m_exponent2;
		}	
		
		public
		{
			this(float exponent1, float exponent2)
			{
				m_up = vec3f(0,1,0);
				m_right = vec3f(1,0,0);
				m_dir = vec3f(0,0,1);
				m_pos = vec3f(0);
				m_vel = vec3f(0);
				m_exponent = exponent1;
				m_exponent2 = exponent2;
			}
			
			void move(float dt, float progression, float rotate)
			{
				
				
				vec3f dest_pos = getPos(progression);
				
				float pos_factor = 1.f - exp(-m_exponent2);
				m_pos += (dest_pos - m_pos) * pos_factor;
				
				vec3f dest_dir = getDir(progression);
				
				// camera rotation77
				{
					float angle = dt * rotate;
					float sine = sin(angle);
					float cose = cos(angle);
					
					vec3f new_up = cose * m_up - sine * m_right;
					vec3f new_right = cose * m_right + sine * m_up;
					
					m_right = new_right.normalized;
					m_up = new_up.normalized;
				}
				
				// rotate the view
				
				float visco_factor = 1.f - exp(-dt * m_exponent);
				
				
				m_dir += (dest_dir - m_dir) * visco_factor; // not exactly accurate 
				m_dir.normalized;
				
				m_up = vec3f.cross(m_right, m_dir).normalized;
				
				m_right = vec3f.cross(m_dir, m_up).normalized;
				m_dir = vec3f.cross(m_up, m_right).normalized;
				
			}	
			
			mat4f camMatrix()
			{
				return mat4f.lookAt(m_pos , m_pos + m_dir, m_up);	
			}
			
			mat4f matrix()
			{
				return mat4f(mat3f(m_right, m_dir, m_up).transposed);	
			}
			
			vec3f pos() { return m_pos; }
			
		}
	}

	
	private
	{
		
		Shader m_shader;
		
	
		Cube[] m_cubes;
		
		Entity m_camera;
		Entity m_objectPos;
		Torus m_male;
		Torus m_female;
	}
		
	public
	{
		Torus male() { return m_male; }	// the male torus is reused in scene 85
		Shader maleShader() { return m_shader; }	// the male torus is reused in scene 85
	}
	
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "Scene80", timeSpan, priority);						
		}
		
		const float SMALL_RADIUS = 0.3f;
		const float LARGE_RADIUS = 0.65f;
				
		override void onLoad()
		{
			m_shader = Demo.loadShader("lambert2");
			m_shader.setSampler("noise", commonTexture(CommonTexture.PINK_NOISE),0 );
			m_shader.setSampler("tex", commonTexture(CommonTexture.CHECKERS),1 );
			
			m_cubes.length = NCUBES;
			
			vec3f pos = vec3f(0.f);
			Face face = Face.FORWARD;
			
			Random random = Random(69);
			
			int i = 0; 
			
			while (i < m_cubes.length)
			{
				
				int n = (i == 0) ? 15 : random.nextRange(1, 5) * 2 - 1;
				
				// straight
				for (int j = 0; j < n; ++j)
				{
					pos += CUBE_SIZE * faceDir(opposite(face));
					m_cubes[i++] = new Cube(pos, face, opposite(face));
					
					if (i >= m_cubes.length) break;
				}
				if (i >= m_cubes.length) break;
				// turn
				Face newf = void;
				do
				{
					newf = cast(Face)random.nextRange(Face.max + 1);
				}	
				while ((newf == face) || (newf == opposite(face)));
				assert(newf >= Face.min);
				assert(newf <= Face.max);
				pos += CUBE_SIZE * faceDir(opposite(face));
				m_cubes[i++] = new Cube(pos, face, newf);
				face = opposite(newf);
			}
			
			
			m_camera = new Entity(9, 45);
			m_objectPos = new Entity(9, 45);
			
			
			m_male = new Torus(80, 40);			
			
			m_female = new Torus(80, 40);
			
		}
		
		
		
		override void onDraw()
		{
			mainFBO.use();
			GL.viewport = viewport;
			
			float fov = 60.f;
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1.f, 1.f)) * mat4f.perspective( fov, 1.f, 0.01, 100.f);
			
			
			mat4f cameraMatrix = m_camera.camMatrix();
			GL.modelviewMatrix = cameraMatrix;
			
			GL.disable(GL_BLEND, GL_ALPHA_TEST, GL_CULL_FACE);
			GL.enable(GL_RESCALE_NORMAL);
 			
			glClearColor(0,0,0,1);
 			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			
			float eventFin = smoothStep( endBeat - 8, endBeat, lb );
			
			m_shader.set3f("ambientColor", lerp(rgb(0x480810), rgb(0x000000), eventFin));
			m_shader.set3f("light1Color", lerp(rgb(0x552b48), rgb(0x004400), eventFin));
			m_shader.set3f("light2Color", lerp(rgb(0x48552b), rgb(0x333300), eventFin));
			m_shader.set3f("light3Color", lerp(rgb(0x2b4855), rgb(0x332000), eventFin));
			
			
			m_shader.set3f("light1Pos", m_camera.pos + m_camera.m_right * 0.6 - m_camera.m_up * 0.5);
			m_shader.set3f("light2Pos", m_camera.pos - m_camera.m_right * 0.6 - m_camera.m_up * 0.5);
			m_shader.set3f("light3Pos", m_camera.pos + m_camera.m_up * 0.7);
			
			auto specularF = 5.5f;
			m_shader.set1f("light1Specular", specularF);
			m_shader.set1f("light2Specular", specularF);
			m_shader.set1f("light3Specular", specularF);

			m_shader.use();
			
			
			
			{
				float p = progression * (NCUBES - 1);
				if (p < 0.f) p = 0.f;
				if (p > (NCUBES - 1)) p = (NCUBES - 1) - 0.001f;
			
				int index = trunc(p);
				
				GL.enable(GL_DEPTH_TEST);
				glDepthFunc(GL_LEQUAL);
			
				GL.color = vec4f(1,1,1,0.5);
				
				
				for( int i = index - 2; i < index + 20; ++i)
				{
					if ((i >= 0) && (i < m_cubes.length))
					{
						float excursion = 0.7f - 0.2f * ( (smoothStep(15,16,lb) - smoothStep(16,17,lb))
				                                        + (smoothStep(31,32,lb) - smoothStep(32,33,lb))) 
				                                        
				                                        + sin(i * 0.5 + lt) * 0.2f;
				
						
						
						float exc = excursion * (((i & 1) == 0) ? 1.f : -1.f);
						if (i == NCUBES - 1) exc = 3.f;
						m_cubes[i].draw(exc);
					}
				}
				
				
			
			}
			
			
			m_shader.use();
			
			GL.color = rgb(0x93a0ff);
			m_male.draw();
			
			
			GL.color = rgb(0xff93a1);			
			m_female.draw();
			GL.disable(GL_RESCALE_NORMAL);
			
			/*auto d1 = 0.85;
			auto d2 = 3.5;
			*/
			
			float endE = step(endBeat - 4, endBeat, lb);
			
			blurAmount = (0.5 + 10.5f * hit(0,8,lb, 4.f) + volumeN(Track.KICK)) * (1.f - endE);
			blurType = 1.5 - 0.3 * volumeN(Track.PERCUS) - 1.8 * endE;
			
			//display(d1, d2);
		}
		
		override void onMove()
		{
			float cameraRot = 0.8f - 1.6f * smoothStep(31.f,33.f,lb);
			
			m_camera.move(dt, progression, cameraRot);
			
			float distObject = 0.5f * (1 - step(13,21,lb)) + 0.011f + 0.0005f * sin(lt);
			
			m_objectPos.move(dt, progression + distObject, cameraRot);
			
			{
				float sdisp = (step(32, 36, lb) * 0.12 + 0.03f) * 0.5f;//volumeN(Track.MB, 0.075f);
				
				
				double pulseSmooth(double a, double b, double t)
				{
					return smoothStep(a - 2, a + 2, t) - smoothStep(b - 2, b + 2, t);
				}
				
				auto mm = pulseSmooth(0, 4, lb)
				        + pulseSmooth(8, 12, lb)
				        + pulseSmooth(16, 20, lb)
				        + pulseSmooth(24, 28, lb)
				        + pulseSmooth(32, 36, lb)
				        + pulseSmooth(40, 44, lb)
				        + pulseSmooth(48, 52, lb)
				        + step(56 - 0.5, 56 + 0.5, lb);
				
				  
				float dist = 0.5f;//1.6f - 1.1f * smoothStep(31.f, 33.f, lb);
			    float angleFem = /* step(0,32,lb) * TWO_PI_F * 4.f+*/ PI_F * 0.5f;      
				float msize = 0.1f + sdisp * mm + step(endBeat - 4, endBeat, lb) * 0.1f;
				float fsize = (0.1f + sdisp * (1.f - mm)) * (1.f - step(endBeat - 4, endBeat, lb) * 0.5);
				
				
				m_male.smallRadius = SMALL_RADIUS - 0.35 + msize * 3;
				m_male.largeRadius = LARGE_RADIUS;
				
				m_female.smallRadius = SMALL_RADIUS - 0.35 + fsize * 3;
				m_female.largeRadius = LARGE_RADIUS;
				
				
				m_male.pos = m_objectPos.pos;
				m_female.pos = m_objectPos.pos;
				
				mat4f rot = m_objectPos.matrix * mat4f.rotateX(lt * 1.7579f) * mat4f.rotateY(lt * -1.33);
				
				
				
				m_male.matrix = rot * mat4f.translate(vec3f(LARGE_RADIUS * dist + sdisp * mm, 0, 0)) * mat4f.rotateZ(lt);
				m_female.matrix = rot * mat4f.translate(-vec3f(LARGE_RADIUS * dist + sdisp * (1.f - mm), 0, 0)) * mat4f.rotateX(angleFem) * mat4f.rotateZ(lt);
				m_male.size = vec3f(0.3f);
				m_female.size = vec3f(0.3f);
			}
		}
	}
}

