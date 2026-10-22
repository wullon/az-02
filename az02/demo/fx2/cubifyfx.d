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
module demo.fx2.cubifyfx;

import demo.whatfxneed;
import demo.sphere;

// draw old texture on a cube

final class CubifyFX : Effect
{
	private
	{
		Shader m_shader;
		Shader m_shaderRec;
		Shader m_shaderWhite;
		float m_rot = 0.f;
		
	}
	
	public
	{
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "CubifyFX", timeSpan, priority);
		}
		
		override void onLoad()
		{
			m_shader = Demo.loadShader("blit");			
			m_shader.setSampler("tex", mainTexture, 0);
			
			m_shaderRec = Demo.loadShader("blit");
			
			m_shaderWhite = putShader;
		}
		
		override void onDraw()
		{
			interFBO.use();
			
			GL.viewport = viewport;
			
			float amount = smoothStep(0,4,lb);
			
			
			
			{
			
				mat4f correctratio = mat4f.scale(vec3f(invRatio, 1.f, 1.f));
				
				auto fov = 60.f + 30.f * amount - 20.f * smoothStep(22,32,lb);
				
				mat4f persp = mat4f.perspective( fov, 1.f, 0.01f, 100.f);
			
				GL.projectionMatrix = correctratio * persp;
			}
			
			auto lb = localBeat;
			
		/*	float rot1 = 1.f - hit(4.f,8.f,lb,2.f) + pulse(8.f, endBeat, lb);//smoothStep(4,8,lb);
			float rot2 = 1.f - hit(10.f,12.f,lb,2.f) + pulse(12.f, endBeat, lb);//smoothStep(10,12,lb);
			float rot3 = 1.f - hit(14.f,18.f,lb,2.f) + pulse(18.f, endBeat, lb);//smoothStep(14,18,lb);
			float rot4 = 1.f - hit(20.f,24.f,lb,2.f) + pulse(24.f, endBeat, lb);//smoothStep(20,24,lb);
		*/
			float rot1 = smoothStep(4,8,lb) + 0.08f * hit(4, 8, lb, 0.3f);
			float rot2 = smoothStep(10,12,lb) + 0.08f * hit(10, 12, lb, 0.3f);
			float rot3 = smoothStep(14,16,lb) + 0.08f * hit(14, 16, lb, 0.3f);
			//float rot4 = smoothStep(20,22,lb) + 0.08f * hit(20, 22, lb, 0.3f);
		
			float eventFin = step(24,32,lb);
			float eventFin2 = step(28,32,lb);
			float movement = 0.f;
			mat4f camMat()
			{
				vec3f getView()
				{
					auto lb = localBeat;
					auto pif2 = 0.5f * PI_F;
					if (lb < 4) return vec3f(0,0,-1);
					if (lb < 8) return vec3f(0,sin(rot1 * PI_F),-cos(rot1 * PI_F));
					if (lb < 10) return vec3f(0,0,+1);
					if (lb < 12) return vec3f(sin(PI_F * 0.5f * rot2),0,+cos(PI_F * 0.5f * rot2));
					if (lb < 14) return vec3f(1,0,0);
					if (lb < 18) return vec3f(cos(PI_F * rot3),-sin(PI_F * rot3),0.f);
					return vec3f(-1,0,0);	
					
				}
				vec3f getUp()
				{
					auto lb = localBeat;
					auto pif2 = 0.5f * PI_F;
					if (lb < 4) return vec3f(0,1,0);
					if (lb < 8) return vec3f(0,cos(rot1 * PI_F),sin(rot1 * PI_F));
					if (lb < 14) return vec3f(0,-1,0);
					if (lb < 18) return vec3f(-sin(PI_F * rot3),-cos(PI_F * rot3),0.f);
					return vec3f(0,1,0);
				}
				
				auto view = getView();
				
				
				auto up = getUp();
				
				
				
				return mat4f.lookAt(- view * 0.7f , view , up);
			}

		
			GL.modelviewMatrix = mat4f.rotateZ(sqr(eventFin) * 5.f) * camMat * mat4f.scale(vec3f(1.f + 0.02f * volumeN(Track.KICK)));
			GL.disable(GL_BLEND, GL_DEPTH_TEST, GL_ALPHA_TEST);
			
			// draw a cube
			float coordCorrect = lerp(1.f, invRatio, amount);
			
			float sizex = lerp(ratio, 1.f, amount);
			
			m_shaderRec.setSampler("tex", lastInterTexture, 0);
			
			{
				
				vec3f size = vec3f(sizex * 1.f,1.f,1.f);
				float texcoordx = coordCorrect;
			
				void quad(vec3f a, vec3f b, vec3f c, vec3f d, vec3f nml)
				{
					glNormal3fv(nml.ptr);
					vec2f ta = vec2f(0.5f + 0.5f * texcoordx,0);
					vec2f tb = vec2f(0.5f - 0.5f * texcoordx,0);
					vec2f tc = vec2f(0.5f - 0.5f * texcoordx,1);
					vec2f td = vec2f(0.5f + 0.5f * texcoordx,1);
					
					
					glTexCoord2fv(ta.ptr);
					glVertex3fv(a.ptr);
					glTexCoord2fv(tb.ptr);
					glVertex3fv(b.ptr);
					glTexCoord2fv(tc.ptr);
					glVertex3fv(c.ptr);
					glTexCoord2fv(td.ptr);
					glVertex3fv(d.ptr);
				}
			
				float nf = -1.f;
				auto a = size * vec3f(-1.f, +1.f, +1.f);
				auto b = size * vec3f(+1.f, +1.f, +1.f);
				auto c = size * vec3f(-1.f, -1.f, +1.f);
				auto d = size * vec3f(+1.f, -1.f, +1.f);
				auto e = size * vec3f(-1.f, +1.f, -1.f);
				auto f = size * vec3f(+1.f, +1.f, -1.f);
				auto g = size * vec3f(-1.f, -1.f, -1.f);
				auto h = size * vec3f(+1.f, -1.f, -1.f);
				
				{
					
					void right() { quad(b,f,h,d,vec3f(nf,0,0)); } 
					void left() { quad(c,g,e,a,vec3f(-nf,0,0)); } 
					void forward() { quad(g,h,f,e,vec3f(0,0,-nf)); } 
					void up() { quad(e,f,b,a,vec3f(0,nf,0)); } 
					void down() { quad(c,d,h,g,vec3f(0,-nf,0)); } 
					void rear() { quad(a,b,d,c,vec3f(0,0,nf)); } 
					auto const L = 0.999f;
					m_shader.use();
					glColor3f(1.f,1.f,1.f);
					glBegin(GL_QUADS);
						up;
						down;
						
						if (rot1 < L) rear;
						if (rot2 < L) right;
						
						//if (rot3 < L) left;
						if (gt < minsec(3,40.309)) left;
						forward;
						
					glEnd();
					glColor3f(0.96f,0.96f,0.98f);
					m_shaderRec.use();
					glBegin(GL_QUADS);
						if (rot1 >= L) rear;
						if (rot2 >= L) right;
						//if (rot3 >= L) left;
						if (gt > minsec(3,40.309)) left;
						forward;
					glEnd();
					
					GL.disable(GL_DEPTH_TEST, GL_ALPHA_TEST);
					GL.enable(GL_BLEND);
					GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
					            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
					            
					m_shaderWhite.use();
					float alpha = eventFin * eventFin;
					glColor4f(1.f,1.f,1.f,alpha);
					
					glBegin(GL_QUADS);
						up;
						down;
					glEnd();
				}	
			}
		}
		
		override void onMove()
		{
			m_rot += dt * step(4,12,lb) * PI_F;
		}
	}
}

