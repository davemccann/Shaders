#version 330

uniform sampler2DRect sampler_world_position;
uniform sampler2DRect sampler_world_normal;
uniform sampler2DRect sampler_world_material;
uniform sampler2DRect sampler_world_shininess;
uniform sampler2DRect shadow_tex;

uniform bool cast_shadow;
uniform vec3 light_direction;
uniform float light_FOV;
uniform vec3 light_position;
uniform float light_range;
uniform vec3 camera_position;

uniform mat4 light_projection_view_xform;

out vec4 reflected_light;


vec4 spotLight(vec3 P, vec3 specular, vec3 Kd, float inner_fov, float outer_fov, vec3 texel_normal)
{
  vec3 L = (light_position - P);

  //Find distance to the light before normalizing
  float distToLight = length(L);

  L = normalize(L);
 
  vec3 light_dir = normalize(light_position - P);

  // Direction and spoteffect for dual cone smooth spotlight
  float cosDir = dot(L, -light_direction);
  float spotEffect = smoothstep(outer_fov, inner_fov, cosDir);
 
  //Distance attenuation
  float distanceAtten = smoothstep(light_range, 0.0f, distToLight);
 
  vec3 N = normalize(texel_normal);
 
  //Diffuse
  float diffuseLight = max(dot(N, L), 0.0f);
  vec3 diffuse = (diffuseLight * Kd) * 0.6f;

  //Bring it all together and return it.
  return vec4((diffuse + specular) * spotEffect * distanceAtten, 1.0f);
}

void main(void)
{
    vec3 texel_normal = texelFetch(sampler_world_normal, ivec2(gl_FragCoord.xy)).rgb;
	vec3 texel_position = texelFetch(sampler_world_position, ivec2(gl_FragCoord.xy)).rgb;
    vec3 texel_material = texelFetch(sampler_world_material, ivec2(gl_FragCoord.xy)).rgb;
    float texel_shininess = texelFetch(sampler_world_shininess, ivec2(gl_FragCoord.xy)).rgb;

	vec4 varying_texcoord = light_projection_view_xform * vec4(texel_position, 1.0f);

	vec3 P = texel_position;
	vec3 L = normalize(light_position - P);
    vec3 N = normalize(texel_normal);
	vec3 V = normalize(camera_position - P);
	vec3 Rv = normalize(reflect(-V, N));
    
    float outer_fov = cos(radians(light_FOV / 2));
    float inner_fov = cos(radians(light_FOV / 6));

	vec3 Ks = vec3(0.0f); //Specular colour plastic is white, otherwise material colour
    vec3 Kd = texel_material;

	vec3 specular = vec3(0.0f);

	//Shadow Mapping
	int count = 0;
    float shadowCoeff = 0.0f;
	if(cast_shadow);
	{
		float shadowing = 0.0f;

		vec2 xyOffset = vec2(1.0f) / textureSize(shadow_tex);
		float oneOverMapSize = 1.0f / textureSize(shadow_tex);

        float sum = 0;
        for (float y = -1.0f; y <= 1.0f; y += 0.5f)
        {
            for (float x = -1.0f; x <= 1.0f; x += 0.5f)
            {
				vec3 texcoord = 0.5 + 0.5 * varying_texcoord.xyz / varying_texcoord.w;
				vec2 pixelcoord = texcoord.xy * textureSize(shadow_tex);
				float depthVal = texelFetch(shadow_tex, ivec2(pixelcoord + vec2(x,y))).r;

		        shadowing += texcoord.z > depthVal ? 0.0f : 1.0f;
                ++count;
            }
        }

        shadowCoeff =  (shadowing / count);		
	}

		//Check if the light can cast shadows
		float visibility = 1.0f;

		if(cast_shadow)
            visibility = shadowCoeff;

		//Shininess/specular
		if(texel_shininess > 0)
		{
			float LDotR = (clamp(dot(L,Rv), 0.0, 1.0));
			Ks = Kd;
		
			float n = texel_shininess * 64;
			specular = Ks * pow(LDotR, n);
		}

	reflected_light = visibility * spotLight(P, specular, Kd, inner_fov, outer_fov, texel_normal);
}