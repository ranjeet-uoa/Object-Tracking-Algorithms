function [xk,wk]=resample(xk,wk,strat)

ns=length(wk);

switch strat
    
    case 'systematic'
        c=zeros(ns);u=zeros(ns);c(1)=wk(1);
        for i=2:ns
            c(i)=c(i-1)+wk(i);
        end
        i=1; u(1)=rand;
        for j=1:ns
            u(j)=(1/ns)*((j-1)+u(1));
            while u(j)>c(i)&& i<ns
                i=i+1;
            end
            xk(:,j)=xk(:,i);
            wk(j)=1/ns;
        end
    case 'multinomial'
        with_replacement=true;
        ij=randsample(1:ns,ns,with_replacement,wk);
        xk=xk(:,ij);
        wk=repmat(1/ns,1,ns);
    case 'multi'
        c=zeros(ns);c(1)=wk(1);u=zeros(ns);
        for i=1:ns
            u(i)=rand;
        end
        ur(ns)=(u(ns))^(1/ns);
        for i=2:ns
            c(i)=c(i-1)+wk(i);
            j=i-1;
            ur(ns-j)=ur(ns-j+1)*(u(ns-j))^(1/(ns-j));
        end
        i=1;
        for j=1:ns
            while ur(j)>=c(i)&&i<ns
                i=i+1;
            end
            xk(:,j)=xk(:,i);
            wk(j)=1/ns;
        end
    case 'stratified'
        c=zeros(ns);u=zeros(ns);ur=zeros(ns);%c(1)=wk(1);
        for j=2:ns
            c(j)=c(j-1)+wk(j);
        end
        for i=1:ns
            u(i)=rand;
        end
        for i=1:ns
            ur(i)=((i-1)+u(i))/ns;
        end
        i=1;
        for j=1:ns
            while ur(j)>c(i)&&i<ns
                i=i+1;
            end
            xk(:,j)=xk(:,i);
            wk(j)=1/ns;
        end
         case 'residual'
        n_babies=zeros(1,ns);
        wk1=wk; wk=wk./sum(wk);
        wk_res=ns.*wk';%'
        n_babies=fix(wk_res);
        n_res=ns-sum(n_babies);
        if(n_res~=0)
            wk_res=(wk_res-n_babies)/n_res;
            cumDist=cumsum(wk_res);
            u=fliplr(cumprod(rand(1,n_res).^(1./(n_res:-1:1))));
            j=1;
            for i=1:n_res
                while (u(1,i)>cumDist(1,j))
                    j=j+1;
                end
                n_babies(1,j)=n_babies(1,j)+1;
            end
        end
        index=1;
        for i=1:ns
            if(n_babies(1,i)>0)
                for j=index:index+n_babies(1,i)-1
                    xk(:,j)=xk(:,i);
                end
            end
            index=index+n_babies(1,i);
        end
        wk=repmat(1/ns,1,ns);
    case 'sys'
        edges=min([0 cumsum(wk)'],1);
        edges(end)=1;
        u1=rand/ns;
        [~,idx]=histc(u1:1/ns:1,edges);
        xk=xk(:,idx);
        wk=repmat(1/ns,1,ns);
end