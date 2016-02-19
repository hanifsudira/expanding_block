function blocks=blockMaker(img, init)
%This function takes in a trimmed matrix representing the grayscale of an
%image, refered to as 'img', and will return a linear array of overlaping 
%pixel blocks, called 'blocks'.  Each block is a matrix of size 
%blockSize-by-blockSize.  This will work for any trimmed matrix as long
%as the number of rows and columns are divisble by the blockDistance.  It 
%will start at the top right corner of the img matrix and creat the blocks
%left to right.  Once it reaches right end it moves down the appropriate
%rows and repeats, a-la typewriter style.

%Note that this makes the overlap half the block size.  If we choose to
%adjust the overlap the variables outerCount and innerCount will need to 
%be adjusted. 

%Test results:
%Test1- 410x620 size image, made 2440 20x20 size blocks in 0.184299 sec
%Test2- 1024x1280 size image, made 4977 32x32 size blocks in 0.631426 sec


%--------------------------------------------------------------------------

%rows and cols will hold number or matrox rows and cols
[rows cols]=size(img);
%initially set to size of 1 will concat in function.  
blocks=cell(1);

%innerCount is the number of blocks traversing matrix Left to right.  
%This will be the number of iterations in the innner loop.
innerCount=(cols-init.blockDistance)/init.blockDistance;

%outerCount is the number of shifts down the matrix, aka the number of
%iterations for the outer loop.
outerCount=(rows-init.blockDistance)/init.blockDistance;


%These variables are values hold the row numbers of the matricies being
%built. These change once the builder reaches the left col.
rowStart=1;
rowEnd=init.blockSize;

for i=1:outerCount
    %These variables are values hold the col numbers of the matricies being
    %built. These change with each iteration of the inner loop.
    colStart=1;
    colEnd=init.blockSize-1;
    
    for j=1:innerCount
        block=img(rowStart:rowEnd,colStart:colEnd); %making a block
        blocks= [blocks block]; %concating the block into the array
        colStart=colStart+init.blockDistance;  %shifting to the next cols
        colEnd=colEnd+init.blockDistance;
    end
    
    %when the inner loop ends this moves down rows
    rowStart=rowStart+init.blockDistance;
    rowEnd=rowEnd+init.blockDistance;
end


% -------------------------------------------------------------------------
% 
% %This is the same code but with hard coded blockSize and blockDistance, 
% %used  for testing.
% 
% %hardcoded blockDistance & blockSize for testing
% blockDistance=16;
% blockSize=32;
% 
% [rows cols]=size(img);  
% blocks=cell(1);
% 
% tic
% innerCount=(cols-blockDistance)/blockDistance;
% outerCount=(rows-blockDistance)/blockDistance;
% 
% 
% rowStart=1;
% rowEnd=blockSize;
% for i=1:outerCount
%     colStart=1;
%     colEnd=blockSize;
%     
%     for j=1:innerCount
%         block=img(rowStart:rowEnd,colStart:colEnd);
%         blocks= [blocks block];
%         colStart=colStart+blockDistance;
%         colEnd=colEnd+blockDistance;
%     end
%     
%     rowStart=rowStart+blockDistance;
%     rowEnd=rowEnd+blockDistance;
% end
% toc

%-------------------------------------------------------------------------

%As written, the firsy first element of blocks is an empty cell by degault.
%this removes that empyer cell
blocks=blocks(2:end);

end
