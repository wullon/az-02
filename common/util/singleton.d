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
module util.singleton;

/** 
	D makes it possible.
	Just use:
		class MyClass
		{
			mixin Singleton!(MyClass);
			
			void doSomeTthing() 
			{ 
				// do something
			};
		}		
		
		MyClass.instance.doSomething(); // create and use a unique instance
		
	to make a singleton out of a normal class;
	
	
	Singleton : simple-singleton
	StartupSingleton : created at startup
	ThreadSafeSingleton : thread-safe singleton, prevent two concurrent creation
	
*/

template Singleton() // object is created on demand
{
	public static final typeof(this) instance ()
	{
		if (_instance is null )
		{
			_instance = new typeof(this)();
		}
		return _instance;
	}
	
	public static final void release()
	{
		delete _instance;	
	}
	
	private static typeof(this) _instance = null;
}

template ThreadSafeSingleton() // object creation is synchronized
{
	public static final typeof(this) instance ()
	{
		if (_instance is null )
		{
			synchronized
			{
				if (_instance is null )
				{
					_instance = new typeof(this)();
				}
			}
		}
		return _instance;
	}
	
	public static final void release()
	{
		delete _instance;	
	}
	
	private static T _instance = null;
}

template StartupSingleton() // object is created at startup
{
	static this()
	{
		_instance = new typeof(this)();
	}	
		
	public static final typeof(this) instance ()
	{
		return _instance;
	}
	
	public static final void release()
	{
		delete _instance;	
	}
	
	private static typeof(this) _instance = null;
}
