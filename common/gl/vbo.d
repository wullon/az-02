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
module gl.vbo;

import gl.buffer;
import derelict.opengl.gl;
import derelict.opengl.gl20;
import util.geometry.all;

/**
 * Note : one could make optimal VBO usage through a parameterized VBO template
 *        It would need a lot of parameters though.
 *
 *   Observed performance : ~10000 poly for a STREAM/DYNAMIC VBO
 *                         ~100000
 */

// This is arbitrary.
// OpenGL allow custom attribute passing but i'll stick with this one.
struct VertexData
{
	vec4f pos;	
	vec3f normal;
	float _dummy0;
	vec4f color;
	vec4f texCoord;	
	
	static VertexData opCall(vec4f pos, 
	                         vec4f color = vec4f(1,1,1,1), 
	                         vec3f normal = vec3f(0,0,1), 
	                         vec4f texCoord = vec4f(0,0,0,0))
	{
		VertexData vd = void;
		vd.pos = pos;
		vd.normal = normal;
		vd._dummy0 = float.nan; 
		vd.color = color;
		vd.texCoord = texCoord;
		return vd;
	}
}

static assert(VertexData.sizeof == 64);

class VBO : GLBuffer
{
	public
	{
		alias GLBuffer.Storage Storage;		
		
		this()
		{
			super(GL_ARRAY_BUFFER);
		}
		
		this(Storage storage, VertexData[] data)
		{
			this();
			setVertexData(storage, data);
		}		
		
		void setVertexData(Storage storage, VertexData[] data)
		{
			
			// setData(VertexData.sizeof * data.length, storage, Usage.DRAW, data.ptr );
			
			// invalidate
			setData(VertexData.sizeof * data.length, storage, Usage.DRAW, null );
			setSubData(0, VertexData.sizeof * data.length, data.ptr);
		}
		
		void setVertexSubData(int offset, VertexData[] data)
		{
			setSubData(offset, VertexData.sizeof * data.length, data.ptr);
		}

		void draw(GLenum mode, int first, int count)
		{	
			bind();
			glEnableClientState( GL_COLOR_ARRAY );
			glColorPointer( 3, GL_FLOAT, VertexData.sizeof, cast(void*) 8 /* VertexData.pos.offsetof*/ );
            
			glEnableClientState( GL_NORMAL_ARRAY );
			glNormalPointer( GL_FLOAT, VertexData.sizeof, cast(void*)4 /* VertexData.normal.offsetof*/ );
            
			glEnableClientState( GL_TEXTURE_COORD_ARRAY );
			glTexCoordPointer( 4, GL_FLOAT, VertexData.sizeof, cast(void*)12 /* VertexData.texCoord.offsetof*/ );
			
			glEnableClientState(GL_VERTEX_ARRAY);
			glVertexPointer( 4, GL_FLOAT, VertexData.sizeof, cast(void*)0 /*VertexData.pos.offsetof*/ );			
			
			glDrawArrays(mode, first, count);
			
			glDisableClientState( GL_COLOR_ARRAY );
			glDisableClientState( GL_NORMAL_ARRAY );
			glDisableClientState( GL_TEXTURE_COORD_ARRAY );
			glDisableClientState( GL_VERTEX_ARRAY );
		}
		
	}
}


/**
 * Double-buffered VBO for faster display
 */
class DoubleVBO
{
	public
	{
		alias VBO.Storage Storage;	
	}
	
	private
	{
		VertexData[] mData; // a slice pointing to data
		VBO[2] mVBO;
		int mCurrentVBO = 1;
		Storage mStorage;
	}	
	
	public
	{
		this(Storage storage, VertexData[] data) // takes some time
		{
			mData = data[]; // take a slice on it
			mVBO[0] = new VBO();	
			mVBO[1] = new VBO();
			mStorage = storage;
			mVBO[0].setVertexData(storage, mData);
			mVBO[1].setVertexData(storage, mData);
			
			if (storage == Storage.STATIC) assert(false, "You should use a single VBO instead");
		}
		
		void swap()
		{
			mVBO[mCurrentVBO].setVertexData(mStorage, mData); // upload all vertices
			mCurrentVBO = 1 - mCurrentVBO;
		}
		
		void draw(GLenum mode, int first, int count)
		{
			mVBO[mCurrentVBO].draw(mode, first, count);	
		}
	}
}