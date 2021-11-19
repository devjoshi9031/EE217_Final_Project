import numpy as np
import cv2
import os

image = cv2.imread("/home/dev/EE217_Final_Project/test1.jpeg",0)
U, S, V = np.linalg.svd(image)
print(U.shape, np.diag(S).shape, V.shape, image.shape)


ret = (np.dot(U,(np.dot(S,V))))
cv2.imshow("Something",image)
cv2.waitKey(0)
cv2.destroyAllWindows()
