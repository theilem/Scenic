param map = localPath('../../../../tests/formats/opendrive/maps/CARLA/Town05.xodr')
param carla_map = 'Town05'
model scenic.simulators.carla.model

# Sample a lane at random
lane = Uniform(*network.lanes)

spot = OrientedPoint on lane.centerline

attrs = {"image_size_x": 640,
         "image_size_y": 480}

car_model = "vehicle.tesla.model3"

# Spawn car on that spot with logging autopilot behavior and
# - an RGB Camera pointing forward with specific attributes
# - a semantic segmentation sensor
ego = Car at spot,
    with blueprint car_model,
    with behavior AutopilotBehavior(),
    with sensors {"front_rgb": CarlaRGBSensor(offset=(1.6, 0, 1.7), attributes=attrs),
                  "front_ss": CarlaSSSensor(offset=(1.6, 0, 1.7), attributes=attrs)}

other = Car offset by 0 @ Range(10, 30),
    with behavior AutopilotBehavior()


monitor RecordingMonitor:
    RECORDING_START = 5
    SUBSAMPLE = 5
    # Exclude the first 5 steps because cars are spawned in the air and need to drop down first
    for _ in range(1, RECORDING_START):
        wait
    while True:
        ego.save_observations(localPath("data/generation"))
        for _ in range(SUBSAMPLE):
            wait