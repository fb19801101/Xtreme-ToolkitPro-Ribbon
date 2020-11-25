// RibbonReportView.cpp : implementation of the CRibbonReportView class
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

#include "RibbonReportDoc.h"
#include "RibbonReportView.h"
#include "ChartView.h"

#include "Ribbon/GalleryItems.h"
#include "Explorer/ShellTreeView.h"
#include "Explorer/ShellListView.h"
#include "Explorer/SearchView.h"
#include "Report/ReportGeneratorView.h"


#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


/////////////////////////////////////////////////////////////////////////////
// CRibbonReportView

IMPLEMENT_DYNCREATE(CRibbonReportView, CReportRecordView)

BEGIN_MESSAGE_MAP(CRibbonReportView, CReportRecordView)
	//{{AFX_MSG_MAP(CRibbonReportView)
	//}}AFX_MSG_MAP
	ON_COMMAND_RANGE(ID_REPORT_SET_EDITABLE, ID_POINTSMGR_LEDGER, OnReportSetCommand)
	ON_COMMAND_RANGE(ID_COSTMGR_DAT, ID_COSTMGR_ALL, OnCostManagerCommand)
	ON_COMMAND_RANGE(ID_MATERMGR_STOCK, ID_MATERMGR_CHECK, OnMaterManagerCommand)
	ON_COMMAND_RANGE(ID_FINANCEMGR_MGE, ID_FINANCEMGR_RATE, OnFinanceManagerCommand)
	ON_COMMAND_RANGE(ID_CRTSMGR_SLAB_DAT, ID_CRTSMGR_RAIL_RATE, OnOrbitalManagerCommand)
	ON_COMMAND_RANGE(ID_PROBLEMMGR_DAT, ID_PROBLEMMGR_CRT, OnProblemManagerCommand)
	ON_COMMAND_RANGE(ID_BUDGETMGR_REPLACE, ID_STEELMGR_PROCESS, OnPullWorkManagerCommand)
	ON_COMMAND_RANGE(IDR_PANE_PROPERTIES, IDR_PANE_BUDGET, OnPaneShowhideCommand)
	ON_UPDATE_COMMAND_UI_RANGE(IDR_PANE_PROPERTIES, IDR_PANE_BUDGET, OnUpdatePaneShowhideCommand)

	//}}AFX_MSG_MAP
	ON_WM_RBUTTONUP()
	ON_WM_LBUTTONUP()
	ON_WM_LBUTTONDOWN()

	ON_UPDATE_COMMAND_UI(XTP_ID_RIBBONCONTROLTAB, OnUpdateRibbonTab)

	//}}AFX_MSG_MAP
	// Standard printing commands

	ON_COMMAND_RANGE(ID_GROUP_FONT_OPTION, ID_GROUP_MODIFY_OPTION, OnGroupOptionCommand)
	ON_UPDATE_COMMAND_UI_RANGE(ID_GROUP_FONT_OPTION, ID_GROUP_MODIFY_OPTION, OnUpdateGroupOptionCommand)


	ON_COMMAND(ID_EDIT_FORMAT_PAINTER, OnEditFormatPainter)
	ON_XTP_EXECUTE(ID_EDIT_UNDO, OnEditUndo)
	ON_XTP_EXECUTE(ID_EDIT_REDO, OnEditRedo)
	ON_UPDATE_COMMAND_UI(ID_EDIT_FORMAT_PAINTER, OnUpdateEditFormatPainter)
	ON_UPDATE_COMMAND_UI(ID_EDIT_UNDO, OnUpdateEditUndo)
	ON_UPDATE_COMMAND_UI(ID_EDIT_REDO, OnUpdateEditRedo)

	ON_COMMAND_RANGE(ID_FONT_GROW, ID_FONT_CHARFIELD, OnFontCommand)
	ON_COMMAND_RANGE(ID_UNDERLINE_SINGLE, ID_UNDERLINE_DOUBLE, OnFontUnderlineCommand)
	ON_COMMAND_RANGE(ID_BORDERS_DOWN, ID_BORDERS_MIDHV, OnFontBordersCommand)
	ON_COMMAND_RANGE(ID_CHARFIELD_SHOW, ID_CHARFIELD_MODIFY, OnFontCharfieldCommand)
	ON_UPDATE_COMMAND_UI_RANGE(ID_FONT_GROW, ID_FONT_CHARFIELD, OnUpdateFontCommand)
	ON_UPDATE_COMMAND_UI_RANGE(ID_UNDERLINE_SINGLE, ID_UNDERLINE_DOUBLE, OnUpdateFontUnderlineCommand)
	ON_UPDATE_COMMAND_UI_RANGE(ID_BORDERS_DOWN, ID_BORDERS_MIDHV, OnUpdateFontBordersCommand)
	ON_UPDATE_COMMAND_UI_RANGE(ID_CHARFIELD_SHOW, ID_CHARFIELD_MODIFY, OnUpdateFontCharfieldCommand)

	ON_COMMAND(ID_FONT_BACKCOLOR, OnBtnFontBackColor)
	ON_XTP_EXECUTE(ID_GALLERY_FONT_BACKCOLOR, OnGalleryFontBackColor)
	ON_COMMAND(ID_FONT_NOBACKCOLOR, OnFontBackNoColors)
	ON_UPDATE_COMMAND_UI(ID_FONT_BACKCOLOR, OnUpdateBtnFontBackColor)
	ON_UPDATE_COMMAND_UI(ID_GALLERY_FONT_BACKCOLOR, OnUpdateGalleryFontBackColor)	
	ON_UPDATE_COMMAND_UI(ID_FONT_NOBACKCOLOR, OnUpdateFontBackNoColors)

	ON_XTP_EXECUTE(ID_FONT_SIZE, OnEditFontSize)
	ON_XTP_EXECUTE(ID_FONT_FACE, OnEditFontFace)
	ON_COMMAND(ID_FONT_OTHER, OnFontOther)
	ON_UPDATE_COMMAND_UI(ID_FONT_SIZE, OnUpdateFontSize)
	ON_UPDATE_COMMAND_UI(ID_FONT_FACE, OnUpdateFontFace)
	ON_UPDATE_COMMAND_UI(ID_FONT_OTHER, OnUpdateFontOther)
	ON_UPDATE_COMMAND_UI(ID_GALLERY_FONT_SIZE, OnUpdateGalleryFontSize)	
	ON_UPDATE_COMMAND_UI(ID_GALLERY_FONT_FACE, OnUpdateGalleryFontFace)	

	ON_COMMAND(ID_FONT_FACECOLOR, OnBtnFontFaceColor)
	ON_XTP_EXECUTE(ID_GALLERY_FONT_FACECOLOR, OnGalleryFontFaceColor)
	ON_COMMAND(XTP_IDS_AUTOMATIC, OnFontFaceAutoColor)
	ON_COMMAND(XTP_IDS_MORE_COLORS, OnFontFaceOtherColor)
	ON_UPDATE_COMMAND_UI(ID_FONT_FACECOLOR, OnUpdateBtnFontFaceColor)
	ON_UPDATE_COMMAND_UI(ID_GALLERY_FONT_FACECOLOR, OnUpdateGalleryFontFaceColor)
	ON_UPDATE_COMMAND_UI(XTP_IDS_AUTOMATIC, OnUpdateFontFaceAutoColor)
	ON_UPDATE_COMMAND_UI(XTP_IDS_AUTOMATIC, OnUpdateFontFaceOtherColor)

	ON_COMMAND_RANGE(ID_ALIGNMENT_UP, ID_ALIGNMENT_MERGE, OnAlignmentCommand)
	ON_COMMAND_RANGE(ID_DIRECT_DECLOCKWISE, ID_DIRECT_CELLALIGNMENT, OnAlignmentDirect)
	ON_COMMAND_RANGE(ID_MERGE_CENTER, ID_MERGE_UNDO, OnAlignmentMerge)
	ON_UPDATE_COMMAND_UI_RANGE(ID_ALIGNMENT_UP, ID_ALIGNMENT_MERGE, OnUpdateAlignmentCommand)
	ON_UPDATE_COMMAND_UI_RANGE(ID_DIRECT_DECLOCKWISE, ID_DIRECT_CELLALIGNMENT, OnUpdateAlignmentDirect)
	ON_UPDATE_COMMAND_UI_RANGE(ID_MERGE_CENTER, ID_MERGE_UNDO, OnUpdateAlignmentMerge)

	ON_XTP_EXECUTE(ID_NUMBER_FORMAT, OnEditNumberFormat)
	ON_COMMAND(ID_NRFMT_OTHER, OnNumberFormatOther)
	ON_COMMAND_RANGE(ID_NUMBER_ACCOUNTANT, ID_NUMBER_ENPRECISION, OnNumberCommand)
	ON_COMMAND_RANGE(ID_ACCOUNTANT_CHINESE, ID_ACCOUNTANT_OTHER, OnNumberAccountant)
	ON_UPDATE_COMMAND_UI(ID_NUMBER_FORMAT, OnUpdateNumberFormat)
	ON_UPDATE_COMMAND_UI(ID_GALLERY_NUMBER, OnUpdateGalleryNumber)
	ON_UPDATE_COMMAND_UI(ID_NRFMT_OTHER, OnUpdateNumberFormatOther)
	ON_UPDATE_COMMAND_UI_RANGE(ID_NUMBER_ACCOUNTANT, ID_NUMBER_ENPRECISION, OnUpdateNumberCommand)
	ON_UPDATE_COMMAND_UI_RANGE(ID_ACCOUNTANT_CHINESE, ID_ACCOUNTANT_OTHER, OnUpdateNumberAccountant)


	ON_COMMAND_RANGE(ID_STYLES_CONDITION, ID_STYLES_CELL, OnStylesCommand)
	ON_COMMAND_RANGE(ID_CONDITION_HIGHLIGHT, ID_CONDITION_ICONLIST, OnCondition)
	ON_COMMAND_RANGE(ID_CONDITION_LARGE, ID_CONDITION_OTHERICON, OnConditionCommand)
	ON_COMMAND_RANGE(ID_STYLEFMT_SAVESTYLE, ID_STYLEFMT_APPLYSTYLE, OnStyleFormat)
	ON_COMMAND_RANGE(ID_STYLECELL_NEW, ID_STYLECELL_MERGE, OnStyleCell)
	ON_XTP_EXECUTE(ID_GALLERY_CONDITION_HIGHLIGHT, OnGalleryConditionHighlight)
	ON_XTP_EXECUTE(ID_GALLERY_CONDITION_ITEMSELECT, OnGalleryConditionItemselect)
	ON_XTP_EXECUTE(ID_GALLERY_CONDITION_DATABARS, OnGalleryConditionDatabars)
	ON_XTP_EXECUTE(ID_GALLERY_CONDITION_CLRVALEUR, OnGalleryConditionClrValeur)
	ON_XTP_EXECUTE(ID_GALLERY_CONDITION_ICONLIST, OnGalleryConditionIconlist)
	ON_XTP_EXECUTE(ID_GALLERY_STYLES_FORMAT, OnGalleryStylesFormat)
	ON_XTP_EXECUTE(ID_GALLERY_STYLES_CELL,  OnGalleryStylesCell)
	ON_UPDATE_COMMAND_UI_RANGE(ID_STYLES_CONDITION, ID_STYLES_CELL, OnUpdateStylesCommand)
	ON_UPDATE_COMMAND_UI_RANGE(ID_CONDITION_HIGHLIGHT, ID_CONDITION_ICONLIST, OnUpdateCondition)
	ON_UPDATE_COMMAND_UI_RANGE(ID_CONDITION_LARGE, ID_CONDITION_OTHERICON, OnUpdateConditionCommand)
	ON_UPDATE_COMMAND_UI_RANGE(ID_STYLEFMT_SAVESTYLE, ID_STYLEFMT_APPLYSTYLE, OnUpdateStyleFormat)
	ON_UPDATE_COMMAND_UI_RANGE(ID_STYLECELL_NEW, ID_STYLECELL_MERGE, OnUpdateStyleCell)
	ON_UPDATE_COMMAND_UI(ID_GALLERY_CONDITION_HIGHLIGHT, OnUpdateGalleryConditionHighlight)
	ON_UPDATE_COMMAND_UI(ID_GALLERY_CONDITION_ITEMSELECT, OnUpdateGalleryConditionItemselect)
	ON_UPDATE_COMMAND_UI(ID_GALLERY_CONDITION_DATABARS, OnUpdateGalleryConditionDatabars)
	ON_UPDATE_COMMAND_UI(ID_GALLERY_CONDITION_CLRVALEUR, OnUpdateGalleryConditionClrValeur)
	ON_UPDATE_COMMAND_UI(ID_GALLERY_CONDITION_ICONLIST, OnUpdateGalleryConditionIconlist)
	ON_UPDATE_COMMAND_UI(ID_GALLERY_STYLES_FORMAT, OnUpdateGalleryStylesFormat)
	ON_UPDATE_COMMAND_UI(ID_GALLERY_STYLES_CELL, OnUpdateGalleryStylesCell)


	ON_COMMAND_RANGE(ID_CELL_INSERT, ID_CELL_FORMAT, OnCellCommand)
	ON_COMMAND_RANGE(ID_INSERT_CELL, ID_INSERT_TABLE, OnCellInsert)
	ON_COMMAND_RANGE(ID_DELETE_CELL, ID_DELETE_TABLE, OnCellDelete)
	ON_COMMAND_RANGE(ID_FORMAT_ROWHIGHT, ID_FORMAT_MODIFY, OnCellFormat)
	ON_UPDATE_COMMAND_UI_RANGE(ID_CELL_INSERT, ID_CELL_FORMAT, OnUpdateCellCommand)
	ON_UPDATE_COMMAND_UI_RANGE(ID_INSERT_CELL, ID_INSERT_TABLE, OnUpdateCellInsert)
	ON_UPDATE_COMMAND_UI_RANGE(ID_DELETE_CELL, ID_DELETE_TABLE, OnUpdateCellDelete)
	ON_UPDATE_COMMAND_UI_RANGE(ID_FORMAT_ROWHIGHT, ID_FORMAT_MODIFY, OnUpdateCellFormat)

	ON_COMMAND_RANGE(ID_MODIFY_SUM, ID_MODIFY_FINDSELECT, OnModifyCommand)
	ON_COMMAND_RANGE(ID_SUM_SUM, ID_SUM_FUNCTION, OnModifySum)
	ON_COMMAND_RANGE(ID_FILL_DOWN, ID_FILL_FULLJUST, OnModifyFill)
	ON_COMMAND_RANGE(ID_CLEAR_ALL, ID_CLEAR_REMARK, OnModifyClear)
	ON_COMMAND_RANGE(ID_SORTFILTER_ASCE, ID_SORTFILTER_REAPPLY, OnModifySortFilter)
	ON_COMMAND_RANGE(ID_FINDSELECT_FIND, ID_FINDSELECT_SELWINDOW, OnModifyFindSelect)
	ON_UPDATE_COMMAND_UI_RANGE(ID_MODIFY_SUM, ID_MODIFY_FINDSELECT, OnUpdateModifyCommand)
	ON_UPDATE_COMMAND_UI_RANGE(ID_SUM_SUM, ID_SUM_FUNCTION, OnUpdateModifySum)
	ON_UPDATE_COMMAND_UI_RANGE(ID_FILL_DOWN, ID_FILL_FULLJUST, OnUpdateModifyFill)
	ON_UPDATE_COMMAND_UI_RANGE(ID_CLEAR_ALL, ID_CLEAR_REMARK, OnUpdateModifyClear)
	ON_UPDATE_COMMAND_UI_RANGE(ID_SORTFILTER_ASCE, ID_SORTFILTER_REAPPLY, OnUpdateModifySortFilter)
	ON_UPDATE_COMMAND_UI_RANGE(ID_FINDSELECT_FIND, ID_FINDSELECT_SELWINDOW, OnUpdateModifyFindSelect)

