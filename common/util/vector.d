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
module util.vector;

import util.collection;
import util.list;
import util.iterator;
import util.math;
import std.stdio;
import std.string;

final class Vector(T) : AbtractCollection!(T) , List!(T) {
	
	private {
	
		T[] d;	
		int count;	
		
		void incCount() {
			
			if (++count > d.length) {
				d.length = (d.length << 1) + 1;	
			}	
			
		}
		
		
		void decCount() {
			
			if (count * 2 + 1 < d.length) {
				d.length = (d.length - 1) >>> 1;
			}	
			count--;
			
		}
		
		
	}
	
	public {
		
		
		class VectorIterator(T) : ListIterator!(T) {			
			
			private {
			
				int nextElt;	
				int lastElt;	
				Vector!(T) v;
					
			}
			
			public {
			
				
				this(Vector!(T) v) 
				{					
					nextElt = 0;
					lastElt = -1;
					this.v = v;					
				}
				
				
				void gotoEnd() {
					
					nextElt = count;
					lastElt = -1;					
				
				}
				
				void add(T o) {	
					
					addAt(nextElt, o) ;
					
				}
				
				bool hasNext() 
				{					
					return (nextElt < count);					
				}				
				
				T next() 
				{							
					lastElt = nextElt;
					return d[nextElt++];						
				}
 	
				bool hasPrevious() 
				{					
					return (nextElt > 0);					
				}				
				
				T previous() 
				{				
					assert(nextElt > 0);
					
					lastElt = nextElt - 1;					
					return d[--nextElt];					
				}				
				
	 			int nextIndex() 
	 			{		 			
		 			if (nextElt < count) 
		 			{
			 			return nextElt;
		 			} else 
		 			{
			 			return count;	
		 			}
		 		}	 			
	 			
	 			int previousIndex() 
	 			{		 			
		 			if (nextElt > 0) 
		 			{
						return nextElt - 1;
			 		} else {
				 		return count;
			 		}
	 			}
	 			
	 			
	 			void remove() 
	 			{		 		
		 			assert(lastElt != -1);
		 			v.removeIndex(lastElt);
		 			lastElt = -1;
	 			}
	 			
	 			
	 			void set(T o) 
	 			{		 			
		 			assert(lastElt != -1);
		 			d[lastElt] = o;		 		
	 			}
	 			
 			}
		}		
		
		this(int initSize) 
		{		
			d.length = nextPow2(initSize);
			count = 0;			
		}
		
		auto const DEFAULT_SIZE = 16;
		
		this() 
		{	
			this(DEFAULT_SIZE);	
		}	
		
		int size() 
		{		
			return count;				
		}
		
		int length()
		{
			return count;	
		}
		
		T * ptr()
		{
			return d.ptr;	
		}
		
		void clear() {
			
			d.length = 0;
			count = 0;
			
		}
		
		void sort()
		{
			d = d.sort;				
		}
		
		T opIndex(size_t i)
		{
			return d[i];		
		}
		
	    T get(int index) 
		{			
			return d[index];				
		}
		
		T opIndexAssign(T value, size_t i)
		{
			return d[i] = value;	
		}
		
		T set(int index, T element) 
		{			
			T previous = d[index];
			d[index] = element;
			return previous;			
		}		
		
		int indexOf(T o) {
			
			for(int i = 0; i < size(); i++) 
			{
				if (d[i] == o) return i;	
			}
			
			return -1;			
		}		
		
		int lastIndexOf(T o) 
		{
			
			for(int i = size() - 1; i >= 0; --i) 
			{
				if (d[i] == o) return i;	
			}
			
			return -1;
			
		}
		
		
		T removeIndex(int index) 
		{
			assert(index >= 0);
			assert(index < count);
			
			T removed = d[index];
			for (int i = index; i < count - 1 ; ++i) {
				d[i] = d[i+1];	
			}			
			decCount();			
			return removed;			
		}
		
		
		bool addAt(int index, T element) 
		{
			incCount();	
			for (int i = count - 1; i > index; --i) {
				d[i] = d[i-1];
			}						
			d[index] = element;
			return true;
			
		}
		
		
		bool remove(T o) 
		{		
			int index = indexOf(o);
			if (index == -1) 
			{
				return false;	
			} else {
				removeIndex(index);	
				return true;
			}
		}
		
		
		bool add(T o) 
		{			
			incCount();	
			d[count - 1] = o;
			return true;			
		}
		
		bool addFirst(T element) 
		{		
			return addAt(0,element);				
		}
		
		
		bool addAllAt(int index, Collection!(T) c) 
		{			
			assert(this !is c); // infinite loop ?			
			
			Iterator!(T) ci = c.iterator();			
			
			for (int i = 0; ci.hasNext() ; i++) {				
				addAt(i+index, ci.next());						
			}
			
			return true;			
		}
		
		
		Iterator!(T) iterator() 
		{			
			return listIterator();			
		}
		
		
		bool addAll(Collection!(T) c) 
		{			
			return addAllAt(count,c);			
		}		
		
		ListIterator!(T) listIterator() 
		{		
			return (new VectorIterator!(T)(this));				
		}
		
		int opApply(int delegate(ref T) dg) 
		{	
			int result = 0;
			for (int i = 0; i < count; ++i)
			{
				result = dg(d[i]);
				if (result) break;
			}			
			return result;
		}		
		
		char[] toString()
		{
			char[] res = "[";	
			for (int i = 0; i < count; ++i)
			{
				if (i != 0) res = res ~ ", ";
				res	= res ~ format("%s", d[i]);				
			}
			res = res ~ "]";
			return res;
		}
	}	
}
