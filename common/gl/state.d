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
module gl.state;

import std.stdio, std.string, std.c.stdio;
import derelict.opengl.gl;
import derelict.opengl.glu;
import derelict.opengl.gl20;

import derelict.opengl.gl20;

import util.common;
import util.logger;
import util.geometry.all;

// wrapper to opengl state variables (not all)


class GLError : object.Exception
{	
	this(char[] msg)
	{
		super(msg);
	}
}

final class GL
{
	public
	{
		enum CullMode 
		{ 
			POINT, 
			LINE, 
			FILL,
			NONE // CULL			
		};	
		
		enum BlendMode 
		{
			ADD, 
			SUB,
			SUBR,
			MIN,
			MAX
		};
		
		enum BlendFactor 
		{ 
			ZERO, 
			ONE, 
			DST_COLOR, 
			SRC_COLOR, 
			ONE_MINUS_DST_COLOR, 
			ONE_MINUS_SRC_COLOR,
			SRC_ALPHA,
			ONE_MINUS_SRC_ALPHA,
			DST_ALPHA,
			ONE_MINUS_DST_ALPHA,
			SRC_ALPHA_SATURATE
		}
		
		enum Buffer
		{
			COLOR = 1,
			DEPTH = 2,
			STENCIL = 4,
			ALL = COLOR | DEPTH | STENCIL
		}
	}
	
	private {
		
		static const GLint[CullMode.max + 1] cullMode_toGL = [
			GL_POINT, 
			GL_LINE, 
			GL_FILL,
			0 // unused
		];
		
		static const GLint[BlendMode.max + 1] blendMode_toGL = 
		[
			GL_FUNC_ADD, 
			GL_FUNC_SUBTRACT, 
			GL_FUNC_REVERSE_SUBTRACT, 
			GL_MIN,
			GL_MAX,
		];
		
		static const GLint[BlendFactor.max + 1] blendFactor_toGL = 
		[
			GL_ZERO, 
			GL_ONE, 
			GL_DST_COLOR, 
			GL_SRC_COLOR, 
			GL_ONE_MINUS_DST_COLOR, 
			GL_ONE_MINUS_SRC_COLOR,
			GL_SRC_ALPHA,
			GL_ONE_MINUS_SRC_ALPHA,
			GL_DST_ALPHA,
			GL_ONE_MINUS_DST_ALPHA,
			GL_SRC_ALPHA_SATURATE
		];
		
	}
	