END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CRibbonReportView construction/destruction

CRibbonReportView::CRibbonReportView()
{
	m_clrFace = RGB(0,0,0);
	m_clrBack = RGB(255,255,255);
	m_nNumberFormat = 0;
	m_strNumberFormat = _T("常规");

	m_idReportSetCmd=m_idCostManagerCmd=m_idBudgetManagerCmd=m_idMaterManagerCmd=m_idFinanceManagerCmd=m_idOrbitalManagerCmd=m_idProblemManagerCmd=-1;
	m_idGroupOptionCmd=-1;
	m_idFontCmd=m_idFontUnderline=m_idFontBorders=FontCharfield=-1;
	m_idFaceColor=m_idBackColor=m_idGalleryFontFaceColor=m_idGalleryFontBackColor=-1;
	m_idFontFace=m_idFontSize=m_idGalleryFontSize=m_idGalleryFontFace=-1;
	m_idAlignmentCmd=m_idAlignmentDirect=m_idAlignmentMerge=-1;
	m_idNumberCmd=m_idNumberAccountant=m_idGalleryNumber=-1;
	m_idGalleryHighLight=m_idGalleryItemSelect=m_idGalleryDataBars=m_idGalleryClrValeur=m_idGalleryIconList=-1;
	m_idStylesCmd=m_idCondition=m_idConditionCmd=m_idStyleFormat=m_idStylesCell=-1;
	m_idCellCmd=m_idCellInsert=m_idCellDelete=m_idCellFormat=-1;
	m_idModifyCmd=m_idModifySum=m_idModifyFill=m_idModifyClear=m_idModifySortFilter=m_idModifyFindSelect=-1;
}

CRibbonReportView::~CRibbonReportView()
{

}

BOOL CRibbonReportView::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	cs.style |= WS_EX_CONTROLPARENT;

	return CReportRecordView::PreCreateWindow(cs);
}

/////////////////////////////////////////////////////////////////////////////
// CRibbonReportView diagnostics

#ifdef _DEBUG
void CRibbonReportView::AssertValid() const
{
	CReportRecordView::AssertValid();
}

void CRibbonReportView::Dump(CDumpContext& dc) const
{
	CReportRecordView::Dump(dc);
}

#endif //_DEBUG


/////////////////////////////////////////////////////////////////////////////
// CRibbonReportView message handlers

void CRibbonReportView::OnInitialUpdate()
{
	CReportRecordView::OnInitialUpdate();
}

void CRibbonReportView::OnReportSetCommand(UINT nID)
{
	switch (nID)
	{
	case ID_REPORT_SET_EDITABLE:
		AllowEdit(!IsAllowEdit());
		AllowHeaderEdit(!IsAllowEdit());
		break;
	case ID_REPORT_SET_ROWHEAD:
		ShowHeaderRows(!IsShowHeaderRows());
		break;
	case ID_REPORT_SET_ROWFOOT:
		ShowFooterRows(!IsShowFooterRows());
		break;
	case ID_REPORT_SET_BACKUP:
		{
			if(GetType() > -1)
			{
				if(CopyTable(GetTable(), GetBackup()))
				{
					msgInf(GetBackup()+_T(" 表备份成功！"));
				}
				else
				{
					msgWrg(GetBackup()+_T(" 表备份失败！"));
				}
			}
		}
		break;
	case ID_REPORT_SET_RESTORE:
		{
			if(ExistsTable(GetBackup()))
			{
				if(CopyTable(GetBackup(),GetTable()))
				{
					msgInf(GetBackup()+_T(" 表恢复成功！"));
				}
				else
				{
					msgWrg(GetBackup()+_T(" 表恢复失败！"));
				}
			}
			else msgWrg(_T("表备份不存在！"));
		}
		break;
	case ID_REPORT_SET_DROP:
		DropTable(GetBackup());
		msgInf(GetBackup()+_T("表删除成功！"));
		break;
	case ID_REPORT_SET_SUBLIST:
		ShowFieldSubList();
		break;
	case ID_REPORT_SET_FILTEREDIT:
		ShowFilterEdit();
		break;
	case ID_REPORT_SET_FILTERCLEAR:
		m_wndFilterEdit.SetText(_T(""));
		break;
	case ID_REPORT_MODIFY_ADD:
		AddRcdToRst();
		break;
	case ID_REPORT_MODIFY_SET:
		SetRcdToRst();
		break;
	case ID_REPORT_MODIFY_DEL:
		DelRcdOfRst();
		break;
	case ID_REPORT_GENERATOR:
		{
			CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
			if(pMaainFrame->IsActiveView((CView*)this))
			{
				pMaainFrame->SetReportGeneratorView();
				if(!pMaainFrame->m_pReportGeneratorView) return;
				pMaainFrame->m_pReportGeneratorView->LoadReportFile();
			}
			else
				pMaainFrame->SetRibbonReportView();
		}
		break;
	case ID_POINTSMGR_POINTS:
		SetView(_T("tv_points"));
		DataBindRecordset();
		break;
	case ID_POINTSMGR_LEDGER:
		SetView(_T("tv_ledger"));
		DataBindRecordset();
		break;
	}
}

void CRibbonReportView::OnCostManagerCommand(UINT nID)
{
	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
	switch (nID)
	{
	case ID_COSTMGR_DAT:
		{
			if(!pMaainFrame->m_pPopupPoints) return;
			CString* tag = (CString*)(DWORD_PTR)pMaainFrame->m_pPopupPoints->GetTag();
			if(!tag) return;
			CString strPreview = _T("tp") + *tag;
			if(!pMaainFrame->m_pPopupCost) return;
			tag = (CString*)(DWORD_PTR)pMaainFrame->m_pPopupCost->GetTag();
			if(!tag) return;
			strPreview += *tag;
			SetPreview(strPreview);
		}
		break;
	case ID_COSTMGR_SUM:
		{
			if(!pMaainFrame->m_pPopupPoints) return;
			CString* tag = (CString*)(DWORD_PTR)pMaainFrame->m_pPopupPoints->GetTag();
			if(!tag) return;
			CString strPreview = _T("tp") + *tag;
			CString strTable = _T("tb") + *tag;
			if(!pMaainFrame->m_pPopupCost) return;
			tag = (CString*)(DWORD_PTR)pMaainFrame->m_pPopupCost->GetTag();
			if(!tag) return;
			strPreview = strPreview + *tag  + _T("_sum");
			strTable += *tag;
			SetPreview(strPreview);
			SetTable(strTable,FALSE);
		}
		break;
	case ID_COSTMGR_ALL:
		{
			if(!pMaainFrame->m_pPopupPoints) return;
			CString* tag = (CString*)(DWORD_PTR)pMaainFrame->m_pPopupPoints->GetTag();
			if(!tag) return;
			CString strPreview = _T("tp") + *tag;
			CString strTable = _T("tb") + *tag;
			if(!pMaainFrame->m_pPopupCost) return;
			tag = (CString*)(DWORD_PTR)pMaainFrame->m_pPopupCost->GetTag();
			if(!tag) return;
			strPreview = strPreview + *tag  + _T("_all");
			strTable += *tag;
			SetPreview(strPreview);
			SetTable(strTable,FALSE);
		}
		break;
	}

	if(pMaainFrame->m_pSearchDatapart && pMaainFrame->m_pItemsSearchdatapart)
	{
		int idx = pMaainFrame->m_pSearchDatapart->GetCurSel();
		if(idx > -1)
		{
			CXTPControlGalleryItem* pCalleryItem = pMaainFrame->m_pItemsSearchdatapart->GetItem(idx);
			if(pCalleryItem)
			{
				CString* tag = (CString*)(DWORD_PTR)pCalleryItem->GetData();
				CString sql;

				if(nID == ID_COSTMGR_DAT)
					sql.Format(_T("where 工点编号='%s'"),*tag);

				//m_pRibbonReportView->m_wndFilterEdit.SetText(*tag);

				CString table = GetCurTable();
				DataBindRecordset(GetRecordset(table,_T(""),sql));
				SetRecordItemEditable();
			}
		}
	}
}

void CRibbonReportView::OnMaterManagerCommand(UINT nID)
{
	switch (nID)
	{
	case ID_MATERMGR_STOCK:
		{
			SetView(_T("tv_stock"));
			DataBindRecordset();
			SetRecordItemControl(1, XTP_REPORT_ITEM_CTRL_LINK, _T("tv_barn"));
			SetRecordItemControl(2, XTP_REPORT_ITEM_CTRL_LINK, _T("tv_goods"));
			int col[] = {3,4,5,6,7,8,9,11,12,13,14,15,16,17,18};
			xtp_vector<int> cols(col);
			SetRecordItemEditable(cols);
		}
		break;
	case ID_MATERMGR_CHECK:
		SetView(_T("tv_check"));
		DataBindRecordset();
		break;
	}
}

void CRibbonReportView::OnFinanceManagerCommand(UINT nID)
{
	switch (nID)
	{
	case ID_FINANCEMGR_MGE:
		{
			SetView(_T("tv_finance"));
			DataBindRecordset();
			CXTPReportControl& wndReport = GetReportCtrl();
			for(int i=0; i<wndReport.GetColumns()->GetCount(); i++)
				SetRecordItemEditable(i);

			SetGroupsOrder(GetColumns()->GetAt(10));
			for (int i=0; i<GetRows()->GetCount(); i++)
			{
				CXTPReportRow *pRow = GetRows()->GetAt(i);

				if (pRow->IsGroupRow())
				{
					CXTPReportGroupRow *pGroupRow = reinterpret_cast<CXTPReportGroupRow*>(pRow);

					pGroupRow->SetFormatString(_T("合计金额  $= %.2f"));
					pGroupRow->SetFormula(_T("SUMSUB(R*C9:R*C10)"));
					pGroupRow->SetCaption(_T("x"));
				}
			}

			SetColumnVisible(10);
		}
		break;
	case ID_FINANCEMGR_SUM:
		{
			SetPreview(_T("tp_finance"));
			DataBindRecordset();
			SetRecordItemEditable();

			SetGroupsOrder(GetColumns()->GetAt(0));
			SetGroupsOrder(GetColumns()->GetAt(1));
			for (int i=0; i<GetRows()->GetCount(); i++)
			{
				CXTPReportRow *pRow = GetRows()->GetAt(i);

				if (pRow->IsGroupRow())
				{
					CXTPReportGroupRow *pGroupRow = reinterpret_cast<CXTPReportGroupRow*>(pRow);
					
					pGroupRow->GetGroupLevel() == 0 ? pGroupRow->SetFormatString(_T("总计金额  $= %.2f"))
						: pGroupRow->SetFormatString(_T("小计金额  $= %.2f"));
					pGroupRow->SetFormula(_T("SUMSUB(R*C4:R*C5)"));
					pGroupRow->SetCaption(_T("x"));
				}
			}

			SetColumnVisible(0);
		}
		break;
	case ID_FINANCEMGR_RATE:
		ShowFinanceRate(GetSelectedRows());
		break;
	}
}

