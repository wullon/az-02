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
module demo.az02program;

import sdl.all;
import util.all;
import util.geometry.all;
import gl.all;
import demo.all;
import demo.fx.all;
import demo.fx2.all;


class AZ02Program : SDLApp
{
	private
	{
		Demo m_demo;
		recti m_view;
	}
	
	public
	{
		this(int asked_width, int asked_height, double ratio, bool fullscreen, int fsaa, bool playMusic, float gamma, bool vsync)
		{
			
			FSAA aa = void;
			if (fsaa == 2) aa = FSAA.FSAA2X;
			else if (fsaa == 4) aa = FSAA.FSAA4X;
			else if (fsaa == 8) aa = FSAA.FSAA8X;
			else if (fsaa == 16) aa = FSAA.FSAA16X;
			else aa = FSAA.OFF;				
			
			
			super(asked_width, asked_height, fullscreen, false, "az02 - Dxtasy", "data/tex/icon.bmp", aa, 0, GLVersion.Version20, vsync);	
			
			GL.check();	
			
			SDL_ShowCursor(SDL_DISABLE);
			
			if (abs(ratio) < 0.0001) // auto ratio
			{
				ratio = cast(double)width / height;
				if (ratio < 5.0 / 4.0) ratio = 5.0 / 4.0;	
				if (ratio > 16.0 / 9.0) ratio = 16.0 / 9.0;
			}
			
			// adjust viewport according to ratio
			m_view = recti(0, 0, width, height).subRectWithRatio(ratio);			
			GL.check();
			
			const SOUND_TRACK = "data/music/ponce_-_Dxtasy.ogg";
			glHint(GL_GENERATE_MIPMAP_HINT, GL_NICEST);
			version(Capped)
			{
				glHint(GL_TEXTURE_COMPRESSION_HINT, GL_NICEST);
			}
			GL.check();
			m_demo = new Demo(m_view, SOUND_TRACK, gamma, playMusic);
			GL.check();
			
			/*****************
			 * TIMELINE HERE *
			 *****************/ 
			void timelineFunction(Demo demo)
			{
					
				const MAIN_EFFECT = 0;
				const LAYER_EFFECT = MAIN_EFFECT+1;
				const BOTTOM_EFFECT = MAIN_EFFECT-1;
				
				trace("creating timeline");
				
				// milestone
				alias Effect.minsec minsec;
				
				const BEGINNING = minsec(0,0.0);
				const SCENE_20_START = minsec(1,53.8744);
				const SCENE_30_START = minsec(2,22.32);
				const KALEIDOSCOP_START = minsec(2,50.75);
				
				const SCENE_40_START = minsec(3,19.21);
				const SCENE_45_START = minsec(3,47.65);
				const SCENE_49_START = minsec(4,16.10);
				const SCENE_50_START = minsec(4,30.316);
				const SCENE_60_START = minsec(4,42.87);
				const SCENE_70_START = minsec(5,12.99);
				const SCENE_80_START = minsec(5,41.43);
				const SCENE_85_START = minsec(6,9.87);
				const SCENE_90_START = minsec(6,31.516);
				const SCENE_PANDAZOOM_START = minsec(6,38.319);
				const SCENE_100_START = minsec(8,3.65);
				const SCENE_110_START = minsec(8,17.878);
				const SCENE_120_START = minsec(8,32.878);
				
				const ENDING = minsec(9,1.0); // 9m01
				const BEAT = 60.0 / 135.0; // length of a beat
				
				
			// EFFECTS THAN SHOULD NOT BE COMMENTED SINCE SEVERAL EFFECTS DEPEND ON THOSE	
				// All BlitFX have been merged since it does nothing, just a copy
				m_demo.FXLayer2.add(new BlitFX(m_demo, 
				                               new TimeSpan( vec2d(SCENE_30_START, KALEIDOSCOP_START),
				                                             vec2d(SCENE_40_START + 8 * BEAT, minsec(3,33.43)), 
				                                             vec2d(SCENE_49_START, SCENE_60_START),
				                                             vec2d(SCENE_60_START, minsec(4,44.54)),
				                                             vec2d(minsec(4,56.95), minsec(4,58.77)),
				                                             vec2d(minsec(5,11.21), minsec(5,41.43)),
				                                             vec2d(SCENE_80_START, minsec(6,30.196)),
				                                             vec2d(minsec(6,36.642), SCENE_100_START) ) , MAIN_EFFECT));
				                                             
				m_demo.FXLayer2.add(new DistortFX(m_demo, new TimeSpan( vec2d(SCENE_20_START + 4.f, SCENE_30_START),
					                                                    vec2d(minsec(3,4.10), minsec(3,4.99)),
					                                                    vec2d(minsec(6,30.196), minsec(6,36.642) )) , LAYER_EFFECT));				                                                     
		
				
				
				
				// Scene10  (eau + planetes)
				{
					m_demo.FXLayer1.add(new Scene10(m_demo, new TimeSpan( vec2d(BEGINNING, SCENE_20_START),
					                                                      vec2d(SCENE_100_START, SCENE_110_START)) , MAIN_EFFECT));
					                                                      
					m_demo.FXLayer1.add(new TrianglesFX(m_demo, new TimeSpan( vec2d(minsec(1,35.65) , SCENE_20_START)) , LAYER_EFFECT));
					                                                 
					
					
					m_demo.FXLayer2.add(new IntroFX(m_demo, new TimeSpan( vec2d(BEGINNING, minsec(0, 30)  )) , LAYER_EFFECT));
					
					m_demo.FXLayer2.add(new BlitCornerFX(m_demo, new TimeSpan( vec2d(BEGINNING, minsec(1,39.65)- 4.f),
					                                                           vec2d(SCENE_100_START, ENDING)) , MAIN_EFFECT));
					
					m_demo.FXLayer2.add(new TunnelizeFX(m_demo, new TimeSpan( vec2d(minsec(1,39.65) - 4.f, SCENE_20_START + 4.f)) , MAIN_EFFECT));
					
					
				}
	
				
				// Scene20 (dans la planete, cellules et serpents)
				{
					m_demo.FXLayer1.add(new Scene20(m_demo, new TimeSpan( vec2d(SCENE_20_START, SCENE_30_START)) , MAIN_EFFECT));
					
					
				}
			
				
				// Scene30 (espace + kaleidoscope)
				{
					m_demo.FXLayer1.add(new Scene30(m_demo, new TimeSpan( vec2d(SCENE_30_START, SCENE_40_START) ) , MAIN_EFFECT));
					m_demo.FXLayer2.add(new KaleidoscopeFX(m_demo, new TimeSpan( vec2d(KALEIDOSCOP_START, SCENE_40_START + 8 * BEAT)) , MAIN_EFFECT));
				}
								
				// Scene40 (serpent dans la salle cubiques + cube recursif)
				{
					m_demo.FXLayer1.add(new Scene40(m_demo, new TimeSpan( vec2d(SCENE_40_START, SCENE_45_START)) , MAIN_EFFECT));
					m_demo.FXLayer2.add(new CubifyFX(m_demo, new TimeSpan( vec2d(minsec(3,33.43), SCENE_45_START )) , MAIN_EFFECT));
				}
				
				// Scene45 (flame fractal)
				{
					m_demo.FXLayer1.add(new Scene45(m_demo, new TimeSpan( vec2d(SCENE_45_START, SCENE_49_START) ) , MAIN_EFFECT));
					m_demo.FXLayer2.add(new LogFX(m_demo, new TimeSpan( vec2d(SCENE_45_START, SCENE_49_START)) , MAIN_EFFECT));
				
				}				
				
				// Scene49
				{
					m_demo.FXLayer1.add(new Scene49(m_demo, new TimeSpan( vec2d(SCENE_49_START, SCENE_50_START) ) , MAIN_EFFECT));
					
					// transition to black
					m_demo.FXLayer1.add(new Fade(m_demo, new TimeSpan( vec2d(SCENE_50_START-3, SCENE_50_START) ) , LAYER_EFFECT, 
				    				                            [vec4f(0,0,0,0), vec4f(0,0,0,1)] ));	
					// Scene50
				
					m_demo.FXLayer1.add(new Scene50(m_demo, new TimeSpan( vec2d(SCENE_50_START, SCENE_60_START) ) , MAIN_EFFECT));
				}
			
				// Scene60 (fille qui parle)
				{
					m_demo.FXLayer1.add(new Scene60(m_demo, new TimeSpan( vec2d(SCENE_60_START - 1 * BEAT, minsec(4,44.54)), // imaginez vous sculpter votre corps
					                                                      vec2d(minsec(4,44.54), minsec(4,56.95)), // DEZOOM
					                                                      vec2d(minsec(4,56.95), minsec(4,58.77)), // un corps fait de courbe et de douceur
					                                                      vec2d(minsec(4,58.77), minsec(5,11.21)), // DEZOOM 2
					                                                      vec2d(minsec(5,11.21), SCENE_70_START + 8 * BEAT), // imaginez vous sculpter votre corps
					                                                      vec2d(minsec(5,25.417) - 4 * BEAT, minsec(5,27.215) + 4 * BEAT), // un corps fait de courbe et de douceur
					                                                      vec2d(minsec(5,39.65), minsec(5,41.43)), // imaginez un corps de reve
					                                                      vec2d(SCENE_90_START, minsec(6,38.319)) // millions de micro-capsules
					                                                      
					                                                    ) , MAIN_EFFECT - 1));
					
					m_demo.FXLayer2.add(new SquarifyFX(m_demo, new TimeSpan( vec2d(minsec(4,44.54), minsec(4,56.95))) , MAIN_EFFECT));
					
					m_demo.FXLayer2.add(new Squarify2FX(m_demo, new TimeSpan( vec2d(minsec(4,58.77), minsec(5,11.21))) , MAIN_EFFECT));
				
					// Scene 70
					
					m_demo.FXLayer1.add(new Scene70(m_demo, new TimeSpan( vec2d(SCENE_70_START, minsec(5,25.417)),
					                                                      vec2d(minsec(5,27.215), minsec(5,39.65))  ) , MAIN_EFFECT));
				}
			
				// Scene 80 (tunnel avec les deux entites)
				{
					auto scene80 = new Scene80(m_demo, new TimeSpan( vec2d(SCENE_80_START, SCENE_85_START)), MAIN_EFFECT);
					m_demo.FXLayer1.add(scene80);
					
				// Scene 85 (le tore qui explose)
					m_demo.FXLayer1.add(new Graindo1(m_demo, new TimeSpan( vec2d(SCENE_85_START, SCENE_90_START)), MAIN_EFFECT, scene80));
					
				// transition to pandazoom
					m_demo.FXLayer1.add(new Fade(m_demo, new TimeSpan( vec2d(SCENE_PANDAZOOM_START - 0.1, SCENE_PANDAZOOM_START) ) , LAYER_EFFECT, 
				    				                            [vec4f(0,0,0,0), vec4f(0,0,0,1)] ));	
		
				}	
				
				
				// Pandazoom
				{
					m_demo.FXLayer1.add(new Pandazoom(m_demo, new TimeSpan( vec2d(SCENE_PANDAZOOM_START, SCENE_100_START + 4)), BOTTOM_EFFECT ));
				}
				
				
				// logo final
				{
					m_demo.FXLayer1.add(new Scene90(m_demo, new TimeSpan( vec2d(SCENE_110_START, ENDING)), LAYER_EFFECT ));
					
					m_demo.FXLayer2.add(new TroubleFX(m_demo, new TimeSpan( vec2d(SCENE_110_START /*SCENE_120_START*/, ENDING)) , LAYER_EFFECT));
				}			
					
				
		
			}
			
			timelineFunction(m_demo);
			
			m_demo.loadAll();
			
			GL.disable(GL_DEPTH_TEST, GL_LINE_SMOOTH, GL_POLYGON_SMOOTH, GL_POINT_SMOOTH, GL_BLEND, 
			          GL_FOG, GL_LIGHTING, GL_NORMALIZE, GL_STENCIL_TEST, GL_CULL_FACE);
			
			glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
			GL.disable(GL_AUTO_NORMAL, GL_DITHER, GL_FOG, GL_LIGHTING, GL_NORMALIZE);
			
			glHint(GL_TEXTURE_COMPRESSION_HINT, GL_FASTEST);
			glHint(GL_GENERATE_MIPMAP_HINT, GL_FASTEST);
			GL.disable(GL_POLYGON_SMOOTH, GL_LINE_SMOOTH, GL_POINT_SMOOTH);
		}
		
		~this()
		{
			m_demo.stopMusicPlayback;	
		}
		
		float a = 0;
		
		override void onRun()
		{
			m_demo.onRun(); 	
		}
		
	    override void onRender(double elapsedTime)
	    {
		    m_demo.draw();
			
			swapBuffers();
		}
	    
	    override void onMove(double elapsedTime, double dt)
	    {
		    // time travel : only active in debug version 
		    debug
		    {   
			    double speed = 1.0;
			    if (SDL.instance.keyboard.isPressed(SDLK_LCTRL)) speed *= 10.0;
			    if (SDL.instance.keyboard.isPressed(SDLK_LSHIFT)) speed *= 0.1;
			    
			    if (SDL.instance.keyboard.isPressed(SDLK_RIGHT)) m_demo.timeTravel(speed * 10 * dt);
			    if (SDL.instance.keyboard.isPressed(SDLK_LEFT)) m_demo.timeTravel(-speed * 10 * dt);
		    }
		    
		    
			m_demo.move(elapsedTime, dt);
			if (m_demo.finished) terminate;
		}
	    
		override void onKeyUp(int key, int mod, wchar ch)
	    {
			if (key == SDLK_ESCAPE) terminate();    
	    }
	    
	    override void onFrameRateChanged(float frameRate)
	    {
		    debug
		    {
			    title = format("az-02 FPS=%s", frameRate);
		    }
		}
	    
	    override void onKeyDown(int key, int mod, wchar ch)
	    { 
		    debug
		    {
		    	if (SDL.instance.keyboard.isPressed(SDLK_SPACE)) m_demo.toogleVisualRatioCue();
		    }
		}	    
		
	    override void onMouseMove(int x, int y, int dx, int dy)  { }	    
	    override void onMouseDown(int button)	    { }	    
	    override void onMouseUp(int button)	    { }	    
	    override void onReshape(int width, int height)  {  }	    
    }	
}



