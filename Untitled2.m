





function success = Untitled2()

    % calibration with 10 different image pairs
    stereoParams = calibration(1, 107);
    
    
    
    success = true;
    
    %rest();
end



% 
% Es m�ssen folgende Schritte abgearbeitet werden:
% Offline   (Vorverarbeitung)
% 1.        Absch�tzung von Parametern, welche die relative Position
%           der Kameras zueinander beinhalten.
%           (a) Absch�tzung der Kamerainternen Parameter ?
%           (b) Absch�tung der relativen Position der Kameras gemessen in
%               * Verschiebung und 
%               * Rotation 
%           der zweiten Kamera relativ zu der zweiten.
%
% Online    (Bildvergleich)
% 2.        Rektifizierung der zu vergleichenden Bilder
%           Die o.g. Parameter werden dann zur Rektifizierung des 
%           Bildpaares genutzt. I.A. sind die Kameras nicht parallel, 
%           sondern besitzen einen Schnittpunkt. Da die Mathematik hinter 
%           dieser Anordnung schwieriger zu handlen ist, als die hinter 
%           einem Kamerasystem mit zwei verschiedenen Kameras, wird das 
%           Bild digital so transformiert, als ob die beiden
%           Kameras mit einer gewissen Distanz parallel zu einander stehen.
%
%



%
%       Hier wird sp�ter ein Auszug aus dem allgemeinen Vorgehen stehen.
%
% Exaktes Vorgehen:
%       gegeben:        - Kamerasystem bestehend aus 2 Kameras
%                       - Kalibrierungsmustr
%                           * Abgewandeltes Schachbrett (7x8)
%                             i.A. auch i.O. (2 m + 1, 2n) um eindeutige
%                             Orientierung feststellen zu k�nnen.
%                           * Fixiert ungef�hr dort, wo das zu bestimmende
%                             Objekt liegt. (auf flacher Oberfl�che)
%                           * Um sp�ter den errechneten Daten mehr Aussage-
%                             kraft zu geben, ist es sinnvoll, die gr��e
%                             eines Schachfeldes so pr�zise wie m�glich zu
%                             kennen.
%                       - meherer Bildpaare (aufgenommen von Kamerasystem,
%                         auf denen �berall das Kalibrierungsmuster zu 
%                         sehen sein sollte.
%       Achtung:        - Bider sollten in PNG - Format vorliegen.
function stereoParams = calibration(numImgPr, sizeSqares)
    

    %
    % Schritt 1:    Erstellen eines Arrays, welches die Pfade enthält.
    %               Außerdem: Einlesen der Bilder.
    %
    rootDir = fullfile('/homes', 'jhuelsmann', 'Desktop', 'bv_files', 'init');

    testImg1 = cell(numImgPr, numImgPr);
    testImg2 = cell(numImgPr, numImgPr);
    images1 = cast([], 'uint8');
    images2 = cast([], 'uint8');
    
    for i = 1:numImgPr
        testImg1{i} = fullfile(rootDir, sprintf('l%d.png', i));
        testImg2{i} = fullfile(rootDir, sprintf('r%d.png', i));


        im = imread(testImg1{i});
        images1(:, :, :, i) = im;

        im = imread(testImg2{i});
        images2(:, :, :, i) = im;
    end
    
    % Anzeigen des Bildes incusive Schachbrett.
    [imagePoints, boardSize] = detectCheckerboardPoints(images1, images2);
    figure;
    imshow(images1(:,:,:,1), 'InitialMagnification', 50);
    hold on;
    plot(imagePoints(:, 1, 1, 1), imagePoints(:, 2, 1, 1), '*-g');
    title('Schachbrett-Detektion');


    % Kalibrierung
    % Generate world coordinates of the checkerboard points.
    worldPoints = generateCheckerboardPoints(boardSize, sizeSquares);

    % Compute the stereo camera parameters.
    stereoParams = estimateCameraParameters(imagePoints, worldPoints);

    % Evaluate calibration accuracy.
    figure;
    showReprojectionErrors(stereoParams);
end



function rest(stereoParams)

    I1 = imread('C:\Users\juliu_000\Desktop\Stuff\my_images\Camera Roll\l.jpg');
    I2 = imread('C:\Users\juliu_000\Desktop\Stuff\my_images\Camera Roll\r.jpg');


    [J1, J2] = rectifyStereoImages(I1, I2, stereoParams);

    figure;
    imshow(stereoAnaglyph(I1, I2), 'InitialMagnification', 50);
    title('Before Rectification');

    figure;
    imshow(stereoAnaglyph(J1, J2), 'Initial Magnification', 50);
    title('After Rectification');


   % Disparitätenkarte erstellen.
    disparityMap = disparity(rgb2gray(J1), rgb2gray(J2));
    figure;
    imshow(disparityMap, [0, 64], 'InitialMagnification', 50);
    colormap('jet');
    colorbar;
    title('Disparity Map');




end






