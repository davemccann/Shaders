#version 330

uniform vec3 camera_position;
uniform vec3 material_colour;
uniform float material_shininess;
uniform samplerCube environment_map;

in vec3 varying_position;
in vec3 varying_normal;

out vec3 gbuffer_varying_position;
out vec3 gbuffer_varying_normal;
out vec3 gbuffer_material_colour;
out float gbuffer_material_shininess; 

//Used to return vec3 of environment map
vec3 reflection()
{
    //I and R do not need normalizing because reflected ray will intersect cube map
    vec3 I = varying_position - camera_position;
    vec3 N = normalize(varying_normal);
    vec3 R = reflect(I, N);

    vec3 reflectedColour = texture(environment_map, R).rgb;

    //use base colour (material_colour) and lerp
    //reflectivity between 0 and 1 - using material_shininess for this
    return mix(material_colour, reflectedColour, material_shininess);
}

void main(void)
{
	gbuffer_varying_position = varying_position;
	gbuffer_varying_normal = varying_normal;
	gbuffer_material_colour = material_shininess > 0.5f ? reflection() : material_colour;
	gbuffer_material_shininess = material_shininess;
}