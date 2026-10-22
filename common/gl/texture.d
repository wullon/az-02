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
module gl.texture;

 import std.string;
 import derelict.opengl.gl;
 import derelict.opengl.glu;
 import derelict.opengl.extension.arb.texture_float;
 import derelict.opengl.extension.arb.pixel_buffer_object;
 
 // this is required
 import derelict.opengl.extension.ext.framebuffer_object;
 
  // these extension are not required
 import derelict.opengl.extension.ext.texture_compression_dxt1; 
 import derelict.opengl.extension.ext.texture_compression_s3tc;

import gl.buffer;
import gl.state;
import std.stdio;
import util.geometry.rect;

class Texture {	
	
	public 
	{		
		enum Wrap 
		{ 
			CLAMP, 
			CLAMP_TO_EDGE, 
			REPEAT, 
			CLAMP_TO_BORDER, 
			MIRRORED_REPEAT 
		}		
		
		// internal fornat of texture
		enum IFormat 
		{ 
			I8,
			I16F,
			I32F,
			ALPHA8,
			ALPHA16F,
			ALPHA32F,
			LUMINANCE8,
			LUMINANCE16F,
			LUMINANCE32F,
			RGB8,
			RGB16F,
			RGB32F,
			RGBA8,
			RGBA16F,
			RGBA32F
		}
		
		// format of data used to write into texture
		     
		enum Format 
		{
			INTENSITY,
			RGB,
			RGBA,
			BGR,
			BGRA,
			DEPTH
		}
		
		enum Type 
		{
			UBYTE,
			BYTE,
			USHORT,
			SHORT,
			UINT,
			INT,
			FLOAT
		}
		
		enum Filter 
		{ 
			NEAREST, 
			LINEAR, 
			NEAREST_MIPMAP_NEAREST, 
			NEAREST_MIPMAP_LINEAR, 
			LINEAR_MIPMAP_NEAREST, 
			LINEAR_MIPMAP_LINEAR 
		}
		
		
		GLint chooseCompressionScheme(IFormat fmt)
		{
			static GLint s_supportedCompressedFormats[] = null;
		
			static bool hasCompressionFormat(GLint fmt)
			{
				// create the array at first time
				if (s_supportedCompressedFormats is null)
				{
					GLint nCompressedFormats;
					glGetIntegerv(GL_NUM_COMPRESSED_TEXTURE_FORMATS, &nCompressedFormats);
					s_supportedCompressedFormats.length = nCompressedFormats;
					glGetIntegerv(GL_COMPRESSED_TEXTURE_FORMATS, s_supportedCompressedFormats.ptr); 
				}
				
				// search the suitable compression format
				for (int i = 0; i < s_supportedCompressedFormats.length; ++i)
				{
					if (fmt == s_supportedCompressedFormats[i]) 
					{
						return true;
					}
				}
				return false;
			}
			
			switch(fmt)
			{	
				// DXT3 and DXT1 RGBA are disqualified
				case IFormat.I8: return GL_COMPRESSED_INTENSITY;	
				case IFormat.ALPHA8: return GL_COMPRESSED_ALPHA;	
				case IFormat.LUMINANCE8: return GL_COMPRESSED_LUMINANCE;	
				
				// RGB -> DXT1 or GL_COMPRESSED_RGB
				case IFormat.RGB8: return hasCompressionFormat(GL_COMPRESSED_RGB_S3TC_DXT1_EXT) 
				                          ? GL_COMPRESSED_RGB_S3TC_DXT1_EXT 
				                          : GL_COMPRESSED_RGB;
				
				// RGBA -> DXT5 or GL_COMPRESSED_RGBA
				case IFormat.RGBA8:  return hasCompressionFormat(GL_COMPRESSED_RGBA_S3TC_DXT5_EXT) 
				                          ? GL_COMPRESSED_RGBA_S3TC_DXT5_EXT 
				                          : GL_COMPRESSED_RGBA;
				default: assert(false);
			}
		}
	}
	
