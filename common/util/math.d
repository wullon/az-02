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
module util.math;

version(D_InlineAsm_X86)
{
// OK	
} else
{
	static assert(0, "x86 support is mandatory.");
}

import std.math;	
/*
alias std.math.sinhf sinhf;

alias std.math.floorf floorf;
alias std.math.floor floor;	
*/

alias std.math.cos cos;
alias std.math.sin sin;
alias std.math.tan tan;
alias std.math.tanh tanh;
alias std.math.isnan isnan;
alias std.math.E E;

const double PI_D = 3.1415926535897932384626433832795;
const double TWO_PI_D = 2.0 * PI_D;
const double PI_DIV_2_D = 0.5 * PI_D;
const double PI_DIV_4_D = 0.25 * PI_D;

const float PI_F = PI_D;
const float TWO_PI_F = TWO_PI_D;
const float PI_DIV_2_F = PI_DIV_2_D;
const float PI_DIV_4_F = PI_DIV_4_D;

const float DEG_TO_RAD = PI_D / 180;
const float RAD_TO_DEG = 180 / PI_D;

const double SQRT_2_D = 1.4142135623730950488016887242097;
const float SQRT_2_F = SQRT_2_D;
const double ONE_OVER_SQRT_2_D = 1.0 / SQRT_2_D;
const float ONE_OVER_SQRT_2_F = ONE_OVER_SQRT_2_D;


// FPU constants
static final ushort FPU_ROUND_TO_NEAREST = 0x037F;
static final ushort FPU_ROUND_TOWARD_ZERO = 0x0F7F;

enum FPUException : ushort
{
	INVALID_OPERATION = 1,
	DENORMAL_OPERAND = 2,
	ZERO_DIVIDE = 4,
	OVERFLOW = 8,
	UNDERFLOW = 16,
	PRECISION = 32,
	ALL = 63
}


void enableFPUException( FPUException e )
{
	ushort cw;
	asm	
	{
		fclex;
		fstcw cw;
  		mov AX, cw;
  		and AX, 0xffc0;
  		or AX, e;
  		mov cw, AX;
  		fldcw cw;			
	}	
}

// min and max function
T min(T)(T a, T b)
{
	return (a < b) ? a : b;
}

T max(T)(T a, T b)
{
	return (a > b) ? a : b;
}

// specialization for int
/*
T min(T:int)(int a, int b)
{
	asm
	{
		mov EDX, a;
		cmp EAX, EDX;
  		cmovg EAX, EDX;	
	}
}

T max(T:int)(int a, int b)
{
	asm
	{
		mov EDX, a;
		cmp EAX, EDX;
  		cmovl EAX, EDX;	
	}	
} */
/*
// specialization for float
T min(T:float)(float a, float b) 
{	
	asm
	{
		fld a;
		fld b;
		fcomi ST, ST(1);
		fcmovnb ST(1);
		ffree ST(1);
	}
}

T max(T:float)(float a, float b) 
{	
	asm
	{
	 	fld a;
    	fld b;
		fcomi ST, ST(1);
		fcmovb ST(1);
		ffree ST(1);
	}
}
*/



T lerp(T, U)(T a, T b, U t)
{
	return t * b + ( cast(U)1 - t ) * a;
}

T clamp(T)(T x)
{
	return x > 1 ? 1 : (x < 0 ? 0 : x);	
}

T clamp(S,T,U)(S x, T min, U max)
{
	return x > max ? max : (x < min ? min : x);	
}

/**
 * distort and clip
 */
T amplify(T)(T x)
{
	T y = clamp(x, cast(T)-1, cast(T)1);
	return y * cast(T)1.5 - cast(T)0.5 * y * y * y;
}

/**
 * Fast clamping for float (between 0.f and 1.f)
 */
T clamp(T : float)(float x) 
{
	asm
	{
		mov EAX, x;
		mov ECX, 0;
		or EAX, EAX;
		cmovs EAX, ECX;
		mov ECX, 0x3F800000; // 1.f
		cmp EAX, ECX;
		cmova EAX, ECX;
		mov x, EAX;
		fld x;
	}
}

/**
 * Useful for mapping a parameter finely for small values with preserved range
 * WARNING : min and max must have the same sign
 *           min cannot be near 0
 */
T logMap(T)(T min, T max, T x)
{
	return min * pow(max / min, x);
}

int round(T)(T x)
{
	asm
	{
		fldcw FPU_ROUND_TO_NEAREST;
		fld x;
		sub ESP, 4;
		fistp dword ptr [ESP];
		pop EAX;
	}
}

int trunc(T)(T x)
{
	asm
	{
		fldcw FPU_ROUND_TOWARD_ZERO;
		fld x;
		sub ESP, 4;
		fistp dword ptr [ESP];
		pop EAX;
	}
}

