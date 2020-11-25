// PaneProperties.cpp : implementation file
//
// This file is a part of the XTREME TOOLKIT PRO MFC class library.
// (c)1998-2011 Codejock Software, All Rights Reserved.
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

#include "stdafx.h"
#include "RibbonReport.h"
#include "MainFrm.h"

#include "PaneProperties.h"
#include "ChartView.h"
#include "Report/ReportRecordView.h"
#include "PropertyItemFlags.h"


#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


/////////////////////////////////////////////////////////////////////////////
// CPaneProperties

CPaneProperties::CPaneProperties()
{
	m_pActiveObject = NULL;
	m_pActivePane = NULL;

	m_nActiveChartStyle = 0;
}

CPaneProperties::~CPaneProperties()
{
}


BEGIN_MESSAGE_MAP(CPaneProperties, CPaneHolder)
	//{{AFX_MSG_MAP(CPaneProperties)
	ON_WM_CREATE()
	ON_WM_SIZE()
	ON_WM_SETFOCUS()
	ON_COMMAND(ID_PANE_PROPERTIES_CATEGORIZED, OnPanePropertiesCategorized)
	ON_UPDATE_COMMAND_UI(ID_PANE_PROPERTIES_CATEGORIZED, OnUpdatePanePropertiesCategorized)
	ON_COMMAND(ID_PANE_PROPERTIES_ALPHABETIC, OnPanePropertiesAlphabetic)
	ON_UPDATE_COMMAND_UI(ID_PANE_PROPERTIES_ALPHABETIC, OnUpdatePanePropertiesAlphabetic)
	ON_COMMAND(ID_PANE_PROPERTIES_PAGES, OnPanePropertiesPages)
	ON_UPDATE_COMMAND_UI(ID_PANE_PROPERTIES_PAGES, OnUpdatePanePropertiesPages)
	//}}AFX_MSG_MAP
	ON_MESSAGE(XTPWM_PROPERTYGRID_NOTIFY, OnGridNotify)
END_MESSAGE_MAP()


void CPaneProperties::Refresh(CObject* pActiveObject, CPaneHolder* pActivePane)
{
	if (!m_hWnd) return;

	m_pActivePane = pActivePane;
	m_pActiveObject = pActiveObject;

	m_wndPropertyGrid.BeginUpdate(m_stateExpanding);

	if (m_pActivePane)
		RefreshPaneProperties();
	else
	{
		if(m_pActiveObject != NULL)
		{
			if (m_pActiveObject->IsKindOf(RUNTIME_CLASS(CReportRecordView)))
				RefreshReportProperties();
			else if (m_pActiveObject->IsKindOf(RUNTIME_CLASS(CChartView)))
				RefreshChartProperties();
		}
	}

	m_wndPropertyGrid.EndUpdate(m_stateExpanding);
}

void CPaneProperties::RefreshPaneProperties()
{
	if (!m_pActivePane)
		return;

	m_pActiveObject = m_pActivePane->RefreshPropertyGrid(&m_wndPropertyGrid);
}

void CPaneProperties::RefreshReportProperties()
{
	if(m_pActiveObject != NULL)
	{
		m_wndPropertyGrid.ResetContent();
		m_wndPropertyGrid.SetVariableItemsHeight(TRUE);

		CXTPPropertyGridItem* pCategory = m_wndPropertyGrid.AddCategory(ID_GRID_CATEGORY_REPORT_PARAM);
		CXTPPropertyGridItemOption* pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_REPORT_ROWS, 0));
		CXTPPropertyGridItemConstraints* pList = pItemOption->GetConstraints();
		pList->AddConstraint(_T("显示头行"), 1);
		pList->AddConstraint(_T("是否尾行"), 2);
		pItemOption->SetCheckBoxStyle();

		
		pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_REPORT_EDIT, 7));
		pList = pItemOption->GetConstraints();
		pList->AddConstraint(_T("允许编辑"), 1);
		pList->AddConstraint(_T("编辑头行"), 2);
		pList->AddConstraint(_T("编辑尾行"), 4);
		pItemOption->SetCheckBoxStyle();

		pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_REPORT_GROUP, 3));
		pList = pItemOption->GetConstraints();
		pList->AddConstraint(_T("分组显示"), 1);
		pList->AddConstraint(_T("全部展开"), 2);
		pItemOption->SetCheckBoxStyle();

		pCategory->Expand();

		pCategory = m_wndPropertyGrid.AddCategory(ID_GRID_CATEGORY_REPORT_ATTRIBUTE);
		pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_REPORT_GRID, 3));
		pList = pItemOption->GetConstraints();
		pList->AddConstraint(_T("水平网格"), 1);
		pList->AddConstraint(_T("竖直网格"), 2);
		pItemOption->SetCheckBoxStyle();

		pCategory->AddChildItem(new CXTPPropertyGridItemBool(ID_GRID_ITEM_REPORT_SELECTION,1));
		pCategory->AddChildItem(new CXTPPropertyGridItemBool(ID_GRID_ITEM_REPORT_FOUCS,1));

		CXTPPropertyGridItem* pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_REPORT_SORT, _T("升序排列")));
		pList = pItemList->GetConstraints();
		pList->AddConstraint(_T("升序排列"),1);
		pList->AddConstraint(_T("降序排列"),2);
		pList->AddConstraint(_T("不 排 序"),3);
		pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

		pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_REPORT_ALIGNMENT, _T("中心对齐")));
		pList = pItemList->GetConstraints();
		pList->AddConstraint(_T("左边对齐"),1);
		pList->AddConstraint(_T("右边对齐"),2);
		pList->AddConstraint(_T("中心对齐"),3);
		pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

		pCategory->AddChildItem(new CXTPPropertyGridItemColor(ID_GRID_ITEM_REPORT_COLOR));
		pCategory->AddChildItem(new CXTPPropertyGridItemColor(ID_GRID_ITEM_REPORT_BKCOLOR));

		LOGFONT lf;
		XTPDrawHelpers()->GetIconLogFont(&lf);
		pCategory->AddChildItem(new CXTPPropertyGridItemFont(ID_GRID_ITEM_REPORT_FONT,lf));

		pCategory->Expand();
	}
}

