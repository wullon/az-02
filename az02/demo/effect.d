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
module demo.effect;

import util.math;
import util.all;
import util.geometry.all;
import gl.all;
import sdl.all;
import demo.demo;
import demo.timespan;
import demo.trackinfo;
import demo.bitmapfont;

/**
 * An Effect is a flexible demo effect.
 *
 * At each frame, a set of effects are "drawed" sequentially, in the full viewport, to the main Texture
 * the onDraw virtual function can do anything relative to openGL and such.
 *
 * Context informations are passed through the base class.
 */
class Effect
{
	private
	{
		Demo m_demo; 
		TimeSpan m_timeSpan; // represents slices of time
		
		bool m_loaded = false,  // true if loaded
		     m_active = false;  // true if currently active
		int m_priority, m_slice; // low priority effects are drawn before
		double m_localTime, // number of beat since the beginning of this effect slice
		       m_progression, // progression of the effect in this time slice (between 0 and 1)
		       m_globalTime, // number of beat since the beginning of the demo
		       m_endTime,   // length of the effect 
		       m_dt; // last time advance in beats
		char[] m_name; // name of the effect (debug purpose)
		
		float m_ratio, m_invRatio;
				
	}
	
	protected
	{
		alias Demo.CommonTexture CommonTexture;
		
		Texture2D commonTexture(CommonTexture which)
		{
			return m_demo.commonTexture(which);
		}
		
		Texture3D commonTexture3D(CommonTexture which)
		{
			return m_demo.commonTexture3D(which);
		}
		
	}
	
