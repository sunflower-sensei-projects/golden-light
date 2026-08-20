lifetime--;
self.y -= rise_spd;
rise_spd = max(0.2, rise_spd - 0.04); // Decelerates as it rises

// Fade out in the last 20 frames
if (lifetime < 20) alpha = lifetime / 20;

if (lifetime <= 0) instance_destroy(self);