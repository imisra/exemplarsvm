function boxes = applyModel(data_set, model, test_set_name)

%% Define test-set parameters
test_params = model.params;
test_params.detect_exemplar_nms_os_threshold = 1.0;
test_params.detect_max_windows_per_exemplar = 500;
test_params.detect_keep_threshold = -2.0;


if length(data_set) == 0
  data_set = get_screenshot_bg(50,@(x)imresize_max(x,400));
  %data_set = get_screenshot_bg(20);
  test_params.display_detections = 1;
  %test_params.write_top_detection = 1;
  %test_params.detect_max_scale = .1;
end


if isnumeric(data_set) && size(data_set,4)==1 && size(data_set,3)== ...
      3
  data_set = {data_set};
elseif isnumeric(data_set) && size(data_set,4) >1 && size(data_set, ...
                                                  3)==3
  for i = 1:size(data_set,4)
    
    curI = data_set(:,:,:,i);
    boxes{i} = esvm_detect_imageset({curI},model,test_params);
  end
else

  %% Apply on test set
  boxes = esvm_detect_imageset(data_set, model, test_params);
end

%% Apply calibration matrix to test-set results
boxes = esvm_pool_exemplar_dets(boxes, model.models, [], ...
                                test_params);
