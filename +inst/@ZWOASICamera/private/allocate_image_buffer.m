function allocate_image_buffer(Z)
    % Allocate the image buffer.
    roi=Z.ROI;
    imlength=(roi(3)-roi(1)+1)*(roi(4)-roi(2)+1)*Z.BitDepth/8;
    Z.pImg=libpointer('uint8Ptr',zeros(imlength,1,'uint8'));
end