void CRibbonReportView::OnOrbitalManagerCommand(UINT nID)
{
	switch (nID)
	{
	case ID_CRTSMGR_SLAB_DAT:
		SetView(_T("tv_retest_orbit"));
		DataBindRecordset();
		SetChartViewDataColor(GetRecords());
		break;
	case ID_CRTSMGR_SLAB_SUM:
		SetPreview(_T("tp_retest_orbit_sum"));
		SetTable(_T("tb_retest_orbit"),FALSE);
		DataBindRecordset();
		SetRecordItemEditable();
		SetChartViewSumDataColor(GetRecords());
		break;
	case ID_CRTSMGR_SLAB_ALL:
		SetPreview(_T("tp_retest_orbit_all"));
		SetTable(_T("tb_retest_orbit"),FALSE);
		DataBindRecordset();
		SetRecordItemEditable();
		break;
	case ID_CRTSMGR_SLAB_CNT:
		SetPreview(_T("tp_retest_orbit_cnt"));
		SetTable(_T("tb_retest_orbit"),FALSE);
		DataBindRecordset();
		SetRecordItemEditable();
		break;
	case ID_CRTSMGR_SLAB_HORIZON:
		ShowPlateHorizon(GetSelectedRows());
		break;
	case ID_CRTSMGR_SLAB_VERTICAL:
		ShowPlateVertical(GetSelectedRows());
		break;
	case ID_CRTSMGR_SLAB_MILEAGE:
		ShowPlateMileage(GetSelectedRows());
		break;
	case ID_CRTSMGR_SLAB_RIDE_IN:
		ShowPlateRideIn(GetSelectedRows());
		break;
	case ID_CRTSMGR_SLAB_RIDE_OUT:
		ShowPlateRideOut(GetSelectedRows());
		break;
	case ID_CRTSMGR_SLAB_RATE:
		ShowPlateRate(GetSelectedRows());
		break;
	case ID_CRTSMGR_RAIL_MGE:
		MergePlateData();
		break;
	case ID_CRTSMGR_RAIL_CAL:
		ClacRailData();
		break;
	case ID_CRTSMGR_RAIL_PLATE:
		SetView(_T("tv_retest_plate"));
		DataBindRecordset();
		break;
	case ID_CRTSMGR_RAIL_ADJUST:
		SetView(_T("tv_retest_rail"));
		DataBindRecordset();
		break;
	case ID_CRTSMGR_RAIL_ALL:
		SetPreview(_T("tp_retest_rail"));
		SetTable(_T("tb_retest_rail"),FALSE);
		DataBindRecordset();
		SetRecordItemEditable();
		break;
	case ID_CRTSMGR_RAIL_WFP:
		SetPreview(_T("tp_retest_rail_wfp"));
		SetTable(_T("tb_retest_rail"),FALSE);
		DataBindRecordset();
		SetRecordItemEditable();
		break;
	case ID_CRTSMGR_RAIL_ZW6:
		SetPreview(_T("tp_retest_rail_zw6"));
		SetTable(_T("tb_retest_rail"),FALSE);
		DataBindRecordset();
		SetRecordItemEditable();
		break;
	case ID_CRTSMGR_RAIL_RIDE:
		ShowRailRide(GetSelectedRows());
		break;
	case ID_CRTSMGR_RAIL_RATE:
		ShowRailRate(GetSelectedRows());
		break;
	}
}

void CRibbonReportView::OnProblemManagerCommand(UINT nID)
{
	switch (nID)
	{
	case ID_PROBLEMMGR_DAT:
		SetView(_T("tv_problem"));
		DataBindRecordset();
		SetCheckBoxState(21);
		SetCheckBoxState(22);
		break;
	case ID_PROBLEMMGR_SUM:
		SetTable(_T("tb_problem"),FALSE);
		if(GetView() == _T("tv_problem_road"))
			SetPreview(_T("tp_problem_road"));
		if(GetView() == _T("tv_problem_bridge"))
			SetPreview(_T("tp_problem_bridge"));
		if(GetView() == _T("tv_problem_tunnel"))
			SetPreview(_T("tp_problem_tunnel"));
		if(GetView() == _T("tv_problem_orbital"))
			SetPreview(_T("tp_problem_orbital"));
		if(GetView() == _T("tv_problem_barrier"))
			SetPreview(_T("tp_problem_barrier"));
		if(GetView() == _T("tv_problem_groud"))
			SetPreview(_T("tp_problem_groud"));
		if(GetView() == _T("tv_problem_measure"))
			SetPreview(_T("tp_problem_measure"));
		DataBindRecordset();
		SetRecordItemEditable();
		SetCheckBoxState(21);
		SetCheckBoxState(22);
		break;
	case ID_PROBLEMMGR_ALL:
		SetPreview(_T("tp_problem"));
		SetTable(_T("tb_problem"),FALSE);
		DataBindRecordset();
		SetRecordItemEditable();
		break;
	case ID_PROBLEMMGR_ROAD:
		SetView(_T("tv_problem_road"));
		SetTable(_T("tb_problem"), FALSE);
		DataBindRecordset();
		SetCheckBoxState(21);
		SetCheckBoxState(22);
		break;
	case ID_PROBLEMMGR_BRIDGE:
		SetView(_T("tv_problem_bridge"));
		SetTable(_T("tb_problem"), FALSE);
		DataBindRecordset();
		SetCheckBoxState(21);
		SetCheckBoxState(22);
		break;
	case ID_PROBLEMMGR_TUNNEL:
		SetView(_T("tv_problem_tunnel"));
		SetTable(_T("tb_problem"), FALSE);
		DataBindRecordset();
		SetCheckBoxState(21);
		SetCheckBoxState(22);
		break;
	case ID_PROBLEMMGR_ORBITAL:
		SetView(_T("tv_problem_orbital"));
		SetTable(_T("tb_problem"), FALSE);
		DataBindRecordset();
		SetCheckBoxState(21);
		SetCheckBoxState(22);
		break;
	case ID_PROBLEMMGR_BARRIER:
		SetView(_T("tv_problem_barrier"));
		SetTable(_T("tb_problem"), FALSE);
		DataBindRecordset();
		SetCheckBoxState(21);
		SetCheckBoxState(22);
		break;
	case ID_PROBLEMMGR_GROUD:
		SetView(_T("tv_problem_groud"));
		SetTable(_T("tb_problem"), FALSE);
		DataBindRecordset();
		SetCheckBoxState(21);
		SetCheckBoxState(22);
		break;
	case ID_PROBLEMMGR_MEASURE:
		SetView(_T("tv_problem_measure"));
		SetTable(_T("tb_problem"), FALSE);
		DataBindRecordset();
		SetCheckBoxState(21);
		SetCheckBoxState(22);
		break;
	case ID_PROBLEMMGR_SUM_:
		SetPreview(_T("tp_problem_sum"));
		SetTable(_T("tb_problem"),FALSE);
		DataBindRecordset();
		SetRecordItemEditable();
		break;
	case ID_PROBLEMMGR_ALL_:
		SetPreview(_T("tp_problem_all"));
		SetTable(_T("tb_problem"),FALSE);
		DataBindRecordset();
		SetRecordItemEditable();
		break;
	case ID_PROBLEMMGR_CRT:
		ShowProblemRate(GetSelectedRows());
		break;
	}
}

void CRibbonReportView::OnPullWorkManagerCommand(UINT nID)
{
	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
	switch (nID)
	{
	case ID_BUDGETMGR_REPLACE:
		{
			ExecuteProcedureSql(_T("sp_budget_rep"));
			msgInf(_T("分项概算批量替换成功！"));
		}
		break;
	case ID_BUDGETMGR_QTYSUM:
		{
			ExecuteProcedureSql(_T("sp_quantity_sum"));
			msgInf(_T("工程数量合计成功！"));
		}
		break;
	case ID_BUDGETMGR_BUDGET:
		{
			if(!pMaainFrame->m_pRibbonReportView) return;
			pMaainFrame->m_pRibbonReportView->DataBindRecordset(GetRecordset(_T("tp_budget_sum")));
		}
		break;
	case ID_BUDGETMGR_GUIDANCE:
		{
			if(!pMaainFrame->m_pRibbonReportView) return;
			pMaainFrame->m_pRibbonReportView->DataBindRecordset(GetRecordset(_T("tp_budget")));
		}
		break;
	case ID_STEELMGR_QTY:
		{
			if(!pMaainFrame->m_pRibbonReportView) return;
			pMaainFrame->m_pRibbonReportView->DataBindRecordset(GetRecordset(_T("tp_sys_steel_qty")));
		}
		break;
	case ID_STEELMGR_LIBRARY:
		{
			if(!pMaainFrame->m_pRibbonReportView) return;
			pMaainFrame->m_pRibbonReportView->DataBindRecordset(GetRecordset(_T("tv_sys_steel_library")));
		}
		break;
	case ID_STEELMGR_ORDER:
		{
			if(!pMaainFrame->m_pRibbonReportView) return;
			pMaainFrame->m_pRibbonReportView->DataBindRecordset(GetRecordset(_T("tp_sys_steel_order")));
		}
		break;
	case ID_STEELMGR_PROCESS:
		{
			if(!pMaainFrame->m_pRibbonReportView) return;
			pMaainFrame->m_pRibbonReportView->DataBindRecordset(GetRecordset(_T("tp_sys_steel_process")));
		}
		break;
	}
}

void CRibbonReportView::OnPaneShowhideCommand(UINT nID)
{
	CXTPDockingPaneManager&  wndPaneManager = ((CMainFrame*)AfxGetMainWnd())->m_wndPaneManager;
	CXTPDockingPane* pPane = NULL;

	switch (nID)
	{
	case IDR_PANE_PROPERTIES:
		pPane = wndPaneManager.FindPane(IDR_PANE_PROPERTIES);
		if(pPane && pPane->IsClosed()) pPane->Attach(&((CMainFrame*)AfxGetMainWnd())->m_wndPaneProperties);
		break;
	case IDR_PANE_RIBBON:
		pPane = wndPaneManager.FindPane(IDR_PANE_RIBBON);
		if(pPane && pPane->IsClosed()) pPane->Attach(&((CMainFrame*)AfxGetMainWnd())->m_wndPaneRibbon);
		break;
	case IDR_PANE_PARTITEM:
		pPane = wndPaneManager.FindPane(IDR_PANE_PARTITEM);
		if(pPane && pPane->IsClosed()) pPane->Attach(&((CMainFrame*)AfxGetMainWnd())->m_wndPanePartItem);
		break;
	case IDR_PANE_PARTTYPE:
		pPane = wndPaneManager.FindPane(IDR_PANE_PARTTYPE);
		if(pPane && pPane->IsClosed()) pPane->Attach(&((CMainFrame*)AfxGetMainWnd())->m_wndPaneItemSys);
		break;
	case IDR_PANE_BUDGET:
		pPane = wndPaneManager.FindPane(IDR_PANE_BUDGET);
		if(pPane && pPane->IsClosed()) pPane->Attach(&((CMainFrame*)AfxGetMainWnd())->m_wndPaneBudget);
		break;
	}

	if(pPane && !pPane->IsClosed())
	{
		pPane->IsHidden() ? wndPaneManager.ToggleDocking(pPane):
		wndPaneManager.ToggleAutoHide(pPane);
	}

	if(pPane && pPane->IsClosed())
	{
		wndPaneManager.ShowPane(pPane);
		wndPaneManager.ToggleDocking(pPane);
		wndPaneManager.DockPane(pPane,xtpPaneDockRight);
	}
}

void CRibbonReportView::OnUpdatePaneShowhideCommand(CCmdUI* pCmdUI)
{
	CXTPControl* pControl = CXTPControl::FromUI(pCmdUI);
	pCmdUI->Enable(TRUE);

	if (pControl)
		pCmdUI->SetCheck(pControl->GetPressed());
}

void CRibbonReportView::SetReportRecordValue(CXTPReportSelectedRows* pRows)
{
	for(int i=0; i<pRows->GetCount(); i++)
	{
		CXTPReportRow* pRow = pRows->GetAt(i);
		CXTPReportRecord* pRecord = pRow->GetRecord();
		UpdateRecord(pRecord);
	}
}

