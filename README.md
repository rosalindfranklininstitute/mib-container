# mib-container
A container for Microscopy Image Browser (MIB) https://mib.helsinki.fi/index.html

## Licences

By using this container, you agree to the following licenses:

- [Matlab Runtime License](/matlabruntime_license_agreement.pdf)

- [MIB external licences](https://mib.helsinki.fi/license_external.html)

- [MIB licence files](https://github.com/Ajaxels/MIB2/tree/master/licenses)


## How to use 
Please check out the latest releases at https://quay.io/repository/rosalindfranklininstitute/mib-container:

To use with apptainer, please use the following command:

`apptainer run --nv docker://quay.io/rosalindfranklininstitute/mib-container`

To use with docker, please use the following command:

`docker run quay.io/rosalindfranklininstitute/mib-container`

### Paths to SAM2 (https://github.com/facebookresearch/sam2)

The paths to use for SAM2 are:

- Python Installation Path: `/opt/sam4mib/bin/python3.12` 
- Path to Segment Anything 2 Installation: `/opt/sam4mib/lib/python3.12/site-packages/` 