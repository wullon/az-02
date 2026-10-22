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
module audio.modules.variable;	

import audio.audiomodule;
import audio.allwhatmodulesneed;
	

final class Variable : AudioModule
{	
	//RegisterModule!("Variable", "Var");
	
	private
	{
		float m_value;
		Spinlock m_spinlock;
		bool m_hasChanged;
	}	
	protected
	{			
		override void doProcess()
		{
			if (m_hasChanged)
			{
				m_spinlock.lock();
				float u = m_value;
				m_spinlock.unlock();
				(cast(FloatData)(output(0).data)).value = u;			
				m_hasChanged = false;
			}
		}
		
		void doSetParameter(int index, AudioParameter param)
		{
			switch(index)
			{
				case 0:
				default:
				
					value = param.asFloat();
			}
		}
		
		AudioParameter doGetParameter(int index)
		{
			switch(index)
			{
				case 0:
				default:
					return AudioParameter(value);
			}
		}	
	}
	
	public
	{
		this()
		{
			addOutput("VALUE", AudioDataType.FLOAT);			
			m_spinlock = Spinlock();
		}
		
		~this()
		{
			m_spinlock.unlock();	
		}
		
		override char[] label()
		{
			return format("%3.3g", m_value);
		}
		
		float value()
		{
			return m_value;
		}	
		
		float value(float newValue)
		{
			m_spinlock.lock();
			scope(exit) m_spinlock.unlock();			
			m_value = newValue;
			m_hasChanged = true;
						
			return newValue;
		}	
		
		override AudioParameterInfo[] getParametersInfo()
		{
			static const AudioParameterInfo[] params = 
			[
				{ name : "VALUE", 
				  type : AudioParameterType.FLOAT, 
				  defaultValue : { m_type : AudioParameterType.FLOAT, m_dataFloat : 0 } }
			];
			return params; 	
		}
	}	
}
