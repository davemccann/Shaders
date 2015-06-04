#version 330

// FXAA shader, GLSL code adapted from:
// http://horde3d.org/wiki/index.php5?title=Shading_Technique_-_FXAA
// Whitepaper describing the technique:
// http://developer.download.nvidia.com/assets/gamedev/files/sdk/11/FXAA_WhitePaper.pdf

uniform sampler2DRect texture_sampler;

// The inverse of the texture dimensions along X and Y
//iform vec2 texcoord_offset;

out vec4 fragment_out;

void main() {
  // The parameters are hardcoded for now, but could be
  // made into uniforms to control fromt he program.
  float FXAA_SPAN_MAX = 8.0;
  float FXAA_REDUCE_MUL = 1.0/8.0;
  float FXAA_REDUCE_MIN = (1.0/128.0);

  vec3 rgbNW = texelFetch(texture_sampler, ivec2(gl_FragCoord.xy + (vec2(-1.0, -1.0)))).xyz;
  vec3 rgbNE = texelFetch(texture_sampler, ivec2(gl_FragCoord.xy + (vec2(+1.0, -1.0)))).xyz;
  vec3 rgbSW = texelFetch(texture_sampler, ivec2(gl_FragCoord.xy + (vec2(-1.0, +1.0)))).xyz;
  vec3 rgbSE = texelFetch(texture_sampler, ivec2(gl_FragCoord.xy + (vec2(+1.0, +1.0)))).xyz;
  vec3 rgbM  = texelFetch(texture_sampler, ivec2(gl_FragCoord.xy)).xyz;
	
  vec3 luma = vec3(0.299, 0.587, 0.114);
  float lumaNW = dot(rgbNW, luma);
  float lumaNE = dot(rgbNE, luma);
  float lumaSW = dot(rgbSW, luma);
  float lumaSE = dot(rgbSE, luma);
  float lumaM  = dot( rgbM, luma);
	
  float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
  float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
	
  vec2 dir;
  dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
  dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
	
  float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
	  
  float rcpDirMin = 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);
	
  dir = min(vec2(FXAA_SPAN_MAX,  FXAA_SPAN_MAX), 
        max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), dir * rcpDirMin));
		
  vec3 rgbA = (1.0/2.0) * (
              texelFetch(texture_sampler, ivec2(gl_FragCoord.xy + dir * (1.0/3.0 - 0.5))).xyz +
              texelFetch(texture_sampler, ivec2(gl_FragCoord.xy + dir * (2.0/3.0 - 0.5))).xyz);
  vec3 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (
              texelFetch(texture_sampler, ivec2(gl_FragCoord.xy + dir * (0.0/3.0 - 0.5))).xyz +
              texelFetch(texture_sampler, ivec2(gl_FragCoord.xy + dir * (3.0/3.0 - 0.5))).xyz);
  float lumaB = dot(rgbB, luma);

  vec4 final_frag = vec4(1.0f); //debug white

  if((lumaB < lumaMin) || (lumaB > lumaMax)){
    fragment_out.xyz=rgbA;
  } else {
    fragment_out.xyz=rgbB;
  }
  fragment_out.a = 1.0;
    
  //fragment_out = final_frag;
}