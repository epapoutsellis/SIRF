classdef ImageData < mSTIR.DataContainer
% Class for PET image data objects.

% CCP PETMR Synergistic Image Reconstruction Framework (SIRF).
% Copyright 2015 - 2017 Rutherford Appleton Laboratory STFC.
% 
% This is software developed for the Collaborative Computational
% Project in Positron Emission Tomography and Magnetic Resonance imaging
% (http://www.ccppetmr.ac.uk/).
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% http://www.apache.org/licenses/LICENSE-2.0
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

    properties
        name
        %handle
        rimsize
    end
    methods(Static)
        function obj = same_object()
            obj = mSTIR.ImageData();
        end
    end
    methods
        function self = ImageData(filename)
            % Creates an ImageData object. 
            % The optional argument is the name of an Interfile containing
            % image data.
            % If no argument given, the object remains empty, and needs to
            % be defined by its initialise() method before it can be used.
            self.name = 'ImageData';
            if nargin < 1
                self.handle = [];
            else
                self.handle = calllib...
                    ('mstir', 'mSTIR_objectFromFile', 'Image', filename);
                mUtilities.check_status('ImageData', self.handle)
            end
            self.rimsize = -1;
        end
        function delete(self)
            if ~isempty(self.handle)
                %calllib('mutilities', 'mDeleteDataHandle', self.handle)
                mUtilities.delete(self.handle)
                self.handle = [];
            end
        end
        function initialise(self,...
                arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
%***SIRF*** Sets this image size in voxels, voxel sizes in mm and the origin.
%         All arguments except the first one are optional.
%         Present arguments are either all scalars or all 3-component arrays.
%         The first array argument or three scalar arguments set the image
%         sizes in voxels.
%         The second array argument or three scalar arguments set the voxel
%         sizes in mm (if absent, sizes default to (1,1,1)).
%         The third array argument or three scalar arguments set the origin
%         (if absent, defaults to (0,0,0)).
            vsize = [1 1 1];
            origin = [0 0 0];
            if max(size(arg1)) == 1
                dim = [arg1 arg2 arg3];
                if nargin > 4
                    vsize = [arg4 arg5 arg6];
                    if nargin > 7
                        origin = [arg7, arg8, arg9];
                    end
                end
            else
                dim = arg1;
                if nargin > 2
                    vsize = arg2;
                    if nargin > 3
                        origin = arg3;
                    end
                end
            end
            if ~isempty(self.handle)
                %calllib('mutilities', 'mDeleteDataHandle', self.handle)
                mUtilities.delete(self.handle)
            end
            voxels = calllib('mstir', 'mSTIR_voxels3DF',...
                dim(1), dim(2), dim(3),...
                vsize(1), vsize(2), vsize(3),...
                origin(1), origin(2), origin(3));
            mUtilities.check_status('ImageData:initialise', voxels)
            self.handle = calllib('mstir', 'mSTIR_imageFromVoxels', voxels);
            mUtilities.check_status('ImageData:initialise', self.handle)
            mUtilities.delete(voxels)
            %calllib('mutilities', 'mDeleteDataHandle', voxels)
        end
        function fill(self, value)
%***SIRF*** Sets this image values at voxels.
%         The argument is either 3D array of values or a scalar to be
%         assigned at each voxel.
            if numel(value) == 1
                h = calllib('mstir', 'mSTIR_fillImage', ...
                    self.handle, single(value));
            else
                if isa(value, 'single')
                    ptr_v = libpointer('singlePtr', value);
                else
                    ptr_v = libpointer('singlePtr', single(value));
                end
                h = calllib('mstir', 'mSTIR_setImageData', self.handle, ptr_v);
            end
            mUtilities.check_status('ImageData:fill', h)
            mUtilities.delete(h)
            %calllib('mutilities', 'mDeleteDataHandle', h)
        end
        function image = clone(self)
%***SIRF*** Creates a copy of this image.
            image = mSTIR.ImageData();
            image.handle = calllib('mstir', 'mSTIR_imageFromImage',...
                self.handle);
            mUtilities.check_status('ImageData:clone', self.handle)
        end
        function image = get_uniform_copy(self, value)
%***SIRF*** Creates a copy of this image filled with the specified value.
            if nargin < 2
                value = 1.0;
            end
            image = mSTIR.ImageData();
            image.handle = calllib('mstir', 'mSTIR_imageFromImage',...
                self.handle);
            mUtilities.check_status('ImageData:get_uniform_copy', self.handle)
            image.fill(value)
        end
        function read_from_file(self, filename)
%***SIRF*** Reads the image data from a file.
            if ~isempty(self.handle)
                %calllib('mutilities', 'mDeleteDataHandle', self.handle)
                mUtilities.delete(self.handle)
            end
            self.handle = calllib...
                ('mstir', 'mSTIR_objectFromFile', 'Image', filename);
            mUtilities.check_status('ImageData:read_from_file', self.handle);
        end
        function write(self, filename)
            h = calllib('mstir', 'mSTIR_writeImage', self.handle, filename);
            mUtilities.check_status('ImageData:write', h);
            mUtilities.delete(h)
            %calllib('mutilities', 'mDeleteDataHandle', h)
        end
        function add_shape(self, shape, add)
%***SIRF*** Adds a uniform shape to the image. 
%         The image values at voxels inside the added shape are increased 
%         by the value of the last argument.
            if isempty(self.handle)
                error('ImageData:error', 'cannot add shapes to uninitialised image');
            end
            h = calllib...
                ('mstir', 'mSTIR_addShape', self.handle,...
                shape.handle, add);
            mUtilities.check_status('ImageData:add_shape', h);
            mUtilities.delete(h)
            %calllib('mutilities', 'mDeleteDataHandle', h)
        end
%         function diff = diff_from(self, image)
% %***SIRF*** Returns the relative difference between self and the image
% %         specified by the last argument, i.e. the maximal difference at
% %         voxels of common containing box divided by the maximum value
% %         of self.
%             h = calllib('mstir', 'mSTIR_imagesDifference',...
%                      self.handle, image.handle, self.rimsize);
%             mUtilities.check_status('ImageData:diff_from', h);
%             diff = calllib('mutilities', 'mFloatDataFromHandle', h);
%             calllib('mutilities', 'mDeleteDataHandle', h)
%         end
        function data = as_array(self)
%***SIRF*** Returns 3D array of this image values at voxels.

%             [ptr, dim] = calllib...
%                 ('mstir', 'mSTIR_getImageDimensions', self.handle, zeros(3, 1));
            ptr_i = libpointer('int32Ptr', zeros(3, 1));
            h = calllib...
                ('mstir', 'mSTIR_getImageDimensions', self.handle, ptr_i);
            mUtilities.check_status('ImageData:as_array', h);
            mUtilities.delete(h)
            %calllib('mutilities', 'mDeleteDataHandle', h)
            dim = ptr_i.Value;
            n = dim(1)*dim(2)*dim(3);
%             [ptr, data] = calllib...
%                 ('mstir', 'mSTIR_getImageData', self.handle, zeros(n, 1));
%             data = reshape(data, dim(3), dim(2), dim(1));
            ptr_v = libpointer('singlePtr', zeros(n, 1));
            h = calllib...
                ('mstir', 'mSTIR_getImageData', self.handle, ptr_v);
            mUtilities.check_status('ImageData:as_array', h);
            mUtilities.delete(h)
            %calllib('mutilities', 'mDeleteDataHandle', h)
            data = reshape(ptr_v.Value, dim(3), dim(2), dim(1));
        end
        function show(self)
%***SIRF*** Interactively plots this image data as a set of 2D image slices.
            data = self.as_array();
            shape = size(data);
            nz = shape(3);
            if nz < 1
                return
            end
            data = data/max(data(:));
            fprintf('Please enter z-slice numbers (ex: 1, 3-5) %s\n', ...
                'or 0 to stop the loop')
            while true
                s = input('z-slices to display: ', 's');
                err = mUtilities.show_3D_array...
                    (data, 'Selected slices', 'x', 'y', 'slice', s); %elect);
                if err ~= 0
                    fprintf('out-of-range slice numbers selected, %s\n', ...
                        'quitting the loop')
                    break
                end
            end
        end
    end
end