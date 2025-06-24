clear
clc
%------------------图像读取及预处理------------------%
I = imread('Lena.tif');
origin_I = double(I);  % 转换为 double 类型

%------------------生成秘密数据------------------%
num = 10000;
rand('seed',0); %设置种子
D = round(rand(1,num)*1); %产生稳定随机数

%------------------密钥与参数设置------------------%
Image_key = 1;
Data_key = 2;
ref_x = 1; %参考像素的行数
ref_y = 1; %参考像素的列数

%------------------图像加密与数据嵌入------------------%
[encrypt_I,stego_I,emD] = Encrypt_Embed(origin_I,D,Image_key,Data_key,ref_x,ref_y);

%------------------数据提取与图像恢复------------------%
num_emD = length(emD);
if num_emD > 0  
    [Side_Information,Refer_Value,Encrypt_exD,Map_I,sign] = Extract_Embedded_Data(stego_I,num,ref_x,ref_y);
    if sign == 1
        [exD] = Encrypt_Data(Encrypt_exD,Data_key);%数据解密
        [recover_I] = Restore_Image(stego_I,Image_key,Side_Information,Refer_Value,Map_I,num,ref_x,ref_y);%图像恢复
        %------------------图像展示------------------%
        t = tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
        nexttile; imshow(origin_I, []); title('原始图像');
        nexttile; imshow(encrypt_I, []); title('加密图像');
        nexttile; imshow(stego_I, []); title('载密图像');
        nexttile; imshow(recover_I, []); title('恢复图像');
        title(t, '图像处理流程可视化', 'FontWeight', 'bold');
 
        %------------------结果分析------------------%
        [m,n] = size(origin_I);
        bpp = num_emD/(m*n);
        
        check1 = isequal(emD,exD);
        check2 = isequal(origin_I,recover_I);

        %------------------信息输出------------------%
        fprintf('\n===== 嵌入提取与重构结果 =====\n');
        fprintf('原图尺寸：%d × %d\n', m, n);
        fprintf('图像加密密钥：%d\n数据加密密钥：%d\n', Image_key, Data_key);
        %fprintf('嵌入数据长度（bits）：%d\n嵌入率（bpp）：%.4f\n', num2str(num_emD), num2str(bpp));
        if check1 == 1
            disp('提取数据与嵌入数据一致')
        else
            disp('提取数据不一致！！！')
        end
        if check2 == 1
            disp('重构图像与原始图像一致')
        else
            disp('图像重构不一致！！！')
        end
 
        if check1 == 1 && check2 == 1
            disp(['嵌入容量: ' num2str(num_emD)])
            disp(['嵌入率（bpp）: ' num2str(bpp)])
            fprintf(['测试图像处理成功','\n\n']);
        else
            fprintf(['测试图像处理失败','\n\n']);
        end     
    else
        disp('无法提取全部辅助信息')
        fprintf(['测试图像处理失败','\n\n']);
    end
else
    disp('辅助信息大于总嵌入量，嵌入空间不足') 
    fprintf(['测试图像处理失败','\n\n']);
end

%% ======================辅助函数========================
%------------------二进制转十进制------------------%
function [decimal_Value] = Binary_Decimalism(binary_Array)
    % ----------------------------------------------------------
    % 函数：
    %   将二进制数组转换成十进制整数
    % 输入：
    %   binary_Array 二进制数组
    % 输出：
    %   decimal_Value 十进制整数
    % ----------------------------------------------------------
    decimal_Value = 0;
    length_Binary = length(binary_Array);
    for i=1:length_Binary
        decimal_Value = decimal_Value + binary_Array(i)*(2^(length_Binary-i));
    end
end

%------------------十进制转二进制------------------%
function [binary_Array] = Decimalism_Binary(decimal_Value)
    % ----------------------------------------------------------
    % 函数：
    %   将十进制灰度像素值转换成8位二进制数组
    % 输入：
    %   decimal_Value 十进制灰度像素值
    % 输出：
    %   binary_Array 8位二进制数组
    % ----------------------------------------------------------
    binary_Array = dec2bin(decimal_Value)-'0';
    if length(binary_Array) < 8
        length_Binary = length(binary_Array);
        binary_Digits = binary_Array;
        binary_Array = zeros(1,8);
        for i=1:length_Binary
            binary_Array(8-length_Binary+i) = binary_Digits(i); %不足8位前面补充0
        end 
    end
end
% =========================辅助函数===========================

%% ====================图像预测阶段======================

function [origin_PV_I] = Predictor_Value(origin_I,ref_x,ref_y)  
    % ----------------------------------------------------------
    % 函数：
    %   计算origin_I的预测值
    % 输入：
    %   origin_I 原始图像矩阵（double 类型）
    %   ref_x,ref_y 用作参考的行列边界
    % 输出：
    %   origin_PV_I 与原图像尺寸相同的预测值矩阵
    [rows, cols] = size(origin_I);               % 获取图像尺寸
    origin_PV_I = origin_I;                      % 初始化预测矩阵（默认复制原图）

    % 遍历非参考区域像素
    for rowIdx = ref_x + 1 : rows
        for colIdx = ref_y + 1 : cols
            % 三个邻近像素作为预测依据
            top    = origin_I(rowIdx - 1, colIdx);      % 上方像素
            topLeft = origin_I(rowIdx - 1, colIdx - 1); % 左上像素
            left   = origin_I(rowIdx, colIdx - 1);      % 左侧像素
            
             % 根据预测函数规则进行判断（边缘保留预测）
            if topLeft <= min(top, left)
                origin_PV_I(rowIdx, colIdx) = max(top, left);
            elseif topLeft >= max(top, left)
                origin_PV_I(rowIdx, colIdx) = min(top, left);
            else
                origin_PV_I(rowIdx, colIdx) = top + left - topLeft;
            end
        end
    end
end
% =======================图像预测阶段=========================


%% =================自适应的哈夫曼编码====================

%------------------编码------------------%
function [Code,Code_Bin] = Huffman_Code(num_Map_origin_I)
    %------------------------------------------------------
    % 函数：
    %   用变长编码(多位0/1编码)表示像素值的标记类别,为9类像素标记分配哈夫曼编码
    % 输入：
    %   num_Map_origin_I 9类标记及其频率统计 (9×2矩阵)
    % 输出：
    %   Code 映射表（左列：类别；右列：编码整数）
    %   Code_Bin 映射表编码的二进制比特流（1D向量）
    % 编码表说明：
    %   用{00,01,100,101,1100,1101,1110,11110,11111}这9中编码来表示9种标记类别
    %   <=> {0,1,4,...,31}
    %   类别频率越高，编码越短（预定义编码值）
    % 求其映射编码关系
    %------------------------------------------------------
    
    % 定义固定的 9 个编码值（整数）
    Code = [-2,0;-2,1;-2,4;-2,5;-2,12;-2,13;-2,14;-2,30;-2,31]; 
    for i=1:9
        drder=1;
        for j=1:9
            if num_Map_origin_I(i,2) < num_Map_origin_I(j,2)
                drder = drder + 1; %排序寻找最小值
            end
        end
        while Code(drder) ~= -2 %防止两种标记类别中像素的个数相等
            drder = drder + 1; 
        end
        Code(drder,1) = num_Map_origin_I(i,1); %第一列从小到大排列了出现的标记顺序
    end
    %------------------ 编码转换为比特流 ------------------%
    Code_Bin = zeros(); % 预分配
    idx = 0; %计数
    for i=0:8
        for j=1:9
            if Code(j,1) == i
                value = Code(j,2);
            end
        end
        if value == 0
            Code_Bin(idx+1:idx+2) = [0, 0];        
            idx = idx+2;
        elseif value == 1
            Code_Bin(idx+1:idx+2) = [0, 1];
            idx = idx+2;
        else 
            add = ceil(log2(value+1)); %标记编码的长度
            Code_Bin(idx+1:idx+add) = dec2bin(value)-'0'; %转换成二进制数组
            idx = idx + add;
        end     
    end
end

