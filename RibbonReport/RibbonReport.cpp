// RibbonReport.cpp : Defines the class behaviors for the application.
//
// This file is a part of the XTREME TOOLKIT PRO MFC class library.
// (c)1998-2011 Codejock Software, All Rights Reserved.
//
// THIS SOURCE FILE IS THE PROPERTY OF CODEJOCK SOFTWARE AND IS NOT TO BE
// RE-DISTRIBUTED BY ANY MEANS WHATSOEVER WITHOUT THE EXPRESSED WRITTEN
// CONSENT OF CODEJOCK SOFTWARE.
//
// THIS SOURCE CODE CAN ONLY BE USED UNDER THE TERMS AND CONDITIONS OUTLINED
// IN THE XTREME TOOLKIT PRO LICENSE AGREEMENT. CODEJOCK SOFTWARE GRANTS TO
// YOU (ONE SOFTWARE DEVELOPER) THE LIMITED RIGHT TO USE THIS SOFTWARE ON A
// SINGLE COMPUTER.
//
// CONTACT INFORMATION:
// support@codejock.com
// http://www.codejock.com
//
/////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "RibbonReport.h"
#include "RibbonReportDoc.h"
#include "RibbonReportView.h"
#include "MainFrm.h"

#include "DlgAbout.h"
#include "AboutDlg.h"
#include "DlgLogin.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CRibbonReportApp

BEGIN_MESSAGE_MAP(CRibbonReportApp, CWinApp)
	//{{AFX_MSG_MAP(CRibbonReportApp)
	ON_COMMAND(ID_APP_ABOUT, OnAppAbout)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG_MAP
	// Standard file based document commands
	ON_COMMAND(ID_FILE_PRINT_SETUP, CWinApp::OnFilePrintSetup)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CRibbonReportApp construction

