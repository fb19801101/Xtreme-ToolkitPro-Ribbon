// PanePartItem.cpp: implementation of the CPanePartItem class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "RibbonReport.h"
#include "MainFrm.h"

#include "ResourceManager.h"
#include "TreeCtrlAction.h"
#include <fstream>

#include "PanePartItem.h"
#include "PropertyItemFlags.h"
#include "RibbonReportView.h"
#include "Report/PropertiesView.h"


//////////////////////////////////////////////////////////////////////////
//

CPanePartItem::CPanePartItem()
{
	m_pIcons = new CXTPImageManager();

	m_bTreeExpand = TRUE;
}

CPanePartItem::~CPanePartItem()
{
	delete m_pIcons;
}

BEGIN_MESSAGE_MAP(CPanePartItem, CPaneHolder)
	//{{AFX_MSG_MAP(CPanePartItem)
	ON_WM_CREATE()
	ON_WM_SIZE()
	ON_WM_SETFOCUS()
	//}}AFX_MSG_MAP
	ON_NOTIFY(TVN_SELCHANGED, AFX_IDW_PANE_FIRST, OnTreeSelChange)
	ON_NOTIFY(NM_CLICK, AFX_IDW_PANE_FIRST, OnClick)
	ON_NOTIFY(NM_DBLCLK, AFX_IDW_PANE_FIRST, OnDblclk)

	ON_COMMAND(ID_PANE_RIBBON_NEW, OnRibbonNew)
	ON_COMMAND(ID_PANE_RIBBON_OPEN, OnRibbonOpen)
	ON_COMMAND(ID_PANE_RIBBON_SAVE, OnRibbonSave)
	ON_COMMAND(ID_PANE_RIBBON_EXPAND, OnRibbonExpand)
	ON_COMMAND(ID_PANE_RIBBON_COLLAPSE, OnRibbonCollapse)
	ON_COMMAND(ID_PANE_RIBBON_INIT, OnRibbonInit)
	ON_COMMAND(ID_PANE_RIBBON_DEL, OnRibbonDeleteTable)
	ON_COMMAND(ID_PANE_RIBBON_LCK, OnRibbonLockTable)
	ON_UPDATE_COMMAND_UI(ID_PANE_RIBBON_EXPAND, OnUpdateRibbonExpand)
	ON_UPDATE_COMMAND_UI(ID_PANE_RIBBON_COLLAPSE, OnUpdateRibbonCollapse)
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// CPaneProperties message handlers

int CPanePartItem::OnCreate(LPCREATESTRUCT lpCreateStruct)
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

	InitPartItemActions();

	RefreshItem();
	m_wndTreeCtrl.RefreshResourceManager();

	return 0;
}

void CPanePartItem::OnSize(UINT nType, int cx, int cy)
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

void CPanePartItem::OnSetFocus(CWnd*)
{
	m_wndTreeCtrl.SetFocus();
}

void CPanePartItem::OnTreeSelChange(NMHDR* pNMHDR, LRESULT*)
{  
	NMTREEVIEW* pNMTreeView = (NMTREEVIEW *)pNMHDR;
	if (!pNMTreeView->itemNew.hItem) return;
}

void CPanePartItem::OnClick(NMHDR* pNMHDR, LRESULT* pResult) 
{
	HTREEITEM hItem = m_wndTreeCtrl.GetSelectedItem();
	if (!hItem) return;

	CXTPControlAction* pAction = (CXTPControlAction*)m_wndTreeCtrl.GetItemData(hItem);
	if(!pAction) return;
	int id = pAction->GetID();

	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
	if(!pMaainFrame->m_pRibbonReportView) return;

	CString sql;
	sql.Format(_T("where �ڵ�ID = %d"),id);
	pMaainFrame->m_pRibbonReportView->SetView(_T("tv_sys_steel_qty"));
	pMaainFrame->m_pRibbonReportView->DataBindRecordset(GetRecordset(_T("tv_sys_steel_qty"),_T(""),sql));

	*pResult = 0;
}

