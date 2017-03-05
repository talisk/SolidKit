//
//  SKPerformanceMemoryMonitor.m
//  SolidKitExample
//
//  Created by 孙恺 on 2017/3/4.
//  Copyright © 2017年 talisk. All rights reserved.
//

#import "SKPerformanceMemoryMonitor.h"
#include <mach/mach.h>
#include <malloc/malloc.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <sys/mman.h>
#import "SKPerformanceMonitorFactory.h"

@implementation SKPerformanceMemoryMonitor {
    NSUInteger appMemory;
}

- (void)handleTick {
    appMemory = [self getResidentMemory];
    Performance(SKPerformanceLogPerformanceTypeMemory, @"%.2f", appMemory / 1024.0 /1024.0);
}

- (NSUInteger)getResidentMemory {
    struct task_basic_info t_info;
    mach_msg_type_number_t t_info_count = TASK_BASIC_INFO_COUNT;
    
    int r = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&t_info, &t_info_count);
    if (r == KERN_SUCCESS)
    {
        return t_info.resident_size;
    }
    else
    {
        return -1;
    }
}

int64_t func_getAppMemory()
{
    return [[[SKPerformanceMonitorFactory sharedFactory] getSingletonForClass:[SKPerformanceMemoryMonitor class]] getResidentMemory];
}

int64_t func_getUsedMemory()
{
    size_t length = 0;
    int mib[6] = {0};
    
    int pagesize = 0;
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    length = sizeof(pagesize);
    if (sysctl(mib, 2, &pagesize, &length, NULL, 0) < 0)
    {
        return 0;
    }
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    
    vm_statistics_data_t vmstat;
    
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
    {
        return 0;
    }
    
    int wireMem = vmstat.wire_count * pagesize;
    int activeMem = vmstat.active_count * pagesize;
    return wireMem + activeMem;
}

int64_t func_getFreeMemory()
{
    size_t length = 0;
    int mib[6] = {0};
    
    int pagesize = 0;
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    length = sizeof(pagesize);
    if (sysctl(mib, 2, &pagesize, &length, NULL, 0) < 0)
    {
        return 0;
    }
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    
    vm_statistics_data_t vmstat;
    
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
    {
        return 0;
    }
    
    int freeMem = vmstat.free_count * pagesize;
    int inactiveMem = vmstat.inactive_count * pagesize;
    
    return freeMem + inactiveMem;
}

@end
