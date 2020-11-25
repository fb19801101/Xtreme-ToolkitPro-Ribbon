// DlgAbout.h : header file
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

#if !defined(AFX_DLGABOUT_H__FB67509E_7603_4797_939B_A82B573267B0__INCLUDED_)
#define AFX_DLGABOUT_H__FB67509E_7603_4797_939B_A82B573267B0__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "CreditStatic/HyperLink.h"

/////////////////////////////////////////////////////////////////////////////
// CDlgAbout window

class CDlgAbout : public CDialogEx
{
	// Construction
public:
	CDlgAbout();

	// Dialog Data
	//{{AFX_DATA(CDlgAbout)
	enum { IDD = IDD_DLG_ABOUT };

	//}}AFX_DATA
private:
	CHyperLink	m_ctlEmail;
	CHyperLink	m_ctlHome;

	// Overrides
	// ClassWizard generate virtual function overrides
	//{{AFX_VIRTUAL(CDlgAbout)
protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

	// Implementation
protected:
	// Generated message map functions
	//{{AFX_MSG(CDlgAbout)
	virtual BOOL OnInitDialog();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_DLGABOUT_H__FB67509E_7603_4797_939B_A82B573267B0__INCLUDED_)
