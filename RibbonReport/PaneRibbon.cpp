// PaneRibbon.cpp: implementation of the CPaneRibbon class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "RibbonReport.h"
#include "MainFrm.h"

#include "PaneRibbon.h"
#include "PropertyItemFlags.h"


//////////////////////////////////////////////////////////////////////////
//

CPaneRibbon::CPaneRibbon()
{
	m_pActions = new CActions();

	m_pIcons = new CXTPImageManager();

	m_pDragAction = NULL;
	m_bTreeExpand = TRUE;

	m_pResourceManager = new CResourceManager;
}

CPaneRibbon::~CPaneRibbon()
{
	m_pActions->InternalRelease();

	delete m_pIcons;

	delete m_pResourceManager;
}

BEGIN_MESSAGE_MAP(CPaneRibbon, CPaneHolder)
	//{{AFX_MSG_MAP(CPaneRibbon)
	ON_WM_CREATE()
	ON_WM_SIZE()
	ON_WM_DESTROY()
	ON_WM_SETFOCUS()
	//}}AFX_MSG_MAP
	ON_NOTIFY(TVN_SELCHANGED, AFX_IDW_PANE_FIRST, OnTreeSelChange)

	ON_COMMAND(ID_PANE_RIBBON_NEW, OnRibbonNew)
	ON_COMMAND(ID_PANE_RIBBON_OPEN, OnRibbonOpen)
	ON_COMMAND(ID_PANE_RIBBON_SAVE, OnRibbonSave)
	ON_COMMAND(ID_PANE_RIBBON_EXPAND, OnRibbonExpand)
	ON_COMMAND(ID_PANE_RIBBON_COLLAPSE, OnRibbonCollapse)
	ON_COMMAND(ID_PANE_RIBBON_INIT, OnRibbonInit)
	ON_UPDATE_COMMAND_UI(ID_PANE_RIBBON_EXPAND, OnUpdateRibbonExpand)
	ON_UPDATE_COMMAND_UI(ID_PANE_RIBBON_COLLAPSE, OnUpdateRibbonCollapse)
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// CPaneProperties message handlers

int CPaneRibbon::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (CPaneHolder::OnCreate(lpCreateStruct) == -1)
		return -1;

	if(!m_wndToolBar.CreateToolBar(WS_TABSTOP|WS_VISIBLE|WS_CHILD|CBRS_TOOLTIPS, this))
		return -1;

	if(!m_wndToolBar.LoadToolBar(IDR_PANE_RIBBON))
		return -1;

	if (!m_wndTreeCtrl.Create(WS_CLIPCHILDREN|WS_CLIPSIBLINGS|WS_VISIBLE|TVS_HASLINES|
		TVS_LINESATROOT|TVS_HASBUTTONS|TVS_SHOWSELALWAYS|TVS_EDITLABELS, CRect(0, 0, 0, 0), this, AFX_IDW_PANE_FIRST))
	{
		TRACE0("Failed to create view window\n");
		return -1;
	}

	LoadRibbonActions();

	RefreshItem();
	RefreshResourceManager();

	m_pIcons->RemoveAll();
	CXTPCommandBars* pCommandBars = ((CMainFrame*)AfxGetMainWnd())->GetCommandBars();
	m_pIcons->AddIcons(pCommandBars->GetImageManager());

	return 0;
}

void CPaneRibbon::OnDestroy()
{
	if (!m_strFileName.IsEmpty())
		SaveToFile(m_strFileName);

	CPaneHolder::OnDestroy();
}

void CPaneRibbon::OnSize(UINT nType, int cx, int cy)
{
	CPaneHolder::OnSize(nType, cx, cy);

	CSize sz(0);
	if (m_wndToolBar.GetSafeHwnd())
	{
		sz = m_wndToolBar.CalcDockingLayout(cx, /*LM_HIDEWRAP|*/ LM_HORZDOCK|LM_HORZ | LM_COMMIT);

		m_wndToolBar.MoveWindow(0, 0, cx, sz.cy);
		m_wndToolBar.Invalidate(FALSE);
	}

	if (m_wndTreeCtrl.GetSafeHwnd())
	{
		m_wndTreeCtrl.MoveWindow(0, sz.cy, cx, cy - sz.cy);
	}
}

void CPaneRibbon::OnSetFocus(CWnd*)
{
	m_wndTreeCtrl.SetFocus();
}

