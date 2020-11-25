// aaa.h : main header file for the RibbonReport application
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

#if !defined(AFX_RIBBONREPORT_H__DAD5979B_EBD4_4702_9500_D56B74BD4808__INCLUDED_)
#define AFX_RIBBONREPORT_H__DAD5979B_EBD4_4702_9500_D56B74BD4808__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols
#include "common.h"


/////////////////////////////////////////////////////////////////////////////
// CRibbonReportApp:
// See RibbonReport.cpp for the implementation of this class
//

class CRibbonReportApp : public CWinApp
{
public:
	CRibbonReportApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CRibbonReportApp)
	public:
	virtual BOOL InitInstance();
	virtual int ExitInstance();
	//}}AFX_VIRTUAL

// Implementation
	//{{AFX_MSG(CRibbonReportApp)
	afx_msg void OnAppAbout();
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
extern CXTPADOConnection theCon;
extern CRibbonReportApp theApp;
extern bool IsAdmin;
extern bool IsConnected;
//extern CFtpConnection* theFtpConPtr;


class CPaneHolder : public CWnd
{
public:
	virtual CObject* RefreshPropertyGrid(CXTPPropertyGrid* pPropertyGrid) 
	{
		UNREFERENCED_PARAMETER(pPropertyGrid);
		return NULL;
	}

	virtual BOOL OnPropertyGridValueChanged(CObject* pActiveObject, CXTPPropertyGridItem* pItem) 
	{
		UNREFERENCED_PARAMETER(pActiveObject);
		UNREFERENCED_PARAMETER(pItem);
		return FALSE;
	}
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_RIBBONREPORT_H__DAD5979B_EBD4_4702_9500_D56B74BD4808__INCLUDED_)