%------------------解码------------------%
function [decoded_value, end_pos] = Huffman_DeCode(bit_stream, start_pos)
    %------------------------------------------------------
    % 函数：
    %   解码二进制比特流bit_stream中下一个Huffman编码对应的整数值
    % 输入：
    %   bit_stream 二进制映射序列
    %   start_pos 上一个映射结束的位置
    % 输出：
    %   decoded_value 十进制整数值 ∈ {0,1,4,5,12,13,14,30,31}
    %   end_pos 本次解码结束的位置
    %------------------------------------------------------   
    stream_length = length(bit_stream);
    current_pos = start_pos + 1;
    bit_counter = 0; % 计数
    
    if current_pos <= stream_length
        if current_pos+1 <= stream_length && bit_stream(current_pos) == 0 % →0
            bit_counter = bit_counter + 1;
            if bit_stream(current_pos+1) == 0 % →00表示0
                bit_counter = bit_counter + 1;
                decoded_value = 0;
            elseif bit_stream(current_pos+1) == 1 % →01表示1
                bit_counter = bit_counter + 1;
                decoded_value = 1;
            end
        else  % bit_stream(current_pos)==1
            if current_pos+2 <= stream_length && bit_stream(current_pos+1) == 0 % →10
                bit_counter = bit_counter + 2;
                if bit_stream(current_pos+2) == 0  % →100表示4
                    bit_counter = bit_counter + 1;
                    decoded_value = 4;
                elseif bit_stream(current_pos+2) == 1 % →101表示5
                    bit_counter = bit_counter + 1;
                    decoded_value = 5;
                end
            else % bit_stream(current_pos+1)==1
                if current_pos+3 <= stream_length && bit_stream(current_pos+2) == 0  % →110
                    bit_counter = bit_counter + 3;
                    if bit_stream(current_pos+3) == 0  % →1100表示12
                        bit_counter = bit_counter + 1;
                        decoded_value = 12;
                    elseif bit_stream(current_pos+3) == 1  % →1101表示13
                        bit_counter = bit_counter + 1;
                        decoded_value = 13;
                    end
                else % bit_stream(current_pos+2)==1
                    if current_pos+3 <= stream_length
                        bit_counter = bit_counter + 3;
                        if bit_stream(current_pos+3) == 0  % →1110表示14
                            bit_counter = bit_counter + 1;
                            decoded_value = 14;
                        elseif current_pos+4 <= stream_length && bit_stream(current_pos+3) == 1  % →1111
                            bit_counter = bit_counter + 1;
                            if bit_stream(current_pos+4) == 0  % →11110表示30
                                bit_counter = bit_counter + 1;
                                decoded_value = 30;
                            elseif bit_stream(current_pos+4) == 1  % →11111表示31
                                bit_counter = bit_counter + 1;
                                decoded_value = 31;
                            end
                        else
                            bit_counter = 0;   
                            decoded_value = -1; % 辅助信息长度不够，无法恢复下一个Huffman编码
                        end
                    else
                        bit_counter = 0;
                        decoded_value = -1; % 辅助信息长度不够，无法恢复下一个Huffman编码
                    end
                end
            end
        end
    else
        bit_counter = 0;               
        decoded_value = -1; % 辅助信息长度不够，无法恢复下一个Huffman编码
    end
    end_pos = start_pos + bit_counter;
end
% =====================自适应的哈夫曼编码======================


%% ===================图像加密阶段======================
%------------------图像------------------%
function [encrypt_I] = Encrypt_Image(origin_I,Image_key)
    % --------------------------------------------------------
    % 函数：
    %   对输入图像 origin_I 进行 bit-level 异或加密
    % 输入：
    %   origin_I 原始图像矩阵
    %   Image_key 图像加密密钥（用于伪随机生成器种子）
    % 输出：
    %   encrypt_I 加密后的图像矩阵
    % --------------------------------------------------------
    [row,col] = size(origin_I); % 获取图像尺寸
    encrypt_I = origin_I;  
    rand('seed',Image_key);     % 设置伪随机种子
    E = round(rand(row,col)*255);  % 生成同尺寸随机矩阵（整数）
    for i=1:row  % 根据E对图像origin_I进行bit加密
        for j=1:col
            encrypt_I(i,j) = bitxor(origin_I(i,j),E(i,j));
        end
    end
end

%------------------信息------------------%
function [Encrypt_D] = Encrypt_Data(D,Data_key)
    % --------------------------------------------------------
    % 函数：
    %   对一维二进制秘密数据 D 进行 bit-level 异或加密
    % 输入参数：
    %   D 待加密的数据向量（0/1）
    %   Data_key 密钥（用于随机数生成器）
    % 输出参数：
    %   Encrypt_D 加密后数据向量（0/1）
    % --------------------------------------------------------
    
    num_D = length(D); % 数据长度
    Encrypt_D = D;     % 存储加密秘密信息
    rand('seed',Data_key); % 设置种子
    E = round(rand(1,num_D)*1); % 生成 0/1 随机序列
    for i=1:num_D % 向量化异或操作  
        Encrypt_D(i) = bitxor(D(i),E(i));
    end
end

% =======================图像加密阶段========================


%% ====================位图嵌入阶段======================
%------------------位图标记--------------------%
function [Map_origin_I] = Category_Mark(origin_PV_I,origin_I,ref_x,ref_y)
    % ---------------------------------------------------------------
    % 函数：
    %   对每个像素计算预测误差位数，生成其对应的类别标记图（位图）
    % 输入参数：
    %   origin_PV_I 预测图像
    %   origin_I 原始图像
    %   ref_x, ref_y 用于指定参考像素范围
    % 输出参数：
    %   Map_origin_I 位图标记图（值为0-8或-1）
    % ---------------------------------------------------------------
    
    [row,col] = size(origin_I); 
    Map_origin_I = origin_I;  %构建存储origin_I标记的容器
    for r=1:row
        for c=1:col
            if r<=ref_x || c<=ref_y       %前ref_x行、前ref_y-参考像素
                Map_origin_I(r,c) = -1;   %标记为-1是为了与下面产生的t=7时ca=0情况分开，两种情况都不能嵌入数据，但是参考像素不必恢复，非参考像素需要在恢复操作中被遍历
            else
                x = origin_I(r,c);         % 实际值
                pv = origin_PV_I(r,c);     % 预测值
                for t = 7 : -1 : 0
                    if floor(x/(2^t)) ~= floor(pv/(2^t))  % 函数向下取整
                        ca = 8-t-1;        % 记录像素值的标记类别
                        break;
                    else
                        ca = 8;            % 默认标记（全相同）
                    end
                end
                Map_origin_I(r,c) = ca; 
            end        
        end
    end

end

%------------------二进制转化------------------%
function [Map_Bin] = Map_Binary(Map_origin_I,Code)
    % ---------------------------------------------------------------
    % 函数：
    %   将位图 Map_origin_I 转换为压缩的二进制流（根据映射 Code）
    % 输入参数：
    %   Map_origin_I 图像中每个像素的位图类别（0-8, -1）
    %   Code 每个类别对应的变长编码（9×2）
    % 输出参数：
    %   Map_Bin 压缩后的二进制向量
    % ---------------------------------------------------------------

    [row,col] = size(Map_origin_I); %计算Map_origin_II的行列值
    Map_Bin = zeros();
    idx = 0; %计数，二进制数组的长度
    for r=1:row 
        for c=1:col
            if Map_origin_I(r,c) == -1 %标为-1的点是作为参考像素，不统计
                continue;
            end
            for k=1:9
                if Map_origin_I(r,c) == Code(k,1)
                    code_val = Code(k,2);
                    break;
                end
            end
            if code_val == 0
                Map_Bin(idx+1:idx+2) = [0, 0];
                idx = idx+2;
            elseif code_val == 1
                Map_Bin(idx+1:idx+2) = [0, 1];
                idx = idx+2;
            else
                add = ceil(log2(code_val+1)); %表示标记编码的长度
                Map_Bin(idx+1:idx+add) = dec2bin(code_val)-'0'; %将value转换成二进制数组
                idx = idx + add;
            end 
        end
    end