	private 
	{
		
		GLint translateIformat_toGL(IFormat fmt, bool compressed)
		{
			if (compressed)
			{
				return chooseCompressionScheme(fmt);
			} 
			else
			{
				switch(fmt)
				{
					case IFormat.I8: return GL_LUMINANCE;
					case IFormat.I16F: return GL_LUMINANCE16F_ARB;
					case IFormat.I32F: return GL_LUMINANCE32F_ARB;
					case IFormat.ALPHA8: return GL_ALPHA;
					case IFormat.ALPHA16F: return GL_ALPHA16F_ARB;
					case IFormat.ALPHA32F: return GL_ALPHA32F_ARB;
					case IFormat.LUMINANCE8: return GL_LUMINANCE;
					case IFormat.LUMINANCE16F: return GL_LUMINANCE16F_ARB;
					case IFormat.LUMINANCE32F: return GL_LUMINANCE32F_ARB;
					case IFormat.RGB8: return GL_RGB;
					case IFormat.RGB16F: return GL_RGB16F_ARB;
					case IFormat.RGB32F: return GL_RGB32F_ARB;
					case IFormat.RGBA8: return GL_RGBA;
					case IFormat.RGBA16F: return GL_RGBA16F_ARB;
					case IFormat.RGBA32F: return GL_RGBA32F_ARB;
					default: assert(false);
				}
			}			
		}
		
		
		static const GLint[Format.max + 1] Format_toGL = 		
		[
			GL_LUMINANCE,
			GL_RGB,
			GL_RGBA,
			GL_BGR,
			GL_BGRA,
			GL_DEPTH_COMPONENT
		];	
		
		static const GLint[Type.max + 1] Type_toGL = 		
		[
			GL_UNSIGNED_BYTE,
			GL_BYTE,
			GL_UNSIGNED_SHORT,
			GL_SHORT,
			GL_UNSIGNED_INT,
			GL_INT,
			GL_FLOAT
		];	
		
		static const GLint[Wrap.max + 1] Wrap_toGL = 
		[ 
			GL_CLAMP, 
			GL_CLAMP_TO_EDGE, 
			GL_REPEAT, 
			GL_CLAMP_TO_BORDER, 
			GL_MIRRORED_REPEAT 
		];
		
		static const GLint[Filter.max + 1] Filter_toGL = 
		[ 
			GL_NEAREST, 
			GL_LINEAR, 
			GL_NEAREST_MIPMAP_NEAREST, 
			GL_NEAREST_MIPMAP_LINEAR, 
			GL_LINEAR_MIPMAP_NEAREST, 
			GL_LINEAR_MIPMAP_LINEAR 
		];
		
		GLuint m_handle;
		GLint m_target;
		GLint m_width, m_height, m_depth;
		GLint m_iFormat;
		
		
		final void bind() 
		{		
			glBindTexture(m_target, m_handle);				
		}
		
		final int getParam(GLenum paramName) 
		{
			
			int res;
			bind();
			glGetTexParameteriv(m_target, paramName, &res);
			return res;
			
		}		
		
		final int getLevelParam(GLenum paramName, int level)
		{			
			int res;
			bind();
			glGetTexLevelParameteriv(m_target, level, paramName, &res);
			return res;			
		}
			
	}	
		
	
	public {
		
		
		this(GLint target, IFormat iFormat, bool useCompression) 
		{
			m_target = target;			
			m_iFormat = translateIformat_toGL(iFormat, useCompression);
			glGenTextures(1, &m_handle);
			GL.check();
			minFilter = Filter.NEAREST;	
			magFilter = Filter.NEAREST;
			wrapS = Wrap.CLAMP_TO_EDGE;
			wrapT = Wrap.CLAMP_TO_EDGE;	
			m_width = m_height = m_depth = 0;			
		}		
		
		~this() 
		{		
			glDeleteTextures( 1, &m_handle);
			GL.check();				
		}
		
		
		final void use(int unit) 
		{		
			
			glActiveTexture(GL_TEXTURE0 + unit);
			glEnable(m_target);				
			GL.check();
			bind();
		}
		
		
		final int width()
		{
			return m_width;
		}
		
		final int height()
		{
			return m_height;
		}
	
		final int depth()
		{
			return m_depth;
		}
				
		
		final Wrap wrapS(Wrap w) 
		{		
			bind();
			glTexParameteri(m_target, GL_TEXTURE_WRAP_S, Wrap_toGL[w]);
			GL.check();
			return w;			
		}
		
		final Wrap wrapT(Wrap w) 
		{
		
			bind();
			glTexParameteri(m_target, GL_TEXTURE_WRAP_T, Wrap_toGL[w]);
			GL.check();
			return w;			
		}
		
		final Wrap wrapR(Wrap w) 
		{
		
			bind();
			glTexParameteri(m_target, GL_TEXTURE_WRAP_R, Wrap_toGL[w]);
			GL.check();
			return w;
			
		}
		
		final Filter minFilter(Filter f) 
		{
			
			bind();
			glTexParameteri(m_target, GL_TEXTURE_MIN_FILTER, Filter_toGL[f]);
			GL.check();
			return f;			
		}
		
		final Filter magFilter(Filter f) 
		{
			
			bind();
			assert( (f == Filter.NEAREST) || (f == Filter.LINEAR) );
			glTexParameteri(m_target, GL_TEXTURE_MAG_FILTER, Filter_toGL[f]);
			GL.check();
			return f;			
		}
				
		final float priority()
		{
			bind();
			GLfloat p;
			glGetTexParameterfv(m_target, GL_TEXTURE_PRIORITY, &p);
			GL.check();
			return p;
		}
		
		final float priority(float pr)
		{
			bind();
			glTexParameterf(m_target, GL_TEXTURE_PRIORITY, pr);
			GL.check();
			return pr;
		}		
		
		GLint handle() 
		{		
			return m_handle;				
		}
		
		GLuint target() 
		{
		
			return m_target;			
				
		}
		
		void getImage(int level, Format format, Type type, void * pixels) 
		{
		
			bind();
			glGetTexImage(m_target, level, Format_toGL[format], Type_toGL[type], pixels);
			GL.check();
				
		}
		
		static final int maxTextureUnit() 
		{
			
			GLint ntu;
			glGetIntegerv(GL_MAX_TEXTURE_UNITS, &ntu);			
			GL.check();
			return ntu;
			
		}
		
		final void generateMipmaps()
		{
			bind();
			glGenerateMipmapEXT(m_target);
			GL.check();
		}
		
		final int baseLevel(int base)
		{
			bind();
			glTexParameteri(m_target, GL_TEXTURE_BASE_LEVEL, base);	
			GL.check();	
			return base;
		}
		
		final int maxLevel(int level)
		{
			bind();
			glTexParameteri(m_target, GL_TEXTURE_MAX_LEVEL, level);	
			GL.check();	
			return level;
		}
	}
}