	public
	{			
		static void enable(GLint[] features...)
		{
			foreach (GLint i; features) glEnable(i);	
		}
				
		static void disable(GLint[] features...)
		{
			foreach (GLint i; features) glDisable(i);	
		}
		
		static GLint matrixMode(GLint mm)
		{
			glMatrixMode(mm);
			return mm;
		}
		
		static void loadIdentity()
		{
			glLoadIdentity();
		}
		
		static void loadMatrix(mat4f m)
		{
			if (glLoadTransposeMatrixf is null)
			{
				mat4f tr = m.transposed();
				glLoadMatrixf(tr.ptr);			
			} else 
			{
				glLoadTransposeMatrixf(m.ptr);
			}
		}
		
		static void multMatrix(mat4f m)
		{
			if (glMultTransposeMatrixf is null)
			{
				mat4f tr = m.transposed();
				glMultMatrixf(tr.ptr);
			} else 
			{
				glMultTransposeMatrixf(m.ptr);
			}
		}
		
		static void lookAt(vec3f eye, vec3f target, vec3f up)
		{
			gluLookAt(eye.x, eye.y, eye.z, target.x, target.y, target.z, up.x, up.y, up.z);
		}
		
		static mat4f projectionMatrix()
		{
			mat4f m;
			glGetFloatv(GL_PROJECTION_MATRIX, m.ptr);
			m.transpose();
			return m;
		}
		
		static mat4f projectionMatrix(mat4f m)
		{
			glMatrixMode(GL_PROJECTION);
			loadMatrix(m);
			return m;
		}
		
		static mat4f modelviewMatrix()
		{
			mat4f m;
			glGetFloatv(GL_MODELVIEW_MATRIX, m.ptr);
			m.transpose();
			return m;
		}
		
		static mat4f modelviewMatrix(mat4f m)
		{
			glMatrixMode(GL_MODELVIEW);
			loadMatrix(m);
			return m;
		}		
		
		static void check() 
		{
			version(Release)
			{
				// do nothing in release mode !
			} 
			else
			{
				GLint r = glGetError();
				if (r != GL_NO_ERROR)
				{
				//	trace(format("error %s", r));
					printf("%s\n",gluErrorString(r)); 
					
					assert(false);
					//throw new GLError(msg);									
				}					
			}
		}
		
		static void setCullMode(CullMode front, CullMode back)
		{
			bool cullFront = (CullMode.NONE == front),
			     cullBack = (CullMode.NONE == back);
				
			if ( (!cullFront) && (!cullBack)) 
			{			
				glDisable(GL_CULL_FACE);			
			} else 
			{			
				glEnable(GL_CULL_FACE);
				GLenum toHide = cullFront ? (cullBack ? GL_FRONT_AND_BACK : GL_FRONT) : GL_BACK;						
				glCullFace(toHide);
				
				if ( !cullFront ) glPolygonMode(GL_FRONT, cullMode_toGL[front]);
				if ( !cullBack ) glPolygonMode(GL_BACK, cullMode_toGL[back]);			
			}			
			GL.check();
		}
		
		static float pointSize(float new_pointSize)
		{
			glPointSize(new_pointSize);
			return new_pointSize;
		}		
		
		static vec4f clearColor(vec4f c)
		{
			glClearColor(c.x, c.y, c.z, c.w);	
			return c;
		}	
		
		static vec3f color(vec3f c)
		{
			glColor3fv(c.ptr);
			return c;
		}	
		
		static vec4f color(vec4f c)
		{
			glColor4fv(c.ptr);
			return c;
		}
		
			
		
        static float clearDepth(float depth)		
		{
			glClearDepth(depth);
			return depth;
		}
		
		static void setBlend(BlendMode RGBOperation, BlendFactor srcRGBFactor, BlendFactor dstRGBFactor, 
		                     BlendMode AlphaOperation, BlendFactor srcAlphaFactor, BlendFactor dstAlphaFactor )
		{
			if ((glBlendEquationSeparate !is null) && (glBlendFuncSeparate !is null))
			{
				glBlendEquationSeparate(blendMode_toGL[RGBOperation], blendMode_toGL[AlphaOperation]);
				glBlendFuncSeparate( blendFactor_toGL[srcRGBFactor], 
				                     blendFactor_toGL[dstRGBFactor], 
				                     blendFactor_toGL[srcAlphaFactor], 
				                     blendFactor_toGL[dstAlphaFactor] );	
			} else
			{
				// try to approximate the desired blend
				glBlendFunc( blendFactor_toGL[srcRGBFactor], blendFactor_toGL[dstRGBFactor]);	
				glBlendFunc( blendFactor_toGL[srcRGBFactor], blendFactor_toGL[dstRGBFactor]);	
				glBlendEquation( blendMode_toGL[RGBOperation] );
			}
		}   
		
		deprecated static void setViewport(int x, int y, int width, int height)
		{
			glViewport(x,y,width,height);
			GL.check();	
		}
		
		static void viewport(recti view)
		{
			glViewport(view.x1, view.y1, view.width, view.height);
			GL.check();	
		}
		
		static void clear(Buffer b)
		{
			GLint mask = 0;
			if (b & Buffer.COLOR) mask |= GL_COLOR_BUFFER_BIT;
			if (b & Buffer.STENCIL) mask |= GL_STENCIL_BUFFER_BIT;
			if (b & Buffer.DEPTH) mask |= GL_DEPTH_BUFFER_BIT;
			glClear(mask);
			GL.check();
		}
		
		static bool glBool(bool b)
		{
			return b ? GL_TRUE : GL_FALSE;
		} 
		
		static void vertex(vec2f[] vs...)	{	foreach(v; vs) glVertex2fv(v.ptr);	}
		static void vertex(vec3f[] vs...)	{	foreach(v; vs) glVertex3fv(v.ptr);	}
		static void vertex(vec4f[] vs...)	{	foreach(v; vs) glVertex4fv(v.ptr);	}
		
		static void normal(float x, float y, float z) {	glNormal3f(x, y, z); }
		static void normal(vec3f nml)		{	glNormal3fv(nml.ptr);	}
		
		
		static void translate(float x, float y, float z){	glTranslatef(x, y, z); }
		static void translate(vec3f v)					{	glTranslatef(v.x, v.y, v.z);	}
		
		static void scale(float x, float y, float z)	{	glScalef(x, y, z); }
		static void scale(vec3f v)						{	glScalef(v.x, v.y, v.z);	}
		
		static void rotate(float angle, float x, float y, float z)  {	glRotatef(angle, x, y, z); }
		static void rotate(vec4f v)									{	glRotatef(v.x, v.y, v.z, v.z);	}
		
		static void pushAttrib(int attribs) 
		{	
			glPushAttrib(attribs);
		}
		
		static void popAttrib() 
		{	
			glPopAttrib();
		}
		
		static void pushMatrix() 
		{	
			glPushMatrix();
		}
		
		static void popMatrix()
		{	
			glPopMatrix();
		}
		
	}
}
