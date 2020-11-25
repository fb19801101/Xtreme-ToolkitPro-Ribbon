// PaneBudget.cpp: implementation of the CPaneBudget class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "RibbonReport.h"
#include "MainFrm.h"

#include "PaneBudget.h"
#include "PropertyItemFlags.h"
#include "RibbonReportView.h"
#include "Report/PropertiesView.h"


//////////////////////////////////////////////////////////////////////////
//

CPaneBudget::CPaneBudget()
{
	m_pIcons = new CXTPImageManager();

	m_bTreeExpand = TRUE;
}

CPaneBudget::~CPaneBudget()
{
	delete m_pIcons;
}

BEGIN_MESSAGE_MAP(CPaneBudget, CPaneHolder)
	//{{AFX_MSG_MAP(CPaneBudget)
	ON_WM_CREATE()
	ON_WM_SIZE()
	ON_WM_SETFOCUS()
	//}}AFX_MSG_MAP
	ON_NOTIFY(TVN_SELCHANGED, AFX_IDW_PANE_FIRST, OnTreeSelChange)
	ON_NOTIFY(NM_DBLCLK, AFX_IDW_PANE_FIRST, OnDblclk)

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

int CPaneBudget::OnCreate(LPCREATESTRUCT lpCreateStruct)
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

	m_wndTreeCtrl.EnableMultiSelect();

	InitBudgetActions();

	RefreshItem();
	m_wndTreeCtrl.RefreshResourceManager();

	return 0;
}

void CPaneBudget::OnSize(UINT nType, int cx, int cy)
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

void CPaneBudget::OnSetFocus(CWnd*)
{
	m_wndTreeCtrl.SetFocus();
}

void CPaneBudget::OnTreeSelChange(NMHDR* pNMHDR, LRESULT*)
{  
	NMTREEVIEW* pNMTreeView = (NMTREEVIEW *)pNMHDR;
	if (!pNMTreeView->itemNew.hItem) return;
}

void CPaneBudget::OnDblclk(NMHDR* pNMHDR, LRESULT* pResult) 
{
	HTREEITEM hItem = m_wndTreeCtrl.GetSelectedItem();
	if (!hItem) return;

	CXTPControlAction* pAction = (CXTPControlAction*)m_wndTreeCtrl.GetItemData(hItem);
	if(!pAction) return;
	CString strCaption = pAction->GetCaption();
	CString strCategory = pAction->GetCategory();
	int id = pAction->GetID()/*-ID_PANE_POINTS_ACTION*/;

	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
	if(!pMaainFrame->m_pRibbonReportView) return;

	CString sql;
	CString str;
	int iCount = m_wndTreeCtrl.GetSubItemCount(hItem, xtpParamSubTree);
	sql.Format(_T("where 清单ID between %d and %d"),id,id+iCount-1);
	pMaainFrame->m_pRibbonReportView->SetView(_T("tv_contract"));
	pMaainFrame->m_pRibbonReportView->DataBindRecordset(GetRecordset(_T("tv_contract"),_T(""),sql));

	*pResult = 0;
}

void CPaneBudget::RefreshItem()
{
	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();

	if (pMaainFrame->m_pActiveCommandBars)
		pMaainFrame->m_pActiveCommandBars->SetDragControl(NULL);

	pMaainFrame->m_pActivePane = this;
	pMaainFrame->m_wndPaneProperties.Refresh(this);
}

CString CPaneBudget::GetCategoryName(const CString& str)
{
	if (str == _T("(None)"))
		return _T("");

	return str;
}

