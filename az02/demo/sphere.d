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
module demo.sphere;

// simple sphere 
// yes, it's inefficient

import util.geometry.vec2;
import util.geometry.vec3;
import util.geometry.vec4;
import util.math;
import demo.demo;

import gl.all;

class Sphere
{
	public
	{
		vec3f m_pos;
		float m_radius;
		Shader m_shader;
		
		int m_slices, m_stacks;		
		
		vec3f m_top, m_bottom;
		vec3f[] m_points;
		vec3f m_size;
		vec4f m_color;
		float m_normalFactor;
		
		static vec3f sphereMap(float theta, float phi)
		{
			
			float cost = void, sint = void;
			float cosp = void, sinp = void;
			sincos(theta, sint, cost);
			sincos(phi, sinp, cosp);
			
			return vec3f(cos(phi) * cos(theta), sin(phi) * cos(theta), sin(theta));
		}
		
		void computeGeometry(int stacks, int slices)
		{
			m_slices = slices;
			m_stacks = stacks;
			
			m_points.length = (m_stacks-1)  * m_slices;
			
			m_top = vec3f(0,0,1);
			m_bottom = vec3f(0,0,-1);
			
			
			for (int i = 0; i < m_stacks - 1; ++i)
			{
				for (int j = 0; j < m_slices; ++j)
				{
					float theta = TWO_PI_F * ( (i + 1.f) / m_stacks  - 0.5f);
					float phi = (TWO_PI_F * j) / m_slices;					
					m_points[j + i * m_slices] = sphereMap(theta, phi);
				}
			}
		}
		
		void vertex(vec3f p) // p should be normalized
		{
			GL.normal(p * m_normalFactor);
			GL.vertex(m_radius * p);
		}
		
		vec3f pt(int i, int j)
		{
			return m_points[j + i * m_slices];
		}
	}	
	
	public
	{
		this(Shader shader, int stacks, int slices, bool normalOutside)
		{
			m_pos = vec3f(0.f,0.f,0.f);
			m_radius = 1.f;
			m_shader = shader;
			m_size = vec3f(1.f,1.f,1.f);
			computeGeometry(stacks, slices);
			m_normalFactor = normalOutside ? 1.f : -1.f;
			
		}
		
		vec3f pos() 
		{ 
			return m_pos;
		}
		
		vec3f pos(vec3f p) 
		{ 
			return m_pos = p;
		}
				
		float radius() 
		{ 
			return m_radius;
		}
		
		float radius(float s) 
		{ 
			return m_radius = s;
		}
		
		vec4f color() 
		{ 
			return m_color;
		}
		
		vec4f color(vec4f p) 
		{ 
			return m_color = p;
		}
		
		vec3f size() 
		{ 
			return m_size;
		}
		
		vec3f size(vec3f p) 
		{ 
			return m_size = p;
		}
		
		void draw()
		{
			m_shader.use();
			
			glPushMatrix();
			glTranslatef(pos.x, pos.y, pos.z);			
			glScalef(m_size.x, m_size.y, m_size.z);
			
			GL.color = m_color;
			
			// bottom
			glBegin(GL_TRIANGLE_FAN);			
				vertex(m_bottom);
				
				for (int j = 0; j < m_slices; ++j)
				{
					vertex(pt(0, j));
				}
				vertex(pt(0, 0));
				
			glEnd();
			
			
			for (int i = 0; i < m_stacks - 2; ++i)
			{
				glBegin(GL_QUAD_STRIP);
				
				for (int j = 0; j < m_slices; ++j)
				{
					vertex(pt(i+1,j));
					vertex(pt(i,j));
					
				}
				vertex(pt(i+1,0));
				vertex(pt(i,0));
				
				
				glEnd();
			}
			
			// top
			glBegin(GL_TRIANGLE_FAN);	
				vertex(m_top);
				for (int j = 0; j < m_slices; ++j)
				{
					vertex(pt(m_stacks - 2, j));
				}
				vertex(pt(m_stacks - 2, 0));
			glEnd();
			
			
			glPopMatrix();			
		}
	}
	
}	