LPCTSTR lpszMarkerTypes = _T("Circle;Square;Diamond;Triangle;Pentagon;Hexagon;Star;");
LPCTSTR lpszInterval = _T("1000;900;800;700;600;500;400;300;200;100;");
LPCTSTR lpszExplodedPoints = _T("None;All;Custom;");
LPCTSTR lpszScatterAngle = _T("0;45;90;135;180;225;270;315;");
LPCTSTR lpszDoughnut = _T("0;10;20;30;40;50;60;70;80;");
void CPaneProperties::RefreshChartProperties()
{
	if(m_pActiveObject && m_pActiveObject->IsKindOf(RUNTIME_CLASS(CChartView)))
	{
		CChartView* pActivepChartView = (CChartView*)m_pActiveObject;
		m_wndPropertyGrid.ResetContent();
		m_wndPropertyGrid.SetVariableItemsHeight(TRUE);

		CXTPPropertyGridItem* pCategory = m_wndPropertyGrid.AddCategory(ID_GRID_CATEGORY_CHART_PARAM);
		int cnt = pActivepChartView->GetSeriesCount();
		int pre = 0;
		CXTPPropertyGridItemOption* pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_CHART_SERIES, pre));
		CXTPPropertyGridItemConstraints* pList = pItemOption->GetConstraints();
		for(int i=0; i<cnt; i++)
		{
			pre = pre + pow(2.0,i);
			pList->AddConstraint(pActivepChartView->GetSeriesName(i), pow(2.0,i));
		}
		pItemOption->SetOption(pre);
		pItemOption->SetCheckBoxStyle();

		switch(m_nActiveChartStyle)
		{
		case ID_CHART_STYLE_BAR:
		case ID_CHART_STYLE_STACKEDBAR:
			{
				pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_CHART_LABELORROTATED, 1));
				pList = pItemOption->GetConstraints();
				pList->AddConstraint(_T("显示标题"), 1);
				pList->AddConstraint(_T("是否旋转"), 2);
				pItemOption->SetCheckBoxStyle();

				CXTPPropertyGridItem* pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_LABEL_POSITION, _T("顶部")));
				pList = pItemList->GetConstraints();
				pList->AddConstraint(_T("顶部"),xtpChartBarLabelTop);
				pList->AddConstraint(_T("中间"),xtpChartBarLabelCenter);
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				pCategory->Expand();
			}
			break;
		case ID_CHART_STYLE_SIDEBAR:
			{
				pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_CHART_LABELORROTATED, 1));
				pList = pItemOption->GetConstraints();
				pList->AddConstraint(_T("显示标题"), 1);
				pList->AddConstraint(_T("是否旋转"), 2);
				pItemOption->SetCheckBoxStyle();

				CXTPPropertyGridItem* pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_LABEL_POSITION, _T("顶部")));
				pList = pItemList->GetConstraints();
				pList->AddConstraint(_T("顶部"),xtpChartBarLabelTop);
				pList->AddConstraint(_T("中间"),xtpChartBarLabelCenter);
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_CHART_SERIESGROUP, pActivepChartView->GetSeriesCount()));
				pList = pItemOption->GetConstraints();
				pList->AddConstraint(_T("项目"), pActivepChartView->GetSeriesCount());
				pList->AddConstraint(_T("系列"), 1);

				pCategory->Expand();
			}
			break;
		case ID_CHART_STYLE_SCATTER:
			{
				pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_CHART_LABELORMARK, 1 + 2));
				pList = pItemOption->GetConstraints();
				pList->AddConstraint(_T("显示标题"), 1);
				pList->AddConstraint(_T("显示标记"), 2);
				pItemOption->SetCheckBoxStyle();

				CStringArray arrMarkerType;
				CreateArray(arrMarkerType, lpszMarkerTypes);
				CXTPPropertyGridItem* pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_MARKER_TYPE, arrMarkerType[0]));
				pList = pItemList->GetConstraints();
				for (int i = 0; i < arrMarkerType.GetSize(); i++)
					pList->AddConstraint(arrMarkerType[i]);
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_MARKER_SIZE, _T("8")));
				pList = pItemList->GetConstraints();
				for (int i = 8; i <= 30; i += 2)
				{
					CString strSize;
					strSize.Format(_T("%d"), i);
					pList->AddConstraint(strSize,i);
				}
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				CStringArray arrScatterAngle;
				CreateArray(arrScatterAngle, lpszScatterAngle);
				pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_MARKER_ANGLE, arrScatterAngle[0]));
				pList = pItemList->GetConstraints();
				for (int i = 0; i < arrScatterAngle.GetSize(); i++)
					pList->AddConstraint(arrScatterAngle[i]);
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				pCategory->Expand();
			}
			break;
		case ID_CHART_STYLE_BUBBLE:
			{
				pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_CHART_LABELORMARK, 1 + 2));
				pList = pItemOption->GetConstraints();
				pList->AddConstraint(_T("显示标题"), 1);
				pList->AddConstraint(_T("显示标记"), 2);
				pItemOption->SetCheckBoxStyle();

				pCategory->AddChildItem(new CXTPPropertyGridItemDouble(ID_GRID_ITEM_CHART_BUBBLE_MIN,50));
				pCategory->AddChildItem(new CXTPPropertyGridItemDouble(ID_GRID_ITEM_CHART_BUBBLE_MAX,200));

				CStringArray arrScatterAngle;
				CreateArray(arrScatterAngle, lpszScatterAngle);
				CXTPPropertyGridItem* pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_BUBBLE_TRANPARENCY, arrScatterAngle[3]));
				pList = pItemList->GetConstraints();
				for (int i = 0; i < arrScatterAngle.GetSize(); i++)
					pList->AddConstraint(arrScatterAngle[i], _tstoi(arrScatterAngle[i]));
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				pCategory->Expand();
			}
			break;
		case ID_CHART_STYLE_LINE:
			{
				pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_CHART_LABELORMARK, 1 + 2));
				pList = pItemOption->GetConstraints();
				pList->AddConstraint(_T("显示标题"), 1);
				pList->AddConstraint(_T("显示标记"), 2);
				pItemOption->SetCheckBoxStyle();

				CStringArray arrMarkerType;
				CreateArray(arrMarkerType, lpszMarkerTypes);
				CXTPPropertyGridItem* pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_MARKER_TYPE, arrMarkerType[0]));
				pList = pItemList->GetConstraints();
				for (int i = 0; i < arrMarkerType.GetSize(); i++)
					pList->AddConstraint(arrMarkerType[i]);
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_MARKER_SIZE, _T("8")));
				pList = pItemList->GetConstraints();
				for (int i = 8; i <= 30; i += 2)
				{
					CString strSize;
					strSize.Format(_T("%d"), i);
					pList->AddConstraint(strSize,i);
				}
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				pCategory->Expand();
			}
			break;
		case ID_CHART_STYLE_STEPLINE:
			{
				pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_CHART_LABELORMARK, 1 + 2));
				pList = pItemOption->GetConstraints();
				pList->AddConstraint(_T("显示标题"), 1);
				pList->AddConstraint(_T("显示标记"), 2);
				pItemOption->SetCheckBoxStyle();

				CStringArray arrMarkerType;
				CreateArray(arrMarkerType, lpszMarkerTypes);
				CXTPPropertyGridItem* pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_MARKER_TYPE, arrMarkerType[0]));
				pList = pItemList->GetConstraints();
				for (int i = 0; i < arrMarkerType.GetSize(); i++)
					pList->AddConstraint(arrMarkerType[i]);
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_MARKER_SIZE, _T("8")));
				pList = pItemList->GetConstraints();
				for (int i = 8; i <= 30; i += 2)
				{
					CString strSize;
					strSize.Format(_T("%d"), i);
					pList->AddConstraint(strSize,i);
				}
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_CHART_MARKER_INVERT, 0));
				pItemOption->GetConstraints()->AddConstraint(_T("标记反向"), 1);
				pItemOption->SetCheckBoxStyle();

				pCategory->Expand();
			}
			break;
		case ID_CHART_STYLE_FASTLINE:
			{
				pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_CHART_INTERLACED, 1 + 2));
				pList = pItemOption->GetConstraints();
				pList->AddConstraint(_T("交错显示"), 1);
				pList->AddConstraint(_T("别样显示"), 2);
				pItemOption->SetCheckBoxStyle();

				CXTPPropertyGridItem* pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_SERIESCNT, _T("2")));
				pList = pItemList->GetConstraints();
				for (int i=1; i<=5; i++)
				{
					CString strCount;
					strCount.Format(_T("%d"), i);
					pList->AddConstraint(strCount,i);
				}
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				CStringArray arrInterval;
				CreateArray(arrInterval, lpszInterval);
				pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_INTERVAL, arrInterval[0]));
				pList = pItemList->GetConstraints();
				for (int i = 0; i < arrInterval.GetSize(); i++)
					pList->AddConstraint(arrInterval[i], _tstoi(arrInterval[i]));
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				CXTPPropertyGridItem* pItem = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_INTERVALSTEP));
				pItem->SetFlags(xtpGridItemHasEdit | xtpGridItemHasExpandButton);

				pCategory->Expand();
			}
			break;
		case ID_CHART_STYLE_PIE:
			{
				pItemOption = (CXTPPropertyGridItemOption*)pCategory->AddChildItem(new CXTPPropertyGridItemOption(ID_GRID_ITEM_CHART_LABELORMARK, 1));
				pItemOption->GetConstraints()->AddConstraint(_T("显示标题"), 1);
				pItemOption->SetCheckBoxStyle();

				CXTPPropertyGridItem* pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_LABEL_POSITION, _T("顶部")));
				pList = pItemList->GetConstraints();
				pList->AddConstraint(_T("顶部"),xtpChartBarLabelTop);
				pList->AddConstraint(_T("中间"),xtpChartBarLabelCenter);
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				CStringArray arrExplodedPoints;
				CreateArray(arrExplodedPoints, lpszExplodedPoints);
				pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_EXPLODED_POINTS, arrExplodedPoints[0]));
				pList = pItemList->GetConstraints();
				for (int i = 0; i < arrExplodedPoints.GetSize(); i++)
					pList->AddConstraint(arrExplodedPoints[i]);
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				CStringArray arrDoughnut;
				CreateArray(arrDoughnut, lpszDoughnut);
				pItemList = pCategory->AddChildItem(new CXTPPropertyGridItem(ID_GRID_ITEM_CHART_DOUGHNUT, arrDoughnut[0]));
				pList = pItemList->GetConstraints();
				for (int i = 0; i < arrDoughnut.GetSize(); i++)
					pList->AddConstraint(arrDoughnut[i],_tstoi(arrDoughnut[i]));
				pItemList->SetFlags(xtpGridItemHasComboButton | xtpGridItemHasEdit);

				pCategory->Expand();
			}
			break;
		}
	}
}