end
% ========================位图嵌入阶段========================


%% ====================信息嵌入阶段======================
%------------------根据位图嵌入秘密信息和辅助信息------------------%
function [stego_I,emD] = Embed_Data(encrypt_I,Map_origin_I,Side_Information,D,Data_key,ref_x,ref_y)
    %---------------------------------------------------------------
    % 函数：
    %   根据位置图Map_origin_I，将辅助信息、参考像素信息和加密秘密数据嵌入到加密图像中
    % 输入：
    %   encrypt_I 输入图像（已加密）
    %   Map_origin_I 位图类别（0~8或-1）
    %   Side_Information 辅助信息（bit向量）
    %   D 原始秘密信息（bit向量）
    %   Data_key 加密数据密钥
    %   ref_x, ref_y 参考像素边界
    % 输出：
    %   stego_I 嵌入后图像
    %   emD 实际成功嵌入的秘密数据
    %---------------------------------------------------------------
    stego_I = encrypt_I;
    [row,col] = size(encrypt_I); 
    %% 1. 对秘密数据加密
    [Encrypt_D] = Encrypt_Data(D,Data_key);
    %% 2. 提取参考像素的原始值（二进制）
    Refer_Value = zeros(); 
    idx = 0; %计数
    for r=1:row
        for c=1:ref_y
            value = encrypt_I(r,c);
            [bin2_8] = Decimalism_Binary(value); %将十进制整数转换成8位二进制数组
            Refer_Value(idx+1:idx+8) = bin2_8; %因为t=0，所以从t+1开始
            idx = idx + 8; 
        end
    end
    for r=1:ref_x
        for c=ref_y+1:col
            value = encrypt_I(r,c);
            [bin2_8] = Decimalism_Binary(value); %将十进制整数转换成8位二进制数组
            Refer_Value(idx+1:idx+8) = bin2_8;
            idx = idx + 8; 
        end
    end 
    %% 3. 初始化指针
    num_D = length(D); 
    num_S = length(Side_Information); 
    num_RV = length(Refer_Value); 

    ptr_D = 0; 
    ptr_S = 0;
    ptr_R = 0; 
    %% 4. 在参考像素区域嵌入辅助信息
    for r=1:row
        for c=1:ref_y
            bin2_8 = Side_Information(ptr_S+1:ptr_S+8);
            [value] = Binary_Decimalism(bin2_8); %将8位二进制数组转换成十进制整数
            stego_I(r,c) = value;
            ptr_S = ptr_S + 8;
        end
    end
    for r=1:ref_x
        for c=ref_y+1:col
            bin2_8 = Side_Information(ptr_S+1:ptr_S+8);
            [value] = Binary_Decimalism(bin2_8);
            stego_I(r,c) = value;
            ptr_S = ptr_S + 8;
        end
    end
    %% 5. 嵌入阶段
    for r=ref_x+1:row  
        for c=ref_y+1:col 
            if ptr_D >= num_D %秘密数据已嵌完
                break;
            end
            %Map=0-原始像素值的第1MSB与其预测值相反
            %Map=1-原始像素值的第2MSB与其预测值相反
            %Map=2-原始像素值的第3MSB与其预测值相反
            %Map=3-原始像素值的第4MSB与其预测值相反
            %Map=4-原始像素值的第5MSB与其预测值相反
            %Map=5-原始像素值的第6MSB与其预测值相反
            %Map=6-原始像素值的第7MSB与其预测值相反
            
            %------像素点可嵌入 1 bit信息------%
            if Map_origin_I(r,c) == 0  
                if ptr_S < num_S %辅助信息没有嵌完
                    ptr_S = ptr_S + 1;
                    stego_I(r,c) = mod(stego_I(r,c),2^7) + Side_Information(ptr_S)*(2^7); %替换1位MSB
                else
                    if ptr_R < num_RV %参考像素二进制序列信息没有嵌完
                        ptr_R = ptr_R + 1;
                        stego_I(r,c) = mod(stego_I(r,c),2^7) + Refer_Value(ptr_R)*(2^7); %替换1位MSB
                    else %最后嵌入秘密信息
                        ptr_D = ptr_D + 1;
                        stego_I(r,c) = mod(stego_I(r,c),2^7) + Encrypt_D(ptr_D)*(2^7); %替换1位MSB
                    end       
                end
            %------像素点可嵌入 2 bit信息------%
            elseif Map_origin_I(r,c) == 1    
                if ptr_S < num_S 
                    if ptr_S+2 <= num_S 
                        ptr_S = ptr_S + 2;
                        stego_I(r,c) = mod(stego_I(r,c),2^6) + Side_Information(ptr_S-1)*(2^7) + Side_Information(ptr_S)*(2^6); %替换2位MSB
                    else
                        ptr_S = ptr_S + 1; 
                        ptr_R = ptr_R + 1; 
                        stego_I(r,c) = mod(stego_I(r,c),2^6) + Side_Information(ptr_S)*(2^7) + Refer_Value(ptr_R)*(2^6); %替换2位MSB
                    end
                else
                    if ptr_R < num_RV 
                        if ptr_R+2 <= num_RV 
                            ptr_R = ptr_R + 2;
                            stego_I(r,c) = mod(stego_I(r,c),2^6) + Refer_Value(ptr_R-1)*(2^7) + Refer_Value(ptr_R)*(2^6); %替换2位MSB
                        else
                            ptr_R = ptr_R + 1; 
                            ptr_D = ptr_D + 1; 
                            stego_I(r,c) = mod(stego_I(r,c),2^6) + Refer_Value(ptr_R)*(2^7) + Encrypt_D(ptr_D)*(2^6); %替换2位MSB
                        end
                    else
                        if ptr_D+2 <= num_D
                            ptr_D = ptr_D + 2; 
                            stego_I(r,c) = mod(stego_I(r,c),2^6) + Encrypt_D(ptr_D-1)*(2^7) + Encrypt_D(ptr_D)*(2^6); %替换2位MSB
                        else
                            ptr_D = ptr_D + 1; 
                            stego_I(r,c) = mod(stego_I(r,c),2^7) + Encrypt_D(ptr_D)*(2^7); %替换1位MSB
                        end   
                    end
                end
            %------像素点可嵌入 3 bit信息------%
            elseif Map_origin_I(r,c) == 2  
                bin2_8 = zeros(1,8); 
                if ptr_S < num_S 
                    if ptr_S+3 <= num_S 
                        bin2_8(1:3) = Side_Information(ptr_S+1:ptr_S+3); 
                        ptr_S = ptr_S + 3;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(r,c) = mod(stego_I(r,c),2^5) + value; 
                    else
                        idx = num_S - ptr_S; 
                        bin2_8(1:idx) = Side_Information(ptr_S+1:num_S); 
                        ptr_S = ptr_S + idx;
                        bin2_8(idx+1:3) = Refer_Value(ptr_R+1:ptr_R+3-idx); 
                        ptr_R = ptr_R + 3-idx;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(r,c) = mod(stego_I(r,c),2^5) + value; 
                    end
                else
                    if ptr_R < num_RV  
                        if ptr_R+3 <= num_RV 
                            bin2_8(1:3) = Refer_Value(ptr_R+1:ptr_R+3); 
                            ptr_R = ptr_R + 3;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^5) + value; 
                        else
                            idx = num_RV - ptr_R; 
                            bin2_8(1:idx) = Refer_Value(ptr_R+1:num_RV); 
                            ptr_R = ptr_R + idx;
                            bin2_8(idx+1:3) = Encrypt_D(ptr_D+1:ptr_D+3-idx); 
                            ptr_D = ptr_D + 3-idx;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^5) + value; 
                        end 
                    else
                        if ptr_D+3 <= num_D
                            bin2_8(1:3) = Encrypt_D(ptr_D+1:ptr_D+3); 
                            ptr_D = ptr_D + 3;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^5) + value; 
                        else
                            idx = num_D - ptr_D; 
                            bin2_8(1:idx) = Encrypt_D(ptr_D+1:ptr_D+idx);
                            ptr_D = ptr_D + idx;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^(8-idx)) + value; 
                        end 
                    end
                end   
            %------像素点可嵌入 4 bit信息------%    
            elseif Map_origin_I(r,c) == 3  
                bin2_8 = zeros(1,8); 
                if ptr_S < num_S 
                    if ptr_S+4 <= num_S 
                        bin2_8(1:4) = Side_Information(ptr_S+1:ptr_S+4); 
                        ptr_S = ptr_S + 4;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(r,c) = mod(stego_I(r,c),2^4) + value; 
                    else
                        idx = num_S - ptr_S; 
                        bin2_8(1:idx) = Side_Information(ptr_S+1:num_S); 
                        ptr_S = ptr_S + idx;
                        bin2_8(idx+1:4) = Refer_Value(ptr_R+1:ptr_R+4-idx);
                        ptr_R = ptr_R + 4-idx;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(r,c) = mod(stego_I(r,c),2^4) + value; 
                    end
                else
                    if ptr_R < num_RV
                        if ptr_R+4 <= num_RV 
                            bin2_8(1:4) = Refer_Value(ptr_R+1:ptr_R+4); 
                            ptr_R = ptr_R + 4;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^4) + value;
                        else
                            idx = num_RV - ptr_R; 
                            bin2_8(1:idx) = Refer_Value(ptr_R+1:num_RV);
                            ptr_R = ptr_R + idx;
                            bin2_8(idx+1:4) = Encrypt_D(ptr_D+1:ptr_D+4-idx);
                            ptr_D = ptr_D + 4-idx;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^4) + value; 
                        end 
                    else
                        if ptr_D+4 <= num_D
                            bin2_8(1:4) = Encrypt_D(ptr_D+1:ptr_D+4); 
                            ptr_D = ptr_D + 4;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^4) + value;
                        else
                            idx = num_D - ptr_D;
                            bin2_8(1:idx) = Encrypt_D(ptr_D+1:ptr_D+idx);
                            ptr_D = ptr_D + idx;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^(8-idx)) + value;
                        end 
                    end
                end    
            %------像素点可嵌入 5 bit信息------%    
            elseif Map_origin_I(r,c) == 4 
                bin2_8 = zeros(1,8); 
                if ptr_S < num_S 
                    if ptr_S+5 <= num_S 
                        bin2_8(1:5) = Side_Information(ptr_S+1:ptr_S+5); 
                        ptr_S = ptr_S + 5;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(r,c) = mod(stego_I(r,c),2^3) + value;
                    else
                        idx = num_S - ptr_S; 
                        bin2_8(1:idx) = Side_Information(ptr_S+1:num_S);
                        ptr_S = ptr_S + idx;
                        bin2_8(idx+1:5) = Refer_Value(ptr_R+1:ptr_R+5-idx); 
                        ptr_R = ptr_R + 5-idx;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(r,c) = mod(stego_I(r,c),2^3) + value; 
                    end
                else
                    if ptr_R < num_RV  
                        if ptr_R+5 <= num_RV 
                            bin2_8(1:5) = Refer_Value(ptr_R+1:ptr_R+5); 
                            ptr_R = ptr_R + 5;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^3) + value; 
                        else
                            idx = num_RV - ptr_R; 
                            bin2_8(1:idx) = Refer_Value(ptr_R+1:num_RV); 
                            ptr_R = ptr_R + idx;
                            bin2_8(idx+1:5) = Encrypt_D(ptr_D+1:ptr_D+5-idx); 
                            ptr_D = ptr_D + 5-idx;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^3) + value; 
                        end 
                    else
                        if ptr_D+5 <= num_D
                            bin2_8(1:5) = Encrypt_D(ptr_D+1:ptr_D+5); 
                            ptr_D = ptr_D + 5;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^3) + value; 
                        else
                            idx = num_D - ptr_D; 
                            bin2_8(1:idx) = Encrypt_D(ptr_D+1:ptr_D+idx);
                            ptr_D = ptr_D + idx;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^(8-idx)) + value; 
                        end 
                    end
                end           
            %------像素点可嵌入 6 bit信息------%    
            elseif Map_origin_I(r,c) == 5  
                bin2_8 = zeros(1,8); 
                if ptr_S < num_S
                    if ptr_S+6 <= num_S 
                        bin2_8(1:6) = Side_Information(ptr_S+1:ptr_S+6); 
                        ptr_S = ptr_S + 6;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(r,c) = mod(stego_I(r,c),2^2) + value; 
                    else
                        idx = num_S - ptr_S;
                        bin2_8(1:idx) = Side_Information(ptr_S+1:num_S);
                        ptr_S = ptr_S + idx;
                        bin2_8(idx+1:6) = Refer_Value(ptr_R+1:ptr_R+6-idx);
                        ptr_R = ptr_R + 6-idx;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(r,c) = mod(stego_I(r,c),2^2) + value;
                    end
                else
                    if ptr_R < num_RV 
                        if ptr_R+6 <= num_RV 
                            bin2_8(1:6) = Refer_Value(ptr_R+1:ptr_R+6); 
                            ptr_R = ptr_R + 6;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^2) + value; 
                        else
                            idx = num_RV - ptr_R;
                            bin2_8(1:idx) = Refer_Value(ptr_R+1:num_RV);
                            ptr_R = ptr_R + idx;
                            bin2_8(idx+1:6) = Encrypt_D(ptr_D+1:ptr_D+6-idx);
                            ptr_D = ptr_D + 6-idx;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^2) + value;
                        end 
                    else
                        if ptr_D+6 <= num_D
                            bin2_8(1:6) = Encrypt_D(ptr_D+1:ptr_D+6);
                            ptr_D = ptr_D + 6;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^2) + value;
                        else
                            idx = num_D - ptr_D;
                            bin2_8(1:idx) = Encrypt_D(ptr_D+1:ptr_D+idx);
                            ptr_D = ptr_D + idx;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^(8-idx)) + value;
                        end 
                    end
                end      
            %------像素点可嵌入 7 bit信息------%    
            elseif Map_origin_I(r,c) == 6 
                bin2_8 = zeros(1,8);
                if ptr_S < num_S 
                    if ptr_S+7 <= num_S
                        bin2_8(1:7) = Side_Information(ptr_S+1:ptr_S+7); 
                        ptr_S = ptr_S + 7;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(r,c) = mod(stego_I(r,c),2^1) + value;
                    else
                        idx = num_S - ptr_S;
                        bin2_8(1:idx) = Side_Information(ptr_S+1:num_S);
                        ptr_S = ptr_S + idx;
                        bin2_8(idx+1:7) = Refer_Value(ptr_R+1:ptr_R+7-idx);
                        ptr_R = ptr_R + 7-idx;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(r,c) = mod(stego_I(r,c),2^1) + value;
                    end
                else
                    if ptr_R < num_RV 
                        if ptr_R+7 <= num_RV
                            bin2_8(1:7) = Refer_Value(ptr_R+1:ptr_R+7); 
                            ptr_R = ptr_R + 7;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^1) + value;
                        else
                            idx = num_RV - ptr_R;
                            bin2_8(1:idx) = Refer_Value(ptr_R+1:num_RV);
                            ptr_R = ptr_R + idx;
                            bin2_8(idx+1:7) = Encrypt_D(ptr_D+1:ptr_D+7-idx);
                            ptr_D = ptr_D + 7-idx;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^1) + value;
                        end 
                    else
                        if ptr_D+7 <= num_D
                            bin2_8(1:7) = Encrypt_D(ptr_D+1:ptr_D+7);
                            ptr_D = ptr_D + 7;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^1) + value;
                        else
                            idx = num_D - ptr_D;
                            bin2_8(1:idx) = Encrypt_D(ptr_D+1:ptr_D+idx);
                            ptr_D = ptr_D + idx;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^(8-idx)) + value;
                        end 
                    end
                end           
            %------像素点可嵌入 8 bit信息------%    
            elseif Map_origin_I(r,c) == 7 || Map_origin_I(r,c) == 8 
                bin2_8 = zeros(1,8); 
                if ptr_S < num_S 
                    if ptr_S+8 <= num_S
                        bin2_8(1:8) = Side_Information(ptr_S+1:ptr_S+8); 
                        ptr_S = ptr_S + 8;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(r,c) = value;
                    else
                        idx = num_S - ptr_S;
                        bin2_8(1:idx) = Side_Information(ptr_S+1:num_S);
                        ptr_S = ptr_S + idx;
                        bin2_8(idx+1:8) = Refer_Value(ptr_R+1:ptr_R+8-idx);
                        ptr_R = ptr_R + 8-idx;
                        [value] = Binary_Decimalism(bin2_8);
                        stego_I(r,c) = value; 
                    end
                else
                    if ptr_R < num_RV
                        if ptr_R+8 <= num_RV 
                            bin2_8(1:8) = Refer_Value(ptr_R+1:ptr_R+8); 
                            ptr_R = ptr_R + 8;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = value;
                        else
                            idx = num_RV - ptr_R;
                            bin2_8(1:idx) = Refer_Value(ptr_R+1:num_RV); 
                            ptr_R = ptr_R + idx;
                            bin2_8(idx+1:8) = Encrypt_D(ptr_D+1:ptr_D+8-idx);
                            ptr_D = ptr_D + 8-idx;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = value; 
                        end 
                    else
                        if ptr_D+8 <= num_D
                            bin2_8(1:8) = Encrypt_D(ptr_D+1:ptr_D+8);  
                            ptr_D = ptr_D + 8;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = value; 
                        else
                            idx = num_D - ptr_D; 
                            bin2_8(1:idx) = Encrypt_D(ptr_D+1:ptr_D+idx); 
                            ptr_D = ptr_D + idx;
                            [value] = Binary_Decimalism(bin2_8);
                            stego_I(r,c) = mod(stego_I(r,c),2^(8-idx)) + value; 
                        end 
                    end
                end         
            end
        end
    end
    %% 6. 返回已嵌入的秘密数据
    emD = D(1:ptr_D);
