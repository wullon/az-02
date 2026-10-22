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
module util.collection;

import util.iterator;
import std.stdio;

interface Collection(T) {

	public {
		
		bool add(T o);
		bool addAll(Collection!(T) c);
		bool addArray(T[] a);
		void clear();
		bool contains(T o);
		bool containsAll(Collection!(T) c);
		bool isEmpty();
		Iterator!(T) iterator();
		bool remove(T o);
		bool removeAll(Collection!(T) c);
		int size();
		T[] toArray();			
		int opApply(int delegate(ref T) dg);		
		
	}
	
}

class AbtractCollection(T) : Collection!(T) {
	
	public {
		
		abstract {
			
			void clear();
			bool add(T o);
			bool remove(T o);
			Iterator!(T) iterator();
			int size();
			
		}
		
		
		bool addAll(Collection!(T) c) {
			
			Iterator!(T) i = iterator();
			bool r = true;
			while (i.hasNext()) 
			{
				r &= add(i.next());	
			}		
			return r;	
			
		}	
		
		bool addArray(T[] a) 
		{			
			bool r = true;
			for (int i = 0; i < a.length; ++i)
			{
				r &= add(a[i]);	
			}		
			return r;				
		}
		
		
		bool contains(T o) {
			
			Iterator!(T) i = iterator();
			while (i.hasNext()) {
				T t = i.next();
				if (t == o) return true;
			}			
			return false;
			
		}
		
		
		bool containsAll(Collection!(T) c) {
					
			Iterator!(T) i = c.iterator();
			while (i.hasNext()) {
				T t = i.next();
				if (! contains(t) ) return false;
			}			
			return true;	
			
		}
		
		
		bool isEmpty() {
			
			return (size == 0);	
			
		}
		
		
		bool removeAll(Collection!(T) c) {
		
			bool r = true;
			Iterator!(T) i = c.iterator();
			while (i.hasNext()) {
				T t = i.next();				
				r &= remove(t);
			}			
			return r;	
			
		}
		
		
		T[] toArray() {
			
			T[] res = new T[size()];
			
			Iterator!(T) i = iterator();
			for(int k = 0; i.hasNext(); k++) {
				res[k] = i.next();
			}			
			return res;
			
		}
		
		
		int opApply(int delegate(ref T) dg) 
		{	
			Iterator!(T) i = iterator();
			int result = 0;
			while( i.hasNext() )
			{
				T t = i.next();
				result = dg(t);
				if (result) break;
			}			
			
			return result;			
		}
		
	}
	
}