T frac(T)(T x)
{
	return x - cast(int)x;
}

T abs(T)(T x)
{  
	asm
	{
		fld x;
		fabs;
	}
}


T pow2(T)(T x)
{  
	
	asm
	{
		fld1;
		fld x;
		fprem;
		fstp ST(1);
		f2xm1;
		fld1;
		fadd;
		fldcw FPU_ROUND_TOWARD_ZERO;
		fld [x];
		frndint;
		fld1;
		fscale;
		fstp ST(1);
		fmul;
	}
}

// seem to break with powf( x, 1.5f ), do not use anymore !
T pow(T)(T base, T exponent)
{
	T tmp;
	asm
	{
		fld exponent;
  		fld base;
  		fyl2x;	
  		fst tmp;
  		fld1;
		fxch ST(1);
		fprem;
		fstp ST(1);
		f2xm1;
		fld1;
		faddp ST(1), ST;
		fldcw FPU_ROUND_TOWARD_ZERO;
		fld tmp;
		frndint;
		fld1;
		fscale;
		fstp ST(1);
		fmul;
	}
}

alias pow!(float) powf;
alias pow!(double) powd;


T exp(T)(T x)
{  
	return pow(cast(T)E, x);
}

T log2(T)(T x)
{  
	asm
	{
		fld1;
		fld x;
		fyl2x;
	}
}	

T log10(T)(T x)
{  
	asm
	{
		fldlg2;
		fld x;
		fyl2x;
	}
}

T log(T)(T x)
{  
	asm
	{
		fldln2;
		fld x;
		fyl2x;
	}
}

/**
 * square 
 */
T sqr(T)(T s)
{
	return s * s;	
}

/**
 * square root
 */
T sqrt(T)(T x)
{
	asm
	{
		fld x;
		fsqrt;
	}	
}

/**
 * tangent function
 */
T atan(T)(T x)
{
	asm
	{
		fld x;
		fld1;
		fpatan;	
	}	
}

/**
 * returns the angle of the vector (x,y)
 * in [-PI, PI[
 */
T atan2(T)(T x, T y)
{
	T u;
	asm
	{
		fld x;
		fld y;
		fpatan;	
		fstp u;
	}
	return u;
}

/**
 * return the first m with m = 2^k and m >= n
 * n must be >= 0
 */
int nextPow2(int n)
{
	for (int i = 0; i < 31; i++)
	{
		int m = (1 << i);
		if ((1 << i) >= n) return m;
	}
	return -1;
}

/**
 * linear interpolation
 */
T linearInterp(T)(T[] table, float index)
{
	if (index < 0)
	{
		return table[0];	
	}		
	else if (index >= table.length - 1) 
	{
		return table[table.length - 1];
	}
	else 
	{
		int ipart = cast(int)(index);
		float fpart = index - ipart;	
		T a = table[ipart] * (1 - fpart);	
		T b = table[ipart + 1] * fpart;	
		return a + b;
	}
}

// hermite 3 point interpolation
T hermite(T)(float frac_pos, T xm1, T x0, T x1, T x2)
{
   auto final c = (x1 - xm1) * cast(T)0.5;
   auto final v = x0 - x1;
   auto final w = c + v;
   auto final a = w + v + (x2 - x0) * cast(T)0.5;
   auto final b_neg = w + a;		
   return ((((a * frac_pos) - b_neg) * frac_pos + c) * frac_pos + x0);
}

//                   ___
// step function ___/
//
// BUG : division by a denormal when (b-a) is small
//
float step(float a, float b, float t)
{
	if (t <= a) return 0.f;
	else if (t >= b) return 1.f;
	else return (t - a) / (b - a); 
}

//                         
// smoothstep function : same as step but smooth
//
// BUG : division by a denormal when (b-a) is small
//
float smoothStep(float a, float b, float t)
{
	if (t <= a) return 0.f;
	else if (t >= b) return 1.f;
	else 
	{
		auto x = (t - a) / (b - a); 
		return x * x * (3.f - 2.f * x); 		
	}
}

//                   ___
// pulse function __|   |____
//
float pulse(float a, float b, float t)
{
	if (t <= a) return 0.f;
	else if (t >= b) return 0.f;
	else return 1.f; 
}



/* computes a sinus and cosinus at the same time */
void sincos(T)(T angle, ref T sin, ref T cos)
{
	T s, c;
	asm
	{
		fld	angle;
		fsincos;
		fstp s;
		fstp c;
	}
	sin = s;
	cos = c;
}



// exp approximation (for FPS independent movement)
T exp3(T)(T x)
{
	if (x < -1.15365) return 0;
	else return 1 + x * (1.0 + x * (0.5 + x * 0.3333333333333));
}