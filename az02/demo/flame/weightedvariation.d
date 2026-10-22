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
module demo.flame.weightedvariation;

import util.math;
import util.geometry.all;
import demo.flame.variation;
import demo.flame.affinetransform;

final class WeightedVariation 
{
	private
	{
		float m_weight;
		Variation m_variation;   // should't be null
		vec4f m_color;
		AffineTransform m_preTransform;
		AffineTransform m_postTransform;
	}
	
	public
	{
		this(Variation v, vec4f color, float w, AffineTransform preTransform, AffineTransform postTransform )
		{
			m_variation = v;
			assert(m_variation !is null);
			m_weight = w;
			m_color = color;
			m_preTransform = preTransform;
			m_postTransform = postTransform;
		}
		
		vec2f transform(vec2f pt)
		{
			return m_postTransform.transform(m_variation.transform(m_preTransform.transform(pt)));
		}
		
		
		
		float weight() { return m_weight; }
		float weight(float w) { return m_weight = w; }
		
		Variation variation() { return m_variation; }
		Variation variation(Variation v) { return m_variation = v; }
		
		vec4f color() { return m_color; }
		vec4f color(vec4f v) { return m_color = v; }
		
		AffineTransform preTransform() { return m_preTransform; }
		AffineTransform preTransform(AffineTransform a) { return m_preTransform = a; }
		
		AffineTransform postTransform() { return m_postTransform; }
		AffineTransform postTransform(AffineTransform a) { return m_postTransform = a; }
	}
}