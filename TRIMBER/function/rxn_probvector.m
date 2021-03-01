function  [temprxnpos, temprxnprob]=rxn_probvector(trimer,bnumstobekoed,regulator,regulated,probtfgene,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%        RXN_PROBVECTOR             Find affected reaction list and the probabilities vector by each TF
%        INPUTS:
%        Model                -  metabolic model obtained from COBRA toolbox through readcbmodel command
%        regulatory network   - format - cell array of regulators and matching target genes
%
%        Parameter:           
%        bnumstobekoed          -    TF list to be knocked out(default is to  knock all TF in regulatory network one by one )
%
%       OUTPUT:
%       temprxnpos            - reaction affected for each knock out 
%       temprxnprob               - probabilities for temprxnpos  


[~,posgenelist] = ismember(regulated,trimer.genes);  %find the position of each target genes in the gene list,"model.gene"
tfnames=unique(regulator);
[rxnpos,genelist] = find(trimer.rxnGeneMat);         % genelist - corresponding genes number.
                                                     % rxnpos - metabolic reaction number ,there maybe many reactions under the same gene.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this section is for tf-gene relationship
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
if any(ismember(tfnames,bnumstobekoed))        
        tfstate = logical(zeros(size(tfnames)));                   %��ʼ�� tfstate
        tfstate( ismember(tfnames,bnumstobekoed)  ) = 1;       %��KO�� TF ״̬���Ϊ1

        k = ismember(regulator,tfnames(tfstate))  ;                % 218 ��interaction �У�  ��KO��TF �����interaction ����� 
        %tempgene = regulated(k);                                  % ��Щinteraction ��  �ܿ��ƵĻ�������� ,û���ظ�.
        tempgeneprobs = probtfgene(k);                             % ��Щinteraction ��  �ܸ�TF ���ƵĻ���� conditional probility
        
        tempgenepos = posgenelist(k);                              % ��Щinteraction ��  �ܵ��صĻ����� trimer.gene �����.����Ϊ0 û�ж�Ӧ��
        temprxnpos = rxnpos( ismember(genelist,tempgenepos)  );    % ��Щgene ��Ӧ ��Ӧ�� ���  mapping from gene to  reaction
        
        tempgeneprobs(tempgenepos == 0)  = '';    %delete prob 
        tempgenepos(tempgenepos == 0)  = '';      %delete postion number equal 0 , which means that the tempgene is not found in trimer.gene  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this section is for gene-protein relationship
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        temprxnpos=states_check(trimer,tempgenepos,temprxnpos);   % reaction affected with state change for  each TF
        temprxnprob=zeros(1,length(temprxnpos));
        for m = 1:length(temprxnpos)
            kgenepos = ismember(  tempgenepos ,  genelist(ismember(rxnpos,temprxnpos(m))));%  ���������Ӱ��ķ�Ӧ��  Ӱ�쵱ǰ������Ӧ  �����л���Ϊ1.
            %kgene=trimer.genes(tempgenepos ( kgenepos ));
            temprxnprob(m) =min(tempgeneprobs(kgenepos) );
        end
else
     temprxnpos=[];
     temprxnprob=[];
end


