#version 330

in vec2 vertex_position;

void main(void)
{
	gl_Position = vec4(vertex_position, 0.f, 1.f);
}