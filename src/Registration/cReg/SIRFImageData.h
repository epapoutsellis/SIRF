/*
CCP PETMR Synergistic Image Reconstruction Framework (SIRF)
Copyright 2015 - 2017 Rutherford Appleton Laboratory STFC

This is software developed for the Collaborative Computational
Project in Positron Emission Tomography and Magnetic Resonance imaging
(http://www.ccppetmr.ac.uk/).

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/

/*!
\file
\ingroup Registration
\brief Base class for SIRF image data.

\author Richard Brown
\author CCP PETMR
*/

#ifndef _SIRFIMAGEDATA_H_
#define _SIRFIMAGEDATA_H_

#include <nifti1_io.h>
#include <string>
#include <memory>
#include <iostream>

template <int num_dimensions>
class VoxelisedGeometricalInfo;
/// Typedef VoxelisedGeometricalInfo for 3D
typedef VoxelisedGeometricalInfo<3> VoxelisedGeometricalInfo3D;
namespace sirf {
class PETImageData;
};
class MRImageData;

namespace sirf {
/// SIRF image data
class SIRFImageData
{
public:

    /// Constructor
    SIRFImageData() {}

    /// Destructor
    virtual ~SIRFImageData() {}

    /// Assignment
    virtual SIRFImageData operator=(const SIRFImageData& to_copy);

    /// Filename constructor
    SIRFImageData(const std::string &filename);

    /// Nifti constructor
    SIRFImageData(const nifti_image &image_nifti);

    /// Nifti shared_ptr constructor
    SIRFImageData(const std::shared_ptr<nifti_image> image_nifti);

    /// STIR constructor
    SIRFImageData(const sirf::PETImageData &pet_image);

    /// Gadgetron constructor
    SIRFImageData(const MRImageData &);

    /// Addition operator
    SIRFImageData operator+(const SIRFImageData&) const;

    /// Subtraction operator
    SIRFImageData operator-(const SIRFImageData&) const;

    /// Is the image initialised? (Should unless default constructor was used.)
    bool is_initialised() const { return (_nifti_image ? true : false); }

    /// Get image as nifti
    std::shared_ptr<nifti_image> get_raw_nifti_sptr() const;

    /// Copy data to PETImageData
    void copy_data_to(sirf::PETImageData &pet_image) const;

    /// Copy data to MRImageData
    void copy_data_to(MRImageData &) const;

    /// Save to file
    void save_to_file(const std::string &filename) const;

    /// Get max
    float get_max() const;

    /// Get min
    float get_min() const;

    /// Get element
    float get_element(int x, int y=0, int z=0, int t=0, int u=0, int v=0, int w=0) const;

    /// Get sum
    float get_sum() const;

    /// Fill
    void fill(const float &v);

    /// Deep copy
    SIRFImageData deep_copy() const;

    /// Get number of voxels
    void get_dimensions(int dims[8]) const
    {
        for (int i=0; i<8; ++i)
            dims[i] = _nifti_image->dim[i];
    }

protected:

    /// Set up nifti image
    void set_up_nifti(const VoxelisedGeometricalInfo3D &info);

    /// Check that images are aligned
    bool check_images_are_aligned(const VoxelisedGeometricalInfo3D &info) const;

    /// Image data as a nifti object
    std::shared_ptr<nifti_image>  _nifti_image;
};
}

#endif