/////////////////////////////////////////////////////////////////////////////
// CPaneProperties message handlers

int CPaneProperties::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (CPaneHolder::OnCreate(lpCreateStruct) == -1)
		return -1;

	if(!m_wndToolBar.CreateToolBar(WS_TABSTOP|WS_VISIBLE|WS_CHILD|CBRS_TOOLTIPS, this))
		return -1;

	if(!m_wndToolBar.LoadToolBar(IDR_PANE_PROPERTIES))
		return -1;


	if(!m_wndPropertyGrid.Create( CRect(0, 0, 0, 0), this, 0 ))
		return -1;

	//m_wndPropertyGrid.SetTheme(xtpGridThemeResource);

	return 0;
}

void CPaneProperties::OnSize(UINT nType, int cx, int cy)
{
	CPaneHolder::OnSize(nType, cx, cy);

	CSize sz(0);
	if (m_wndToolBar.GetSafeHwnd())
	{
		sz = m_wndToolBar.CalcDockingLayout(cx, /*LM_HIDEWRAP|*/ LM_HORZDOCK|LM_HORZ | LM_COMMIT);

		m_wndToolBar.MoveWindow(0, 0, cx, sz.cy);
		m_wndToolBar.Invalidate(FALSE);
	}
	if (m_wndPropertyGrid.GetSafeHwnd())
	{
		m_wndPropertyGrid.MoveWindow(0, sz.cy, cx, cy - sz.cy);
	}
}

