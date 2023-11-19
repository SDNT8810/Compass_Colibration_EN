function [A,b,magB] = magcal(d, fitkind)
%MAGCAL - Magnetometer calibration coefficients 
%
%   [A,B,EXPMFS] = MAGCAL(D) returns the coefficients needed to correct
%   uncalibrated magnetometer data D. Specify D as an N-by-3 matrix of 
%   [X Y Z] measurements. A is a 3-by-3 matrix which corrects soft-iron
%   effects. B is a 1-by-3 vector which corrects hard-iron effects. EXPMFS
%   is the scalar expected magnetic field strength.
%
%   [A,B,EXPMFS] = MAGCAL(..., FITKIND) constrains A to have the form in
%   FITKIND.  Valid choices for FITKIND are:
%
%     'eye'   - constrains A to be eye(3)
%     'diag'  - constrains A to be diagonal
%     'sym'   - constrains A to be symmetric
%     'auto'  - (default) chooses A among 'eye', 'diag', and 'sym' to give
%               the best fit.
%
%   The data D can be corrected with the 3-by-3 matrix A and the 3-by-1
%   vector B using the equation
%     F = (D-B)*A
%   to produce the N-by-3 matrix F of corrected magnetometer data. The
%   corrected magnetometer data lies on a sphere of radius EXPMFS.
%
%   Example: Correct Data Lying on an Ellipsoid
%       % Generate magnetometer data that lies on an ellipsoid. 
%       c = [-50; 20; 100]; % ellipsoid center
%       r = [30; 20; 50]; % semiaxis radii
%       [x,y,z] = ellipsoid(c(1),c(2),c(3),r(1),r(2),r(3),20);
%       d = [x(:),y(:),z(:)];
%
%       % Correct the magnetometer data so that it lies on a sphere.
%       [A,b,magB] = magcal(d); % calibration coefficients
%       dc = (d-b)*A; % correct data to a sphere
%
%       % Visualize the uncalibrated and calibrated magnetometer data.
%       plot3(x(:),y(:),z(:), 'LineStyle', 'none', 'Marker', 'X', ...
%           'MarkerSize', 8);
%       hold(gca, 'on');
%       grid(gca, 'on');
%       plot3(dc(:,1),dc(:,2),dc(:,3), 'LineStyle', 'none', 'Marker', ...
%           'o', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); 
%       axis equal
%       xlabel('uT');
%       ylabel('uT');
%       xlabel('uT');
%       legend('Uncalibrated Samples', 'Calibrated Samples', ...
%           'Location', 'southoutside');
%       title("Uncalibrated vs Calibrated" + newline + ...
%           "Magnetometer Measurements");
%       hold(gca, 'off');
%
%   See also IMUSENSOR, ALLANVAR, ELLIPSOID

% Copyright 2018-2019 The MathWorks, Inc.

    narginchk(1,2);
    validateattributes(d, {'double', 'single'}, ...
        {'2d', 'real', 'ncols', 3}, 'magcal', 'd');
        
    x = d(:,1);
    y = d(:,2);
    z = d(:,3);

    if nargin < 2
        [A,bCol,magB] = bestfit(x,y,z);
    else
        str = validatestring(fitkind, {'eye', 'diag', 'sym', 'auto'}, ...
            'magcal', 'fitkind');
        [A,bCol,magB] = parameterizedfit(str, x,y,z);
    end

    b = bCol(:).'; % make a row vector 

end

function [A,b,magB] = bestfit(x,y,z)
% Find the best fit - 4, 7 or 10 parameter

    [A,b,magB, er] = correctEllipsoid4(x,y,z);
    
    [A7,b7,magB7, er7, ispd7] = correctEllipsoid7(x,y,z);
    if ispd7 && isreal(A7) && (er7 < er)
        A = A7;
        b = b7;
        magB = magB7;
        er = er7;
    end
    
    [A10,b10,magB10, er10, ispd10] = correctEllipsoid10(x,y,z);
    if ispd10 && isreal(A10) && (er10 < er)
        A = A10;
        b = b10;
        magB = magB10;
    end
end

function [A,b,magB] = parameterizedfit(str, x,y,z)
% Choose 4 (eye) , 7  (diag), 10 (sym), parameter fit or best fit . 

    switch str
        case 'eye'
            [A,b,magB] = correctEllipsoid4(x,y,z);
        case 'diag'
            [A,b,magB] = correctEllipsoid7(x,y,z);
        case 'sym'
            [A,b,magB] = correctEllipsoid10(x,y,z);
        otherwise % auto
            [A,b,magB] = bestfit(x,y,z);
    end
