//
//  main.c
//  pluginTest
//
//  Created by jia jerry on 2018/3/27.
//  Copyright  jia.jerry. All rights reserved.
//

#define _PLUGIN

#include <stdbool.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <dlfcn.h>
#include <mach/mach.h>

#include <Foundation/Foundation.h>
//#include <objc/objc-runtime.h>
#include <objc/runtime.h>
#include <objc/message.h>

#include "plugin.h"
#include "cpplib.hpp"


int scan_objc_method()
{
    uint32_t outCount, methodCnt=0;
    uint32_t outCountMethod = 0;
    Class *classes = objc_copyClassList(&outCount);
    plugin_msg("found classes count %d", outCount);
    for (int i = 0; i < outCount; i++) {
        //plugin_msg("%s", class_getName(classes[i]));
        Method * methods = class_copyMethodList(classes[i], &outCountMethod);
        for (int j = 0; j < outCountMethod; j++) {
            Method method = methods[j];
            SEL methodSEL = method_getName(method);
            //const char * selName = sel_getName(methodSEL);
            if (methodSEL) {
                methodCnt++;
                //impMap.insert(pair<uint64_t, void *>((uint64_t)method->method_imp, (void *)method));
                //plugin_msg("[%s %s] -> %llx", class_getName(classes[i]), selName, method->method_imp);
            }
        }
    }
    free(classes);
    plugin_msg("found methods count %d", methodCnt);
    return 0;
}

int get_program_info(void)
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier = infoDic[@"CFBundleIdentifier"];
    plugin_msg("app [%s] started", [bundleIdentifier UTF8String]);
    scan_objc_method();
    return 0;
}


uint64_t g_addr_objc_storeStrong;


void PrintRegister(CPUAL* cpual)
{
	uint32_t threadid = mach_thread_self();
	/*plugin_msg("%08lx : 0x%016llX 0x%016llX %p %p %p %p %p"
			   ,threadid , cpual->free, cpual->ret_code, cpual->vmcpu, cpual->cpu
			   , cpual->tmp_ctx, cpual->sp_ptr, cpual->stack_top);
	plugin_msg("%08lx : pc==0x%016llX, lr==0x%016llX , sp==0x%016llX, 0x%016llX"
			   ,threadid ,cpual->gp->pc,cpual->gp->r[30],cpual->gp->uc_sp,cpual->gp->sim_sp);*/
	plugin_msg("%08lx : pc==0x%016llX, lr==0x%016llX , sp==0x%016llX, 0x%016llX"
			   ,threadid ,cpual->gp->pc,cpual->gp->r[30],cpual->gp->uc_sp,cpual->gp->sim_sp);
	int i = 0;
	for (i=0; i<24; i+=8) {
		plugin_msg("%08lx : %02d 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX" ,threadid ,i
				   ,cpual->gp->r[i+0],cpual->gp->r[i+1],cpual->gp->r[i+2],cpual->gp->r[i+3]
				   ,cpual->gp->r[i+4],cpual->gp->r[i+5],cpual->gp->r[i+6],cpual->gp->r[i+7]);
	}
	plugin_msg("%08lx : %02d 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX" ,threadid ,i
			   ,cpual->gp->r[i+0],cpual->gp->r[i+1],cpual->gp->r[i+2],cpual->gp->r[i+3]
			   ,cpual->gp->r[i+4],cpual->gp->r[i+5],cpual->gp->r[i+6]);
#if 0
	for (i=0; i<32; i+=8) {
		plugin_msg("%02d %Lf, %Lf, %Lf, %Lf, %Lf, %Lf, %Lf, %Lf",i
				   ,cpual->fp->v[i+0],cpual->fp->v[i+1],cpual->fp->v[i+2],cpual->fp->v[i+3]
				   ,cpual->fp->v[i+4],cpual->fp->v[i+5],cpual->fp->v[i+6],cpual->fp->v[i+7]);
	}
#else
	/*for (i=0; i<8; i+=8) {
		plugin_msg("%02d %Lf, %Lf, %Lf, %Lf, %Lf, %Lf, %Lf, %Lf",i
				   ,cpual->fp->v[i+0].F,cpual->fp->v[i+1].F,cpual->fp->v[i+2].F,cpual->fp->v[i+3].F
				   ,cpual->fp->v[i+4].F,cpual->fp->v[i+5].F,cpual->fp->v[i+6].F,cpual->fp->v[i+7].F);
	}
	for (i=0; i<32; i+=8) {
		plugin_msg("%02d %lf, %lf, %lf, %lf, %lf, %lf, %lf, %lf",i
				   ,cpual->fp->v[i+0].f,cpual->fp->v[i+1].f,cpual->fp->v[i+2].f,cpual->fp->v[i+3].f
				   ,cpual->fp->v[i+4].f,cpual->fp->v[i+5].f,cpual->fp->v[i+6].f,cpual->fp->v[i+7].f);
	}
	for (i=0; i<32; i+=8) {
		plugin_msg("%02d %016lllX, %016lllX, %016lllX, %016lllX, %016lllX, %016lllX, %016lllX, %016lllX",i
				   ,cpual->fp->v[i+0].n,cpual->fp->v[i+1].n,cpual->fp->v[i+2].n,cpual->fp->v[i+3].n
				   ,cpual->fp->v[i+4].n,cpual->fp->v[i+5].n,cpual->fp->v[i+6].n,cpual->fp->v[i+7].n);
	}*/
#endif
}