CObject* CPaneBudget::RefreshPropertyGrid(CXTPPropertyGrid* pPropertyGrid) 
{
	HTREEITEM hItem = m_wndTreeCtrl.GetSelectedItem();
	if (!hItem) return NULL;

	CXTPControlAction* pAction = (CXTPControlAction*)m_wndTreeCtrl.GetItemData(hItem);
	if (!pAction) return NULL;

	CXTPPropertyGridItem* pCategoryAction = pPropertyGrid->AddCategory(ID_GRID_CATEGORY_ACTION);
	pCategoryAction->AddChildItem(new CXTPPropertyGridItemNumber(ID_GRID_ITEM_ACTION_ID, pAction->GetID()));
	pCategoryAction->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTION_KEY, pAction->GetKey()));
	pCategoryAction->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTION_CAPTION, pAction->GetCaption()));
	pCategoryAction->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTION_DESCRIPTION, pAction->GetDescription()));
	pCategoryAction->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTION_TOOLTIP, pAction->GetTooltip()));
	pCategoryAction->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTION_CATEGORY, pAction->GetCategory()));
	pCategoryAction->Expand();


	LPTVACTIONTAG pTag = (LPTVACTIONTAG)pAction->GetTag();
	if (!pTag) return NULL;
	CXTPPropertyGridItem* pCategoryTag = pPropertyGrid->AddCategory(ID_GRID_CATEGORY_ACTIONTAG);
	CXTPPropertyGridItem* pItemBdt =  pCategoryTag->AddChildItem(new CXTPPropertyGridItemDate(ID_GRID_ITEM_ACTIONTAG_DESIGNBDT, pTag->bdt));
	pItemBdt->AddChildItem(new CXTPPropertyGridItemDate(ID_GRID_ITEM_ACTIONTAG_DONEBDT, pTag->_bdt));
	pItemBdt->Expand();
	CXTPPropertyGridItem* pItemEdt =  pCategoryTag->AddChildItem(new CXTPPropertyGridItemDate(ID_GRID_ITEM_ACTIONTAG_DESIGNEDT, pTag->edt));
	pItemEdt->AddChildItem(new CXTPPropertyGridItemDate(ID_GRID_ITEM_ACTIONTAG_DONEEDT, pTag->_edt));
	pItemEdt->Expand();

	MAPTAGQTY::iterator _iterQty = pTag->qty.begin();
	PAIRTAGQTY _pairQty = *_iterQty;
	CXTPPropertyGridItem* pItemQtyenu =  pCategoryTag->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTIONTAG_ENGINEENU, CXTPString(_pairQty.first)));
	pItemQtyenu->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);
	pItemQtyenu->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTIONTAG_ENGINEMUT, CXTPString(_pairQty.second.mut)));
	pItemQtyenu->AddChildItem(new CXTPPropertyGridItemDouble(ID_GRID_ITEM_ACTIONTAG_ENGINEQTY, _pairQty.second.qty));
	pItemQtyenu->AddChildItem(new CXTPPropertyGridItemDouble(ID_GRID_ITEM_ACTIONTAG_ENGINEDOE, _pairQty.second.qty1));
	pItemQtyenu->AddChildItem(new CXTPPropertyGridItemDouble(ID_GRID_ITEM_ACTIONTAG_ENGINEFIG, _pairQty.second.qty2));
	while(_iterQty != pTag->qty.end())
	{
		_pairQty = *_iterQty++;
		pItemQtyenu->GetConstraints()->AddConstraint(CXTPString(_pairQty.first));
	}
	pItemQtyenu->Expand();

	MAPTAGQTY::iterator _iterLab = pTag->lab.begin();
	PAIRTAGQTY _pairLab = *_iterLab;
	CXTPPropertyGridItem* pItemLabenu =  pCategoryTag->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTIONTAG_LABOURENU, CXTPString(_pairLab.first)));
	pItemLabenu->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);
	pItemLabenu->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTIONTAG_LABOURRNK, CXTPString(_pairLab.second.rnk)));
	pItemLabenu->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTIONTAG_LABOURMUT, CXTPString(_pairLab.second.mut)));
	pItemLabenu->AddChildItem(new CXTPPropertyGridItemNumber(ID_GRID_ITEM_ACTIONTAG_LABOURQTY, _pairLab.second.qty));
	pItemLabenu->Expand();
	while(_iterLab != pTag->lab.end())
	{
		_pairLab = *_iterLab++;
		pItemLabenu->GetConstraints()->AddConstraint(CXTPString(_pairLab.first));
	}

	MAPTAGQTY::iterator _iterDev = pTag->dev.begin();
	PAIRTAGQTY _pairDev = *_iterDev;
	CXTPPropertyGridItem* pItemDevenu =  pCategoryTag->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTIONTAG_DEVICEENU, CXTPString(_pairDev.first)));
	pItemDevenu->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);
	pItemDevenu->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTIONTAG_DEVICERNK, CXTPString(_pairDev.second.rnk)));
	pItemDevenu->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTIONTAG_DEVICEMUT, CXTPString(_pairDev.second.mut)));
	pItemDevenu->AddChildItem(new CXTPPropertyGridItemNumber(ID_GRID_ITEM_ACTIONTAG_DEVICEQTY, _pairDev.second.qty));
	pItemDevenu->Expand();
	while(_iterDev != pTag->dev.end())
	{
		_pairDev = *_iterDev++;
		pItemDevenu->GetConstraints()->AddConstraint(CXTPString(_pairDev.first));
	}

	MAPTAGQTY::iterator _iterMat = pTag->mat.begin();
	PAIRTAGQTY _pairMat = *_iterMat;
	CXTPPropertyGridItem* pItemMatenu =  pCategoryTag->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTIONTAG_MATERENU, CXTPString(_pairMat.first)));
	pItemMatenu->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);
	pItemMatenu->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_ACTIONTAG_MATERMUT, CXTPString(_pairMat.second.mut)));
	pItemMatenu->AddChildItem(new CXTPPropertyGridItemDouble(ID_GRID_ITEM_ACTIONTAG_MATERQTY, _pairMat.second.qty));
	pItemMatenu->Expand();
	while(_iterMat != pTag->mat.end())
	{
		_pairMat = *_iterMat++;
		pItemMatenu->GetConstraints()->AddConstraint(CXTPString(_pairMat.first));
	}

	pCategoryTag->Expand();

	return pAction;
}