	public
	{
		this(Demo demo, char[] name, TimeSpan timeSpan, int priority)
		{
			m_demo = demo;
			m_name = name;
			m_timeSpan = timeSpan;
			m_priority = priority;
			m_timeSpan = timeSpan;			
			m_ratio = demo.ratio;
			m_invRatio = cast(float)(1.0 / demo.ratio);
			m_slice = -1;
			m_dt = 0.0;
		}
		
		//final Demo demo() {	return m_demo; }
		
		final char[] name() 	{ return m_name; }
		
		final bool isActive()	{ return m_active; }
		
		final float ratio()		{ return m_ratio; }
		final float invRatio()		{ return m_invRatio; }
		
		
		final int priority()	{ return m_priority; }
		
		final int priority(int p)	{ return (m_priority = p); }
		
		final double progression()	{ return m_progression;	}
		final double progressionf()	{ return cast(float)m_progression;	}
		
		final double localTime()	{ return m_localTime; }		
		alias localTime lt; // short-cut
		
		final double globalTime()	{ return m_globalTime; }
		alias globalTime gt; // short-cut
		
		final double endTime()	{ return m_endTime; }		
		final double endBeat()	{ return m_endTime * m_demo.TIME_PER_BEAT_INV; }		
		
		final double localBeat()	{ return m_localTime * m_demo.TIME_PER_BEAT_INV; }		
		alias localBeat lb; // short-cut
		
		final double time2bpm(double time) { return time * m_demo.TIME_PER_BEAT_INV; }
		final double bpm2time(double bpm) { return bpm * m_demo.TIME_PER_BEAT; }
		
		final double lastLocalBeat()	{ return (m_localTime - m_dt) * m_demo.TIME_PER_BEAT_INV; }		
		
		
		final double globalBeat()	{ return m_globalTime * m_demo.TIME_PER_BEAT_INV; }
		alias globalBeat gb; // short-cut
		
		final double lastGlobalBeat()	{ return (m_globalTime - m_dt) * m_demo.TIME_PER_BEAT_INV; }		
		
		final FBO mainFBO()			{ return m_demo.mainFBO; }
		
		final FBO interFBO()		{ return m_demo.interFBO; }
		
		final Texture2D mainTexture() 			{ return m_demo.mainTexture; }
		final Texture2D currentInterTexture()	{ return m_demo.currentInterTexture; }		
		final Texture2D lastInterTexture()		{ return m_demo.lastInterTexture; }
		final Shader putShader()                { return m_demo.putShader; }
		
		final BitmapFont font()                       { return m_demo.font; } 
		final BitmapFont greetzFont()                  { return m_demo.greetzFont; } 
		
		debug 
		{
			void display(float x)
			{
				string s = format("%s", x);
				m_demo.display(-0.5f, 0.9, s);
			}
			
			void display(float x, float y)
			{
				string s = format("%s %s", x, y);
				m_demo.display(-0.5f, 0.9, s);
			}
			
			void display(float x, float y, float z)
			{
				string s = format("%s %s %s", x, y, z);
				m_demo.display(-0.5f, 0.9, s);
			}
			
			void display(float x, float y, float z, float a)
			{
				string s = format("%s %s %s %s", x, y, z, a);
				m_demo.display(-0.5f, 0.9, s);
			}
		}
		
		final float blurAmount()       
		{ 
			return m_demo.postProcess.blurAmount;
		}
		
		final float blurType()       
		{ 
			return m_demo.postProcess.blurType;
		}
		
		final float blurAmount(float amt)       
		{ 
			m_demo.postProcess.blurAmount = amt;
			return amt;
		}
		
		final float blurType(float type) // should be between 0 and 1
		{
			m_demo.postProcess.blurType = type;
			return type;
		}
		
		final recti viewport()		{ return m_demo.viewport; }
		
		// get track volume
		final float volume(Track t) 				{ return m_demo.volume(t, m_globalTime); }		
		final float volume(Track t, double time) 	{ return m_demo.volume(t, time + m_globalTime); } // relative to now
		// get track volume (normalized)
		final float volumeN(Track t) 				{ return m_demo.volumeNormalized(t, m_globalTime); }		
		final float volumeN(Track t, double time) 	{ return m_demo.volumeNormalized(t, time + m_globalTime); } // relative to now
		
		
		
		final float bpm()			{ return m_demo.BPM; }		
		
		final double dt() 				{ return m_dt; }
		
		final int slice()					{ return m_slice; } // which slice of time it is
		
		final int width()					{ return m_demo.width; }
		final int height()				{ return m_demo.height; }
		
		
		// return an axis of the first joystick (for dev purpose)
		// will work even when there are no joystick
		// (int this case all axis are 0
		final float axis(int i)
		{
			debug
			{
				int nJoy = SDL.instance.numJoysticks();
				if (nJoy <= 0) return 0.f;
				
				auto j = SDL.instance.joystick(0);
				
				if (j is null) return 0.f;
				
				if ((i < 0) || (i >= j.getNumAxis))
				{
					return 0.f;	
				}
				
				return j.axis(i);
			}
			else
			{
				return 0.f;					
			}
		}
		
		
		
		final void load()
		{
			if (!m_loaded)
			{
				trace(format("load effect %s", name));
				m_loaded = true;
				onLoad();
			}	
		}
		
		/**
		 * update the state of the effect considering
		 * also compute if the effect is active
		 */
		final void updateTiming(double globalTime, double dt)
		{
			
			m_globalTime = globalTime;
			m_dt = dt;
			int timeSliceIndex = m_timeSpan.search(globalTime);
			m_slice = timeSliceIndex;
			m_active = (timeSliceIndex >= 0);
			
			if( m_active )
			{
				vec2d currentInterval = m_timeSpan.interval(timeSliceIndex);
				m_localTime = globalTime - currentInterval[0];
				m_progression = m_localTime / (currentInterval[1] - currentInterval[0]);
				m_endTime = currentInterval[1] - currentInterval[0];
				
				assert(m_progression >= 0.0);
				assert(m_progression <= 1.0);
					
			}		
		}
		
		final void draw()
		{
			debug(3) writefln("draw : %s", name);			
			onDraw();			
		}
		
		final void move()
		{
			debug(3) writefln("move : %s", name);
			load(); // ensure the effect is loaded (move is called before draw)
			onMove();			
		}
		
		abstract void onLoad(); // load resources
		abstract void onDraw(); // draw effect on a texture
		abstract void onMove(); // move effect
		
		
		int opCmp(Object o) // for sorting effects by priority
   		{
			auto e = cast(Effect) o;
        	if (!e) 
        	{
	        	return -1;
        	} else 
        	{
	        	return m_priority - e.m_priority;
        	}
   		}
   		
   		static vec3f rgb(uint color)
   		{
	   		float r = ((color >> 16) & 0xff) / 255.f;
	   		float g = ((color >> 8) & 0xff) / 255.f;
	   		float b = ((color >> 0) & 0xff) / 255.f;
	   		return vec3f(r,g,b);
   		}
   		
   		static vec4f rgba(uint color)
   		{
	   		float r = ((color >> 24) & 0xff) / 255.f;
	   		float g = ((color >> 16) & 0xff) / 255.f;
	   		float b = ((color >> 8) & 0xff) / 255.f;
	   		float a = ((color ) & 0xff) / 255.f;
	   		return vec4f(r,g,b,a);
   		}
   		
   		static double minsec(double min, double sec)
   		{
	   		return min * 60 + sec;	
   		}
   		
   		final vec3f hsl(float h, float s, float l)
   		{
	   		const float ONE_THIRD = 1.f / 3.f;
	   		const float TWO_THIRD = 2.f / 3.f;
	   		float hue_to_rgb(float m1, float m2, float h)
	   		{
		   		h = frac(h);
		   		if (h * 6.f < 1.f) return m1 + (m2 - m1) * h * 6.f;	
		   		else if (h < 0.5f) return m2;
		   		else if (h < TWO_THIRD) return m1 + (m2 - m1) * (TWO_THIRD - h) * 6.f;
		   		else return m1;
	   		}
	   		
	   		float m2 = (l < 0.5f) ? (l * s + 1.f) : (l + s - l * s);
	   		float m1 = l * 2.f - m2;
	   		return vec3f(hue_to_rgb(m1,m2,h + ONE_THIRD), 
	   		             hue_to_rgb(m1,m2,h ),
	   		             hue_to_rgb(m1,m2,h - ONE_THIRD));
   		}
   		
   		final vec3f hsl(vec3f arg)
   		{
	   		return hsl(arg.x, arg.y, arg.z);
   		}
   		
		final vec4f hsla(float h, float s, float l, float a)
		{
			return vec4f(hsl(h, s, l), a);
		}
		
		final vec4f hsla(vec4f arg)
		{
			return hsla(arg.x, arg.y, arg.z, arg.w);
		}
		
		final float hit(float start, float stop, float t, float power)
		{
			if (t < start) return 0.f;	
			if (t > stop) return 0.f;
			float p = 1.f  - (t - start) / (stop - start);
			return pow(p, power);
		}
		
		final vec3f desaturate(vec3f color, float a)
		{
			vec3f grey = (color.x + color.y + color.z) * 0.3333f;
			return lerp(color, grey, a);
		}
	}
}

