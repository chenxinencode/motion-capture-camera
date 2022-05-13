% clc
% clear
%%导入执行仿真数据 同时用动捕相机记录
N=8;
run('initial_dxl');
run('initial_NOKOV');
%加载参数
% load('ff_smc0');
% load('ff_smc_turn');
load('ff_smc_follow_ct_02');
% load('ff_line');%完整的正方形路径
servo=degree_to_dxl(ff(1:7,:));

%% 一些参数
% t0=0; tf=30; dt=0.05; num_seg_t=(tf-t0)/dt;
%% 主程序
elapsed=0;
dt=0.05;
t2=0;


%% 主循环
tic
for index=1:size(servo,2)
    %% 期望关节角度
    t1=clock;
   
    
%     CMD01=degree_to_dxl(pos(1,index));
%     CMD02=degree_to_dxl(pos(2,index));CMD03=degree_to_dxl(pos(3,index));CMD04=degree_to_dxl(pos(4,index));
%     CMD05=degree_to_dxl(pos(5,index));CMD06=degree_to_dxl(pos(6,index));CMD07=degree_to_dxl(pos(7,index));
    %% 执行
    dxl_addparam_result = groupSyncWriteAddParam(group_num, DXL1_ID, servo(1,index), LEN_POSITION);
    dx2_addparam_result = groupSyncWriteAddParam(group_num, DXL2_ID, servo(2,index), LEN_POSITION);
    dx3_addparam_result = groupSyncWriteAddParam(group_num, DXL3_ID, servo(3,index), LEN_POSITION);
    dx4_addparam_result = groupSyncWriteAddParam(group_num, DXL4_ID, servo(4,index), LEN_POSITION);
    dx5_addparam_result = groupSyncWriteAddParam(group_num, DXL5_ID, servo(5,index), LEN_POSITION);
    dx6_addparam_result = groupSyncWriteAddParam(group_num, DXL6_ID, servo(6,index), LEN_POSITION);
    dx7_addparam_result = groupSyncWriteAddParam(group_num, DXL7_ID, servo(7,index), LEN_POSITION);

    groupSyncWriteTxPacket(group_num);
    groupSyncWriteClearParam(group_num);  

    %% 动捕相机测得的实际关节角度
    iBody=1;
    frameOfData = mGetCurrentFrame() ;%获取当前帧动捕数据
    head_info(:,index)=frameOfData.BodyData(iBody).Segments(:,8);% Tx,Ty,Tz,Rx,Ry,Rz,Length
    link1_info(:,index)=frameOfData.BodyData(iBody).Segments(:,1);% Tx,Ty,Tz,Rx,Ry,Rz,Length
    link2_info(:,index)=frameOfData.BodyData(iBody).Segments(:,2);% Tx,Ty,Tz,Rx,Ry,Rz,Length
    link3_info(:,index)=frameOfData.BodyData(iBody).Segments(:,3);% Tx,Ty,Tz,Rx,Ry,Rz,Length
    link4_info(:,index)=frameOfData.BodyData(iBody).Segments(:,4);% Tx,Ty,Tz,Rx,Ry,Rz,Length
    link5_info(:,index)=frameOfData.BodyData(iBody).Segments(:,5);% Tx,Ty,Tz,Rx,Ry,Rz,Length
    link6_info(:,index)=frameOfData.BodyData(iBody).Segments(:,6);% Tx,Ty,Tz,Rx,Ry,Rz,Length
    link7_info(:,index)=frameOfData.BodyData(iBody).Segments(:,7);% Tx,Ty,Tz,Rx,Ry,Rz,Length

   
    t2=toc;
    elapsed=etime(clock,t1);
    pause(dt-elapsed);

end
% 
% %% 数据连续化
for i=1:size(link1_info,1)
    for j=1:size(link1_info,2)
    if (link1_info(i,j)>5000)||(link1_info(i,j)==0)
        link1_info(i,j)=link1_info(i-1,j);
    end
    if (link2_info(i,j)>5000)||(link2_info(i,j)==0)
        link2_info(i,j)=link2_info(i-1,j);
    end
    if (link3_info(i,j)>5000)||(link3_info(i,j)==0)
        link3_info(i,j)=link3_info(i-1,j);
    end
    if (link4_info(i,j)>5000)||(link4_info(i,j)==0)
        link4_info(i,j)=link4_info(i-1,j);
    end
    if (link5_info(i,j)>5000)||(link5_info(i,j)==0)
        link5_info(i,j)=link5_info(i-1,j);
    end
    if (link6_info(i,j)>5000)||(link6_info(i,j)==0)
        link6_info(i,j)=link6_info(i-1,j);
    end
    if (link7_info(i,j)>5000)||(link7_info(i,j)==0)
        link7_info(i,j)=link7_info(i-1,j);
    end
    if (head_info(i,j)>5000)||(head_info(i,j)==0)
        head_info(i,j)=head_info(i-1,j);
    end
    end
end



%% 连杆位置坐标
x1=link1_info(2,:);y1=link1_info(3,:);
x2=link2_info(2,:);y2=link2_info(3,:);
x3=link3_info(2,:);y3=link3_info(3,:);
x4=link4_info(2,:);y4=link4_info(3,:);
x5=link5_info(2,:);y5=link5_info(3,:);
x6=link6_info(2,:);y6=link6_info(3,:);
x7=link7_info(2,:);y7=link7_info(3,:);
x8=head_info(2,:);y8=head_info(3,:);
x=[x1;x2;x3;x4;x5;x6;x7;x8];
y=[y1;y2;y3;y4;y5;y6;y7;y8];
N=8;
e=ones(N,1);

for i=1:length(x1)

    xrobot(i)=(1/N)*e'*x(:,i);
    yrobot(i)=(1/N)*e'*y(:,i);

end
xy_follow3=[xrobot;yrobot];
save('xy_follow','xy_follow3');
plot(xrobot,yrobot)


%% 扫尾工作
% run('end_dxl');
exitValue = mCortexExit();
toc