class Texture1D : Texture 
{	
	public 
	{		
		this(IFormat iFormat, bool useCompression) 
		{			
			super(GL_TEXTURE_1D, iFormat, useCompression);
		}
		
		void setImage(int level, int width, Format format, Type type, void * data, bool mipmapped) 
		{			
			bind();			
				
			if ( mipmapped )
			{
				gluBuild1DMipmaps(m_target, 
				                  m_iFormat, 
				                  width,
				                  Format_toGL[format],
				                  Type_toGL[type],
				                  data);
			}
			else
			{
				if ((this.width == width))
				{
					setSubImage(0, 0, width, format, type, data);
				} 
				else
				{
					glTexImage1D(m_target, 
			             level, 
			             m_iFormat, 
			             width, 
			             0, 
			             Format_toGL[format], 
			             Type_toGL[type], 
			             data);
				}
			}
			
			GL.check();		
			m_width = width;	
			m_height = 1;
			m_depth = 1;
		}
		
		void setSubImage(int level, int x, int width, Format format, Type type, void * data) 
		{
			bind();
			glTexSubImage1D(m_target, 
			             level, 
			             x,
			             width, 
			             Format_toGL[format], 
			             Type_toGL[type], 
			             data);
			GL.check();
		}
		
	}
	
}

class Texture2D : Texture 
{	
	public 
	{		
		this(IFormat iFormat, bool useCompression)
		{	
			super(GL_TEXTURE_2D, iFormat, useCompression);			
		}
		
		void setImage(int level, int width, int height, Format format, Type type, void * data, bool mipmapped) 
		{			
			
			bind();
			
			
			if ( mipmapped )
			{
				gluBuild2DMipmaps(m_target, 
				                  m_iFormat, 
				                  width,
				                  height,
				                  Format_toGL[format],
				                  Type_toGL[type],
				                  data);
			} else
			{
				if ((this.width == width) && (this.height == height))
				{
					setSubImage(0, 0, 0, width, height, format, type, data);
				} 
				else
				{
					glTexImage2D(m_target, 
					             level, 
					             m_iFormat, 
					             width, 
					             height,
					             0, 
					             Format_toGL[format], 
					             Type_toGL[type], 
					             data);
				}
			}
			GL.check();
			m_width = width;	
			m_height = height;
			m_depth = 1;			
			
		}
	
		
	
		
				
		void setSubImage(int level, int x, int y, int width, int height, Format format, Type type, void * data) 
		{		
			bind();
			glTexSubImage2D(m_target, 
			             level, 
			             x,
			             y,
			             width, 
			             height,
			             Format_toGL[format], 
			             Type_toGL[type], 
			             data);
			GL.check();		
		}	
		
		recti rect() 
		{ 
			return recti(0, 0, m_width, m_height); 
		}
	}	
}