BOOL CPaneBudget::OnPropertyGridValueChanged(CObject* pActiveObject, CXTPPropertyGridItem* pItem)
{
	CXTPControlAction* pAction = DYNAMIC_DOWNCAST(CXTPControlAction, pActiveObject);
	if (!pAction) return FALSE;

	HTREEITEM hItem = m_wndTreeCtrl.GetSelectedItem();
	if (m_wndTreeCtrl.GetItemData(hItem) != (DWORD_PTR)pAction) return FALSE;

	switch (pItem->GetID())
	{
	case ID_GRID_ITEM_ACTION_KEY:	
		pAction->SetKey(pItem->GetValue());
		break;
	case ID_GRID_ITEM_ACTION_CAPTION:
		pAction->SetCaption(pItem->GetValue());
		m_wndTreeCtrl.SetItemText(hItem, pAction->GetCaption());	
		break;
	case ID_GRID_ITEM_ACTION_ID:
		m_wndTreeCtrl.ReplaceActionId(pAction, GetNumberValue(pItem));
		break;
	case ID_GRID_ITEM_ACTION_DESCRIPTION:
		pAction->SetDescription(pItem->GetValue());
		break;
	case ID_GRID_ITEM_ACTION_TOOLTIP:
		pAction->SetTooltip(pItem->GetValue());
		break;
	case ID_GRID_ITEM_ACTION_CATEGORY:
		pAction->SetCategory(pItem->GetValue());
		break;
	}

	LPTVACTIONTAG pTag = (LPTVACTIONTAG)pAction->GetTag();
	if (!pTag) return FALSE;

	switch (pItem->GetID())
	{
	case ID_GRID_ITEM_ACTIONTAG_DESIGNBDT:
		pTag->bdt = ((CXTPPropertyGridItemDate*)pItem)->GetDate();
		break;
	case ID_GRID_ITEM_ACTIONTAG_DESIGNEDT:
		pTag->edt = ((CXTPPropertyGridItemDate*)pItem)->GetDate();
		break;
	case ID_GRID_ITEM_ACTIONTAG_DONEBDT:
		pTag->_bdt = ((CXTPPropertyGridItemDate*)pItem)->GetDate();
		break;
	case ID_GRID_ITEM_ACTIONTAG_DONEEDT:
		pTag->_edt = ((CXTPPropertyGridItemDate*)pItem)->GetDate();
		break;
	case ID_GRID_ITEM_ACTIONTAG_ENGINEENU:
		{
			TVTAGQTY& qty = pTag->qty[CXTPString(pItem->GetValue())];
			CXTPPropertyGridItem* _pItem =  pItem->GetChilds()->FindItem(ID_GRID_ITEM_ACTIONTAG_ENGINEQTY);
			((CXTPPropertyGridItemDouble*)_pItem)->SetDouble(qty.qty);
			_pItem =  pItem->GetChilds()->FindItem(ID_GRID_ITEM_ACTIONTAG_ENGINEDOE);
			((CXTPPropertyGridItemDouble*)_pItem)->SetDouble(qty.qty1);
			_pItem =  pItem->GetChilds()->FindItem(ID_GRID_ITEM_ACTIONTAG_ENGINEFIG);
			((CXTPPropertyGridItemDouble*)_pItem)->SetDouble(qty.qty2);
			_pItem =  pItem->GetChilds()->FindItem(ID_GRID_ITEM_ACTIONTAG_ENGINEMUT);
			_pItem->SetValue(qty.mut);
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_ENGINEQTY:
		{
			CXTPPropertyGridItem* _pItem =  pItem->GetParentItem();
			TVTAGQTY& qty = pTag->qty[CXTPString(_pItem->GetValue())];
			qty.qty = ((CXTPPropertyGridItemDouble*)pItem)->GetDouble();
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_ENGINEDOE:
		{
			CXTPPropertyGridItem* _pItem =  pItem->GetParentItem();
			TVTAGQTY& qty = pTag->qty[CXTPString(_pItem->GetValue())];
			qty.qty1 = ((CXTPPropertyGridItemDouble*)pItem)->GetDouble();
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_ENGINEFIG:
		{
			CXTPPropertyGridItem* _pItem =  pItem->GetParentItem();
			TVTAGQTY& qty = pTag->qty[CXTPString(_pItem->GetValue())];
			qty.qty2 = ((CXTPPropertyGridItemDouble*)pItem)->GetDouble();
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_ENGINEMUT:
		{
			CXTPPropertyGridItem* _pItem =  pItem->GetParentItem();
			TVTAGQTY& qty = pTag->qty[CXTPString(_pItem->GetValue())];
			qty.mut = CXTPString(pItem->GetValue());
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_LABOURENU:
		{
			TVTAGQTY& qty = pTag->lab[CXTPString(pItem->GetValue())];
			CXTPPropertyGridItem* _pItem =  pItem->GetChilds()->FindItem(ID_GRID_ITEM_ACTIONTAG_LABOURRNK);
			_pItem->SetValue(qty.rnk);
			_pItem =  pItem->GetChilds()->FindItem(ID_GRID_ITEM_ACTIONTAG_LABOURQTY);
			((CXTPPropertyGridItemNumber*)_pItem)->SetNumber(qty.qty);
			_pItem =  pItem->GetChilds()->FindItem(ID_GRID_ITEM_ACTIONTAG_LABOURMUT);
			_pItem->SetValue(qty.mut);
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_LABOURRNK:
		{
			CXTPPropertyGridItem* _pItem =  pItem->GetParentItem();
			TVTAGQTY& qty = pTag->lab[CXTPString(_pItem->GetValue())];
			qty.rnk = CXTPString(pItem->GetValue());
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_LABOURQTY:
		{
			CXTPPropertyGridItem* _pItem =  pItem->GetParentItem();
			TVTAGQTY& qty = pTag->lab[CXTPString(_pItem->GetValue())];
			qty.qty = ((CXTPPropertyGridItemNumber*)pItem)->GetNumber();
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_LABOURMUT:
		{
			CXTPPropertyGridItem* _pItem =  pItem->GetParentItem();
			TVTAGQTY& qty = pTag->lab[CXTPString(_pItem->GetValue())];
			qty.mut = CXTPString(pItem->GetValue());
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_DEVICEENU:
		{
			TVTAGQTY& qty = pTag->dev[CXTPString(pItem->GetValue())];
			CXTPPropertyGridItem* _pItem =  pItem->GetChilds()->FindItem(ID_GRID_ITEM_ACTIONTAG_DEVICERNK);
			_pItem->SetValue(qty.rnk);
			_pItem =  pItem->GetChilds()->FindItem(ID_GRID_ITEM_ACTIONTAG_DEVICEQTY);
			((CXTPPropertyGridItemNumber*)_pItem)->SetNumber(qty.qty);
			_pItem =  pItem->GetChilds()->FindItem(ID_GRID_ITEM_ACTIONTAG_DEVICEMUT);
			_pItem->SetValue(qty.mut);
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_DEVICERNK:
		{
			CXTPPropertyGridItem* _pItem =  pItem->GetParentItem();
			TVTAGQTY& qty = pTag->dev[CXTPString(_pItem->GetValue())];
			qty.rnk = CXTPString(pItem->GetValue());
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_DEVICEQTY:
		{
			CXTPPropertyGridItem* _pItem =  pItem->GetParentItem();
			TVTAGQTY& qty = pTag->dev[CXTPString(_pItem->GetValue())];
			qty.qty = ((CXTPPropertyGridItemNumber*)pItem)->GetNumber();
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_DEVICEMUT:
		{
			CXTPPropertyGridItem* _pItem =  pItem->GetParentItem();
			TVTAGQTY& qty = pTag->dev[CXTPString(_pItem->GetValue())];
			qty.mut = CXTPString(pItem->GetValue());
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_MATERENU:
		{
			TVTAGQTY& qty = pTag->mat[CXTPString(pItem->GetValue())];
			CXTPPropertyGridItem *_pItem =  pItem->GetChilds()->FindItem(ID_GRID_ITEM_ACTIONTAG_MATERQTY);
			((CXTPPropertyGridItemDouble*)_pItem)->SetDouble(qty.qty);
			_pItem =  pItem->GetChilds()->FindItem(ID_GRID_ITEM_ACTIONTAG_MATERMUT);
			_pItem->SetValue(qty.mut);
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_MATERQTY:
		{
			CXTPPropertyGridItem* _pItem =  pItem->GetParentItem();
			TVTAGQTY& qty = pTag->mat[CXTPString(_pItem->GetValue())];
			qty.qty = ((CXTPPropertyGridItemDouble*)pItem)->GetDouble();
		}
		break;
	case ID_GRID_ITEM_ACTIONTAG_MATERMUT:
		{
			CXTPPropertyGridItem* _pItem =  pItem->GetParentItem();
			TVTAGQTY& qty = pTag->mat[CXTPString(_pItem->GetValue())];
			qty.mut = CXTPString(pItem->GetValue());
		}
		break;
	}

	pAction->SetTag((DWORD_PTR)pTag);
	m_wndTreeCtrl.SetAtPtr(pAction->GetID(), pTag);
	return TRUE;
}

void CPaneBudget::OnRibbonNew()
{
	if (AfxMessageBox(_T("Are you sure you want remove all actions?"), MB_YESNO) != IDYES) return;

	m_wndTreeCtrl.DeleteAllItems();

	HTREEITEM hItemRibbon = m_wndTreeCtrl.GetRootItem();
	if (!hItemRibbon) hItemRibbon = m_wndTreeCtrl.InsertItem(_T("BudgetList"), 0, 0);

	m_strFileName.Empty();
}

void CPaneBudget::InitBudgetActions()
{
	m_wndTreeCtrl.DeleteAllItems();

	HTREEITEM hItemPartItem = m_wndTreeCtrl.GetRootItem();
	if (!hItemPartItem) hItemPartItem = m_wndTreeCtrl.InsertItem(_T("BudgetList"),0,0);
	m_wndTreeCtrl.SetItemColor(hItemPartItem,RGB(255,0,0));

	CString sql;
	sql.Format(_T("select cl_level, cl_node, cl_id, cl_rootid from %s[tb_costlist] \
				  group by cl_level, cl_node, cl_id, cl_rootid \
				  order by cl_id"),g_TablePrix);

	CXTPADORecordset rst(theCon);
	rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);

	XTPTVITEMVECTOR tvis;
	while (!rst.IsEOF())
	{
		XTPTVITEM tvi;
		rst.GetFieldValue(0,tvi.lv);
		CString node;
		rst.GetFieldValue(1,node);
		rst.GetFieldValue(2,tvi.id);
		rst.GetFieldValue(3,tvi.pid);
		tvi.buf = CXTPString(node).c_ptr();
		
		CString strCategory;
		if(tvi.pid == 0)
		{
			strCategory = _T("BudgetList");
			int nState = xtpStateUnChecked;
			tvi.hti = m_wndTreeCtrl.InsertItem(node, 0, 0, nState, hItemPartItem);
			m_wndTreeCtrl.SetItemColor(tvi.hti,RGB(255,0,0));
		}
		else
		{
			HTREEITEM hRoot = XTPTVITEM::FindTreeNode(tvis, tvi.pid).hti;
			strCategory = node;
			int nState = xtpStateUnChecked;
			tvi.hti = m_wndTreeCtrl.InsertItem(node, 0, 0, nState, hRoot);
			m_wndTreeCtrl.SetItemColor(tvi.hti,RGB(0,0,255));
		}

		tvis.push_back(tvi);

		CString strKeyAction = GetDefineID(tvi.id);
		CString strCaption = node;
		CXTPControlAction* pAction = m_wndTreeCtrl.AddAction(tvi.hti, strCaption, /*ID_PANE_POINTS_ACTION+*/tvi.id, tvi.pid, tvi.lv, strKeyAction, strCategory, 0, strCaption);
		LPTVACTIONTAG pTag = new TVACTIONTAG;
		pTag->id = tvi.id;
		pTag->pid = tvi.pid;
		pTag->lv = tvi.lv;
		TVTAGQTY qty;
		qty.qty = 50.4;
		qty.mut = "m3";
		pTag->qty.insert(PAIRTAGQTY("混凝土",qty));
		qty.qty = 150.2;
		pTag->qty.insert(PAIRTAGQTY("片石砼",qty));
		qty.qty = 2330.1;
		pTag->qty.insert(PAIRTAGQTY("浆砌石",qty));
		qty.qty = 130.6;
		qty.mut = "t";
		pTag->qty.insert(PAIRTAGQTY("钢  筋",qty));
		qty.qty = 30.8;
		pTag->qty.insert(PAIRTAGQTY("钢  板",qty));
		qty.qty = 2220.1;
		qty.mut = "m3";
		pTag->qty.insert(PAIRTAGQTY("挖土方",qty));
		qty.qty = 1130.2;
		pTag->qty.insert(PAIRTAGQTY("挖石方",qty));
		qty = TVTAGQTY("一队","人",30);
		pTag->lab.insert(PAIRTAGQTY("钢筋班",qty));
		qty = TVTAGQTY("一队","人",16);
		pTag->lab.insert(PAIRTAGQTY("砼  班",qty));
		qty = TVTAGQTY("一队","人",20);
		pTag->lab.insert(PAIRTAGQTY("模板班",qty));
		qty = TVTAGQTY("五队","台",3);
		pTag->dev.insert(PAIRTAGQTY("挖掘机",qty));
		qty = TVTAGQTY("五队","台",5);
		pTag->dev.insert(PAIRTAGQTY("装载机",qty));
		qty = TVTAGQTY("五队","辆",10);
		pTag->dev.insert(PAIRTAGQTY("自卸车",qty));
		qty = TVTAGQTY("一队","台",2);
		pTag->dev.insert(PAIRTAGQTY("汽车吊",qty));
		qty.qty = 1200.4;
		qty.mut = "t";
		pTag->mat.insert(PAIRTAGQTY("墩柱模板",qty));
		qty.qty = 100.1;
		pTag->mat.insert(PAIRTAGQTY("承台模板",qty));
		qty.qty = 200.23;
		pTag->mat.insert(PAIRTAGQTY("顶帽模板",qty));
		qty.qty = 510.55;
		pTag->mat.insert(PAIRTAGQTY("底座模板",qty));
		qty.qty = 300;
		qty.mut = "套";
		pTag->mat.insert(PAIRTAGQTY("轨道支架",qty));
		pAction->SetTag((DWORD_PTR)pTag);
		m_wndTreeCtrl.SetAction(tvi.hti, pAction);
		m_wndTreeCtrl.SetAtPtr(tvi.id, pTag);

		rst.MoveNext();
	}
	rst.Close();

	XTPTVITEMVECTOR::iterator _iter = tvis.begin();
	while(_iter != tvis.end())
	{
		XTPTVITEM tvi = *_iter++;
		if(!m_wndTreeCtrl.ItemHasChildren(tvi.hti))
		{
			m_wndTreeCtrl.SetItemImage(tvi.hti,2,3);
			m_wndTreeCtrl.SetItemColor(tvi.hti,RGB(0,0,0));
			m_wndTreeCtrl.SetItemState(tvi.hti,0);
		}
	}

	m_wndTreeCtrl.Expand(hItemPartItem, TVE_EXPAND);
}

void CPaneBudget::OnRibbonOpen()
{
	m_wndTreeCtrl.OpenTreeFile(xtpFileFormatBinary);
}

void CPaneBudget::OnRibbonSave()
{
	m_wndTreeCtrl.SaveTreeFile(xtpFileFormatBinary);
}

void CPaneBudget::OnRibbonExpand()
{
	m_wndTreeCtrl.ExpandItems();
	m_bTreeExpand = TRUE;
}

void CPaneBudget::OnRibbonCollapse()
{
	m_wndTreeCtrl.CollapseItems();
	m_bTreeExpand = FALSE;
}

void CPaneBudget::OnRibbonInit()
{
	BOOL ret = msgAsk(_T("是否初始化计量清单树形结构？"));
	if(ret)
	{
		InitBudgetActions();
		msgInf(_T("初始化计量清单树形结构成功！"));
	}
}

void CPaneBudget::OnUpdateRibbonExpand(CCmdUI* pCmdUI)
{
	CXTPControl* pControl = CXTPControl::FromUI(pCmdUI);

	pCmdUI->Enable(TRUE);

	if (pControl) pControl->SetVisible(!m_bTreeExpand);
}

void CPaneBudget::OnUpdateRibbonCollapse(CCmdUI* pCmdUI)
{
	CXTPControl* pControl = CXTPControl::FromUI(pCmdUI);

	pCmdUI->Enable(TRUE);

	if (pControl) pControl->SetVisible(m_bTreeExpand);
}