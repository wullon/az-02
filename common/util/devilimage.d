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
module util.devilimage;

import util.common;
import util.singleton;

import derelict.devil.il;
import derelict.devil.ilu;
import derelict.devil.iltypes;

import std.string;

class DevilError : object.Exception
{	
	this(char[] s)
	{
		super(s);	
	}	
}




private class DevilState 
{
	mixin Singleton;
	private
	{
		this()
		{
			DerelictIL.load();
    		DerelictILU.load();            
			ilInit();
			iluInit();   
		}	
	}	
	
}
	         

final class DevilImage 
{
	
	private
	{		
		ILuint m_handle;		
		static bool m_devil_loaded = false;
	}
	
	public
	{
		
		this()
		{
			DevilState.instance(); // load devIL if necessary
			if (!m_devil_loaded)
			{
				DerelictIL.load();
            	DerelictILU.load();
		    	ilInit();
		    	iluInit();	
		    	m_devil_loaded = true;
			}
			ilGenImages(1, &m_handle);			
					
		}
		
		this(char[] filename)
		{
			this();
			loadImage(filename);
		}
		
		~this()
		{
			ilDeleteImages(1, &m_handle);					
		}
		
		bool loadImage(char[] filename)
		{
			ilBindImage(m_handle); 
			
			// charge l'image
			ILboolean res = ilLoadImage(toCString(filename));			
			
			bool bres = false;
			
			switch (res)
			{
				case IL_COULD_NOT_OPEN_FILE:
					throw new DevilError(format("devIL : Impossible d'ouvrir %s", filename));
					
				case IL_ILLEGAL_OPERATION:
					throw new DevilError("devIL : Operation non reconnue");
				
				case IL_INVALID_EXTENSION:
					throw new DevilError(format("devIL : format du fichier %s non reconnu", filename));					
				
				case IL_INVALID_PARAM:
					throw new DevilError("Parametre invalide");
					
				default:
					bres = true;
					ilConvertImage(IL_RGBA, IL_UNSIGNED_BYTE);
					break;
			}
							
			return bres;
		}
		
		void flipVertical()
		{
			ilBindImage(m_handle);
			iluFlipImage();
		}
		
		void saveImage(char[] filename)
		{
			ilBindImage(m_handle); 
			flipVertical();
			ilEnable(IL_FILE_OVERWRITE);			
			ilSaveImage(toCString(filename));
			flipVertical();
		}
		

		ubyte* data()
		{
			ilBindImage(m_handle);
			return cast(ubyte*) ilGetData();
		}	
		
		int height()
		{
			ilBindImage(m_handle); 
			return ilGetInteger(IL_IMAGE_HEIGHT);			
		}		
		
		int width()
		{
			ilBindImage(m_handle); 
			return ilGetInteger(IL_IMAGE_WIDTH);			
		}	
		
		void setData(int width, int height, ubyte[] data)
		{
			ilBindImage(m_handle); 
			ilTexImage( width, height, 1, 4, IL_RGBA, IL_UNSIGNED_BYTE, cast(ILvoid *) data.ptr);
		}
	}
}
