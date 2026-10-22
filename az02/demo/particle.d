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
module demo.particle;

import gl.all;
import util.all;
import util.geometry.all;
import sdl.all;


struct Particle
{
	private
	{
		auto const QUEUE = 10;
		
		vec3f m_pos;
		vec3f m_mov;
		vec3f m_acc;
		vec4f m_color;
		vec3f m_posm1;
		float m_life;
		float m_shine;
		vec3f[QUEUE] m_oldPos;
		Random m_random;
	}
	
	public
	{
		
		static Particle opCall(vec3f pos, vec3f mov, vec4f color, float life)
		{
			Particle pr = void;
			pr.m_pos = pos;
			pr.m_mov = mov;
			pr.m_acc = vec3f(0.f);
			pr.m_color = color;
			pr.m_life = life;
			pr.m_oldPos[] = pos;
			pr.m_shine = 0.f;
			pr.m_random = Random();
			return pr;
		}
		
		bool isDead()
		{
			return m_life <= 0;	
		}	
		
		bool isAlive()
		{
			return m_life > 0;	
		}			
		
		void move(float dt, float visco)
		{
			m_life -= dt;
			m_mov += dt * m_acc;			
			
			m_acc = vec3f(0.f);
			
			m_oldPos[0] = m_pos;
			for (int i = QUEUE - 1; i >= 1; --i)
			{
				m_oldPos[i] = m_oldPos[i-1];
			}
			
			m_pos += dt * m_mov;
			m_mov *= visco;		
			m_shine = 0.5f * m_shine + 0.5 * m_random.nextFloat();
		}
		
		void applyForce(vec3f force)
		{
			m_acc += force;
		}
		
		void draw(float g_alpha)
		{
			float alpha = min(1.f, m_life ) * m_color.w * g_alpha;
			glColor4f(m_color.x, m_color.y, m_color.z, alpha * m_shine);		 // m_life is clamped
			glVertex3fv(m_pos.ptr);
			
			for (int i = 0; i < QUEUE; ++i)
			{
				alpha *= 0.8f;
				glColor4f(m_color.x, m_color.y, m_color.z, alpha);
				glVertex3fv(m_oldPos[i].ptr);
			}
		}
	}
}

static assert(Particle.sizeof % 4 == 0);