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
module audio.audiomodule;

import audio.types, audio.parameters, audio.audiodata, 
       audio.errors, audio.parametersinfo;
import audio.pin : Pin;       
import audio.inputpin;
import audio.outputpin;
import std.string, std.stdio;
import util.logger, util.common;
import util.tokenstream : TokenStream;
import util.token : Token;
import util.spinlock : Spinlock;


abstract class AudioModule
{
	private
	{
		OutputPin[] m_outputs;
		InputPin[] m_inputs;
		ModuleID m_id;
		Object m_user; // "user" pointer
		Spinlock m_spinlock; // doProcess Futex
		
		bool m_NaNOccured;
		bool m_denormalOccured;
		float m_cyclesStat; 		
	}
	
	protected
	{
		this()
		{	
			m_outputs.length = 0;
			m_inputs.length = 0;
			m_cyclesStat = 0;
			m_user = null;
			m_NaNOccured = false;
			m_denormalOccured = false;
			m_spinlock = Spinlock();
			
			auto info = getParametersInfo();
			for (int i = 0; i < info.length; ++i)
			{
				setParameter(info[i].name, info[i].defaultValue);
			}
		}
		
		
		~this()
		{
			unlock();
		}
		
		void deserialize(TokenStream stream)
		{ 
			// default : do nothing			
		}	
		
		abstract void doProcess();
		
		// get informations about this module parameters
		AudioParameterInfo[] getParametersInfo()
		{
			static const AudioParameterInfo[] defaultParams = [];
			return defaultParams; 	
		}
		
		// change the value of a parameter
		// execute the corresponding action
		void doSetParameter(int index, AudioParameter param)
		{
			// default : do nothing			
		}
		
		// get the value of a parameter
		AudioParameter doGetParameter(int index)
		{
			return AudioParameter(0);
		}
				
		final void addInput(char[] name, AudioDataTypeSet expectedType)
		{
		//	lock();
			m_inputs.length = m_inputs.length + 1;
			m_inputs[m_inputs.length - 1] = new InputPin(this, name, expectedType);
		//	unlock();
		}
		
		final void removeInput(char[] name)
		{
		//	lock();
			int index = findPinIndex(m_inputs, name);
			for (int i = index; i < m_inputs.length - 1; ++i)
			{
				m_inputs[i] = m_inputs[i+1];	
			}
			m_inputs.length = m_inputs.length - 1;			
		//	unlock();
		}
		
		final void clearAllInputs()
		{
		//	lock();
			m_inputs.length = 0;			
		//	unlock();
		}
		
		final void addOutput(char[] name, AudioDataType type)
		{
		//	lock();
			m_outputs.length = m_outputs.length + 1;
			m_outputs[m_outputs.length - 1] = new OutputPin(this, name, type);			
		//	unlock();
		}		
		
		final void removeOutput(char[] name)
		{
			lock();
			int index = findPinIndex(m_outputs, name);
			for (int i = index; i < m_outputs.length - 1; ++i)
			{
				m_outputs[i] = m_outputs[i+1];	
			}
			m_outputs.length = m_outputs.length - 1;			
			unlock();
		}
		
		// find the index of a pin with given name
		final int findPinIndex(Pin[] arrayOfPins, char[] pinName)
		{
			for(int i = 0; i < arrayOfPins.length; i++)
			{
				if (arrayOfPins[i].name == pinName) 
				{
					return i;	
				}
			}	
			throw new NoSuchPinError(className, pinName);
		}
		
		// find the index of a parameter with given name
		final int findParameterIndex(char[] paramName)
		{
			auto info = getParametersInfo();
			for(int i = 0; i < info.length; i++)
			{
				if (info[i].name == paramName) 
				{
					return i;	
				}
			}	
			throw new NoSuchParameterError(className, paramName);
		}
		
		final Pin findPin(Pin[] arrayOfPins, char[] pinName)
		{
			return arrayOfPins[findPinIndex(arrayOfPins, pinName)];
		}		
	}		
	
