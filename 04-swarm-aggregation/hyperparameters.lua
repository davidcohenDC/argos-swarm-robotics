local hyperparameters = {}

-- Global State
hyperparameters.states = {
    WALK = "WALK",
    STOP = "STOP"
}

hyperparameters.MAX_VELOCITY = tonumber(os.getenv("MAX_VELOCITY")) or 15

STATE = hyperparameters.states.WALK

-- Aggregation parameters
hyperparameters.ALPHA = tonumber(os.getenv("ALPHA")) or 0.1  -- stopping probability increase factor
hyperparameters.BETA = tonumber(os.getenv("BETA")) or 0.05  -- walking probability decrease factor
hyperparameters.S = tonumber(os.getenv("S")) or 0.01    -- spontaneous stopping event
hyperparameters.W = tonumber(os.getenv("W")) or 0.1  -- spontaneous starting event
hyperparameters.PSMAX = tonumber(os.getenv("PSMAX")) or 0.99 -- maximum stopping probability
hyperparameters.PWMIN = tonumber(os.getenv("PWMIN")) or 0.005 -- minimum walking probability

hyperparameters.MAXRANGE = tonumber(os.getenv("MAXRANGE")) or 30   -- maximum range for sensing other robots
hyperparameters.NTURNS = tonumber(os.getenv("NTURNS")) or 10    -- number of turns to aggregate
hyperparameters.MAXSTEPS = tonumber(os.getenv("MAXSTEPS")) or 10  -- maximum number of steps

-- Proximity
hyperparameters.CLEAR_PATH_THRESHOLD = tonumber(os.getenv("CLEAR_PATH_THRESHOLD")) or 0.3    -- Threshold for determining a clear path

-- Configuration
hyperparameters.CONFIG_FILE = os.getenv("CONFIG_FILE") or "aggregation.argos"

-- Debugging
hyperparameters.DEBUG = os.getenv("DEBUG") == "true" or false

return hyperparameters