void CPanePartItem::OnDblclk(NMHDR* pNMHDR, LRESULT* pResult) 
{
	HTREEITEM hItem = m_wndTreeCtrl.GetSelectedItem();
	if (!hItem) return;

	CXTPControlAction* pAction = (CXTPControlAction*)m_wndTreeCtrl.GetItemData(hItem);
	if(!pAction) return;
	int id = pAction->GetID();

	LPTVACTIONTAG pTag = (LPTVACTIONTAG)m_wndTreeCtrl.GetAtPtr(id);
	if (!pTag) return;

	if (pTag->lv != 5) return;

	CString strPath = GetCurPath()+_T("\\Excel\\");
	CString strBridge = m_wndTreeCtrl.GetItemText(m_wndTreeCtrl.GetParentItem(m_wndTreeCtrl.GetParentItem(hItem)));
	if (!DirExist(strPath+strBridge))
		ModifyDir(strPath+strBridge);

	CString strSteel = m_wndTreeCtrl.GetItemText(hItem);

	CString strFile = strPath+strBridge+ _T("\\")+strSteel+ _T("�ֽ����������.xlsx");

	CXTPExcelUtil excel;
	excel.InitExcel();
	if(excel.CreateExcel(strSteel+_T("�ֽ����������.xlsx"), strPath+strBridge, _T("�ֽ�����ģ��.xlsx"), strPath))
	{
		excel.OpenExcel(strFile);
		excel.LoadSheet(1);

		int idx = 0;

		HTREEITEM _hItem = m_wndTreeCtrl.GetChildItem(hItem);
		while (_hItem)
		{
			CString strCur = m_wndTreeCtrl.GetItemText(_hItem);
			HTREEITEM hItemSub = m_wndTreeCtrl.GetChildItem(_hItem);
			if (hItemSub)
			{
				while (hItemSub)
				{
					CXTPControlAction* pAction = (CXTPControlAction*)m_wndTreeCtrl.GetItemData(hItemSub);
					if(!pAction) continue;
					int id = pAction->GetID();

					LPTVACTIONTAG pTag = (LPTVACTIONTAG)m_wndTreeCtrl.GetAtPtr(id);
					if (!pTag) continue;
					id = pTag->id;
					int pid = pTag->ids[2];
					int spi = pTag->spi;
					CString strSub = m_wndTreeCtrl.GetItemText(hItemSub);

					HTREEITEM hItemPre = hItemSub;
					for (int i=pTag->lv; i>3; i--)
					{
						hItemPre = m_wndTreeCtrl.GetParentItem(hItemPre);
					}
					CString strPre = m_wndTreeCtrl.GetItemText(hItemPre);

					excel.SetCell(strPre,5+idx,3);
					excel.SetCell(strCur,5+idx,4);
					excel.SetCell(strSub,5+idx,5);
					excel.SetCell(pid,5+idx,6);
					excel.SetCell(id,5+idx,7);
					excel.SetCell(spi,5+idx,8);
					excel.SetCell(strSteel+_T("-A")+ToString(id,0),5+idx,9);
					excel.InsertRow(5+idx++);

					hItemSub = m_wndTreeCtrl.GetNextSiblingItem(hItemSub);
				}
			}
			else
			{
				CXTPControlAction* pAction = (CXTPControlAction*)m_wndTreeCtrl.GetItemData(_hItem);
				if(!pAction) continue;
				int id = pAction->GetID();

				LPTVACTIONTAG pTag = (LPTVACTIONTAG)m_wndTreeCtrl.GetAtPtr(id);
				if (!pTag) continue;
				id = pTag->id;
				int pid = pTag->ids[2];
				int spi = pTag->spi;

				HTREEITEM hItemPre = _hItem;
				for (int i=pTag->lv; i>3; i--)
				{
					hItemPre = m_wndTreeCtrl.GetParentItem(hItemPre);
				}
				CString strPre = m_wndTreeCtrl.GetItemText(hItemPre);

				excel.SetCell(strPre,5+idx,3);
				excel.SetCell(strCur,5+idx,4);
				excel.SetCell(pid,5+idx,6);
				excel.SetCell(id,5+idx,7);
				excel.SetCell(spi,5+idx,8);
				excel.SetCell(strSteel+_T("-A")+ToString(id,0),5+idx,9);
				excel.InsertRow(5+idx++);
			}

			_hItem = m_wndTreeCtrl.GetNextSiblingItem(_hItem);
		}

		excel.Save();
	}
	else
	{
		msgWrg(_T("����")+strSteel+_T("�ֽ����������.xlsx")+_T("ʧ�ܣ�"));
	}
				
	excel.CloseExcel();
	excel.ReleaseExcel();


	if (FileExist(strFile)) ShellExecuteOpen(strFile);

	*pResult = 0;
}

