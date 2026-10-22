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
module audio.errors;

import audio.pin, audio.types;
import std.string, std.stdio;


class AudioError : object.Exception
{
	this(char[] msg)
	{
		super(msg);	
	}	
}

class NoSuchPinError : AudioError
{	
	this(char[] moduleName, char[] pinName, )
	{
		super(format("No pin named %s in %s", pinName, moduleName));	
	}
}

class NoSuchParameterError : AudioError
{	
	this(char[] moduleName, char[] paramName, )
	{
		super(format("No parameter named %s in %s", paramName, moduleName));	
	}
}

class BadArgumentForParameter : AudioError
{	
	this(char[] moduleName, char[] paramName, AudioParameterType requiredType, AudioParameterType givenType)
	{
		auto sRequiredType = AudioParameterType_to_string(requiredType);
		auto sGivenType = AudioParameterType_to_string(givenType);
		
		super(format("Parameter %s in %s is of type %s, not %s", 
		             paramName, 
		             moduleName, 
		             sRequiredType, 
		             sGivenType));	
	}
}

class TooMuchArguments : AudioError
{	
	this(char[] moduleName, int expectedCount, int givenCount)
	{
		super(format("Module %s accepts up to %s arguments, not %s", 
		             moduleName, 
		             expectedCount, 
		             givenCount));	
	}
}

class BadInputTypeError : AudioError
{	
	this(char[] moduleName, char[] pinName, AudioDataTypeSet expectedType)
	{
		super(format("Bad input type for %s::%s : %s expected", moduleName, pinName, 
		             AudioDataTypeSet_to_string(expectedType)));
	}
}

class UnconnectedPinError : AudioError
{	
	this(char[] moduleName, char[] pinName, AudioDataTypeSet expectedType)
	{
		super(format("%s::%s should be connected to %s", moduleName, pinName, expectedType));	
	}
}

class LinkIsImpossible : AudioError
{	
	this(Pin pin, Pin pinLink)
	{
		super(format("%s::%s cannot be linked to %s::%s", pin.owner.className, pin.name, 
		                                                  pinLink.owner.className,  pinLink.name));	
	}
}

class CouldNotOpenSample : AudioError
{	
	this(char[] filename)
	{
		super(format("Couldn't open %s\n", filename));
	}
}

class CouldNotConvertData : AudioError
{	
	this(char[] msg)
	{
		super(msg);
	}
}

class PortAudioError : AudioError
{	
	this(char[] msg)
	{
		super(msg);
	}
}