void CPaneRibbon::OnTreeSelChange(NMHDR* pNMHDR, LRESULT* pResult)
{  
	NMTREEVIEW* pNMTreeView = (NMTREEVIEW *)pNMHDR;
	if (pNMTreeView->itemNew.hItem) return;

	if (m_wndTreeCtrl.GetItemType(pNMTreeView->itemNew.hItem) == xtpTypeItem)
	{
		CXTPControlAction* pAction = (CXTPControlAction*)m_wndTreeCtrl.GetItemData(pNMTreeView->itemNew.hItem);
		
		if (pAction)
		{
			//msgInf(GetDefineID(pAction->GetID())+_T("  ")+pAction->GetCaption());
			::SendMessage(AfxGetMainWnd()->m_hWnd, WM_COMMAND, pAction->GetID(),0);
		}
	}
}

void CPaneRibbon::RefreshItem()
{
	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();

	if (pMaainFrame->m_pActiveCommandBars)
		pMaainFrame->m_pActiveCommandBars->SetDragControl(NULL);

	pMaainFrame->m_pActivePane = this;
	pMaainFrame->m_wndPaneProperties.Refresh(this);
}

void CPaneRibbon::RefreshResourceManager()
{
	m_pResourceManager->FreeAll();

	for (int i = 0; i < m_pActions->GetCount(); i++)
	{
		m_pResourceManager->Set(m_pActions->GetAt(i)->GetID(), m_pActions->GetAt(i)->GetKey());
	}
}

CString CPaneRibbon::GetCategoryName(const CString& str)
{
	if (str == _T("(None)"))
		return _T("");

	return str;
}

CObject* CPaneRibbon::RefreshPropertyGrid(CXTPPropertyGrid* pPropertyGrid) 
{
	HTREEITEM hItem = m_wndTreeCtrl.GetSelectedItem();
	if (!hItem)  return NULL;

	if (m_wndTreeCtrl.GetItemType(hItem) != xtpTypeItem) return NULL;

	CXTPControlAction* pAction = (CXTPControlAction*)m_wndTreeCtrl.GetItemData(hItem);
	if (!pAction) return NULL;

	CXTPPropertyGridItem* pCategory = pPropertyGrid->AddCategory(ID_GRID_CATEGORY_ACTION);
	pCategory->AddChildItem(new CXTPPropertyGridItemNumber(ID_GRID_ITEM_ACTION_ID, pAction->GetID()));
	pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTION_KEY, pAction->GetKey()));
	pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTION_CAPTION, pAction->GetCaption()));
	pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTION_DESCRIPTION, pAction->GetDescription()));
	pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTION_TOOLTIP, pAction->GetTooltip()));
	CXTPPropertyGridItem* pItemControlCategory = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTION_CATEGORY, pAction->GetCategory()));
	pItemControlCategory->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

	HTREEITEM hItemRoot = m_wndTreeCtrl.GetRootItem();
	HTREEITEM hItemChild = m_wndTreeCtrl.GetChildItem(hItemRoot);
	while (hItemChild)
	{
		CString strItem = m_wndTreeCtrl.GetItemText(hItemChild);

		if (!GetCategoryName(strItem).IsEmpty())
			pItemControlCategory->GetConstraints()->AddConstraint(strItem);

		hItemChild = m_wndTreeCtrl.GetNextSiblingItem(hItemChild);
	}

	pCategory->Expand();

	return pAction;
}

