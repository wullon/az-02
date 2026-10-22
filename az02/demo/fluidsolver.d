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
module demo.fluidsolver;

import util.all;
import util.geometry.vec2;

// only power of two are allowed

final class FluidSolver(int BITS)
{
	private
	{
		static assert(BITS <= 10, "too large");
		
		static const M = 1 << BITS;
		static const N = M - 2;
		static const SIZE = M * M;
		
		float[] mu, mv, mu_prev, mv_prev, mdens, mdens_prev;
		float m_visc;
		float m_diff;
		
		static void add_source(float* x, float* s, float dt)
		{
			for (int i = 0; i < SIZE; ++i)
			{
				x[i] += dt * s[i];	
			}
		}
		
		static void diffuse( float sgn1, float sgn2, float* x, float* x0, float diff, float dt ) 
		{
			int i, j, k; 
			float a = dt * diff * N * N; 
			float factor = 1.f / (1.f + 4.f * a);
			
			for ( k = 0 ; k < 20 ; k++ ) 
			{ 
				int index = M + 1;
				
				for ( j = 1 ; j <= N ; j++ ) 
				{ 
					for ( i = 1 ; i <= N ; i++ ) 
					{ 
						x[index] = (x0[index] + a * (x[index - 1] + x[index + 1] + x[index - M] + x[index + M] ) ) * factor;
						index++;
					}
					
					index += 2;
				}
			} 			
			set_bnd ( x, sgn1, sgn2 ); 
		} 			
		
		static void advect ( float sign1, float sign2, float * d, float * d0, float * u, float * v, float dt ) 
		{ 
			float dt0 = dt * N; 
			
			int index2 = M + 1;
			for (int j = 1; j <= N; ++j) 
			{ 
				for (int i = 1; i <= N; ++i) 				
				{ 
					float x = i - dt0 * u[index2] + 0.4f; 
					float y = j - dt0 * v[index2] + 0.4f; 
					if (x < 0.5) x = 0.5; 
					if (x > N + 0.5) x = N; 
					
					if (y < 0.5) y = 0.5; 
					if (y > N+0.5) y = N; 
					
					int i0 = trunc(x); 
					int j0 = trunc(y); 
					
					int index = i0 + (j0 << BITS);
					
					float s1 = x - i0; 
					float s0 = 1.f - s1; 
					float t1 = y - j0; 
					float t0 = 1.f - t1; 
					d[index2++] = s0 * (t0 * d0[index] + t1 * d0[index + M])
					            + s1 * (t0 * d0[index + 1] + t1 * d0[index + M + 1]); 					
				}
				index2 += 2;
			}
			set_bnd ( d , sign1, sign2); 
		}
		
		static void dens_step ( float * x, float * x0,  float * u, float * v, float diff, float dt ) 
		{ 
			add_source ( x, x0, dt ); 
			static long s1 = 0;
			diffuse ( 1.f, 1.f, x0, x, diff, dt ); 
			advect ( 1.f, 1.f, x, x0, u, v, dt ); 			
		} 
		
		static void vel_step ( float * u, float * v, float * u0, float * v0, float visc, float dt ) 
		{ 
/*			static double s1 = 0; 
			static double s2 = 0;
			static double s3 = 0;
			static double s4 = 0; 
			static double s5 = 0;
			static double s6 = 0;
*/
//			auto l0 = rdtsc;
			add_source ( u, u0, dt ); 
			add_source ( v, v0, dt ); 
//			auto l1 = rdtsc;
			diffuse ( -1.f, 1.f, u0, u, visc, dt ); 
			diffuse ( 1.f, -1.f, v0, v, visc, dt ); 
//			auto l2 = rdtsc;
			project ( u0, v0, u, v ); 
//			auto l3 = rdtsc;
			advect ( -1.f, 1.f, u, u0, u0, v0, dt ); 
			advect ( 1.f, -1.f, v, v0, u0, v0, dt ); 
//			auto l4 = rdtsc;
			project ( u, v, u0, v0 ); 
//			auto l5 = rdtsc;
/*			
			s1 += 0.1 * ((l1-l0)- s1);
			s2 += 0.1 * ((l2-l1)- s2); 
			s3 += 0.1 * ((l5-l4+l3-l2)- s3);
			s4 += 0.1 * ((l4-l3)- s4);
*/
//			writefln("s1 = %s, s2 = %s, s3 = %s, s4 = %s", s1, s2, s3, s4);
		} 
		
		static void project ( float * u, float * v, float * p, float * div )  
		{ 
			int i, j, k; 
			const float h = 1.0 / N; 
			const float invhx2 = 0.5f * N;
			
			{
				int index = M + 1;
				for (j = 1; j <= N; j++) 
				{ 
					for (i = 1; i <= N; i++)     
				    { 
					    div[index] = -0.5 * h * (u[index + 1] - u[index - 1]+ v[index + M] - v[index - M]); 
						p[index++] = 0; 
					}
					index += 2;
				} 
			}
			
			set_bnd(div, 1.f, 1.f); 
			set_bnd(p, 1.f, 1.f); 
			
			for ( k = 0 ; k < 20 ; k++ ) 
			{
				int index = M + 1;
				for (j = 1; j <= N; j++) 
				{ 
			    	for (i = 1; i <= N; i++) 	
					{
						p[index] = (div[index] + p[index - 1] + p[index + 1] + p[index - M] + p[index + M]) * 0.25f;
						index++;
					}
					index += 2;
				}
				
				set_bnd ( p, 1.f, 1.f ); 
		    } 
		    
		    {
			    int index = M + 1;
				for ( j = 1 ; j <= N ; j++ ) 
				{ 
					for ( i = 1 ; i <= N ; i++ ) 	
					{
						u[index] -= invhx2 * (p[index + 1] - p[index - 1]); 
						v[index] -= invhx2 * (p[index + M] - p[index - M]); 
						index++;
					}
					index += 2;
				}
			}
			set_bnd ( u , -1.f, 1.f); 
			set_bnd ( v ,  1.f, -1.f );  
		}
		
		static void set_bnd ( float * x, float sgn1, float sgn2 ) 
		{ 
			int i; 
			
			static const int i1 = 0;
			x[i1] = 0.5f * (x[i1 + 1] + x[i1 + M]);
			
			for ( i = 1 ; i <= N; i++ ) 
			{ 
				x[i + (0 << BITS)] = sgn2 * x[i + (1 << BITS)];
			} 
			
			static const int i3 = N + 1;	
			x[i3] = 0.5f * (x[i3 - 1] + x[i3 + M]);
			
			static const int i2 = (N+1) << BITS;
			x[i2] = 0.5f * (x[i2 + 1] + x[i2 - M]); 
			
			
			for ( i = 1 ; i <= N; i++ ) 
			{ 
				x[i + ((N+1) << BITS)] = sgn2 * x[i + (N << BITS)];			
			} 
			
			static const int i4 = i2 + i3;
			x[i4] = 0.5f * (x[i4 - 1] + x[i4 - M]); 
			
			
			for ( i = 1 ; i <= N; i++ ) 
			{
				x[0 + (i << BITS)] = sgn1 * x[1 + (i << BITS)];	
			}
			for ( i = 1 ; i <= N; i++ ) 
			{
				x[N + 1 + (i << BITS)] = sgn1 * x[N + (i << BITS)];
			}
		} 
		
		
	}	
	
