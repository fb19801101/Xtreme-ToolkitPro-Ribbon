// MergeView.h : header file
//
// This file is a part of the XTREME TOOLKIT PRO MFC class library.
// (c)1998-2012 Codejock Software, All Rights Reserved.
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

#if !defined(AFX_MERGEVIEW_H__INCLUDED_)
#define AFX_MERGEVIEW_H__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000



/////////////////////////////////////////////////////////////////////////////
// CMergeView view

class CMergeView : public CXTPReportView
{
	typedef CXTPReportView base;
protected:
	DECLARE_DYNCREATE(CMergeView)
	CMergeView();
	virtual ~CMergeView();

public:

	//{{AFX_VIRTUAL(CMergeView)
	protected:
	afx_msg void OnEndPrintPreview(CDC *pDC, CPrintInfo *pInfo, POINT point, CPreviewView *pView);
	//}}AFX_VIRTUAL

protected:
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:
	//{{AFX_MSG(CMergeView)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnDestroy();
	afx_msg void OnFilePrintPreview();

	// Command handler
	afx_msg void OnReportAllowEdit();
	afx_msg void OnReportEditOnClick();
	
	afx_msg void OnReportAutoSizing();
	afx_msg void OnReportFocusSubItems();
	afx_msg void OnReportWatermark();


	// Update handler
	afx_msg void OnUpdateReportAllowEdit    (CCmdUI *pCmdUI);
	afx_msg void OnUpdateReportEditOnClick  (CCmdUI *pCmdUI);
	afx_msg void OnUpdateReportAutoSizing   (CCmdUI *pCmdUI);
	afx_msg void OnUpdateReportFocusSubItems(CCmdUI *pCmdUI);
	afx_msg void OnUpdateReportWatermark    (CCmdUI *pCmdUI);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:

	BOOL m_bAutoSizing;
	BOOL m_bWatermark;

	CPrintPreviewState *m_pPreviewState;
};

//{{AFX_INSERT_LOCATION}}

#endif // !defined(AFX_MERGEVIEW_H__INCLUDED_)
