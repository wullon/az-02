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
module demo.flame.variation;

import util.math;
import util.geometry.all;


class Variation
{
	public
	{
		abstract vec2f transform(vec2f pt);
	}
}



// several kind of variation

final class LinearVariation : Variation
{
	public
	{
		override vec2f transform(vec2f pt)
		{
			return pt;
		}
	}
}

final class SinusoidalVariation : Variation
{
	public
	{
		override vec2f transform(vec2f pt)
		{
			return vec2f(sin(pt.x), sin(pt.y));
		}
	}
}

final class SphericalVariation : Variation
{
	public
	{
		override vec2f transform(vec2f pt)
		{
			float r = pt.squaredLength;
			return pt / r;
		}
	}
}


final class SwirlVariation : Variation
{
	public
	{
		override vec2f transform(vec2f pt)
		{
			float r2 = pt.squaredLength;
			float sine = void;
			float cose = void;
			sincos(r2, sine, cose);
			return vec2f(pt.x * sine - pt.y * cose, 
			             pt.x * cose + pt.y * sine);
		}
	}
}

final class HorseShoeVariation : Variation
{
	public
	{
		override vec2f transform(vec2f pt)
		{
			float r = pt.length;
			if (abs(r) < 1e-20) return vec2f(0.f,0.f);
			return (1.f / r) * vec2f((pt.x - pt.y)*(pt.x + pt.y), 2.f * pt.x * pt.y);
		}
	}
}


final class EyefishVariation : Variation
{
	public
	{
		override vec2f transform(vec2f pt)
		{
			float r = pt.length;
			return (2.f / (r + 1.f)) * pt;
		}
	}
}

