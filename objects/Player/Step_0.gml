/// @description Movement

script_execute(scr_Player_Input);
script_execute(scr_Player_State_Machine);
scr_update_z_layers(z_level);
script_execute(scr_Player_Move);
scr_Player_Diagonal_Stair_Check();
script_execute(scr_Player_Animate);