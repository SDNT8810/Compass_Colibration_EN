# Compass Calibration

Matlab code for a compass sensor calibration algorithm.

## Introduction
Magnetic field measurement sensors typically have three degrees of freedom in measurement. In other words, they measure the magnetic field in three orthogonal directions (Cartesian coordinate system). The square of the measured values with these sensors, in an ideal scenario, equals the Earth's magnetic field at the sensor's location. However, real-world measurements may deviate from this ideal scenario, and calibration is needed to account for these discrepancies.

This report introduces a process for calibrating magnetic field sensors.

## Data Collection and Data Refinement
To calibrate the sensor, an adequate amount of data collection is necessary, covering the sensor's workspace sufficiently. During data collection, the sensor is rotated at various angles, ensuring it covers all three-dimensional directions. Subsequent preprocessing is applied to the data, and a transformation matrix is computed. This matrix aligns the measured data onto a spherical surface with a radius equal to the magnetic field strength at the calibration location.

### Raw Sensor Data
If measurements are correctly performed, plotting the measured values in the three-dimensional coordinate system should depict an ellipsoid approximately. The center of this ellipsoid might not align with the coordinate system origin, and the three principal diameters of this ellipsoid can differ.

![Raw Sensor Data](https://github.com/SDNT8810/Compass_Colibration/assets/110291520/83ccbb68-e7d4-489d-8e74-96562d495066)

*Figure 2.1 Raw magnetic sensor data*

### Idealized Data
When using an ideal sensor and rotating it arbitrarily to cover all possible directions, the sampled data represents a sphere centered at the coordinate system origin with a radius equal to the magnetic field strength at the calibration location.

![Idealized Data](https://github.com/SDNT8810/Compass_Colibration/assets/110291520/48cce03b-5800-405c-b101-cead61a6ca0f)

*Figure 2.2 Idealized data from an ideal sensor*

## Computation of Transformation Matrix
To calculate the appropriate transformation matrix aligning sensor data with ideal sensor data, the 'magcal' function in Matlab is employed. This function maps the measured data with the sensor to a sphere around the coordinate origin. The radius of this sphere might not match the magnetic field strength. Therefore, by multiplying the Earth's magnetic field strength, calculated using the 'wrdmg' function, with the obtained sphere from the 'magcal' function and dividing it by the radius of the sphere from 'magcal,' the measured data is mapped onto the ideal sensor sphere.

These steps are applied to the data shown in Figure 2.2, resulting in the following:

![Calibrated Data](https://github.com/SDNT8810/Compass_Colibration/assets/110291520/b0c9de7c-d1cb-44ad-804f-ac6027c6cb17)

*Figure 2.3 Uncalibrated, calibrated, and ideal sensor data*

## Data Accuracy Assessment
To ensure the accuracy of the measurement process and data refinement, several conditions need to be verified.

### Coverage of the Surface
Histogram analysis on the mapped spherical surface is used to ensure coverage. The histogram, shown in Figure 3.1, indicates the distribution of measured data points on the mapped sphere.

![Histogram of Azimuth and Elevation Angles](https://github.com/SDNT8810/Compass_Colibration/assets/110291520/7dfe9cad-9ab2-42f7-961f-d01f499397f7)

*Figure 3.1 Azimuth and elevation angles histogram*

### Co-Radial Condition
All measured points on an ideal sensor should be on the surface of a sphere with a radius equal to the Earth's magnetic field strength at the measurement location. To assess this, the distribution of points in the radial direction is examined, as shown in Figure 3.2.

![Radial Histogram](https://github.com/SDNT8810/Compass_Colibration/assets/110291520/26f890bc-54f1-4b56-b073-bfbfb5707563)

*Figure 3.2 Radial direction histogram*