end
% ========================信息嵌入阶段========================


%% ================对原图像的加密和嵌入全过程================
function [encrypted_Img,stego_Img,embedded_Data] = Encrypt_Embed(input_Img,data_To_Embed,img_Encryption_Key,data_Encryption_Key,reference_x,reference_y)
    %---------------------------------------------------------------
    % 函数：
    %   将原始图像input_Img加密并嵌入数据
    % 输入：
    %   input_Img 原始图像
    %   data_To_Embed 要嵌入的数据
    %   img_Encryption_Key, data_Encryption_Key 密钥
    %   reference_x, reference_y 参考像素的行列数
    % 输出：
    %   encrypted_Img 加密图像 
    %   stego_Img 加密标记图像
    %   embedded_Data 嵌入的数据
    %---------------------------------------------------------------
    % 计算input_Img的预测值
    [predicted_Img] = Predictor_Value(input_Img,reference_x,reference_y); 
    % 对每个像素值进行标记（即原始图像的位置图）
    [pixel_Category_Map] = Category_Mark(predicted_Img,input_Img,reference_x,reference_y);
    % 将像素值的标记类别进行Huffman编码标记
    histogram_Category = tabulate(pixel_Category_Map(:)); %统计每个标记类别的像素值个数
    category_Count = zeros(9,2);
    for i=1:9  % 9种类别的标记
        category_Count(i,1) = i-1;   % category_Count=[0 0;1 0;2 0;3 0;4 0;5 0;6 0;7 0;8 0]
    end
    [m,~] = size(histogram_Category);
    for i=1:9
        for j=2:m %histogram_Category第一行统计的是参考像素的个数
            if category_Count(i,1) == histogram_Category(j,1)
                category_Count(i,2) = histogram_Category(j,2);  %去掉参考像素信息，只统计标记类别信息
            end
        end
    end
    [huffman_Codes,huffman_Bin] = Huffman_Code(category_Count); %计算标记的映射关系及其二进制序列表示
    % 将位置图pixel_Category_Map转换成二进制数组
    [category_Binary] = Map_Binary(pixel_Category_Map,huffman_Codes);
    % 计算存储Map_Binary长度需要的信息长度
    [img_rows,img_cols]=size(input_Img); 
    max_bits = ceil(log2(img_rows)) + ceil(log2(img_cols)) + 2; %用这么长的二进制表示Map_Binary的长度 ceil()与floor相对，表示向上取整
    binary_Length = length(category_Binary);
    binary_Len_Bin = dec2bin(binary_Length)-'0'; %将binary_Length转换成二进制数组
    if length(binary_Len_Bin) < max_bits
        len = length(binary_Len_Bin);
        binary_Vector = binary_Len_Bin;
        binary_Len_Bin = zeros(1,max_bits);
        for i=1:len
            binary_Len_Bin(max_bits-len+i) = binary_Vector(i); %存储Map_Bin的长度信息
        end 
    end
    % 统计恢复时需要的辅助信息（huffman_Bin，binary_Len_Bin，category_Binary）
    auxiliary_Info = [huffman_Bin,binary_Len_Bin,category_Binary];
    % 对原始图像input_Img进行加密
    [encrypted_Img] = Encrypt_Image(input_Img,img_Encryption_Key);
    % 在encrypted_Img中嵌入信息
    [stego_Img,embedded_Data] = Embed_Data(encrypted_Img,pixel_Category_Map,auxiliary_Info,data_To_Embed,data_Encryption_Key,reference_x,reference_y);
