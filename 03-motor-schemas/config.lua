-- config.lua
local config = {
    CONFIG_FILE = os.getenv("ARGOS_CONFIG_FILE") or "motor_schemas.argos",
    VMAX = 15,
    -- Noise parameters
    NOISE_FACTOR = 1,
    -- Force parameters
    INITIAL_FORCE_INTENSITY = 5.5,
    MIN_FORCE_INTENSITY = 1.5,
    FORCE_DECAY_FACTOR = 0.9998,
    -- Time parameters
    TIMESTEP = 0.1,         -- Assuming 0.1 seconds per step, adjust as needed
    -- Past avoidance parameters
    MEMORY_STEPS = 10,      -- Number of steps to preserve in memory
    AVOIDANCE_RADIUS = 0.1, -- Radius for past avoidance
    -- Attraction/repulsion parameters
    LIGHT_THRESHOLD = 0.7,    -- Threshold for deciding when to switch to aggressive behavior
    -- Compound forces parameters
    AGGRESSIVE_INTENSITY_MULTIPLIER = 3, -- Multiplier to increase attraction force when being aggressive
    EXPLORE_INTENSITY_MULTIPLIER = 5,    -- Multiplier to increase attraction force when exploring
}

return config
