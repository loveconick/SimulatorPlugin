//
//  main.h
//  pluginTest
//
//  Created by jia jerry on 2018/3/27.
//  Copyright © 2018年 jia.jerry. All rights reserved.
//

#ifndef main_h
#define main_h


#ifdef _PLUGIN
#define _export __attribute__((visibility("default")))
#endif


typedef struct {
    uint64_t r[31];		//32个通用寄存器
    uint64_t uc_sp;		//用github开源项目unicorn实现的模拟器堆栈
    uint64_t pc;
    uint64_t sim_sp;	//贾工自己实现的模拟器堆栈
}arm64_gpregs;			//general Purpose 寄存器

typedef struct {
    __uint128_t v[32];
    uint32_t fp_status;
    uint32_t std_fp_status;
}arm64_fpregs;			//float point 寄存器

typedef struct _CPUAL CPUAL;

typedef struct _CPUAL {
    int free;
    void *vmcpu;
    
    void *cpu;
    uint64_t *sp_ptr;
    int ret_code;
    
    arm64_gpregs *gp;
    arm64_fpregs *fp;
    uint64_t *stack_top;
    
    void *tmp_ctx;
    
    int (*update_pc)(CPUAL *cpual, uint64_t newpc);
    int (*run_loop)(CPUAL *cpual);
    int (*stop)(CPUAL *cpual);
    void *(*save_context)(CPUAL *cpual);
    void  (*restore_context)(CPUAL *cpual, void *context);
}CPUAL;

typedef void (*stub_handler_t)(CPUAL* cpual);
// exported
extern void plugin_msg(char *, ...);
extern void register_stub_handler(stub_handler_t handler);

#endif /* main_h */