	public
	{
	
		this(float visc = 0.05f, float diff = 0.05f)
		{
			
			mu.length = SIZE;
			mv.length = SIZE;
			mu_prev.length = SIZE;
			mv_prev.length = SIZE;
			mdens.length = SIZE;
			mdens_prev.length = SIZE;
			
			mu[] = 0.f;
			mv[] = 0.f;
			mu_prev[] = 0.f;
			mv_prev[] = 0.f;
			mdens[] = 0.f;
			mdens_prev[] = 0.f;
		}
		
		void move(float dt)
		{
			vel_step ( mu.ptr, mv.ptr, mu_prev.ptr, mv_prev.ptr, m_visc, dt ); 
			dens_step ( mdens.ptr, mdens_prev.ptr, mu.ptr, mv.ptr, m_diff, dt ); 					
			
		}
		
		void applyDensity(int x, int y, int size, float force)
		{
			for (int i = 0; i <= size; ++i)
			{
				for (int j = 0; j <= size; ++j)
				{
					auto ni = i - size >> 1;
					auto nj = j - size >> 1;					
					auto xi = x + ni;
					auto yj = y + nj;
					
					if ((xi >= 1) && (yj >= 1) && (xi <= N) && (yj <= N))
					{
						float d = sqr(ni) + sqr(nj);							
						auto index = xi + (yj << BITS);
						mdens[index] = force / (1 + d);
											
					}
				}
			}
		}
		
		void applyDensityArray(int x, int y, float[] values)
		{
			auto size = values.length;
			for (int i = 0; i < size * 2; ++i)
			{
				for (int j = 0; j < size * 2; ++j)
				{
					auto ni = i - size;
					auto nj = j - size;					
					auto xi = x + ni;
					auto yj = y + nj;
					
					if ((xi >= 1) && (yj >= 1) && (xi <= N) && (yj <= N))
					{
						int indValues = cast(int)(sqrt(ni*ni+nj*nj));						
						if (indValues < values.length)
						{
							int index = xi + (yj << BITS);
							float a = atan2(nj + 0.5f, ni + 0.5f) + PI_F * 0.5;
							mu[index] += cos(a) * values[indValues];
							mv[index] += sin(a) * values[indValues];
							
						}
											
					}
				}
			}
		}
		
		void applyVortex(int x, int y, int size, float force)
		{
			for (int i = 0; i <= size; ++i)
			{
				for (int j = 0; j <= size; ++j)
				{
					auto ni = i - size >> 1;
					auto nj = j - size >> 1;
					
					auto xi = x + ni;
					auto yj = y + nj;
					
					if ((xi >= 1) && (yj >= 1) && (xi <= N) && (yj <= N))
					{
						if ((ni != 0) || (nj != 0))
						{
							float d = sqr(ni) + sqr(nj);	
							float a = atan2(nj, ni) + PI_F * 0.5;
							auto index = xi + (yj << BITS);
							mu[index] += cos(a) * force * exp3(-d / size);
							mv[index] += sin(a) * force * exp3(-d / size);
						}
					}
				}
			}
		}
		
		float[] density()
		{
			return mdens;
		}
		
		float[] velocityX()
		{
			return mu;
		}
		
		float[] velocityY()
		{
			return mv;
		}
		
		float viscosity() { return m_visc; }
		float viscosity(float visc) { return m_visc = visc; }
		
		float diffusion() { return m_diff; }
		float diffusion(float d) { return m_diff = d; }
		
		vec2f velocity(int i, int j)
		{
			if ((cast(uint)i < M) && (cast(uint)j < M))
			{
				int index = i + (j << BITS);
				return vec2f(mu[index],mv[index]);
			}
			else
			{
				return vec2f(0.f);
			}
		}
		
	}
}
	
