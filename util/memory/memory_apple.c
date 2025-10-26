#include <mach/mach.h>
#include <stdio.h>
#include <string.h>
#include <sys/sysctl.h>
#include <unistd.h>
#include <stdint.h>

typedef struct FFMemoryResult {
  uint64_t bytesUsed;
  uint64_t bytesTotal;
} FFMemoryResult;

const char *ffDetectMemory(FFMemoryResult *ram) {
  // 获取总内存
  size_t length = sizeof(ram->bytesTotal);
  if (sysctl((int[]){CTL_HW, HW_MEMSIZE}, 2, &ram->bytesTotal, &length, NULL,
             0))
    return "Failed to read hw.memsize";

  // 获取虚拟内存统计
  mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;
  vm_statistics64_data_t vmstat;
  if (host_statistics64(mach_host_self(), HOST_VM_INFO64,
                        (host_info64_t)(&vmstat), &count) != KERN_SUCCESS)
    return "Failed to read host_statistics64";

  // 获取页面大小（使用 sysconf 替代 instance）
  size_t pageSize = sysconf(_SC_PAGESIZE);
  if (pageSize == (size_t)-1)
    return "Failed to get page size";

  // 计算已使用内存
  ram->bytesUsed = ((uint64_t)+vmstat.active_count + vmstat.inactive_count +
                    vmstat.speculative_count + vmstat.wire_count +
                    vmstat.compressor_page_count - vmstat.purgeable_count -
                    vmstat.external_page_count) *
                   pageSize; // 使用获取到的 pageSize

  return NULL;
}

int main() {
  FFMemoryResult memory;
  const char *error = ffDetectMemory(&memory);

  if (error != NULL) {
    fprintf(stderr, "获取内存信息失败：%s\n", error);
    return 1; // 错误退出
  }

  printf("%llu %llu \n", memory.bytesUsed, memory.bytesTotal);
}