end
% ===================对原图像的加密和嵌入全过程===================


%% ====================信息提取阶段======================
%------------------提取秘密信息--------------------%
function [aux_info, ref_value, encrypted_data, location_map, status] = Extract_Embedded_Data(marked_img, data_length, ref_rows, ref_cols)
    %---------------------------------------------------------------
    % 函数：
    %   从加密标记图像中提取嵌入的信息
    % 输入：
    %   marked_img 加密标记图像
    %   data_length 秘密信息的长度
    %   ref_rows, ref_cols 参考像素区域的行列数
    % 输出：
    %   aux_info 辅助信息
    %   ref_value 参考像素信息
    %   encrypted_data 加密的秘密信息
    %   location_map 位置图
    %   status 提取状态标志（1=成功，0=失败）
    %---------------------------------------------------------------
    [img_rows, img_cols] = size(marked_img); % 获取图像尺寸
    
    % 初始化位置图矩阵
    location_map = zeros(img_rows, img_cols); % 构建存储位置图的矩阵
    for i = 1:img_rows
        for j = 1:ref_cols
            location_map(i, j) = -1; % 前ref_cols列为参考像素，不进行标记
        end
    end
    for i = 1:ref_rows
        for j = ref_cols+1:img_cols       
            location_map(i, j) = -1; % 前ref_rows行为参考像素，不进行标记   
        end
    end
    
    % 提取前ref_cols列、前ref_rows行中的辅助信息
    aux_info = [];
    aux_counter = 0; % 统计提取的辅助信息位数
    
    % 提取前ref_cols列的辅助信息
    for i = 1:img_rows
        for j = 1:ref_cols
            pixel_val = marked_img(i, j);
            [bin_array] = Decimalism_Binary(pixel_val); % 将十进制整数转换成8位二进制数组
            aux_info(aux_counter+1:aux_counter+8) = bin_array;
            aux_counter = aux_counter + 8;  
        end
    end
    
    % 提取前ref_rows行的辅助信息
    for i = 1:ref_rows
        for j = ref_cols+1:img_cols
            pixel_val = marked_img(i, j);
            [bin_array] = Decimalism_Binary(pixel_val); % 将十进制整数转换成8位二进制数组
            aux_info(aux_counter+1:aux_counter+8) = bin_array;
            aux_counter = aux_counter + 8; 
        end
    end
    
    % 提取映射规则信息（前32位）
    mapping_rules_bin = aux_info(1:32); % 前32位是映射规则信息
    mapping_table = [0,-1; 1,-1; 2,-1; 3,-1; 4,-1; 5,-1; 6,-1; 7,-1; 8,-1];
    decode_end = 0;
    
    % 解码映射规则
    for i = 1:9 % 将二进制序列映射转换成整数映射
        last_pos = decode_end;
        [rule_value, decode_end] = Huffman_DeCode(mapping_rules_bin, last_pos);
        mapping_table(i, 2) = rule_value;
    end
    
    % 提取位置图二进制序列的长度信息
    max_bits = ceil(log2(img_rows)) + ceil(log2(img_cols)) + 2; % 二进制表示位置图长度所需的位数
    len_bin = aux_info(33:32+max_bits); % 前33到32+max_bits位是位置图二进制序列的长度信息
    map_length = 0; % 将二进制序列len_bin转换成十进制数
    
    for i = 1:max_bits
        map_length = map_length + len_bin(i)*(2^(max_bits-i));
    end
    
    % 辅助变量初始化
    aux_info_length = 32 + max_bits + map_length; % 辅助信息总长度
    ref_value = [];
    ref_bits = (ref_rows*img_rows + ref_cols*img_cols - ref_rows*ref_cols)*8; % 参考像素二进制序列信息的长度
    ref_counter = 0; % 统计提取的参考像素二进制序列信息位数
    encrypted_data = [];
    data_counter = 0; % 统计提取的秘密信息位数
    
    % 在非参考区域提取信息
    decode_start = 32 + max_bits; % 跳过前面的辅助信息
    status = 1; % 表示可以完全提取数据恢复图像
    
    for i = ref_rows+1:img_rows
        if status == 0 % 提取失败，提前终止
            break;
        end
        for j = ref_cols+1:img_cols
            if data_counter >= data_length % 秘密数据已提取完毕
                break;
            end
            
            % 将当前十进制像素值转换成8位二进制数组
            pixel_val = marked_img(i, j); 
            [bin_array] = Decimalism_Binary(pixel_val); 
            
            % 通过辅助信息计算当前像素点能提取多少bit的信息
            last_pos = decode_start;
            [map_val, decode_start] = Huffman_DeCode(aux_info, last_pos);
            if map_val == -1 % 辅助信息长度不足
                status = 0;
                break; 
            end
            
            % 查找映射值对应的编码
            for k = 1:9
                if map_val == mapping_table(k, 2)
                    location_map(i, j) = mapping_table(k, 1); % 当前像素的位置图信息
                    break;
                end
            end
            
            % 根据位置图信息提取不同数量的bit
            switch location_map(i, j)
                %---------提取1 bit信息---------%
                case 0
                    if aux_counter < aux_info_length % 辅助信息未提取完
                        aux_counter = aux_counter + 1;
                        aux_info(aux_counter) = bin_array(1);
                    else
                        if ref_counter < ref_bits % 参考像素信息未提取完
                            ref_counter = ref_counter + 1;
                            ref_value(ref_counter) = bin_array(1);
                        else % 提取秘密信息
                            data_counter = data_counter + 1;
                            encrypted_data(data_counter) = bin_array(1);
                        end
                    end
                %---------提取2 bit信息---------%
                case 1  
                    if aux_counter < aux_info_length % 辅助信息未提取完
                        if aux_counter+2 <= aux_info_length
                            aux_info(aux_counter+1:aux_counter+2) = bin_array(1:2);
                            aux_counter = aux_counter + 2;
                        else
                            aux_counter = aux_counter + 1; % 1bit辅助信息
                            aux_info(aux_counter) = bin_array(1);
                            ref_counter = ref_counter + 1; % 1bit参考像素信息
                            ref_value(ref_counter) = bin_array(2);                   
                        end
                    else
                        if ref_counter < ref_bits % 参考像素信息未提取完
                            if ref_counter+2 <= ref_bits
                                ref_value(ref_counter+1:ref_counter+2) = bin_array(1:2);
                                ref_counter = ref_counter + 2;
                            else
                                ref_counter = ref_counter + 1; % 1bit参考像素信息
                                ref_value(ref_counter) = bin_array(1);  
                                data_counter = data_counter + 1; % 1bit秘密信息
                                encrypted_data(data_counter) = bin_array(2);
                            end
                        else
                            if data_counter+2 <= data_length
                                encrypted_data(data_counter+1:data_counter+2) = bin_array(1:2); % 2bit秘密信息
                                data_counter = data_counter + 2;
                            else
                                data_counter = data_counter + 1; % 1bit秘密信息
                                encrypted_data(data_counter) = bin_array(1);
                            end
                        end
                    end 
                %---------提取3 bit信息---------%
                case 2  
                    if aux_counter < aux_info_length % 辅助信息未提取完
                        if aux_counter+3 <= aux_info_length
                            aux_info(aux_counter+1:aux_counter+3) = bin_array(1:3);
                            aux_counter = aux_counter + 3;
                        else
                            remaining = aux_info_length - aux_counter; % 剩余辅助信息位数
                            aux_info(aux_counter+1:aux_counter+remaining) = bin_array(1:remaining);
                            aux_counter = aux_counter + remaining;
                            ref_value(ref_counter+1:ref_counter+3-remaining) = bin_array(remaining+1:3);
                            ref_counter = ref_counter + 3-remaining;                 
                        end
                    else
                        if ref_counter < ref_bits % 参考像素信息未提取完
                            if ref_counter+3 <= ref_bits
                                ref_value(ref_counter+1:ref_counter+3) = bin_array(1:3);
                                ref_counter = ref_counter + 3;
                            else
                                remaining = ref_bits - ref_counter; % 剩余参考像素信息位数
                                ref_value(ref_counter+1:ref_counter+remaining) = bin_array(1:remaining);
                                ref_counter = ref_counter + remaining;
                                encrypted_data(data_counter+1:data_counter+3-remaining) = bin_array(remaining+1:3);
                                data_counter = data_counter + 3-remaining;
                            end
                        else
                            if data_counter+3 <= data_length
                                encrypted_data(data_counter+1:data_counter+3) = bin_array(1:3); % 3bit秘密信息
                                data_counter = data_counter + 3;
                            else
                                remaining = data_length - data_counter;
                                encrypted_data(data_counter+1:data_counter+remaining) = bin_array(1:remaining);
                                data_counter = data_counter + remaining; 
                            end
                        end
                    end
                %---------提取4 bit信息---------%
                case 3  
                    if aux_counter < aux_info_length % 辅助信息未提取完
                        if aux_counter+4 <= aux_info_length
                            aux_info(aux_counter+1:aux_counter+4) = bin_array(1:4);
                            aux_counter = aux_counter + 4;
                        else
                            remaining = aux_info_length - aux_counter; % 剩余辅助信息位数
                            aux_info(aux_counter+1:aux_counter+remaining) = bin_array(1:remaining);
                            aux_counter = aux_counter + remaining;
                            ref_value(ref_counter+1:ref_counter+4-remaining) = bin_array(remaining+1:4);
                            ref_counter = ref_counter + 4-remaining;                 
                        end
                    else
                        if ref_counter < ref_bits % 参考像素信息未提取完
                            if ref_counter+4 <= ref_bits
                                ref_value(ref_counter+1:ref_counter+4) = bin_array(1:4);
                                ref_counter = ref_counter + 4;
                            else
                                remaining = ref_bits - ref_counter; % 剩余参考像素信息位数
                                ref_value(ref_counter+1:ref_counter+remaining) = bin_array(1:remaining);
                                ref_counter = ref_counter + remaining;
                                encrypted_data(data_counter+1:data_counter+4-remaining) = bin_array(remaining+1:4);
                                data_counter = data_counter + 4-remaining;
                            end
                        else
                            if data_counter+4 <= data_length
                                encrypted_data(data_counter+1:data_counter+4) = bin_array(1:4); % 4bit秘密信息
                                data_counter = data_counter + 4;
                            else
                                remaining = data_length - data_counter;
                                encrypted_data(data_counter+1:data_counter+remaining) = bin_array(1:remaining);
                                data_counter = data_counter + remaining; 
                            end
                        end
                    end
                %---------提取5 bit信息---------%
                case 4 
                    if aux_counter < aux_info_length % 辅助信息未提取完
                        if aux_counter+5 <= aux_info_length
                            aux_info(aux_counter+1:aux_counter+5) = bin_array(1:5);
                            aux_counter = aux_counter + 5;
                        else
                            remaining = aux_info_length - aux_counter; % 剩余辅助信息位数
                            aux_info(aux_counter+1:aux_counter+remaining) = bin_array(1:remaining);
                            aux_counter = aux_counter + remaining;
                            ref_value(ref_counter+1:ref_counter+5-remaining) = bin_array(remaining+1:5);
                            ref_counter = ref_counter + 5-remaining;                 
                        end
                    else
                        if ref_counter < ref_bits % 参考像素信息未提取完
                            if ref_counter+5 <= ref_bits
                                ref_value(ref_counter+1:ref_counter+5) = bin_array(1:5);
                                ref_counter = ref_counter + 5;
                            else
                                remaining = ref_bits - ref_counter; % 剩余参考像素信息位数
                                ref_value(ref_counter+1:ref_counter+remaining) = bin_array(1:remaining);
                                ref_counter = ref_counter + remaining;
                                encrypted_data(data_counter+1:data_counter+5-remaining) = bin_array(remaining+1:5);
                                data_counter = data_counter + 5-remaining;
                            end
                        else
                            if data_counter+5 <= data_length
                                encrypted_data(data_counter+1:data_counter+5) = bin_array(1:5); % 5bit秘密信息
                                data_counter = data_counter + 5;
                            else
                                remaining = data_length - data_counter;
                                encrypted_data(data_counter+1:data_counter+remaining) = bin_array(1:remaining);
                                data_counter = data_counter + remaining; 
                            end
                        end
                    end
                %---------提取6 bit信息---------%
                case 5
                    if aux_counter < aux_info_length % 辅助信息未提取完
                        if aux_counter+6 <= aux_info_length
                            aux_info(aux_counter+1:aux_counter+6) = bin_array(1:6);
                            aux_counter = aux_counter + 6;
                        else
                            remaining = aux_info_length - aux_counter; % 剩余辅助信息位数
                            aux_info(aux_counter+1:aux_counter+remaining) = bin_array(1:remaining);
                            aux_counter = aux_counter + remaining;
                            ref_value(ref_counter+1:ref_counter+6-remaining) = bin_array(remaining+1:6);
                            ref_counter = ref_counter + 6-remaining;                 
                        end
                    else
                        if ref_counter < ref_bits % 参考像素信息未提取完
                            if ref_counter+6 <= ref_bits
                                ref_value(ref_counter+1:ref_counter+6) = bin_array(1:6);
                                ref_counter = ref_counter + 6;
                            else
                                remaining = ref_bits - ref_counter; % 剩余参考像素信息位数
                                ref_value(ref_counter+1:ref_counter+remaining) = bin_array(1:remaining);
                                ref_counter = ref_counter + remaining;
                                encrypted_data(data_counter+1:data_counter+6-remaining) = bin_array(remaining+1:6);
                                data_counter = data_counter + 6-remaining;
                            end
                        else
                            if data_counter+6 <= data_length
                                encrypted_data(data_counter+1:data_counter+6) = bin_array(1:6); % 6bit秘密信息
                                data_counter = data_counter + 6;
                            else
                                remaining = data_length - data_counter;
                                encrypted_data(data_counter+1:data_counter+remaining) = bin_array(1:remaining);
                                data_counter = data_counter + remaining; 
                            end
                        end
                    end
                %---------提取7 bit信息---------%
                case 6 
                    if aux_counter < aux_info_length % 辅助信息未提取完
                        if aux_counter+7 <= aux_info_length
                            aux_info(aux_counter+1:aux_counter+7) = bin_array(1:7);
                            aux_counter = aux_counter + 7;
                        else
                            remaining = aux_info_length - aux_counter; % 剩余辅助信息位数
                            aux_info(aux_counter+1:aux_counter+remaining) = bin_array(1:remaining);
                            aux_counter = aux_counter + remaining;
                            ref_value(ref_counter+1:ref_counter+7-remaining) = bin_array(remaining+1:7);
                            ref_counter = ref_counter + 7-remaining;                 
                        end
                    else
                        if ref_counter < ref_bits % 参考像素信息未提取完
                            if ref_counter+7 <= ref_bits
                                ref_value(ref_counter+1:ref_counter+7) = bin_array(1:7);
                                ref_counter = ref_counter + 7;
                            else
                                remaining = ref_bits - ref_counter; % 剩余参考像素信息位数
                                ref_value(ref_counter+1:ref_counter+remaining) = bin_array(1:remaining);
                                ref_counter = ref_counter + remaining;
                                encrypted_data(data_counter+1:data_counter+7-remaining) = bin_array(remaining+1:7);
                                data_counter = data_counter + 7-remaining;
                            end
                        else
                            if data_counter+7 <= data_length
                                encrypted_data(data_counter+1:data_counter+7) = bin_array(1:7); % 7bit秘密信息
                                data_counter = data_counter + 7;
                            else
                                remaining = data_length - data_counter;
                                encrypted_data(data_counter+1:data_counter+remaining) = bin_array(1:remaining);
                                data_counter = data_counter + remaining; 
                            end
                        end
                    end
                %---------提取8 bit信息---------%
                case {7, 8}
                    if aux_counter < aux_info_length % 辅助信息未提取完
                        if aux_counter+8 <= aux_info_length
                            aux_info(aux_counter+1:aux_counter+8) = bin_array(1:8);
                            aux_counter = aux_counter + 8;
                        else
                            remaining = aux_info_length - aux_counter; % 剩余辅助信息位数
                            aux_info(aux_counter+1:aux_counter+remaining) = bin_array(1:remaining);
                            aux_counter = aux_counter + remaining;
                            ref_value(ref_counter+1:ref_counter+8-remaining) = bin_array(remaining+1:8);
                            ref_counter = ref_counter + 8-remaining;                 
                        end
                    else
                        if ref_counter < ref_bits % 参考像素信息未提取完
                            if ref_counter+8 <= ref_bits
                                ref_value(ref_counter+1:ref_counter+8) = bin_array(1:8);
                                ref_counter = ref_counter + 8;
                            else
                                remaining = ref_bits - ref_counter; % 剩余参考像素信息位数
                                ref_value(ref_counter+1:ref_counter+remaining) = bin_array(1:remaining);
                                ref_counter = ref_counter + remaining;
                                encrypted_data(data_counter+1:data_counter+8-remaining) = bin_array(remaining+1:8);
                                data_counter = data_counter + 8-remaining;
                            end
                        else
                            if data_counter+8 <= data_length
                                encrypted_data(data_counter+1:data_counter+8) = bin_array(1:8); % 8bit秘密信息
                                data_counter = data_counter + 8;
                            else
                                remaining = data_length - data_counter;
                                encrypted_data(data_counter+1:data_counter+remaining) = bin_array(1:remaining);
                                data_counter = data_counter + remaining; 
                            end
                        end
                    end
            end
        end
    end
