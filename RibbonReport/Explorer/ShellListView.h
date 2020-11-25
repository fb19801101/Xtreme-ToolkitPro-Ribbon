#if !defined(AFX_SHELLLISTVIEW_H__218BC459_82F2_4781_889B_72318030490E__INCLUDED_)
#define AFX_SHELLLISTVIEW_H__218BC459_82F2_4781_889B_72318030490E__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000
// ShellListView.h : header file
//

#include "MainFrm.h"


/////////////////////////////////////////////////////////////////////////////
// CShellListView view


enum ENUM_LISTCTRL_MSG{ WM_USER_DROPFILESTOLISTCTRL = WM_APP + 0x0100 };

class CShellListView : public CXTPShellListView
{
protected:
	CShellListView();           // protected constructor used by dynamic creation
	DECLARE_DYNCREATE(CShellListView)

// Attributes
public:
	void SetShelTreeView(CXTPShellTreeView* pShellTreeView);
	void DownLoad();
	void UpLoad();
	void Delete();
	void Flush();


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CShellListView)
	protected:
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	virtual void OnInitialUpdate();
	//}}AFX_VIRTUAL

// Implementation
protected:
	virtual ~CShellListView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif
	// Generated message map functions

protected:
	//{{AFX_MSG(CShellListView)
		// NOTE - the ClassWizard will add and remove member functions here.
	//{{AFX_MSG(m_pShellSqlView)
	afx_msg void OnDropFiles(HDROP hDropInfo);
	afx_msg LRESULT OnDropFilesToListCtrl(WPARAM wParam, LPARAM lParam);
	//}}AFX_MSG
	afx_msg void OnLVNItemChanged(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnLVNEndlabelEdit(NMHDR *pNMHDR, LRESULT *pResult);
	//}}AFX_MSG
	int m_idShellStyle,m_idShellSort;
	afx_msg void OnShellStyle(UINT nID);
	afx_msg void OnUpdateShellStyle(CCmdUI* pCmdUI);
	afx_msg void OnShellSort(UINT nID);
	afx_msg void OnUpdateShellSort(CCmdUI* pCmdUI);
	DECLARE_MESSAGE_MAP()

private:
	UINT         m_iItem;
	UINT         m_iSubItem;
	CXTPShellTreeView* m_pShellTreeView;
};

AFX_INLINE void CShellListView::SetShelTreeView(CXTPShellTreeView* pShelTreeView) {
	m_pShellTreeView = pShelTreeView;
}

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_SHELLLISTVIEW_H__218BC459_82F2_4781_889B_72318030490E__INCLUDED_)
