module util.geometry.mat3;


import util.math : cos, sin;
import util.common : swap;
import std.string;// : format, toString;
import util.geometry.vec2 : vec2;
import util.geometry.vec3 : vec3;

final struct mat3(T) 
{	
	public {
		
		union 
		{
			T c[3][3];
			T[9] v;
			T c00, c01, c02, c10, c11, c12, c20, c21, c22;			
		}	
		
		static mat3 opCall(T c00, T c01, T c02, 
		                   T c10, T c11, T c12, 
		                   T c20, T c21, T c22 ) 
		{			
			mat3 m = void;
			m.c[0][0] = c00;	m.c[0][1] = c01;	m.c[0][2] = c02;
			m.c[1][0] = c10;	m.c[1][1] = c11;	m.c[1][2] = c12;
			m.c[2][0] = c20;	m.c[2][1] = c21;	m.c[2][2] = c22;	
			return m;
		}	
		
		static mat3 opCall(vec3!(T) c0, vec3!(T) c1, vec3!(T) c2)
		{		
			mat3 m = void;;	
			m.c[0][0] = c0.x;	m.c[0][1] = c1.x;	m.c[0][2] = c2.x;
			m.c[1][0] = c0.y;	m.c[1][1] = c1.y;	m.c[1][2] = c2.y;
			m.c[2][0] = c0.z;	m.c[2][1] = c1.z;	m.c[2][2] = c2.z;
			return m;
		}
		
		static mat3 opCall(T x)
		{			
			return mat3(x, x, x, x, x, x, x, x, x);
		}
		
		vec3!(T) c0() { return vec3!(T)(c00, c10, c20); }
		vec3!(T) c1() { return vec3!(T)(c01, c11, c21); }
		vec3!(T) c2() { return vec3!(T)(c02, c12, c22); }
		
		vec3!(T) l0() { return vec3!(T)(c00, c01, c02); }
		vec3!(T) l1() { return vec3!(T)(c10, c11, c12); }
		vec3!(T) l2() { return vec3!(T)(c20, c21, c22); }
		
		mat3 opMul(mat3 m) 
		{			
			return mat3
			(
				c[0][0] * m.c[0][0] + c[0][1] * m.c[1][0] + c[0][2] * m.c[2][0],
				c[0][0] * m.c[0][1] + c[0][1] * m.c[1][1] + c[0][2] * m.c[2][1],
				c[0][0] * m.c[0][2] + c[0][1] * m.c[1][2] + c[0][2] * m.c[2][2],				
				
				c[1][0] * m.c[0][0] + c[1][1] * m.c[1][0] + c[1][2] * m.c[2][0],
				c[1][0] * m.c[0][1] + c[1][1] * m.c[1][1] + c[1][2] * m.c[2][1],
				c[1][0] * m.c[0][2] + c[1][1] * m.c[1][2] + c[1][2] * m.c[2][2],
				
				c[2][0] * m.c[0][0] + c[2][1] * m.c[1][0] + c[2][2] * m.c[2][0],
				c[2][0] * m.c[0][1] + c[2][1] * m.c[1][1] + c[2][2] * m.c[2][1],
				c[2][0] * m.c[0][2] + c[2][1] * m.c[1][2] + c[2][2] * m.c[2][2]
			);
		}
		
		vec3!(T) opMul(vec3!(T) v) {
			
			return vec3!(T)
			(
				c[0][0] * v.v[0] + c[0][1] * v.v[1] + c[0][2] * v.v[2],
				c[1][0] * v.v[0] + c[1][1] * v.v[1] + c[1][2] * v.v[2],
				c[2][0] * v.v[0] + c[2][1] * v.v[1] + c[2][2] * v.v[2]	
			);
			
		}
		
		mat3 opMul(T v) {
			
			return mat3(
				c[0][0] * v,
				c[0][1] * v,
				c[0][2] * v,
				c[1][0] * v,
				c[1][1] * v,
				c[1][2] * v,
				c[2][0] * v,
				c[2][1] * v,
				c[2][2] * v
			);
			
		}
		
		mat3 opAdd(mat3 v) 
		{			
			return mat3(
				c[0][0] + v.c[0][0],
				c[0][1] + v.c[0][1],
				c[0][2] + v.c[0][2],
				c[1][0] + v.c[1][0],
				c[1][1] + v.c[1][1],
				c[1][2] + v.c[1][2],
				c[2][0] + v.c[2][0],
				c[2][1] + v.c[2][1],
				c[2][2] + v.c[2][2]				
			);			
		}
		
		mat3 opSub(mat3 v) 
		{			
			return mat3(
				c[0][0] - v.c[0][0],
				c[0][1] - v.c[0][1],
				c[0][2] - v.c[0][2],
				c[1][0] - v.c[1][0],
				c[1][1] - v.c[1][1],
				c[1][2] - v.c[1][2],
				c[2][0] - v.c[2][0],
				c[2][1] - v.c[2][1],
				c[2][2] - v.c[2][2]			
			);
		}
		

		mat3 opAddAssign(mat3 v) 
		{			
			c[0][0] += v.c[0][0];
			c[0][1] += v.c[0][1];
			c[0][2] += v.c[0][2];
			c[1][0] += v.c[1][0];
			c[1][1] += v.c[1][1];
			c[1][2] += v.c[1][2];
			c[2][0] += v.c[2][0];
			c[2][1] += v.c[2][1];
			c[2][2] += v.c[2][2];
			return *this;
		}
		
		
		mat3 opSubAssign(mat3 v) 
		{			
			c[0][0] -= v.c[0][0];
			c[0][1] -= v.c[0][1];
			c[0][2] -= v.c[0][2];
			c[1][0] -= v.c[1][0];
			c[1][1] -= v.c[1][1];
			c[1][2] -= v.c[1][2];
			c[2][0] -= v.c[2][0];
			c[2][1] -= v.c[2][1];
			c[2][2] -= v.c[2][2];
			return *this;
		}
		
		mat3 opMulAssign(mat3 v) 
		{
			mat3 m = *this * v;
			return *this = m;
		}
		
		mat3 transposed() 
		{			
			return mat3
			(
				c[0][0], c[1][0], c[2][0],
				c[0][1], c[1][1], c[2][1],
				c[0][2], c[1][2], c[2][2]				
			);
			
		}
		
		void transpose() 
		{			
			swap(c[0][1],c[1][0]);
			swap(c[0][2],c[2][0]);			
			swap(c[1][2],c[2][1]);
		}
		
		// orthonormalize a rotation matrix (introduce some error)
		mat3 orthonormalized()
		{
			vec3!(T) right   = vec3!(T)(c[0][0], c[1][0], c[2][0]);
			vec3!(T) up      = vec3!(T)(c[0][1], c[1][1], c[2][1]);
			vec3!(T) forward = vec3!(T)(c[0][2], c[1][2], c[2][2]);
			right.normalize;
			up.normalize;
			forward.normalize;
			
			
			right = vec3!(T).cross(up, forward); // right is normalized
			up = vec3!(T).cross(forward, right);
			
			return mat3(				
				right.x  , up.x , forward.x,
				right.y  , up.y , forward.y,
				right.z  , up.z , forward.z
			);
		}
			
		void orthonormalize()
		{
			auto nml = orthonormalized;
			*this = nml;
		}
		
		char[] toString() 
		{			
			alias std.string.toString s;
			
			return "((" ~ s(c[0][0]) ~ ", " ~ s(c[0][1]) ~ ", " ~ s(c[0][2]) ~ ")"\n
			      ~" (" ~ s(c[1][0]) ~ ", " ~ s(c[1][1]) ~ ", " ~ s(c[1][2]) ~ ")"\n
			      ~" (" ~ s(c[2][0]) ~ ", " ~ s(c[2][1]) ~ ", " ~ s(c[2][2]) ~ "))";
			
		}
		
		static mat3 IDENTITY, ZERO;
		
		static this()
		{
			ZERO = mat3(0);
			IDENTITY = mat3(1, 0, 0,
			                0, 1, 0,
			                0, 0, 1);				
		}	
		
		static {
			
			mat3 zero() 
			{				
				return ZERO;
			}
			
			mat3 identity() 
			{				
				return IDENTITY;
			}
			
			mat3 scale(T f) 
			{			
				return mat3
				(
					f, 0, 0, 
                	0, f, 0,
                	0, 0, 1
                );	
				
			}
			
			mat3 scale(T x, T y) 
			{			
				return mat3
				(
					x, 0, 0,
                	0, y, 0,
                	0, 0, 1
                );	
				
			}
			
			mat3 scale(vec2!(T) v) 
			{			
				return mat3
				(
					v.x,   0,   0,
                	  0, v.y,   0,
                	  0,   0,   1                	  
                );					
			}			
			
			mat3 translate(T x, T y) 
			{			
				return mat3
				(
					1, 0, x,
                	0, 1, y,
                	0, 0, 1
                );	
				
			}			
			
			mat3 translate(vec2!(T) v) 
			{			
				return mat3
				(
					1, 0, v.x,
                	0, 1, v.y,
                	0, 0, 1                	
                );					
			}			
			
			mat3 rotateX(T angle) 
			{				
				T cosa = cos(angle);
				T sina = sin(angle);			
				return mat3
				(
					1,    0,     0,
                	0, cosa, -sina,
                	0, sina,  cosa
                );				
			}
			
			
			mat3 rotateY(T angle) 
			{				
				T cosa = cos(angle);
				T sina = sin(angle);			
				return mat3
				(
					cosa, 0, -sina,
                	   0, 1,     0,
                	sina, 0,  cosa               	   
                );				
			}
			
			
			mat3 rotateZ(T angle) 
			{				
				T cosa = cos(angle);
				T sina = sin(angle);			
				return mat3
				(
					cosa, -sina, 0,
                	sina,  cosa, 0,
                	   0,     0, 1                	   
                );				
			}
		}	
	}
}

alias mat3!(float) mat3f;
alias mat3!(double) mat3d;

static assert(mat3f.sizeof == 9 * float.sizeof);
static assert(mat3d.sizeof == 9 * double.sizeof);