void CRibbonReportView::MergePlateData()
{
	CXTPExcelUtil excel;
	excel.InitExcel();
	xtp_vector<xtp_vector<VARIANT>> vecData1,vecData2,vecData3;

	TCHAR szFilter[] = _T("Excel 2003|*.xls|Excel 2007|*.xlsx|CSV文件|*.csv|所有文件|*.*||");
	CFileDialog FileDlg(TRUE, _T("xls"), NULL, OFN_ALLOWMULTISELECT, szFilter, this);
	DWORD MaxFile = 10000; //2562 is the max by default
	FileDlg.m_ofn.nMaxFile = MaxFile;
	XTPCHAR* strFiles = new XTPCHAR[MaxFile];
	FileDlg.m_ofn.lpstrFile = strFiles;
	ZeroMemory(FileDlg.m_ofn.lpstrFile,sizeof(XTPCHAR)* FileDlg.m_ofn.nMaxFile);

	if(IDOK == FileDlg.DoModal())
	{
		POSITION posFile = FileDlg.GetStartPosition();
		while (NULL != posFile)
		{
			xtp_vector<xtp_vector<VARIANT>> vecData;
			CString strFilePath = FileDlg.GetNextPathName(posFile);
			excel.OpenExcel(strFilePath);
			excel.LoadSheet(1);
			long rows = excel.GetRowCount();
			for(long i=0; i<rows; i++)
			{
				if(CString(excel.GetCell(i+7,1).bstrVal).IsEmpty()) break;
				xtp_vector<VARIANT> data;
				for(long j=0; j<10; j++)
					data.push_back(excel.GetCell(i+7,j+1));

				vecData.push_back(data);
				vecData1.push_back(data);
			}

			excel.LoadSheet(2);
			rows = vecData.size();
			for(long i=0; i<rows; i++)
			{
				xtp_vector<VARIANT> data;
				for(long j=0; j<6; j++)
				{
					if(j<3)
						data.push_back(excel.GetCell(i+5,j+4));
					else
						data.push_back(excel.GetCell(i+5,j+6));
				}
				vecData2.push_back(data);
			}

			excel.LoadSheet(3);
			for(long i=0; i<rows; i++)
			{
				if(i>0 && i< rows-1)
				{
					if(i%2==0)
					{
						xtp_vector<VARIANT> data;
						for(long j=0; j<4; j++)
							data.push_back(excel.GetCell(i+4,j+2));
						vecData3.push_back(data);
					}
					else
					{
						xtp_vector<VARIANT> data;
						for(long j=0; j<4; j++)
							data.push_back(excel.GetCell(i+5,j+2));
						vecData3.push_back(data);
					}
				}
				else
				{
					xtp_vector<VARIANT> data;
					for(long j=0; j<4; j++)
						data.push_back(excel.GetCell(i+5,j+2));
					vecData3.push_back(data);
				}
			}

			excel.CloseExcel();
		}

		msgInf(_T("文件数据读取成功!"));
	}

	TCHAR szFilter1[] = _T("Excel 2003|*.xls|Excel 2007|*.xlsx|CSV文件|*.csv|所有文件|*.*||");
	CFileDialog FileDlg1(TRUE, _T("xls"), NULL, 0, szFilter, this);
	if(IDOK == FileDlg1.DoModal())
	{

		CString strFilePath = FileDlg1.GetPathName();
		excel.OpenExcel(strFilePath);
		excel.LoadSheet(1);

		long rows = vecData1.size();
		int cols = vecData1[0].size();
		for(long i=0; i<rows; i++)
		{
			for(long j=0; j<cols; j++)
				excel.SetCell(vecData1[i][j],i+5,j+4);
		}
		cols = vecData2[0].size();
		for(long i=0; i<rows; i++)
		{
			for(long j=0; j<cols; j++)
				excel.SetCell(vecData2[i][j],i+5,j+14);
		}
		cols = vecData3[0].size();
		for(long i=0; i<rows; i++)
		{
			for(long j=0; j<cols; j++)
				excel.SetCell(vecData3[i][j],i+5,j+20);
		}

		excel.Save();
		excel.CloseExcel();

		msgInf(FileDlg1.GetFileName() + " 文件处理成功!");
	}

	excel.ReleaseExcel();
}

void CRibbonReportView::MergePlateDataOledb()
{
	xtp_vector<xtp_vector<VARIANT>> vecData1,vecData2,vecData3;

	TCHAR szFilter[] = _T("Excel 2003|*.xls|Excel 2007|*.xlsx|CSV文件|*.csv|所有文件|*.*||");
	CFileDialog FileDlg(TRUE, _T("xls"), NULL, OFN_ALLOWMULTISELECT, szFilter, this);
	DWORD MaxFile = 10000; //2562 is the max by default
	FileDlg.m_ofn.nMaxFile = MaxFile;
	XTPCHAR* strFiles = new XTPCHAR[MaxFile];
	FileDlg.m_ofn.lpstrFile = strFiles;
	ZeroMemory(FileDlg.m_ofn.lpstrFile,sizeof(XTPCHAR)* FileDlg.m_ofn.nMaxFile);

	if(IDOK == FileDlg.DoModal())
	{
		CXTPADOConnection con;
		con.SetDataDriver(CXTPADOConnection::xtpAdoACEExcel);

		POSITION posFile = FileDlg.GetStartPosition();
		while (NULL != posFile)
		{
			xtp_vector<xtp_vector<VARIANT>> vecData;
			CString strFilePath = FileDlg.GetNextPathName(posFile);
			strFilePath = strFilePath.Mid(0, strFilePath.ReverseFind('\\')+1);
			CString strFileName = FileDlg.GetFileName();
			con.SetDataPath(strFilePath);
			con.SetDataBase(strFileName);
			con.InitConnectionString();

			if(con.Open())
			{
				int idx = 10;
				int cols[] = {1,2,3,4,5,6,7,8,9,10};
				CString fids = con.GetFields(_T("Sheet1"), idx, cols);
				CString sql;
				sql.Format(_T("select %s from 'Sheet1'"), fids);

				CXTPADORecordset rst(theCon);
				rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
				long rs = rst.GetRecordCount();
				int cs = rst.GetFieldCount();
				if(rs*cs > 0)
				{
					_variant_t** val = new _variant_t*[rs];
					for(int i=0;i<rs;i++)
					{
						val[i] = new _variant_t[cs];
						for(int j=0;j<cs;j++) rst.GetFieldValue(j,val[i][j]);
						rst.MoveNext();
					}
				}
				rst.Close();
				con.Close();
			}
		}

		msgInf(_T("文件数据读取成功!"));
	}

	TCHAR szFilter1[] = _T("Excel 2003|*.xls|Excel 2007|*.xlsx|CSV文件|*.csv|所有文件|*.*||");
	CFileDialog FileDlg1(TRUE, _T("xls"), NULL, 0, szFilter, this);
	if(IDOK == FileDlg1.DoModal())
	{
		CString strFilePath = FileDlg1.GetPathName();
		CXTPExcelUtil excel;
		excel.InitExcel();
		excel.OpenExcel(strFilePath);
		excel.LoadSheet(1);

		long rows = vecData1.size();
		int cols = vecData1[0].size();
		for(long i=0; i<rows; i++)
		{
			for(long j=0; j<cols; j++)
				excel.SetCell(vecData1[i][j],i+5,j+4);
		}
		cols = vecData2[0].size();
		for(long i=0; i<rows; i++)
		{
			for(long j=0; j<cols; j++)
				excel.SetCell(vecData2[i][j],i+5,j+14);
		}
		cols = vecData3[0].size();
		for(long i=0; i<rows; i++)
		{
			for(long j=0; j<cols; j++)
				excel.SetCell(vecData3[i][j],i+5,j+20);
		}

		excel.Save();
		excel.CloseExcel();
		excel.ReleaseExcel();

		msgInf(FileDlg1.GetFileName() + " 文件处理成功!");
	}
}

void CRibbonReportView::ClacRailData()
{
	CString sql1,sql2;
	sql1.Format(_T("delete from %stb_retest_rail"), g_TablePrix);
	theCon.Execute(sql1);
	sql1.Format(_T("select * from %stp_retest_rail_calc order by code"), g_TablePrix);
	sql2.Format(_T("select * from %stb_retest_rail order by rr_code"), g_TablePrix);
	CXTPADORecordset rst1(theCon),rst2(theCon);
	rst1.Open(sql1,CXTPADORecordset::xtpAdoRstStoredProc);
	rst2.Open(sql2,CXTPADORecordset::xtpAdoRstStoredProc);
	rst1.MoveFirst();
	int idx = 1;
	while(!rst1.IsEOF())
	{
		CString code,ptcode,mark,rpcode;
		double zm,lq,rq,lh,rh,zm1,zm2,lq1,lq2,rq1,rq2,lh1,lh2,rh1,rh2;
		double dzm,dlq,dlh,drq,drh,dq,dh,ldq,ldh,rdq,rdh;
		int tie;
		rst1.GetFieldValue(1,ptcode);
		rst1.GetFieldValue(2,mark);
		rst1.GetFieldValue(3,zm1);
		rst1.GetFieldValue(5,lq1);
		rst1.GetFieldValue(6,lh1);
		rst1.GetFieldValue(8,rq1);
		rst1.GetFieldValue(9,rh1);
		rst1.GetFieldValue(12,tie);
		rst1.GetFieldValue(13,rpcode);
		rst1.MoveNext();
		rst1.GetFieldValue(3,zm2);
		rst1.GetFieldValue(5,lq2);
		rst1.GetFieldValue(6,lh2);
		rst1.GetFieldValue(8,rq2);
		rst1.GetFieldValue(9,rh2);
		dzm=(zm2-zm1)/(tie/2-3);
		dlq=(lq2-lq1)/(tie/2-3);
		drq=(rq2-rq1)/(tie/2-3);
		dlh=(lh2-lh1)/(tie/2-3);
		drh=(rh2-rh1)/(tie/2-3);
		rst1.MoveNext();
		for(int j=0; j<tie/2; j++)
		{
			rst2.AddNew();
			code.Format(_T("RR%08d"),idx++);
			rst2.SetFieldValue(0,code);
			rst2.SetFieldValue(1,ptcode);
			rst2.SetFieldValue(2,rpcode);
			code.Format(_T("%s_%02d"),mark,2*j+1);
			rst2.SetFieldValue(4,code);
			code.Format(_T("%s_%02d"),mark,2*j+2);
			rst2.SetFieldValue(7,code);

			if(j==0) {zm = zm1-dzm;lq=lq1-dlq;lh=lh1-dlh;rq=rq1-drq;rh=rh1-drh;}
			else if(j==1) {zm = zm1;lq=lq1;lh=lh1;rq=rq1;rh=rh1;}
			else if(j==tie/2-2) {zm = zm2;lq=lq2;lh=lh2;rq=rq2;rh=rh2;}
			else if(j==tie/2-1) {zm = zm2+dzm;lq=lq2+dlq;lh=lh2+dlh;rq=rq2+drq;rh=rh2+drh;}
			else {zm = zm1+dzm*(j-1);lq=lq1+dlq*(j-1);lh=lh1+dlh*(j-1);rq=rq1+drq*(j-1);rh=rh1+drh*(j-1);}

			zm = Round(zm,3);
			lq = Round(lq,1);rq = Round(rq,1);lh = Round(lh,1);rh = Round(rh,1);
			dq = Round(rq-lq,1);dh = Round(rh-lh,1);
			ldq = Round(-1*lq,0);ldh = Bound(abs(lh)-abs(INT(lh)),0,0.5) ? (lh>0?-1:1)*(abs(INT(lh))+0.5) : Round(-1*lh,0);
			rdq = Round(-1*rq,0);rdh = Bound(abs(rh)-abs(INT(rh)),0,0.5) ? (rh>0?-1:1)*(abs(INT(rh))+0.5) : Round(-1*rh,0);
			rst2.SetFieldValue(3,zm);
			rst2.SetFieldValue(5,lq);
			rst2.SetFieldValue(6,lh);
			rst2.SetFieldValue(8,rq);
			rst2.SetFieldValue(9,rh);
			rst2.SetFieldValue(10,dq);
			rst2.SetFieldValue(11,dh);
			rst2.SetFieldValue(12,ldq);
			rst2.SetFieldValue(13,ldh);
			rst2.SetFieldValue(14,rdq);
			rst2.SetFieldValue(15,rdh);
		}
	}
	rst1.Close();
	rst2.Close();

	msgInf(_T("精调数据计算成功!"));
}

void CRibbonReportView::SetChartViewDataColor(CXTPReportRecords* pRecords)
{
	if(pRecords != NULL)
	{
		xtp_vector<int> vecColumn;
		for(int i=9; i<23; i++) vecColumn.push_back(i);
		vecColumn[0] = 5;vecColumn[1] = 6;vecColumn[2] = 9;vecColumn[3] = 10;

		int iRows = pRecords->GetCount();
		for(int i=0; i<iRows; i++)
		{
			CXTPReportRecord* pRecord = pRecords->GetAt(i);
			if(pRecord != NULL)
			{
				for(int j=0; j<vecColumn.size(); j++)
				{
					CXTPReportRecordItem* pItem = pRecord->GetItem(vecColumn[j]);
					if(pItem != NULL)
					{
						double dbl = ((CXTPReportRecordItemVariant*)pItem)->GetValue().dblVal;
						if(j < 4)
						{
							if(dbl >4 || dbl < -4)
								pItem->SetBackgroundColor(RGB(255,0,255));
							else if(dbl >3 || dbl < -3)
								pItem->SetBackgroundColor(RGB(255,0,0));
							else if(dbl >2 || dbl < -2)
								pItem->SetBackgroundColor(RGB(255,255,0));
						}
						else
						{
							if(dbl >3 || dbl < -3)
								pItem->SetBackgroundColor(RGB(255,0,255));
							if(dbl >2 || dbl < -2)
								pItem->SetBackgroundColor(RGB(255,0,0));
							else if(dbl >1 || dbl < -1)
								pItem->SetBackgroundColor(RGB(255,255,0));
						}
					}
				}
			}
		}
	}
}

