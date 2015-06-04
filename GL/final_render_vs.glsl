#version 330

uniform mat4 combined_xform;
uniform mat4 model_xform;

in vec3 vertex_position;
in vec3 vertex_normal;

out vec3 varying_position;
out vec3 varying_normal;

void main(void)
{
	varying_normal = mat3(model_xform) * vertex_normal;
	varying_position = mat4x3(model_xform) * vec4(vertex_position, 1.f);
	gl_Position = combined_xform * vec4(vertex_position, 1.0f);
}