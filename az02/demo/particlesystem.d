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
module demo.particlesystem;

import gl.all;
import demo.particle;
import demo.demo;
import util.geometry.all;
import util.all;

// This do not what it is supposed to do because sizing does not work

final class ParticleSystem
{
	private
	{
		Shader m_shader;
		Texture2D m_pointTexture;
		
		Particle[] m_particles;	
		int m_count;
		float m_viscosity_force;
		float m_intensity; // color multiplier (to overcome the clamping)
		
		float m_minDist, m_maxDist, m_minSize, m_maxSize;
		
	}
	
	public
	{
		this(int max, char[] textureFile )
		{			
			m_pointTexture = Demo.loadTexture2D(textureFile, 
			                                    Texture.IFormat.RGBA8,
			                                    Texture.Filter.NEAREST_MIPMAP_LINEAR,  
			                                    Texture.Filter.LINEAR, 
			                                    Texture.Wrap.REPEAT, 
			                                    true, false);
			m_particles.length = max;
			m_count = 0;
			m_shader = Demo.loadShader("particle");
			m_shader.setSampler("tex", m_pointTexture, 0);
			
			m_viscosity_force = 1.f;
			m_intensity = 1.f;
			m_minDist = 0;
			m_maxDist = 1;
			m_minSize = 30;
			m_maxSize = 1;
		}
		
		float intensity() { return m_intensity; }
		float intensity(float i) { return m_intensity = i; }
		
		float viscosityForce() { return m_viscosity_force; }
		float viscosityForce(float f) { return m_viscosity_force = f; }
		
		float minDist() { return m_minDist; }
		float minDist(float f) { return m_minDist = f; }
		
		float maxDist() { return m_maxDist; }
		float maxDist(float f) { return m_maxDist = f; }
		
		float minSize() { return m_minSize; }
		float minSize(float f) { return m_minSize = f; }
		
		float maxSize() { return m_maxSize; }
		float maxSize(float f) { return m_maxSize = f; }
			
		void addParticle(vec3f pos, vec3f mov, vec4f color, float life)
		{
			if (m_count < m_particles.length)
			{
				m_particles[m_count++] = Particle(pos, mov, color, life);
			}	
		}
		
		void draw(float globalAlpha = 1.f)
		{
			
			m_shader.set1f("intensity", m_intensity);
			m_shader.set1f("minDist", m_minDist);
			m_shader.set1f("maxDist", m_maxDist);
			m_shader.set1f("minSize", m_minSize);
			m_shader.set1f("maxSize", m_maxSize);
			
			m_shader.use();
			
			            
			glBegin(GL_POINTS);			
			for (int i	= 0; i < m_count; ++i)
			{
				m_particles[i].draw(globalAlpha);
			}
			glEnd();
			
		
		}
		
		void move(float dt)
		{
			auto visco_factor = exp(-dt * m_viscosity_force);
			
			for (int i	= 0; i < m_count; ++i)
			{
				m_particles[i].move(dt, visco_factor);
			}
			cleanDeadParticles();			
			
		}
		
		void cleanDeadParticles()
		{
			int i = 0;
			while (i < m_count)
			{
				if (m_particles[i].isDead())
				{
					m_particles[i] = m_particles[--m_count];
				} 
				else 
				{
					i++;
				}
			}
			
		}
	}
}

