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
module demo.shapes;

import gl.all;
import util.geometry.vec3;

private void quad(vec3f a, vec3f b, vec3f c, vec3f d, vec3f nml)
{
	glNormal3fv(nml.ptr);
	glTexCoord2f(0,0);
	glVertex3fv(a.ptr);
	glTexCoord2f(1,0);
	glVertex3fv(b.ptr);
	glTexCoord2f(1,1);
	glVertex3fv(c.ptr);
	glTexCoord2f(0,1);
	glVertex3fv(d.ptr);
}

void drawCube(vec3f size, bool outerNormal = true)
{
	float nf = outerNormal ? 1.f : -1.f;
	auto a = size * vec3f(-1.f, +1.f, +1.f);
	auto b = size * vec3f(+1.f, +1.f, +1.f);
	auto c = size * vec3f(-1.f, -1.f, +1.f);
	auto d = size * vec3f(+1.f, -1.f, +1.f);
	auto e = size * vec3f(-1.f, +1.f, -1.f);
	auto f = size * vec3f(+1.f, +1.f, -1.f);
	auto g = size * vec3f(-1.f, -1.f, -1.f);
	auto h = size * vec3f(+1.f, -1.f, -1.f);
	
	glBegin(GL_QUADS);
	quad(a,b,d,c,vec3f(0,0,nf));
	quad(e,f,b,a,vec3f(0,nf,0));
	quad(b,f,h,d,vec3f(nf,0,0));
	quad(c,g,e,a,vec3f(-nf,0,0));
	quad(c,d,h,g,vec3f(0,-nf,0));
	quad(g,h,f,e,vec3f(0,0,-nf));
	glEnd();
}