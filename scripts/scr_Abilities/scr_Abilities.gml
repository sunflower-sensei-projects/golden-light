function load_ability_data() {
	global.ability_data = {
		// -- Other Actions
		stunned: {
			name: "Stunned",
			type: "none",
			element: "none",
			target_mode: "self",
			anim_user: "idle",
			impact_spr: undefined,
			sfx: undefined
		},
		// -- Physical attacks
		attack: {
			name: "Attack",
			type: "physical",
			element: "physical",
			damage_formula: function(_user, _target) {
				return floor((_user.attack_current * 1.0) - (_target.defense_current * 0.5))	
			},
			target_mode: "single_enemy",
			anim_user: "attack",
			impact_spr: undefined,
			sfx: sfx_hit
		},
		
		// -- Attacks from Artifact Weapons
		
		// -- Enemy abilities
	};
}