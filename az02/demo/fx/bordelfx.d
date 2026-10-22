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
module demo.fx.bordelfx;

import demo.whatfxneed;

final class BordelFX : Effect
{
	private
	{
		Shader m_shader;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "BordelFX", timeSpan, priority);						
		}
		
		override void onLoad()
		{
			m_shader = Demo.loadShader("graindo1");
		}
		
		override void onDraw()
		{
			mainFBO.use();
			m_shader.use();
			
			m_shader.set1f("time", localTime);
			
			GL.viewport = viewport;
			
			GL.projectionMatrix = mat4f.scale(vec3f(1 / ratio, 1, 1)); 
			GL.modelviewMatrix = mat4f.identity;
				
			glBegin(GL_QUADS);	
				glColor4f(1,1,1,1);
				glTexCoord2f(0,0); glVertex2f(-1,-1);	
				glTexCoord2f(1,0); glVertex2f(+1,-1);
				glTexCoord2f(1,1); glVertex2f(+1,+1);
				glTexCoord2f(0,1); glVertex2f(-1,+1);	
			glEnd();
			
		
		}
		
		override void onMove()
		{
		}
	}
}

