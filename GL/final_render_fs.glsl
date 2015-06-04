#version 330

uniform vec3 camera_position;
uniform vec3 material_colour;
uniform vec3 light_direction;
uniform float light_intensity = 1.f;

in vec3 varying_position;
in vec3 varying_normal;

out vec3 forward_out;

void main(void)
{    
	vec3 N = normalize(varying_normal);
	vec3 P = normalize(varying_position);

	float diffuse = clamp(dot(light_direction, N), 0.f, 1.f);

	vec3 Kd = material_colour;

	forward_out = ((Kd * diffuse) * light_intensity);
}