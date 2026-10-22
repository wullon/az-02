module util.geometry.mat4;

import util.math : cos, sin, tan, PI_D;
import util.common : swap;
import std.string;// : format, toString;
import util.geometry.vec2 : vec2;
import util.geometry.vec3 : vec3;
import util.geometry.vec4 : vec4;
import util.geometry.mat3 : mat3;


final struct mat4(T) 
{	
	private
	{
		T minor (int r0, int r1, int r2, int c0, int c1, int c2) 
		{		
			return c[r0][c0] * (c[r1][c1] * c[r2][c2] - c[r2][c1] * c[r1][c2]) -
			       c[r0][c1] * (c[r1][c0] * c[r2][c2] - c[r2][c0] * c[r1][c2]) +
				   c[r0][c2] * (c[r1][c0] * c[r2][c1] - c[r2][c0] * c[r1][c1]);
		}	
	}
	
	public 
	{
		union 
		{
			T c[4][4];
			T[16] v;
			T c00, c01, c02, c03, 
			  c10, c11, c12, c13,
			  c20, c21, c22, c23,
			  c30, c31, c32, c33;			
		}	
		
		static mat4 opCall(T c00, T c01, T c02, T c03,
		                   T c10, T c11, T c12, T c13,
		                   T c20, T c21, T c22, T c23,
		                   T c30, T c31, T c32, T c33) 
		{		
			mat4 m = void;	
			m.c[0][0] = c00;	m.c[0][1] = c01;	m.c[0][2] = c02;	m.c[0][3] = c03;
			m.c[1][0] = c10;	m.c[1][1] = c11;	m.c[1][2] = c12;	m.c[1][3] = c13;
			m.c[2][0] = c20;	m.c[2][1] = c21;	m.c[2][2] = c22;	m.c[2][3] = c23;
			m.c[3][0] = c30;	m.c[3][1] = c31;	m.c[3][2] = c32;	m.c[3][3] = c33;
			return m;
		}
		
		static mat4 opCall(vec4!(T) c0, vec4!(T) c1, vec4!(T) c2, vec4!(T) c3)
		{		
			mat4 m = void;	
			m.c[0][0] = c0.x;	m.c[0][1] = c1.x;	m.c[0][2] = c2.x;	m.c[0][3] = c3.x;
			m.c[1][0] = c0.y;	m.c[1][1] = c1.y;	m.c[1][2] = c2.y;	m.c[1][3] = c3.y;
			m.c[2][0] = c0.z;	m.c[2][1] = c1.z;	m.c[2][2] = c2.z;	m.c[2][3] = c3.z;
			m.c[3][0] = c0.w;	m.c[3][1] = c1.w;	m.c[3][2] = c2.w;	m.c[3][3] = c3.w;
			return m;
		}
		
		static mat4 opCall(T x)
		{			
			return mat4(x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x);
		}
		
		static mat4 opCall(mat3!(T) m)
		{			
			return mat4(m.c[0][0], m.c[0][1], m.c[0][2], 0, 
			            m.c[1][0], m.c[1][1], m.c[1][2], 0, 
			            m.c[2][0], m.c[2][1], m.c[2][2], 0, 
			            0        , 0        , 0        , 1);
		}
		
		static mat4 IDENTITY, ZERO;
		
		static this()
		{
			ZERO = mat4(0);
			IDENTITY = mat4(1, 0, 0, 0,
			                0, 1, 0, 0,
			                0, 0, 1, 0,
			                0, 0, 0, 1);				
		}	
		
		final T * ptr()
		{
			return &c[0][0];	
		}
		
		vec4!(T) c0() { return vec4!(T)(c00, c10, c20, c30); }
		vec4!(T) c1() { return vec4!(T)(c01, c11, c21, c31); }
		vec4!(T) c2() { return vec4!(T)(c02, c12, c22, c32); }
		vec4!(T) c3() { return vec4!(T)(c03, c13, c23, c33); }
		
		vec4!(T) l0() { return vec4!(T)(c00, c01, c02, c03); }
		vec4!(T) l1() { return vec4!(T)(c10, c11, c12, c13); }
		vec4!(T) l2() { return vec4!(T)(c20, c21, c22, c23); }
		vec4!(T) l3() { return vec4!(T)(c30, c31, c32, c33); }
		
		mat4 opMul(mat4 m) {
			
			return mat4(
				c[0][0] * m.c[0][0] + c[0][1] * m.c[1][0] + c[0][2] * m.c[2][0] + c[0][3] * m.c[3][0],
				c[0][0] * m.c[0][1] + c[0][1] * m.c[1][1] + c[0][2] * m.c[2][1] + c[0][3] * m.c[3][1],
				c[0][0] * m.c[0][2] + c[0][1] * m.c[1][2] + c[0][2] * m.c[2][2] + c[0][3] * m.c[3][2],
				c[0][0] * m.c[0][3] + c[0][1] * m.c[1][3] + c[0][2] * m.c[2][3] + c[0][3] * m.c[3][3],
				
				c[1][0] * m.c[0][0] + c[1][1] * m.c[1][0] + c[1][2] * m.c[2][0] + c[1][3] * m.c[3][0],
				c[1][0] * m.c[0][1] + c[1][1] * m.c[1][1] + c[1][2] * m.c[2][1] + c[1][3] * m.c[3][1],
				c[1][0] * m.c[0][2] + c[1][1] * m.c[1][2] + c[1][2] * m.c[2][2] + c[1][3] * m.c[3][2],
				c[1][0] * m.c[0][3] + c[1][1] * m.c[1][3] + c[1][2] * m.c[2][3] + c[1][3] * m.c[3][3],
				
				c[2][0] * m.c[0][0] + c[2][1] * m.c[1][0] + c[2][2] * m.c[2][0] + c[2][3] * m.c[3][0],
				c[2][0] * m.c[0][1] + c[2][1] * m.c[1][1] + c[2][2] * m.c[2][1] + c[2][3] * m.c[3][1],
				c[2][0] * m.c[0][2] + c[2][1] * m.c[1][2] + c[2][2] * m.c[2][2] + c[2][3] * m.c[3][2],
				c[2][0] * m.c[0][3] + c[2][1] * m.c[1][3] + c[2][2] * m.c[2][3] + c[2][3] * m.c[3][3],
				
				c[3][0] * m.c[0][0] + c[3][1] * m.c[1][0] + c[3][2] * m.c[2][0] + c[3][3] * m.c[3][0],
				c[3][0] * m.c[0][1] + c[3][1] * m.c[1][1] + c[3][2] * m.c[2][1] + c[3][3] * m.c[3][1],
				c[3][0] * m.c[0][2] + c[3][1] * m.c[1][2] + c[3][2] * m.c[2][2] + c[3][3] * m.c[3][2],
				c[3][0] * m.c[0][3] + c[3][1] * m.c[1][3] + c[3][2] * m.c[2][3] + c[3][3] * m.c[3][3]
			);
			
		}
		
		vec4!(T) opMul(vec4!(T) v) {
			
			return vec4!(T)(
				c[0][0] * v.v[0] + c[0][1] * v.v[1] + c[0][2] * v.v[2] + c[0][3] * v.v[3],
				c[1][0] * v.v[0] + c[1][1] * v.v[1] + c[1][2] * v.v[2] + c[1][3] * v.v[3],
				c[2][0] * v.v[0] + c[2][1] * v.v[1] + c[2][2] * v.v[2] + c[2][3] * v.v[3],
				c[3][0] * v.v[0] + c[3][1] * v.v[1] + c[3][2] * v.v[2] + c[3][3] * v.v[3]				
			);
			
		}
		
		mat4 opMul(T v) {
			
			return mat4(
				c[0][0] * v,
				c[0][1] * v,
				c[0][2] * v,
				c[0][3] * v,
				c[1][0] * v,
				c[1][1] * v,
				c[1][2] * v,
				c[1][3] * v,
				c[2][0] * v,
				c[2][1] * v,
				c[2][2] * v,
				c[2][3] * v,
				c[3][0] * v,
				c[3][1] * v,
				c[3][2] * v,
				c[3][3] * v
			);
			
		}
		
		mat4 opAdd(mat4 v) {
			
			return mat4(
				c[0][0] + v.c[0][0],
				c[0][1] + v.c[0][1],
				c[0][2] + v.c[0][2],
				c[0][3] + v.c[0][3],
				c[1][0] + v.c[1][0],
				c[1][1] + v.c[1][1],
				c[1][2] + v.c[1][2],
				c[1][3] + v.c[1][3],
				c[2][0] + v.c[2][0],
				c[2][1] + v.c[2][1],
				c[2][2] + v.c[2][2],
				c[2][3] + v.c[2][3],
				c[3][0] + v.c[3][0],
				c[3][1] + v.c[3][1],
				c[3][2] + v.c[3][2],
				c[3][3] + v.c[3][3]
			);
			
		}
		
		mat4 opSub(mat4 v) {
			
			return mat4(
				c[0][0] - v.c[0][0],
				c[0][1] - v.c[0][1],
				c[0][2] - v.c[0][2],
				c[0][3] - v.c[0][3],
				c[1][0] - v.c[1][0],
				c[1][1] - v.c[1][1],
				c[1][2] - v.c[1][2],
				c[1][3] - v.c[1][3],
				c[2][0] - v.c[2][0],
				c[2][1] - v.c[2][1],
				c[2][2] - v.c[2][2],
				c[2][3] - v.c[2][3],
				c[3][0] - v.c[3][0],
				c[3][1] - v.c[3][1],
				c[3][2] - v.c[3][2],
				c[3][3] - v.c[3][3]
			);
			
		}
		

		void opAddAssign(mat4 v) {
			
			c[0][0] += v.c[0][0];
			c[0][1] += v.c[0][1];
			c[0][2] += v.c[0][2];
			c[0][3] += v.c[0][3];
			c[1][0] += v.c[1][0];
			c[1][1] += v.c[1][1];
			c[1][2] += v.c[1][2];
			c[1][3] += v.c[1][3];
			c[2][0] += v.c[2][0];
			c[2][1] += v.c[2][1];
			c[2][2] += v.c[2][2];
			c[2][3] += v.c[2][3];
			c[3][0] += v.c[3][0];
			c[3][1] += v.c[3][1];
			c[3][2] += v.c[3][2];
			c[3][3] += v.c[3][3];			
			
		}
		
		
		void opSubAssign(mat4 v) {
			
			c[0][0] -= v.c[0][0];
			c[0][1] -= v.c[0][1];
			c[0][2] -= v.c[0][2];
			c[0][3] -= v.c[0][3];
			c[1][0] -= v.c[1][0];
			c[1][1] -= v.c[1][1];
			c[1][2] -= v.c[1][2];
			c[1][3] -= v.c[1][3];
			c[2][0] -= v.c[2][0];
			c[2][1] -= v.c[2][1];
			c[2][2] -= v.c[2][2];
			c[2][3] -= v.c[2][3];
			c[3][0] -= v.c[3][0];
			c[3][1] -= v.c[3][1];
			c[3][2] -= v.c[3][2];
			c[3][3] -= v.c[3][3];
			
		}
		
		mat4 transposed() {
			
			return mat4(
				c[0][0], c[1][0], c[2][0], c[3][0],
				c[0][1], c[1][1], c[2][1], c[3][1],
				c[0][2], c[1][2], c[2][2], c[3][2],
				c[0][3], c[1][3], c[2][3], c[3][3]
			);
			
		}
		
		/**
		 * in-place transpose
		 */
		void transpose() 
		{			
			swap(c[0][1],c[1][0]);
			swap(c[0][2],c[2][0]);
			swap(c[0][3],c[3][0]);
			swap(c[1][2],c[2][1]);
			swap(c[1][3],c[3][1]);
			swap(c[2][3],c[3][2]);			
		}
		

		
		
		T determinant() {
		
			return c[0][0] * minor( 1, 2, 3, 1, 2, 3) -
			       c[0][1] * minor( 1, 2, 3, 0, 2, 3) +
			       c[0][2] * minor( 1, 2, 3, 0, 1, 3) -
			       c[0][3] * minor( 1, 2, 3, 0, 1, 2);
		   
		}
		
		
		mat4 adjoint() {
			
			return mat4(
				minor( 1, 2, 3, 1, 2, 3),
				-minor( 0, 2, 3, 1, 2, 3),
				minor( 0, 1, 3, 1, 2, 3),
				-minor( 0, 1, 2, 1, 2, 3),
				
				-minor( 1, 2, 3, 0, 2, 3),
				minor( 0, 2, 3, 0, 2, 3),
				-minor( 0, 1, 3, 0, 2, 3),
				minor( 0, 1, 2, 0, 2, 3),
				
				minor( 1, 2, 3, 0, 1, 3),
				-minor( 0, 2, 3, 0, 1, 3),
				minor( 0, 1, 3, 0, 1, 3),
				-minor( 0, 1, 2, 0, 1, 3),
				
				-minor( 1, 2, 3, 0, 1, 2),
				minor( 0, 2, 3, 0, 1, 2),
				-minor( 0, 1, 3, 0, 1, 2),
				minor( 0, 1, 2, 0, 1, 2)
			);
			
		}
		
		mat4 inverse() 
		{			
			return adjoint() * (1.0f / determinant());		    
		}
		
		// orthonormalize a rotation matrix (introduce some error)
		mat4 orthonormalized()
		{
			vec3!(T) right   = vec3!(T)(c[0][0], c[1][0], c[2][0]);
			vec3!(T) up      = vec3!(T)(c[0][1], c[1][1], c[2][1]);
			vec3!(T) forward = vec3!(T)(c[0][2], c[1][2], c[2][2]);
			
			right.normalize();
			up.normalize();
			forward.normalize();
			
			right = vec3!(T).cross(up, forward); // right is normalized
			up = vec3!(T).cross(forward, right);
			
			return mat4(				
				right.x  , up.x , forward.x, 0, 
				right.y  , up.y , forward.y, 0, 
				right.z  , up.z , forward.z, 0, 
				0        , 0    , 0        , 1
			);
		}
			
		void orthonormalize()
		{
			auto nml = orthonormalized;
			*this = nml;
		}
				
		char[] toString() 
		{						
			/*return format( "( ( %s, %s, %s, %s ),"\n"( %s, %s, %s, %s ),"\n"( %s, %s, %s, %s ),"\n"( %s, %s, %s, %s )  )", 
			               c00, c01, c02, c03, c10, c11, c12, c13, c20, c21, c22, c23, c30, c31, c32, c33);
			  */             
			alias std.string.toString s;
			
			return "((" ~ s(c[0][0]) ~ ", " ~ s(c[0][1]) ~ ", " ~ s(c[0][2]) ~ ", " ~ s(c[0][3]) ~ ")"\n
			      ~" (" ~ s(c[1][0]) ~ ", " ~ s(c[1][1]) ~ ", " ~ s(c[1][2]) ~ ", " ~ s(c[1][3]) ~ ")"\n
			      ~" (" ~ s(c[2][0]) ~ ", " ~ s(c[2][1]) ~ ", " ~ s(c[2][2]) ~ ", " ~ s(c[2][3]) ~ ")"\n
			      ~" (" ~ s(c[3][0]) ~ ", " ~ s(c[3][1]) ~ ", " ~ s(c[3][2]) ~ ", " ~ s(c[3][3]) ~ "))";			               
		}
		
		// "basic" matrices used in 3D
		static 
		{
			
			mat4 scale(vec3!(T) v) {
			
				return mat4(
					v.x,   0,   0, 0,
                	  0, v.y,   0, 0,
                	  0,   0, v.z, 0,
                	  0,   0,   0, 1
                );	
				
			}
			
			mat4 scale(vec4!(T) v) {
			
				return mat4(
					v.x,   0,   0, 0,
                	  0, v.y,   0, 0,
                	  0,   0, v.z, 0,
                	  0,   0,   0, v.w
                );
			}
			
			mat4 translate(vec3!(T) v) 
			{			
				return mat4(
					1, 0, 0, v.x,
                	0, 1, 0, v.y,
                	0, 0, 1, v.z,
                	0, 0, 0, 1
                );					
			}
			
			mat4 identity() 
			{			
				return IDENTITY;
			}
			
			mat4 zero() 
			{			
				return ZERO;
			}			
			
			mat4 rotateX(T angle) 
			{				
				T cosa = cos(angle);
				T sina = sin(angle);			
				return mat4(
					1,    0,     0, 0,
                	0, cosa, -sina, 0,
                	0, sina,  cosa, 0,
                	0,    0,     0, 1
                );					
			}
			
			
			mat4 rotateY(T angle) 
			{				
				T cosa = cos(angle);
				T sina = sin(angle);			
				return mat4(
					cosa, 0, -sina, 0,
                	   0, 1,     0, 0,
                	sina, 0,  cosa, 0,
                	   0, 0,     0, 1
                );					
			}
			
			
			mat4 rotateZ(T angle) {
				
				T cosa = cos(angle);
				T sina = sin(angle);			
				return mat4(
					cosa, -sina, 0, 0,
                	sina,  cosa, 0, 0,
                	   0,     0, 1, 0,
                	   0,     0, 0, 1
                );	
				
			}
			
			// fovy in degree
			mat4 perspective(T fovy, T aspect, T zNear, T zFar) 
			{
				
				
				T f = 1 / tan( fovy * PI_D / 360);
				T d = 1 / (zNear - zFar);
				
				return mat4(
					f / aspect, 0,                  0,                    0,
					         0, f,                  0,                    0,
					         0, 0, (zFar + zNear) * d, 2 * d * zFar * zNear,
					         0, 0,                 -1,                    0
				);

			}
			
						
			// use it to set up a camera (seems to work but could be inverted)
			mat4 lookAt(vec3!(T)eye, vec3!(T)center, vec3!(T)up)
			{
				auto f = (center - eye).normalized();
				auto upp = up.normalized();
				auto s = vec3!(T).cross(f, upp);
				auto u = vec3!(T).cross(s, f);
				
				
				auto rot = 
				mat4(				
					-s.x, u.x, -f.x, 0, 
					-s.y, u.y, -f.y, 0, 
					-s.z, u.z, -f.z, 0, 
					0  ,   0,    0,  1
				).transposed();
				
				auto tr = translate(-eye);
				
				return rot * tr;				
			}
			
	
			
			
			// ortho
			mat4 ortho(float left, float right, float bottom, float top, float near, float far)
			{
				float dx = right - left, 
				      dy = right - left,
				      dz = far - near;
				      
				float tx = -(right + left) / dx;
				float ty = -(top + bottom) / dy;
				float tz = -(far + near) / dz;
				
				return 
				mat4(
					2.f / dx, 0.f,      0.f,      tx,
					0.f,      2.f / dy, 0.f,      ty,
					0.f,      0.f,      2.f / dz, tz,
					0.f,       0.f,     0.f,      1.f
				);
			}
			
		}		
		
	}
}

alias mat4!(float) mat4f;
alias mat4!(double) mat4d;

static assert(mat4f.sizeof == 16 * float.sizeof);
static assert(mat4d.sizeof == 16 * double.sizeof);