void CRibbonReportView::SetChartViewSumDataColor(CXTPReportRecords* pRecords)
{
	if(pRecords != NULL)
	{
		xtp_vector<int> vecColumn;
		for(int i=9; i<18; i++) vecColumn.push_back(i);
		vecColumn[0] = 9;vecColumn[1] = 10;vecColumn[2] = 13;vecColumn[3] = 14;vecColumn[4] = 15;vecColumn[5] = 11;vecColumn[6] = 12;
		int iRows = pRecords->GetCount();
		for(int i=0; i<iRows; i++)
		{
			CXTPReportRecord* pRecord = pRecords->GetAt(i);
			if(pRecord != NULL)
			{
				for(int j=0; j<vecColumn.size(); j++)
				{
					CXTPReportRecordItem* pItem = pRecord->GetItem(vecColumn[j]);
					if(pItem != NULL)
					{
						double dbl = ((CXTPReportRecordItemVariant*)pItem)->GetValue().dblVal;
						if(j < 6)
						{
							if(dbl >4 || dbl < -4)
								pItem->SetBackgroundColor(RGB(255,0,255));
							else if(dbl >3 || dbl < -3)
								pItem->SetBackgroundColor(RGB(255,0,0));
							else if(dbl >2 || dbl < -2)
								pItem->SetBackgroundColor(RGB(255,255,0));
						}
						else
						{
							if(dbl >3 || dbl < -3)
								pItem->SetBackgroundColor(RGB(255,0,255));
							if(dbl >2 || dbl < -2)
								pItem->SetBackgroundColor(RGB(255,0,0));
							else if(dbl >1 || dbl < -1)
								pItem->SetBackgroundColor(RGB(255,255,0));
						}
					}
				}
			}
		}
	}
}

void CRibbonReportView::ShowFinanceRate(CXTPReportSelectedRows* pRows)
{
	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();

	xtp_vector<SeriesPoint> vecSeries;
	pMaainFrame->SetChartView();
	if(!pMaainFrame->m_pChartView) return;
	pMaainFrame->m_pChartView->ClearChartSeries();
	CXTPADORecordset rst(theCon);
	CString sql;
	sql.Format(_T("select 收支, 姓名, case when 收支 = '收入' then sum(金额) else 0 end as 收入, case when 收支 = '支出' then sum(金额) else 0 end as 支出 from %stp_finance group by 收支,姓名 order by 姓名"), g_TablePrix);
	rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
	rst.MoveFirst();
	while(!rst.IsEOF())
	{
		CString inout,name;
		double income,outlay;
		rst.GetFieldValue(0,inout);
		rst.GetFieldValue(1,name);
		rst.GetFieldValue(2,income);
		rst.GetFieldValue(3,outlay);
		double gap = income-outlay;
		SeriesPoint sp(income, outlay, gap);
		sp._x = name+_T("_")+inout;
		vecSeries.push_back(sp);
		rst.MoveNext();
	}
	rst.Close();

	pMaainFrame->m_pChartView->AddChartPieSeries(_T("%.0f元"), vecSeries, 0);
	pMaainFrame->m_wndPaneProperties.m_nActiveChartStyle = ID_CHART_STYLE_PIE;
	pMaainFrame->m_pChartView->SetChartTitle(_T("财务收支分布图"),_T(""));
}

void CRibbonReportView::ShowPlateHorizon(CXTPReportSelectedRows* pRows)
{
	if(pRows != NULL)
	{
		int rs = pRows->GetCount();
		if(rs < 2) return;

		CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
		pMaainFrame->SetChartView();
		if(!pMaainFrame->m_pChartView) return;
		pMaainFrame->m_pChartView->ClearChartSeries();

		xtp_vector<SeriesPoint> vecSeries;
		LPCTSTR lpszlabels = _T("线路左轨横向偏差;线路右轨横向偏差;");
		CStringArray arrLabels;
		CreateArray(arrLabels, lpszlabels);
		for(int i=0; i<arrLabels.GetSize(); i++)
		{
			vecSeries.clear();
			for (int j = 0; j < rs; j++)
			{
				CXTPReportRow* pRow = pRows->GetAt(j);
				CXTPReportRecord* pRecord = pRow->GetRecord();
				if(pRecord)
				{
					double mileage = ((CXTPReportRecordItemVariant*)pRecord->GetItem(4))->GetValue().dblVal;
					double dval = ((CXTPReportRecordItemVariant*)pRecord->GetItem(i==0 ? 5:9))->GetValue().dblVal;
					SeriesPoint sp(mileage, dval);
					sp.SetM(mileage);
					vecSeries.push_back(sp);
				}
			}

			pMaainFrame->m_pChartView->AddChartSeries(arrLabels[i], vecSeries, new CXTPChartLineSeriesStyle(),TRUE);
		}
		pMaainFrame->m_wndPaneProperties.m_nActiveChartStyle = ID_CHART_STYLE_LINE;
	}
}

void CRibbonReportView::ShowPlateVertical(CXTPReportSelectedRows* pRows)
{
	if(pRows != NULL)
	{
		int rs = pRows->GetCount();
		if(rs < 2) return;

		CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
		pMaainFrame->SetChartView();
		if(!pMaainFrame->m_pChartView) return;
		pMaainFrame->m_pChartView->ClearChartSeries();

		xtp_vector<SeriesPoint> vecSeries;
		LPCTSTR lpszlabels = _T("线路左轨高程偏差;线路右轨高程偏差;");
		CStringArray arrLabels;
		CreateArray(arrLabels, lpszlabels);
		for(int i=0; i<arrLabels.GetSize(); i++)
		{
			vecSeries.clear();
			for (int j = 0; j < rs; j++)
			{
				CXTPReportRow* pRow = pRows->GetAt(j);
				CXTPReportRecord* pRecord = pRow->GetRecord();
				if(pRecord)
				{
					double mileage = ((CXTPReportRecordItemVariant*)pRecord->GetItem(4))->GetValue().dblVal;
					double dval = ((CXTPReportRecordItemVariant*)pRecord->GetItem(i==0 ? 6:10))->GetValue().dblVal;
					SeriesPoint sp(mileage, dval);
					sp.SetM(mileage);
					vecSeries.push_back(sp);
				}
			}

			pMaainFrame->m_pChartView->AddChartSeries(arrLabels[i], vecSeries, new CXTPChartLineSeriesStyle(),TRUE);
		}
		pMaainFrame->m_wndPaneProperties.m_nActiveChartStyle = ID_CHART_STYLE_LINE;
	}
}

void CRibbonReportView::ShowPlateMileage(CXTPReportSelectedRows* pRows)
{
	if(pRows != NULL)
	{
		int rs = pRows->GetCount();
		if(rs < 2) return;

		CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
		pMaainFrame->SetChartView();
		if(!pMaainFrame->m_pChartView) return;
		pMaainFrame->m_pChartView->ClearChartSeries();

		xtp_vector<SeriesPoint> vecSeries;
		for(int i=0; i<rs ;i++)
		{
			CXTPReportRow* pRow = pRows->GetAt(i);
			CXTPReportRecord* pRecord = pRow->GetRecord();
			if(pRecord)
			{
				double left_mileage = ((CXTPReportRecordItemVariant*)pRecord->GetItem(4))->GetValue().dblVal;
				double right_mileage = ((CXTPReportRecordItemVariant*)pRecord->GetItem(8))->GetValue().dblVal;
				double dif_mileage = (right_mileage-left_mileage)*1000;
				SeriesPoint sp(left_mileage, dif_mileage);
				sp.SetM(left_mileage);
				vecSeries.push_back(sp);
			}
		}
		pMaainFrame->m_pChartView->AddChartSeries(_T("线路左右里程偏差"), vecSeries, new CXTPChartLineSeriesStyle(), TRUE);
		pMaainFrame->m_wndPaneProperties.m_nActiveChartStyle = ID_CHART_STYLE_LINE;
	}
}

void CRibbonReportView::ShowPlateRideIn(CXTPReportSelectedRows* pRows)
{
	if(pRows != NULL)
	{
		int rs = pRows->GetCount();
		if(rs < 2) return;

		CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
		pMaainFrame->SetChartView();
		if(!pMaainFrame->m_pChartView) return;
		pMaainFrame->m_pChartView->ClearChartSeries();

		xtp_vector<SeriesPoint> vecSeries;
		LPCTSTR lpszlabels = _T("板内左轨纵向平顺性;板内左轨横向平顺性;板内左轨高程平顺性;板内右轨纵向平顺性;板内右轨横向平顺性;板内右轨高程平顺性;");
		CStringArray arrLabels;
		CreateArray(arrLabels, lpszlabels);
		for(int i=0; i<arrLabels.GetSize(); i++)
		{
			vecSeries.clear();
			for (int j = 0; j < rs; j++)
			{
				CXTPReportRow* pRow = pRows->GetAt(j);
				CXTPReportRecord* pRecord = pRow->GetRecord();
				if(pRecord)
				{
					CString mask = ((CXTPReportRecordItemVariant*)pRecord->GetItem(2))->GetValue().bstrVal;
					double mileage = ((CXTPReportRecordItemVariant*)pRecord->GetItem(4))->GetValue().dblVal;
					double dval = ((CXTPReportRecordItemVariant*)pRecord->GetItem(13+i))->GetValue().dblVal;
					SeriesPoint sp(mileage, dval);
					//sp.SetM(mileage);
					sp._x = mask;
					vecSeries.push_back(sp);
				}
			}

			pMaainFrame->m_pChartView->AddChartSeries(arrLabels[i], vecSeries, new CXTPChartLineSeriesStyle(),TRUE);
		}
		pMaainFrame->m_wndPaneProperties.m_nActiveChartStyle = ID_CHART_STYLE_LINE;
	}
}

void CRibbonReportView::ShowPlateRideOut(CXTPReportSelectedRows* pRows)
{
	if(pRows != NULL)
	{
		int rs = pRows->GetCount();
		if(rs < 2) return;

		CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
		pMaainFrame->SetChartView();
		if(!pMaainFrame->m_pChartView) return;
		pMaainFrame->m_pChartView->ClearChartSeries();

		pMaainFrame->SetChartView();
		if(!pMaainFrame->m_pChartView) return;
		xtp_vector<SeriesPoint> vecSeries;
		pMaainFrame->m_pChartView->CreateChartStepLine(_T(""), vecSeries);
		pMaainFrame->m_pChartView->ClearChartSeries();

		LPCTSTR lpszlabels = _T("板间左轨横向平顺性;板间左轨高程平顺性;板间右轨横向平顺性;板间右轨高程平顺性;");
		CStringArray arrLabels;
		CreateArray(arrLabels, lpszlabels);
		for(int i=0; i<arrLabels.GetSize(); i++)
		{
			vecSeries.clear();
			for (int j = 0; j < rs; j=j+2)
			{
				CXTPReportRow* pRow = pRows->GetAt(j+1);
				CXTPReportRecord* pRecord = pRow->GetRecord();
				if(pRecord)
				{
					CString mask = ((CXTPReportRecordItemVariant*)pRecord->GetItem(2))->GetValue().bstrVal;
					double dbl = ((CXTPReportRecordItemVariant*)pRecord->GetItem(19+i))->GetValue().dblVal;
					SeriesPoint sp(j, dbl);	
					sp._x = mask;

					vecSeries.push_back(sp);
				}
			}

			pMaainFrame->m_pChartView->AddChartSeries(arrLabels[i], vecSeries, new CXTPChartStepLineSeriesStyle(),TRUE);
		}
		pMaainFrame->m_wndPaneProperties.m_nActiveChartStyle = ID_CHART_STYLE_STEPLINE;
	}
}

void CRibbonReportView::ShowPlateRate(CXTPReportSelectedRows* pRows)
{
	if(pRows != NULL)
	{
		int rs = pRows->GetCount();
		if(rs < 2) return;

		CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
		pMaainFrame->SetChartView();
		if(!pMaainFrame->m_pChartView) return;
		pMaainFrame->m_pChartView->ClearChartSeries();

		CXTPReportRow* pRow = pRows->GetAt(0);
		CXTPReportRecord* pRecord = pRow->GetRecord();
		CString code1 = ((CXTPReportRecordItemVariant*)pRecord->GetItem(0))->GetValue().bstrVal;
		pRow = pRows->GetAt(rs-1);
		pRecord = pRow->GetRecord();
		CString code2 = ((CXTPReportRecordItemVariant*)pRecord->GetItem(0))->GetValue().bstrVal;

		pMaainFrame->SetChartView();
		if(!pMaainFrame->m_pChartView) return;
		xtp_vector<SeriesPoint> vecSeries;
		pMaainFrame->m_pChartView->CreateChartBar(_T(""), vecSeries);
		pMaainFrame->m_pChartView->ClearChartSeries();

		LPCTSTR lpszFields = _T("ro_left_horizon;ro_right_horizon;ro_left_vertical;ro_right_vertical;");
		LPCTSTR lpszlabels = _T("左轨横向偏差;右轨横向偏差;左轨高程偏差;右轨高程偏差;");
		CStringArray arrFields,arrLabels;
		CreateArray(arrFields, lpszFields);
		CreateArray(arrLabels, lpszlabels);
		for(int i=0; i<arrFields.GetSize(); i++)
		{
			CString fid = arrFields[i];
			CString tbl = _T("tb_retest_orbit");
			CString label = arrLabels[i];

			long rs = pRows->GetCount();
			LPCTSTR lpszCond1 = _T(">= 0;>= 1;>= 2;>= 3;>= 4;>= 5;>= 6;>= 7;> -1;> -2;> -3;> -4;> -5;> -6;> -7;> -8;");
			LPCTSTR lpszCond2 = _T("< 1;< 2;< 3;< 4;< 5;< 6;< 7;< 8;< 0;<= -1;<= -2;<= -3;<= -4;<= -5;<= -6;<= -7;");
			CStringArray arrCond1,arrCond2;
			CreateArray(arrCond1, lpszCond1);
			CreateArray(arrCond2, lpszCond2);

			if(arrCond1.GetSize() == arrCond2.GetSize())
			{
				vecSeries.clear();
				for (int j = 0; j < arrCond1.GetSize(); j++)
				{
					CXTPADORecordset rst(theCon);
					CString sql1,sql;
					sql1.Format(_T("with tbl1 as (select * from %s[%s] where ro_code between '%s' and '%s')"), g_TablePrix, tbl, code1, code2);
					if(arrCond2[j].GetLength() == 0)
						sql.Format(_T("%s select * from tbl1 where %s %s order by ro_code"), sql1, fid, arrCond1[j]);
					else
						sql.Format(_T("%s select * from tbl1 where %s %s and %s %s order by ro_code"), sql1, fid, arrCond1[j], fid, arrCond2[j]);
					rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
					long cnt = rst.GetRecordCount();

					SeriesPoint sp(i, cnt);

					if(arrCond2[j].GetLength() == 0)
						sp._x.Format(_T("%s mm"),arrCond1[j]);
					else
						sp._x.Format(_T("%s mm & %s mm"),arrCond1[j],arrCond2[j]);

					vecSeries.push_back(sp);
				}

				pMaainFrame->m_pChartView->AddChartSideBarSeries(i, label, vecSeries,TRUE);
			}
		}
		pMaainFrame->m_wndPaneProperties.m_nActiveChartStyle = ID_CHART_STYLE_SIDEBAR;
	}
}

