#if !defined(AFX_SHELLTREEVIEW_H__48775716_74D4_4EBE_8212_0C33AA271BB0__INCLUDED_)
#define AFX_SHELLTREEVIEW_H__48775716_74D4_4EBE_8212_0C33AA271BB0__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000
// ShellTreeView.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CShellTreeView view

class CShellTreeView : public CXTPShellTreeView
{
protected:
	CShellTreeView();           // protected constructor used by dynamic creation
	DECLARE_DYNCREATE(CShellTreeView)

// Attributes
public:

// Operations
public:
	BOOL SelectRootFolderItemPath(CString& strFolderPath);
	BOOL SelectParentFolderItemPath(CString &strFolderPath);
	BOOL SelectFolderItemPath(CString &strFolderPath);
	BOOL GetSelectedParentFolderItemPath(CString& strFolderPath);
	void SetShellListView(CXTPShellListView* pShellListView);

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CShellTreeView)
	protected:
	virtual void OnDraw(CDC* pDC);      // overridden to draw this view
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	//}}AFX_VIRTUAL

// Implementation
protected:
	virtual ~CShellTreeView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif
	void CShellTreeView::OnInitialUpdate();

	// Generated message map functions
protected:
	int GetHeaderHeight() const;
	
	//{{AFX_MSG(CShellTreeView)
	afx_msg void OnNcCalcSize(BOOL bCalcValidRects, NCCALCSIZE_PARAMS FAR* lpncsp);
	afx_msg void OnNcPaint();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:
	CXTPShellListView* m_pShellListView;
};

AFX_INLINE void CShellTreeView::SetShellListView(CXTPShellListView* pShellListView) {
	m_pShellListView = pShellListView;
}

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_SHELLTREEVIEW_H__48775716_74D4_4EBE_8212_0C33AA271BB0__INCLUDED_)
