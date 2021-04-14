#Fatal Error: cuda_runtime.h: No such file or directory解决办法：https://www.codeleading.com/article/49053416150/
#解决找不到/usr/bin/ld: cannot find -lcudart的问题:https://blog.csdn.net/eastlhu/article/details/78533193
#把$CUDAPATH后面所跟的路径换一下，换成cuda11版本的路径


# evaluation
TFPATH=$1 # e.g: /usr/miniconda3/envs/3dssd/lib/python3.6/site-packages/tensorflow/
CUDAPATH=$2 # e.g: /usr/local/cuda-11.1/
OPSPATH="lib/utils/tf_ops"

# voxel operation
cd lib/builder/voxel_generator
./build.sh
cd dist
pip install points2voxel-0.0.1-cp36-cp36m-linux_x86_64.whl
cd ../../../..

# evaluation
cd ${OPSPATH}/evaluation
/usr/bin/gcc-5 -std=c++11 tf_evaluate.cpp -o tf_evaluate_so.so -shared -fPIC -I ${TFPATH}/include -I ${CUDAPATH}/nvvm/include -I ${TFPATH}/include/external/nsync/public -lcudart -L ${CUDAPATH}/targets/x86_64-linux/lib -L ${TFPATH} -ltensorflow_framework -O2 -D_GLIBCXX_USE_CXX11_ABI=0
cd ..

# grouping
cd grouping
$CUDAPATH/bin/nvcc  -ccbin /usr/bin/gcc-5 tf_grouping_g.cu -o tf_grouping_g.cu.o -c -O2 -DGOOGLE_CUDA=1 -x cu -Xcompiler -fPIC
/usr/bin/gcc-5 -std=c++11 tf_grouping.cpp tf_grouping_g.cu.o -o tf_grouping_so.so -shared -fPIC -I $TFPATH/include -I $CUDAPATH/nvvm/include -I $TFPATH/include/external/nsync/public -lcudart -L $CUDAPATH/targets/x86_64-linux/lib/ -L $TFPATH -ltensorflow_framework -O2 -D_GLIBCXX_USE_CXX11_ABI=0
cd ..

# interpolation
cd interpolation
$CUDAPATH/bin/nvcc -ccbin /usr/bin/gcc-5 tf_interpolate_g.cu -o tf_interpolate_g.cu.o -c -O2 -DGOOGLE_CUDA=1 -x cu -Xcompiler -fPIC
/usr/bin/gcc-5 -std=c++11 tf_interpolate.cpp tf_interpolate_g.cu.o -o tf_interpolate_so.so -shared -fPIC -I $TFPATH/include -I $CUDAPATH/nvvm/include -I $TFPATH/include/external/nsync/public -lcudart -L $CUDAPATH/targets/x86_64-linux/lib/ -L $TFPATH -ltensorflow_framework -O2 -D_GLIBCXX_USE_CXX11_ABI=0
cd ..

# points pooling
cd points_pooling
$CUDAPATH/bin/nvcc -ccbin /usr/bin/gcc-5 tf_points_pooling_g.cu -o tf_points_pooling_g.cu.o -c -O2 -DGOOGLE_CUDA=1 -x cu -Xcompiler -fPIC
/usr/bin/gcc-5 -std=c++11 tf_points_pooling.cpp tf_points_pooling_g.cu.o -o tf_points_pooling_so.so -shared -fPIC -I $TFPATH/include -I $CUDAPATH/nvvm/include -I $TFPATH/include/external/nsync/public -lcudart -L $CUDAPATH/targets/x86_64-linux/lib/ -L $TFPATH -ltensorflow_framework -O2 -D_GLIBCXX_USE_CXX11_ABI=0
cd ..

# sampling
cd sampling
$CUDAPATH/bin/nvcc -ccbin /usr/bin/gcc-5 tf_sampling_g.cu -o tf_sampling_g.cu.o -c -O2 -DGOOGLE_CUDA=1 -x cu -Xcompiler -fPIC
/usr/bin/gcc-5 -std=c++11 tf_sampling.cpp tf_sampling_g.cu.o -o tf_sampling_so.so -shared -fPIC -I $TFPATH/include -I $CUDAPATH/nvvm/include -I $TFPATH/include/external/nsync/public -lcudart -L $CUDAPATH/targets/x86_64-linux/lib/ -L $TFPATH -ltensorflow_framework -O2 -D_GLIBCXX_USE_CXX11_ABI=0
cd ..

# nms
cd nms
./build.sh
cd ..

