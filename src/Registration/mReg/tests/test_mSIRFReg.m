% Paths
SIRF_PATH     = getenv('SIRF_PATH');
examples_path = [SIRF_PATH  '/data/examples/Registration'];
output_path   = [pwd  '/results/'];

% Input filenames
reference_image_filename = [examples_path  '/mouseFixed.nii.gz'];
floating_image_filename  = [examples_path  '/mouseMoving.nii.gz'];
parameter_file_aladin    = [examples_path  '/paramFiles/aladin.par'];
parameter_file_f3d       = [examples_path  '/paramFiles/f3d.par'];
matrix                   = [examples_path  '/transformation_matrix.txt'];
stir_nifti               = [examples_path  '/nifti_created_by_stir.nii'];

% Output filenames
aladin_warped            = [output_path    'matlab_aladin_warped'];
f3d_warped               = [output_path    'matlab_f3d_warped'];
TM_fwrd					 = [output_path    'matlab_TM_fwrd.txt'];
TM_back					 = [output_path    'matlab_TM_back.txt'];
aladin_disp_fwrd 	 	 = [output_path    'matlab_aladin_disp_fwrd'];
aladin_disp_back    	 = [output_path    'matlab_aladin_disp_back'];
f3d_disp_fwrd  			 = [output_path    'matlab_f3d_disp_fwrd'];
f3d_disp_back	 		 = [output_path    'matlab_f3d_disp_back'];

output_resample          = [output_path    'matlab_resample'];
output_activity_corr     = [output_path    'matlab_activity_corr'];
output_weighted_mean     = [output_path    'matlab_weighted_mean'];

output_stir_nifti        = [output_path    'matlab_stir_nifti.nii'];

reference = mSIRFReg.ImageData( reference_image_filename );
floating  = mSIRFReg.ImageData(  floating_image_filename );
nifti     = mSIRFReg.ImageData(        stir_nifti        );


disp('% ----------------------------------------------------------------------- %')
disp('%                  Starting Nifty aladin test...                          %')
disp('%------------------------------------------------------------------------ %')
NA = mSIRFReg.NiftyAladinSym();
NA.set_reference_image               (         reference      );
NA.set_floating_image                (         floating       );
NA.set_parameter_file		         ( parameter_file_aladin  );
NA.update();
NA.save_warped_image                 (      aladin_warped     );
NA.save_transformation_matrix_fwrd   (         TM_fwrd        );
NA.save_transformation_matrix_back   (         TM_back        );
NA.save_displacement_field_fwrd_image( aladin_disp_fwrd, true );
NA.save_displacement_field_back_image( aladin_disp_back, true );
disp('% ----------------------------------------------------------------------- %')
disp('%                  Finished Nifty aladin test.                            %')
disp('%------------------------------------------------------------------------ %')




disp('% ----------------------------------------------------------------------- %')
disp('%                  Starting Nifty f3d test...                             %')
disp('%------------------------------------------------------------------------ %')
NF = mSIRFReg.NiftyF3dSym();
NF.set_reference_image               (     reference       );
NF.set_floating_image                (      floating       );
NF.set_parameter_file		         ( parameter_file_f3d  );
NF.set_reference_time_point	         (         1           );
NF.set_floating_time_point	         (         1           );
NF.update();
NF.save_warped_image                 (     f3d_warped      );
NF.save_displacement_field_fwrd_image( f3d_disp_fwrd, true );
NF.save_displacement_field_fwrd_image( f3d_disp_back, true );
disp('% ----------------------------------------------------------------------- %')
disp('%                  Finished Nifty f3d test.                               %')
disp('%------------------------------------------------------------------------ %')



disp('% ----------------------------------------------------------------------- %')
disp('%                  Starting Nifty resample test...                        %')
disp('%------------------------------------------------------------------------ %')
NR = mSIRFReg.NiftyResample();
NR.set_reference_image                (   reference     );
NR.set_floating_image                 (    floating     );
NR.set_transformation_matrix          (     matrix      );
NR.set_interpolation_type_to_cubic_spline();
NR.update();
NR.save_resampled_image               ( output_resample );
disp('% ----------------------------------------------------------------------- %')
disp('%                  Finished Nifty resample test.                          %')
disp('%------------------------------------------------------------------------ %')




disp('% ----------------------------------------------------------------------- %')
disp('%                  Starting weighted mean test...                         %')
disp('%------------------------------------------------------------------------ %')
WM = mSIRFReg.ImageWeightedMean();
WM.add_image( nifti, 0.2 );
WM.add_image( nifti, 0.2 );
WM.add_image( nifti, 0.2 );
WM.update();
WM.save_image_to_file(output_weighted_mean);
disp('% ----------------------------------------------------------------------- %')
disp('%                  Finished weighted mean test.                           %')
disp('%------------------------------------------------------------------------ %')



disp('% ----------------------------------------------------------------------- %')
disp('%                  Starting PET SIRFImageData test...                     %')
disp('%------------------------------------------------------------------------ %')
% Open stir image
pet_image_data = mSIRFReg.PETImageData(stir_nifti);
image_data_from_stir = mSIRFReg.ImageData(pet_image_data);
% Compare to nifti IO (if they don't match, you'll see a message but don't throw an error for now)
image_data_from_nifti = mSIRFReg.ImageData(stir_nifti);
mSIRFReg.do_nifti_image_match(image_data_from_stir, image_data_from_nifti);
% Print info
ims=mSIRFReg.ImageDataVector();
ims.push_back(image_data_from_stir);
ims.push_back(image_data_from_nifti);
mSIRFReg.dump_nifti_info(ims);
% Save the one opened by stir
image_data_from_stir.save_to_file(output_stir_nifti);
% Now clone the converted and fill with 1's
cloned = pet_image_data;
cloned.fill(1.);
% Fill the cloned image with data from converted
image_data_from_stir.copy_data_to(cloned);
disp('% ----------------------------------------------------------------------- %')
disp('%                  Finished PET SIRFImageData test.                       %')
disp('%------------------------------------------------------------------------ %')
