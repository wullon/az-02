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
module demo.torus;

// a torus

import util.geometry.vec2;
import util.geometry.vec3;
import util.geometry.vec4;
import util.geometry.mat4;
import util.math;
import demo.demo;

import gl.all;

final class Torus
{
	struct TorusPoint
	{	
		vec3f pos;
		vec3f nml;
		
		static TorusPoint opCall(vec3f pos, vec3f nml)
		{
			TorusPoint tp = void;
			tp.pos = pos;
			tp.nml = nml;
			return tp;
		}
		
		void vertex(float smallRadius, float largeRadius)
		{
			glNormal3fv(nml.ptr);
			glVertex3fv((largeRadius * pos + smallRadius * nml).ptr);			
		}
	}
	
	public
	{
		vec3f m_pos;
		
		int m_slices, m_stacks;		
		
		TorusPoint[] m_points;
		vec3f m_size;
		mat4f m_matrix;
		
		float m_smallRadius, m_largeRadius;
		float m_peakAmount = 0.f;
		float m_peakX = 0.f;
		float m_peakY = 0.f;
	
		void computeGeometry(int stacks, int slices)
		{
			m_slices = slices;
			m_stacks = stacks;
			
			m_points.length = m_stacks * m_slices;
			
			for (int i = 0; i < m_stacks ; ++i)
			{
				float theta = (TWO_PI_F * i) / m_stacks;
				float costheta = cos(theta);
				float sintheta = sin(theta);
				vec3f center = vec3f(costheta, sintheta, 0.f);
				
				for (int j = 0; j < m_slices; ++j)
				{
					
					float phi = (TWO_PI_F * j) / m_slices;					
					
					float cosphi = cos(phi);
					float sinphi = sin(phi);
					
					vec3f nml = vec3f(costheta * cosphi, sintheta * cosphi, sinphi);					
					m_points[j + i * m_slices] = TorusPoint(center, nml);
				}
			}
		}
		
		TorusPoint* pt(int i, int j)
		{
			assert(i >= 0);
			assert(i < m_stacks);
			assert(j >= 0);
			assert(j < m_slices);
			return &m_points[j + i * m_slices];
		}
		
		void vertex(int i, int j, float sR, float lR)
		{
			if (m_peakAmount != 0.f)
			{
				float ti = (cast(float)i) / m_stacks;
				float tj = (cast(float)j) / m_slices;
				
				sR += peakAmount * max!(float)(0.f, sin(ti * m_peakX * TWO_PI_F) * sin(tj * m_peakY * TWO_PI_F));
			}
			
			pt(i,j).vertex(sR, lR);	
		}
	}	
	
	public
	{
		this(int stacks, int slices)
		{
			m_pos = vec3f(0.f,0.f,0.f);
			m_size = vec3f(1.f,1.f,1.f);
			m_matrix = mat4f.identity;
			computeGeometry(stacks, slices);			
			m_smallRadius = 0.4;
			m_largeRadius = 1.0;
		}
		
		vec3f pos() { return m_pos; }		
		vec3f pos(vec3f p) { return m_pos = p; }
		
		vec3f size() { return m_size; }
		vec3f size(vec3f p) { return m_size = p; }
		
		mat4f matrix() { return m_matrix; }
		mat4f matrix(mat4f p) { return m_matrix = p; }
		
		float smallRadius() { return m_smallRadius; }
		float smallRadius(float sR) { return m_smallRadius = sR; }
		
		float largeRadius() { return m_largeRadius; }
		float largeRadius(float lR) { return m_largeRadius = lR; }
		
		float peakAmount() { return m_peakAmount; }
		float peakAmount(float pa) { return m_peakAmount = pa; }
		
		float peakX() { return m_peakX; }
		float peakX(float pa) { return m_peakX = pa; }
		
		float peakY() { return m_peakY; }
		float peakY(float pa) { return m_peakY = pa; }
		
		void draw()
		{
			auto sR = m_smallRadius;
			auto lR = m_largeRadius;
			glPushMatrix();
			glTranslatef(pos.x, pos.y, pos.z);			
			glScalef(m_size.x, m_size.y, m_size.z);
			GL.multMatrix(m_matrix);			
			
			for (int i = 0; i < m_stacks - 1; ++i)
			{
				float ti = (2 * i) / cast(float)m_stacks;
				float tip1 = (2 * i + 1) / cast(float)m_stacks;
				glBegin(GL_QUAD_STRIP);
				
					for (int j = 0; j < m_slices; ++j)
					{
						float tj = j / cast(float)m_slices;
						
						glTexCoord2f(tip1, tj);
						vertex(i+1,j, sR, lR);
						glTexCoord2f(ti, tj);
						vertex(i,j, sR, lR);
					}
					glTexCoord2f(tip1, 1);
					vertex(i+1,0, sR, lR);
					glTexCoord2f(ti, 1);
					vertex(i,0, sR, lR);
					
				glEnd();
			}
			
			{
				glBegin(GL_QUAD_STRIP);
					
					auto t = (2 * m_stacks - 2) / cast(float)m_stacks;
					for (int j = 0; j < m_slices; ++j)
					{
						float tj = j / cast(float)m_slices;
						glTexCoord2f(2, tj);
						vertex(0,j, sR, lR);
						glTexCoord2f(t, tj);
						vertex(m_stacks-1,j, sR, lR);
					}
					glTexCoord2f(2, 1);
					vertex(0, 0, sR, lR);
					glTexCoord2f(t, 1);
					vertex(m_stacks-1, 0, sR, lR);
				
				glEnd();
			}
			
			glPopMatrix();			
		}
	}
	
}	