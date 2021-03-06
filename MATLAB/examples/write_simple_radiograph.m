% write_simple_radiograph.m: A template for writing your own Simple Radiographs

%% Construct object
rad = SimpleRadiograph;

%% Set datasets and attributes
M = 800; % image first dimension
N = 600; % image second dimension

rad.image = zeros(M, N); % required | Radiograph image (cropped and rotated, if desired) | pixel count
% rad.X = zeros(M, N); % optional | X position of pixel centers (radiograph coordinate system*) | meters
% rad.Y = zeros(M, N); % optional | Y position of pixel centers (radiograph coordinate system*) | meters
% rad.T = zeros(3,3); % optional | Change-of-basis matrix (a.k.a. transition matrix) to move from x, y, z radiograph coordinate system* to x', y', z' global coordinate system of the target chamber. [x' y' z'] = T [x y z].

% disp(rad.object_type) % already-set | Specification of the HDF5 object type | "radiograph" (always this value)
% disp(rad.radiograph_type) % already-set | Specification of the radiograph sub-type | "simple" (always this value)
% disp(rad.pradformat_version) % already-set | HDF5 pradformat file format version followed | e.g. "0.1.0"

rad.scale_factor = 1.0; % required | Multiplier to convert pixel counts into particle counts | particles/pixel count
rad.pixel_width = 100.0e-6; % required | Physical pixel width / bin width, for the first image axis | meters
% rad.pixel_width_ax2 = 25.0e-6; % optional | Physical pixel width / bin width, for the second image axis (not needed if using square pixels) | meters
rad.source_object_dist = 0.11; % optional | Approximate distance from the particle source to the object plane (the E & M structures). Used to estimate image magnification. | meters
rad.object_image_dist = 1.45; % optional | Approximate distance from the object plane (the E & M structures) to the image plane (the radiograph). Used to estimate image magnification. | meters
rad.source_radius = 80.0e-6; % optional | Approximate characteristic radius of the particle source (set as zero for a point source). Helpful in estimating image resolution. | meters
rad.spec_name = "p+"; % optional | Shortname for the particle species**
rad.spec_mass = 1.67262e-27; % optional | Particle mass | kg
rad.spec_charge = 1.6021766208e-19; % optional | Particle charge | Coulombs
rad.spec_energy = 14.7e6; % optional | Particle energy | eV

rad.label = "Shot5_CR39_Layer2"; % optional | Short, identifying label for this file (with no spaces or crazy characters). This can be stamped onto plots, etc.
rad.description = "Bottom CR39, for 14.7 MeV protons, on shot number 5 at NIF 2021 DISC."; % optional | Longer description of this file. This can be read by people trying to figure out where this file came from.
% rad.experiment_date = "2021-02-29"; % optional | Date of the experiment (or synthetic particle tracing), in the format "YYYY-MM-DD".
% disp(rad.file_date); % automatically-set | Date the (future) file will be created, in the format "YYYY-MM-DD" | You don't need to set this, it will be set automatically
rad.raw_data_filename = "20210231_scan_MIT.csv"; % optional | Filename of the raw data file (e.g. CSV from MIT) from which this derivative file was created, if applicable.

%% Pretty print your newly-minted radiograph object
disp(rad)

%% Save to file
[status, msg, msgID] = mkdir('outs');
h5filename = fullfile('outs', 'myradiograph.h5');
prad_save(rad, h5filename);

%%  Asterixed footnotes referenced above:
%
%  * The convention of this format is that the image lies in the z=0 plane of the radiograph coordinate system, and that the z-axis will point towards the particle source. The image may be stored already cropped and rotated by any angle within the x-y radiograph coordinate system, which is why X and Y are specified as arrays rather than vectors.
%
%  ** For best compatibility, consider using the PlasmaPy particle symbol conventions. https://docs.plasmapy.org/en/stable/api/plasmapy.particles.particle_symbol.html
%     For example, protons can be specified as just "p+", and electrons by "e-". Any arbitrary isotope of Hydrogen can be specified "H-I q+"? where I is the mass number and q is the charge.
%