#include <string.h>
#include "utests/utest_helper.hpp"
#include <sys/time.h>

#define IMAGE_BPP 2

double benchmark_copy_image_to_buffer(void)
{
  struct timeval start,stop;
  const size_t w = 960 * 4;
  const size_t h = 540 * 4;
  const size_t sz = IMAGE_BPP * w * h;
  cl_image_format format;
  cl_image_desc desc;

  memset(&desc, 0x0, sizeof(cl_image_desc));
  memset(&format, 0x0, sizeof(cl_image_format));

  // Setup image and buffer
  buf_data[0] = (unsigned short*) malloc(sz);
  for (uint32_t i = 0; i < w*h; ++i) {
    ((unsigned short*)buf_data[0])[i] = (rand() & 0xffff);
  }

  format.image_channel_order = CL_R;
  format.image_channel_data_type = CL_UNSIGNED_INT16;
  desc.image_type = CL_MEM_OBJECT_IMAGE2D;
  desc.image_width = w;
  desc.image_height = h;
  desc.image_row_pitch = desc.image_width * IMAGE_BPP;
  OCL_CREATE_IMAGE(buf[0], CL_MEM_COPY_HOST_PTR, &format, &desc, buf_data[0]);
  OCL_CREATE_BUFFER(buf[1], 0, sz, NULL);

  /*copy image to buffer*/
  size_t origin[3] = {0, 0, 0};
  size_t region[3] = {w, h, 1};

  OCL_CALL (clEnqueueCopyImageToBuffer, queue, buf[0], buf[1], origin, region,
            0, 0, NULL, NULL);
  OCL_FINISH();
  OCL_MAP_BUFFER(1);
  /*check result*/
  for (uint32_t i = 0; i < w*h; ++i) {
    OCL_ASSERT(((unsigned short *)buf_data[0])[i] == ((unsigned short *)buf_data[1])[i]);
  }
  OCL_UNMAP_BUFFER(1);
  gettimeofday(&start,0);

  for (uint32_t i=0; i<100; i++) {
    OCL_CALL (clEnqueueCopyImageToBuffer, queue, buf[0], buf[1], origin, region,
            0, 0, NULL, NULL);
  }
  OCL_FINISH();

  gettimeofday(&stop,0);
  free(buf_data[0]);
  buf_data[0] = NULL;

  double elapsed = time_subtract(&stop, &start, 0);

  return BANDWIDTH(sz * 100, elapsed);
}

MAKE_BENCHMARK_FROM_FUNCTION(benchmark_copy_image_to_buffer, "GB/S");
