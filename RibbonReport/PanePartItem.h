// PanePartItem.h: interface for the CPanePartItem class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_PANELPARTITEM_H__6C481840_FE83_4798_9524_1A01F1FB13DB__INCLUDED_)
#define AFX_PANELPARTITEM_H__6C481840_FE83_4798_9524_1A01F1FB13DB__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class CPanePartItem : public CPaneHolder 
{
public:
	CPanePartItem();
	virtual ~CPanePartItem();

public:
	void InitPartItemActions();
	void InitPartItemFromJson();

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
	afx_msg void OnClick(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDblclk(NMHDR* pNMHDR, LRESULT* pResult);
	//}}AFX_MSG

	afx_msg void OnRibbonNew();
	afx_msg void OnRibbonOpen();
	afx_msg void OnRibbonSave();
	afx_msg void OnRibbonExpand();
	afx_msg void OnRibbonCollapse();
	afx_msg void OnRibbonInit();
	afx_msg void OnRibbonDeleteTable();
	afx_msg void OnRibbonLockTable();
	afx_msg void OnUpdateRibbonExpand(CCmdUI* pCmdUI);
	afx_msg void OnUpdateRibbonCollapse(CCmdUI* pCmdUI);

	DECLARE_MESSAGE_MAP()
	
private:
	CXTPToolBar m_wndToolBar;
	BOOL        m_bTreeExpand;
	CTreeCtrlAction   m_wndTreeCtrl;
};

#endif // !defined(AFX_PANELPARTITEM_H__6C481840_FE83_4798_9524_1A01F1FB13DB__INCLUDED_)