BOOL CPaneRibbon::OnPropertyGridValueChanged(CObject* pActiveObject, CXTPPropertyGridItem* pItem)
{
	CXTPControlAction* pAction = DYNAMIC_DOWNCAST(CXTPControlAction, pActiveObject);
	if (!pAction) return FALSE;

	HTREEITEM hItem = m_wndTreeCtrl.GetSelectedItem();
	if (m_wndTreeCtrl.GetItemData(hItem) != (DWORD_PTR)pAction) return FALSE;

	switch (pItem->GetID())
	{
	case ID_GRID_ITEM_ACTION_KEY:	
		pAction->SetKey(pItem->GetValue());
		return TRUE;

	case ID_GRID_ITEM_ACTION_CAPTION:
		pAction->SetCaption(pItem->GetValue());
		m_wndTreeCtrl.SetItemText(hItem, pAction->GetCaption());	
		return TRUE;

	case ID_GRID_ITEM_ACTION_ID:
		m_pActions->ReplaceActionId(pAction, GetNumberValue(pItem));
		return TRUE;

	case ID_GRID_ITEM_ACTION_DESCRIPTION:
		pAction->SetDescription(pItem->GetValue());
		return TRUE;

	case ID_GRID_ITEM_ACTION_TOOLTIP:
		pAction->SetTooltip(pItem->GetValue());
		return TRUE;

	case ID_GRID_ITEM_ACTION_CATEGORY:
		{
			pAction->SetCategory(pItem->GetValue());

			HTREEITEM hItemRoot = m_wndTreeCtrl.GetRootItem();
			HTREEITEM hItemChild = m_wndTreeCtrl.GetChildItem(hItemRoot);

			CString strCategory = pAction->GetCategory();
			if (strCategory.IsEmpty()) 
				strCategory = _T("(None)");

			while (hItemChild)
			{
				CString strItem = m_wndTreeCtrl.GetItemText(hItemChild);

				if (GetCategoryName(strItem) == strCategory)
					break;
		
				hItemChild = m_wndTreeCtrl.GetNextSiblingItem(hItemChild);
			}

			if (!hItemChild)
				hItemChild = m_wndTreeCtrl.InsertItem(strCategory, 0, 0, hItemRoot);

			m_wndTreeCtrl.DeleteItem(hItem);

			HTREEITEM hNewItem = m_wndTreeCtrl.InsertItem(pAction->GetCaption(), 0, 0, hItemChild);
			m_wndTreeCtrl.SetItemData(hNewItem, (DWORD_PTR)pAction);

			m_wndTreeCtrl.SelectItem(hNewItem);			

		}
		return TRUE;

	}

	return FALSE;
}

void CPaneRibbon::OnRibbonNew()
{
	if (AfxMessageBox(_T("Are you sure you want remove all actions?"), MB_YESNO) != IDYES)
		return;

	m_wndTreeCtrl.DeleteAllItems();
	m_pActions->RemoveAll();

	HTREEITEM hItemRibbon = m_wndTreeCtrl.GetRootItem();
	if (!hItemRibbon)
		hItemRibbon = m_wndTreeCtrl.InsertItem(_T("Ribbon"), 0, 0);

	m_strFileName.Empty();
}

void CPaneRibbon::LoadRibbonActions()
{
	CXTPRibbonBar* pRibbonBar = ((CMainFrame*)AfxGetMainWnd())->m_pRibbonBar;
	if (!pRibbonBar) return;

	m_pActions->RemoveAll();

	HTREEITEM hItemRibbon = m_wndTreeCtrl.GetRootItem();
	if (!hItemRibbon)
		hItemRibbon = m_wndTreeCtrl.InsertItem(_T("Ribbon"), 0, 0);

	for(int i=0; i<pRibbonBar->GetTabCount();i++)
	{
		CXTPRibbonTab* pTab = pRibbonBar->GetTab(i);
		if(!pTab) break;
		CString strKeyAction = GetDefineID(pTab->GetID());
		CXTPControlAction* pAction = m_pActions->AddAction(pTab->GetID(), strKeyAction, _T("Ribbon"), pTab->GetID());
		HTREEITEM hItemTab = m_wndTreeCtrl.InsertItem(pTab->GetCaption(), 0, 0, hItemRibbon);
		m_wndTreeCtrl.SetItemData(hItemTab, (DWORD_PTR)pAction);

		CXTPRibbonGroups* pGroups = pTab->GetGroups();
		if(!pGroups) break;
		for(int j=0; j<pGroups->GetCount(); j++)
		{
			CXTPRibbonGroup* pGroup = pGroups->GetAt(j);
			if(!pGroup) break;
			CString strKeyAction = GetDefineID(pGroup->GetID());
			CXTPControlAction* pAction = m_pActions->AddAction(pGroup->GetID(), strKeyAction, pTab->GetCaption(), pGroup->GetID());
			HTREEITEM hItemGroup = m_wndTreeCtrl.InsertItem(pGroup->GetCaption(), 0, 0, hItemTab);
			m_wndTreeCtrl.SetItemData(hItemGroup, (DWORD_PTR)pAction);

			for(int k=0; k<pGroup->GetCount(); k++)
			{
				CXTPControl* pControl = pGroup->GetAt(k);
				if(!pControl) break;
				CString strKeyAction = GetDefineID(pControl->GetID());
				CXTPControlAction* pAction = m_pActions->AddAction(pControl->GetID(), strKeyAction, pGroup->GetCaption(), pControl->GetID());
				HTREEITEM hItemControl = m_wndTreeCtrl.InsertItem(pControl->GetCaption(), 2, 3, hItemGroup);
				m_wndTreeCtrl.SetItemData(hItemControl, (DWORD_PTR)pAction);
			}
			m_wndTreeCtrl.Expand(hItemGroup, TVE_EXPAND);
		}
		m_wndTreeCtrl.Expand(hItemTab, TVE_EXPAND);
	}

	m_wndTreeCtrl.Expand(hItemRibbon, TVE_EXPAND);
}

