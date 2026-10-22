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
module gl.shaders;

private import derelict.opengl.gl;	
private import derelict.opengl.gl20;
private import util.all;	
private import util.geometry.all;
private import gl.texture;
private import gl.state;

class ShaderError : object.Exception
{	
	this(char[] s)
	{
		super(s);	
	}	
}

final class CompileError : ShaderError
{	
	this(char[] filename, char[] log)
	{
		super(format("CompileError : Cannot compile %s\nLOG :\n%s", filename, log));
	}
}

final class LinkError : ShaderError
{	
	this(char[] filename)
	{
		super(format("LinkError : Cannot link shader (%s)", filename));
	}
}

final class NotFoundUniformError : ShaderError
{	
	this(char[] name)
	{
		super(format("Not found uniform \"%s\"", name));
	}
}

// shader class
private final class Subshader 
{	
	private 
	{		
		GLuint handle;				
	}	
	
	public 
	{			
		this(GLenum shaderType) 
		{			
			handle = glCreateShader(shaderType);
			GL.check();
		}
		
		~this() 
		{			
			glDeleteShader(handle);
			GL.check();
		}
		
		final GLuint getHandle() 
		{
			return handle;	
		}
		
		final bool compile() 
		{		
			glCompileShader(handle);
			if (glGetError() == 0) {
				GLint compiled;
				glGetShaderiv(handle, GL_COMPILE_STATUS, &compiled);			
				return (compiled == GL_TRUE);
			} else 
			{
				return false;
			}			
		}
		
		final char [] getInfoLog() 
		{			
			GLint logLength;
			glGetShaderiv(handle, GL_INFO_LOG_LENGTH, &logLength);
			char[] log = new char[logLength];
			GLint dummy;
			glGetShaderInfoLog(handle,logLength,&dummy, log.ptr);
			GL.check();
			
			return toDString(log.ptr);
		}
		
		
		final void load(StringList l) 
		{		
			StringIterator it = l.iterator();			
			int count = l.size();			
			
			GLint[] lengths = new GLint[count];
			GLchar * [] addresses;
			addresses.length = count;
			
			char[] EMPTY_LINE = "";
			
			for (int i = 0; (it.hasNext()) && (i < count); i++ ) 
			{	
				char[] s = it.next();
				
				if (s is null)
				{
					lengths[i] = EMPTY_LINE.length;				
					addresses[i] = EMPTY_LINE.ptr;	
				} else
				{
					lengths[i] = s.length;				
					addresses[i] = s.ptr;
				}
			
			}
			glShaderSource(handle,count,addresses.ptr,cast(GLint*) lengths);		
			GL.check();
		}		
		
		final void loadFromFile(char[] filename, char[] prelude) 
		{		
			StringList l = readTextFile(filename);		
			if (prelude !is null) l.addFirst(prelude);	
			load(l);	
		}
		
		final void loadFromFile(char[] filename) 
		{		
			loadFromFile(filename, null);
		}
	}	
}

final class Shader 
{
	
	private 
	{		
		GLuint handle = 0;
		Subshader fragmentShader, vertexShader;		
		
		static Shader binded = null;
		static Shader used = null;
		
		Texture[] textures;
		GLint[] samplerLocations;
		
		final void attach(Subshader s) 
		{			
			glAttachShader(handle,s.getHandle());
			GL.check();
		}
		
		final bool link() 
		{			
			glLinkProgram(handle);	
			GLint linked;
			glGetProgramiv(handle,GL_LINK_STATUS,&linked);
			return ( linked == GL_TRUE);			
		}
		
		
		final void createProgram() 
		{
			
			handle = glCreateProgram();
			
			//assert( glIsProgram(handle) );
			GL.check();
			
			textures.length = Texture.maxTextureUnit();
			foreach (ref Texture t; textures)
			{
				t = null;
			}			
			samplerLocations.length = Texture.maxTextureUnit();			
						
		}
		
		
		GLint getUniformLocation(char[] name) 
		{			
			GLint r = glGetUniformLocation(handle, cast(char*) name);
			GL.check();
			if (r == -1) 
			{
				throw new NotFoundUniformError(name);
			}
			
			return r;				
		}
		
		this(int handle) // to create the default shader
		{
			this.handle = handle;
		}
		
		final char [] getInfoLog() 
		{			
			GLint logLength;
			glGetProgramiv(handle, GL_INFO_LOG_LENGTH, &logLength);
			char[] log = new char[logLength];
			GLint dummy;
			glGetProgramInfoLog(handle, logLength, &dummy, log.ptr);
			GL.check();
			return toDString(log.ptr);			
		}
		
		static Shader fixedPipelineShader;
		
	}	
	
