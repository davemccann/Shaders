#version 330

uniform mat4 combined_xform;
uniform mat4 model_xform;

in vec3 vertex_position;
in vec3 vertex_normal;

void main(void)
{
	gl_Position = combined_xform * vec4(vertex_position, 1.0f);
}