void CPaneRibbon::DoPropExchange(CXTPPropExchange* pPX)
{
	if (pPX->IsLoading())
	{
		pPX->m_dwData = (DWORD_PTR)m_pActions;
		m_wndTreeCtrl.SetRedraw(FALSE);
		m_wndTreeCtrl.DeleteAllItems();
		m_pActions->RemoveAll();

		HTREEITEM hItemRibbon = m_wndTreeCtrl.GetRootItem();
		if (!hItemRibbon)
			hItemRibbon = m_wndTreeCtrl.InsertItem(_T("Ribbon"), 0, 0);

		CXTPPropExchangeEnumeratorPtr pEnumeratorTab(pPX->GetEnumerator(_T("Tab")));
		POSITION posEnumTab = pEnumeratorTab->GetPosition(m_pActions->GetCount());

		for(int i=0; posEnumTab != NULL; i++)
		{
			CXTPPropExchangeSection secTab(pEnumeratorTab->GetNext(posEnumTab));
			CString strTab;
			PX_String(&secTab, _T("Group"), strTab);
			int nActionId;
			PX_Int(&secTab, _T("ActionId"), nActionId);
			int nIconId;
			PX_Int(&secTab, _T("IconId"), nIconId);
			CString strActionCaption;
			PX_String(&secTab, _T("Caption"), strActionCaption);
			CString strActionDescription;
			PX_String(&secTab, _T("DescriptionText"), strActionDescription);
			CString strActionTooltip;
			PX_String(&secTab, _T("TooltipText"), strActionTooltip);
			CString strActionCategory;
			PX_String(&secTab, _T("Category"), strActionCategory);
			CString strActionKey;
			PX_String(&secTab, _T("Key"), strActionKey);
			CXTPControlAction* pAction = m_pActions->AddAction(strActionCaption, nActionId, strActionKey, strActionCategory, nIconId, strActionDescription, strActionTooltip);

			HTREEITEM hItemTab = m_wndTreeCtrl.InsertItem(strTab, 0, 0, hItemRibbon);
			m_wndTreeCtrl.SetItemData(hItemTab, (DWORD_PTR)pAction);

			CXTPPropExchangeEnumeratorPtr pEnumeratorGroup(secTab->GetEnumerator(_T("Group")));
			POSITION posEnumGroup = pEnumeratorGroup->GetPosition(m_pActions->GetCount());

			for(int j=0; posEnumGroup != NULL; j++)
			{
				CXTPPropExchangeSection secGroup(pEnumeratorGroup->GetNext(posEnumGroup));
				CString strGroup;
				PX_String(&secGroup, _T("Group"), strGroup);
				int nActionId;
				PX_Int(&secGroup, _T("ActionId"), nActionId);
				int nIconId;
				PX_Int(&secGroup, _T("IconId"), nIconId);
				CString strActionCaption;
				PX_String(&secGroup, _T("Caption"), strActionCaption);
				CString strActionDescription;
				PX_String(&secGroup, _T("DescriptionText"), strActionDescription);
				CString strActionTooltip;
				PX_String(&secGroup, _T("TooltipText"), strActionTooltip);
				CString strActionCategory;
				PX_String(&secGroup, _T("Category"), strActionCategory);
				CString strActionKey;
				PX_String(&secGroup, _T("Key"), strActionKey);
				CXTPControlAction* pAction = m_pActions->AddAction(strActionCaption, nActionId, strActionKey, strActionCategory, nIconId, strActionDescription, strActionTooltip);

				HTREEITEM hItemGroup = m_wndTreeCtrl.InsertItem(strGroup, 0, 0, hItemTab);
				m_wndTreeCtrl.SetItemData(hItemGroup, (DWORD_PTR)pAction);

				CXTPPropExchangeEnumeratorPtr pEnumeratorControl(secGroup->GetEnumerator(_T("Control")));
				POSITION posEnumControl = pEnumeratorControl->GetPosition(m_pActions->GetCount());

				for(int k=0; posEnumControl != NULL; k++)
				{
					CXTPPropExchangeSection secControl(pEnumeratorControl->GetNext(posEnumControl));
					CString strControl;
					PX_String(&secControl, _T("Control"), strControl);
					int nActionId;
					PX_Int(&secControl, _T("ActionId"), nActionId);
					int nIconId;
					PX_Int(&secControl, _T("IconId"), nIconId);
					CString strActionCaption;
					PX_String(&secControl, _T("Caption"), strActionCaption);
					CString strActionDescription;
					PX_String(&secControl, _T("DescriptionText"), strActionDescription);
					CString strActionTooltip;
					PX_String(&secControl, _T("TooltipText"), strActionTooltip);
					CString strActionCategory;
					PX_String(&secControl, _T("Category"), strActionCategory);
					CString strActionKey;
					PX_String(&secControl, _T("Key"), strActionKey);
					CXTPControlAction* pAction = m_pActions->AddAction(strActionCaption, nActionId, strActionKey, strActionCategory, nIconId, strActionDescription, strActionTooltip);

					HTREEITEM hItemControl = m_wndTreeCtrl.InsertItem(strControl, 2, 3, hItemGroup);
					m_wndTreeCtrl.SetItemData(hItemControl, (DWORD_PTR)pAction);
				}

				m_wndTreeCtrl.Expand(hItemGroup, TVE_EXPAND);
			}

			m_wndTreeCtrl.Expand(hItemTab, TVE_EXPAND);
		}

		m_wndTreeCtrl.Expand(hItemRibbon, TVE_EXPAND);

		m_wndTreeCtrl.SetRedraw(TRUE);
	}
	else
	{
		HTREEITEM hItemRibbon = m_wndTreeCtrl.GetRootItem();
		HTREEITEM hItemTab = m_wndTreeCtrl.GetChildItem(hItemRibbon);

		CXTPPropExchangeEnumeratorPtr pEnumeratorTab(pPX->GetEnumerator(_T("Tab")));
		int nItemCount = 0;
		m_wndTreeCtrl.GetChildCount(nItemCount, hItemRibbon);
		POSITION posEnumTab = pEnumeratorTab->GetPosition(nItemCount);

		for(int i=0; posEnumTab && hItemTab; i++)
		{
			CXTPPropExchangeSection secTab(pEnumeratorTab->GetNext(posEnumTab));
			CString strTab = GetCategoryName(m_wndTreeCtrl.GetItemText(hItemTab));
			PX_String(&secTab, _T("Tab"), strTab);
			CXTPControlAction* pAction = (CXTPControlAction*)m_wndTreeCtrl.GetItemData(hItemTab);
			int nActionId = pAction->GetID();
			PX_Int(&secTab, _T("ActionId"), nActionId);
			PX_Object(&secTab, pAction, RUNTIME_CLASS(CXTPControlAction));
			int nActionIndex = m_pActions->GetIndex(pAction);
			PX_Int(&secTab, _T("ActionIndex"), nActionIndex);

			HTREEITEM hItemGroup = m_wndTreeCtrl.GetChildItem(hItemTab);

			CXTPPropExchangeEnumeratorPtr pEnumeratorGroup(secTab->GetEnumerator(_T("Group")));
			int nItemCount = 0;
			m_wndTreeCtrl.GetChildCount(nItemCount,hItemTab);
			POSITION posEnumGroup = pEnumeratorGroup->GetPosition(nItemCount);

			for(int j=0; posEnumGroup && hItemGroup; j++)
			{
				CXTPPropExchangeSection secGroup(pEnumeratorGroup->GetNext(posEnumGroup));
				CString strGroup = GetCategoryName(m_wndTreeCtrl.GetItemText(hItemGroup));
				PX_String(&secGroup, _T("Group"), strGroup);
				CXTPControlAction* pAction = (CXTPControlAction*)m_wndTreeCtrl.GetItemData(hItemGroup);
				int nActionId = pAction->GetID();
				PX_Int(&secGroup, _T("ActionId"), nActionId);
				PX_Object(&secGroup, pAction, RUNTIME_CLASS(CXTPControlAction));
				int nActionIndex = m_pActions->GetIndex(pAction);
				PX_Int(&secGroup, _T("ActionIndex"), nActionIndex);

				HTREEITEM hItemControl = m_wndTreeCtrl.GetChildItem(hItemGroup);

				CXTPPropExchangeEnumeratorPtr pEnumeratorControl(secGroup->GetEnumerator(_T("Control")));
				int nItemCount = 0;
				m_wndTreeCtrl.GetChildCount(nItemCount,hItemGroup);
				POSITION posEnumControl = pEnumeratorControl->GetPosition(nItemCount);

				for(int k=0; posEnumControl && hItemControl; k++)
				{
					CXTPPropExchangeSection secControl(pEnumeratorControl->GetNext(posEnumControl));
					CString strControl = GetCategoryName(m_wndTreeCtrl.GetItemText(hItemControl));
					PX_String(&secControl, _T("Control"), strControl);
					CXTPControlAction* pAction = (CXTPControlAction*)m_wndTreeCtrl.GetItemData(hItemControl);
					int nActionId = pAction->GetID();
					PX_Int(&secControl, _T("ActionId"), nActionId);
					PX_Object(&secControl, pAction, RUNTIME_CLASS(CXTPControlAction));
					int nActionIndex = m_pActions->GetIndex(pAction);
					PX_Int(&secControl, _T("ActionIndex"), nActionIndex);

					hItemControl = m_wndTreeCtrl.GetNextSiblingItem(hItemControl);
				}

				hItemGroup = m_wndTreeCtrl.GetNextSiblingItem(hItemGroup);
			}

			hItemTab = m_wndTreeCtrl.GetNextSiblingItem(hItemTab);
		}
	}
}

