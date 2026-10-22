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
module demo.demo;

import util.all;
import util.geometry.all;
import demo.trackinfo;
import demo.effect;
import demo.postprocess;
import demo.effectcollection;
import demo.bitmapfont;
import demo.musicplayback;
import demo.loadingscreen;
import gl.all;
import audio.all;
import audio.modules.all;
import sdl.all;

final class Demo
{
	public
	{
		auto const BPM = 135.0;
		auto const TIME_PER_BEAT = 60.0 / BPM;
		auto const TIME_PER_BEAT_INV = BPM / 60.0;
		
		enum CommonTexture { PINK_NOISE, WHITE_NOISE, WATER, INSECT, WHITE_NOISE_3D, STARS, CHECKERS };
		
	}
	
	
	private
	{
		recti m_viewport; // viewport for effects (0,0)-(width,height)
		recti m_finalViewport; // viewport for render (the same but centered)
		
		int m_width;
		int m_height;
		float m_ratio;
		
		TrackInfo m_trackInfo;
		FBO m_mainFBO;
		
		
		// in az02 there is 2 layers of effects
		EffectCollection m_layer1Effects;		
		EffectCollection m_layer2Effects;
		
		PostProcess m_postProcess;
		
		static const int NUMBER_OF_INTER_TEXTURE = 2;
		
		Texture2D m_mainTexture;
		RenderBuffer m_mainDepthBuffer;
		
		Texture2D m_interTexture[NUMBER_OF_INTER_TEXTURE];
		FBO m_interFBO;
		
		int m_lastInterTextureIndex = -1;
		int m_currentInterTextureIndex = 0;
		
		MusicPlayback m_musicPlayback;
		
		// used for time travel (debug)
		double m_timeModifier = 0.0; 
		
		// used for synchonisation
		// smooth the time difference between music and graphics
		double m_timeDifferenceSmooth = 0.0; 
		
		Shader m_putShader;
		
		
		Texture m_commonTexture[CommonTexture.max+1];
		
		bool m_musicEnabled;
		string m_musicFile;
		float m_gamma;
	
		SDL m_SDL;
		
		 
		BitmapFont m_font;
		BitmapFont m_greetzFont;
		
		
		void createTextureAndFBOs() // supposed fast enough to do this in the constructor
		{
			trace(">Demo.createTextureAndFBOs()");
			
			m_mainTexture = new Texture2D(Texture.IFormat.RGBA8, false); 
			
			m_mainTexture.minFilter = Texture.Filter.LINEAR;//NEAREST;
			m_mainTexture.magFilter = Texture.Filter.LINEAR;//NEAREST;
			m_mainTexture.wrapS = Texture.Wrap.CLAMP_TO_EDGE;
			m_mainTexture.wrapT = Texture.Wrap.CLAMP_TO_EDGE;
			m_mainTexture.setImage(0, width, height, Texture.Format.RGBA, Texture.Type.UBYTE, null, false);
			
			GL.check();
			
			m_mainDepthBuffer = new RenderBuffer(RenderBuffer.Format.DEPTH, width, height);
			
			GL.check();
			
			m_mainFBO = new FBO();
			m_mainFBO.color[0].setTarget(m_mainTexture, 0);
			m_mainFBO.depth.setTarget(m_mainDepthBuffer);
			m_mainFBO.setDrawBuffers([0]);
			m_mainFBO.setWrite(FBO.Component.COLORS_AND_DEPTH);
			m_mainFBO.check();
			
			GL.check();
			
			
			
			
			foreach (ref tex; m_interTexture)
			{
				tex = new Texture2D(Texture.IFormat.RGBA8, false); 
				tex.minFilter = Texture.Filter.LINEAR;//NEAREST;
				tex.magFilter = Texture.Filter.LINEAR;//NEAREST;
				tex.wrapS = Texture.Wrap.CLAMP_TO_EDGE;
				tex.wrapT = Texture.Wrap.CLAMP_TO_EDGE;
				tex.setImage(0, width, height, Texture.Format.RGBA, Texture.Type.UBYTE, null, false);
				GL.check();
			}
			
			
			m_interFBO = new FBO();			
			m_interFBO.setDrawBuffers([0]);
			m_interFBO.setWrite(FBO.Component.COLORS); // no depth buffer for now
			GL.check();
			
			trace("<Demo.createTextureAndFBOs()");
		}
		
		void cycleInterTexture()
		{
			m_lastInterTextureIndex = m_currentInterTextureIndex;
			m_currentInterTextureIndex = (m_currentInterTextureIndex + 1) % NUMBER_OF_INTER_TEXTURE;
			
			m_interFBO.color[0].setTarget(currentInterTexture, 0);	
			
			
			
		}
		
		void loadMusic(char[] s, bool musicEnabled)
		{
			m_musicPlayback	= new MusicPlayback(s, musicEnabled);
		}
		
		
	}
	
