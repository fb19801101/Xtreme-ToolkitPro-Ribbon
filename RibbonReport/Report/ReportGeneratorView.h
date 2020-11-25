// ReportGeneratorView.h : interface of the CReportGeneratorView class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_REPORTGENERATORVIEW_H__INCLUDED_)
#define AFX_REPORTGENERATORVIEW_H__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "RibbonReportView.h"

class CRibbonReportDoc;

class CReportGeneratorView : public CView
{
	friend class CReportRecordView;
protected: // create from serialization only
	CReportGeneratorView();
	DECLARE_DYNCREATE(CReportGeneratorView)

// Attributes
public:
	CRibbonReportDoc* GetDocument();

public:
	CRibbonReportView* GetReportRecordView();
	void LoadReportFile();

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CReportGeneratorView)
	public:
	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	protected:
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	virtual void OnPrint(CDC* pDC, CPrintInfo* pInfo);
	//}}AFX_VIRTUAL

// Implementation
public:
	virtual ~CReportGeneratorView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	//{{AFX_MSG(CReportGeneratorView)
	afx_msg void OnOpenReportFile();
	afx_msg void OnActiveRibbonReportView();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:
	CXTPReportGenerator	m_rptGenerator;
	CString				m_output;
};

#ifndef _DEBUG  // debug version in ReportGeneratorView.cpp
inline CRibbonReportDoc* CReportGeneratorView::GetDocument()
{ return (CRibbonReportDoc*)m_pDocument; }
#endif

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_REPORTGENERATORVIEW_H__INCLUDED_)
