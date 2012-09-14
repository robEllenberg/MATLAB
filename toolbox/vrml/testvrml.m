fname='Body_LPalm.wrl'
disp('Loading example VRML')
importVRMLMesh(fname,1)

disp('Create mirror and convex hull')
processVRML(fname,'LR',1,1)