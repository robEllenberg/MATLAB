function [X,Tes,Srf]=VolLoader(filename,varargin)
% [X,Tes,Srf]=VolLoader(filename)
%
% loads a VOL file, (the output format of the freeware NetGen)
% which includes coordinate list X, (N x 3), tesselation indices
% (Tes, NT x 4) and surface faces indices (Srf, NS x 3).


if isempty(varargin)
    pathname=[];
else
    pathname=varargin{1};
end

    fid = fopen(fullfile(pathname,filename),'r');             % Open text file

% dump introduction lines - unneccessary, but wtf
    textscan(fid,'%*s',4,'delimiter','\n'); % Read strings delimited by a carriage return
   
    while (~feof(fid)) 

	  InputText=textscan(fid,'%s',1,'delimiter','\n'); % Read line

	  if strcmp(InputText{1},'surfaceelementsgi')
		textscan(fid,'%*f',1); % discard element count
		FormatString='%*f %*f %*f %*f %*f %f %f %f %*f %*f %*f';
		InputText=textscan(fid,FormatString); % Read data block
		Srf=cell2mat(InputText); % Convert to numerical array from cell

	  elseif strcmp(InputText{1},'volumeelements')
		textscan(fid,'%*f',1); % discard element count
		FormatString='%*f %*f %f %f %f %f' ;
		InputText=textscan(fid,FormatString); % Read data block
		Tes=cell2mat(InputText); % Convert to numerical array from cell

 	  elseif strcmp(InputText{1},'edgesegmentsgi2')
% the format of the edge section isn't clear, and in any way most probably	
% relates to the surface edges alone. In the project itself, the edges are 
% computed from the tetras, rather than read. This section is meant only
% to dump the data quickly.

		textscan(fid,'%*f',1); % discard element count
		FormatString='%*f %*f %*f %*f %*f %*f' ;
		textscan(fid,FormatString); % Read data block
	
	  elseif strcmp(InputText{1},'points')
		textscan(fid,'%*f',1); % discard element count
		FormatString='%f %f %f';
		InputText=textscan(fid,FormatString); % Read data block
		X=cell2mat(InputText); % Convert to numerical array from cell

	  end   %if sequence
    end %while

    fclose(fid);   % Close the text file