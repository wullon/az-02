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
module demo.azrfile;

import std.stream, std.regexp, std.conv, std.file, std.date, std.string, std.stdio;

import gl.all;
import util.all;
import util.geometry.all;
import sdl.all;
import demo.demo;
import demo.azrstep;

class AZRException : object.Exception
{	
	this(char[] filename, ulong linenumber, char[] msg)
	{
		super(format("%s(%s) : %s", filename, linenumber, msg));
	}
}



final class AZRAnimation
{
	class Token
	{
		public
		{
			char[] s;	
			ulong line;
			
			this(char[] _s, ulong _line)
			{
				s = _s;
				line = _line;
			}
		}	
	}
	
	private
	{
		Vector!(AZRStep) m_steps;
		TexturePool m_pool;
		bool m_viewBox = false;
		
		Shader m_blitShader;
		
	}
		
	public
	{
		this()
		{
			m_steps = new Vector!(AZRStep)();
			m_pool = new TexturePool();
		}
		
		this(char[] filename)
		{
			this();
			load(filename);			
		}
		
		void load(char[] filename)
		{
			if (filename is null) return;	
			m_steps.clear(); // clear old steps
			
			m_blitShader = Demo.loadShader("blit");
			
			auto tokens = new Vector!(Token)(); 
			
			{
				auto scope file = new BufferedFile(filename);
				int nol = 0;			
				
				while (!file.eof()) 
				{
					char[] line = file.readLine();	
					++nol;
				
					foreach (s; std.regexp.split(line, "\\s+"))
	 				{
		 				// eliminate empty token
		 				if (s != "") tokens.add(new Token(s, nol));
	 				}
				}
				file.close();
			}
			
			bool isComment(Token token)
			{
				return token.s[0] == '#';
			}			
			
			int currentToken = 0;
			
			Token nextToken()
			{
				while(currentToken < tokens.size)
				{
					Token t = tokens.get(currentToken);
					
					currentToken++;
					
					if (isComment(t)) // remove comments
					{
						while(currentToken < tokens.size)
						{
							Token t2 = tokens.get(currentToken);	
							if (t2.line != t.line) break;
							else currentToken++;
						} 
						
					} else return t;
				}	
				return null;
			}
			
					
			
			// interpreting the AZR
			
			Token t = nextToken();
			if (t.s != "AZR")
			{
				throw new AZRException(filename, t.line, format("not an AZR file (%s instead)", t.s));
			}
			
			t = nextToken();
			if (t.s != "version")
			{
				throw new AZRException(filename, t.line, "'version' directive expected");				
			}
			
			t = nextToken();
			int ver = toInt(t.s);
			
			if (ver < 0) throw new AZRException(filename, t.line, "such a version does not exist. Don't cheat with me");				
			if (ver > 1) throw new AZRException(filename, t.line, "unsupported version");
			
			vec4f currentColor = vec4f(1.f,1.f,1.f,1.f);
			float currentWidth = 3.f;
			
			Token tok;
			while (( tok = nextToken()) !is null)
			{
				switch(tok.s)
				{
					case "step":
					
						string filen = nextToken().s;						
						float x = atof(nextToken().s);
						float y = atof(nextToken().s);
						float size = atof(nextToken().s);
						float angle = atof(nextToken().s);						
						
						try
						{
							auto tex = m_pool.texture(filen);
							if (tex.width == 1024 && tex.height == 1024) 
							{
								m_steps.add(new AZRStep(tex, filen, vec2f(x,y), size, angle));									
							} 
							else
							{
								throw new AZRException(filename, tok.line, format("%s n'existe pas ou n'est pas a la bonne taille (1024x1024)", filen));	
							}
							
							
						} catch(Error e)
						{
							throw new AZRException(filename, tok.line, format("%s n'a pas pu etre chargee", filen));	
						}
						break;
					
					default:
						throw new AZRException(filename, tok.line, format("unknown token : %s", tok.s ));
				}
			}	
			
			// make neighbours
			
			for (int i = 0; i < m_steps.length - 1; ++i)
			{
				m_steps[i].next = m_steps[i+1];
				m_steps[i+1].previous = m_steps[i];
			}
						
			
		}
		
		void save(char[] filename)
		{
			auto scope file = new File(filename, FileMode.OutNew);
			file.writefln("AZR");
			file.writefln("version 1");
			foreach (step; m_steps)
			{
				file.writefln("%s", step);	
			}
			
			scope(exit) file.close();
		}
		
		void draw(double progression, int bias)
		{
			
			GL.setBlend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA, 
		                GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
	                
			
			const int DEPTH = 8;
			
		    if (progression < 0.f) progression = 0.f;
		    int base = cast(int)(progression);
		    double frac = progression - base;		    
		    Texture2D[DEPTH] tex;		    
		    mat4f[DEPTH] mat;
		    
		    int effective = 0;
		    for (int i = 0; i < tex.length; ++i)
		    {
				if (i + base < m_steps.length) 
				{
					effective++;
					tex[i] = m_steps[i + base].texture;
					mat[i] = m_steps[i + base].matrix;
					
				} else
				{
					tex[i] = null;
					mat[i] = mat4f.identity;					
				} 
		    }
		    
		    glPushMatrix();
		    GL.scale(5.0,5.0,5.0);
		    
		    if (effective >= 0)
		    {
			    
			    
			    		    	
		    	auto mat0Inv = (tex[0] is null) ? mat4f.identity : m_steps[base].invMatrixSmooth(frac);		    
		    	
		    	
		    	GL.multMatrix(mat0Inv);
		    	
	    	}
		    
		    void drawTexture(int i)
		    {
			    GL.pushMatrix();
			    GL.multMatrix(mat[i]);
			    
			    if (i < effective - 1) drawTexture(i+1);
			    
			    GL.popMatrix();
			    
			    if (tex[i] !is null)
			    {
				    Shader.useDefault();
				    m_blitShader.setSampler("tex", tex[i], 0);
					m_blitShader.use();
				    GL.color = vec4f(1);
				    
				   	glBegin(GL_QUADS);	
						glColor4f(1,1,1,1);				
						glTexCoord2f(0,1); glVertex2f(-1,-1);	
						glTexCoord2f(1,1); glVertex2f(+1,-1);
						glTexCoord2f(1,0); glVertex2f(+1,+1);
						glTexCoord2f(0,0); glVertex2f(-1,+1);				
					glEnd();
				}
		    }
		    drawTexture(0);	
		    glPopMatrix();
		    
		}
		
		int length()
		{
			return m_steps.length;	
		}
		
		AZRStep step(int i)
		{
			return m_steps[i];	
		}
		
		AZRStep currentStep(float progression, int bias)
		{
		    int base = cast(int)(progression) + bias;
		    if (base < 0) return null;
		    if (base >= length) return null;
		    else return step(base);
		}
		
		void multSize(float progression, float factor, int bias)
		{
			auto step = currentStep(progression, bias);
			if (step !is null)
			{
				step.size = step.size * factor;	
			}
		}
		
		void incAngle(float progression, float angle, int bias)
		{
			auto step = currentStep(progression, bias);
			if (step !is null)
			{
				step.angle = step.angle + angle;	
			}
		}
		
		void movCenter(float progression, vec2f movement, int bias)
		{
			auto step = currentStep(progression, bias);
			if (step !is null)
			{
				step.center = step.center + movement;	
			}
		}
		
		void toggleViewBox()
		{
			m_viewBox = !m_viewBox;
		}
	}
}

