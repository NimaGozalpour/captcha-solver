function [mode_r,mode_g,mode_b]=color_finder(I_hsv,I)
coloered_Pixel=zeros(5000,3);
counter=1;
for i=1:50
    for j=100:200
        if sum(I(i,j,:))<760
            coloered_Pixel(counter,:)=I_hsv(i,j,:);
            counter=counter+1;
        end
    end
end
coloered_Pixel(counter:5000,:)=[];
mode_r=mode(coloered_Pixel(:,1));
mode_g=mode(coloered_Pixel(:,2));
mode_b=mode(coloered_Pixel(:,3));
[mode_r,mode_g,mode_b]=hsv2rgb([mode_r,mode_g,mode_b]);
colori=zeros(100,100,3);
colori(:,:,1)=colori(:,:,1)+mode_r;
colori(:,:,2)=colori(:,:,2)+mode_g;
colori(:,:,3)=colori(:,:,3)+mode_b;

end