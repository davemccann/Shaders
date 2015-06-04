#version 330

in vec3 varying_position;
in vec3 varying_normal;

out vec3 shadow_depth;

void main(void)
{
	shadow_depth = vec3(gl_FragCoord.z, 0.f, 0.f);
}