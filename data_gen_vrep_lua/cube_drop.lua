-- This is a non-threaded child script associated with the cube to be dropped in V-REP.

-- the first if-end block - called "initialization part" is run only once.  
if (sim_call_type==sim_childscriptcall_initialization) then
    handle=simGetObjectHandle('Cuboid') -- handle to the cube we are going to drop

    -- files to write initial and final quaternions of the cube to
    -- TODO pwd using debug.info not working in vrep, hence hardcoded 
    init_quat=io.open("/home/ratneshmadaan/projects/riss_bingham/data/cuboid/20160711/init_quat.csv", "w")
    final_quat=io.open("/home/ratneshmadaan/projects/riss_bingham/data/cuboid/20160711/final_quat.csv", "w")

    -- helper variables to track the start and end of one trial (one trial = dropping the cube from a random initial orientation till it is resting on the floor)
    count = 0
    no_of_trials = 6000       -- no of times to drop the cube / no of data points
    timesteps_per_trial = 100 -- no of simulation timesteps we run each trial for (ensure duration of simulation timestep is default)
                              -- (this is hardcoded and might have to changed for a different experiment, depending on height or the type of solid used)
                              -- a simple way to find a good timestep_per_trial is to just uncomment the "print count" line in the next if block 
                              -- and look at the ubuntu terminal 
    threshold_init_quat = timesteps_per_trial*(no_of_trials+1) -- timesteps till which we note the initial orientation of the cube 
    -- (+1 as we'll discard the last time we set the orientation of the cube.
    threshold_final_quat = timesteps_per_trial*no_of_trials    -- timesteps till which we note the final orientation of the cube
    height_min = 0.4 -- min height from which cube is dropped. it varied from [height_min, heigh_min + 1] (height_const+math.random())
    r2a = 180/math.pi
end

-- this if-end block is run at each simulation time step. Now, we have to note down the final pose of the cube in the beginning and set the pose at the end of each trial, 
-- where again each trial is basically a data point - setting the cube to random orientation and droppping it. 
-- Recall that each trial's duration will be timesteps_per_trial.

-- We note the pose in the beginning of each iteration of the "trial loop", and set the cube's pose at the end of trial loop  
-- Hence, two catches - the first loop of the trial, we don't use the final_pose, as the value returned by simGetObjectQuaternion or simGetObjectPosition will be just the 
-- default position of the cube (set by the scene).
-- Secondly, we throwaway the last orientation (pose) we set using simSetObjectOrientation/Position as we stop the simulation j.

if (sim_call_type==sim_childscriptcall_actuation) then
    -- print count -- for choosing a good value of (hardcoded) timesteps_per_trial 

    -- Now, we want to end the simulation after no_of_trials time we drop the cube
    if count < threshold_init_quat then 
        -- get the pose of the cube via vrep api
        local position=simGetObjectPosition(handle,-1) 
        local quaternion=simGetObjectQuaternion(handle,-1)  
        local orientation=simGetObjectOrientation(handle, -1)

        if (count%timesteps_per_trial==0) then
			
			if count ~= 0 then 
                -- no final pose written at the beginning of the simulation 
               final_quat:write(count/timesteps_per_trial, ",", quaternion[4], ",", quaternion[1], ",", quaternion[2], ",", quaternion[3], "\n")
            end
   
            -- x, y position is (0,1), z is (height_const, height_const+1)
            position[1] =  math.random() 
            position[2] =  math.random()
            position[3] =  height_const+math.random()

            --because setting random orientation via euler angles is easier than setting it via random quaternions
            -- TODO read from sample quats' csv from a uniform bing 
            orientation[1] =  math.random(-180,180)*math.pi/180.0
            orientation[2] =  math.random(-180,180)*math.pi/180.0
            orientation[3] =  math.random(-180,180)*math.pi/180.0

            -- set the cube's initial pose 
            simSetObjectPosition(handle,-1,position)
            simSetObjectOrientation(handle,-1,orientation)

            -- get the corresponding quat from api (and avoid converting heh)
            quat_get = simGetObjectQuaternion(handle, -1)

            -- last value of initial_quat is garbage
            if count < threshold_final_quat then
                init_quat:write(count/timesteps_per_trial,",", quat_get[4], ",", quat_get[1], ",", quat_get[2], ",", quat_get[3], "\n")
			end               
        end
        count = count+1
    end
end


if (sim_call_type==sim_childscriptcall_sensing) then
-- Put your main SENSING code here
end

if (sim_call_type==sim_childscriptcall_cleanup) then
-- Put some restoration code here
end