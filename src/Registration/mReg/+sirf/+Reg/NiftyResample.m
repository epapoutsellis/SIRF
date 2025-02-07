classdef NiftyResample < handle
% Class for resampling using NiftyReg.

% CCP PETMR Synergistic Image Reconstruction Framework (SIRF).
% Copyright 2018-2019 University College London
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
        handle_
        reference_image
    end
    methods(Static)
        function name = class_name()
            name = 'NiftyResample';
        end
    end
    methods
        function self = NiftyResample(src)
            self.name = 'NiftyResample';
            self.handle_ = calllib('mreg', 'mReg_newObject', self.name);
            sirf.Utilities.check_status(self.name, self.handle_)
        end
        function delete(self)
            if ~isempty(self.handle_)
                sirf.Utilities.delete(self.handle_)
                self.handle_ = [];
            end
        end
        function set_reference_image(self, reference_image)
            %Set reference image.
            assert(isa(reference_image, 'sirf.SIRF.ImageData'), 'NiftyResample::set_reference_image expects sirf.SIRF.ImageData')
            self.reference_image = reference_image;
            sirf.Reg.setParameter(self.handle_, self.name, 'reference_image', reference_image, 'h')
        end
        function set_floating_image(self, floating_image)
            %Set floating image.
            assert(isa(floating_image, 'sirf.SIRF.ImageData'), 'NiftyResample::set_floating_image expects sirf.SIRF.ImageData')
            sirf.Reg.setParameter(self.handle_, self.name, 'floating_image', floating_image, 'h')
        end
        function add_transformation(self, src)
            %Add transformation.
            if isa(src, 'sirf.Reg.AffineTransformation')
                h = calllib('mreg', 'mReg_NiftyResample_add_transformation', self.handle_, src.handle_, 'affine');
            elseif isa(src, 'sirf.Reg.NiftiImageData3DDisplacement')
                h = calllib('mreg', 'mReg_NiftyResample_add_transformation', self.handle_, src.handle_, 'displacement');
            elseif isa(src, 'sirf.Reg.NiftiImageData3DDeformation')
                h = calllib('mreg', 'mReg_NiftyResample_add_transformation', self.handle_, src.handle_, 'deformation');
            else 
                error('Transformation should be affine, deformation or displacement.')
            end
        end
        function set_interpolation_type(self, type)
            %Set interpolation type. 0=nearest neighbour, 1=linear, 3=cubic, 4=sinc.
            sirf.Reg.setParameter(self.handle_, self.name, 'interpolation_type', type, 'i')
        end
        function set_interpolation_type_to_nearest_neighbour(self)
            %Set interpolation type to nearest neighbour.
            sirf.Reg.setParameter(self.handle_, self.name, 'interpolation_type', 0, 'i')
        end
        function set_interpolation_type_to_linear(self)
            %Set interpolation type to linear.
            sirf.Reg.setParameter(self.handle_, self.name, 'interpolation_type', 1, 'i')
        end
        function set_interpolation_type_to_cubic_spline(self)
            %Set interpolation type to cubic spline.
            sirf.Reg.setParameter(self.handle_, self.name, 'interpolation_type', 3, 'i')
        end
        function set_interpolation_type_to_sinc(self)
            %Set interpolation type to sinc.
            sirf.Reg.setParameter(self.handle_, self.name, 'interpolation_type', 4, 'i')
        end
        function set_padding_value(self, val)
            %Set padding value.
            sirf.Reg.setParameter(self.handle_, self.name, 'padding', val, 'f')
        end
        function process(self)
            %Process.
            h = calllib('mreg', 'mReg_NiftyResample_process', self.handle_);
            sirf.Utilities.check_status([self.name ':process'], h);
            sirf.Utilities.delete(h)
        end
        function output = get_output(self)
            %Get output.
            assert(~isempty(self.reference_image) && ~isempty(self.reference_image.handle_))
            output = self.reference_image.same_object();
            sirf.Utilities.delete(output.handle_)
            output.handle_ = calllib('mreg', 'mParameter', self.handle_, self.name, 'output');
            sirf.Utilities.check_status([self.name ':get_output'], output.handle_)
        end
    end
end
