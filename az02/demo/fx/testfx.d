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
module demo.fx.testfx;

import demo.whatfxneed;

class TestFX  :Effect
{
	private
	{
		Shader m_shader;
		VBO mVBO;	
	
		
		VertexData[] m_vertices;
	}
	
	public
	{
		
		this(Demo demo, TimeSpan timeSpan, int priority)
		{
			super(demo, "TestFX", timeSpan, priority);			
			
		}
		
		auto const N = 100000;
		
		override void onLoad()
		{
			m_shader = putShader;
			
			m_vertices.length = 3 * N;
		
			Random r = Random(4 + cast(int)globalTime);			
			
			for (int i = 0; i < N; ++i)
			{
				vec3f p = vec3f(r.nextFloat2, r.nextFloat2, r.nextFloat2);
				vec3f a = p + 0.01 * vec3f(r.nextFloat2, r.nextFloat2, r.nextFloat2);
				vec3f b = p + 0.01 * vec3f(r.nextFloat2, r.nextFloat2, r.nextFloat2);
				vec3f c = p + 0.01 * vec3f(r.nextFloat2, r.nextFloat2, r.nextFloat2);				
				
				m_vertices[i * 3] = VertexData(vec4f(a,1), vec4f(1), vec3f(0,0,1) );
				m_vertices[i * 3 + 1] = VertexData(vec4f(b,1), vec4f(1), vec3f(0,0,1) );
				m_vertices[i * 3 + 2] = VertexData(vec4f(c,1), vec4f(1), vec3f(0,0,1) );
			}			
			
			mVBO = new VBO(VBO.Storage.STATIC, m_vertices);
		}
		
		override void onDraw()
		{
			mainFBO.use();
			m_shader.use();
			
			GL.viewport = viewport;
			GL.projectionMatrix = mat4f.scale(vec3f(1 / ratio, 1, 1)); // to span all the screen
			GL.modelviewMatrix = mat4f.IDENTITY;
			
			GL.disable(GL_DEPTH_TEST, GL_CULL_FACE, GL_CULL_FACE, GL_BLEND);
			
			mVBO.draw(GL_TRIANGLES, 0, 3 * N);
		}
		
		override void onMove()
		{
			
		}
	}
}

