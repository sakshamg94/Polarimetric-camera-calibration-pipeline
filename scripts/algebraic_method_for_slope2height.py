import numpy as np

def rotationX(alpha):
    temp  = [[1, 0, 0],\
             [0, np.cos(alpha), -np.sin(alpha)],
             [0, np.sin(alpha), np.cos(alpha)]]
    return temp

def rotationY(alpha):
    temp  = [[np.cos(alpha), 0, np.sin(alpha)],\
             [0, 1, 0],
             [-np.sin(alpha), 0, np.cos(alpha)]]
    return temp

rows, cols = im_theta1.shape

x = np.arange(0, cols)
y = np.arange(0, rows)

X, Y = np.meshgrid(x,y)
Z = np.zeros((rows,cols)) # Z = 0 at node (0,0)


# parameters of the any plane facet that need to keeo updating
nx = np.zeros((rows,cols))
ny = np.zeros((rows,cols))
nz = np.zeros((rows,cols))

visited = np.zeros((rows,cols))
d = np.zeros((rows,cols))
visited[0,0]  = 1

# evaluate the normals nx, ny, nz
delta_theta = np.radians(im_theta2 - im_theta1)
delta_phi = np.radians(im_phi2 - im_phi1)
for i in tqdm(range(rows)):
    for j in range(cols):
        temp = rotationX(delta_theta[i,j]) @ np.array([0,0,1]).reshape(3,1)
        nx[i,j] = temp[0]

        temp = rotationY(delta_phi[i,j]) @ np.array([0,0,1]).reshape(3,1)
        ny[i,j] = temp[0]

nz = np.sqrt(1 - nx**2 - ny**2)
assert nz.shape == im_theta1.shape


for i in tqdm(range(rows)):
    for j in range(cols):
        if i==0 and j!=0: # Z = 0 at node (0,0)
            Z[i,j] = -d[i,j-1] - nx[i,j-1]*X[i,j] - ny[i,j-1]*Y[i,j]
            Z[i,j]/= nz[i,j-1]
        elif i!=0 and j==0:
            Z[i,j] = -d[i-1,j] - nx[i-1,j]*X[i,j] - ny[i-1,j]*Y[i,j]
            Z[i,j]/= nz[i-1,j]
        elif i!=0 and j!=0:
            Z_north= -d[i-1,j] - nx[i-1,j]*X[i,j] - ny[i-1,j]*Y[i,j]
            Z_north/= nz[i-1,j]
            
            Z_west = -d[i,j-1] - nx[i,j-1]*X[i,j] - ny[i,j-1]*Y[i,j]
            Z_west/= nz[i,j-1]
            
            Z_diag = -d[i-1,j-1] - nx[i-1,j-1]*X[i,j] - ny[i-1,j-1]*Y[i,j]
            Z_diag/= nz[i-1,j-1]

            Z[i,j] = np.mean([Z_west, Z_north, Z_diag])
        d[i,j] = -nx[i,j]*X[i,j]- ny[i,j]*Y[i,j] - nz[i,j]*Z[i,j]
        visited[i,j] = 1



