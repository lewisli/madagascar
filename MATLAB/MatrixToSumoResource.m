function [ success ] = MatrixToSumoResource(OutputDir, RealizationName, RealizationData, Dim, ...
	CellSize, NumComponents)
%MatrixToSumoResource Converts matlab matrix to sumo format
%   Given a matrix, writes the appropiate XML formatted header file and
%   corresponding binary file that makes up a SumoResource file.
%
% Input Parameters:
%
% OutputDir: Path to output sumo file
% RealizationName: Realization name
% RealizationData: Matrix containing actual realization
% Dim: Dimension of realization
% CellSize: Cell size
% NumComponents: Number of data components of realization
%
% Output Parameters:
%
% Success: If write was successful
%
% Lewis Li (lewisli@stanford.edu)
% Date of Creation: April 21st 2015
% Last Updated: September 23rd 2015

% Set up root
docNode = com.mathworks.xml.XMLUtils.createDocument('SumoResource');
entry_node = docNode.createElement(RealizationName);
docNode.getDocumentElement.appendChild(entry_node);

% For now only Uniform grids are supported
name_node = docNode.createElement('ResourceType');
name_node.setAttribute('Type','UniformGrid');
entry_node.appendChild(name_node);

% For now use float only
variable_type_node = docNode.createElement('DataType');
variable_type_node.setAttribute('Type','Float');
entry_node.appendChild(variable_type_node);

% Dimension grid
dim_node = docNode.createElement('Grid_Dimension');
dim_node.setAttribute('x',num2str(Dim(1)));
dim_node.setAttribute('y',num2str(Dim(2)));
dim_node.setAttribute('z',num2str(Dim(3)));
entry_node.appendChild(dim_node);

% Dimension grid
spacing_node = docNode.createElement('Grid_Spacing');
spacing_node.setAttribute('x',num2str(CellSize(1)));
spacing_node.setAttribute('y',num2str(CellSize(2)));
spacing_node.setAttribute('z',num2str(CellSize(3)));
entry_node.appendChild(spacing_node);

% Number of components
num_components_node = docNode.createElement('Num_Components');
num_components_node.setAttribute('Num', num2str(NumComponents));
entry_node.appendChild(num_components_node);

% Binary file path
absPath=[OutputDir '/' RealizationName '.bin'];
filepath_node = docNode.createElement('Binary_path');
filepath_node.setAttribute('Path', absPath);
entry_node.appendChild(filepath_node);

fid = fopen(absPath,'w');
fwrite(fid,RealizationData,'float32');
fclose(fid);

xmlFileName = [OutputDir '/' RealizationName,'.smh'];
xmlwrite(xmlFileName,docNode);

success = true;
end

