;BFWS--FF-parser version(https://editor.planning.domains/#) solver was used to find the path plan
(define (problem mars_rover_problem) (:domain mars_rover)
(:objects 
    base loc1 loc2 loc3 loc4 - location 
    r - robot 
    camera imu spectometer radar - sensor
)

(:init
    ; Initial setup of the environment.

    (robotIsAt r base)
    (path loc1 loc2)
    (path loc2 loc1)

    (path loc2 loc3)
    (path loc3 loc2)

    (path loc3 loc4)
    (path loc4 loc3)
    
    (path base loc1)
    (path loc1 base)

    (BaseStation base)    
)

(:goal (and
    ;goal for the robot to move

    (robotIsAt r base)
    (sampleCollectedAt loc1 camera)
    (sampleCollectedAt loc1 spectometer)

    (secondSampleCollectedAt loc2 camera)


    (sampleCollectedAt loc3 camera)
    (sampleCollectedAt loc3 imu)

    (sampleCollectedAt loc4 radar)
    (sampleCollectedAt loc4 spectometer)

    (dataTransmitted)
    (closeCommunicationchannel)
))

)
