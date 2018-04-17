//
//  cpplib.cpp
//  pluginTest
//
//  Created by zhangzhiyong on 2018/4/17.
//  Copyright © 2018年 jia.jerry. All rights reserved.
//

#include "cpplib.hpp"


_FUNC_FILE_ *g_pFuncFile = NULL;
uint32_t g_u32FuncNumb = 0;

bool loadSrcFunc(void)
{
	char *pSrcFunc = (char *)"/Users/zzy/Desktop/SrcFunc.txt";
	FILE *fp = fopen(pSrcFunc, "r");
	if (fp==NULL)
	{
		plugin_msg((char *)"fopen %s fail\n", pSrcFunc);
		return(false);
	}
	
	plugin_msg((char *)"fopen %s success\n", pSrcFunc);
	int nLines = 0;
	fscanf(fp, "%d", &nLines);
	if ((nLines>0) && (nLines<100000))
	{
		g_pFuncFile = new _FUNC_FILE_[nLines];
		if (g_pFuncFile==NULL)
		{
			plugin_msg((char *)"new memmory fail\n");
			fclose(fp);
			return(false);
		}
		memset(g_pFuncFile, 0, sizeof(_FUNC_FILE_)*nLines);
		g_u32FuncNumb = 0;
		_FUNC_FILE_ *p = g_pFuncFile;
		//0000000100004DD0	0000000100004E58	UIViewController+Swizzling.m	18	+[UIViewController(Swizzling)-load]
		while (fscanf(fp, "%llx %llx %s %u %s", &p->u64FuncAdd, &p->u64FuncEnd
					  , &p->szFileName, &p->dwFileLine, &p->szFuncName)==5)
		{
			p++;
			g_u32FuncNumb++;
		}
		plugin_msg((char *)"Load %u Souce Functions\n", g_u32FuncNumb);
	}
	fclose(fp);
	return(true);
}

_FUNC_FILE_ *pFindSrcFuncByLR(uint64_t lr)
{
	uint32_t i;
	for (i=0; i<g_u32FuncNumb; i++)
	{
		if ((lr>g_pFuncFile[i].u64FuncAdd) && (lr<g_pFuncFile[i].u64FuncEnd))
		{
			return(g_pFuncFile+i);
		}
	}
	return(NULL);
}