CRibbonReportApp::CRibbonReportApp()
{
	// TODO: add construction code here,
	// Place all significant initialization in InitInstance
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CRibbonReportApp object

CRibbonReportApp theApp;
CXTPADOConnection theCon;
bool IsAdmin = true;
bool IsConnected = false;

/////////////////////////////////////////////////////////////////////////////
// CRibbonReportApp initialization

BOOL CRibbonReportApp::InitInstance()
{
	if (!AfxOleInit())
	{
		AfxMessageBox(IDP_OLE_INIT_FAILED);
		return FALSE;
	}
	AfxEnableControlContainer();
	//afxAmbientActCtx = FALSE;//禁用 0xC015000F: 正被停用的激活上下文不是最近激活的
	CXTPWinDwmWrapper().SetProcessDPIAware();

	// Standard initialization
	// If you are not using these features and wish to reduce the size
	//  of your final executable, you should remove from the following
	//  the specific initialization routines you do not need.

#if _MSC_VER <= 1200 // MFC 6.0 or earlier
#ifdef _AFXDLL
	Enable3dControls();         // Call this when using MFC in a shared DLL
#else
	Enable3dControlsStatic();   // Call this when linking to MFC statically
#endif
#endif

	try
	{
		InitCommon();
		XTPCHAR path[MAX_PATH];
		GetModuleFileName(AfxGetApp()->m_hInstance,path,MAX_PATH);
		CXTPString xml(path),val;
		xml = xml.Mid(0,xml.ReverseFind('\\'));
		theCon.SetDataPath(xml);
		xml = xml+"\\RibbonReport.xml";
		CXTPTinyXmlDocument doc(xml);
		if(doc.LoadFile())
		{
			LogInfo(L"XML File Load Successful!");
			CXTPTinyXmlNode* node = doc.RootElement();
			if(!node) return FALSE;
			node = node->NextSibling();
			if(!node) return FALSE;
			CXTPTinyXmlElement* root = node->ToElement();
			if(!root) return FALSE;
			CXTPTinyXmlElement* elem = root->FirstChildElement();
			if(!elem)  return FALSE;
			val = CXTPString(elem->Attribute("SQLServer"));
			theCon.SetServer(val);
			elem = elem->NextSiblingElement();
			if(!elem)  return FALSE;
			val = CXTPString(elem->Attribute("SQLUser"));
			theCon.SetUId(val);
			elem = elem->NextSiblingElement();
			if(!elem)  return FALSE;
			val = CXTPString(elem->Attribute("SQLPwd"));
			theCon.SetPwd(val);
			elem = elem->NextSiblingElement();
			if(!elem)  return FALSE;
			val = CXTPString(elem->Attribute("SQLDb"));
			g_DataBase = val.t_str();
			g_TablePrix = g_DataBase.Mid(0,g_DataBase.ReverseFind('.')+1)+_T("[dbo].");
			elem = elem->NextSiblingElement();
			if(!elem)  return FALSE;
			val = CXTPString(elem->Attribute("UserID"));
			g_SysUid = val.t_str();
			elem = elem->NextSiblingElement();
			doc.SaveFile();

			theCon.SetDataDriver(CXTPADOConnection::xtpAdoMSSQL);
			theCon.SetDataBase(g_DataBase);
			theCon.InitConnectionString();

			if (theCon.Open())
			{
				IsConnected = TRUE;

				CDlgLogin dlg;
				ado_users src;
				if(FindSysUid(src))
				{
					g_SysUid = src.id;
					dlg.m_strUser = g_SysUser = src.sysuser;
					dlg.m_strPwd = g_SysPwd = src.password;
					dlg.m_bRemberPwd = g_SysRemberPwd = src.remberpwd;
					dlg.m_bAutoLogin = g_SysAutoLogin = src.autologin;
					dlg.m_bAutoFrame = g_SysAutoFrame = src.autoframe;
				}

				if(!src.autologin && dlg.DoModal() == IDCANCEL)
					return FALSE;

				if(Login() == 0)
				{
					msgErr(_T("该用户名不存在或\n用户名密码错误！"));
					return FALSE;
				}
			}
			else msgErr(_T("SQLServer2012 数据库连接失败！"));
		}
		else msgErr(_T("RibbonReport.xml 文件加载失败！"));

		// Change the registry key under which our settings are stored.
		// TODO: You should modify this string to be something appropriate
		// such as the name of your company or organization.
		SetRegistryKey(_T("Codejock Software Sample Applications"));

		LoadStdProfileSettings();  // Load standard INI file options (including MRU)

		// Register the application's document templates.  Document templates
		//  serve as the connection between documents, frame windows and views.

		CSingleDocTemplate* pDocTemplate;
		pDocTemplate = new CSingleDocTemplate(
			IDR_MAINFRAME,
			RUNTIME_CLASS(CRibbonReportDoc),
			RUNTIME_CLASS(CMainFrame),       // main SDI frame window
			RUNTIME_CLASS(CRibbonReportView));
		pDocTemplate->SetContainerInfo(IDR_MENU_MINITOOLBAR);
		AddDocTemplate(pDocTemplate);

		// Parse command line for standard shell commands, DDE, file open
		CCommandLineInfo cmdInfo;
		ParseCommandLine(cmdInfo);

		// Dispatch commands specified on the command line
		if (!ProcessShellCommand(cmdInfo))
			return FALSE;

		// The one and only window has been initialized, so show and update it.
		m_pMainWnd->ShowWindow(SW_SHOW);
		m_pMainWnd->UpdateWindow();

		ShowSampleHelpPopup(m_pMainWnd, IDR_MAINFRAME);

		LogInfo(L"SQLServer2012 Connect Successful!");
	}
	catch(CException *e)
	{
		LogErrorExp(L"SQLServer2012 Connect Faild!", e);
	}

	return TRUE;
}

int CRibbonReportApp::ExitInstance()
{
	try
	{
		if(IsConnected)
		{
			theCon.Close();
			IsConnected = FALSE;
		}

		XTPCHAR path[MAX_PATH];
		GetModuleFileName(AfxGetApp()->m_hInstance,path,MAX_PATH);
		CXTPString xml(path),val;
		xml = xml.Mid(0,xml.ReverseFind('\\'));
		xml = xml+"\\RibbonReport.xml";
		CXTPTinyXmlDocument doc(xml);
		if(doc.LoadFile())
		{
			CXTPTinyXmlNode* node = doc.RootElement();
			if(!node)  return 0;
			node = node->NextSibling();
			if(!node)  return 0;
			CXTPTinyXmlElement* root = node->ToElement();
			if(!root)  return 0;
			CXTPTinyXmlElement* elem = root->FirstChildElement();
			if(!elem)  return 0;
			elem = elem->NextSiblingElement();
			if(!elem)  return 0;
			elem = elem->NextSiblingElement();
			if(!elem)  return 0;
			elem = elem->NextSiblingElement();
			if(!elem)  return 0;
			elem = elem->NextSiblingElement();
			if(!elem)  return 0;
			elem->SetAttribute("UserID",CXTPString(g_SysUid).c_ptr());
			doc.SaveFile();
		}

		LogInfo(L"SQLServer2012 Close Successful!");
	}
	catch(CException *e)
	{
		LogErrorExp(L"SQLServer2012 Close Faild!", e);
	}

	return CWinApp::ExitInstance();
}


/////////////////////////////////////////////////////////////////////////////
// CRibbonReportApp message handlers

void CRibbonReportApp::OnAppAbout()
{
	CDlgAbout dlgAbout;
	dlgAbout.DoModal();
}