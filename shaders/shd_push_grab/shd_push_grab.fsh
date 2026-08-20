// shd_push_grab — Fragment Shader
//
// A pulsing glow for whatever's currently grabbed by field-cast Push,
// active during pState.SORCERY_AIM (and, if you want the glow to
// persist through the slide, pState.SORCERY_RESOLVE too - your call,
// see the GML side notes in shd_push_grab_notes.md).
//
// Two effects layered together, both driven by u_time (a looping 0-1
// value you feed in from GML, NOT gm_Time directly, so pulse speed is
// controllable/tunable without touching this file):
//
//   1. A soft overall brightness pulse on the sprite itself (sin wave
//      on RGB, subtle) - reads as "this object is charged/highlighted"
//      even at a glance.
//   2. An edge/rim glow using alpha-gradient detection (samples
//      neighboring texels; where opaque pixels sit next to transparent
//      ones, that's an edge - brighten those specifically) - gives a
//      GBA-JRPG-style outline-glow without needing a second sprite,
//      separate outline texture, or SDF data. This is the same
//      "detect edges via alpha neighbor sampling" technique, just a
//      different visual target than shd_sorcery_outline's sine-wave
//      shimmer (which per your notes is for the CASTER's casting
//      state, not the target object - this shader is deliberately
//      simpler/steadier, since a grabbed object should read as
//      "held," not "actively casting").
//
// Uniforms (set from GML - see shd_push_grab_notes.md for exact calls):
//   u_time       (float) - 0-1 looping value, drives both pulses
//   u_tint       (vec3)  - glow color, RGB 0-1. Suggested default:
//                          a warm gold/white (1.0, 0.9, 0.6) to read as
//                          "psynergy energy" without implying a
//                          specific element - Push isn't
//                          elementally-flavored the way Ignite/Freeze
//                          are, per your Faefolk/elemental design notes,
//                          so this deliberately avoids reading as Fire
//                          or Earth-aligned.
//   u_glow_strength (float) - 0-1, overall intensity multiplier. Lets
//                          you fade the effect in/out at the start/end
//                          of the grab rather than having it snap on.

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform vec3  u_tint;
uniform float u_glow_strength;

void main() {
	vec4 base_color = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;

	// Texel size for neighbor sampling - GameMaker doesn't expose the
	// source texture's resolution directly in a portable way, so this
	// assumes a reasonably standard sprite texture page sample step.
	// If the glow edge looks too thick/thin once you see it on your
	// actual pillar sprite, this is the value to tune first.
	vec2 texel = vec2(1.0 / 256.0, 1.0 / 256.0);

	// --- Edge/rim detection ---
	// Sample the 4 cardinal neighbors' alpha. If this pixel is opaque
	// but any neighbor is significantly more transparent, we're on an
	// edge - accumulate how "edge-y" this pixel is.
	float a_up    = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.0, -texel.y)).a;
	float a_down  = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.0,  texel.y)).a;
	float a_left  = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-texel.x, 0.0)).a;
	float a_right = texture2D(gm_BaseTexture, v_vTexcoord + vec2( texel.x, 0.0)).a;

	float edge = 0.0;
	if (base_color.a > 0.5) {
		edge = max(edge, base_color.a - a_up);
		edge = max(edge, base_color.a - a_down);
		edge = max(edge, base_color.a - a_left);
		edge = max(edge, base_color.a - a_right);
	}
	edge = clamp(edge, 0.0, 1.0);

	// --- Pulse ---
	// Two sine waves at different speeds/phases so the pulse reads as
	// slightly organic rather than a metronomic blink - a single sine
	// wave on a small pixel-art sprite can look distractingly robotic.
	float pulse_a = (sin(u_time * 6.28318) + 1.0) * 0.5;        // one full cycle per u_time loop
	float pulse_b = (sin(u_time * 6.28318 * 1.7 + 1.0) + 1.0) * 0.5; // faster, offset phase
	float pulse = mix(pulse_a, pulse_b, 0.5);
	float pulse_intensity = 0.4 + (pulse * 0.6); // never fully off, ranges ~0.4-1.0

	// --- Combine ---
	// Rim glow: additive tint on edge pixels, scaled by pulse and
	// overall strength.
	vec3 rim_glow = u_tint * edge * pulse_intensity * u_glow_strength;

	// Overall body pulse: much subtler additive brighten across the
	// whole sprite, not just the edge, so the object doesn't look like
	// ONLY its outline is affected.
	vec3 body_glow = u_tint * 0.15 * pulse_intensity * u_glow_strength;

	vec3 final_rgb = base_color.rgb + rim_glow + body_glow;

	gl_FragColor = vec4(final_rgb, base_color.a);
}