BOOL CPaneRibbon::LoadFromFile(CString strFileName)
{
	CXTPPropExchangeXMLNode px(TRUE, NULL, _T("RibbonActions"));
	if (!px.LoadFromFile(strFileName))
		return FALSE;

	CXTPPropExchangeSection secRibbon(px.GetSection(_T("Ribbon")));
	DoPropExchange(&secRibbon);

	m_strFileName = strFileName;

	return TRUE;

}

void CPaneRibbon::OnRibbonOpen()
{
	CString strFilter = _T("XML Document (*.xml)|*.xml|All files (*.*)|*.*||");

	CFileDialog fd(TRUE, _T("xml"), NULL, OFN_FILEMUSTEXIST| OFN_HIDEREADONLY, strFilter);
	if (fd.DoModal() != IDOK)
		return;

	if (!LoadFromFile(fd.GetPathName()))
		return;

	AfxGetApp()->WriteProfileString(_T("ActionsLibrary"), _T("CurrentFile"), fd.GetPathName());
	msgInf(_T("控件树配置导入成功！"));
}

void CPaneRibbon::SaveToFile(CString strFileName)
{
	CXTPPropExchangeXMLNode px(FALSE, 0, _T("RibbonActions"));

	CXTPPropExchangeSection secRibbon(px.GetSection(_T("Ribbon")));
	DoPropExchange(&secRibbon);

	px.SaveToFile(strFileName);

	m_strFileName = strFileName;
}

