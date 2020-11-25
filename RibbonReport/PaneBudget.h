// PaneBudget.h: interface for the CPaneBudget class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_PANEBUDGET_H__6C481840_FE83_4798_9524_1A01F1FB13DB__INCLUDED_)
#define AFX_PANEBUDGET_H__6C481840_FE83_4798_9524_1A01F1FB13DB__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "ResourceManager.h"
#include "TreeCtrlAction.h"

class CPaneBudget : public CPaneHolder 
{
public:
	CPaneBudget();
	virtual ~CPaneBudget();

public:
	void InitBudgetActions();

	void RefreshItem();

	CObject* RefreshPropertyGrid(CXTPPropertyGrid* pPropertyGrid);
	BOOL OnPropertyGridValueChanged(CObject* pActiveObject, CXTPPropertyGridItem* pItem);

	CString GetCategoryName(const CString& str);

public:
	CString m_strFileName;
	CXTPImageManager* m_pIcons;


protected:
	//{{AFX_MSG(CPanePartItem)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnSetFocus(CWnd*);
	//}}AFX_MSG

	afx_msg void OnTreeSelChange(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDblclk(NMHDR* pNMHDR, LRESULT* pResult);
	//}}AFX_MSG

	afx_msg void OnRibbonNew();
	afx_msg void OnRibbonOpen();
	afx_msg void OnRibbonSave();
	afx_msg void OnRibbonExpand();
	afx_msg void OnRibbonCollapse();
	afx_msg void OnRibbonInit();
	afx_msg void OnUpdateRibbonExpand(CCmdUI* pCmdUI);
	afx_msg void OnUpdateRibbonCollapse(CCmdUI* pCmdUI);

	DECLARE_MESSAGE_MAP()
	
private:
	CXTPToolBar m_wndToolBar;
	BOOL        m_bTreeExpand;
	CTreeCtrlAction   m_wndTreeCtrl;
};

#endif // !defined(AFX_PANEBUDGET_H__6C481840_FE83_4798_9524_1A01F1FB13DB__INCLUDED_)