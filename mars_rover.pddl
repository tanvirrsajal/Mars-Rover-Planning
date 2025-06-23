(define (domain mars_rover)

    (:requirements :strips :typing :negative-preconditions)

    (:types
        robot location sensor
    )

    (:predicates
        (robotIsAt ?r - robot ?l - location) ; Indicates the robot's current location
        (path ?l1 ?l2 - location) ; Represents a path between two locations
        (sampleCollectedAt ?l - location ?s - sensor) ; Indicates that a sample is collected at a location by a sensor
        (secondSampleCollectedAt ?l - location ?s - sensor) ; Indicates that a second sample is collected at a location by a sensor
        (stable ?l - location) ; Indicates whether a location is stable
        (BaseStation ?l - location) ; Indicates the location of the base station
        (dataTransmitted) ; Indicates whether the data has been transmitted
        (communicationChannelFound) ; Indicates if a communication channel has been found
        (closeCommunicationchannel) ; Indicates if the communication channel is closed
        (instrumentDeployed ?l - location ?r - robot ?s - sensor) ; Indicates if an instrument is deployed at a location
        (dataProcessed ?l ?r ?s) ; Indicates if the data has been processed
        (dataStored ?l - location ?r - robot ?s - sensor) ; Indicates if the data has been stored
        (sensorActivated ?l - location ?r - robot ?s - sensor) ;; Indicates if the sensor is activated at a location
        (currentSensor ?s - sensor) ; Indicates the sensor currently being processed
        (processingComplete ?s - sensor) ; Indicates that processing of the sensor is complete
    )

    ;; Action for navigating the robot from one location to another
    (:action navigate
        :parameters (?from ?to - location ?r - robot)
        :precondition (and
            (path ?from ?to)
            (robotIsAt ?r ?from)
            (not (stable ?from))
        )
        :effect (and
            (robotIsAt ?r ?to) ; The robot is now at the destination location
            (not (robotIsAt ?r ?from)) ; The robot is no longer at the starting location
        )
    )

    ;; Action for stabilizing a location
    (:action stabilize
        :parameters (?r - robot ?l - location)
        :precondition (and
            (robotIsAt ?r ?l)
            (not (stable ?l))
        )
        :effect (and
            (stable ?l)
        )
    )

    ;; Action for deploying an instrument (sensor) at a location
    (:action deploy
        :parameters (?r - robot ?l - location ?s - sensor)
        :precondition (and
            (robotIsAt ?r ?l)
            (stable ?l)
            (not (currentSensor ?s)) ; The sensor must not be currently processed
            (not (exists (?s - sensor) (currentSensor ?s))) ; No other sensor should be currently processed
        )
        :effect (and
            (instrumentDeployed ?l ?r ?s) ; The instrument is deployed at the location
            (currentSensor ?s)
        )
    )

    ; Action for activating a sensor at a location
    (:action activate
        :parameters (?r - robot ?l - location ?s - sensor)
        :precondition (and
            (robotIsAt ?r ?l)
            (stable ?l)
            (instrumentDeployed ?l ?r ?s)
            (currentSensor ?s)
        )
        :effect (and
            (sensorActivated ?l ?r ?s) ; The sensor is activated at the location
        )
    )

    ; Action for collecting a sample using a sensor at a location
    (:action collect_sample
        :parameters (?r - robot ?l - location ?s - sensor)
        :precondition (and
            (robotIsAt ?r ?l)
            (stable ?l)
            (sensorActivated ?l ?r ?s) ; The sensor must be activated at the location
            (not (dataTransmitted))
            (currentSensor ?s)
        )
        :effect (and
            (sampleCollectedAt ?l ?s) ; The sample is collected at the location by the sensor
        )
    )

    ; Action for collecting a second sample using a sensor at a location
    (:action collect_sample_again
        :parameters (?r - robot ?l - location ?s - sensor)
        :precondition (and
            (robotIsAt ?r ?l)
            (sampleCollectedAt ?l ?s) ; The first sample must be collected at the location
            (not (secondSampleCollectedAt ?l ?s)) ; The second sample must not be collected yet
            (not (dataTransmitted))
            (currentSensor ?s)
        )
        :effect (and
            (secondSampleCollectedAt ?l ?s) ; The second sample is collected at the location by the sensor
        )
    )

    ; Action for processing the data collected by a sensor at a location
    (:action data_process
        :parameters (?r - robot ?l - location ?s - sensor)
        :precondition (and
            (robotIsAt ?r ?l)
            (stable ?l)
            (sampleCollectedAt ?l ?s)
            (sensorActivated ?l ?r ?s)
            (currentSensor ?s)
        )
        :effect (and 
            (dataProcessed ?l ?r ?s) ; The data is processed
        )
    )

    ; Action for storing the processed data
    (:action store_data
        :parameters (?r - robot ?l - location ?s - sensor)
        :precondition (and
            (robotIsAt ?r ?l)
            (dataProcessed ?l ?r ?s) ; The data must be processed
            (currentSensor ?s)
        )
        :effect (and
            (dataStored ?l ?r ?s) ; The data is stored
        )
    )

    ; Action for deactivating the sensor at a location
    (:action deactivate
        :parameters (?r - robot ?l - location ?s - sensor)
        :precondition (and
            (robotIsAt ?r ?l)
            (stable ?l)
            (sensorActivated ?l ?r ?s)
            (dataStored ?l ?r ?s) ; The data must be stored
            (currentSensor ?s)
        )
        :effect (and
            (not(sensorActivated ?l ?r ?s)) ;The sensor is deactivated
        )
    )

    ; Action for undeploying the instrument at a location
    (:action undeploy
        :parameters (?r - robot ?l - location ?s - sensor)
        :precondition (and
            (robotIsAt ?r ?l)
            (stable ?l)
            (not(sensorActivated ?l ?r ?s)) ; The sensor must not be activated
            (sampleCollectedAt ?l ?s) 
            (currentSensor ?s)
        )
        :effect (and
            (not (instrumentDeployed ?l ?r ?s)) ; The instrument is undeployed
            (processingComplete ?s) ; Processing of the sensor is complete
            (not(currentSensor ?s)) ; The sensor is no longer the current sensor
        )
    )

    ;; Action for destabilizing a location
    (:action destabilize
        :parameters (?r - robot ?l - location) 
        :precondition (and
            (robotIsAt ?r ?l)
            (stable ?l) ; The location must be stable
            (not(exists (?s - sensor)(instrumentDeployed ?l ?r ?s))) ; No instrument should be deployed at the location
        )
        :effect (and
            (not (stable ?l)) ; The location is no longer stable
        )
    )

    ; Action for waiting for a communication connection at the base station
    (:action wait_for_connection
        :parameters (?l - location ?r - robot)
        :precondition (and 
            (BaseStation ?l) ; The location must be the base station
            (not (dataTransmitted)) ; Data must not be transmitted yet
            (robotIsAt ?r ?l)
            (not (communicationChannelFound)) ; The communication channel must not be found yet
        )
        :effect (and
            (communicationChannelFound) ; The communication channel is found
        )
    )

    ; Action for sending data at the base station
    (:action send_data
        :parameters (?l - location ?r - robot)
        :precondition (and 
            (BaseStation ?l) ; The location must be the base station
            (not (dataTransmitted)) ; Data must not be transmitted yet
            (robotIsAt ?r ?l)
            (communicationChannelFound) ; The communication channel must be found
        )
        :effect (and
            (dataTransmitted) ; The data is transmitted
        )
    )

    ; Action for closing the communication channel at the base station
    (:action close_commmunication_channel
        :parameters (?l - location ?r - robot)
        :precondition (and 
            (BaseStation ?l)
            (dataTransmitted) ; Data must be transmitted
            (robotIsAt ?r ?l)
        )
        :effect (and
            (closeCommunicationchannel) ; The communication channel is closed
        )
    )

)

