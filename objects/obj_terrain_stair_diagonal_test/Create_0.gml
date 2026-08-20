/// Create Event

x_bottom = x;        // world x of the BOTTOM/progress-0 end - set to
                      // wherever you place the instance for the bottom
                      // of the stair
x_top = x - 48;      // world x of the TOP/progress-1 end - adjust to
                      // match your actual staircase's horizontal span
                      // (negative offset here = stairs rising to the
                      // LEFT, matching your screenshot; use a positive
                      // offset instead if a specific stair rises to
                      // the right)
rise_dir_x = sign(x_top - x_bottom); // computed automatically, don't
                      // set this by hand - it's -1 for a left-rising
                      // stair (your screenshot), +1 for right-rising
z_level_bottom = 0;   // the z_level of the floor at the BOTTOM of this
                      // stair (top is always z_level_bottom + 1)