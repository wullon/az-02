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
module audio.utils;

import audio.types;
import audio.constants;
import util.math;


float audioClip(float x)
{
	static const float LIM_INF = cast(float) -1;
	static const float LIM_SUP = cast(float) +1;
	if (x < LIM_INF) 
	{
		return LIM_INF;
	} else if (x > LIM_SUP)
	{
		return LIM_SUP;	
	} else 
	{
		return x;
	}
}


// time conversion
float bpm_to_freq(float bpm) {	return bpm / 60.f; }
float freq_to_bpm(float frequency) { return 60.f / frequency; }

float bpm_to_sec(float bpm) { 	return 60.f / bpm; }
float sec_to_bpm(float bpm) { 	return bpm / 60.f; }

float freq_to_sec(float frequency) { return 1.f / frequency; }
float sec_to_freq(float seconds) { return 1.f / seconds; }

float sec_to_samples(float seconds) { return seconds * SAMPLE_RATE_F; }
float samples_to_sec(float samples) { return samples * SAMPLE_RATE_INV_F; }

// amplitude conversion

float db_to_float(float db)
{
	return pow(10.f, 0.05f * db);	
}

float float_to_db(float x)
{
	return 20.f * log10(x);
}


// basic oversample with ugly mean filter
void oversample(int factor)(float * input, float * output, int length, ref float previous)
{
	float f = 1.f / factor;
	float current = previous;
	for (int i = 0; i < length; ++i)
	{
		float next = input[i];
		float step = (next - current) * f;
		for (int j = 0; j < factor; ++j)
		{
			current += step;
			*output++ = current;
		}		
	}	
	previous = current;
}

void subsample(int factor)(float * input, float * output, int length)
{
	float f = 1.f / factor; 
	for (int i = 0; i < length; ++i)
	{
		float acc = 0.f;
		for (int j = 0; j < factor; ++j)
		{
			acc += *input++;
		}
		output[i] = f * acc;
	}
}

// HQ oversampling with hermite interpolation
void oversampleHermite(int factor)(float * input, float * output, int length, 
                                   ref float _x_m_1, ref float _x_m_2, ref float _x_m_3)
{
	float[factor] steps;
	
	for (int i = 0; i < factor; ++i)
	{
		steps[i] = (1.f / factor) * (i + 1);
	}
	
	float x_m_1 = _x_m_1;
	float x_m_2 = _x_m_2;
	float x_m_3 = _x_m_3;
	
	for (int i = 0; i < length; ++i)
	{
		float next = input[i];
		for (int j = 0; j < factor; ++j)
		{
			*output++ = hermite(steps[j], x_m_3, x_m_2, x_m_1, next);
		}	
		x_m_3 = x_m_2;
		x_m_2 = x_m_1;
		x_m_1 = next;		
	}	
	_x_m_1 = x_m_1;
	_x_m_2 = x_m_2;
	_x_m_3 = x_m_3;
}


