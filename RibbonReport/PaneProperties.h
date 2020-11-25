// PaneProperties.h : header file
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

#if !defined(AFX_PANEPROPERTIES_H__459C9EAA_E750_419F_BA3D_8AF424923076__INCLUDED_)
#define AFX_PANEPROPERTIES_H__459C9EAA_E750_419F_BA3D_8AF424923076__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "RibbonReport.h"

/////////////////////////////////////////////////////////////////////////////
// CPaneProperties window

class CChartView;
class CReportRecordView;
class CPaneProperties : public CPaneHolder
{
// Construction
public:
	CPaneProperties();

// Attributes
public:
	CXTPToolBar m_wndToolBar;
	CXTPPropertyGrid m_wndPropertyGrid;

	CPaneHolder* m_pActivePane;
	CObject* m_pActiveObject;
	CXTPPropertyGridUpdateContext m_stateExpanding;

	UINT m_nActiveChartStyle;

	void Refresh(CObject* pActiveObject = NULL, CPaneHolder* pActivePane = NULL);
	void RefreshPaneProperties();

	void RefreshReportProperties();
	void RefreshChartProperties();

	void OnPropertyReportValueChanged(CXTPPropertyGridItem* pItem );
	void OnPropertyChartValueChanged(CXTPPropertyGridItem* pItem );

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPaneProperties)
	//}}AFX_VIRTUAL

// Implementation
public:
	virtual ~CPaneProperties();

	// Generated message map functions
protected:
	//{{AFX_MSG(CPaneProperties)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnSetFocus(CWnd*);
	afx_msg LRESULT OnGridNotify(WPARAM wParam, LPARAM lParam);

	//}}AFX_MSG

	afx_msg void OnPanePropertiesCategorized();
	afx_msg void OnUpdatePanePropertiesCategorized(CCmdUI* pCmdUI);
	afx_msg void OnPanePropertiesAlphabetic();
	afx_msg void OnUpdatePanePropertiesAlphabetic(CCmdUI* pCmdUI);
	afx_msg void OnPanePropertiesPages();
	afx_msg void OnUpdatePanePropertiesPages(CCmdUI* pCmdUI);

	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PANEPROPERTIES_H__459C9EAA_E750_419F_BA3D_8AF424923076__INCLUDED_)