void CPaneRibbon::OnRibbonSave()
{
	CString strFilter = _T("XML Document (*.xml)|*.xml|All files (*.*)|*.*||");

	CFileDialog fd(FALSE, _T("xml"), NULL, OFN_HIDEREADONLY|OFN_OVERWRITEPROMPT, strFilter);
	if (fd.DoModal() != IDOK)
		return;

	SaveToFile(fd.GetPathName());

	AfxGetApp()->WriteProfileString(_T("ActionsLibrary"), _T("CurrentFile"), fd.GetPathName());

	msgInf(_T("控件树配置保存成功！"));
}

void CPaneRibbon::OnRibbonExpand()
{
	m_wndTreeCtrl.ExpandItems();
	m_bTreeExpand = TRUE;
}

void CPaneRibbon::OnRibbonCollapse()
{
	m_wndTreeCtrl.CollapseItems();
	m_bTreeExpand = FALSE;
}

void CPaneRibbon::OnRibbonInit()
{
	bool ret = msgAsk(_T("是否初始化功能列表？"));
	if(ret)
	{
		LoadRibbonActions();
		msgInf(_T("初始化功能列表成功！"));
	}
}

void CPaneRibbon::OnUpdateRibbonExpand(CCmdUI* pCmdUI)
{
	CXTPControl* pControl = CXTPControl::FromUI(pCmdUI);

	pCmdUI->Enable(TRUE);

	if (pControl) pControl->SetVisible(!m_bTreeExpand);
}

void CPaneRibbon::OnUpdateRibbonCollapse(CCmdUI* pCmdUI)
{
	CXTPControl* pControl = CXTPControl::FromUI(pCmdUI);

	pCmdUI->Enable(TRUE);

	if (pControl) pControl->SetVisible(m_bTreeExpand);
}
