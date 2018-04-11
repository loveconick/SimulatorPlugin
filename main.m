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

//#include <objc/objc-runtime.h>
#include <objc/message.h>

#include "plugin.h"


void PrintRegister(CPUAL* cpual)
{
	plugin_msg("0x%016llX 0x%016llX %p %p %p %p %p"
			   , cpual->free, cpual->ret_code, cpual->vmcpu, cpual->cpu
			   , cpual->tmp_ctx, cpual->sp_ptr, cpual->stack_top);
	plugin_msg("pc==0x%016llX, lr==0x%016llX , sp==0x%016llX, 0x%016llX"
			   ,cpual->gp->pc,cpual->gp->r[30],cpual->gp->uc_sp,cpual->gp->sim_sp);
	int i = 0;
	for (i=0; i<24; i+=8) {
		plugin_msg("%02d 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX",i
				   ,cpual->gp->r[i+0],cpual->gp->r[i+1],cpual->gp->r[i+2],cpual->gp->r[i+3]
				   ,cpual->gp->r[i+4],cpual->gp->r[i+5],cpual->gp->r[i+6],cpual->gp->r[i+7]);
	}
	plugin_msg("%02d 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX 0x%016llX",i
			   ,cpual->gp->r[i+0],cpual->gp->r[i+1],cpual->gp->r[i+2],cpual->gp->r[i+3]
			   ,cpual->gp->r[i+4],cpual->gp->r[i+5],cpual->gp->r[i+6]);
}

void my_stub_handler(CPUAL* cpual)
{
	//const char      *dli_fname;     /* Pathname of shared object */
	//void            *dli_fbase;     /* Base address of shared object */
	//const char      *dli_sname;     /* Name of nearest symbol */
	//void            *dli_saddr;     /* Address of nearest symbol */
	Dl_info dlinfo;
	if(cpual->gp->pc == (uint64_t)objc_msgSend)
		plugin_msg("objc method %s", (char *)cpual->gp->r[1]);
	else{
		dladdr((const void *)cpual->gp->pc, &dlinfo);
		plugin_msg("%s %s", dlinfo.dli_fname, dlinfo.dli_sname);
	}
	PrintRegister(cpual);
	
    //plugin_msg("call stub lr: 0x0x%016llX\n", cpual->gp->r[30]);
    if(cpual->gp->pc == (uint64_t)fopen){
        plugin_msg("call fopen(%s %s)", (char *)cpual->gp->r[0], (char *)cpual->gp->r[1]);
    }else if (cpual->gp->pc == (uint64_t)sysctlbyname) {
        plugin_msg("call sysctlbyname(%s), lr 0x%016llX", cpual->gp->r[0], cpual->gp->r[30]);
	}else if (cpual->gp->pc == (uint64_t)1) {	//objc_msgSend
		plugin_msg("call fprintf : %s %d", (char *)cpual->gp->r[2], (int)cpual->gp->r[3]);
	}
}

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
