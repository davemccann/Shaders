#version 330

uniform sampler2DRect sampler_world_position;
uniform sampler2DRect sampler_world_normal;
uniform sampler2DRect sampler_world_material;
uniform sampler2DRect sampler_world_shininess;

uniform vec3 light_direction;
uniform float light_intensity = 0.45f;

out vec3 reflected_light;

void main(void)
{
	vec3 texel_normal = texelFetch(sampler_world_normal, ivec2(gl_FragCoord.xy)).rgb;
	vec3 texel_position = texelFetch(sampler_world_position, ivec2(gl_FragCoord.xy)).rgb;
    vec3 texel_material = texelFetch(sampler_world_material, ivec2(gl_FragCoord.xy)).rgb;
    //float texel_shininess = texelFetch(sampler_world_material, ivec2(gl_FragCoord.xy)).rgb;

	vec3 N = normalize(texel_normal);
	vec3 P = normalize(texel_position);

	float diffuse = clamp(dot(light_direction, N), 0.f, 1.f);

	vec3 Kd = texel_material;

	reflected_light = ((Kd * diffuse) * light_intensity); //(Kd * diffuse * vec3(1.f)) * light_intensity;
}

