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
module util.common;

import std.math;
import std.string;
import std.file;
import std.path;
import std.stdio;


final long rdtsc()
{
	asm
	{		
		rdtsc;
	}
}

final void emms()
{
	asm
	{
		emms;
	}
}

final long perf(void (*func)(), int tries)
{
	long accum = 0;
	for (int i = 0; i < tries; i++)
	{
		long start = rdtsc();
		func();		
		long stop = rdtsc();
		accum += (stop - start);
	}
	return accum / tries;
}

final void perfCompare(void (*func1)(), void (*func2)(), int tries)
{
	long perf1 = perf(func1, tries);
	long perf2 = perf(func2, tries);
	
	writefln("func1 : %s cycles (%s tries)", perf1, tries);	
	writefln("func2 : %s cycles (%s tries)", perf2, tries);
}

final void swap(T)(ref T a, ref T b) 
{	
	T c = a;
	a = b;
	b = c;			
}

// transforme chaine D en chaine C
char* toCString(char[] str) 
{
    version(Tango)
    {
        return toUtf8z(str);
    }
    else
    {
        return toStringz(str);
    }
}

// transforme chaine C en chaine D
char[] toDString(char* cstr)
{
   return toString(cstr);
}

void setBytes(void * data, uint count, ubyte value)
{
	asm
	{
		cld;
		push EDI;
		mov ECX, count;
		mov AL, value;
		mov EDI, data;
		rep;
		stosb;
		pop EDI;
	}
}

void setWords(void * data, uint count, ushort value)
{
	asm
	{
		cld;
		push EDI;
		mov ECX, count;
		mov AX, value;
		mov EDI, data;
		rep;
		stosw;
		pop EDI;
	}
}

void setDWords(void * data, uint count, uint value)
{
	asm
	{
		cld;
		push EDI;
		mov ECX, count;
		mov EAX, value;
		mov EDI, data;
		rep;
		stosd;		
		pop EDI;
	}
}

void moveBytes(void * src, void * dst, uint count)
{
	asm
	{
		cld;
		push EDI;
		push ESI;
		mov ECX, count;
		mov ESI, src;
		mov EDI, dst;
		rep;
		movsb;
		pop ESI;
		pop EDI;
	}
}

void moveWords(void * src, void * dst, uint count)
{
	asm
	{
		cld;
		push EDI;
		push ESI;
		mov ECX, count;
		mov ESI, src;
		mov EDI, dst;
		rep;
		movsw;
		pop ESI;
		pop EDI;
	}
}

void moveDWords(void * src, void * dst, uint count)
{
	asm
	{
		cld;
		push EDI;
		push ESI;
		mov ECX, count;
		mov ESI, src;
		mov EDI, dst;
		rep;
		movsd;
		pop ESI;
		pop EDI;
	}
}

ushort byteSwap(ushort w)
{
	asm
	{
		mov AX, w;
		xchg AH, AL;
	}	
}

uint byteSwap(uint dw)
{
	asm
	{
		mov EAX, dw;
		bswap EAX;	
	}
}

template Create(A ...)
{
    void print()
    {
        writefln("args are ", A);
    }
}
