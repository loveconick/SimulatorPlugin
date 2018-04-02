//
//  main.c
//  pluginTest
//
//  Created by jia jerry on 2018/3/27.
//  Copyright Â© 2018å¹?jia.jerry. All rights reserved.
//

#define _PLUGIN

#include <stdbool.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <dlfcn.h>

#include "plugin.h"

void my_stub_handler(CPUAL* cpual)
{
	//const char      *dli_fname;     /* Pathname of shared object */
	//void            *dli_fbase;     /* Base address of shared object */
	//const char      *dli_sname;     /* Name of nearest symbol */
	//void            *dli_saddr;     /* Address of nearest symbol */
	Dl_info dlinfo;
	dladdr((const void *)cpual->gp->pc, &dlinfo);
	plugin_msg("%s %s", dlinfo.dli_fname, dlinfo.dli_sname);
	
    bool bHit = false;
    //plugin_msg("call stub lr: 0x%llx\n", cpual->gp->r[30]);
    if(cpual->gp->pc == (uint64_t)fopen){
        bHit = true;
        plugin_msg("call fopen(%s %s)", (char *)cpual->gp->r[0], (char *)cpual->gp->r[1]);
    }else if (cpual->gp->pc == (uint64_t)sysctlbyname) {
        bHit = true;
        plugin_msg("call sysctlbyname(%s), lr %llx", cpual->gp->r[0], cpual->gp->r[30]);
    }
	
    if (bHit) {
        plugin_msg("%08X %08X %p %p %p %p %p"
			, cpual->free, cpual->ret_code, cpual->vmcpu, cpual->cpu
				   , cpual->tmp_ctx, cpual->sp_ptr, cpual->stack_top);
		plugin_msg("%08X %08X %08X",cpual->gp->pc,cpual->gp->uc_sp,cpual->gp->sim_sp);
		for (int i=0; i<31; i++) {
			plugin_msg("%02d %08X",i,cpual->gp->r[i]);
		}
		
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




