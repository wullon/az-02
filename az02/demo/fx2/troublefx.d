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
module demo.fx2.troublefx;

import demo.whatfxneed;
import demo.fluidsolver;



final class TroubleFX : Effect
{
	
	private
	{
		const SIZE = 64;
		FluidSolver!(6) m_solver;
		Shader m_shader, m_blit;
		Texture2D texu, texv, water, insect;
		byte[] texubuf, texvbuf;
		Random random;
		
		double m_angleGr = 0.f;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "TroubleFX", timeSpan, priority);
		}		
		
		override void onLoad()
		{
			m_solver = new FluidSolver!(6)();
			
			texu	= new Texture2D(Texture.IFormat.I16F, false);
			texu.minFilter = Texture.Filter.LINEAR;
			texu.magFilter = Texture.Filter.LINEAR;
			texu.wrapS = Texture.Wrap.MIRRORED_REPEAT;
			texu.wrapT = Texture.Wrap.MIRRORED_REPEAT;
			texu.setImage(0, SIZE, SIZE, Texture.Format.INTENSITY, Texture.Type.FLOAT, m_solver.velocityX.ptr, false);
			
			water = commonTexture(CommonTexture.WATER);
			insect = commonTexture(CommonTexture.INSECT);
			
			texv	= new Texture2D(Texture.IFormat.I16F, false);
			texv.minFilter = Texture.Filter.LINEAR;
			texv.magFilter = Texture.Filter.LINEAR;
			texv.wrapS = Texture.Wrap.MIRRORED_REPEAT;
			texv.wrapT = Texture.Wrap.MIRRORED_REPEAT;
			texv.setImage(0, SIZE, SIZE, Texture.Format.INTENSITY, Texture.Type.FLOAT, m_solver.velocityY.ptr, false);
			
			texubuf.length = SIZE * SIZE;
			texvbuf.length = SIZE * SIZE;
				
			m_shader = Demo.loadShader("water");
			m_shader.setSampler("tex", water, 0);
			m_shader.setSampler("texu", texu, 1);
			m_shader.setSampler("texv", texv, 2);
			random = Random();
			
			m_blit = Demo.loadShader("blit");
			m_blit.setSampler("tex", insect, 0);
			
		}
		
		override void onDraw()
		{
			interFBO.use();
			
			GL.viewport = viewport;
			
			
			
			auto zoom = 1.f + lt * 0.04f;
			auto rotation = lt * 0.f;
			
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1, 1));
			GL.modelviewMatrix = mat4f.scale(vec3f(zoom, zoom, 1.f)) * mat4f.rotateZ(rotation);
			
			
			GL.disable(GL_STENCIL_TEST, GL_DEPTH_TEST, GL_ALPHA_TEST, GL_POLYGON_SMOOTH);
			GL.enable(GL_BLEND);
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			
			auto spacing = 0.34f * pow(2.f, 10 * axis(0));
			
			m_shader.set1f("spacing", spacing);
			m_shader.set1f("ratio", ratio);
			m_shader.use();
			
			GL.enable(GL_BLEND);
			float alpha = 0.3f + step(15,25,lt) * 0.63f;
			vec2f wsize = ratio * vec2f(1.f, 1.f * 723.f / 1385.f);		
				
			{
				
				
				
				glBegin(GL_QUADS);	
					GL.color = vec4f(vec3f(0.4 + axis(0)), alpha);		
					glTexCoord2f(0.0, 0.5 - 0.5f * invRatio); glVertex2f(-ratio, -1);	
					glTexCoord2f(1.0, 0.5 - 0.5f * invRatio); glVertex2f(+ratio, -1);	
					glTexCoord2f(1.0, 0.5 + 0.5f * invRatio); glVertex2f(+ratio, +1);	
					glTexCoord2f(0.0, 0.5 + 0.5f * invRatio); glVertex2f(-ratio, +1);			
				glEnd();
			}
			
			m_blit.use();
			
			GL.enable(GL_BLEND, GL_ALPHA_TEST);
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			
			
		/*	
			for (int i = 0; i < 3; ++i)
			{
				vec3f color = vec3f(0.5);
				float a = TWO_PI_F * i / 3.f;
				
				float x = lerp(-ratio, ratio, 0.5 + 0.15 * cos(m_angleGr+a));
				float y = lerp(-ratio, ratio, 0.5 + 0.15 * sin(m_angleGr+a));
				auto size = 0.025f;
				glPushMatrix();
				glTranslatef(x,y,0);
				glRotatef((m_angleGr+a) * 180 / PI_F,0.f,0.f,1.f);
				glBegin(GL_QUADS);	
					GL.color = vec4f(color,alpha);
					glTexCoord2f(0,0); glVertex2f(- size,- size);
					glTexCoord2f(0,1); glVertex2f(- size,+ size);
					glTexCoord2f(1,1); glVertex2f(+ size,+ size);
					glTexCoord2f(1,0); glVertex2f(+ size,- size);
				glEnd();
				glPopMatrix();
			}
		*/	
			putShader.use();
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1, 1));
			GL.modelviewMatrix = mat4f.identity;
			
			glBegin(GL_QUADS);	
				glColor4f(0,0,0,alpha);				
				glVertex2f(+ratio, 3);	
				glVertex2f(+ratio, +wsize.y);	
				glVertex2f(-ratio, +wsize.y);			
				glVertex2f(-ratio, 3);	
				glVertex2f(+ratio, -3);	
				glVertex2f(+ratio, -wsize.y);	
				glVertex2f(-ratio, -wsize.y);			
				glVertex2f(-ratio, -3);				
			glEnd();
			
			float eventFin = step(10, endTime, lt);
			{	
				GL.enable(GL_BLEND);
				GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
				            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
				            
				putShader.use();
				glBegin(GL_QUADS);
					float a = alpha * eventFin;
					glColor4f(0,0,0,a);
					glVertex2f(-ratio, -1.f);
					glVertex2f(+ratio, -1.f);
					glVertex2f(+ratio, +1.f);
					glVertex2f(-ratio, +1.f);
				glEnd();
			}
			
		}
		
		
		override void onMove()
		{	
			m_solver.viscosity = 0.0005f;
			m_solver.diffusion = 1.f;
			m_angleGr += dt * 0.05f;
			
			m_angleGr -= volumeN(Track.GRAINDO) * dt * 10;
			
			for (int i = 0; i < 3; ++i)
			{
				float a = TWO_PI_F * i / 3.f;
				auto power = 1 * (2 + 1.f * volumeN(Track.GRAINDO) * sin(2.f * PI_F * 50.f * lt));
				//auto power = random.nextFloat2 * 20;//+ 2 + volumeN(Track.GRAINDO) * sin(2.f * PI_F * 5.f * lt);
				
				m_solver.applyVortex(round(SIZE * 0.5 + SIZE * 0.15 * cos(m_angleGr+a)),
				                     round(SIZE * 0.5 + SIZE * 0.15 * sin(m_angleGr+a)), 15,  power * dt  );
			}
			
	
			m_solver.move(dt);
			/*
			// create smaller textures
			float* uptr = m_solver.velocityX.ptr;
			float* vptr = m_solver.velocityY.ptr;
			for (int i = 0; i < SIZE*SIZE;++i)
			{
				texubuf[i] = cast(byte)(uptr[i] / 0.02f);
				texvbuf[i] = cast(byte)(vptr[i] * 0.02f);
			}
			*/
			
			// upload texture (calls glTexSubImage2D)
			
			//texu.setImage(0, SIZE, SIZE, Texture.Format.INTENSITY, Texture.Type.BYTE, texubuf.ptr, false);
			//texv.setImage(0, SIZE, SIZE, Texture.Format.INTENSITY, Texture.Type.BYTE, texvbuf.ptr, false);			
			texu.setImage(0, SIZE, SIZE, Texture.Format.INTENSITY, Texture.Type.FLOAT, m_solver.velocityX.ptr, false);
			texv.setImage(0, SIZE, SIZE, Texture.Format.INTENSITY, Texture.Type.FLOAT, m_solver.velocityY.ptr, false);			
			
			texu.generateMipmaps();
			texv.generateMipmaps();
			
			
		}
	}
}