class Texture3D : Texture 
{	
	public 
	{		
		
		this(IFormat iFormat, bool useCompression) 
		{	
			assert(!useCompression, "cannot compress 3D texture");		
			super(GL_TEXTURE_3D, iFormat, useCompression);
			
		}	
		
		void setImage(int level, int width, int height, int depth, Format format, Type type, void * data, bool mipmapped) 
		{
			
			bind();			
			
			
				
			if ( mipmapped )
			{
				assert(false, "cannot mipmap 3D texture yet");	 
				// seems to require GLU 1.3 (?)
				/*gluBuild3DMipmaps(m_target, 
				                  m_iFormat, 
				                  width,
				                  height,
				                  depth,
				                  Format_toGL[format],
				                  Type_toGL[type],
				                  data);*/
			} else
			{
				if ((this.width == width) && (this.height == height) && (this.depth == depth))
				{
					setSubImage(0, 0, 0, 0, width, height, depth, format, type, data);
				} 
				else
				{
					glTexImage3D(m_target, 
			             level, 
			             m_iFormat, 
			             width, 
			             height,
			             depth,
			             0, 
			             Format_toGL[format], 
			             Type_toGL[type], 
			             data);
				}
			}			
			
			GL.check();
			m_width = width;	
			m_height = height;
			m_depth = depth;			
		}
		
		
		void setSubImage(int level, int x, int y, int z, int width, int height, int depth, Format format, Type type, void * data) 
		{
		
			bind();
			glTexSubImage3D(m_target, 
			             level, 
			             x,
			             y,
			             z,
			             width, 
			             height,
			             depth,
			             Format_toGL[format], 
			             Type_toGL[type], 
			             data);			
			GL.check();
		
		}
		
	
		
	}
	
}

class CubeMap : Texture
{
	public
	{
		enum Face { POS_X, NEG_X, POS_Y, NEG_Y, POS_Z, NEG_Z };
		
	}
	private
	{
		static const GLenum Face_toGL[6] = 
		[           
			GL_TEXTURE_CUBE_MAP_POSITIVE_X,
			GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
			GL_TEXTURE_CUBE_MAP_POSITIVE_Y,
			GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
			GL_TEXTURE_CUBE_MAP_POSITIVE_Z,
			GL_TEXTURE_CUBE_MAP_NEGATIVE_Z,
		];
	}

	
	public
	{
		this(IFormat iFormat, bool useCompression) 
		{			
			super(GL_TEXTURE_CUBE_MAP, iFormat, useCompression);
		}
		
		void setAllImages(int level, int width, int height, Format format, Type type, void * data, bool mipmap) 
		{
			
			bind();
			
			for (Face f = Face.min; f <= Face.max; ++f)
			{
				glTexImage2D(Face_toGL[f], level, m_iFormat, width, height, 0, Format_toGL[format], Type_toGL[type], data);
			}
			
			if (mipmap) generateMipmaps();

			
			GL.check();
			m_width = width;	
			m_height = height;
			m_depth = 1;			
		}
	}
}