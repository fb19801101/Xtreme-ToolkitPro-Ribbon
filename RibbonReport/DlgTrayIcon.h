// DlgTrayIcon.h : header file
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

#if !defined(__DLG_TRAYICON_H__)
#define __DLG_TRAYICON_H__

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CDlgTrayIcon dialog

class CDlgTrayIcon : public CXTPResizeDialog
{
// Construction
public:
	void EnableControls();
	CDlgTrayIcon(CWnd* pParentWnd = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CDlgTrayIcon)
	enum { IDD = IDD_DLG_TRAYICON };
	CStatic m_gboxToolTip;
	CEdit   m_editTooltip;
	CStatic m_txtInfo;
	CButton m_chkShowIcon;
	CButton m_chkAnimateIcon;
	CButton m_btnTooltip;
	CButton m_btnMinimizeToTray;
	CButton m_chkHideIcon;
	CStatic m_gboxBalloonTip;
	CStatic m_txtBalloonTitle;
	CStatic m_txtTimeOut;
	CStatic m_txtBalloonMsg;
	CEdit   m_editBalloonTitle;
	CEdit   m_editTimeout;
	CXTPNoFlickerWnd <CEdit> m_editBalloonMsg;
	CStatic m_txtBalloonIcon;
	CComboBox m_comboBalloonIcon;
	CButton m_btnShowBalloon;

	CString m_strToolTip;
	BOOL    m_bShowIcon;
	BOOL    m_bAnimateIcon;
	BOOL    m_bHideIcon;
	CString m_strBalloonTitle;
	int     m_iTimeOut;
	CString m_strBalloonMsg;
	int     m_iBalloonIcon;
	//}}AFX_DATA

	static void MinMaxWindow();
	static CDlgTrayIcon *m_pInstance;


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CDlgTrayIcon)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL


// Implementation
protected:
	HICON m_hIcon;
	static bool  m_bMinimized;
	CWnd* m_pParentWnd;

	// Generated message map functions
	//{{AFX_MSG(CDlgTrayIcon)
	virtual BOOL OnInitDialog();
	afx_msg void OnDestroy();

	afx_msg void OnChangeEditTooltip();
	afx_msg void OnBtnTooltip();
	afx_msg void OnBtnMinimizetray();
	afx_msg void OnChkShowicon();
	afx_msg void OnChkAnimateicon();
	afx_msg void OnChkHideicon();

	afx_msg void OnChangeEditBalloontitle();
	afx_msg void OnChangeEditTimeout();
	afx_msg void OnChangeEditBalloonmsg();
	afx_msg void OnSelendokComboBalloonicon();
	afx_msg void OnBtnShowBalloon();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
public:
	virtual INT_PTR DoModal(CWnd* pParentWnd);
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(__DLG_TRAYICON_H__)
