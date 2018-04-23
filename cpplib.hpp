//
//  cpplib.hpp
//  pluginTest
//
//  Created by zhangzhiyong on 2018/4/17.
//  Copyright © 2018年 jia.jerry. All rights reserved.
//

#ifndef cpplib_hpp
#define cpplib_hpp

#include <stdbool.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <dlfcn.h>
#include <mach/mach.h>

//#include <objc/objc-runtime.h>
#include <objc/message.h>

#include "plugin.h"

//extern "C" {
//函数的相关信息
struct _FUNC_FILE_
{
	uint64_t	u64FuncAdd;				//函数地址（本来是map的key，加到value里方便调试）
	uint64_t	u64FuncEnd;				//函数大小
	char		szFuncName[256];		//函数名字
	char		szFileName[256];		//所在文件
	uint32_t	dwFileLine;				//文件行数
};
typedef struct _FUNC_FILE_ _FUNC_FILE_;

bool loadSrcFunc(void);
_FUNC_FILE_ *pFindSrcFuncByLR(uint64_t lr);

void PrintCallStack(void);
//};

#endif /* cpplib_hpp */
