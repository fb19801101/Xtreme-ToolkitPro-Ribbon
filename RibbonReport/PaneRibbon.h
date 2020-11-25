// PaneRibbon.h: interface for the CPaneRibbon class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_PANELRIBBON_H__6C481840_FE83_4798_9524_1A01F1FB13DB__INCLUDED_)
#define AFX_PANELRIBBON_H__6C481840_FE83_4798_9524_1A01F1FB13DB__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "ResourceManager.h"
#include "TreeCtrlAction.h"

class CPaneRibbon : public CPaneHolder 
{
public:
	CPaneRibbon();
	virtual ~CPaneRibbon();

public:
	BOOL LoadFromFile(CString strFileName);
	void SaveToFile(CString strFileName);

	void LoadRibbonActions();
	void DoPropExchange(CXTPPropExchange* pPX);

	void RefreshItem();
	void RefreshResourceManager();

	CObject* RefreshPropertyGrid(CXTPPropertyGrid* pPropertyGrid);
	BOOL OnPropertyGridValueChanged(CObject* pActiveObject, CXTPPropertyGridItem* pItem);
	CString GetCategoryName(const CString& str);


public:
	CString m_strFileName;
	CResourceManager* m_pResourceManager;

	CXTPControlAction* m_pDragAction;
	CXTPImageManager* m_pIcons;


protected:
	//{{AFX_MSG(CPaneRibbon)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg void OnDestroy();
	afx_msg void OnSetFocus(CWnd*);
	//}}AFX_MSG

	afx_msg void OnTreeSelChange(NMHDR*, LRESULT*);

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
	CActions* m_pActions;
	CXTPToolBar m_wndToolBar;
	BOOL        m_bTreeExpand;
	CTreeCtrlAction m_wndTreeCtrl;
	typedef CMapStringToOb CMapActions;
	CMapActions m_mapActions;
};

#endif // !defined(AFX_PANELRIBBON_H__6C481840_FE83_4798_9524_1A01F1FB13DB__INCLUDED_)