void CRibbonReportView::ShowRailRide(CXTPReportSelectedRows* pRows)
{
	if(pRows != NULL)
	{
		int rs = pRows->GetCount();
		if(rs < 2) return;

		CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
		pMaainFrame->SetChartView();
		if(!pMaainFrame->m_pChartView) return;
		pMaainFrame->m_pChartView->ClearChartSeries();

		pMaainFrame->SetChartView();
		if(!pMaainFrame->m_pChartView) return;
		xtp_vector<SeriesPoint> vecSeries;
		pMaainFrame->m_pChartView->CreateChartStepLine(_T(""), vecSeries);
		pMaainFrame->m_pChartView->ClearChartSeries();

		LPCTSTR lpszlabels = _T("板间左轨横向平顺性;板间左轨高程平顺性;板间右轨横向平顺性;板间右轨高程平顺性;");
		CStringArray arrLabels;
		CreateArray(arrLabels, lpszlabels);
		for(int i=0; i<arrLabels.GetSize(); i++)
		{
			vecSeries.clear();
			for (int j = 0; j < rs; j=j+2)
			{
				CXTPReportRow* pRow = pRows->GetAt(j+1);
				CXTPReportRecord* pRecord = pRow->GetRecord();
				if(pRecord)
				{
					CString mask = ((CXTPReportRecordItemVariant*)pRecord->GetItem(2))->GetValue().bstrVal;
					double dbl = ((CXTPReportRecordItemVariant*)pRecord->GetItem(19+i))->GetValue().dblVal;
					SeriesPoint sp(j, dbl);	
					sp._x = mask;

					vecSeries.push_back(sp);
				}
			}

			pMaainFrame->m_pChartView->AddChartSeries(arrLabels[i], vecSeries, new CXTPChartStepLineSeriesStyle(),TRUE);
		}
		pMaainFrame->m_wndPaneProperties.m_nActiveChartStyle = ID_CHART_STYLE_STEPLINE;
	}
}

void CRibbonReportView::ShowRailRate(CXTPReportSelectedRows* pRows)
{
	if(pRows != NULL)
	{
		int rs = pRows->GetCount();
		if(rs < 2) return;

		CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
		pMaainFrame->SetChartView();
		if(!pMaainFrame->m_pChartView) return;
		pMaainFrame->m_pChartView->ClearChartSeries();

		CXTPReportRow* pRow = pRows->GetAt(0);
		CXTPReportRecord* pRecord = pRow->GetRecord();
		CString code1 = ((CXTPReportRecordItemVariant*)pRecord->GetItem(0))->GetValue().bstrVal;
		pRow = pRows->GetAt(rs-1);
		pRecord = pRow->GetRecord();
		CString code2 = ((CXTPReportRecordItemVariant*)pRecord->GetItem(0))->GetValue().bstrVal;

		pMaainFrame->SetChartView();
		if(!pMaainFrame->m_pChartView) return;
		xtp_vector<SeriesPoint> vecSeries;
		pMaainFrame->m_pChartView->CreateChartBar(_T(""), vecSeries);
		pMaainFrame->m_pChartView->ClearChartSeries();

		LPCTSTR lpszFields = _T("ro_left_horizon;ro_right_horizon;ro_left_vertical;ro_right_vertical;");
		LPCTSTR lpszlabels = _T("左轨横向偏差;右轨横向偏差;左轨高程偏差;右轨高程偏差;");
		CStringArray arrFields,arrLabels;
		CreateArray(arrFields, lpszFields);
		CreateArray(arrLabels, lpszlabels);
		for(int i=0; i<arrFields.GetSize(); i++)
		{
			CString fid = arrFields[i];
			CString tbl = _T("tb_retest_orbit");
			CString label = arrLabels[i];

			long rs = pRows->GetCount();
			LPCTSTR lpszCond1 = _T(">= 0;>= 1;>= 2;>= 3;>= 4;>= 5;>= 6;>= 7;> -1;> -2;> -3;> -4;> -5;> -6;> -7;> -8;");
			LPCTSTR lpszCond2 = _T("< 1;< 2;< 3;< 4;< 5;< 6;< 7;< 8;< 0;<= -1;<= -2;<= -3;<= -4;<= -5;<= -6;<= -7;");
			CStringArray arrCond1,arrCond2;
			CreateArray(arrCond1, lpszCond1);
			CreateArray(arrCond2, lpszCond2);

			if(arrCond1.GetSize() == arrCond2.GetSize())
			{
				vecSeries.clear();
				for (int j = 0; j < arrCond1.GetSize(); j++)
				{
					CXTPADORecordset rst(theCon);
					CString sql1,sql;
					sql1.Format(_T("with tbl1 as (select * from %s[%s] where ro_code between '%s' and '%s')"), g_TablePrix, tbl, code1, code2);
					if(arrCond2[j].GetLength() == 0)
						sql.Format(_T("%s select * from tbl1 where %s %s order by ro_code"), sql1, fid, arrCond1[j]);
					else
						sql.Format(_T("%s select * from tbl1 where %s %s and %s %s order by ro_code"), sql1, fid, arrCond1[j], fid, arrCond2[j]);
					rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
					long cnt = rst.GetRecordCount();

					SeriesPoint sp(i, cnt);

					if(arrCond2[j].GetLength() == 0)
						sp._x.Format(_T("%s mm"),arrCond1[j]);
					else
						sp._x.Format(_T("%s mm & %s mm"),arrCond1[j],arrCond2[j]);

					vecSeries.push_back(sp);
				}

				pMaainFrame->m_pChartView->AddChartSideBarSeries(i, label, vecSeries,TRUE);
			}
		}
		pMaainFrame->m_wndPaneProperties.m_nActiveChartStyle = ID_CHART_STYLE_SIDEBAR;
	}
}

void CRibbonReportView::ShowProblemRate(CXTPReportSelectedRows* pRows)
{
	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();

	if(pRows != NULL)
	{
		int rs = pRows->GetCount();
		if(rs > 1)
		{
			xtp_vector<SeriesPoint> vecSeries;
			pMaainFrame->SetChartView();
			if(!pMaainFrame->m_pChartView) return;
			pMaainFrame->m_pChartView->ClearChartSeries();

			for(int i=0; i<rs ;i++)
			{
				CXTPReportRow* pRow = pRows->GetAt(i);
				CXTPReportRecord* pRecord = pRow->GetRecord();
				if(pRecord)
				{
					CString str1 = ((CXTPReportRecordItemVariant*)pRecord->GetItem(1))->GetValue().bstrVal;
					CString str2 = ((CXTPReportRecordItemVariant*)pRecord->GetItem(2))->GetValue().bstrVal;
					int cnt_all = ((CXTPReportRecordItemVariant*)pRecord->GetItem(3))->GetValue().intVal;
					int cnt_do = ((CXTPReportRecordItemVariant*)pRecord->GetItem(4))->GetValue().intVal;
					double rat = cnt_do*100.0/cnt_all;
					SeriesPoint sp(cnt_all, cnt_do, rat);
					sp._x = str1+_T("_")+str2;
					vecSeries.push_back(sp);
				}
			}

			pMaainFrame->m_pChartView->AddChartPieSeries(_T("%.1f%%"), vecSeries, 0);
			pMaainFrame->m_wndPaneProperties.m_nActiveChartStyle = ID_CHART_STYLE_PIE;
			pMaainFrame->m_pChartView->SetChartTitle(_T("克缺问题库消号比率图"),_T(""));
			return;
		}
	}

	xtp_vector<SeriesPoint> vecSeries;
	pMaainFrame->SetChartView();
	if(!pMaainFrame->m_pChartView) return;
	pMaainFrame->m_pChartView->ClearChartSeries();
	CXTPADORecordset rst(theCon);
	CString sql;
	sql.Format(_T("select 专业, sum(整改数量) as 整改数量, sum(消号数量) as 消号数量 from %stp_problem_all group by 专业 order by 专业"), g_TablePrix);
	rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc);
	rst.MoveFirst();
	while(!rst.IsEOF())
	{
		CString str;
		int cnt_all,cnt_do;
		rst.GetFieldValue(0,str);
		rst.GetFieldValue(1,cnt_all);
		rst.GetFieldValue(2,cnt_do);
		double rat = cnt_do*100.0/cnt_all;
		SeriesPoint sp(cnt_all, cnt_do, rat);
		sp._x = str;
		vecSeries.push_back(sp);
		rst.MoveNext();
	}
	rst.Close();

	pMaainFrame->m_pChartView->AddChartPieSeries(_T("%.1f%%"), vecSeries, 0);
	pMaainFrame->m_wndPaneProperties.m_nActiveChartStyle = ID_CHART_STYLE_PIE;
	pMaainFrame->m_pChartView->SetChartTitle(_T("克缺问题库消号比率图"),_T(""));
}


void CRibbonReportView::OnRButtonUp(UINT nFlags, CPoint point) 
{
	if (TRUE)
	{
		CReportRecordView::OnRButtonUp(nFlags, point);
	}
	else
	{
		CXTPCommandBars* pCommandBars = ((CMainFrame*)AfxGetMainWnd())->GetCommandBars();
		CXTPMiniToolBar* pMiniToolBar = DYNAMIC_DOWNCAST(CXTPMiniToolBar, pCommandBars->GetContextMenus()->FindCommandBar(IDR_MENU_MINITOOLBAR));
		if (!pMiniToolBar)
			return;

		CXTPPopupBar* pPopupBar = (CXTPPopupBar*)pCommandBars->GetContextMenus()->FindCommandBar(IDR_MENU_MINITOOLBAR);

		pMiniToolBar->TrackPopupMenu(pPopupBar, 0, point.x, point.y);
	}
}

void CRibbonReportView::OnLButtonDown(UINT nFlags, CPoint point) 
{
	//GetRichEditCtrl().GetSel(m_ptLastSel.x, m_ptLastSel.y);

	CReportRecordView::OnLButtonDown(nFlags, point);
}

void CRibbonReportView::OnLButtonUp(UINT nFlags, CPoint point) 
{
	CReportRecordView::OnLButtonUp(nFlags, point);

	CPoint ptSel;
	//GetRichEditCtrl().GetSel(ptSel.x, ptSel.y);

	CMainFrame* pMainFrame = (CMainFrame*)AfxGetMainWnd();

	if ((ptSel.x != ptSel.y && ptSel != m_ptLastSel) && pMainFrame->m_bShowMiniToolbar)
	{

		ClientToScreen(&point);
		CXTPCommandBars* pCommandBars = pMainFrame->GetCommandBars();

		CXTPMiniToolBar* pMiniToolBar = DYNAMIC_DOWNCAST(CXTPMiniToolBar, pCommandBars->GetContextMenus()->FindCommandBar(IDR_MENU_MINITOOLBAR));
		if (!pMiniToolBar)
			return;

		pMiniToolBar->TrackMiniBar(0, point.x, point.y  - 15);
	}
}


void CRibbonReportView::OnUpdateRibbonTab(CCmdUI* pCmdUI)
{
	CXTPRibbonControlTab* pControl = DYNAMIC_DOWNCAST(CXTPRibbonControlTab, CXTPControl::FromUI(pCmdUI));
	if (pControl)
		pControl->GetParent()->UnlockRedraw();

	pCmdUI->Enable(TRUE);
}


void CRibbonReportView::OnGroupOptionCommand(UINT nID)
{

}

void CRibbonReportView::OnUpdateGroupOptionCommand(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}


void CRibbonReportView::OnEditFormatPainter()
{

}

void CRibbonReportView::OnEditUndo(NMHDR* pNMHDR, LRESULT* pResult)
{
	CXTPControlGallery* pControlUndo = DYNAMIC_DOWNCAST(CXTPControlGallery, ((NMXTPCONTROL*)pNMHDR)->pControl);
	if (pControlUndo)
	{
		CString str;
		str.Format(_T("Undo last %i actions"), pControlUndo->GetSelectedItem() + 1);

		AfxMessageBox(str);
	}
	else
	{
		//CReportRecordView::OnEditUndo();
	}

	*pResult = 1; // Handled;
}

