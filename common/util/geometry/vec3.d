module util.geometry.vec3;

//import util.math;
import std.string : format;

import util.geometry.vec2 : vec2;
import util.geometry.vectorop;


final struct vec3(T) 
{	
	public 
	{		
		union 
		{
			struct 
			{
				T x, y, z;
			}
			T[3] v;
		}
	}
	
	mixin VectorOp!(T, v);
	
	public 
	{		
		//////////////////
		// constructors //
		//////////////////
		
		static vec3 opCall(T x, T y, T z)
		{
			vec3 v = void;
			v.x = x;
			v.y = y;
			v.z = z;
			return v;
		}
		
		static vec3 opCall(T x)
		{
			return vec3(x, x, x);
		}
		
		static vec3 opCall(vec2!(T) v, T z)
		{
			return vec3(v.x, v.y, z);
		}	
		
		
		///////////////
		// constants //
		///////////////
		
		static vec3 ZEROS, ONES, AXIS_X, AXIS_Y, AXIS_Z;
		static this()
		{
			ZEROS = vec3(0);
			ONES = vec3(1);
			AXIS_X = vec3(1,0,0);
			AXIS_Y = vec3(0,1,0);
			AXIS_Z = vec3(0,0,1);
		}			
		
		///////////////////////////
		// GLSL style properties //
		///////////////////////////
		
	/*	char[] swizzle3()() 
		{
			char[] result;
			foreach (char i; ['x', 'y', 'z'])
			foreach (char j; ['x', 'y', 'z'])
			foreach (char k; ['x', 'y', 'z'])
			{
				result ~= Format!(
					"vec3!(T) %s() "
					"{ "
					"	return vec3!(T)(%s, %s, %s);"
					" }\n", i ~ j ~ k, i, j, k);
			}	
			return result;
		}
			
		pragma(msg, swizzle3!()());		*/ // don't want to compile		
		
		vec2!(T) xx() { return vec2!(T)(x, x); }
		vec2!(T) xy() { return vec2!(T)(x, y); }
		vec2!(T) xz() { return vec2!(T)(x, z); }
		vec2!(T) yx() { return vec2!(T)(y, x); }
		vec2!(T) yy() { return vec2!(T)(y, y); }
		vec2!(T) yz() { return vec2!(T)(y, z); }
		vec2!(T) zx() { return vec2!(T)(z, x); }
		vec2!(T) zy() { return vec2!(T)(z, y); }
		vec2!(T) zz() { return vec2!(T)(z, z); }
		
		vec3 xxx() { return vec3(x, x, x); }
		vec3 xxy() { return vec3(x, x, y); }
		vec3 xxz() { return vec3(x, x, z); }
		vec3 xyx() { return vec3(x, y, x); }
		vec3 xyy() { return vec3(x, y, y); }
		vec3 xyz() { return vec3(x, y, z); }
		vec3 xzx() { return vec3(x, z, x); }
		vec3 xzy() { return vec3(x, z, y); }
		vec3 xzz() { return vec3(x, z, z); }
		
		vec3 yxx() { return vec3(y, x, x); }
		vec3 yxy() { return vec3(y, x, y); }
		vec3 yxz() { return vec3(y, x, z); }
		vec3 yyx() { return vec3(y, y, x); }
		vec3 yyy() { return vec3(y, y, y); }
		vec3 yyz() { return vec3(y, y, z); }
		vec3 yzx() { return vec3(y, z, x); }
		vec3 yzy() { return vec3(y, z, y); }
		vec3 yzz() { return vec3(y, z, z); }
		
		vec3 zxx() { return vec3(z, x, x); }
		vec3 zxy() { return vec3(z, x, y); }
		vec3 zxz() { return vec3(z, x, z); }
		vec3 zyx() { return vec3(z, y, x); }
		vec3 zyy() { return vec3(z, y, y); }
		vec3 zyz() { return vec3(z, y, z); }
		vec3 zzx() { return vec3(z, z, x); }
		vec3 zzy() { return vec3(z, z, y); }
		vec3 zzz() { return vec3(z, z, z); }		
		
		vec2!(T) xy(vec2!(T) v) { x = v.x; y = v.y; return v; }
		vec2!(T) xz(vec2!(T) v) { x = v.x; z = v.y; return v; }
		vec2!(T) yx(vec2!(T) v) { y = v.x; x = v.y; return v; }		
		vec2!(T) yz(vec2!(T) v) { y = v.x; z = v.y; return v; }
		vec2!(T) zx(vec2!(T) v) { z = v.x; x = v.y; return v; }		
		vec2!(T) zy(vec2!(T) v) { z = v.x; y = v.y; return v; }
		
		vec3 xyz(vec3 v) { x = v.x; y = v.y; z = v.z; return v; }
		vec3 xzy(vec3 v) { x = v.x; z = v.y; y = v.z; return v; }
		vec3 yxz(vec3 v) { y = v.x; x = v.y; z = v.z; return v; }
		vec3 yzx(vec3 v) { y = v.x; z = v.y; x = v.z; return v; }
		vec3 zxy(vec3 v) { z = v.x; x = v.y; y = v.z; return v; }
		vec3 zyx(vec3 v) { z = v.x; y = v.y; x = v.z; return v; }
		
		//////////////////////////
		// operator overloading	//
		//////////////////////////
		
		vec3 opAdd(T a) 
		{
			return  vec3(x + a, y + a, z + a);			
		}		
		
		vec3 opAdd(vec3 v) 
		{
			return  vec3(x + v.x, y + v.y, z + v.z);			
		}				

		vec3 opSub(vec3 v) 
		{
			return  vec3(x - v.x, y - v.y, z - v.z);			
		}				
		
		vec3 opSub(T a) 
		{
			return  vec3(x - a, y - a, z - a);			
		}		
				
		vec3 opSub_r(T a) 
		{
			return  vec3(a - x, a - y, a - z);			
		}		
		
		vec3 opMul(vec3 v) 
		{
			return  vec3(x * v.x, y * v.y, z * v.z);			
		}			
		
		vec3 opMul(T a) 
		{
			return  vec3(x * a, y * a, z * a);			
		}	
		
		vec3 opDiv(vec3 v) 
		{
			return vec3(x / v.x, y / v.y, z / v.z);			
		}

		vec3 opDiv(T a) 
		{
			return  vec3(x / a, y / a, z / a);			
		}		
		
		void opAddAssign(T a) 
		{			
			x += a;
			y += a;
			z += a;			
		}
				
		void opAddAssign(vec3 v)
		{			
			x += v.x;
			y += v.y;
			z += v.z;			
		}		
		
		void opSubAssign(T a) 
		{			
			x -= a;
			y -= a;
			z -= a;			
		}		
		
		void opSubAssign(vec3 v) 
		{			
			x -= v.x;
			y -= v.y;
			z -= v.z;			
		}
			
		void opMulAssign(T a) 
		{				
			x *= a;
			y *= a;
			z *= a;			
		}
		
		void opMulAssign(vec3 v) 
		{				
			x *= v.x;
			y *= v.y;
			z *= v.z;			
		}
				
		void opDivAssign(T a) 
		{				
			x /= a;
			y /= a;
			z /= a;			
		}
		
		void opDivAssign(vec3 v) 
		{				
			x /= v.x;
			y /= v.y;
			z /= v.z;			
		}
		
		vec3 opNeg() 
		{			
			return  vec3(-x, -y, -z);			
		}	

		char[] toString() 
		{			
			return format("( %s, %s, %s )", x, y, z);
		}
		
		static vec3 cross(vec3 a, vec3 b) 
		{			
			return  vec3(a.y * b.z - a.z * b.y, 
			             a.z * b.x - a.x * b.z,
			             a.x * b.y - a.y * b.x);			
		}	
		
		static vec3 min(vec3 a, vec3 b)
		{
			T x = util.math.min(a.x, b.x);
			T y = util.math.min(a.y, b.y);
			T z = util.math.min(a.z, b.z);
			return vec3(x, y, z);	
		}
		
		static vec3 max(vec3 a, vec3 b)
		{
			T x = util.math.max(a.x, b.x);
			T y = util.math.max(a.y, b.y);
			T z = util.math.max(a.z, b.z);
			return vec3(x, y, z);	
		}	
	}
}


alias vec3!(int) vec3i;
alias vec3!(float) vec3f;
alias vec3!(double) vec3d;