void CPanePartItem::RefreshItem()
{
	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();

	if (pMaainFrame->m_pActiveCommandBars)
		pMaainFrame->m_pActiveCommandBars->SetDragControl(NULL);

	pMaainFrame->m_pActivePane = this;
	pMaainFrame->m_wndPaneProperties.Refresh(this);
}

CString CPanePartItem::GetCategoryName(const CString& str)
{
	if (str == _T("(None)"))
		return _T("");

	return str;
}

CObject* CPanePartItem::RefreshPropertyGrid(CXTPPropertyGrid* pPropertyGrid) 
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

BOOL CPanePartItem::OnPropertyGridValueChanged(CObject* pActiveObject, CXTPPropertyGridItem* pItem)
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

void CPanePartItem::OnRibbonNew()
{
	if (AfxMessageBox(_T("Are you sure you want remove all actions?"), MB_YESNO) != IDYES) return;

	m_wndTreeCtrl.DeleteAllItems();

	HTREEITEM hItemRibbon = m_wndTreeCtrl.GetRootItem();
	if (!hItemRibbon) hItemRibbon = m_wndTreeCtrl.InsertItem(_T("PartItemList"), 0, 0);

	m_strFileName.Empty();
}

void CPanePartItem::InitPartItemActions()
{
	m_wndTreeCtrl.DeleteAllItems();

	HTREEITEM hItemPartItem = m_wndTreeCtrl.GetRootItem();
	if (!hItemPartItem) hItemPartItem = m_wndTreeCtrl.InsertItem(_T("PartItemList"),0,0);
	m_wndTreeCtrl.SetItemColor(hItemPartItem,RGB(255,0,0));

	CString sql;
	sql.Format(_T("select hpi_level, hpi_node, hpi_id, hpi_rootid, spi_id from %s[tb_highway_partitem] \
				  group by hpi_level, hpi_node, hpi_id, hpi_rootid, spi_id \
				  order by hpi_id"),g_TablePrix);

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
		int spi;
		rst.GetFieldValue(4,spi);

		CString strCategory;
		if(tvi.pid == 0)
		{
			strCategory = _T("PartItemList");
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
		pTag->spi = spi;
		TVTAGQTY qty;
		qty.qty = 50.4;
		qty.mut = "m3";
		pTag->qty.insert(PAIRTAGQTY("������",qty));
		qty.qty = 150.2;
		pTag->qty.insert(PAIRTAGQTY("Ƭʯ��",qty));
		qty.qty = 2330.1;
		pTag->qty.insert(PAIRTAGQTY("����ʯ",qty));
		qty.qty = 130.6;
		qty.mut = "t";
		pTag->qty.insert(PAIRTAGQTY("��  ��",qty));
		qty.qty = 30.8;
		pTag->qty.insert(PAIRTAGQTY("��  ��",qty));
		qty.qty = 2220.1;
		qty.mut = "m3";
		pTag->qty.insert(PAIRTAGQTY("������",qty));
		qty.qty = 1130.2;
		pTag->qty.insert(PAIRTAGQTY("��ʯ��",qty));
		qty = TVTAGQTY("һ��","��",30);
		pTag->lab.insert(PAIRTAGQTY("�ֽ��",qty));
		qty = TVTAGQTY("һ��","��",16);
		pTag->lab.insert(PAIRTAGQTY("��  ��",qty));
		qty = TVTAGQTY("һ��","��",20);
		pTag->lab.insert(PAIRTAGQTY("ģ���",qty));
		qty = TVTAGQTY("���","̨",3);
		pTag->dev.insert(PAIRTAGQTY("�ھ��",qty));
		qty = TVTAGQTY("���","̨",5);
		pTag->dev.insert(PAIRTAGQTY("װ�ػ�",qty));
		qty = TVTAGQTY("���","��",10);
		pTag->dev.insert(PAIRTAGQTY("��ж��",qty));
		qty = TVTAGQTY("һ��","̨",2);
		pTag->dev.insert(PAIRTAGQTY("������",qty));
		qty.qty = 1200.4;
		qty.mut = "t";
		pTag->mat.insert(PAIRTAGQTY("����ģ��",qty));
		qty.qty = 100.1;
		pTag->mat.insert(PAIRTAGQTY("��̨ģ��",qty));
		qty.qty = 200.23;
		pTag->mat.insert(PAIRTAGQTY("��ñģ��",qty));
		qty.qty = 510.55;
		pTag->mat.insert(PAIRTAGQTY("����ģ��",qty));
		qty.qty = 300;
		qty.mut = "��";
		pTag->mat.insert(PAIRTAGQTY("���֧��",qty));
		pAction->SetTag((DWORD_PTR)pTag);
		m_wndTreeCtrl.SetAction(tvi.hti, pAction);
		m_wndTreeCtrl.SetAtPtr(tvi.id, pTag);

		rst.MoveNext();
	}
	rst.Close();

	XTPTVITEMMAP mapTvis = XTPTVITEM::convert_map(tvis);
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

		CXTPControlAction* pAction = (CXTPControlAction*)m_wndTreeCtrl.GetItemData(tvi.hti);
		if(!pAction) return;
		int id = pAction->GetID();
		LPTVACTIONTAG pTag = (LPTVACTIONTAG)m_wndTreeCtrl.GetAtPtr(id);
		if (!pTag) return;

		HTREEITEM hItem = m_wndTreeCtrl.GetParentItem(tvi.hti);
		for (int i=1; i<tvi.lv; i++)
		{
			pTag->ids[tvi.lv-i-1] = mapTvis[hItem].id;
			hItem = m_wndTreeCtrl.GetParentItem(hItem);
		}

		pAction->SetTag((DWORD_PTR)pTag);
		m_wndTreeCtrl.SetAction(tvi.hti, pAction);
		m_wndTreeCtrl.SetAtPtr(tvi.id, pTag);
	}

	m_wndTreeCtrl.Expand(hItemPartItem, TVE_EXPAND);
}

