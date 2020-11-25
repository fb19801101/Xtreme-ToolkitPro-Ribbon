// RibbonResource.h : main header file for the RIBBONRESOURCE application
//

#if !defined(AFX_RIBBONRESOURCE_H__2F573F31_A4FA_4B5C_89B4_EA0AB88DF566__INCLUDED_)
#define AFX_RIBBONRESOURCE_H__2F573F31_A4FA_4B5C_89B4_EA0AB88DF566__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CRibbonResourceApp:
// See RibbonResource.cpp for the implementation of this class
//

class CRibbonResourceApp : public CWinApp
{
public:
	CRibbonResourceApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CRibbonResourceApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation
	//{{AFX_MSG(CRibbonResourceApp)
	afx_msg void OnAppAbout();
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

extern CRibbonResourceApp theApp;

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_RIBBONRESOURCE_H__2F573F31_A4FA_4B5C_89B4_EA0AB88DF566__INCLUDED_)