void CRibbonReportView::OnEditRedo(NMHDR* pNMHDR, LRESULT* pResult)
{
	CXTPControlGallery* pControlUndo = DYNAMIC_DOWNCAST(CXTPControlGallery, ((NMXTPCONTROL*)pNMHDR)->pControl);
	if (pControlUndo)
	{
		CString str;
		str.Format(_T("Undo last %i actions"), pControlUndo->GetSelectedItem() + 1);

		AfxMessageBox(str);
	}
	else
	{
		//CReportRecordView::OnEditUndo();
	}

	*pResult = 1; // Handled;
}

void CRibbonReportView::OnUpdateEditFormatPainter(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnUpdateEditUndo(CCmdUI* pCmdUI)
{
	CXTPControlGallery* pControlUndo = DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	pCmdUI->Enable(TRUE);

	if (pControlUndo)
	{
		//pCmd->Enable(GetReportCtrl().CanUndo());

		CXTPControlGalleryItems* pItems = pControlUndo->GetItems();
		pItems->RemoveAll();

		int nCount = RAND_S() % 20 + 3;

		for (int i = 0; i < nCount; i++)
		{
			CString str;
			str.Format(_T("Undo String %i"), i + 1);
			pItems->AddItem(new CGalleryItemUndo(str), i);
		}

		pControlUndo->OnSelectedItemChanged();
		pControlUndo->SetHeight(pItems->GetItemSize().cy * nCount + 2);

	}
	else
	{
		//CReportRecordView::OnUpdateEditUndo(pCmd);
	}
}

void CRibbonReportView::OnUpdateEditRedo(CCmdUI* pCmdUI)
{
	CXTPControlGallery* pControlUndo = DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	pCmdUI->Enable(TRUE);

	if (pControlUndo)
	{
		//pCmd->Enable(GetReportCtrl().CanUndo());

		CXTPControlGalleryItems* pItems = pControlUndo->GetItems();
		pItems->RemoveAll();

		int nCount = RAND_S() % 20 + 3;

		for (int i = 0; i < nCount; i++)
		{
			CString str;
			str.Format(_T("Undo String %i"), i + 1);
			pItems->AddItem(new CGalleryItemUndo(str), i);
		}

		pControlUndo->OnSelectedItemChanged();
		pControlUndo->SetHeight(pItems->GetItemSize().cy * nCount + 2);

	}
	else
	{
		//CReportRecordView::OnUpdateEditUndo(pCmd);
	}
}


void CRibbonReportView::OnFontCommand(UINT nID)
{
	SetFocus();
	CFont* pFont = GetPaintManager()->GetTextFont();
	LOGFONT lf;
	pFont->GetLogFont(&lf);

	switch(nID)
	{
	case ID_FONT_GROW:
		lf.lfHeight -= 1; 
		break;
	case ID_FONT_SHRINK:
		lf.lfHeight += 1; 
		break;
	case ID_FONT_CLEAR:
		lf.lfHeight = 12;
		break;
	case ID_FONT_BOLD:
		lf.lfWeight = lf.lfWeight == 400 ? 700:400;
		break;
	case ID_FONT_ITALIC:
		lf.lfItalic = lf.lfItalic ? FALSE:TRUE;
		break;
	case ID_FONT_UNDERLINE:
		lf.lfUnderline = lf.lfUnderline ? FALSE:TRUE;
		break;
	case ID_FONT_BORDERS:
		SetGridStyle(FALSE, GetGridStyle(FALSE) == xtpReportGridSolid ? xtpReportGridNoLines : xtpReportGridSolid);
		SetGridStyle(TRUE, GetGridStyle(TRUE) == xtpReportGridSolid ? xtpReportGridNoLines : xtpReportGridSolid);
		break;
	}

	GetPaintManager()->SetTextFont(lf);
}

void CRibbonReportView::OnFontUnderlineCommand(UINT nID)
{

}

void CRibbonReportView::OnFontBordersCommand(UINT nID)
{

}

void CRibbonReportView::OnFontCharfieldCommand(UINT nID)
{

}

void CRibbonReportView::OnUpdateFontCommand(CCmdUI* pCmdUI)
{
	CXTPControl* pControl = CXTPControl::FromUI(pCmdUI);

	pCmdUI->Enable(TRUE);

	if (pControl)
	{
		if (pControl->IsFocused())
			return;

		CFont* pFont = GetPaintManager()->GetTextFont();
		LOGFONT lf;
		pFont->GetLogFont(&lf);

		switch(pCmdUI->m_nID)
		{
		case ID_FONT_BOLD:
			pControl->SetPressed(lf.lfWeight  == 700);
			break;
		case ID_FONT_ITALIC:
			pControl->SetPressed(lf.lfItalic);
			break;
		case ID_FONT_UNDERLINE:
			pControl->SetPressed(lf.lfUnderline);
			break;
		case ID_FONT_BORDERS:
			pControl->SetPressed(GetGridStyle(TRUE) == xtpReportGridSolid);
			break;
		}
	}
}

void CRibbonReportView::OnUpdateFontUnderlineCommand(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnUpdateFontBordersCommand(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnUpdateFontCharfieldCommand(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnBtnFontFaceColor()
{
	SetRecordItemColor(-1, m_clrFace, m_clrBack);
	Populate();
}

void CRibbonReportView::OnGalleryFontFaceColor(NMHDR* pNMHDR, LRESULT* pResult)
{
	NMXTPCONTROL* tagNMCONTROL = (NMXTPCONTROL*)pNMHDR;

	CXTPControlGallery* pControl = DYNAMIC_DOWNCAST(CXTPControlGallery, tagNMCONTROL->pControl);

	if (pControl)
	{
		CXTPControlGalleryItem* pItem = pControl->GetItem(pControl->GetSelectedItem());
		if (pItem)
		{
			m_clrFace = (COLORREF)pItem->GetID();
			OnBtnFontFaceColor();
		}

		*pResult = TRUE; // Handled
	}


	*pResult = 1;
}

void CRibbonReportView::OnFontFaceAutoColor()
{
	m_clrFace = COLOR_BTNFACE;
	OnBtnFontFaceColor();
}

void CRibbonReportView::OnFontFaceOtherColor()
{
	CColorDialog ClrDlg(m_clrFace);

	if (IDOK == ClrDlg.DoModal())
	{
		m_clrFace = ClrDlg.GetColor();
		OnBtnFontFaceColor();
	}
}

void CRibbonReportView::OnUpdateBtnFontFaceColor(CCmdUI* pCmdUI)
{
	CXTPControlPopupColor* pPopup = DYNAMIC_DOWNCAST(CXTPControlPopupColor, CXTPControl::FromUI(pCmdUI));
	
	pCmdUI->Enable(TRUE);

	if (pPopup)
		pPopup->SetColor(m_clrFace);
}

void CRibbonReportView::OnUpdateGalleryFontFaceColor(CCmdUI* pCmdUI)
{
	CXTPControlGallery* pGallery = 	DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	if (pGallery)
	{
		if (pGallery->GetCheckedItem() != m_idGalleryFontFaceColor)
		{
			pGallery->SetCheckedItem(m_clrFace);
			pGallery->SetCheckedItem(m_idGalleryFontFaceColor);
			pGallery->EnsureVisible(m_idGalleryFontFaceColor);
		}
	}
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnUpdateFontFaceAutoColor(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnUpdateFontFaceOtherColor(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnBtnFontBackColor()
{
	SetRecordItemColor(-1, m_clrFace, m_clrBack);
	Populate();
}

void CRibbonReportView::OnGalleryFontBackColor(NMHDR* pNMHDR, LRESULT* pResult)
{
	NMXTPCONTROL* tagNMCONTROL = (NMXTPCONTROL*)pNMHDR;

	CXTPControlGallery* pControl = DYNAMIC_DOWNCAST(CXTPControlGallery, tagNMCONTROL->pControl);

	if (pControl)
	{
		CXTPControlGalleryItem* pItem = pControl->GetItem(pControl->GetSelectedItem());
		if (pItem)
		{
			m_clrBack = (COLORREF)pItem->GetID();
			OnBtnFontBackColor();
		}

		*pResult = TRUE; // Handled
	}
}

void CRibbonReportView::OnFontBackNoColors()
{
	m_clrBack = COLORREF_NULL;
	OnBtnFontBackColor();
}

void CRibbonReportView::OnUpdateBtnFontBackColor(CCmdUI* pCmdUI)
{
	CXTPControlPopupColor* pPopup = DYNAMIC_DOWNCAST(CXTPControlPopupColor, CXTPControl::FromUI(pCmdUI));
	if (pPopup)
		pPopup->SetColor(m_clrBack == COLORREF_NULL ? 0xFFFFFF : m_clrBack);

	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnUpdateGalleryFontBackColor(CCmdUI* pCmdUI)
{
	CXTPControlGallery* pGallery = 	DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	if (pGallery)
	{
		if (pGallery->GetCheckedItem() != m_idGalleryFontBackColor)
		{
			pGallery->SetCheckedItem(m_clrBack);
			pGallery->SetCheckedItem(m_idGalleryFontBackColor);
			pGallery->EnsureVisible(m_idGalleryFontBackColor);
		}
	}
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnUpdateFontBackNoColors(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnEditFontFace(NMHDR* pNMHDR, LRESULT* pResult)
{
	NMXTPCONTROL* tagNMCONTROL = (NMXTPCONTROL*)pNMHDR;

	CXTPControlComboBox* pControl = (CXTPControlComboBox*)tagNMCONTROL->pControl;
	if (pControl->GetType() == xtpControlComboBox)
	{
		CFont* pFont = GetPaintManager()->GetTextFont();
		LOGFONT lf;
		pFont->GetLogFont(&lf);
		lstrcpy( lf.lfFaceName, pControl->GetEditText());
		
		GetPaintManager()->SetTextFont(lf);

		*pResult = 1; // Handled;
	}
}

void CRibbonReportView::OnEditFontSize(NMHDR* pNMHDR, LRESULT* pResult)
{
	NMXTPCONTROL* tagNMCONTROL = (NMXTPCONTROL*)pNMHDR;

	CXTPControlComboBox* pControl = (CXTPControlComboBox*)tagNMCONTROL->pControl;
	if (pControl->GetType() == xtpControlComboBox)
	{
		CFont* pFont = GetPaintManager()->GetTextFont();
		LOGFONT lf;
		pFont->GetLogFont(&lf);
		lf.lfHeight = _ttol(pControl->GetEditText());

		GetPaintManager()->SetTextFont(lf);

		*pResult = 1; // Handled;
	}
}

void CRibbonReportView::OnFontOther()
{
	CFont* pFont = GetPaintManager()->GetTextFont();
	LOGFONT lf;
	pFont->GetLogFont(&lf);

	CFontDialog FontDlg(&lf,CF_EFFECTS | CF_SCREENFONTS,NULL,this);

	if(IDOK == FontDlg.DoModal())
	{
		FontDlg.GetCurrentFont(&lf);
		GetPaintManager()->SetTextFont(lf);
	}
}

void CRibbonReportView::OnUpdateFontFace(CCmdUI* pCmdUI)
{
	CXTPControlComboBox* pFontCombo = (CXTPControlComboBox*)CXTPControl::FromUI(pCmdUI);

	pCmdUI->Enable(TRUE);

	if (pFontCombo)
	if (pFontCombo->GetType() == xtpControlComboBox)
	{
		CFont* pFont = GetPaintManager()->GetTextFont();
		LOGFONT lf;
		pFont->GetLogFont(&lf);

		if (pFontCombo->HasFocus())
			return;

		// the selection must be same font and charset to display correctly
		if (lf.lfFaceName > 0)
			pFontCombo->SetEditText(lf.lfFaceName);
	}
}

void CRibbonReportView::OnUpdateFontSize(CCmdUI* pCmdUI)
{
	CXTPControlComboBox* pFontCombo = (CXTPControlComboBox*)CXTPControl::FromUI(pCmdUI);

	pCmdUI->Enable(TRUE);

	if(pFontCombo)
	if (pFontCombo->GetType() == xtpControlComboBox)
	{
		CFont* pFont = GetPaintManager()->GetTextFont();
		LOGFONT lf;
		pFont->GetLogFont(&lf);

		if (pFontCombo->HasFocus())
			return;

		if(abs(lf.lfHeight) > 0)
			pFontCombo->SetEditText(ToString(abs(lf.lfHeight),0));
	}
}

void CRibbonReportView::OnUpdateFontOther(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnUpdateGalleryFontFace(CCmdUI* pCmdUI)
{
	CXTPControlGallery* pGallery = 	DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	if (pGallery)
	{
		if (pGallery->GetCheckedItem() != m_idGalleryFontFace)
		{
			pGallery->SetCheckedItem(m_idGalleryFontFace);
			pGallery->EnsureVisible(m_idGalleryFontFace);
		}
	}
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnUpdateGalleryFontSize(CCmdUI* pCmdUI)
{
	CXTPControlGallery* pGallery = 	DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	if (pGallery)
	{
		if (pGallery->GetCheckedItem() != m_idGalleryFontSize)
		{
			pGallery->SetCheckedItem(m_idGalleryFontSize);
			pGallery->EnsureVisible(m_idGalleryFontSize);
		}
	}
	pCmdUI->Enable(TRUE);
}


void CRibbonReportView::OnAlignmentCommand(UINT nID)
{
	SetFocus();
	CXTPReportColumn* pColumn = GetFocusedColumn();

	switch(nID)
	{
	case ID_ALIGNMENT_SORT:
		pColumn->SetSortIncreasing(!pColumn->IsSortedIncreasing());
		break;
	case ID_ALIGNMENT_LEFT:
		pColumn->SetAlignment(xtpColumnTextLeft);
		break;
	case ID_ALIGNMENT_CENTER:
		pColumn->SetAlignment(xtpColumnTextCenter);
		break;
	case ID_ALIGNMENT_RIGHT:
		pColumn->SetAlignment(xtpColumnTextRight);
		break;
	case ID_ALIGNMENT_MERGE:
		break;
	}
}

void CRibbonReportView::OnAlignmentDirect(UINT nID)
{

}

void CRibbonReportView::OnAlignmentMerge(UINT nID)
{

}

void CRibbonReportView::OnUpdateAlignmentCommand(CCmdUI* pCmdUI)
{
	CXTPControl* pControl = CXTPControl::FromUI(pCmdUI);

	pCmdUI->Enable(TRUE);

	if (pControl)
	{
		if (pControl->IsFocused())
			return;

		CXTPReportColumn* pColumn = GetFocusedColumn();
		if(pColumn)
		{
			int nAlign = pColumn->GetAlignment();

			switch(pCmdUI->m_nID)
			{
			case ID_ALIGNMENT_LEFT:
				pControl->SetPressed(nAlign == xtpColumnTextLeft);
				break;
			case ID_ALIGNMENT_CENTER:
				pControl->SetPressed(nAlign == xtpColumnTextCenter);
				break;
			case ID_ALIGNMENT_RIGHT:
				pControl->SetPressed(nAlign == xtpColumnTextRight);
				break;
			}
		}
	}
}

void CRibbonReportView::OnUpdateAlignmentDirect(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnUpdateAlignmentMerge(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}


void CRibbonReportView::OnEditNumberFormat(NMHDR* pNMHDR, LRESULT* pResult)
{
	NMXTPCONTROL* tagNMCONTROL = (NMXTPCONTROL*)pNMHDR;

	CXTPControlComboBox* pControl = (CXTPControlComboBox*)tagNMCONTROL->pControl;
	if (pControl->GetType() == xtpControlComboBox)
	{
		*pResult = 1; // Handled;
	}
}

void CRibbonReportView::OnNumberFormatOther()
{

}

void CRibbonReportView::OnNumberCommand(UINT nID)
{

}

void CRibbonReportView::OnNumberAccountant(UINT nID)
{

}

void CRibbonReportView::OnUpdateNumberFormat(CCmdUI* pCmdUI)
{
	CXTPControlComboBox* pNumberCombo = (CXTPControlComboBox*)CXTPControl::FromUI(pCmdUI);

	pCmdUI->Enable(TRUE);

	if (pNumberCombo && pNumberCombo->GetType() == xtpControlComboBox)
	{
		if (pNumberCombo->HasFocus())
			return;

		if(pNumberCombo->GetEditText().IsEmpty())
			pNumberCombo->SetEditText(m_strNumberFormat);

		m_strNumberFormat = pNumberCombo->GetText();
	}
}

void CRibbonReportView::OnUpdateGalleryNumber(CCmdUI* pCmdUI)
{
	CXTPControlGallery* pGallery = 	DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	if (pGallery)
	{
		if (pGallery->GetCheckedItem() != m_idGalleryNumber)
		{
			pGallery->SetCheckedItem(m_idGalleryNumber);
			pGallery->EnsureVisible(m_idGalleryNumber);
		}
	}
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnUpdateNumberFormatOther(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnUpdateNumberCommand(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}

void CRibbonReportView::OnUpdateNumberAccountant(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(TRUE);
}


void CRibbonReportView::OnStylesCommand(UINT nID)
{

}

 void CRibbonReportView::OnCondition(UINT nID)
 {

 }

 void CRibbonReportView::OnConditionCommand(UINT nID)
 {

 }

 void CRibbonReportView::OnStyleFormat(UINT nID)
 {

 }

 void CRibbonReportView::OnStyleCell(UINT nID)
 {

 }

 void CRibbonReportView::OnGalleryConditionHighlight(NMHDR* pNMHDR, LRESULT* pResult)
 {
	 NMXTPCONTROL* tagNMCONTROL = (NMXTPCONTROL*)pNMHDR;

	 CXTPControlGallery* pGallery = DYNAMIC_DOWNCAST(CXTPControlGallery, tagNMCONTROL->pControl);

	 if (pGallery)
	 {
		 CXTPControlGalleryItem* pItem = pGallery->GetItem(pGallery->GetSelectedItem());
		 if (pItem)
		 {
			 m_idGalleryHighLight = pItem->GetID();
		 }

		 *pResult = TRUE; // Handled
	 }
 }

 void CRibbonReportView::OnGalleryConditionItemselect(NMHDR* pNMHDR, LRESULT* pResult)
 {
	 NMXTPCONTROL* tagNMCONTROL = (NMXTPCONTROL*)pNMHDR;

	 CXTPControlGallery* pGallery = DYNAMIC_DOWNCAST(CXTPControlGallery, tagNMCONTROL->pControl);

	 if (pGallery)
	 {
		 CXTPControlGalleryItem* pItem = pGallery->GetItem(pGallery->GetSelectedItem());
		 if (pItem)
		 {
			 m_idGalleryItemSelect = pItem->GetID();
		 }

		 *pResult = TRUE; // Handled
	 }
 }

 void CRibbonReportView::OnGalleryConditionDatabars(NMHDR* pNMHDR, LRESULT* pResult)
 {
	 NMXTPCONTROL* tagNMCONTROL = (NMXTPCONTROL*)pNMHDR;

	 CXTPControlGallery* pGallery = DYNAMIC_DOWNCAST(CXTPControlGallery, tagNMCONTROL->pControl);

	 if (pGallery)
	 {
		 CXTPControlGalleryItem* pItem = pGallery->GetItem(pGallery->GetSelectedItem());
		 if (pItem)
		 {
			 m_idGalleryDataBars = pItem->GetID();
		 }

		 *pResult = TRUE; // Handled
	 }
 }

 void CRibbonReportView::OnGalleryConditionClrValeur(NMHDR* pNMHDR, LRESULT* pResult)
 {
	 NMXTPCONTROL* tagNMCONTROL = (NMXTPCONTROL*)pNMHDR;

	 CXTPControlGallery* pGallery = DYNAMIC_DOWNCAST(CXTPControlGallery, tagNMCONTROL->pControl);

	 if (pGallery)
	 {
		 CXTPControlGalleryItem* pItem = pGallery->GetItem(pGallery->GetSelectedItem());
		 if (pItem)
		 {
			 m_idGalleryClrValeur = pItem->GetID();
		 }

		 *pResult = TRUE; // Handled
	 }
 }

 void CRibbonReportView::OnGalleryConditionIconlist(NMHDR* pNMHDR, LRESULT* pResult)
 {
	 NMXTPCONTROL* tagNMCONTROL = (NMXTPCONTROL*)pNMHDR;

	 CXTPControlGallery* pGallery = DYNAMIC_DOWNCAST(CXTPControlGallery, tagNMCONTROL->pControl);

	 if (pGallery)
	 {
		 CXTPControlGalleryItem* pItem = pGallery->GetItem(pGallery->GetSelectedItem());
		 if (pItem)
		 {
			 m_idGalleryIconList = pItem->GetID();
		 }

		 *pResult = TRUE; // Handled
	 }
 }

 void CRibbonReportView::OnGalleryStylesFormat(NMHDR* pNMHDR, LRESULT* pResult)
 {
	 NMXTPCONTROL* tagNMCONTROL = (NMXTPCONTROL*)pNMHDR;

	 CXTPControlGallery* pGallery = DYNAMIC_DOWNCAST(CXTPControlGallery, tagNMCONTROL->pControl);

	 if (pGallery)
	 {
		 CXTPControlGalleryItem* pItem = pGallery->GetItem(pGallery->GetSelectedItem());
		 if (pItem)
		 {
			 m_idStyleFormat = pItem->GetID();
		 }

		 *pResult = TRUE; // Handled
	 }
 }

 void CRibbonReportView::OnGalleryStylesCell(NMHDR* pNMHDR, LRESULT* pResult)
 {
	 NMXTPCONTROL* tagNMCONTROL = (NMXTPCONTROL*)pNMHDR;

	 CXTPControlGallery* pGallery = DYNAMIC_DOWNCAST(CXTPControlGallery, tagNMCONTROL->pControl);

	 if (pGallery)
	 {
		 CXTPControlGalleryItem* pItem = pGallery->GetItem(pGallery->GetSelectedItem());
		 if (pItem)
		 {
			 m_idStylesCell = pItem->GetID();
		 }

		 *pResult = TRUE; // Handled
	 }
 }

 void CRibbonReportView::OnUpdateStylesCommand(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateCondition(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateConditionCommand(CCmdUI* pCmdUI)
 {
	 CXTPControl* pControl = CXTPControl::FromUI(pCmdUI);

	 if (pControl)
	 {
		 if (pControl->GetID() == ID_CONDITION_NEW || pControl->GetID() == ID_CONDITION_MANAGE)
		 {
			 pControl->SetHeight(24);
			 pControl->SetIconSize(CSize(16,16));
		 }
	 }

	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateStyleFormat(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateStyleCell(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateGalleryConditionHighlight(CCmdUI* pCmdUI)
 {
	 CXTPControlGallery* pGallery = DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	 if (pGallery)
	 {
		 if (pGallery->GetCheckedItem() != m_idGalleryHighLight)
		 {
			 pGallery->SetCheckedItem(m_idGalleryHighLight);
			 pGallery->EnsureVisible(m_idGalleryHighLight);
		 }
	 }
	 pCmdUI->Enable(TRUE);
 }
 
 void CRibbonReportView::OnUpdateGalleryConditionItemselect(CCmdUI* pCmdUI)
 {
	 CXTPControlGallery* pGallery = DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	 if (pGallery)
	 {
		 if (pGallery->GetCheckedItem() != m_idGalleryItemSelect)
		 {
			 pGallery->SetCheckedItem(m_idGalleryItemSelect);
			 pGallery->EnsureVisible(m_idGalleryItemSelect);
		 }
	 }
	 pCmdUI->Enable(TRUE);
 }
 
 void CRibbonReportView::OnUpdateGalleryConditionDatabars(CCmdUI* pCmdUI)
 {
	 CXTPControlGallery* pGallery = DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	 if (pGallery)
	 {
		 if (pGallery->GetCheckedItem() != m_idGalleryDataBars)
		 {
			 pGallery->SetCheckedItem(m_idGalleryDataBars);
			 pGallery->EnsureVisible(m_idGalleryDataBars);
		 }
	 }
	 pCmdUI->Enable(TRUE);
 }
 
 void CRibbonReportView::OnUpdateGalleryConditionClrValeur(CCmdUI* pCmdUI)
 {
	 CXTPControlGallery* pGallery = DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	 if (pGallery)
	 {
		 if (pGallery->GetCheckedItem() != m_idGalleryClrValeur)
		 {
			 pGallery->SetCheckedItem(m_idGalleryClrValeur);
			 pGallery->EnsureVisible(m_idGalleryClrValeur);
		 }
	 }
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateGalleryConditionIconlist(CCmdUI* pCmdUI)
 {
	 CXTPControlGallery* pGallery = DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	 if (pGallery)
	 {
		 if (pGallery->GetCheckedItem() != m_idGalleryIconList)
		 {
			 pGallery->SetCheckedItem(m_idGalleryIconList);
			 pGallery->EnsureVisible(m_idGalleryIconList);
		 }
	 }
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateGalleryStylesFormat(CCmdUI* pCmdUI)
 {
	 CXTPControlGallery* pGallery =  DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	 if (pGallery)
	 {
		 if (pGallery->GetCheckedItem() != m_idStyleFormat)
		 {
			 pGallery->SetCheckedItem(m_idStyleFormat);
			 pGallery->EnsureVisible(m_idStyleFormat);
		 }
	 }
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateGalleryStylesCell(CCmdUI* pCmdUI)
 {
	 CXTPControlGallery* pGallery =  DYNAMIC_DOWNCAST(CXTPControlGallery, CXTPControl::FromUI(pCmdUI));

	 if (pGallery)
	 {
		 if (pGallery->GetCheckedItem() != m_idStylesCell)
		 {
			 pGallery->SetCheckedItem(m_idStylesCell);
			 pGallery->EnsureVisible(m_idStylesCell);
		 }
	 }
	 pCmdUI->Enable(TRUE);
 }


 void CRibbonReportView::OnCellCommand(UINT nID)
 {

 }

 void CRibbonReportView::OnCellInsert(UINT nID)
 {

 }

 void CRibbonReportView::OnCellDelete(UINT nID)
 {

 }

 void CRibbonReportView::OnCellFormat(UINT nID)
 {

 }

 void CRibbonReportView::OnUpdateCellCommand(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateCellInsert(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateCellDelete(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateCellFormat(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }


 void CRibbonReportView::OnModifyCommand(UINT nID)
 {

 }

 void CRibbonReportView::OnModifySum(UINT nID)
 {

 }

 void CRibbonReportView::OnModifyFill(UINT nID)
 {

 }

 void CRibbonReportView::OnModifyClear(UINT nID)
 {

 }

 void CRibbonReportView::OnModifySortFilter(UINT nID)
 {

 }

 void CRibbonReportView::OnModifyFindSelect(UINT nID)
 {

 }

 void CRibbonReportView::OnUpdateModifyCommand(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateModifySum(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateModifyFill(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateModifyClear(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateModifySortFilter(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }

 void CRibbonReportView::OnUpdateModifyFindSelect(CCmdUI* pCmdUI)
 {
	 pCmdUI->Enable(TRUE);
 }