%Converts a thermistor's resistance into temperature, accepts vectors
function thermistorTemp = resistanceToTemp(resistances, RT_at_25)
 
%Resistance of Thermistor at 25 degrees Celsius
%RT_at_25 = 10000;

%Thermistor Lookup Table
%Resistance decreases with increasing temperature 
%(negative temperature coefficient(NTC))

%First Column                        Second Column
%Ratio of resistance to R@25         Temperature
%R = TableValue*R@25
%R/R@25 = TableValue
thermTable = [
 67.0115           -50
 62.4122           -49
 58.1579           -48
  54.221           -47
 50.5749           -46
 47.1985           -45
 44.0682           -44
 41.1655           -43
 38.4725           -42
 35.9716           -41
 33.6499           -40
  31.492           -39
 29.4867           -38
 27.6208           -37
 25.8853           -36
 24.2694           -35
 22.7642           -34
 21.3619           -33
 20.0546           -32
 18.8354           -31
 17.6977           -30
  16.636           -29
  15.644           -28
 14.7176           -27
 13.8515           -26
 13.0418           -25
 12.2842           -24
 11.5754           -23
 10.9116           -22
 10.2899           -21
 9.70741           -20
  9.1615           -19
 8.64951           -18
 8.16902           -17
 7.71837           -16
   7.295           -15
 6.89749           -14
 6.52404           -13
 6.17302           -12
 5.84286           -11
 5.53247           -10
 5.24025            -9
 4.96529            -8
 4.70621            -7
 4.46231            -6
 4.23247            -5
 4.01573            -4
 3.81144            -3
 3.61858            -2
 3.43675            -1
 3.26505             0
 3.10302             1
 2.94995             2
  2.8053             3
 2.66858             4
 2.53931             5
  2.4171             6
  2.3014             7
 2.19191             8
 2.08829             9
 1.99013            10
 1.89719            11
 1.80903            12
 1.72553            13
 1.64633            14
 1.57121            15
 1.49991            16
 1.43235            17
 1.36814            18
 1.30718            19
 1.24927            20
 1.19424            21
 1.14195            22
 1.09223            23
 1.04497            24
       1            25
 0.95721            26
 0.91649            27
 0.87774            28
 0.84083            29
 0.80567            30
 0.77217            31
 0.74025            32
 0.70983            33
 0.68082            34
 0.65314            35
 0.62675            36
 0.60157            37
 0.57752            38
 0.55456            39
 0.53266            40
 0.51172            41
 0.49172            42
 0.47262            43
 0.45435            44
 0.43689            45
 0.42019            46
 0.40422            47
 0.38893            48
 0.37431            49
 0.36031            50
 0.34687            51
 0.33401            52
 0.32168            53
 0.30988            54
 0.29857            55
 0.28773            56
 0.27735            57
 0.26739            58
 0.25784            59
 0.24869            60
  0.2399            61
 0.23147            62
 0.22338            63
 0.21562            64
 0.20816            65
 0.20101            66
 0.19413            67
 0.18753            68
 0.18118            69
 0.17508            70
 0.16922            71
 0.16358            72
 0.15816            73
 0.15295            74
 0.14793            75
 0.14311            76
 0.13846            77
 0.13399            78
 0.12969            79
 0.12554            80
 0.12155            81
 0.11771            82
   0.114            83
 0.11044            84
   0.107            85
 0.10368            86
0.100484            87
0.097402            88
 0.09443            89
0.091563            90
0.088797            91
0.086127            92
0.083552            93
0.081064            94
0.078666            95
0.076348            96
0.074109            97
0.071948            98
 0.06986            99
0.067842           100
0.065901           101
0.064023           102
0.062208           103
0.060453           104
0.058757           105
0.057117           106
0.055527           107
0.053991           108
0.052505           109
0.051066           110
0.049673           111
0.048325           112
0.047019           113
0.045755           114
0.044531           115
0.043345           116
0.042196           117
0.041083           118
0.040004           119
0.038958           120
0.037945           121
0.036962           122
0.036009           123
0.035086           124
 0.03419           125
0.033321           126
0.032478           127
 0.03166           128
0.030867           129
0.030096           130
0.029349           131
0.028623           132
0.027919           133
0.027234           134
 0.02657           135
0.025925           136
0.025299           137
 0.02469           138
0.024099           139
0.023524           140
0.022966           141
0.022423           142
0.021895           143
0.021383           144
0.020884           145
0.020399           146
0.019928           147
 0.01947           148
0.019024           149
 0.01859           150 ];    
    
%Calculating Thermistor Resistance
ratio = resistances/RT_at_25;
thermistorTemp = zeros(1,length(resistances));

for i = 1:length(resistances)
    boundsError = 0;
    %Error Bounds Checking
    if ratio(i)>=67.0115
        boundsError = 1;
        fprintf(2,'Error at index %d: Resistance too high, outside table bounds\n',i);
        thermistorTemp(i) = -9000;
    elseif ratio(i)<=0.01859
        boundsError = 1;
        fprintf(2,'Error at index %d: Resistance too low, outside table bounds\n',i);
        thermistorTemp(i) = 9000;
    elseif ratio(i)<0.43689
        fprintf('[\bWarning at index %d: Resistance below expected range]\b\n',i);
        fprintf('[\b                     Temperature higher than 45degC]\b\n');
    elseif ratio(i)>2.53931
        fprintf('[\bWarning at index %d: Resistance above expected range]\b\n',i);
        fprintf('[\b                     Temperature lower than 5degC]\b\n');
    end
    
    if boundsError==0
        %Find index of table to interpolate from
        j = 1;
        while j<=length(thermTable(:,1)) && thermTable(j,1) > ratio(i)
            j = j+1;
        end
        %Linear Interpolation: y = m*x + b
        m = (thermTable(j,2)-thermTable(j-1,2))/(thermTable(j,1)-thermTable(j-1,1));
        b = thermTable(j,2)-m*thermTable(j,1);
        thermistorTemp(i) = m*ratio(i) + b;
    end
end

end