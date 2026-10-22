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
module demo.plane;

// simple textured quad
// yes, it's stupid

import util.geometry.vec2;
import util.geometry.vec4;
import demo.demo;

import gl.all;

class Plane
{
	public
	{
		vec2f m_pos;
		vec2f m_size;
		Texture2D m_tex;
		Shader m_shader;
		vec4f m_color;
		float m_rotation;
	}	
	
	public
	{
		this(Texture2D tex, Shader shader)
		{
			m_pos = vec2f(0,0);
			m_size = vec2f(1,1);
			m_tex = tex;
			m_shader = shader;
			m_shader.setSampler("tex", tex, 0);
			m_rotation = 0.f;
			m_color = vec4f(1,1,1,1);
		}
		
		this(Texture2D tex)
		{
			this(tex, Demo.loadShader("blit")); // default shader
		}
		
		vec2f pos() 
		{ 
			return m_pos;
		}
		
		vec2f pos(vec2f p) 
		{ 
			return m_pos = p;
		}
		
		vec4f color() 
		{ 
			return m_color;
		}
		
		vec4f color(vec4f p) 
		{ 
			return m_color = p;
		}
			
		float rotation() 
		{ 
			return m_rotation;
		}
		
		float rotation(float r) 
		{ 
			return m_rotation = r;
		}
			
		Shader shader() { return m_shader; }
		Shader shader(Shader shader) { return m_shader = shader; }
		
		vec2f size() 
		{ 
			return m_size;
		}
		
		vec2f size(vec2f s) 
		{ 
			return m_size = s;
		}
			
		
		void draw()
		{
			m_shader.use();
			
			glPushMatrix();
			glTranslatef(pos.x, pos.y, 0.f);
			glScalef(size.x, size.y, 1.f);
			glRotatef(m_rotation, 0,0,1);		
			
			glBegin(GL_QUADS);
				GL.color = m_color;
				glTexCoord2f(0,1);
				glVertex2f(-0.5f, -0.5f);
				glTexCoord2f(0,0);
				glVertex2f(-0.5f, +0.5f);
				glTexCoord2f(1,0);
				glVertex2f(0.5f, 0.5f);
				glTexCoord2f(1,1);
				glVertex2f(0.5f, -0.5f);
			
			glEnd();
			glPopMatrix();
		}
	}
	
}	