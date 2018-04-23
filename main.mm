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

//#include <objc/objc-runtime.h>
#include <objc/message.h>

#include "plugin.h"
#include "cpplib.hpp"


void PrintRegister(CPUAL* cpual)
{
	uint32_t threadid = mach_thread_self();
	/*plugin_msg("%08lx : 0x%016llX 0x%016llX %p %p %p %p %p"
			   ,threadid , cpual->free, cpual->ret_code, cpual->vmcpu, cpual->cpu
			   , cpual->tmp_ctx, cpual->sp_ptr, cpual->stack_top);
	plugin_msg("%08lx : pc==0x%016llX, lr==0x%016llX , sp==0x%016llX, 0x%016llX"
			   ,threadid ,cpual->gp->pc,cpual->gp->r[30],cpual->gp->uc_sp,cpual->gp->sim_sp);*/
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
		const char *pFileName = strrchr(dlinfo.dli_fname, '/');
		if (pFileName==NULL) {
			pFileName = dlinfo.dli_fname;
		}
		else
		{
			pFileName++;
		}
		plugin_msg("%08lx(lr=%llx) : %s %s", mach_thread_self(), cpual->gp->r[30], dlinfo.dli_sname, pFileName);
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
    }/*else if (cpual->gp->pc == (uint64_t)sysctlbyname) {
        plugin_msg("call sysctlbyname(%s), lr 0x%016llX", cpual->gp->r[0], cpual->gp->r[30]);
	}else if (cpual->gp->pc == (uint64_t)objc_msgSend) {
		plugin_msg("call fprintf : %s %d", (char *)cpual->gp->r[2], (int)cpual->gp->r[3]);
	}*/
}

extern "C" {

//###################################################
_export const char * module_get_title()
{
    return "plugintest";
}

_export const char * module_get_version()
{
    return "0.0.3";
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
    //plugin_msg("test module inited\n");
    register_stub_handler(my_stub_handler);
	loadSrcFunc();
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
