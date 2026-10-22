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
module demo.azrstep;

import std.file, std.date, std.string, std.stdio;
import gl.all;
import util.all;
import util.geometry.all;
import sdl.all;
import demo.demo;

class AZRStepException : object.Exception
{	
	this(char[] msg)
	{
		super(msg);
	}
}

class AZRStep
{
	private
	{
		Texture2D m_texture;
		vec2f m_center;
		float m_size;
		float m_angle; // 0 = horizontal	
		char[] m_filename;
		
		AZRStep m_next = null;
		AZRStep m_previous = null;
	}
	
	public
	{
		this(Texture2D tex, char[] filename, vec2f center, float size, float angle)
		{
			
			m_filename = filename;
			m_center = center;
			m_angle = angle;
			m_size = size;
			m_texture = tex;
		}
		
		this(Texture2D thetexture)
		{
			texture = thetexture;
			m_center = vec2f(512,512);
			m_angle = 0;
		}
		
		Texture2D texture()
		{
			return m_texture;
		}
		
		Texture2D texture(Texture2D t)
		{
			if (t.width != 1024 || t.height != 1024) throw new AZRStepException("size of images must be 1024x1024");
			return m_texture;
		}
		
		mat4f matrix()
		{
			vec2f c = (m_center / 512.0) - vec2f(1,1);
			return mat4f.translate(vec3f(c,0)) * mat4f.rotateZ(m_angle) * mat4f.scale(vec3f(m_size / 512.0));
		}
		
		mat4f invMatrix(double frac)
		{
			vec2f c = (m_center / 512.0) - vec2f(1,1);
			return mat4f.scale(vec3f(pow( 512.0 / m_size, frac ))) * mat4f.rotateZ(-m_angle * frac) * mat4f.translate(vec3f(-c * frac,0));
		}
		
		mat4f invMatrix()
		{
			vec2f c = (m_center / 512.0) - vec2f(1,1);
			return mat4f.scale(vec3f(512.0 / m_size)) 
			     * mat4f.rotateZ(-m_angle) * 
			       mat4f.translate(vec3f(-c,0));
		}
		
		vec2f centerLogical()
		{
			return (m_center / 512.0) - vec2f(1,1);
		}
		
		double sFactor() { return 512.0 / m_size; }
		
		mat4f invMatrixSmooth(double frac)
		{
			float fracSmooth = smoothStep(0,1,frac);
			
			vec2f cp0 = vec2f(0);
			vec2f cpm1 = (previous !is null) ? previous.centerLogical : cp0;
			vec2f cp1 = centerLogical();
			vec2f cp2 = next !is null ? next.centerLogical : cp1;
			vec2f c = -hermite(frac, cpm1, cp0, cp1, cp2);
			
			
			
			float a0 = 0.f;
			float am1 = (previous !is null) ?  -previous.m_angle : a0; 			
			float a1 = m_angle;
			float a2 = (next !is null) ? next.m_angle + m_angle : m_angle;			
			float a = hermite(frac, am1, a0, a1, a2);
			
//			auto scale = mat4f.scale(vec3f(pow( 512.0 / m_size, frac )));

			float sm1 = (previous !is null) ? (sFactor() /* 1.f*/ / previous.sFactor) : 1.f;
			float s0 = 1.f;
			float s1 = 1.f; 
			float s2 = ((next !is null) ? next.sFactor / sFactor() : 1.0) * s1;
			
			float s = hermite(frac, sm1, s0, s1, s2);
		
		// hermite cubic interpolation FTW
		/*	float m0 = (s1 - sm1) * 0.5f;
			float m1 = (s2 - s0) * 0.5f;
			float h00 = (1.f + 2.f * frac) * sqr(1.f - frac);
			float h10 = frac * sqr(1.f - frac);
			float h01 = sqr(frac) * (3.f - 2.f * frac);
			float h11 = sqr(frac) * (frac - 1.f);
			float s = h00 * s0 + h10 * m0 + h01 * s1 + h11 * m1;
			if (s < 0.f) s = 0.0001f;
		*/
		//	auto s = hermite(	
			s = s * pow(sFactor(), frac);
			
			auto scale = mat4f.scale(vec3f(s));
			
			auto rotateZ = mat4f.rotateZ(-a);
			auto translate = mat4f.translate(vec3f(c, 0));
			return scale * rotateZ * translate;
		}
		
		
		float size() { return m_size; }
		float size(float s) 
		{ 
			if (s > 1024) s = 1024.f;
			//if (s < 64) s = 64.f;
			return m_size = s; 
		}
		
		vec2f center() { return m_center; }
		vec2f center(vec2f s) 
		{ 
			s.x = clamp(s.x, 0.f, 1023.f);
			s.y = clamp(s.y, 0.f, 1023.f);
			return m_center = s; 
		}
		
		float angle() { return m_angle; }
		float angle(float s) 
		{ 
			s = clamp(s, -PI_F * 0.5f, PI_F * 0.5f);
			return m_angle = s;
		}
		
		override char[] toString()
		{
			return format("step %s %s %s %s %s", m_filename, m_center.x, m_center.y, m_size, m_angle);
		}
		
		AZRStep next() { return m_next; }
		AZRStep next(AZRStep step) { return m_next = step; }
		
		AZRStep previous() { return m_previous; }
		AZRStep previous(AZRStep step) { return m_previous = step; }
		
	}
}


private class TexturePool
{
	private
	{
		Texture2D[char[]] m_textures;	
//		d_time m_timeOfLoad[char[]];		
		
		void loadImage(char[] filepath)
		{
			bool compression = true;
			Texture2D tex = Demo.loadTexture2D(filepath, 
			                                   Texture.IFormat.RGBA8,
			                                   Texture.Filter.LINEAR_MIPMAP_LINEAR, 
			                                   Texture.Filter.LINEAR, 
			                                   Texture.Wrap.CLAMP_TO_EDGE, 
			                                   true, 
			                                   compression);
			m_textures[filepath] = tex;
	//		m_timeOfLoad[filepath] = lastWriteTime(filepath);		
		}
		
		// BUG with Linux		
	/*	d_time lastWriteTime(char[] f)
		{
			d_time t = getUTCtime(); 
			
			bool callback(DirEntry* de)
		    {
				t = de.lastWriteTime;
				return true;
		    }
						
			listdir(f, &callback); 
			return t;		
		}
		*/
	}
	
	public
	{
		this()
		{
		}	
		
		Texture2D texture(char[] filepath) // load a texture and cache it (or use cache instead)
		{
			if (! (filepath in m_textures))
			{
				loadImage(filepath);	
			} 
/*			else
			{
				d_time timeLoading = m_timeOfLoad[filepath];
				d_time timeModified = lastWriteTime(filepath);				
				if (timeModified > timeLoading) 
				{
					m_textures.remove(filepath); // release texture
					loadImage(filepath); // update image
				}
			}
*/			return m_textures[filepath];
		}
	}
}