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
module demo.fx.scene10;

import demo.whatfxneed;

final class Scene10FX : Effect
{
	private
	{
		
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "Scene10FX", timeSpan, priority);			
			
		}
		
		
		override void onLoad()
		{
			
		}
		
		override void onDraw()
		{
			mainFBO.use();
			
			GL.viewport = viewport;
			
			GL.projectionMatrix = mat4f.scale(vec3f(invRatio, 1, 1));
			GL.modelviewMatrix = mat4f.IDENTITY;
			
			GL.clearColor = vec4f(0.f,0.f,0.f,1.f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			
			
			blurAmount = 0.0;			
			blurType = 1.0;
		}
		
		}
		
		override void onMove()
		{
		}
	}
}

