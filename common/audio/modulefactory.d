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
module audio.modulefactory;

import util.all;
import audio.audiomodule;
import audio.modules.all;
import std.string;

final class ModuleFactory // audio buffer
{
	mixin Singleton;
	
	public
	{
		AudioModule create(char[] cmd)
		{
			writefln("%s", cmd);
			char[] fullName = format("audio.modules.%s.%s", tolower(cmd), cmd);
			
			auto info = ClassInfo.find(fullName);
			assert(info !is null);
			//if (info is null) return null;
			return cast(AudioModule) info.create();
			
	/*		
			switch(cmd)
			{
				case "Adder" : return new Adder();
				case "AzertyKeyboard" : return new AzertyKeyboard();
				case "Bang" : return new Bang();
				case "BP12" : return new BP12();				
				case "Clock" : return new Clock();
				case "CPULoad" : return new CPULoad();
				case "Doubler" : return new Doubler();
				case "Envelope" : return new Envelope();				
				case "Hold" : return new Hold();				
				case "HP12" : return new HP12();				
				case "HQEnvelope" : return new HQEnvelope();				
				case "LFO" : return new LFO();
				case "LP12" : return new LP12();	
				case "Merger" : return new Merger();
				case "Mixer" : return new Mixer();
				case "ModeOsc" : return new ModeOsc();
				case "MSDec" : return new MSDec();
				case "MSEnc" : return new MSEnc();
				case "Multiplier" : return new Multiplier();
				case "Notch" : return new Notch();
				case "PinkNoise" : return new PinkNoise();
				case "PsychoPanner" : return new PsychoPanner();
				case "Saw" : return new Saw();				
				case "Sine" : return new Sine();
				case "SimplePanner" : return new SimplePanner();	
				case "Square" : return new Square();
				case "Smoother" : return new Smoother();				
				case "StereoMixer" : return new StereoMixer();
				case "StereoRotater" : return new StereoRotater();
				case "TestSynth" : return new TestSynth();
				case "Variable" : return new Variable();
				case "WhiteNoise" : return new WhiteNoise();
				case "Xor" : return new Xor();
				case "Split" : return new Splitter();
				default: 					
					return null;
			}*/
		}
	}
}