	public
	{
		final char[] className() // class-name as an audiomodule
		{
			auto classname = toString();
			int i = rfind(classname, '.'); 
			
			if (i < 0)
			{
				return classname;
			} else
			{
				return classname[i+1 .. classname.length];
			}
		}
		
		char[] label() // interesting information to be displayed
		{
			return className;
		}
		
		final int parametersCount()
		{
			return getParametersInfo().length;
		}	
		
		final void setParameter(char[] name, AudioParameter p)
		{
			
			int index = findParameterIndex(name);
			auto info = getParametersInfo()[index];
			
			if (info.type != p.type) 
			{
				// integer -> float promotion
				if ((p.type == AudioParameterType.INTEGER) && (info.type == AudioParameterType.FLOAT))
				{
					p = AudioParameter(cast(float)(p.asInt()));
				}
				else throw new BadArgumentForParameter(className, name, info.type, p.type);
			}
			
			doSetParameter(index, p);								
		}	
		
		final AudioParameter getParameter(char[] name)
		{
			auto info = getParametersInfo();
			int index = findParameterIndex(name);
			return doGetParameter(index);
		}		
		
		final void setParameters(AudioParameter[] params)
		{
			auto info = getParametersInfo();
			
			if (params.length > info.length)
			{
				throw new TooMuchArguments(className, info.length, params.length);
			}
			
			for (int i = 0; i < params.length; ++i)
			{
				setParameter(info[i].name, params[i]);
			}
		}
		
		final InputPin input(char[] name)
		{
			return cast(InputPin) findPin(m_inputs, name);
		}
		
		final OutputPin output(char[] name)
		{
			return cast(OutputPin) findPin(m_outputs, name);
		}
		
		final InputPin input(int i)
		{
			return m_inputs[i];
		}
		
		final OutputPin output(int i = 0)
		{
			return m_outputs[i];
		}
		
		final void updateTo(AudioCycle targetCycle )
		{
			for (int i = 0; i < m_outputs.length; i++)
			{
				m_outputs[i].setLastCycle(targetCycle);
			}
			
//			debug(1) trace(format(">%s.updateTo(%d)", this, targetCycle));
			if (isValid())
			{
				for (int i = 0; i < m_inputs.length; i++)
				{
					m_inputs[i].updateTo(targetCycle);
				}
				final long startCycles = rdtsc();
				{
					lock();
					scope(exit) unlock();
					doProcess();
				}
				
				{
					final long stopCycles = rdtsc();
					final long cycles = stopCycles - startCycles;			
					m_cyclesStat = m_cyclesStat * 0.99 + cycles * 0.01;
				}
				
				for (int i = 0; i < m_outputs.length; i++)
				{
					if (m_outputs[i].data.hasNaNs) m_NaNOccured = true;
					if (m_outputs[i].data.hasDenormals) m_denormalOccured = true;
					m_outputs[i].setLastCycle(targetCycle);
				}				
				
			} else
			{
				// if not valid, set data with default values
				for (int i = 0; i < m_outputs.length; i++)
				{
					m_outputs[i].clearData();
				}		
			}			
		//	trace(format("audio: %s::doProcess::fin, took %s cycles", name, stopCycles - startCycles));	
		
		//	trace(format("<%s.updateTo(%d)", this, targetCycle));	
		}
		
		final InputPin[] inputs()
		{
			return m_inputs;
		}
		
		final OutputPin[] outputs()
		{
			return m_outputs;
		}
				
		final ModuleID id(ModuleID newId)
		{
			m_id = newId;
			return newId;
		}
		
		final ModuleID id()
		{
			return m_id;	
		}
		
		final float cycles()
		{
			return m_cyclesStat;	
		}
		
		// a module is valid when it can render something (ie : doProcess)
		// all its input need to be connected as specified to be valid
		final bool isValid()
		{
			for (int i = 0; i < m_inputs.length; ++i)
			{
				if (! m_inputs[i].isValid()) return false;
			}
			return true;
		}
		
		final Object user() 
		{ 
			return m_user; 
		}
		
		final Object user(Object u) 
		{
			return m_user = u; 
		}
		
		final void lock()
		{
			m_spinlock.lock();	
		}
		
		final void unlock()
		{
			m_spinlock.unlock();	
		}
		
		// disconnect all inputs and outputs to allow deletion
		final void disconnect()
		{
			for (int i = 0; i < m_inputs.length; ++i)
			{
				m_inputs[i].disconnect();					
			}
			
			for (int i = 0; i < m_outputs.length; ++i)
			{
				m_outputs[i].disconnect();					
			}
		}
		
		final char[] serialize()
		{
			char[] res = className();
			
			auto info = getParametersInfo();			
			
			for (int i = 0; i < info.length; ++i)
			{
				res ~= " ";	
				AudioParameter p = doGetParameter(i);
				res ~= p.toString();
			}
			return res;
		}
		
		final bool NaNOccured()
		{
			return m_NaNOccured;
		}
		
		final bool denormalOccured()
		{
			return m_denormalOccured;
		}
		
		final bool NaNOccured(bool b)
		{
			return m_NaNOccured = b;
		}
		
		final bool denormalOccured(bool b)
		{
			return m_denormalOccured = b;
		}
	}	
}