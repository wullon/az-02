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
module util.linkedlist;

private import util.collection;
private import util.list;
private import util.iterator;

class LinkedList(T) : AbstractSequentialList!(T) {
	
	private {
		
		
		class ListElement(T) {	
			
			public {	
			
				ListElement!(T) next, previous;
				T data;			
				
				this(ListElement!(T) previous, ListElement!(T) next, T data) {
					
					this.previous = previous;
					this.next = next;
					this.data = data;
				
				}
			}
			
		}
		
		ListElement!(T) head, last;		
		int count;
		
		class LinkedListIterator(T) : ListIterator!(T) {			
			
			private {
			
				ListElement!(T) nextElt;
				int nextEltIndex;
				ListElement!(T) lastReturned;
				bool lastMoveForward;
					
			}
			
			public {
			
				void gotoEnd() {
					
					nextElt = null;
					nextEltIndex = count;
					lastReturned = null;					
				
				}
				
				this(ListElement!(T) nextElt,int nextEltIndex) {
				
					this.nextElt = nextElt;				
					this.nextEltIndex = nextEltIndex;
					lastReturned = null;
					lastMoveForward = false;
					
					
				}
				
				void add(T o) {	
					
					if (nextElt is null) { // end of list
					
						if (head is null) { // empty list	
											
							head = nextElt = new ListElement!(T)(null, null, o);
													
						} else {						
							
							nextElt = new ListElement!(T)(last, null, o);
							last.next = nextElt;			
											
						}
						
						last = nextElt;
						
					} else { // middle of the list (or beginning)
						
						ListElement!(T) e = new ListElement!(T)(nextElt.previous, nextElt, o);
						
						if (nextElt.previous !is null) { // middle
							
							nextElt.previous.next = e;
							
						} else { // beginning
						
							head = e;
								
						}
						
						nextElt.previous = e;
						nextElt = e;						
						
					}						
						
					count++;
				}
				
				
				bool hasNext() {
					
					return (nextElt !is null);
						
				}
				
				
				T next() {
					
					assert(hasNext());
					lastReturned = nextElt;					
					nextElt = nextElt.next;
					nextEltIndex++;			
					lastMoveForward = true;		
					return lastReturned.data;					
						
				}
 	
				
				bool hasPrevious() {
					
					if (nextElt is null) { // end of list
					
						return (last !is null);	
						
					} else {
						
						return (nextElt.previous !is null);
						
					}
					
				}
				
				
				T previous() {
				
					assert(hasPrevious());	
					
					if (nextElt is null) { // end of list
					
						nextElt = last;
						
					} else {
						
						nextElt = nextElt.previous;
						
					}
					
					nextEltIndex--;
					lastReturned = nextElt;
					lastMoveForward = false;
					return nextElt.data;
					
				}
				
				
	 			int nextIndex() {
		 		
		 			if (hasNext()) {
			 			return nextEltIndex;
		 			} else {
			 			return count;
		 			}
		 				
	 			}
	 			
	 			
	 			int previousIndex() {
		 			
		 			if (hasPrevious()) {
			 			return nextEltIndex - 1;
		 			} else {
			 			return count;
		 			}
		 			
	 			}
	 			
	 			
	 			void remove() {
		 			
		 			assert(lastReturned !is null);
		 			
		 			if (lastReturned.previous !is null) {	
			 			
			 			nextElt = lastReturned.previous.next = lastReturned.next;
			 			
			 			if (lastReturned.next !is null) { // middle
				 			
				 			lastReturned.next.previous = lastReturned.previous;
				 			
			 			} else {
				 			
				 			last = lastReturned.previous;
				 			
			 			}
			 			
		 			} else { // first of the list
		 			
		 				if (lastReturned.next !is null) {
			 				
			 				lastReturned.next.previous = null;
			 				
		 				} else { // the list become empty
		 				
		 					last = null;
		 				
	 					}
			 			
		 				head = nextElt = lastReturned.next;		 				
			 			
		 			}
		 			
		 			lastReturned = null;
		 			
		 			if (lastMoveForward) nextEltIndex--;
		 			
		 			count--;
		 			
	 			}
	 			
	 			
	 			void set(T o) {
		 			
		 			assert(lastReturned !is null);
		 			lastReturned.data = o;
		 			
	 			}
	 			
 			}
			
		}
		
				
		
	}
	
	public {
		
		
		this() {
			
			head = last = null;
			count = 0;
			
		}
			
		
		ListIterator!(T) listIterator() {
			
			return new LinkedListIterator!(T)(head, 0);
			
		}
				
		
		int size() {
			
			return count;
			
		}
		
		
	}	
	
}