	public
	{
		this( recti viewport, string musicFile, float gamma, bool musicEnabled )
		{
			trace(">Demo.this");
						
			
			m_SDL = SDL.instance;
			m_finalViewport = viewport;
			m_viewport = recti(vec2i(0,0), vec2i(viewport.width, viewport.height));
			
			m_width = viewport.width;
			m_height = viewport.height;
			
			m_ratio = m_width / cast(float)m_height;
			
			m_layer1Effects = new EffectCollection("layer 1");
			m_layer2Effects = new EffectCollection("layer 2");
			
			m_musicFile = musicFile;
			m_musicEnabled = musicEnabled;
			m_gamma = gamma;
			GL.check();
			trace("<Demo.this");
		}	
		
		~this()
		{
			
		}
		
		void loadAll()
		{
			trace(">Demo.loadAll");
			// loading the loading Screen
			trace("load put shader");
			m_putShader = Demo.loadShader("put");
			trace("> load loading screen");
			
			scope auto loadingScreen = new LoadingScreen(m_viewport, m_finalViewport, m_gamma);
			loadingScreen.progress(0);
			
			trace("load font");
			m_font = new BitmapFont("data/tex/font.png", "data/tex/font2.jpg");
			m_greetzFont = new BitmapFont("data/tex/greetzfont.png", "data/tex/font2.jpg");
			
			
			// load track info
			trace(" load tracks info");
			m_trackInfo = new TrackInfo(); 
			loadingScreen.progress(5);
			
			trace(" load render textures and FBO");
			// ditto
			createTextureAndFBOs();
			
			trace(" load postprocessing");
			// create PostProcess object
			m_postProcess = new PostProcess(this, m_finalViewport, m_gamma);
			loadingScreen.progress(10);
			
			m_commonTexture[CommonTexture.PINK_NOISE] = loadTexture2D("data/tex/pinknoise.png", 
			                                                          Texture.IFormat.I8, 
			                                                          Texture.Filter.LINEAR_MIPMAP_LINEAR, 
			                                                          Texture.Filter.LINEAR,
			                                                          Texture.Wrap.REPEAT, true, false);
			                                                          
			m_commonTexture[CommonTexture.WATER] = loadTexture2D("data/tex/water.jpg", 
			                                                           Texture.IFormat.RGB8, 
			                                                           Texture.Filter.LINEAR_MIPMAP_LINEAR, 
			                                                           Texture.Filter.LINEAR,
			                                                           Texture.Wrap.REPEAT, true, true);	
			                                                           
			m_commonTexture[CommonTexture.INSECT] = loadTexture2D("data/tex/insect.png", 
			                                                           Texture.IFormat.RGBA8, 
			                                                           Texture.Filter.LINEAR_MIPMAP_LINEAR, 
			                                                           Texture.Filter.LINEAR,
			                                                           Texture.Wrap.REPEAT, true, true);
			                                                           
			m_commonTexture[CommonTexture.STARS] = loadTexture2D("data/tex/space1.jpg", 
			                                                     Texture.IFormat.RGB8,
			                                                     Texture.Filter.LINEAR_MIPMAP_LINEAR, 
			                                                     Texture.Filter.LINEAR, 
			                                                     Texture.Wrap.REPEAT, true, true);
			                                                     
			 m_commonTexture[CommonTexture.CHECKERS] = loadTexture2D("data/tex/checkers.jpg", Texture.IFormat.RGB8, 
			                                                         Texture.Filter.LINEAR_MIPMAP_LINEAR, 
			                                                         Texture.Filter.LINEAR,
			                                                         Texture.Wrap.REPEAT, true, false); 
			
			// build 2D white noise
			{
				Random random = Random();
				const int WHITE_NOISE_2D_SIZE = 256;
				const int WHITE_NOISE_2D_SIZE_POW_2 = WHITE_NOISE_2D_SIZE * WHITE_NOISE_2D_SIZE;
				scope float[] white_noise_2D_data;			                                                           		
				white_noise_2D_data.length = WHITE_NOISE_2D_SIZE_POW_2;
				for (int i = 0; i < WHITE_NOISE_2D_SIZE_POW_2; ++i)
				{
					white_noise_2D_data[i] = random.nextFloat();
				}
				
				auto wn2d_texture = new Texture2D(Texture.IFormat.I8, false);
				wn2d_texture.minFilter = Texture.Filter.LINEAR;
				wn2d_texture.magFilter = Texture.Filter.LINEAR;
				wn2d_texture.wrapS = Texture.Wrap.REPEAT;
				wn2d_texture.wrapT = Texture.Wrap.REPEAT;
				wn2d_texture.wrapR = Texture.Wrap.REPEAT;
				wn2d_texture.setImage(0,WHITE_NOISE_2D_SIZE, WHITE_NOISE_2D_SIZE,  
				                      Texture.Format.INTENSITY, Texture.Type.FLOAT, white_noise_2D_data.ptr, false);
				m_commonTexture[CommonTexture.WHITE_NOISE] = wn2d_texture;
			}
			                                                     
			// build 3D white noise
			{
				Random random = Random();
				const int WHITE_NOISE_3D_SIZE = 32;
				const int WHITE_NOISE_3D_SIZE_POW_3 = WHITE_NOISE_3D_SIZE * WHITE_NOISE_3D_SIZE * WHITE_NOISE_3D_SIZE;
				scope float[] white_noise_3D_data;			                                                           		
				white_noise_3D_data.length = WHITE_NOISE_3D_SIZE_POW_3;
				for (int i = 0; i < WHITE_NOISE_3D_SIZE_POW_3; ++i)
				{
					white_noise_3D_data[i] = random.nextFloat();
				}
				
				auto wn3d_texture = new Texture3D(Texture.IFormat.I8, false);
				wn3d_texture.minFilter = Texture.Filter.LINEAR;
				wn3d_texture.magFilter = Texture.Filter.LINEAR;
				wn3d_texture.wrapS = Texture.Wrap.REPEAT;
				wn3d_texture.wrapT = Texture.Wrap.REPEAT;
				wn3d_texture.wrapR = Texture.Wrap.REPEAT;
				wn3d_texture.setImage(0,WHITE_NOISE_3D_SIZE, WHITE_NOISE_3D_SIZE, WHITE_NOISE_3D_SIZE, 
				                      Texture.Format.INTENSITY, Texture.Type.FLOAT, white_noise_3D_data.ptr, false);
				m_commonTexture[CommonTexture.WHITE_NOISE_3D] = wn3d_texture;
			}
			                                                           
				                                                           
			                                                           		                                                          
			loadingScreen.progress(15);
			
			
			int n_effects = m_layer1Effects.length + m_layer2Effects.length;
			float prog = 15.f;
			float prog_inc = (80.f - 15.f) / n_effects;
			
			trace(" load effect layer 1");
			foreach (Effect e; m_layer1Effects)
			{
				e.load();
				loadingScreen.progress(prog += prog_inc);
			}	
			
			trace(" load effect layer 2");
			foreach (Effect e; m_layer2Effects)
			{
				e.load();
				loadingScreen.progress(prog += prog_inc);
			}
			
			trace(" load music");
			
			loadMusic(m_musicFile, m_musicEnabled);
			loadingScreen.progress(100);
			trace("<Demo.loadAll");
		}
		
		
		void onRun()
		{
			m_musicPlayback.play();
		}
		
		void stopMusicPlayback()
		{
			m_musicPlayback.stopMusicPlayback();
			SDL_Delay(20);
		}
		
		
		// useful for effects
		int width()						{ return m_width;	}
		int height() 					{ return m_height; }		
		float ratio() 					{ return m_ratio; }
		recti viewport() 				{ return m_viewport; }
		
		Texture2D mainTexture() 		{ return m_mainTexture; }
		Texture2D currentInterTexture() { return m_interTexture[m_currentInterTextureIndex]; }
		Texture2D lastInterTexture() 	{ return m_interTexture[m_lastInterTextureIndex]; }
		
		Texture2D commonTexture(CommonTexture ct) 
		{ 
			return cast(Texture2D) m_commonTexture[ct]; 
		}
		
		Texture3D commonTexture3D(CommonTexture ct) 
		{ 
			return cast(Texture3D) m_commonTexture[ct]; 
		}
		
		
		FBO mainFBO() 					{ return m_mainFBO; }
		FBO interFBO()					{ return m_interFBO; }
		
		bool finished()					{ return false; }
		
		EffectCollection FXLayer1() 	{ return m_layer1Effects; }
		EffectCollection FXLayer2() 	{ return m_layer2Effects; }
		PostProcess postProcess()       { return m_postProcess; }
		
		BitmapFont font()               { return m_font; } 
		BitmapFont greetzFont()         { return m_greetzFont; } 
		
		
		Shader putShader()              { return m_putShader; } 
		
		debug 
		{
			void display(float x, float y, string s)
			{
				GL.projectionMatrix = mat4f.scale(vec3f(1 / ratio, 1, 1)); 
				GL.modelviewMatrix = mat4f.identity;
				m_font.drawString(s, x, y, m_font.getStringWidth(s) * 0.001f, vec4f(1.f),  vec4f(1.f), 0.f);
			}
		}
		
		float volume(Track t, double time)
		{
			return m_trackInfo.volume(t, time);
		}
		
		float volumeNormalized(Track t, double time)
		{
			return m_trackInfo.volumeNormalized(t, time);
		}
		
		void draw()
		{
			
			mainTexture.minFilter = Texture.Filter.NEAREST;
			mainTexture.magFilter = Texture.Filter.NEAREST;
			
			mainFBO.use();
			
			m_layer1Effects.draw();
			
			cycleInterTexture();
			
			mainTexture.generateMipmaps;
			mainTexture.minFilter = Texture.Filter.LINEAR_MIPMAP_LINEAR;
			mainTexture.magFilter = Texture.Filter.LINEAR;
			
			currentInterTexture.minFilter = Texture.Filter.NEAREST;
			currentInterTexture.magFilter = Texture.Filter.NEAREST;
			
			lastInterTexture.generateMipmaps;
			lastInterTexture.minFilter = Texture.Filter.LINEAR_MIPMAP_LINEAR;
			lastInterTexture.magFilter = Texture.Filter.LINEAR;
			
			m_layer2Effects.draw();			
			
			currentInterTexture.generateMipmaps;
			currentInterTexture.minFilter = Texture.Filter.LINEAR_MIPMAP_LINEAR;
			currentInterTexture.magFilter = Texture.Filter.LINEAR;
			
			m_postProcess.render(currentInterTexture);
			//m_postProcess.render(m_mainTexture, time);
			
		}		
		
		void move(double globalTime, double dt)
		{
			// THIS IS THE SYNC BETWEEN GRAPHICS AND MUSIC
			// should be OK for Linux
			{
				double timeDifference = m_musicPlayback.streamTimeOffset(globalTime);
				
				// should be FPS independent
				m_timeDifferenceSmooth += (timeDifference - m_timeDifferenceSmooth) * (1.0 - exp(-0.854278547 * dt));
				
				//m_timeDifferenceSmooth = m_timeDifferenceSmooth * 0.99 + timeDifference * 0.01;
				//dt += timeDifference * 0.01; // correct the delta time
			}
			
			double correctedTime = globalTime + m_timeModifier + m_timeDifferenceSmooth;
			
			const double MIN_REWIND = 8.0 * 60 + 0.088;
			const double MAX_REWIND = 8.0 * 60 + 3.543;
			
			if ((correctedTime > MIN_REWIND) && (correctedTime < MAX_REWIND))
			{
				double prog = (correctedTime - MIN_REWIND) / (MAX_REWIND - MIN_REWIND);
				
				const double A = 0.04;
				
				prog = -prog * A + prog * prog * (1.0 + A);
				double timeTravel = lerp(8.0 * 60.0, 1 * 60 + 37.053, prog);
				
				m_layer1Effects.move(timeTravel, dt);
				m_layer2Effects.move(timeTravel, dt);
			} 
			else		
			{			
				m_layer1Effects.move(correctedTime, dt);
				m_layer2Effects.move(correctedTime, dt);
			}
		}		
				
		
		void timeTravel(double diffSec, bool modifyMusic = true) // only for dev
		{
			m_musicPlayback.timeTravel(diffSec);
			m_timeModifier += diffSec;		
		}
		
		debug
		{
			void toogleVisualRatioCue()
			{
				m_postProcess.visualRatioCue = ! m_postProcess.visualRatioCue;
			}
		}
		
		
		// utility : load a texture in one line
   		static Texture2D loadTexture2D(char[] filename, Texture.IFormat iFormat, Texture.Filter minfilter, Texture.Filter magfilter, Texture.Wrap wrap, 
   		                               bool mipmap, bool compress)
   		{
	   		version(Capped)
	   		{
		   		compress = false;	
	   		}
	   		
	   		trace(format("load texture %s", filename));
	   		Texture2D res = new Texture2D(iFormat, compress);
			res.minFilter = minfilter;
			res.magFilter = magfilter;
			res.wrapS = wrap;
			res.wrapT = wrap;
			scope auto img = new SDLImage(filename);
			img.lock();
			res.setImage(0, img.width, img.height, Texture.Format.RGBA, Texture.Type.UBYTE, img.data, mipmap);
			img.unlock();
			return res;
   		}   
   		
   		
   		// utility : load a shader
   		static Shader loadShader(char[] name)
   		{
	   		return new Shader(format("data/shaders/%s.vs", name), format("data/shaders/%s.fs", name));
		}	
	}
}