void my_stub_handler(CPUAL* cpual)
{
	//const char      *dli_fname;     /* Pathname of shared object */
	//void            *dli_fbase;     /* Base address of shared object */
	//const char      *dli_sname;     /* Name of nearest symbol */
	//void            *dli_saddr;     /* Address of nearest symbol */
	Dl_info dlinfo;
	if(cpual->gp->pc == (uint64_t)objc_msgSend)
		plugin_msg("%08lx(lr=%llx) : objc method %s", mach_thread_self(), cpual->gp->r[30], (char *)cpual->gp->r[1]);
	else{
		dladdr((const void *)cpual->gp->pc, &dlinfo);
		if ((g_addr_objc_storeStrong==0) && (strcmp(dlinfo.dli_sname,"objc_storeStrong")==0)) {
			g_addr_objc_storeStrong = cpual->gp->pc;
			plugin_msg((char *)"objc_storeStrong addr = %llx", g_addr_objc_storeStrong);
		}
		/*const char *pFileName = strrchr(dlinfo.dli_fname, '/');
		if (pFileName==NULL) {
			pFileName = dlinfo.dli_fname;
		}
		else
		{
			pFileName++;
		}
		plugin_msg("%08lx(lr=%llx) : %s %s", mach_thread_self(), cpual->gp->r[30], dlinfo.dli_sname, pFileName);*/
		plugin_msg("%08lx(lr=%llx) : %s %s", mach_thread_self(), cpual->gp->r[30], dlinfo.dli_sname, dlinfo.dli_fname);
	}
	_FUNC_FILE_ *pFunc = pFindSrcFuncByLR(cpual->gp->r[30]);
	if (pFunc!=NULL)
	{
		plugin_msg("%08lx(lr=%llx) : caller is %-20s : %5u : %s", mach_thread_self()
			, cpual->gp->r[30], pFunc->szFileName, pFunc->dwFileLine, pFunc->szFuncName);
		//PrintRegister(cpual);
	}
	
    //plugin_msg("call stub lr: 0x0x%016llX\n", cpual->gp->r[30]);
    if(cpual->gp->pc == (uint64_t)fopen){
        plugin_msg("call fopen(%s %s)", (char *)cpual->gp->r[0], (char *)cpual->gp->r[1]);
	}else if (cpual->gp->pc == g_addr_objc_storeStrong) {
		plugin_msg("objc_storeStrong param : %llx %llx ", cpual->gp->r[0], cpual->gp->r[1]);
		//void objc_storeStrong(id *location, id obj)
		/*union
		 {
		 id *p;
		 uint64_t u;
		 } union_idp_u;*/
		//plugin_msg("%llx %@", cpual->gp->r[0], (id *)cpual->gp->r[0]);
		/*if (cpual->gp->r[30]==(uint64_t)0x100091bb8)
		{
			cpual->gp->r[1] = 0;
		}*/
	}/*else if (cpual->gp->pc == (uint64_t)sysctlbyname) {
        plugin_msg("call sysctlbyname(%s), lr 0x%016llX", cpual->gp->r[0], cpual->gp->r[30]);
	}else if (cpual->gp->pc == (uint64_t)objc_msgSend) {
		plugin_msg("call fprintf : %s %d", (char *)cpual->gp->r[2], (int)cpual->gp->r[3]);
	}*/
}

void my_hookcode_handler(uc_engine *uc, uint64_t address, uint32_t size, void *user_data)
{
    CPUAL *cpual = (CPUAL*)uc_get_userdata(uc);
    if(0x1000080a4 == address){
        plugin_msg("0x1000080a4 r0 %llx, r19", cpual->gp->r[0], cpual->gp->r[19]);
    }else if(0x100007f50 == address){
        //uint64_t val = cpual->gp->r[1];
		//需要使用uc_reg_write进行内核寄存器设置，不能直接cpual->gp->r[0]=cpual->gp->r[1];可能是因为cpual指向的地址只是内核寄存器的一个拷贝
        //uc_reg_write(uc, UC_ARM64_REG_X0, &val);
        //val = cpual->gp->r[2];
        //uc_reg_write(uc, UC_ARM64_REG_X1, &val);
        //plugin_msg("0x100007f50 set r0 %llx", val);
	}else if((address==0x100054a24) || (address==0x100054a44) || (address==0x100054a78)){
		PrintRegister(cpual);
	}
}

extern "C" {

//###################################################
_export const char * module_get_title()
{
    return "plugintest";
}

_export const char * module_get_version()
{
    return "0.0.5";
}

_export const char * module_get_author()
{
    return "jerry";
}

_export const char * module_get_description()
{
    return "test plugin function";
}


_export int module_init(void)
{
    uint32_t a,b;
    //plugin_msg("test module inited\n");
    register_stub_handler(my_stub_handler);
    register_unicorn_hookcode_handler(my_hookcode_handler);
    get_program_info();
    uc_version(&a, &b);
    plugin_msg("uc version [%d:%d]", a, b);
	loadSrcFunc();
	g_addr_objc_storeStrong = (uint64_t)dlsym(RTLD_DEFAULT, "_objc_storeStrong");
	if (g_addr_objc_storeStrong==0) {
		plugin_msg((char *)"%s",dlerror());
	}
    return 0;
}

_export int module_finit(void)
{
    //plugin_msg("test module inited\n");
    return 0;
}

_export int module_cleanup(void)
{
    //plugin_msg("test module inited\n");
    return 0;
}

_export void* module_thread(void *para)
{
    return NULL;
}

}
