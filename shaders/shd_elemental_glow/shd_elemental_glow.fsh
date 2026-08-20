//
// Fragment Shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 u_tint;
uniform float u_glow;

void main()
{
    vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
    vec3 tinted = base.rgb * u_tint * (1.0 + u_glow * 1.5);
    gl_FragColor = vec4(tinted, base.a) * v_vColour;
}