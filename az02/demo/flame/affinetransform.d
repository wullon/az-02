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
module demo.flame.affinetransform;

import util.math;
import util.geometry.all;

final class AffineTransform
{
	private
	{
		float m_a, m_b, m_c, m_d, m_e, m_f;
	}
	public
	{
		this(float a, float b, float c, float d, float e, float f)
		{
			m_a = a;
			m_b = b;
			m_c = c;
			m_d = d;
			m_e = e;
			m_f = f;			
		}
		
		vec2f transform(vec2f pt)
		{
			return vec2f(m_a * pt.x + m_b * pt.y + m_c, m_d * pt.x + m_e * pt.y + m_f);
		}
		
		float a() { return m_a; }
		float a(float v) { return m_a = v; }
		float b() { return m_b; }
		float b(float v) { return m_b = v; }
		float c() { return m_c; }
		float c(float v) { return m_c = v; }
		float d() { return m_d; }
		float d(float v) { return m_d = v; }
		float e() { return m_e; }
		float e(float v) { return m_e = v; }
		float f() { return m_f; }
		float f(float v) { return m_f = v; }
		
		void setRotationtranslate(float angle, float dist, vec2f disp)
		{
			float cosa = dist * cos(angle);	
			float sina = dist * sin(angle);
						
			m_a = cosa;
			m_b = sina;
			m_c = disp.x;
			m_d = -sina;
			m_e = cosa;
			m_f = disp.y;
		}
	}
}