end
% ========================信息提取阶段========================

%% ====================图像恢复阶段======================
function [restored_img] = Restore_Image(encrypted_img,encryption_key,aux_info,ref_vals,pos_map,msg_len,ref_rows,ref_cols)
    %---------------------------------------------------------------
    % 函数：
    %   根据提取的辅助信息恢复图像
    % 输入：
    %   encrypted_img 载密图像
    %   encryption_key 图像加密密钥
    %   aux_info 辅助信息
    %   ref_vals 参考像素信息
    %   pos_map 位置图
    %   msg_len 秘密信息的长度
    %   ref_rows, ref_cols 参考像素的行列数
    % 输出：
    %   restored_img 恢复图像
    %---------------------------------------------------------------    
    [img_rows,img_cols] = size(encrypted_img); %统计encrypted_img的行列数
    % 根据ref_vals恢复前ref_cols列、前ref_rows行的参考像素
    ref_pixels = encrypted_img;
    counter = 0; %计数
    for i=1:img_rows
        for j=1:ref_cols
            bin_segment = ref_vals(counter+1:counter+8);
            [pixel_val] = Binary_Decimalism(bin_segment); %将8位二进制数组转换成十进制整数
            ref_pixels(i,j) = pixel_val;
            counter = counter + 8;
        end
    end
    for i=1:ref_rows
        for j=ref_cols+1:img_cols
            bin_segment = ref_vals(counter+1:counter+8);
            [pixel_val] = Binary_Decimalism(bin_segment); %将8位二进制数组转换成十进制整数
            ref_pixels(i,j) = pixel_val;
            counter = counter + 8;
        end
    end
    % 将图像ref_pixels根据图像加密密钥解密
    [decrypted_img] = Encrypt_Image(ref_pixels,encryption_key);
    % 根据aux_info、pos_map和msg_len恢复其他位置的像素
    restored_img = decrypted_img;
    aux_info_len = length(aux_info);
    total_bits = aux_info_len + msg_len; %嵌入信息的总数
    bit_counter = 0; %计数
    for i=ref_rows+1:img_rows
        for j=ref_cols+1:img_cols
            if bit_counter >= total_bits %嵌入信息的比特位全部恢复完毕
                break;
            end
            %---------求当前像素点的预测值---------%
            upper_pix = restored_img(i-1,j);
            diag_pix = restored_img(i-1,j-1);
            left_pix = restored_img(i,j-1);
            if diag_pix <= min(upper_pix,left_pix)
                pred_val = max(upper_pix,left_pix);
            elseif diag_pix >= max(upper_pix,left_pix)
                pred_val = min(upper_pix,left_pix);
            else
                pred_val = upper_pix + left_pix - diag_pix;
            end
            %-----原始值和预测值 --> 8位二进制数组----%
            curr_pix = restored_img(i,j);
            [bin_curr] = Decimalism_Binary(curr_pix);
            [bin_pred] = Decimalism_Binary(pred_val);
            %---------像素点需恢复 1 bit MSB----------%
            if pos_map(i,j) == 0  %Map=0表示原始像素值的第1MSB与其预测值相反
                if bin_pred(1) == 0 
                    bin_curr(1) = 1; 
                else  
                    bin_curr(1) = 0;
                end
                [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                restored_img(i,j) = pixel_val;
                bit_counter = bit_counter + 1; %恢复1bit  
            %---------像素点需恢复 2 bit MSB----------%
            elseif pos_map(i,j) == 1  %Map=1表示原始像素值的第2MSB与其预测值相反
                if bit_counter+2 <= total_bits
                    if bin_pred(2) == 0
                        bin_curr(2) = 1;
                    else
                        bin_curr(2) = 0;
                    end
                    bin_curr(1) = bin_pred(1);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + 2; %恢复2bit
                else 
                    remaining_bits = total_bits - bit_counter; %剩余恢复的bit数
                    bin_curr(1:remaining_bits) = bin_pred(1:remaining_bits);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + remaining_bits; %恢复tbit 
                end
            %---------像素点需恢复 3 bit MSB----------%
            elseif pos_map(i,j) == 2  %Map=2表示原始像素值的第3MSB与其预测值相反
                if bit_counter+2 <= total_bits
                    if bin_pred(3) == 0 
                        bin_curr(3) = 1; 
                    else                    
                        bin_curr(3) = 0;
                    end
                    bin_curr(1:2) = bin_pred(1:2);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + 3; %恢复3bit
                else 
                    remaining_bits = total_bits - bit_counter; %剩余恢复的bit数
                    bin_curr(1:remaining_bits) = bin_pred(1:remaining_bits);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + remaining_bits; %恢复tbit
                end    
            %---------像素点需恢复 4 bit MSB----------%
            elseif pos_map(i,j) == 3  %Map=3表示原始像素值的第4MSB与其预测值相反
                if bit_counter+3 <= total_bits
                    if bin_pred(4) == 0 
                        bin_curr(4) = 1; 
                    else                    
                        bin_curr(4) = 0;
                    end
                    bin_curr(1:3) = bin_pred(1:3);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + 4; %恢复4bit
                else 
                    remaining_bits = total_bits - bit_counter; %剩余恢复的bit数
                    bin_curr(1:remaining_bits) = bin_pred(1:remaining_bits);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + remaining_bits; %恢复tbit
                end  
            %---------像素点需恢复 5 bit MSB----------%
            elseif pos_map(i,j) == 4  %Map=4表示原始像素值的第5MSB与其预测值相反
                if bit_counter+4 <= total_bits
                    if bin_pred(5) == 0 
                        bin_curr(5) = 1; 
                    else                    
                        bin_curr(5) = 0;
                    end
                    bin_curr(1:4) = bin_pred(1:4);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + 5; %恢复5bit
                else 
                    remaining_bits = total_bits - bit_counter; %剩余恢复的bit数
                    bin_curr(1:remaining_bits) = bin_pred(1:remaining_bits);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + remaining_bits; %恢复tbit
                end    
            %---------像素点需恢复 6 bit MSB----------%
            elseif pos_map(i,j) == 5  %Map=5表示原始像素值的第6MSB与其预测值相反
                if bit_counter+5 <= total_bits
                    if bin_pred(6) == 0 
                        bin_curr(6) = 1; 
                    else                    
                        bin_curr(6) = 0;
                    end
                    bin_curr(1:5) = bin_pred(1:5);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + 6; %恢复6bit
                else 
                    remaining_bits = total_bits - bit_counter; %剩余恢复的bit数
                    bin_curr(1:remaining_bits) = bin_pred(1:remaining_bits);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + remaining_bits; %恢复tbit
                end 
            %---------像素点需恢复 7 bit MSB----------%%
            elseif pos_map(i,j) == 6  %Map=6表示原始像素值的第7MSB与其预测值相反
                if bit_counter+6 <= total_bits
                    if bin_pred(7) == 0 
                        bin_curr(7) = 1; 
                    else                    
                        bin_curr(7) = 0;
                    end
                    bin_curr(1:6) = bin_pred(1:6);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + 7; %恢复7bit
                else 
                    remaining_bits = total_bits - bit_counter; %剩余恢复的bit数
                    bin_curr(1:remaining_bits) = bin_pred(1:remaining_bits);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + remaining_bits; %恢复tbit
                end 
            %---------像素点需恢复 8 bit MSB----------%
            elseif pos_map(i,j) == 7  %Map=7表示原始像素值的第8MSB与其预测值相反
                if bit_counter+7 <= total_bits
                    if bin_pred(8) == 0 
                        bin_curr(8) = 1; 
                    else                    
                        bin_curr(8) = 0;
                    end
                    bin_curr(1:7) = bin_pred(1:7);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + 8; %恢复8bit
                else 
                    remaining_bits = total_bits - bit_counter; %剩余恢复的bit数
                    bin_curr(1:remaining_bits) = bin_pred(1:remaining_bits);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + remaining_bits; %恢复tbit
                end  
            %---------像素点需恢复 8 bit MSB----------%
            elseif pos_map(i,j) == 8  %Map=8表示原始像素值等于其预测值
                if bit_counter+8 <= total_bits
                    bin_curr(1:8) = bin_pred(1:8);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + 8; %恢复8bit
                else 
                    remaining_bits = total_bits - bit_counter; %剩余恢复的bit数
                    bin_curr(1:remaining_bits) = bin_pred(1:remaining_bits);
                    [pixel_val] = Binary_Decimalism(bin_curr); %将8位二进制数组转换成十进制整数
                    restored_img(i,j) = pixel_val;
                    bit_counter = bit_counter + remaining_bits; %恢复tbit
                end
            end
        end
    end
end
% ========================图像恢复阶段========================











