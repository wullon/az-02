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
module audio.constants;



const int SAMPLE_RATE = 44100; 
//const int SAMPLE_RATE = 96000;
const int BUFFER_SIZE = 64;
const int BUFFER_SIZE_BITS = 6;

const double SAMPLE_RATE_D = SAMPLE_RATE;
const double SAMPLE_RATE_KHZ_D = SAMPLE_RATE * 0.001;
const double SAMPLE_RATE_INV_D = 1.0 / SAMPLE_RATE_D;
const double SAMPLE_RATE_KHZ_INV_D = 1.0 / SAMPLE_RATE_KHZ_D;
const double TIME_PER_CYCLE_D = BUFFER_SIZE / SAMPLE_RATE_D; 
const double TIME_PER_SAMPLE_D = SAMPLE_RATE_INV_D;
const double BUFFER_SIZE_INV_D = 1.0 / cast(double)BUFFER_SIZE;
const double MAXIMUM_FREQUENCY_D = SAMPLE_RATE_D * 0.49; // to be determined
const double LISTENER_HEAD_SIZE_D = 0.093; // 9.3 cm
const double SPEED_OF_SOUND_D = 340.0; // m/sec
const double SPEED_OF_SOUND_INV_D = 1.0 / SPEED_OF_SOUND_D;
const double CYCLES_PER_SEC_D = SAMPLE_RATE_D / BUFFER_SIZE; 

const float SAMPLE_RATE_F = SAMPLE_RATE_D;
const float SAMPLE_RATE_KHZ_F = SAMPLE_RATE_KHZ_D;
const float SAMPLE_RATE_INV_F = SAMPLE_RATE_INV_D;
const float SAMPLE_RATE_KHZ_INV_F = SAMPLE_RATE_KHZ_INV_D;
const float TIME_PER_CYCLE_F = TIME_PER_CYCLE_D;
const float TIME_PER_SAMPLE_F = TIME_PER_SAMPLE_D;
const float BUFFER_SIZE_INV_F = BUFFER_SIZE_INV_D;
const float MAXIMUM_FREQUENCY_F = MAXIMUM_FREQUENCY_D;
const float LISTENER_HEAD_SIZE_F = LISTENER_HEAD_SIZE_D;
const float SPEED_OF_SOUND_F = SPEED_OF_SOUND_D;
const float SPEED_OF_SOUND_INV_F = SPEED_OF_SOUND_INV_D;
const float CYCLES_PER_SEC_F = CYCLES_PER_SEC_D; 

const float DENORMAL_DC_F = 1e25f;