void CPanePartItem::InitPartItemFromJson()
{
	CString strFilter = _T("JSON file (*.jsn)|*.jsn|TREE file (*.tre)|*.tre|CSV file (*.csv)|*.csv|Excel 2007 file (*.xlsx)|*.xlsx|INDENT file (*.idt)|*.idt|TEXT file (*.txt)|*.txt|TAG file (*.tag)|*.tag|All files (*.*)|*.*||");
	CFileDialog fd(TRUE, _T("jsn"), NULL, OFN_FILEMUSTEXIST| OFN_HIDEREADONLY, strFilter);

	if (fd.DoModal() != IDOK)
		return;

	CString strFilePath = fd.GetPathName();
	CString strPath = strFilePath.Mid(0,strFilePath.ReverseFind('\\'))+_T("\\");

	filebuf file;
	if (!file.open(strFilePath, ios::in)) throw xtpErrorOpen;

	istream ist(&file);
	XTPJSON::Reader reader;
	XTPJSON::Value val;

	if (!reader.parse(ist, val, false)) return;

	XTPTVITEMVECTOR tvis;

	XTPJSON::Value items = val["Items"];
	for (int i = 0; i < items.size(); i++)
	{
		XTPTVITEM tvi;
		tvi.buf = const_cast<char*>(items[i]["partName"].asCString());
		tvi.id = items[i]["partid"].asInt();
		tvi.pid = items[i]["parentid"].asInt();
		tvi.lv = items[i]["partNmb"].asInt();
		tvis.push_back(tvi);
	}

	if(!file.close()) return;

	m_wndTreeCtrl.InitTreeItem(tvis);

	CStdioFile _file;
	if(_file.Open(strPath+_T("\\��Ŀ���ṹ.csv"), CFile::modeCreate | CFile::modeReadWrite))
	{
		setlocale(LC_ALL,"");
		_file.Seek(CFile::begin,0);

		_file.WriteString(_T("�ڵ�����,�ڵ�ID,���ڵ�ID,�ڵ㼶��,ϵͳ�ڵ�\n"));

		XTPTVITEMMAP mapTvis = XTPTVITEM::convert_map(tvis);
		XTPTVITEMVECTOR::iterator _iter = tvis.begin();
		while(_iter != tvis.end())
		{
			XTPTVITEM tvi = *_iter++;
			int id = tvi.id;
			int pid = tvi.pid;
			int lv = m_wndTreeCtrl.GetItemLevel(tvi.hti);
			if(tvi.buf == NULL) continue;
			CString node = CXTPString(tvi.buf);
			CString str;
			str.Format(_T("%s,%d,%d,%d,%d\n"),node,id,pid,lv,tvi.lv);
			_file.WriteString(str);

			LPTVACTIONTAG pTag = new TVACTIONTAG;
			pTag->id = id;
			pTag->pid = pid;
			pTag->lv = lv;

			HTREEITEM hItem = m_wndTreeCtrl.GetParentItem(tvi.hti);
			for (int i=1; i<tvi.lv; i++)
			{
				pTag->ids[tvi.lv-i-1] = mapTvis[hItem].id;
				hItem = m_wndTreeCtrl.GetParentItem(hItem);
			}

			TVTAGQTY qty;
			qty.qty = 50.4;
			qty.mut = "m3";
			pTag->qty.insert(PAIRTAGQTY("������",qty));
			qty.qty = 150.2;
			pTag->qty.insert(PAIRTAGQTY("Ƭʯ��",qty));
			qty.qty = 2330.1;
			pTag->qty.insert(PAIRTAGQTY("����ʯ",qty));
			qty.qty = 130.6;
			qty.mut = "t";
			pTag->qty.insert(PAIRTAGQTY("��  ��",qty));
			qty.qty = 30.8;
			pTag->qty.insert(PAIRTAGQTY("��  ��",qty));
			qty.qty = 2220.1;
			qty.mut = "m3";
			pTag->qty.insert(PAIRTAGQTY("������",qty));
			qty.qty = 1130.2;
			pTag->qty.insert(PAIRTAGQTY("��ʯ��",qty));
			qty = TVTAGQTY("һ��","��",30);
			pTag->lab.insert(PAIRTAGQTY("�ֽ��",qty));
			qty = TVTAGQTY("һ��","��",16);
			pTag->lab.insert(PAIRTAGQTY("��  ��",qty));
			qty = TVTAGQTY("һ��","��",20);
			pTag->lab.insert(PAIRTAGQTY("ģ���",qty));
			qty = TVTAGQTY("���","̨",3);
			pTag->dev.insert(PAIRTAGQTY("�ھ��",qty));
			qty = TVTAGQTY("���","̨",5);
			pTag->dev.insert(PAIRTAGQTY("װ�ػ�",qty));
			qty = TVTAGQTY("���","��",10);
			pTag->dev.insert(PAIRTAGQTY("��ж��",qty));
			qty = TVTAGQTY("һ��","̨",2);
			pTag->dev.insert(PAIRTAGQTY("������",qty));
			qty.qty = 1200.4;
			qty.mut = "t";
			pTag->mat.insert(PAIRTAGQTY("����ģ��",qty));
			qty.qty = 100.1;
			pTag->mat.insert(PAIRTAGQTY("��̨ģ��",qty));
			qty.qty = 200.23;
			pTag->mat.insert(PAIRTAGQTY("��ñģ��",qty));
			qty.qty = 510.55;
			pTag->mat.insert(PAIRTAGQTY("����ģ��",qty));
			qty.qty = 300;
			qty.mut = "��";
			pTag->mat.insert(PAIRTAGQTY("���֧��",qty));

			CString strKeyAction = GetDefineID(id);
			CString strCaption = node;
			m_wndTreeCtrl.AddAction(tvi.hti, strCaption, id, pid, lv, strKeyAction, strCaption, 0, _T(""), _T(""), (DWORD_PTR)pTag);
			m_wndTreeCtrl.SetAtPtr(id, pTag);
		}

		_file.Close();
	}
}