void CPaneProperties::OnSetFocus(CWnd*)
{
	m_wndPropertyGrid.SetFocus();
}

void CPaneProperties::OnPropertyReportValueChanged(CXTPPropertyGridItem* pItem )
{
	if(!pItem) return;
	if(m_pActiveObject && m_pActiveObject->IsKindOf(RUNTIME_CLASS(CReportRecordView)))
	{
		CReportRecordView* pActivepReportView = ((CReportRecordView*)m_pActiveObject);
		switch (pItem->GetID())
		{
		case ID_GRID_ITEM_REPORT_ROWS:
			{
				CXTPPropertyGridItemOption* pItemOption  = (CXTPPropertyGridItemOption*)pItem;
				int val = pItemOption->GetOption();
				CXTPPropertyGridItemConstraints* pList = pItemOption->GetConstraints();
				pActivepReportView->ShowHeaderRows(val & pList->GetConstraintAt(0)->m_dwData);
				pActivepReportView->ShowFooterRows(val & pList->GetConstraintAt(1)->m_dwData);
			}
			break;
		case ID_GRID_ITEM_REPORT_EDIT:
			{
				CXTPPropertyGridItemOption* pItemOption  = (CXTPPropertyGridItemOption*)pItem;
				int val = pItemOption->GetOption();
				CXTPPropertyGridItemConstraints* pList = pItemOption->GetConstraints();
				pActivepReportView->AllowEdit(val & pList->GetConstraintAt(0)->m_dwData);
				pActivepReportView->AllowHeaderEdit(val & pList->GetConstraintAt(1)->m_dwData);
				pActivepReportView->AllowFooterEdit(val & pList->GetConstraintAt(2)->m_dwData);
			}
			break;
		case ID_GRID_ITEM_REPORT_GROUP:
			{
				CXTPPropertyGridItemOption* pItemOption  = (CXTPPropertyGridItemOption*)pItem;
				int val = pItemOption->GetOption();
				CXTPPropertyGridItemConstraints* pList = pItemOption->GetConstraints();
				pActivepReportView->ShowGroupBox(val & pList->GetConstraintAt(0)->m_dwData);
				if(val & pList->GetConstraintAt(1)->m_dwData)
					pActivepReportView->ExpandAll();
				else
					pActivepReportView->CollapseAll();
			}
			break;
		case ID_GRID_ITEM_REPORT_GRID:
			{
				CXTPPropertyGridItemOption* pItemOption  = (CXTPPropertyGridItemOption*)pItem;
				int val = pItemOption->GetOption();
				CXTPPropertyGridItemConstraints* pList = pItemOption->GetConstraints();
				pActivepReportView->SetGridStyle(TRUE, val & pList->GetConstraintAt(0)->m_dwData ? xtpReportGridSolid:xtpReportGridNoLines);
				pActivepReportView->SetGridStyle(FALSE, val & pList->GetConstraintAt(1)->m_dwData ? xtpReportGridSolid:xtpReportGridNoLines);
			}
			break;
		case ID_GRID_ITEM_REPORT_SELECTION:
			{
				CXTPPropertyGridItemBool* pItemBool  = (CXTPPropertyGridItemBool*)pItem;
				pActivepReportView->AllowMultipleSelection(pItemBool->GetBool());
			}
			break;
		case ID_GRID_ITEM_REPORT_FOUCS:
			{
				CXTPPropertyGridItemBool* pItemBool  = (CXTPPropertyGridItemBool*)pItem;
				pActivepReportView->AllowFocusSubItems(pItemBool->GetBool());
			}
			break;
		case ID_GRID_ITEM_REPORT_SORT:
			{
				CXTPPropertyGridItemConstraints* pList = pItem->GetConstraints();
				int idx = pList->GetCurrent();
				if(idx >= 0)
				{
					int val = pList->GetConstraintAt(idx)->m_dwData;
					CXTPReportColumn* pColumn = pActivepReportView->GetFocusedColumn();
					CXTPReportColumns* pColumns = pActivepReportView->GetColumns();
					if (pColumn && pColumn->IsSortable())
					{
						if(val != 3)  pColumns->SetSortColumn(pColumn, val == 1);
						if(val == 3) pColumns->GetSortOrder()->Clear();
						pActivepReportView->Populate();
					}
				}
			}
			break;
		case ID_GRID_ITEM_REPORT_ALIGNMENT:
			{
				CXTPPropertyGridItemConstraints* pList = pItem->GetConstraints();
				CXTPReportSelectedRows* pRows = pActivepReportView->GetSelectedRows();
				if(pRows != NULL)
				{
					int iRows = pRows->GetCount();
					for(int i=0; i<iRows; i++)
					{
						CXTPReportRow* pRow = pRows->GetAt(i);
						CXTPReportRecord* pRecord = pRow->GetRecord();
						CXTPReportColumn* pColumn = pActivepReportView->GetFocusedColumn();
						if(pRecord != NULL)
						{
							CXTPReportRecordItem* pItem = pRecord->GetItem(pColumn->GetIndex());
							if(pItem != NULL)
							{
								int idx = pList->GetCurrent();
								if(idx >= 0)
								{
									int val = pList->GetConstraintAt(idx)->m_dwData;
									CXTPReportColumn* pColumn = pActivepReportView->GetFocusedColumn();
									int nAlign = pColumn->GetAlignment();
									nAlign &= ~(xtpColumnTextLeft | xtpColumnTextCenter | xtpColumnTextRight);

									switch (val)
									{
									case 1 :
										pItem->SetAlignment(nAlign | xtpColumnTextLeft);
										break;
									case 2 :
										pItem->SetAlignment(nAlign | xtpColumnTextRight);
										break;
									case 3  :
										pItem->SetAlignment(nAlign | xtpColumnTextCenter);
										break;
									}
								}
							}
						}
					}
				}
			}
			break;
		case ID_GRID_ITEM_REPORT_COLOR:
			{
				CXTPPropertyGridItemColor* pItemColor = (CXTPPropertyGridItemColor*)pItem;
				CXTPReportSelectedRows* pRows = pActivepReportView->GetSelectedRows();
				if(pRows != NULL)
				{
					int iRows = pRows->GetCount();
					for(int i=0; i<iRows; i++)
					{
						CXTPReportRow* pRow = pRows->GetAt(i);
						CXTPReportRecord* pRecord = pRow->GetRecord();
						CXTPReportColumn* pColumn = pActivepReportView->GetFocusedColumn();
						if(pRecord != NULL)
						{
							CXTPReportRecordItem* pItem = pRecord->GetItem(pColumn->GetIndex());
							if(pItem != NULL)
								pItem->SetTextColor(pItemColor->GetColor());
						}
					}
				}
			}
			break;
		case ID_GRID_ITEM_REPORT_BKCOLOR:
			{
				CXTPPropertyGridItemColor* pItemColor = (CXTPPropertyGridItemColor*)pItem;
				CXTPReportSelectedRows* pRows = pActivepReportView->GetSelectedRows();
				if(pRows != NULL)
				{
					int iRows = pRows->GetCount();
					for(int i=0; i<iRows; i++)
					{
						CXTPReportRow* pRow = pRows->GetAt(i);
						CXTPReportRecord* pRecord = pRow->GetRecord();
						CXTPReportColumn* pColumn = pActivepReportView->GetFocusedColumn();
						if(pRecord != NULL)
						{
							CXTPReportRecordItem* pItem = pRecord->GetItem(pColumn->GetIndex());
							if(pItem != NULL)
								pItem->SetBackgroundColor(pItemColor->GetColor());
						}
					}
				}
			}
			break;
		case ID_GRID_ITEM_REPORT_FONT:
			{
				CXTPPropertyGridItemFont* pItemFont = (CXTPPropertyGridItemFont*)pItem;
				CXTPReportSelectedRows* pRows = pActivepReportView->GetSelectedRows();
				if(pRows != NULL)
				{
					int iRows = pRows->GetCount();
					for(int i=0; i<iRows; i++)
					{
						CXTPReportRow* pRow = pRows->GetAt(i);
						CXTPReportRecord* pRecord = pRow->GetRecord();
						CXTPReportColumn* pColumn = pActivepReportView->GetFocusedColumn();
						if(pRecord != NULL)
						{
							CXTPReportRecordItem* pItem = pRecord->GetItem(pColumn->GetIndex());
							if(pItem != NULL)
							{
								LOGFONT lf;
								pItemFont->GetFont(&lf);
								CFont ft;
								ft.CreateFontIndirect(&lf);
								pItem->SetFont(&ft);
							}
						}
					}
				}
			}
			break;
		}
	}
}

