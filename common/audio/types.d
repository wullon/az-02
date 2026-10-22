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
module audio.types;

alias int AudioCycle;

enum AudioDataType 
{ 
	FLOAT = 1, // 1 float value
	INTEGER = 2, // 1 int value
	ANALOG = 4, // 32 samples
	STEREO_ANALOG = 8, // 2x32 samples
	MESSAGE = 16, // 1 object Message of any type
	UNASSIGNED = 32,  // nothing, used to state that an InputPin could remain unassigned
	ALL = 63,
}; 	

alias AudioDataType AudioDataTypeSet; // AudioDataTypeSet is currently a bitfield

alias uint ModuleID;


char[] AudioDataType_to_string(AudioDataType u)
{
	switch(u)
	{
		case AudioDataType.FLOAT: return "float";
		case AudioDataType.INTEGER: return "integer";
		case AudioDataType.ANALOG: return "audio";
		case AudioDataType.STEREO_ANALOG: return "stereo";
		case AudioDataType.MESSAGE: return "message";
		case AudioDataType.UNASSIGNED: return "void";
		default : return "error";	
	}
}

char[] AudioDataTypeSet_to_string(AudioDataTypeSet s)
{
	char [] res = "";
	bool first_one = true;
	AudioDataType[] possible = 
		[ AudioDataType.FLOAT, AudioDataType.INTEGER, AudioDataType.ANALOG, 
		  AudioDataType.STEREO_ANALOG, AudioDataType.MESSAGE, AudioDataType.UNASSIGNED];
	for (int i = 0; i < possible.length; i++)
	{
		if (possible[i] & s)
		{
			if (!first_one) 
			{
				res = res ~ " | ";
			} else first_one = false;
			res = res ~ AudioDataType_to_string(possible[i]);
			
		}
	}
	return res;
}

enum AudioParameterType
{ 
	INTEGER = 0,
	STRING = 1,
	FLOAT = 2,
};

char[] AudioParameterType_to_string(AudioParameterType s)
{
	switch(s)
	{
		case AudioParameterType.INTEGER: 
			return "INTEGER";
			
		case AudioParameterType.FLOAT: 
			return "FLOAT";
			
		case AudioParameterType.STRING:
		default: 
			return "STRING";
		
	}
}

//bool checkparameters(char[][], AudioParametersSet