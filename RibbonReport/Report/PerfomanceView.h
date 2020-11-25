// PerfomanceView.h : header file
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

#if !defined(AFX_PERFOMANCEVIEW_H__INCLUDED_)
#define AFX_PERFOMANCEVIEW_H__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "ReportRecordView.h"

/////////////////////////////////////////////////////////////////////////////
// CPerfomanceView view

class CPerfomanceView : public CReportRecordView
{
protected:
	CPerfomanceView();           // protected constructor used by dynamic creation
	DECLARE_DYNCREATE(CPerfomanceView)

	// Attributes
public:
	void SetRecordItem(CXTPReportRecordItemVariant*& pItem);
	// Operations
public:
	CReportRecordView* GetTargetReportView();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPropertiesView)
	protected:
	virtual void OnDraw(CDC* pDC);      // overridden to draw this view
	//}}AFX_VIRTUAL

// Implementation
protected:
	virtual ~CPerfomanceView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
protected:
	//{{AFX_MSG(CPerfomanceView)
	//}}AFX_MSG
	afx_msg void OnReportItemDblClick(NMHDR* pNMHDR, LRESULT* /*result*/);

	DECLARE_MESSAGE_MAP()

private:
	CXTPReportRecordItemVariant* m_pItem;
	BOOL m_bDblClickClose;
};


//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PERFOMANCEVIEW_H__INCLUDED_)
