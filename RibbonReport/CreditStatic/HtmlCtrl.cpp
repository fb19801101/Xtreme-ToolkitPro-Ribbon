// HtmlCtrl.cpp : implementation file
//
// HtmlCtrl static control. Will open the default browser with the given URL
// when the user clicks on the link.
//
// Copyright (C) 1997, 1998 Chris Maunder
// All rights reserved. May not be sold for profit.
//
// Thanks to P錶 K. T鴑der for auto-size and window caption changes.
//
// "GotoURL" function by Stuart Patterson
// As seen in the August, 1997 Windows Developer's Journal.
// Copyright 1997 by Miller Freeman, Inc. All rights reserved.
// Modified by Chris Maunder to use TCHARs instead of chars.
//
// "Default hand cursor" from Paul DiLascia's Jan 1998 MSJ article.
//

#include "stdafx.h"
#include "HtmlCtrl.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CHyperLink

IMPLEMENT_DYNAMIC(CHtmlCtrl, CHtmlView)
CHtmlCtrl::CHtmlCtrl()
{
}

CHtmlCtrl::~CHtmlCtrl()
{
}

BEGIN_MESSAGE_MAP(CHtmlCtrl, CHtmlView)
	//{{AFX_MSG_MAP(HtmlCtrl)
	ON_WM_DESTROY()
	ON_WM_MOUSEACTIVATE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CHyperLink message handlers

//ShowHTMLDialog对话框打开网页
BOOL CHtmlCtrl::ShowHtml(LPWSTR url)
{
	//装载动态连
	HINSTANCE hinstMSHTML = LoadLibrary(_T("MSHTML.DLL"));
	//此地址名称可直接用html文件名代替
	LPWSTR lpUrl=url; 
	if(hinstMSHTML)//装载动态连接库成功
	{
		SHOWHTMLDIALOGFN *pfnShowHTMLDialog;
		pfnShowHTMLDialog = (SHOWHTMLDIALOGFN*) GetProcAddress(hinstMSHTML, "ShowHTMLDialog");
		if(pfnShowHTMLDialog)
		{
			IMoniker *moniker=NULL;
			//
			if( FAILED(CreateURLMoniker( NULL, (LPWSTR)lpUrl, &moniker ) ))
			{
				FreeLibrary(hinstMSHTML);
				return FALSE;
			}
			//调用ShowHTMLDialog函数显示URL上的HTML文件
			pfnShowHTMLDialog(NULL, moniker, NULL, NULL, NULL);

			if(moniker != NULL)
				moniker->Release();

			//显示成功，返回TRUE
			return TRUE;

		}
		else //GetProcessAddress失败
			return FALSE;

		FreeLibrary(hinstMSHTML);
	}
	else //装载动态连接库失败
		return FALSE;
}

//利用默认浏览器打开网页
void CHtmlCtrl::GetUrl(CString sURL)
{
	HKEY hkRoot,hSubKey; //定义注册表根关键字及子关键字 
	XTPCHAR ValueName[256]; 
	unsigned char DataValue[256]; 
	unsigned long cbValueName=256; 
	unsigned long cbDataValue=256; 
	char ShellChar[256]; //定义命令行 
	DWORD dwType; 

	//打开注册表根关键字 
	if(RegOpenKey(HKEY_CLASSES_ROOT,NULL,&hkRoot)==ERROR_SUCCESS) 
	{ 
		//打开子关键字 
		if(RegOpenKeyEx(hkRoot, 
			_T("htmlfile\\shell\\open\\command"), 
			0, 
			KEY_ALL_ACCESS, 
			&hSubKey)==ERROR_SUCCESS) 
		{ 
			//读取注册表，获取默认浏览器的命令行  
			RegEnumValue(hSubKey,  
				0, 
				ValueName, 
				&cbValueName, 
				NULL, 
				&dwType, 
				DataValue, 
				&cbDataValue); 
			// 调用参数（主页地址）赋值 
			strcpy(ShellChar,(LPCSTR )DataValue); 
			strcat(ShellChar,CXTPString(sURL));
			// 启动浏览器 
			WinExec(ShellChar,SW_SHOW); 
		} 
		else 
		{
			//关闭注册表 
			RegCloseKey(hSubKey); 
			RegCloseKey(hkRoot);
		}
	}
}

// Create control in same position as an existing static control with
// the same ID (could be any kind of control, really)
BOOL CHtmlCtrl::CreateFromStatic(UINT nID, CWnd* pParent)
{
	CStatic wndStatic;
	if (!wndStatic.SubclassDlgItem(nID, pParent))
		return FALSE;

	// Get static control rect, convert to parent's client coords.
	CRect rc;
	wndStatic.GetWindowRect(&rc);
	pParent->ScreenToClient(&rc);
	wndStatic.DestroyWindow();

	// create HTML control (CHtmlView)
	return Create(NULL,						 // class name
		NULL,										 // title
		(WS_CHILD | WS_VISIBLE ),			 // style
		rc,										 // rectangle
		pParent,									 // parent
		nID,										 // control ID
		NULL);	                                    // frame/doc context not used
}

// Override to avoid CView stuff that assumes a frame.
void CHtmlCtrl::OnDestroy()
{
	// This is probably unecessary since ~CHtmlView does it, but
	// safer to mimic CHtmlView::OnDestroy.
	if (m_pBrowserApp) {
		//m_pBrowserApp->Release();
		m_pBrowserApp = NULL;
	}
	CWnd::OnDestroy(); // bypass CView doc/frame stuff
}

// Override to avoid CView stuff that assumes a frame.
int CHtmlCtrl::OnMouseActivate(CWnd* pDesktopWnd, UINT nHitTest, UINT msg)
{
	// bypass CView doc/frame stuff
	return CWnd::OnMouseActivate(pDesktopWnd, nHitTest, msg);
}

