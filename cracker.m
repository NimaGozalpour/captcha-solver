
function cracker(l)
tic
s1=num2str(l);
s2='Images\img (';
s=strcat(s1,').jpg');
s=strcat(s2,s);

I=imread(s);
I_orginal=I;

%----------clean image background color and black point (noise) using hsv
%transform
I_hsv=rgb2hsv(I);
[row,column,~]=size(I_hsv);
for i=1:row
    for j=1:column
        if I_hsv(i,j,2)<0.60
            I(i,j,:)=255;
        end
        if sum(I(i,j,:))<90
            I(i,j,:)=255;
        end
    end
end
I_5 = I;

%-------- find the color of characters
[mode_r,mode_g,mode_b]=color_finder(I_hsv,I);

%-------- find the Hue of characters color and filter other color using of
%this feature
[h,~,~]=rgb2hsv([mode_r,mode_g,mode_b]);
I_clean=zeros(size(I));
for i=1:row
    for j=1:column
        if sum(I(i,j,:))<760
            if abs(h-I_hsv(i,j,1))*360<=15 && I_hsv(i,j,2)>0.60
                I_clean(i,j,:)=1;
            elseif (1-abs(h-I_hsv(i,j,1)))*360<=15 && I_hsv(i,j,2)>0.60
                I_clean(i,j,:)=1;
            end
        end
    end
end

clear_pics=I_clean(:,:,1);

I_1=clear_pics;


k=clear_pics;

%--------- calculate vertical and horizental histograms and using
%vertical histogram, position of characters are found
histogram_hor=zeros(1,row);
for j=1:row
    histogram_hor(1,j)=sum(k(j,:))/column;
end
counter=1;
flag=0;
start_finish=zeros(1,40);
histogram_ver=zeros(1,row);
for j=1:column
    histogram_ver(1,j)=sum(k(:,j))/row;
    if flag==0
        if histogram_ver(1,j)~=0
            start_finish(1,counter)=j;
            flag=1;
            counter=counter+1;
        end
    else
        if histogram_ver(1,j)==0
            start_finish(1,counter)=j;
            flag=0;
            counter=counter+1;
        end
    end
end


%---------- remove parts of image which have area
%been lower than 50 pixels
kl=logical(k);
I_2=kl;

l=regionprops (kl,'Area','PixelList');
len=length(l);
for j=1:len
    if l(j).Area<50
        for ii=1:l(j).Area
            k(l(j).PixelList(ii,2),l(j).PixelList(ii,1))=0;
        end
    end
end

clear_pics=k;
I_3 = clear_pics;

%-------- because some of characters are joint togather, this part of
%code goal is seprating characters and finding each character start and final point
start_finish_modified=zeros(1,40);
i=1;
j=1;
counter=1;
while j<=40
    if start_finish(i,j+1)-start_finish(i,j)>53
        mid=floor((start_finish(i,j+1)-start_finish(i,j))/6);
        f1=start_finish(i,j)+mid;
        s1=start_finish(i,j)+3*mid;
        stop_start=find(min(histogram_ver(i,f1:s1))==histogram_ver(i,f1:s1));
        len=length(stop_start);
        disp(stop_start);
        if len==1
            s1=stop_start+f1-1;
            f1=stop_start+f1-1;
        else
            s1=stop_start(len)+f1-1;
            f1=stop_start(1)+f1-1;
        end
        
        f2=start_finish(i,j)+3*mid;
        s2=start_finish(i,j)+5*mid;
        stop_start=find(min(histogram_ver(i,f2:s2))==histogram_ver(i,f2:s2));
        
        len=length(stop_start);
        if len==1
            s2=stop_start+f2-1;
            f2=stop_start+f2-1;
        else
            s2=stop_start(len)+f2-1;
            f2=stop_start(1)+f2-1;
        end
        
        
        
        start_finish_modified(i,counter:counter+5)=...
            [start_finish(i,j),f1,s1,f2,s2,start_finish(i,j+1)];
        counter=counter+6;
    elseif start_finish(i,j+1)-start_finish(i,j)>30
        mid=floor((start_finish(i,j+1)+start_finish(i,j))/2);
        stop_start=find(min(histogram_ver(i,mid-8:mid+8))==...
            histogram_ver(i,mid-8:mid+8));
        len=length(stop_start);
        if len==1
            f=stop_start+mid-9;
            s=stop_start+mid-9;
        else
            f=stop_start(1)+mid-9;
            s=stop_start(len)+mid-9;
        end
        
        start_finish_modified(i,counter:counter+3)=...
            [start_finish(i,j),f,s,start_finish(i,j+1)];
        counter=counter+4;
    elseif start_finish(i,j+1)-start_finish(i,j)>8
        start_finish_modified(i,counter:counter+1)=...
            [start_finish(i,j),start_finish(i,j+1)];
        counter=counter+2;
    end
    j=j+2;
    if start_finish(i,j)==0
        break;
    end
end

%--------- put each character in diffrent layer of matrix with same size
% 28*28
num_pics=zeros(28,28,1*6);
counter_pic=1;
l=1;

counter=1;
for j=1:6
    if start_finish_modified(l,counter+1)==0
        break;
    end
    num_pics(:,:,counter_pic)=imresize(clear_pics(:,start_finish_modified...
        (l,counter):start_finish_modified(l,counter+1),l),[28,28]);
    counter=counter+2;
    counter_pic=counter_pic+1;
end

%-------- make ready each character for softmax by flatten them
[row,column,len]=size(num_pics);
I_4 = num_pics;
in_data=zeros(len,row*column);
for i=1:len
    for j=1:row
        in_data(i,(j-1)*column+1:j*column)=num_pics(j,:,i);
    end
end


%------- predict each character and save it in s1 string as char
load('model.mat');
Y = net(in_data.');
counter_pic=counter_pic-1;
s1='';
for i=1:counter_pic
    num=find(max(Y(:,i))== Y(:,i))-1;
    s=num2str(num);
    s1=strcat(s1,s);
end
toc
%-------------
c1=7;
c2=6;
subplot(c1,c2,[1,6])
imshow(I_orginal);
subplot(c1,c2,[7,12])
imshow(I_hsv);
subplot(c1,c2,[13,18])
imshow(I_5);
subplot(c1,c2,[19,24])
imshow(I_1);
subplot(c1,c2,[25,30])
imshow(I_2);
subplot(c1,c2,[31,36])
imshow(I_3);
for i=1:6
    subplot(c1,c2,36+i)
    imshow(I_4(:,:,i))
    xlabel(s1(i),'FontSize',20,'FontWeight','bold');
end
end