end

function [Winv, V,B,er, ispd] = correctEllipsoid10(x,y,z)

    d = [...
        x.*x, ...
        2*x.*y, ...
        2*x.*z, ...
        y.*y, ...
        2*y.*z, ...
        z.*z, ...
        x, ...
        y, ...
        z, ...
        ones(size(x))];

    dtd = d.' * d;

    [evc, evlmtx] = eig(dtd);

    eigvals = diag(evlmtx);
    [~, idx] = min(eigvals);

    beta = evc(:,idx); %solution has smallest eigenvalue

    A = beta([1 2 3; 2 4 5; 3 5 6]); %make symmetric
    dA = det(A);

    if dA < 0
        A = -A;
        beta = -beta;
        dA = -dA; %Compensate for -A.
    end

    V = -0.5*(A\beta(7:9)); %hard iron offset

    B = sqrt(abs(sum([...
        A(1,1)*V(1)*V(1), ...
        2*A(2,1)*V(2)*V(1), ...
        2*A(3,1)*V(3)*V(1), ...
        A(2,2)*V(2)*V(2), ...
        2*A(3,2)*V(2)*V(3), ...
        A(3,3)*V(3)*V(3), ...
        -beta(end)] ...
    )));
  
    % We correct Winv and B by det(A) because we don't know which has the
    % gain. By convention, normalize A.

    det3root = nthroot(dA,3);
    det6root = sqrt(det3root);
    Winv = sqrtm(A./det3root);
    B = B./det6root;
    
    if nargout > 3 
        res = residual(Winv,V,B, [x,y,z]);
        er = (1/(2*B*B))*sqrt(res.'*res/numel(x));
        [~,p] = chol(A);
        ispd = (p == 0);
    else
        er = -ones(1, 'like',x);
        ispd = -1;
    end

end

function [Winv, V,B,er, ispd] = correctEllipsoid7(x,y,z)

    d = [...
        x.*x, ...
        y.*y, ...
        z.*z, ...
        x, ...
        y, ...
        z, ...
        ones(size(x))];


    dtd = d.' * d;

    [evc, evlmtx] = eig(dtd);

    eigvals = diag(evlmtx);
    [~, idx] = min(eigvals);

    beta = evc(:,idx); %solution has smallest eigenvalue
    A = diag(beta(1:3));
    dA = det(A);

    if dA < 0
        A = -A;
        beta = -beta;
        dA = -dA; %Compensate for -A.
    end
    V = -0.5*(beta(4:6)./beta(1:3)); %hard iron offset

    B = sqrt(abs(sum([...
        A(1,1)*V(1)*V(1), ...
        A(2,2)*V(2)*V(2), ...
        A(3,3)*V(3)*V(3), ...
        -beta(end)] ...
    )));
  

    % We correct Winv and B by det(A) because we don't know which has the
    % gain. By convention, normalize A.

    det3root = nthroot(dA,3);
    det6root = sqrt(det3root);
    Winv = sqrtm(A./det3root);
    B = B./det6root;
    
    if nargout > 3
        res = residual(Winv,V,B, [x,y,z]);
        er = (1/(2*B*B))*sqrt(res.'*res/numel(x));
        [~,p] = chol(A);
        ispd = (p == 0);
    else
        er = -ones(1, 'like',x);
        ispd = -1;
    end

    
    
end

function [Winv, V,B, er, ispd] = correctEllipsoid4(x,y,z)
% R is the identity

    bv = x.*x + y.*y + z.*z;

    A3 = [x,y,z];
    A = [A3 ones(numel(x),1, 'like', x)];

    soln = A\bv;
    Winv = eye(3, 'like', x);
    V = 0.5*soln(1:3);
    B = sqrt(soln(4) + sum(V.*V));
    
    if nargout > 3
        res = A*soln - bv;
        er = (1/(2*B*B) * sqrt( res.'*res / numel(x)));
        ispd = 1;
    else
        er = -ones(1, 'like',x);
        ispd = -1;
    end
end

function r = residual(Winv, V, B, data)
% Residual error after correction

spherept = (Winv * (data.' - V)).'; % a point on the unit sphere
radsq = sum(spherept.^2,2);

r = radsq - B.^2;
end
