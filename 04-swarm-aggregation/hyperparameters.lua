-- hyperparameters.lua

local hyperparameters = {}

-- Global State
hyperparameters.states = {
    WALK = "WALK",
    STOP = "STOP"
}

hyperparameters.MAX_VELOCITY = 15

STATE = hyperparameters.states.WALK

-- Aggregation parameters
hyperparameters.ALPHA = 0.1  -- stopping probability increase factor
hyperparameters.BETA = 0.05  -- walking probability decrease factor
hyperparameters.S = 0.01    -- spontaneous stopping event
hyperparameters.W = 0.1  -- spontaneous starting event
hyperparameters.PSMAX = 0.99 -- maximum stopping probability
hyperparameters.PWMIN = 0.005 -- minimum walking probability

hyperparameters.MAXRANGE = 30   -- maximum range for sensing other robots
hyperparameters.NTURNS = 10    -- number of turns to aggregate
hyperparameters.MAXSTEPS = 10  -- maximum number of steps

-- Proximity
hyperparameters.CLEAR_PATH_THRESHOLD = 0.3    -- Threshold for determining a clear path

-- Configuration
hyperparameters.CONFIG_FILE = "aggregation.argos"

-- Debugging
hyperparameters.DEBUG = false

return hyperparameters