// generates a Blackman window in the data
void genBlackmanWindow(float[] data)
{
	int m = data.length - 1;
	float fm = m;
	
	for(int i = 0; i < data.length; ++i)
	{
		float f1 = (2.0f * PI_F) * i / fm;	
		float f2 = 2.f * f1;
		data[i] = 0.42f - 0.5f * cos(f1) + 0.08f * cos(f2);
	}
}
/*
// Discrete Fourier Transform
void DFT(int n, float *realTime, float *imagTime, float *realFreq, float *imagFreq)
{
  int k, i;
  float sr, si, p;

  for(k = 0; k < n; k++)
  {
    realFreq[k] = 0.0f;
    imagFreq[k] = 0.0f;
  }

  for(k = 0; k < n; k++)
    for(i = 0; i < n; i++)
    {
      p = (2.0f * PI * (float)(k * i)) / n;
      sr = cosf(p);
      si = -sinf(p);
      realFreq[k] += (realTime[i] * sr) - (imagTime[i] * si);
      imagFreq[k] += (realTime[i] * si) + (imagTime[i] * sr);
    }
}

// Inverse Discrete Fourier Transform
void InverseDFT(int n, float *realTime, float *imagTime, float *realFreq, float *imagFreq)
{
  int k, i;
  float sr, si, p;

  for(k = 0; k < n; k++)
  {
    realTime[k] = 0.0f;
    imagTime[k] = 0.0f;
  }

  for(k = 0; k < n; k++)
  {
    for(i = 0; i < n; i++)
    {
      p = (2.0f * PI * (float)(k * i)) / n;
      sr = cosf(p);
      si = -sinf(p);
      realTime[k] += (realFreq[i] * sr) + (imagFreq[i] * si);
      imagTime[k] += (realFreq[i] * si) - (imagFreq[i] * sr);
    }
    realTime[k] /= n;
    imagTime[k] /= n;
  }
}

// Complex Absolute Value
inline float cabs(float x, float y)
{
  return sqrtf((x * x) + (y * y));
}

// Complex Exponential
inline void cexp(float x, float y, float *zx, float *zy)
{
  float expx;

  expx = expf(x);
  *zx = expx * cosf(y);
  *zy = expx * sinf(y);
}

// Compute Real Cepstrum Of Signal
void RealCepstrum(int n, float *signal, float *realCepstrum)
{
  float *realTime, *imagTime, *realFreq, *imagFreq;
  int i;

  realTime = new float[n];
  imagTime = new float[n];
  realFreq = new float[n];
  imagFreq = new float[n];

  // Compose Complex FFT Input

  for(i = 0; i < n; i++)
  {
    realTime[i] = signal[i];
    imagTime[i] = 0.0f;
  }

  // Perform DFT

  DFT(n, realTime, imagTime, realFreq, imagFreq);

  // Calculate Log Of Absolute Value

  for(i = 0; i < n; i++)
  {
    realFreq[i] = logf(cabs(realFreq[i], imagFreq[i]));
    imagFreq[i] = 0.0f;
  }

  // Perform Inverse FFT

  InverseDFT(n, realTime, imagTime, realFreq, imagFreq);

  // Output Real Part Of FFT
  for(i = 0; i < n; i++)
    realCepstrum[i] = realTime[i];

  delete realTime;
  delete imagTime;
  delete realFreq;
  delete imagFreq;
}

// Compute Minimum Phase Reconstruction Of Signal
void MinimumPhase(int n, float *realCepstrum, float *minimumPhase)
{
  int i, nd2;
  float *realTime, *imagTime, *realFreq, *imagFreq;

  nd2 = n / 2;
  realTime = new float[n];
  imagTime = new float[n];
  realFreq = new float[n];
  imagFreq = new float[n];

  if((n % 2) == 1)
  {
    realTime[0] = realCepstrum[0];
    for(i = 1; i < nd2; i++)
      realTime[i] = 2.0f * realCepstrum[i];
    for(i = nd2; i < n; i++)
      realTime[i] = 0.0f;
  }
  else
  {
    realTime[0] = realCepstrum[0];
    for(i = 1; i < nd2; i++)
      realTime[i] = 2.0f * realCepstrum[i];
    realTime[nd2] = realCepstrum[nd2];
    for(i = nd2 + 1; i < n; i++)
      realTime[i] = 0.0f;
  }

  for(i = 0; i < n; i++)
    imagTime[i] = 0.0f;

  DFT(n, realTime, imagTime, realFreq, imagFreq);

  for(i = 0; i < n; i++)
    cexp(realFreq[i], imagFreq[i], &realFreq[i], &imagFreq[i]);

  InverseDFT(n, realTime, imagTime, realFreq, imagFreq);

  for(i = 0; i < n; i++)
    minimumPhase[i] = realTime[i];

  delete realTime;
  delete imagTime;
  delete realFreq;
  delete imagFreq;
}

// Generate MinBLEP And Return It In An Array Of Floating Point Values
float *GenerateMinBLEP(int zeroCrossings, int overSampling)
{
  int i, n;
  float r, a, b;
  float *buffer1, *buffer2, *minBLEP;

  n = (zeroCrossings * 2 * overSampling) + 1;

  buffer1 = new float[n];
  buffer2 = new float[n];

  // Generate Sinc

  a = (float)-zeroCrossings;
  b = (float)zeroCrossings;
  for(i = 0; i < n; i++)
  {
    r = ((float)i) / ((float)(n - 1));
    buffer1[i] = SINC(a + (r * (b - a)));
  }

  // Window Sinc

  BlackmanWindow(n, buffer2);
  for(i = 0; i < n; i++)
    buffer1[i] *= buffer2[i];

  // Minimum Phase Reconstruction

  RealCepstrum(n, buffer1, buffer2);
  MinimumPhase(n, buffer2, buffer1);

  // Integrate Into MinBLEP

  minBLEP = new float[n];
  a = 0.0f;
  for(i = 0; i < n; i++)
  {
    a += buffer1[i];
    minBLEP[i] = a;
  }

  // Normalize
  a = minBLEP[n - 1];
  a = 1.0f / a;
  for(i = 0; i < n; i++)
    minBLEP[i] *= a;

  delete buffer1;
  delete buffer2;
  return minBLEP;
}
*/