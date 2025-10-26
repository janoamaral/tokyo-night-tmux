#include <mach/mach_host.h>
#include <mach/processor_info.h>
#include <mach/vm_map.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> // 用于 usleep

// 定义 CPU 时间信息结构体（与底层逻辑一致）
typedef struct {
  uint64_t inUseAll; // 繁忙时间（用户态+系统态+低优先级）
  uint64_t totalAll; // 总时间（繁忙+空闲）
} FFCpuUsageInfo;

// 动态列表结构体（简化版，用于存储各核心时间信息）
typedef struct {
  FFCpuUsageInfo *data;
  size_t count;
  size_t capacity;
} FFList;

// 初始化列表
static void ffListInit(FFList *list) {
  list->data = NULL;
  list->count = 0;
  list->capacity = 0;
}

// 向列表添加元素
static FFCpuUsageInfo *ffListAdd(FFList *list) {
  if (list->count >= list->capacity) {
    list->capacity = (list->capacity == 0) ? 4 : list->capacity * 2;
    list->data = realloc(list->data, list->capacity * sizeof(FFCpuUsageInfo));
    if (!list->data)
      exit(1); // 内存分配失败直接退出
  }
  return &list->data[list->count++];
}

// 释放列表资源
static void ffListDestroy(FFList *list) {
  free(list->data);
  list->data = NULL;
  list->count = 0;
  list->capacity = 0;
}

// 底层：获取各核心 CPU 时间信息（复用你的逻辑）
static const char *ffGetCpuUsageInfo(FFList *cpuTimes) {
  natural_t numCPUs = 0U;
  processor_info_array_t cpuInfo;
  mach_msg_type_number_t numCpuInfo;

  // 调用系统 API 获取 CPU 负载信息
  if (host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUs,
                          &cpuInfo, &numCpuInfo) != KERN_SUCCESS)
    return "host_processor_info() failed";
  if (numCPUs * CPU_STATE_MAX != numCpuInfo)
    return "Unexpected host_processor_info() result";

  // 遍历每个核心，计算繁忙时间和总时间
  for (natural_t i = 0U; i < numCPUs; ++i) {
    integer_t inUse = cpuInfo[CPU_STATE_MAX * i + CPU_STATE_USER] +
                      cpuInfo[CPU_STATE_MAX * i + CPU_STATE_SYSTEM] +
                      cpuInfo[CPU_STATE_MAX * i + CPU_STATE_NICE];
    integer_t total = inUse + cpuInfo[CPU_STATE_MAX * i + CPU_STATE_IDLE];

    FFCpuUsageInfo *info = ffListAdd(cpuTimes);
    *info = (FFCpuUsageInfo){
        .inUseAll = (uint64_t)inUse,
        .totalAll = (uint64_t)total,
    };
  }

  // 释放内核内存
  vm_deallocate(mach_task_self(), (vm_address_t)cpuInfo,
                numCpuInfo * sizeof(integer_t));
  return NULL;
}

// 计算 CPU 平均使用率
static double calculateCpuAvgUsage(uint32_t waitTimeMs) {
  FFList initialTimes;
  FFList finalTimes;
  ffListInit(&initialTimes);
  ffListInit(&finalTimes);

  // 第一次获取初始时间
  const char *error = ffGetCpuUsageInfo(&initialTimes);
  if (error) {
    fprintf(stderr, "Error: %s\n", error);
    return -1.0;
  }
  if (initialTimes.count == 0) {
    fprintf(stderr, "Error: No CPU cores detected\n");
    return -1.0;
  }

  // 等待指定时间（让 CPU 产生时间差，确保使用率计算准确）
  usleep(waitTimeMs * 1000); // usleep 单位是微秒

  // 第二次获取最终时间
  error = ffGetCpuUsageInfo(&finalTimes);
  if (error) {
    fprintf(stderr, "Error: %s\n", error);
    ffListDestroy(&initialTimes);
    return -1.0;
  }
  if (finalTimes.count != initialTimes.count) {
    fprintf(stderr, "Error: CPU core count changed during measurement\n");
    ffListDestroy(&initialTimes);
    ffListDestroy(&finalTimes);
    return -1.0;
  }

  // 计算所有核心的总繁忙时间差和总时间差
  uint64_t totalInUseDiff = 0;
  uint64_t totalTotalDiff = 0;
  for (size_t i = 0; i < initialTimes.count; ++i) {
    uint64_t inUseDiff =
        finalTimes.data[i].inUseAll - initialTimes.data[i].inUseAll;
    uint64_t totalDiff =
        finalTimes.data[i].totalAll - initialTimes.data[i].totalAll;

    // 避免除以零（理论上不会发生）
    if (totalDiff == 0)
      totalDiff = 1;

    totalInUseDiff += inUseDiff;
    totalTotalDiff += totalDiff;
  }

  // 释放资源
  ffListDestroy(&initialTimes);
  ffListDestroy(&finalTimes);

  // 计算平均使用率（百分比）
  return (double)totalInUseDiff / totalTotalDiff * 100.0;
}

int main() {
  // 采样间隔：200ms（可调整，越小响应越快，越大越稳定）
  const uint32_t WAIT_TIME_MS = 200;

  double avgUsage = calculateCpuAvgUsage(WAIT_TIME_MS);
  if (avgUsage < 0)
    return 1; // 出错退出

  // 输出平均使用率（保留 1 位小数，方便 tmux 显示）
  printf("%.1f\n", avgUsage);

  return 0;
}