void CPanePartItem::OnRibbonOpen()
{
	m_wndTreeCtrl.OpenTreeFile(xtpFileFormatBinary);
}

void CPanePartItem::OnRibbonSave()
{
	m_wndTreeCtrl.SaveTreeFile(xtpFileFormatBinary);
}

void CPanePartItem::OnRibbonExpand()
{
	m_wndTreeCtrl.ExpandItems();
	m_bTreeExpand = TRUE;
}

void CPanePartItem::OnRibbonCollapse()
{
	m_wndTreeCtrl.CollapseItems();
	m_bTreeExpand = FALSE;
}

void CPanePartItem::OnRibbonInit()
{
	BOOL ret = msgAsk(_T("�Ƿ��ʼ���ֲ��������νṹ��"));
	if(ret)
	{
		InitPartItemActions();
		msgInf(_T("��ʼ���ֲ��������νṹ�ɹ���"));
	}
	else
	{
		InitPartItemFromJson();
		msgInf(_T("���طֲ���������JSN�ļ��ɹ���"));
	}
}

void CPanePartItem::OnRibbonDeleteTable()
{
	BOOL ret = msgAsk(_T("�Ƿ���ոֽ����ݱ����ݣ�"));
	if(ret)
	{
		DeleteTable(_T("tb_sys_steel_qty"));
		DeleteTable(_T("tb_sys_steel_library"));
		msgInf(_T("��ոֽ����ݱ����ݳɹ���"));
	}
}

void CPanePartItem::OnRibbonLockTable()
{
	BOOL ret = msgAsk(_T("�Ƿ����øֽ����ݱ��Զ���ţ�"));
	if(ret)
	{
		ResetIdent(_T("tb_sys_steel_qty"),0);
		ResetIdent(_T("tb_sys_steel_library"),0);
		msgInf(_T("���øֽ����ݱ��Զ���ųɹ���"));
	}
}

void CPanePartItem::OnUpdateRibbonExpand(CCmdUI* pCmdUI)
{
	CXTPControl* pControl = CXTPControl::FromUI(pCmdUI);

	pCmdUI->Enable(TRUE);

	if (pControl) pControl->SetVisible(!m_bTreeExpand);
}

void CPanePartItem::OnUpdateRibbonCollapse(CCmdUI* pCmdUI)
{
	CXTPControl* pControl = CXTPControl::FromUI(pCmdUI);

	pCmdUI->Enable(TRUE);

	if (pControl) pControl->SetVisible(m_bTreeExpand);
}