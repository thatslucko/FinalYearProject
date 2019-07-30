close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful

thetaArray = zeros(700,2);
distanceArray = zeros(700,2);
noCoordinates = zeros(700,2);
addedTotal = 1;
noCoordCount = 1;

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 1:numel(D)                                               %1:122727
    subject = D(k).name
    dir(subject);
    
    ccLeftAdded = 0;
    ccRightAdded = 0;
    mloLeftAdded = 0;
    
    infoFileName = strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful/', subject);
    cd(infoFileName)
    % CC
    if isequal(exist('CCpair', 'dir'),7) % 7 means its a folder and exists
        fprintf('CCpair exists\n');         % Comment to consel
        cd('CCpair')                        % move into CCpair folder
        % CC PAIR LEFT
        if isequal(exist('left', 'dir'),7) % if left folder exists
            cd('left')                      % move into it
            
            if isequal(exist('processedPair', 'dir'),7)
                fprintf('Processed Pair Exists\n');
                cd('processedPair');
                dcmFiles = dir('*.dcm');
                for currentFile = 1:2
                    fileName = dcmFiles(currentFile).name;
                    cropFlag = strfind(fileName, 'cropped.');
                    if cropFlag > 0
                        croppedSpotFileName = dcmFiles(currentFile).name;
                        croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/left', '/processedPair/', croppedSpotFileName));
                        croppedSpotImage = dicomread(croppedSpotImageFilePath);
                    else
                        fullImageFileName = dcmFiles(currentFile).name;
                        fullImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/left', '/processedPair/', fullImageFileName));
                        fullImage = dicomread(fullImageFilePath);
                        % Obtaining image size data
                        [imageHight, imageWidth, imageDepth] = size(fullImage);
                    end
                end
                jsonFiles = dir('*.json');
                for currentFile = 1:size(jsonFiles)
                    fileName = jsonFiles(currentFile).name;
                    coordinateFlag = strfind(fileName, 'coordinates');
                    if coordinateFlag > 0
                        coordinateFilePath = jsonFiles(currentFile).name;
                        
                        jsonText = fileread('coordinates.json');
                        coordinateStruct = jsondecode(jsonText);
                        X1 = str2double(coordinateStruct.X1);
                        X2 = str2double(coordinateStruct.X2);
                        Y1 = str2double(coordinateStruct.Y1);
                        Y2 = str2double(coordinateStruct.Y2);
                        
                        % Coordinate border for visualisation
                        XI = [X1, X2, X2, X1, X1];
                        YI = [Y1, Y1, Y2, Y2, Y1];
                        
                        %             rectangle            top left      width hight
                        cropOfFullView = imcrop(fullImage,  [X1 Y1       X2-X1 Y2-Y1]);
                        
                        % Resize spotView image in   percentage
                        %downSizedCroppedSpot = imresize(croppedSpot, 1);
                        
                        % Centre of the coordinate rectangle
                        coordxCentre = ((X2+X1)/2);
                        coordyCentre = ((Y2+Y1)/2);
                        
                        % Calculate SSD and NCC between Template and Image
                        [I_SSD, I_NCC] = template_matching(croppedSpotImage,fullImage);
                        
                        % Find maximum correspondence in I_SDD image
                        [cropxCentre, cropyCentre] = find(I_SSD == max(I_SSD(:)));
                        
                        deltaX = max(coordxCentre, cropxCentre) - min(coordxCentre, cropxCentre);
                        deltaY = max(coordyCentre, cropyCentre) - min(coordyCentre, cropyCentre);
                        
                        distanceBetweenCentres = sqrt(deltaX^2 + deltaY^2);
                        
                        twoPI = 6.2831853071795865;
                        rad2deg = 57.2957795130823209;
                        theta = atan(deltaY/deltaX);
                        if theta < 0.0
                            theta = theta+twoPI ;
                        end
                        thetaInDegrees = rad2deg*theta;
                        
                        subjectDouble = str2double(erase(string(subject), 'demd'));
                        thetaArray(addedTotal,2) = subjectDouble;
                        thetaArray(addedTotal,1) = theta;
                        distanceArray(addedTotal,2) = subjectDouble;
                        distanceArray(addedTotal,1) = distanceBetweenCentres;
                        addedTotal = addedTotal+1;
                    else
                        subjectDouble = str2double(erase(string(subject), 'demd'));
                        noCoordinates(noCoordCount,1) = subjectDouble;
                        noCoordCount = noCoordCount+1;
                    end
                end
                cd ..
            end
            cd ..     
        else
            fprintf('No CC left folder\n');
        end
        
        % CC PAIR RIGHT
        if isequal(exist('right', 'dir'),7) % if left folder exists
            cd('right')                      % move into right folder
            
            if isequal(exist('processedPair', 'dir'),7)
                fprintf('Processed Pair Exists\n');
                cd('processedPair');
                dcmFiles = dir('*.dcm');
                for currentFile = 1:2
                    fileName = dcmFiles(currentFile).name;
                    cropFlag = strfind(fileName, 'cropped.');
                    if cropFlag > 0
                        croppedSpotFileName = dcmFiles(currentFile).name;
                        croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/right', '/processedPair/', croppedSpotFileName));
                        croppedSpotImage = dicomread(croppedSpotImageFilePath);
                    else
                        fullImageFileName = dcmFiles(currentFile).name;
                        fullImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/right', '/processedPair/', fullImageFileName));
                        fullImage = dicomread(fullImageFilePath);
                        % Obtaining image size data
                        [imageHight, imageWidth, imageDepth] = size(fullImage);
                    end
                end
                jsonFiles = dir('*.json');
                for currentFile = 1:size(jsonFiles)
                    fileName = jsonFiles(currentFile).name;
                    coordinateFlag = strfind(fileName, 'coordinates');
                    if coordinateFlag > 0
                        coordinateFilePath = jsonFiles(currentFile).name;
                        
                        jsonText = fileread('coordinates.json');
                        coordinateStruct = jsondecode(jsonText);
                        X1 = str2double(coordinateStruct.X1);
                        X2 = str2double(coordinateStruct.X2);
                        Y1 = str2double(coordinateStruct.Y1);
                        Y2 = str2double(coordinateStruct.Y2);

                        % Coordinate border for visualisation
                        XI = [X1, X2, X2, X1, X1];
                        YI = [Y1, Y1, Y2, Y2, Y1];

                        %             rectangle            top left      width hight
                        cropOfFullView = imcrop(fullImage,  [X1 Y1       X2-X1 Y2-Y1]);

                        % Resize spotView image in   percentage
                        %downSizedCroppedSpot = imresize(croppedSpot, 1);

                        % Centre of the coordinate rectangle
                        coordxCentre = ((X2+X1)/2);
                        coordyCentre = ((Y2+Y1)/2);

                        % Calculate SSD and NCC between Template and Image
                        [I_SSD, I_NCC] = template_matching(croppedSpotImage,fullImage);

                        % Find maximum correspondence in I_SDD image
                        [cropxCentre, cropyCentre] = find(I_SSD == max(I_SSD(:)));

                        deltaX = max(coordxCentre, cropxCentre) - min(coordxCentre, cropxCentre);
                        deltaY = max(coordyCentre, cropyCentre) - min(coordyCentre, cropyCentre);

                        distanceBetweenCentres = sqrt(deltaX^2 + deltaY^2);

                        twoPI = 6.2831853071795865;
                        rad2deg = 57.2957795130823209;
                        theta = atan(deltaY/deltaX);
                        if theta < 0.0
                            theta = theta+twoPI ;
                        end
                        thetaInDegrees = rad2deg*theta;

                        subjectDouble = str2double(erase(string(subject), 'demd'));
                        thetaArray(addedTotal,2) = subjectDouble;
                        thetaArray(addedTotal,1) = theta;
                        distanceArray(addedTotal,2) = subjectDouble;
                        distanceArray(addedTotal,1) = distanceBetweenCentres;
                        addedTotal = addedTotal+1;     
                    else
                        subjectDouble = str2double(erase(string(subject), 'demd'));
                        noCoordinates(noCoordCount,2) = subjectDouble;
                        noCoordCount = noCoordCount+1;
                    end
                end 
                cd ..
            end
            cd ..
        else
            fprintf('No CC right folder\n')
            noProPairCCR = 1;
        end
        cd ..
    end
    % MLO
    if isequal(exist('MLOpair', 'dir'),7) % 7 means its a folder and exists
        fprintf('MLOpair exists\n');
        cd('MLOpair')
        % MLO LEFT
        if isequal(exist('left', 'dir'),7) % if left folder exists
            cd('left')                      % move into it
            
            if isequal(exist('processedPair', 'dir'),7)
                fprintf('Processed Pair Exists\n');
                cd('processedPair');
                dcmFiles = dir('*.dcm');
                for currentFile = 1:2
                    fileName = dcmFiles(currentFile).name;
                    cropFlag = strfind(fileName, 'cropped.');
                    if cropFlag > 0
                        croppedSpotFileName = dcmFiles(currentFile).name;
                        croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/processedPair/', croppedSpotFileName));
                        croppedSpotImage = dicomread(croppedSpotImageFilePath);
                    else
                        fullImageFileName = dcmFiles(currentFile).name;
                        fullImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/processedPair/', fullImageFileName));
                        fullImage = dicomread(fullImageFilePath);
                        % Obtaining image size data
                        [imageHight, imageWidth, imageDepth] = size(fullImage);
                    end
                end
                jsonFiles = dir('*.json');
                for currentFile = 1:size(jsonFiles)
                    fileName = jsonFiles(currentFile).name;
                    coordinateFlag = strfind(fileName, 'coordinates');
                    if coordinateFlag > 0
                        coordinateFilePath = jsonFiles(currentFile).name;
                        
                        jsonText = fileread('coordinates.json');
  
                        coordinateStruct = jsondecode(jsonText);
                        X1 = str2double(coordinateStruct.X1);
                        X2 = str2double(coordinateStruct.X2);
                        Y1 = str2double(coordinateStruct.Y1);
                        Y2 = str2double(coordinateStruct.Y2);

                        % Coordinate border for visualisation
                        XI = [X1, X2, X2, X1, X1];
                        YI = [Y1, Y1, Y2, Y2, Y1];

                        %             rectangle            top left      width hight
                        cropOfFullView = imcrop(fullImage,  [X1 Y1       X2-X1 Y2-Y1]);

                        % Resize spotView image in   percentage
                        %downSizedCroppedSpot = imresize(croppedSpot, 1);

                        % Centre of the coordinate rectangle
                        coordxCentre = ((X2+X1)/2);
                        coordyCentre = ((Y2+Y1)/2);

                        % Calculate SSD and NCC between Template and Image
                        [I_SSD, I_NCC] = template_matching(croppedSpotImage,fullImage);

                        % Find maximum correspondence in I_SDD image
                        [cropxCentre, cropyCentre] = find(I_SSD == max(I_SSD(:)));

                        deltaX = max(coordxCentre, cropxCentre) - min(coordxCentre, cropxCentre);
                        deltaY = max(coordyCentre, cropyCentre) - min(coordyCentre, cropyCentre);

                        distanceBetweenCentres = sqrt(deltaX^2 + deltaY^2);

                        twoPI = 6.2831853071795865;
                        rad2deg = 57.2957795130823209;
                        theta = atan(deltaY/deltaX);
                        if theta < 0.0
                            theta = theta+twoPI ;
                        end
                        thetaInDegrees = rad2deg*theta;

                        subjectDouble = str2double(erase(string(subject), 'demd'));
                        thetaArray(addedTotal,2) = subjectDouble;
                        thetaArray(addedTotal,1) = theta;
                        distanceArray(addedTotal,2) = subjectDouble;
                        distanceArray(addedTotal,1) = distanceBetweenCentres;
                        addedTotal = addedTotal+1;
                    else
                        subjectDouble = str2double(erase(string(subject), 'demd'));
                        noCoordinates(noCoordCount,2) = subjectDouble;
                        noCoordCount = noCoordCount+1;
                    end
                end
                cd ..
            end
            cd ..
        end
    else
        fprintf('No MLO left folder\n');
        noProPairMLOL = 1;
    end
    % MLO RIGHT
    if isequal(exist('right', 'dir'),7) % if left folder exists
        cd('right')                      % move into it
        
        if isequal(exist('processedPair', 'dir'),7)
            fprintf('Processed Pair Exists\n');
            cd('processedPair');
            dcmFiles = dir('*.dcm');
            for currentFile = 1:2
                fileName = dcmFiles(currentFile).name;
                cropFlag = strfind(fileName, 'cropped.');
                if cropFlag > 0
                    croppedSpotFileName = dcmFiles(currentFile).name;
                    croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/right', '/processedPair/', croppedSpotFileName));
                    croppedSpotImage = dicomread(croppedSpotImageFilePath);
                else
                    fullImageFileName = dcmFiles(currentFile).name;
                    fullImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/right', '/processedPair/', fullImageFileName));
                    fullImage = dicomread(fullImageFilePath);
                    % Obtaining image size data
                    [imageHight, imageWidth, imageDepth] = size(fullImage);
                end
            end
            jsonFiles = dir('*.json');
            for currentFile = 1:size(jsonFiles)
                fileName = jsonFiles(currentFile).name;
                coordinateFlag = strfind(fileName, 'coordinates');
                if coordinateFlag > 0
                    coordinateFilePath = jsonFiles(currentFile).name;
                    jsonText = fileread('coordinates.json');
                    coordinateStruct = jsondecode(jsonText);
                    X1 = str2double(coordinateStruct.X1);
                    X2 = str2double(coordinateStruct.X2);
                    Y1 = str2double(coordinateStruct.Y1);
                    Y2 = str2double(coordinateStruct.Y2);

                    % Coordinate border for visualisation
                    XI = [X1, X2, X2, X1, X1];
                    YI = [Y1, Y1, Y2, Y2, Y1];

                    %             rectangle            top left      width hight
                    cropOfFullView = imcrop(fullImage,  [X1 Y1       X2-X1 Y2-Y1]);

                    % Resize spotView image in   percentage
                    %downSizedCroppedSpot = imresize(croppedSpot, 1);

                    % Centre of the coordinate rectangle
                    coordxCentre = ((X2+X1)/2);
                    coordyCentre = ((Y2+Y1)/2);

                    % Calculate SSD and NCC between Template and Image
                    [I_SSD, I_NCC] = template_matching(croppedSpotImage,fullImage);

                    % Find maximum correspondence in I_SDD image
                    [cropxCentre, cropyCentre] = find(I_SSD == max(I_SSD(:)));

                    deltaX = max(coordxCentre, cropxCentre) - min(coordxCentre, cropxCentre);
                    deltaY = max(coordyCentre, cropyCentre) - min(coordyCentre, cropyCentre);

                    distanceBetweenCentres = sqrt(deltaX^2 + deltaY^2);

                    twoPI = 6.2831853071795865;
                    rad2deg = 57.2957795130823209;
                    theta = atan(deltaY/deltaX);
                    if theta < 0.0
                        theta = theta+twoPI ;
                    end
                    thetaInDegrees = rad2deg*theta;

                    if mloLeftAdded == 1
                        addedTotal = addedTotal+1;
                    end

                    subjectDouble = str2double(erase(string(subject), 'demd'));
                    thetaArray(addedTotal,2) = subjectDouble;
                    thetaArray(addedTotal,1) = theta;
                    distanceArray(addedTotal,2) = subjectDouble;
                    distanceArray(addedTotal,1) = distanceBetweenCentres;
                    addedTotal = addedTotal+1;
                else
                    subjectDouble = str2double(erase(string(subject), 'demd'));
                    noCoordinates(noCoordCount,2) = subjectDouble;
                    noCoordCount = noCoordCount+1;
                end
            end    
        end
    else
        fprintf('No MLO right folder\n');
        noProPairMLOR = 1;
    end  
end
