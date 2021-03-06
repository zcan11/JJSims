%Explanation of base program

%The program splits a squid into two junctions that have xmax discrete sections.  Each
%section has a supercurrent density, and a phase difference that is
%contributed to by the field (PhaseF) in the junction, the field in the squid loop,
%and an arbitrary phase set at x=1 %called Phase1.  These phase factors are 
%all summed along the junction to determine the local phase difference 
%across the junction at each point.  For each value of field and Phase1 the
%supercurrent at each point is calculated and the net supercurrent (sum 
%along the junction and then the sum of the two junctions together)
%is calcualted to find the supercurrent carried at that phase and that
%field.  To find the maximum supercurrent for a given field, the max of
%that vector is taken for that field value.  The minimum can be calculated 
%to find the negative critical current.  Both of these can be plotted 
%against the magnetic field that is applied.  This is the exact measurment 
%of the critical current vs field that we do in the lab.

%This version adds the ability to add several realistic features of squids

% Critical Current Asymmetry
% Junction Area Asymmetry
% Critical Current density variation along each junction
% Squid Loop size variation
% Changes in the field scan range



%Abreviations used
%Junction=Junc
%Super Current = SCur or just SC
%Step Size = SS sufix
%Width = Wid
%Length = Len
%Magnitude = Mag


%% Clearing memory and input screen

clear;
clc;
close all;

%% Defining the Parameters of the Simulaiton

    %Dividing the Junctions up into discrete sections
        xmax1=51;
        xmax2=52;
        x1(:,1)=(1:xmax1);
        x2(:,1)=(1:xmax2);

    %Critical Current Magnitudes
        SCurrentMag1=1;
        SCurrentMag2=1;

        SCurNoiseMag1=.01;
        SCurNoiseMag2=.01;
              
    %Junction Area Dimensions
        JuncWid1=1;
        JuncLen1=1;

        JuncWid2=1;
        JuncLen2=1;
        
    %Setting Squid Loop Parameers
        LoopWid=2;
        LoopLen=5;
        
%Setting up Loop Parameters
        
    %Phase Loop parameters
        p=1;
        pmax=203;
        Phase0Min=0*pi;
        Phase0Max=2*pi;
            
    %Field Parameters
        f=1;
        fmax=1004;
        FieldMin=-2;
        FieldMax=2;
        
    %Stepping through a parameter
        j=1;
        jmax=2;
        AlphaMin=0;
        AlphaMax=.8;


%Calculating Critical Current Densities
    JuncArea1=JuncWid1*JuncLen1;
    JuncArea2=JuncWid2*JuncLen2;
    LoopArea=LoopWid*LoopLen;
    
    SCurNoise1=SCurNoiseMag1*(2*rand(xmax1,1)-1);
    SCurNoise2=SCurNoiseMag2*(2*rand(xmax2,1)-1);
 
    SCurDen1=ones(xmax1,1)*SCurrentMag1/xmax1+SCurNoise1/xmax1;
    SCurDen2=ones(xmax2,1)*SCurrentMag2/xmax2+SCurNoise2/xmax2;

%Pre Allocating memory to the arrays (should decrease runtime)
Phase0=zeros(1,pmax);
Field=zeros(1,fmax);
FluxinJunc1=zeros(1,fmax);
FluxinJunc2=zeros(1,fmax);
FluxinLoop=zeros(1,fmax);

PhaseFDen1=zeros(1,fmax); %Phase from field in Junction 1
PhaseFDen2=zeros(1,fmax); %Phase from field in Junction 2
PhaseFL=zeros(1,fmax); %Phase from field in the Squid Loop


SCurrent1=zeros(xmax1,pmax,fmax);
SCurrent2=zeros(xmax2,pmax,fmax);
SCurrentNet=zeros(1,pmax);

MaxSCurrentNet=zeros(jmax,fmax);
MinSCurrentNet=zeros(jmax,fmax);
IndexMaxSC=zeros(jmax,fmax);
IndexMinSC=zeros(jmax,fmax);
Phase0MaxSC=zeros(jmax,fmax);
Phase0MinSC=zeros(jmax,fmax);

%% Loops for running the simulation Meat of the Simulation


%Changing a Parameter of the plot
AlphaSS =(AlphaMax-AlphaMin)/(jmax-1);
AlphaV= AlphaMin:AlphaSS:AlphaMax;

for j=1:jmax;
    
    Alpha=AlphaV(j);
 
    %Field Contribution to the Phase 
    %Define the Field ForLoop setp size, then run the Field for ForLoop
    FieldSS=(FieldMax-FieldMin)/(fmax-1);
    for f=1:fmax

        Field(f)=FieldMin+(f-1)*FieldSS;


        PhaseF1=2*pi*Field(f)*JuncArea1;
        PhaseF2=2*pi*Field(f)*JuncArea2;
        PhaseFL=2*pi*Field(f)*LoopArea;

        PhaseFDen1=PhaseF1*x1/xmax1;
        PhaseFDen2=PhaseF2*x2/xmax2;

        %Phase0 ForLoop of externally set phase 
        %Define the Phase0 setp size, then run the ForLoop
            
            Phase0SS=(Phase0Max-Phase0Min)/(pmax-1);
            Phase0=(Phase0Min:Phase0SS:Phase0Max);
            PhaseNorm=Phase0/(2*pi);
            PhaseIntrinsic1=zeros(xmax1,pmax);
            PhaseIntrinsic2=zeros(xmax2,pmax);
                        
        %Calculating the local Phase Drop across each junction
            PhaseDrop1=ones(xmax1,1)*Phase0+PhaseFDen1*ones(1,pmax);
            PhaseDrop2=ones(xmax2,1)*Phase0+PhaseFL.*ones(xmax2,pmax)+PhaseFDen2*ones(1,pmax);
            PhaseIntrinsic2(round(xmax2/2):end,:)=pi;
        
        %Calculating the Super Current 
            SCurrent1=SCurDen1*ones(1,pmax).*(1-Alpha).*(sin(PhaseDrop1+PhaseIntrinsic1));
            SCurrent2=SCurDen2*ones(1,pmax).*(1+Alpha).*sin(PhaseDrop2+PhaseIntrinsic2);
            
            SCurrentNet=sum(SCurrent1)+sum(SCurrent2);
        
            
        %Recording the Maximum Super Current and its index in "p"
        [MaxSCurrentNet(j,f),IndexMaxSC(j,f)]=max(SCurrentNet);  
        [MinSCurrentNet(j,f),IndexMinSC(j,f)]=min(SCurrentNet);
        %Recording the Phase0 of the Maximum Super Current
        Phase0MaxSC(j,f)=Phase0(IndexMaxSC(j,f));
        Phase0MinSC(j,f)=Phase0(IndexMinSC(j,f));
        
     end

end

hold on; subplot(2,1,1); plot(Field,MaxSCurrentNet,'.')
hold on; subplot(2,1,1); plot(Field,MinSCurrentNet,'.')
xlabel('Magnetic Field'); ylabel('Critical Current');


hold on; subplot(2,1,2); plot(Field,Phase0MaxSC/pi,'.')
hold on; subplot(2,1,2); plot(Field,Phase0MinSC/pi,'.')
xlabel('Magnetic Field'); ylabel('Phase 0/pi');

