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
module demo.bitmapfont;

import gl.all;
import util.all;
import util.geometry.all;
import demo.demo;
import sdl.sdlimage;

final class BitmapFont
{
	
	public
	{
		Texture2D fillTexture()
		{
			return m_fillTex;	
		}	
		
	}
	
	private
	{
		Texture2D m_tex; // the letters
		Texture2D m_fillTex; // filling
		Shader m_shader;
		int m_widths[256];		// width of each character
		
		
		void drawChar(float x, float y, float factor, char a, vec4f color, vec4f color2, float letterSize)
		{
			float cw = cellWidth;
			float ch = cellHeight;
			auto xmin = x ;
			auto xmax = x + cw * factor;
			auto ymin = y ;
			auto ymax = y + ch * factor;
			
	/*		auto prout = 0.005f;
			auto xmin2 = x - prout ;
			auto xmax2 = x + cw * factor + prout;
			auto ymin2 = y - prout;
			auto ymax2 = y + ch * factor + prout;
	*/		
			
			auto xmid = (xmin + xmax) * 0.5f;
			auto ymid = (ymin + ymax) * 0.5f;
			xmin = lerp(xmin, xmid, (1.f - letterSize));
			xmax = lerp(xmax, xmid, (1.f - letterSize));
			ymin /= powf(letterSize, 0.1) + 0.001;
			ymax /= powf(letterSize, 0.1) + 0.001;
			
			ubyte b = cast(ubyte) a; // assume ASCII-compatible utf-8 !!!
			
			// ugly hack to support some french characters without utf-8 -> iso-something converting
			if (b == 1) b = 0xEA; // &ecirc;
			if (b == 2) b = 0xE9; // &eacute;
			if (b == 3) b = 0xE8; // &egrave;
			
			int ligne = (b / 16);
			int col = (b & 15);
			
		    float s = col * (1.0f / 16.0f) + 0.01f / 16.f;
		    float s2 = s + (0.98f / 16.0f);
		    
		    float t = ligne * (1.0f / 16.0f) + 0.01f / 16.f;
		    float t2 = t + (0.98f / 16.0f);		
		    
	
	 	
		    
    		
			 
			glColor4fv(color.ptr); 
			glTexCoord2f(s, t);	glVertex2f(xmin, ymax);
			glColor4fv(color2.ptr);
			glTexCoord2f(s2, t);  glVertex2f(xmax, ymax);
			glTexCoord2f(s2, t2); glVertex2f(xmax, ymin);
			glColor4fv(color.ptr); 
			glTexCoord2f(s, t2);  glVertex2f(xmin, ymin);
			
		}
	}	
	
	public
	{
		this(char[] file, char[] file2)
		{
			
			{
				// load text texture
				m_tex = new Texture2D(Texture.IFormat.RGBA8, true);
				m_tex.minFilter = Texture.Filter.LINEAR_MIPMAP_LINEAR;
				m_tex.magFilter = Texture.Filter.LINEAR;
				m_tex.wrapS = Texture.Wrap.CLAMP_TO_EDGE;
				m_tex.wrapT = Texture.Wrap.CLAMP_TO_EDGE;
				scope auto img = new SDLImage(file);
				img.lock();
				m_tex.setImage(0, img.width, img.height, Texture.Format.RGBA, Texture.Type.UBYTE, img.data, true);
				img.unlock();
				
				// load filling texture
				m_fillTex = new Texture2D(Texture.IFormat.RGBA8, true);
				m_fillTex.minFilter = Texture.Filter.LINEAR_MIPMAP_LINEAR;
				m_fillTex.magFilter = Texture.Filter.LINEAR;
				m_fillTex.wrapS = Texture.Wrap.REPEAT;
				m_fillTex.wrapT = Texture.Wrap.REPEAT;
				scope auto img2 = new SDLImage(file2);
				img2.lock();
				m_fillTex.setImage(0, img2.width, img2.height, Texture.Format.RGBA, Texture.Type.UBYTE, img2.data, true);
				img2.unlock();
				
				
				// analysis to find the width of each character
				auto scope image = new Image(img);
				
				for (int i = 0; i < 256; ++i)
				{
					int ligne = (i / 16);
					int col = (i & 15);
					
					int bx = cellWidth() * col;
					int by = cellHeight() * ligne;
					
					m_widths[i] = cellWidth() >> 1;
					
					for (int x = cellWidth() - 1; x >= 0; --x)
					{
						for (int y = 0; y < cellHeight(); ++y)
						{
							uint c = image.getPixel(bx + x, by + y);
							
							if (Avalue(c) > 0)
							{
								m_widths[i] = x;
								goto end_of_loops;
							}
						}
					}
					
					end_of_loops: ;
					
				}
				
			}
			
			m_shader = Demo.loadShader("font");
			m_shader.setSampler("tex", m_tex, 0);
			m_shader.setSampler("fill", m_fillTex, 1);
			
		}		
		
		int cellWidth()
		{
			return m_tex.width / 16;	
		}
		
		int cellHeight()
		{
			return m_tex.height / 16;	
		}
		
		int charWidth(char a)
		{
			ubyte b = cast(ubyte) a;
			return m_widths[b];
		}
		
		int charHeight()
		{
			return cellHeight();
		}
		
		// draw a string on the screen, centered in (x, y) with a given expected width 
		void drawString(char[] s, float x, float y, float width, vec4f color1, vec4f color2, float progression = 1.f, float letterSize = 1.f )
		{
			
			float real_width = getStringWidth(s);
		    float factor = width / real_width;
		    
		 
		    
			
			
			if (s == "") return;
			
			GL.disable( GL_DEPTH_TEST, GL_CULL_FACE ); 		    
		    GL.enable(GL_BLEND, GL_ALPHA_TEST);
		    GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA,
 			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			
 			            
		    m_shader.use();
		    
		    float bx = x - width * 0.5f;		      
		    
		    progression = 0.5f + (progression - 0.5f) * 1.2f;
		    
		    glBegin(GL_QUADS);								 
				for (int i = 0; i < s.length; ++i)
				{
					float t = i / cast(float)s.length;
					float t2 = (i+1) / cast(float)s.length;
					float cy = y - factor * (charHeight() * 0.5f);
					
					vec4f colorLeft = lerp( color1, color2, smoothStep(progression - 0.1, progression + 0.1, t));
					vec4f colorRight = lerp( color1, color2, smoothStep(progression - 0.1, progression + 0.1, t2));					
					
					drawChar( bx, cy, factor, s[i], colorLeft, colorRight, letterSize);
					bx += charWidth(s[i]) * factor;
				}				
			glEnd();
		}
		
		int getStringWidth(char[] s)
		{
			int w = 0;
			for (int i = 0; i < s.length; ++i)
			{
				w += charWidth(s[i]) + 2;	
			}
			return w;
		}
		
		int getStringHeight(char[] s)
		{
			return charHeight();
		}
		
	}
}