void CPaneProperties::OnPropertyChartValueChanged(CXTPPropertyGridItem* pItem )
{
	if(!pItem) return;
	if(m_pActiveObject && m_pActiveObject->IsKindOf(RUNTIME_CLASS(CChartView)))
	{
		CChartView* pActivepChartView = (CChartView*)m_pActiveObject;
		switch (pItem->GetID())
		{
		case ID_GRID_ITEM_CHART_SERIES:
			{
				CXTPPropertyGridItemOption* pItemOption  = (CXTPPropertyGridItemOption*)pItem;
				CXTPPropertyGridItemConstraints* pList = pItemOption->GetConstraints();
				int val = pItemOption->GetOption();
				int idx = pActivepChartView->GetSeriesCount();
				for (int i=0; i<idx; i++)
					pActivepChartView->ShowSeries(i, val & pList->GetConstraintAt(i)->m_dwData);
			}
			break;
		case ID_GRID_ITEM_CHART_LABELORROTATED:
			{
				CXTPPropertyGridItemOption* pItemOption  = (CXTPPropertyGridItemOption*)pItem;
				CXTPPropertyGridItemConstraints* pList = pItemOption->GetConstraints();
				int val = pItemOption->GetOption();
				pActivepChartView->ShowLabels(val & pList->GetConstraintAt(0)->m_dwData);
				pActivepChartView->SetRotated(val & pList->GetConstraintAt(1)->m_dwData);
			}
			break;
		case ID_GRID_ITEM_CHART_LABEL_POSITION:
			{
				CXTPPropertyGridItemConstraints* pList = pItem->GetConstraints();
				int idx = pList->GetCurrent();
				if(idx >= 0)
				{
					int val = pList->GetConstraintAt(idx)->m_dwData;
					pActivepChartView->SetLabelPosition(val);
				}
			}
			break;
		case ID_GRID_ITEM_CHART_SERIESGROUP:
			{
				CXTPPropertyGridItemOption* pItemOption  = (CXTPPropertyGridItemOption*)pItem;
				int val = pItemOption->GetOption();
				pActivepChartView->SetChartGroup(val);
			}
			break;
		case ID_GRID_ITEM_CHART_LABELORMARK:
			{
				CXTPPropertyGridItemOption* pItemOption  = (CXTPPropertyGridItemOption*)pItem;
				CXTPPropertyGridItemConstraints* pList = pItemOption->GetConstraints();
				int val = pItemOption->GetOption();
				pActivepChartView->ShowLabels(val & pList->GetConstraintAt(0)->m_dwData);
				if(m_nActiveChartStyle != ID_CHART_STYLE_PIE)
					pActivepChartView->ShowMarkers(val & pList->GetConstraintAt(1)->m_dwData);
			}
			break;
		case ID_GRID_ITEM_CHART_MARKER_TYPE:
			{
				int idx = pItem->GetConstraints()->GetCurrent();
				if(idx >= 0) pActivepChartView->SetMarkerType(idx);
			}
			break;
		case ID_GRID_ITEM_CHART_MARKER_SIZE:
			{
				CXTPPropertyGridItemConstraints* pList = pItem->GetConstraints();
				int idx = pList->GetCurrent();
				if(idx >= 0)
				{
					int val = pList->GetConstraintAt(idx)->m_dwData;
					pActivepChartView->SetMarkerSize(val);
				}
			}
			break;
		case ID_GRID_ITEM_CHART_MARKER_ANGLE:
			{
				CXTPPropertyGridItemConstraints* pList = pItem->GetConstraints();
				int idx = pList->GetCurrent();
				if(idx >= 0)
				{
					int val = pList->GetConstraintAt(idx)->m_dwData;
					pActivepChartView->SetScatterAngle(val);
				}
			}
			break;
		case ID_GRID_ITEM_CHART_MARKER_INVERT:
			{
				CXTPPropertyGridItemOption* pItemOption  = (CXTPPropertyGridItemOption*)pItem;
				CXTPPropertyGridItemConstraints* pList = pItem->GetConstraints();
				int val = pItemOption->GetOption();
				pActivepChartView->SetInvertedStep(val & pList->GetConstraintAt(0)->m_dwData);
			}
			break;
		case ID_GRID_ITEM_CHART_BUBBLE_MIN:
			{
				CXTPPropertyGridItemDouble* pItemMin  = (CXTPPropertyGridItemDouble*)pItem;
				CXTPPropertyGridItemDouble* pItemMax  = (CXTPPropertyGridItemDouble*)m_wndPropertyGrid.FindItem(ID_GRID_ITEM_CHART_BUBBLE_MAX);
				pActivepChartView->SetBubbleSize(pItemMin->GetDouble(), pItemMax->GetDouble());
			}
			break;
		case ID_GRID_ITEM_CHART_BUBBLE_MAX:
			{
				CXTPPropertyGridItemDouble* pItemMin  = (CXTPPropertyGridItemDouble*)m_wndPropertyGrid.FindItem(ID_GRID_ITEM_CHART_BUBBLE_MIN);
				CXTPPropertyGridItemDouble* pItemMax  = (CXTPPropertyGridItemDouble*)pItem;
				pActivepChartView->SetBubbleSize(pItemMin->GetDouble(), pItemMax->GetDouble());
			}
			break;
		case ID_GRID_ITEM_CHART_BUBBLE_TRANPARENCY:
			{
				CXTPPropertyGridItemConstraints* pList = pItem->GetConstraints();
				int idx = pList->GetCurrent();
				if(idx >= 0)
				{
					int val = pList->GetConstraintAt(idx)->m_dwData;
					pActivepChartView->SetBubbleTransparency(val);
				}
			}
			break;
		case ID_GRID_ITEM_CHART_INTERLACED:
			{
				CXTPPropertyGridItemOption* pItemOption  = (CXTPPropertyGridItemOption*)pItem;
				CXTPPropertyGridItemConstraints* pList = pItem->GetConstraints();
				int val = pItemOption->GetOption();
				pActivepChartView->SetInterlaced(val & pList->GetConstraintAt(0)->m_dwData);
				pActivepChartView->SetAntialiased(val & pList->GetConstraintAt(1)->m_dwData);
			}
			break;
		case ID_GRID_ITEM_CHART_INTERVAL:
			{
				CXTPPropertyGridItemConstraints* pList = pItem->GetConstraints();
				int idx = pList->GetCurrent();
				int interval = 0;
				if(idx >= 0)
				{
					interval = pList->GetConstraintAt(idx)->m_dwData;
					pActivepChartView->SetInterval(interval);
				}
			}
			break;
			break;
		case ID_GRID_ITEM_CHART_INTERVALSTEP:
			{
				CXTPPropertyGridItemNumber* pItemNum  = (CXTPPropertyGridItemNumber*)pItem;
				pActivepChartView->GoIntervalStep(pItemNum->GetNumber());
			}
			break;
		case ID_GRID_ITEM_CHART_EXPLODED_POINTS:
			{
				int idx = pItem->GetConstraints()->GetCurrent();
				if(idx >= 0) pActivepChartView->SetnExplodedPoints(idx);
			}
			break;
		case ID_GRID_ITEM_CHART_DOUGHNUT:
			{
				CXTPPropertyGridItemConstraints* pList = pItem->GetConstraints();
				int idx = pList->GetCurrent();
				if(idx >= 0)
				{
					int val = pList->GetConstraintAt(idx)->m_dwData;
					pActivepChartView->SetDoughnut(val);
				}
			}
			break;
		}
	}
}

