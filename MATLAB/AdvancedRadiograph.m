classdef AdvancedRadiograph < matlab.mixin.SetGetExactNames & matlab.mixin.CustomDisplay
    % Advanced Radiograph class
    properties (Constant)
        object_type = "radiograph";
        radiograph_type = "advanced";
    end
    properties
        image(:,:) {mustBeNumeric}
        X(:,:) {mustBeNumeric}
        Y(:,:) {mustBeNumeric}
        T(:,:) double
        
        pradformat_version string = pradformat_version()
        scale_factor double
        pixel_width double
        pixel_width_ax2 double
        source_object_dist double
        object_image_dist double
        source_radius double
        spec_name string
        spec_mass double
        spec_charge double
        spec_energy double
        label string
        description string
        experiment_date string
        file_date string = datestr(datetime('now'), 'yyyy-mm-dd')
        raw_data_filename string
        
        sensitivities cell
    end
    properties (Hidden)
        % Categorize the above public properties as required or optional
        req_ds = ["image"]; % Required datasets
        opt_ds = ["X", "Y", "T"]; % Optional datasets
        req_atts = [...  % Required attributes
            "object_type", ...
            "radiograph_type", ...
            "pradformat_version", ...
            "pixel_width", ...
            ];
        opt_atts = [...  % Optional attributes
            "pixel_width_ax2", ...
            "source_object_dist", ...
            "object_image_dist", ...
            "source_radius", ...
            "label", ...
            "description", ...
            "experiment_date", ...
            "file_date", ...
            "raw_data_filename", ...
            ];
        % List for a second time any above properties that are constants
        % of the class (and are not to be overwritten when reading from file)
        const_atts = ["object_type", "radiograph_type"];
    end
    methods (Access = protected)
        function propgrps = getPropertyGroups(obj)
            % Customized pretty printing of object
            propgrp1 = matlab.mixin.util.PropertyGroup(cellstr(obj.req_ds), 'Datasets (Required)');
            propgrp2 = matlab.mixin.util.PropertyGroup(cellstr(obj.opt_ds), 'Datasets (Optional)');
            propgrp3 = matlab.mixin.util.PropertyGroup(cellstr(obj.req_atts), 'Attributes (Required)');
            propgrp4 = matlab.mixin.util.PropertyGroup(cellstr(obj.opt_atts), 'Attributes (Optional)');
            propgrp5 = matlab.mixin.util.PropertyGroup(cellstr(["sensitivities"]), 'Sensitivity Groups (Optional)');
            propgrps = [propgrp1 propgrp2 propgrp3 propgrp4 propgrp5];
        end
        function validate(obj)
            % Validate that all required properties have been set.
            % If some are not, throw an error.
            for i=1:length(obj.req_ds)
                ds = obj.req_ds(i);
                if isempty(get(obj, char(ds)))
                    error(['Please assign a value to all required properties.' newline 'The following required dataset property is not yet assigned: "' char(ds) '".' newline 'Assign a value via "object.' char(ds) ' = value" and try again.'])
                end
            end           
            for i=1:length(obj.req_atts)
                att = obj.req_atts(i);
                if isempty(get(obj, char(att)))
                    error(['Please assign a value to all required properties.' newline 'The following required attribute property is not yet assigned: "' char(att) '". ' newline 'Assign a value via "object.' char(att) ' = value" and try again.'])
                end
            end
        end
    end
    methods
        function obj = AdvancedRadiograph(h5filename)
            % Constructor method - load object from file
            if nargin == 1
                % Load in the prad object from h5filename
                load_prad_group(obj, h5filename, '/')
                for i=1:100000
                    h5root = sprintf('/sensitivity%d', i);
                    try
                        h5info(h5filename, h5root) % will return error if h5root location does not exist
                    catch
                        break
                    end
                    obj.sensitivities{i} = Sensitivity;
                    load_prad_group(obj.sensitivities{i}, h5filename, h5root)
                end
            end
        end
        function prad_save(obj, h5filename)
            % Saves Simple Radiograph object to HDF5 file
            obj.validate();
            
            % Delete any existing file
            if (exist(h5filename, 'file') == 2)
                delete(h5filename);
                if (exist(h5filename, 'file') == 2)
                    error(['The existing HDF5 file: "' h5filename '" could not be overwritten.' newline 'Perhaps you do not have permissions to delete this file.' newline 'For example, perhaps the file is open and being read by another program, like HDFView? If so, close the file in that program.' newline 'Or, perhaps this file handle is currently open in MATLAB? Try the command fclose(''all'') to close all current file handles.' newline 'If all else fails, try manually deleting the file in question, or change your desired output filename to something else.' newline 'Once you''re done troubleshooting, run your script again.']);
                end
            end
            
            % Create new file and save object into it
            save_prad_group(obj, h5filename, '/')
            for i=1:numel(obj.sensitivities)
                h5root = sprintf('/sensitivity%d', i);
                save_prad_group(obj.sensitivities{i}, h5filename, h5root)
            end
        end
    end
end
