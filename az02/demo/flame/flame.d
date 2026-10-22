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
module demo.flame.flame;

import util.all;
import util.geometry.all;
import demo.demo;
import gl.all;
import demo.flame.variation;
import demo.flame.weightedvariation;
import demo.flame.affinetransform;

final class Flame
{
	private
	{
		vec3f m_pos;
		
		Shader m_shader;
		Texture2D m_tex;
		
		WeightedVariation[] m_variations;
		
		int m_seed;
		
		float m_seedSize;
	
		
		const int n_triangles = 1000;	
		const int n_points = 40;
		const int n_total = n_points * n_triangles;
		
		vec2f[] points;
		vec4f[] colors;
	}
	
	
	public
	{
		this(WeightedVariation[] variations, Texture2D tex) // variations should'nt be null
		{
			m_shader = Demo.loadShader("blit");
			m_tex = tex;
			m_shader.setSampler("tex", tex, 0);	
			m_seed = Random().nextInt;		 // random random seed
			
			
			m_variations = variations;
			
			points.length = n_total * 4;
			colors.length = n_total;
		}
		
		WeightedVariation[] variations() { return m_variations; }
		WeightedVariation[] variations(WeightedVariation[] wv) { return m_variations = wv; }
		
		
		
		void draw()
		{
			Random random = Random(m_seed);
			
			
			
			auto totalWeight = 0.f;
			for (int i = 0; i < m_variations.length; ++i)
			{
				totalWeight += m_variations[i].weight;				
			}
			
			WeightedVariation chooseVariation(ref Random random1)
			{
				float rnd = random1.nextFloat() * totalWeight;
				int index = m_variations.length - 1;
				for (int i = 0; i < m_variations.length; ++i)
				{
					rnd -= m_variations[i].weight;
					if (rnd < 0.f) 
					{
						index = i;
						break;
					}
				}
				return m_variations[index];
			}
			
			glEnable(GL_POINT_SPRITE);
			glTexEnvi(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);
			m_shader.use();
			//glLineWidth(10.f);
			
			//glBegin(GL_LINE_STRIP);
			
			{
				int index = 0;
				int index2 = 0;
				for (int i = 0; i < n_triangles; ++i)
				{
					vec2f a = vec2f(random.nextFloat2(), random.nextFloat2());
					auto angle = random.nextFloat * TWO_PI_F;
					
					auto ab = PI_F / 3.f;
					vec4f color = vec4f(0.f);
					
					// skip first 20 iterations
					for (int j = 0; j < 10; ++j)
					{
						auto wv = chooseVariation(random);
						
						a = wv.transform(a);					
						
						color = (color + wv.color) * 0.5f;
					}
								
					for (int j = 0; j < n_points; ++j)
					{
						WeightedVariation wv = chooseVariation(random);
						a = wv.transform(a);
						
						colors[index2++] = (color + wv.color) * 0.5f;
						points[index++] = vec2f(a.x * 0.4f, a.y * 0.4f);
						points[index++] = vec2f(a.x * -0.4f, a.y * 0.4f);
						points[index++] = vec2f(a.x * -0.4f, a.y * -0.4f);
						points[index++] = vec2f(a.x * 0.4f, a.y * -0.4f);
						
					}
				}
			}
			
			{
				glBegin(GL_POINTS);
				int ind = 0;
				for (int i = 0; i < n_total; ++i)
				{
					glColor4fv(colors[i].ptr);	
					glVertex2fv(points[ind++].ptr);
					glVertex2fv(points[ind++].ptr);
					glVertex2fv(points[ind++].ptr);
					glVertex2fv(points[ind++].ptr);
				}
			
				glEnd();
			}
		}
		
		float seedSize()
		{
			return m_seedSize;	
		}
		
		float seedSize(float s)
		{
			return m_seedSize = s;	
		}
	}
}
