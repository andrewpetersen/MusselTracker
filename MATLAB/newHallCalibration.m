
%y is distance, mm
y = [
0        
.51        
1.31               
1.31               
1.41        
1.92             
1.92
2.28                
2.88        
3.25        
3.71        
4.04              
4.04
4.30           
4.30
4.81   
4.81  ];           
%x is voltage reading from board serial readout, 
x = [
477
484
492        
493
495
498        
498
501        
503
505
508
510        
510
510        
511
512        
512 ];

modelFun = @(n,x) n(1).*exp(n(2).*x) + n(3);     
startingVals = [1 0.01 0];
opts = statset('nlinfit');
opts.Robust = 'on';
opts.MaxIter = 10000;
coefEsts = nlinfit(x, y, modelFun, startingVals, opts);
figure,plot(x,y,'o')
x2 = 460:.1:530; 
f=modelFun(coefEsts,x2);
hold on,plot(x2,f)