LRESULT CPaneProperties::OnGridNotify(WPARAM wParam, LPARAM lParam)
{
	if (wParam == XTP_PGN_INPLACEBUTTONDOWN)
	{
		CXTPPropertyGridInplaceButton* pButton = (CXTPPropertyGridInplaceButton*)lParam;
		CXTPPropertyGridItem* pItem = pButton->GetItem();

		switch (pItem->GetID())
		{
		case ID_GRID_ITEM_ACTION_ID:
			if (m_pActiveObject && m_pActiveObject->IsKindOf(RUNTIME_CLASS(CXTPReportRecord)))
			{

			}
		}
	}
	else if (wParam == XTP_PGN_VERB_CLICK)
	{
		CXTPPropertyGridVerb* pVerb = (CXTPPropertyGridVerb*)lParam;
		if (pVerb->GetID() == 0)
		{
			if (AfxMessageBox(_T("Are you sure you want to enable Actions? It will modify all controls that were created"), MB_YESNO) != IDYES)
				return TRUE;
		}

		return TRUE;
	}
	else if (wParam == XTP_PGN_ITEMVALUE_CHANGED)
	{
		CXTPPropertyGridItem* pItem = (CXTPPropertyGridItem*)lParam;
		if (m_pActiveObject && pItem)
		{
			if (m_pActivePane)
			{
				return m_pActivePane->OnPropertyGridValueChanged(m_pActiveObject, pItem);
			}
			else
			{
				if(m_pActiveObject != NULL)
				{
					if (m_pActiveObject->IsKindOf(RUNTIME_CLASS(CReportRecordView)))
						OnPropertyReportValueChanged(pItem);
					else if (m_pActiveObject->IsKindOf(RUNTIME_CLASS(CChartView)))
						OnPropertyChartValueChanged(pItem);
				}
				return TRUE;
			}
		}
	}

	return 0;
}

