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
module audio.message;


final struct Message // audio buffer
{
	public
	{
		enum Type 
		{ 
			NOTE_ON, // tell a synth to produce a note
			NOTE_OFF, // tell a synth to stop a note
			TRIG_ON, // tell a voice to produce a note
			TRIG_OFF, // tell a voice to stop producing a note
			ENV_START, // tell the enveloppe to trig
			ENV_STOP, // tell the enveloppe to release
			SYNC, // tell an Oscillator to hard-sync
			BANG, // bang signal
		};		
	}
	
	protected
	{
		Type m_type;
		align(4) union
		{
			struct
			{
				float m_paramf1;
				float m_paramf2;
			}
			
			struct
			{
				int m_parami1;
				int m_parami2;
			}
		}
		
		static Message opCall(Type type, float paramf1, float paramf2)
		{
			Message m;
			m.m_type = type;
			m.m_paramf1 = paramf1;
			m.m_paramf2 = paramf2;			
			return m;
		}
		
		static Message opCall(Type type, int parami1, int parami2)
		{
			Message m;
			m.m_type = type;
			m.m_parami1 = parami1;
			m.m_parami2 = parami2;
			return m;
		}
		
		static Message opCall(Type type) { return Message(type, 0, 0); }
		
	}
	
	
	public
	{	
		final Type type()
		{
			return m_type;	
		}
		
		static Message createBang()			{	return Message(Type.BANG);		}
		static Message createSync(int offset) {	return Message(Type.SYNC, offset, 0);	}
		
		static Message createEnvStart()		{	return Message(Type.ENV_START);	}
		static Message createEnvStop()		{	return Message(Type.ENV_STOP);	}
			
		static Message createNoteOn(int note, int velocity) 	{	return Message(Type.NOTE_ON, note, velocity);	}
		static Message createNoteOff(int note, int velocity)	{	return Message(Type.NOTE_OFF, note, velocity);	}
		
		static Message createTrigOn(float baseFrequency, float intensity) {		return Message(Type.TRIG_ON, baseFrequency, intensity); }
		static Message createTrigOff() {	return Message(Type.TRIG_OFF);	}
		
		// if m_type == Type.TRIG_ON
		float baseFrequency() { return m_paramf1; }
		float intensity() { return m_paramf2; }
		
		// if m_type == Type.NOTE_ON
		int note() { return m_parami1; }
		int velocity() { return m_parami2; }
		
		// if m_type == Type.SYNC
		int offset() { return m_parami1; }
	}	
}


