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
module util.list;

private import util.collection;
private import util.iterator;

interface List(T) : Collection!(T) 
{	
	
	public 
	{		
		bool addAt(int index, T element);
		bool addFirst(T element);
		bool addAllAt(int index, Collection!(T) c);		
		T get(int index);		
 		int indexOf(T o); // -1 if not in the list 
 		int lastIndexOf(T o); // -1 if not in the list           
 		ListIterator!(T) listIterator(); 		
 		T removeIndex(int index);
 		T set(int index, T element); // replace 
	}
}

class AbstractSequentialList(T) : AbtractCollection!(T) , List!(T) {
	
	public {
	
		abstract {
			
			ListIterator!(T) listIterator();			
			int size();
			
		}
	
	
		void clear() {
			
			ListIterator!(T) li = listIterator();
			while (li.hasNext()) {
				T dummy = li.next();	
				li.remove();
			}	
			
		}
		
				
		bool add(T o) {
			
			ListIterator!(T) li = listIterator();
			li.gotoEnd();
			li.add(o);
			return true;
			
		}
		
		bool addFirst(T element) {
			
			ListIterator!(T) li = listIterator();
			li.add(element);
			return true;
			
		}
		
		
		bool remove(T o) {
			
			ListIterator!(T) li = listIterator();
			while (li.hasNext()) {				
				T t = li.next();	
				if (t == o) {
					li.remove();
					return true;
				}
			}
			return false;	
			
		}
		
		
		Iterator!(T) iterator() {
			
			return listIterator();	
			
		}
		
		bool addAt(int index, T element) {
			
			ListIterator!(T) li = gotoIndex (index);
			li.add(element);
			return true;	
			
		}
		
		
		bool addAllAt(int index, Collection!(T) c) {
			
			assert(this !is c); // infinite loop ?			
			ListIterator!(T) li = gotoIndex (index);
			
			Iterator!(T) ci = c.iterator();			
			
			while (ci.hasNext()) {				
				li.add(ci.next());		
				li.next();		
			}
			
			return true;
			
		}
		
		bool addAll(Collection!(T) c) {
			
			return addAllAt(0,c);
			
		}
				

		T get(int index) {
			
			ListIterator!(T) li = gotoIndex (index);
			return li.next();
			
		}
				
		
		int indexOf(T o) {
			
			ListIterator!(T) li = listIterator();
			while (li.hasNext()) {
				int ind = li.nextIndex();
				T t = li.next();
				if (t == o) return ind;
			}	
			return -1;
			
		}
		
		int lastIndexOf(T o) {
			
			int lastIndex = -1;
			ListIterator!(T) li = listIterator();
			while (li.hasNext()) {
				int ind = li.nextIndex();
				T t = li.next();
				lastIndex = ind;
			}	
			return lastIndex;
			
		}
		
		
		T removeIndex(int index) {
								
			ListIterator!(T) li = gotoIndex (index);
			T r = li.next();
			li.remove;
			return r;				
						
		}
		
		T set(int index, T element) {
	
			ListIterator!(T) li = gotoIndex (index);
			T r = li.next();
			li.set(element);
			return r;				
			
		}
		
	}
	
	private {
		
		
		ListIterator!(T) gotoIndex (int index) {
			
			ListIterator!(T) li = listIterator();
			while (li.hasNext()) {
				if (li.nextIndex() == index) return li;					
				li.next();
			}	
			if (li.nextIndex() == index) return li;
			assert(false);
			
		}
		
		
	}
	
}