void CPaneProperties::OnPanePropertiesCategorized()
{
	m_wndPropertyGrid.SetPropertySort(xtpGridSortCategorized);
}

void CPaneProperties::OnUpdatePanePropertiesCategorized(CCmdUI* pCmdUI)
{
	pCmdUI->SetCheck(m_wndPropertyGrid.GetPropertySort() == xtpGridSortCategorized);
}

void CPaneProperties::OnPanePropertiesAlphabetic()
{
	m_wndPropertyGrid.SetPropertySort(xtpGridSortAlphabetical);
}

void CPaneProperties::OnUpdatePanePropertiesAlphabetic(CCmdUI* pCmdUI)
{
	pCmdUI->SetCheck(m_wndPropertyGrid.GetPropertySort() == xtpGridSortAlphabetical);
}

void CPaneProperties::OnPanePropertiesPages()
{
	if(m_pActiveObject != NULL)
	{
		if (m_pActiveObject->IsKindOf(RUNTIME_CLASS(CReportRecordView)))
			RefreshReportProperties();
		else if (m_pActiveObject->IsKindOf(RUNTIME_CLASS(CChartView)))
			RefreshChartProperties();
	}
}

void CPaneProperties::OnUpdatePanePropertiesPages(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(m_pActiveObject != NULL);
}
