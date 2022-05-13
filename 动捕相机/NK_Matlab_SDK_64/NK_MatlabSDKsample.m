% function [frameOfData] = NK_MatlabSDKsample()

% [frameOfData, bodyDefs] = NK_MatlabSDKsample()
% Sample file to illustrate usage of the Matlab SDK for Nokov motioncapture software
% 
% This function creates a simple MENU with the following options:
% 
% 1: Obtain the current frame of data. This returns a frame of data structure to the
% variable 'frameOfData'
% 2: Exit: This unloads the libraries and exits
% 

% Set-up the IP initialization values. These values should be edited to
% match appropriate values for a given system 
initializeStruct.TalkToHostNicCardAddress = '10.1.1.198';
initializeStruct.HostNicCardAddress = '10.1.1.198';
initializeStruct.HostMulticastAddress = '225.1.1.1';
initializeStruct.TalkToClientsNicCardAddress = '0';
initializeStruct.ClientsMulticastAddress = '225.1.1.2';

frameofData = [];

% Load the SDK libraries and initialize ethernet communication
returnValue = mCortexInitialize(initializeStruct);

if returnValue == 0
    choice = 1;
    
    while choice ~=2
        % Generate menu
        choice = menu('NK_MatlabSDKsample Program','Get Frame of Data','Exit');
        
        switch choice
            case 1 % Get Frame of Data
                frameOfData = mGetCurrentFrame() %获取当前帧动捕数据
				
                if (isempty(frameOfData))
                    continue;
                else
                    fprintf( 'nMarkerset=%d\n', frameOfData.nBodies);%动捕数据Markerset（骨架）的数量
                    for iBody=1: frameOfData.nBodies
                        fprintf( 'Markerset %d: %s\n', iBody, frameOfData.BodyData(iBody).szName);%动捕数据第iBody个Markerset的名字
                        fprintf( '{\n');
					
                        fprintf( '\tnMarkers=%d\n', frameOfData.BodyData(iBody).nMarkers);%动捕数据第iBody个Markerset（骨架），包含的Marker点数量
                        fprintf( '\t{\n');
                        for i=1:frameOfData.BodyData(iBody).nMarkers %输出包含的Marker点坐标
                            fprintf('\t\tMarker %d  X:%f Y:%f Z:%f\n',frameOfData.BodyData(iBody).Markers(i*4-3),frameOfData.BodyData(iBody).Markers(i*4-2),...
                                                                        frameOfData.BodyData(iBody).Markers(i*4-1),frameOfData.BodyData(iBody).Markers(i*4))
                        end
                        fprintf( '\t}\n');
					
                        %Segments
                        fprintf('\tnSegments=%d\n', frameOfData.BodyData(iBody).nSegments);%动捕数据第iBody个Markerset（骨架），包含的Segments（骨骼）数量
                        fprintf('\t{\n');
                        for iBodynSegments=1:frameOfData.BodyData(iBody).nSegments %输出包含的Segments（骨骼）的六个自由度信息（Tx,Ty,Tz,Rx,Ry,Rz）+长度（Length） 每一列是一个刚体的数据
                            fprintf('\t\tSegment %d, Tx:%f Ty:%f Tz:%f Rx:%f Ry:%f Rz:%f Length:%f \n',frameOfData.BodyData(iBody).Segments(iBodynSegments*8-7),...
                                                                                                        frameOfData.BodyData(iBody).Segments(iBodynSegments*8-6),...
                                                                                                        frameOfData.BodyData(iBody).Segments(iBodynSegments*8-5),...
                                                                                                        frameOfData.BodyData(iBody).Segments(iBodynSegments*8-4),...
                                                                                                        frameOfData.BodyData(iBody).Segments(iBodynSegments*8-3),...
                                                                                                        frameOfData.BodyData(iBody).Segments(iBodynSegments*8-2),...
                                                                                                        frameOfData.BodyData(iBody).Segments(iBodynSegments*8-1),...
                                                                                                        frameOfData.BodyData(iBody).Segments(iBodynSegments*8)  );
                        end
                        fprintf( '\t}\n');
                        fprintf('}\n');%第iBody个Markerset的数据输出完成
                    end
				
                    %Unidentified Markers
                    fprintf('nUnidentifiedMarkers=%d\n', frameOfData.nUnidentifiedMarkers);%动捕数据中，未识别的Marker点数量
                    fprintf( '{\n');
                    for inUnidentifiedMarkers=1:frameOfData.nUnidentifiedMarkers %输出未识别的Marker点坐标
                        fprintf( '\tUnidentifiedMarkers %d  X:%f Y:%f Z:%f\n',frameOfData.UnidentifiedMarkers(inUnidentifiedMarkers*4-3),frameOfData.UnidentifiedMarkers(inUnidentifiedMarkers*4-2),frameOfData.UnidentifiedMarkers(inUnidentifiedMarkers*4-1),frameOfData.UnidentifiedMarkers(inUnidentifiedMarkers*4))
                    end
                    fprintf( '}\n');
                end
  
            case 2 % Unload library and exit
                exitValue = mCortexExit();
        end
    end
       
else
    errordlg('Unable to initialize ethernet communication','Sample file error');
end

% end