	public 
	{
		
		
		
		this(char[] vertexFile, char[] fragmentFile) 
		{	
			trace(format("Loading shader %s + %s", vertexFile, fragmentFile));		
			createProgram();
			
			vertexShader = new Subshader(GL_VERTEX_SHADER);			
			vertexShader.loadFromFile(vertexFile);			
			
			if (!vertexShader.compile()) 
			{
				throw new CompileError(vertexFile, vertexShader.getInfoLog());
			} else
			{
				char[] log = vertexShader.getInfoLog();
				if (log.length >= 0) trace(log);
			}
			
			
			fragmentShader = new Subshader(GL_FRAGMENT_SHADER);
			fragmentShader.loadFromFile(fragmentFile);			
			
			if (!fragmentShader.compile()) 
			{
				throw new CompileError(fragmentFile, fragmentShader.getInfoLog());				
			} else
			{
				char[] log = fragmentShader.getInfoLog();
				if (log.length >= 0) trace(log);
			}
						
			attach(vertexShader);
			attach(fragmentShader);
			
			if (!link())
			{
				char[] log = getInfoLog();
				trace(log);	
				throw new LinkError(vertexFile ~ " + " ~ fragmentFile);								
			} else
			{
				char[] log = getInfoLog();
				trace(log);
			}
		}
		
		~this() {
			
			if (binded is this) 
			{				
				binded = null;					
			}
			
			delete vertexShader; // force deletion
			delete fragmentShader; 
			glDeleteProgram(handle);
			
			for( int i = 0; i < textures.length; i++) 
			{
				textures[i] = null;				
			}			
			textures.length = 0;
			samplerLocations.length = 0;
			
			GL.check();
			
		}
		
		final void bind() 
		{			
			if (binded !is this) 
			{				
				binded = this;
				glUseProgram(handle);	
				GL.check();
			}			
		}		
		
		final void use() 
		{			
			if (used !is this) 
			{				
				bind();
				
				for (int i = 0; i < textures.length; i++) 
				{				
					if ( textures[i] !is null)
					{
						int unit = i;
						textures[i].use(unit);
						glUniform1i( samplerLocations[i], unit);
						GL.check();
					}	
				}	
				glActiveTexture(GL_TEXTURE0);				
				used = this;				
			}			
		}	
		
		static Shader getDefault() 
		{	
			if (fixedPipelineShader is null)
			{
				fixedPipelineShader = new Shader(0);
			}
			return fixedPipelineShader;
		}	
		
		static void useDefault() 
		{	
			getDefault().use;
		}		
		
		final void set1f (char[] name, float x) 
		{						
			bind();			
			glUniform1f( getUniformLocation(name), x);
			GL.check();
		}				
		
		final void set2f (char[] name, float x, float y) 
		{						
			bind();			
			glUniform2f( getUniformLocation(name), x, y);
    		GL.check();
		}
		
		final void set2f (char[] name, vec2f v) 
		{						
			bind();			
			glUniform2fv( getUniformLocation(name), 1, cast(GLfloat*) v.v);
    		GL.check();
		}				
		
		final void set3f (char[] name, float x, float y, float z) 
		{						
			bind();			
			glUniform3f( getUniformLocation(name), x, y, z);
    		GL.check();
		}
		
		final void set3f (char[] name, vec3f v) 
		{						
			bind();			
			glUniform3fv( getUniformLocation(name), 1, cast(GLfloat*) v.v);
    		GL.check();
		}	

		
		final void set4f (char[] name, float x, float y, float z, float w) 
		{						
			bind();			
			glUniform4f( getUniformLocation(name), x, y, z, w);
    		GL.check();
		}		
		
		final void set4f (char[] name, vec4f v) 
		{						
			bind();			
			glUniform4fv( getUniformLocation(name), 1, cast(GLfloat*) v.v);
			GL.check();

		}	
		
		final void set1b (char[] name, bool b) 
		{				
			set1i(name, b ? 1 : 0);			
		}		
		
		final void set1i (char[] name, int x) 
		{				
			bind();			
			glUniform1i( getUniformLocation(name), x);
    		GL.check();
		}				
		
		final void set2i (char[] name, int x, int y) 
		{						
			bind();			
			glUniform2i( getUniformLocation(name), x, y);
    		GL.check();
		}		
		
		final void set2i (char[] name, vec2i v) 
		{						
			bind();			
			glUniform2iv( getUniformLocation(name), 1, v.ptr);
    		GL.check();
		}		
		
		final void set3i (char[] name, int x, int y, int z) 
		{						
			bind();			
			glUniform3i( getUniformLocation(name), x, y, z);
    		GL.check();
		}
				
		final void set3i (char[] name, vec3i v) 
		{						
			bind();			
			glUniform3iv( getUniformLocation(name), 1, v.ptr);
    		GL.check();
		}
		
		final void set4i (char[] name, int x, int y, int z, int w) 
		{						
			bind();			
			glUniform4i( getUniformLocation(name), x, y, z, w);
    		GL.check();
		}
				
		final void set4i (char[] name, vec4i v) 
		{						
			bind();			
			glUniform4iv( getUniformLocation(name), 1, v.ptr);
    		GL.check();
		}		
		
		final void setMat4f (char[] name, mat4f m) 
		{						
			bind();			
    		glUniformMatrix4fv(getUniformLocation(name), 1, false, cast(GLfloat*) m.c);
    		GL.check();
		}
		
		final void set1fv (char[] name, float[] x) 
		{						
			bind();			
			glUniform1fv( getUniformLocation(name), x.length, x.ptr);
			GL.check();
		}				
	
		final void set2fv (char[] name, vec2f[] v) 
		{						
			bind();			
			glUniform2fv( getUniformLocation(name), v.length, v.ptr.ptr);
    		GL.check();
		}				
		
		final void set3fv (char[] name, vec3f[] v) 
		{						
			bind();			
			glUniform3fv( getUniformLocation(name), v.length, v.ptr.ptr);
    		GL.check();
		}	
		
		final void set4fv (char[] name, vec4f[] v) 
		{						
			bind();			
			glUniform4fv( getUniformLocation(name), v.length, v.ptr.ptr);
    		GL.check();

		}	
		
		final void set1iv (char[] name, int[] x) 
		{				
			bind();			
			glUniform1iv( getUniformLocation(name), x.length, x.ptr);
    		GL.check();   		
		}				
		
		final void set2iv (char[] name, vec2i[] x) 
		{						
			bind();			
			glUniform2iv( getUniformLocation(name), x.length, x.ptr.ptr);
    		GL.check();
		}			
				
		final void set3iv (char[] name, vec3i[] v) 
		{						
			bind();			
			glUniform3iv( getUniformLocation(name), v.length, v.ptr.ptr);
    		GL.check();
		}
		
		final void set4iv (char[] name, vec4i[] v) 
		{						
			bind();			
			glUniform4iv( getUniformLocation(name), v.length, v.ptr.ptr);
    		GL.check();
		}		
		
		final void setMat4fv (char[] name, mat4f[] m) 
		{						
			bind();			
    		glUniformMatrix4fv(getUniformLocation(name), m.length, false, m.ptr.ptr);
    		GL.check();
		}		
		
		final void setSampler(char[] name, Texture tex, int unit) 
		{	
			samplerLocations[unit] = getUniformLocation(name);
			textures[unit] = tex;								
		}		
	
	}	
	
}