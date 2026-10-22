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
module util.textfile;

private import util.linkedlist;
private import util.iterator;
private import std.file;
private import std.stream;
private import std.stdio;

alias LinkedList!(char[]) StringList;
alias Iterator!(char[]) StringIterator;


StringList readTextFile(char[] filename) {
	
	StringList l = new StringList();
	auto fd = new File(filename);
	
	while (!fd.eof()) {
		char[] line = fd.readLine();								
		l.add(line);				
	}
	fd.close(); 
	return l;
	
}

void printStringList(StringList l) 
{
	StringIterator it = l.iterator();
			
	while(it.hasNext()) {
		char[] s = it.next();
		if (s != "")
		  writefln("%s", s);
	}
}
	
