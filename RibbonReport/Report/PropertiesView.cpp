// PropertiesFrame.cpp : implementation file
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
#include "PropertiesView.h"
#include "ReportRecordView.h"
#include "ReportFrame.h"
#include "ReportRecord.h"
#include "Resource.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#define ID_PROPERTY_MULTIPLESELECTION 1
#define ID_PROPERTY_PREVIEWMODE 2
#define ID_PROPERTY_GROUPBOXVISIBLE 3
#define ID_PROPERTY_FOCUSSUBITEMS 4
#define ID_PROPERTY_ALLOWCOLUMNREMOVE 5
#define ID_PROPERTY_ALLOWCOLUMNREORDER 6
#define ID_PROPERTY_ALLOWCOLUMNRESIZE 7
#define ID_PROPERTY_FLATHEADER 8
#define ID_PROPERTY_HIDESELECTION 9
#define ID_PROPERTY_TREEINDENT 10
#define ID_PROPERTY_ITEM_TEXT 11
#define ID_PROPERTY_ITEM_DOUBLE 12
#define ID_PROPERTY_ITEM_INT 13
#define ID_PROPERTY_ITEM_BOOL 14
#define ID_PROPERTY_ITEM_VARIANT 15



/////////////////////////////////////////////////////////////////////////////
// CPropertiesView

IMPLEMENT_DYNCREATE(CPropertiesView, CView)

CPropertiesView::CPropertiesView()
{
}

CPropertiesView::~CPropertiesView()
{
}

BEGIN_MESSAGE_MAP(CPropertiesView, CView)
	//{{AFX_MSG_MAP(CPropertiesView)
	ON_WM_CREATE()
	ON_WM_SIZE()
	ON_WM_ERASEBKGND()
	ON_WM_SETFOCUS()
	//}}AFX_MSG_MAP
	ON_NOTIFY(XTP_NM_REPORT_VALUECHANGED, IDC_REPORT_CONTROL, OnPropertyChanged)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPropertiesView drawing

void CPropertiesView::OnDraw(CDC*)
{
}

/////////////////////////////////////////////////////////////////////////////
// CPropertiesView diagnostics

#ifdef _DEBUG
void CPropertiesView::AssertValid() const
{
	CView::AssertValid();
}

void CPropertiesView::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CPropertiesView message handlers

CXTPReportControl* CPropertiesView::GetTargetReport()
{
	CView* pView = ((CReportFrame*)GetParent())->m_pOwnerView;

	return &((CReportRecordView*)pView)->GetReportCtrl();
}

int CPropertiesView::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (CView::OnCreate(lpCreateStruct) == -1)
		return -1;

	if (!m_wndReport.Create(WS_CHILD|WS_TABSTOP|WS_VISIBLE|WM_VSCROLL, CRect(0, 0, 0, 0), this, IDC_REPORT_CONTROL))
	{
		TRACE(_T("Failed to create view window\n"));
		return -1;
	}

	m_wndReport.GetReportHeader()->AllowColumnRemove(FALSE);

	CXTPReportColumn* pColumn = m_wndReport.AddColumn(new CXTPReportColumn(0, _T("Name"), 200));
	pColumn->SetTreeColumn(TRUE);
	pColumn->SetEditable(FALSE);

	m_wndReport.AddColumn(new CXTPReportColumn(1, _T("Value"), 150));

	pColumn = m_wndReport.AddColumn(new CXTPReportColumn(2, _T("Type"), 100));
	pColumn->SetEditable(FALSE);

	CXTPReportRecord* pRecordControl = m_wndReport.AddRecord(new CPropertyRecordGroup(_T("Report Control")));

	pRecordControl->SetExpanded(TRUE);

	CXTPReportControl* pTargetReport = GetTargetReport();

	pRecordControl->GetChilds()->Add(
		new CPropertyRecordBool(ID_PROPERTY_MULTIPLESELECTION, _T("Multiple Selection"), pTargetReport->IsMultipleSelection()));

	pRecordControl->GetChilds()->Add(
		new CPropertyRecordBool(ID_PROPERTY_PREVIEWMODE, _T("Preview Mode"), pTargetReport->IsPreviewMode()));

	pRecordControl->GetChilds()->Add(
		new CPropertyRecordBool(ID_PROPERTY_GROUPBOXVISIBLE, _T("Group Box Visible"), pTargetReport->IsGroupByVisible()));

	pRecordControl->GetChilds()->Add(
		new CPropertyRecordBool(ID_PROPERTY_FOCUSSUBITEMS, _T("Focus Sub Items"), pTargetReport->IsFocusSubItems()));


	CXTPReportRecord* pRecordHeader = pRecordControl->GetChilds()->Add(
		new CPropertyRecordGroup(_T("Report Header")));

	pRecordHeader->GetChilds()->Add(
		new CPropertyRecordBool(ID_PROPERTY_ALLOWCOLUMNREMOVE, _T("Allow Column Remove"), pTargetReport->GetReportHeader()->IsAllowColumnRemove()));

	pRecordHeader->GetChilds()->Add(
		new CPropertyRecordBool(ID_PROPERTY_ALLOWCOLUMNREORDER, _T("Allow Column Reorder"), pTargetReport->GetReportHeader()->IsAllowColumnReorder()));

	pRecordHeader->GetChilds()->Add(
		new CPropertyRecordBool(ID_PROPERTY_ALLOWCOLUMNRESIZE, _T("Allow Column Resize"), pTargetReport->GetReportHeader()->IsAllowColumnResize()));


	CXTPReportRecord* pRecordPaintManager = pRecordControl->GetChilds()->Add(
		new CPropertyRecordGroup(_T("Report Paint Manager")));

	pRecordPaintManager->GetChilds()->Add(
		new CPropertyRecordBool(ID_PROPERTY_FLATHEADER, _T("Flat Header"), pTargetReport->GetPaintManager()->GetColumnStyle() == xtpReportColumnFlat));

	pRecordPaintManager->GetChilds()->Add(
		new CPropertyRecordBool(ID_PROPERTY_HIDESELECTION, _T("Hide Selection"), pTargetReport->GetPaintManager()->m_bHideSelection));

	pRecordPaintManager->GetChilds()->Add(
		new CPropertyRecordInt(ID_PROPERTY_TREEINDENT, _T("Tree Indent"), pTargetReport->GetPaintManager()->m_nTreeIndent));


	CXTPReportRecord* pRecordItem = pRecordControl->GetChilds()->Add(
		new CPropertyRecordGroup(_T("Report Record Item")));

	pRecordItem->GetChilds()->Add(
		new CPropertyRecordText(ID_PROPERTY_ITEM_TEXT, _T("Item Text"), _T("string")));

	pRecordItem->GetChilds()->Add(
		new CPropertyRecordDouble(ID_PROPERTY_ITEM_DOUBLE, _T("Item Double"), 100.501));

	pRecordItem->GetChilds()->Add(
		new CPropertyRecordInt(ID_PROPERTY_ITEM_INT, _T("Item Int"), 1000));

	pRecordItem->GetChilds()->Add(
		new CPropertyRecordBool(ID_PROPERTY_ITEM_BOOL, _T("Item Bool"), TRUE));

	pRecordItem->GetChilds()->Add(
		new CPropertyRecordVariant(ID_PROPERTY_ITEM_VARIANT, _T("Item Variant"), COleVariant(_T("variant"))));
	pRecordItem->SetExpanded(TRUE);

	m_wndReport.GetPaintManager()->SetColumnStyle(xtpReportColumnFlat);
	m_wndReport.AllowEdit(TRUE);
	m_wndReport.EditOnClick(FALSE);
	m_wndReport.SetMultipleSelection(FALSE);
	m_wndReport.SetTreeIndent(10);
	m_wndReport.GetReportHeader()->AllowColumnSort(FALSE);

	m_wndReport.Populate();

	return 0;
}

void CPropertiesView::OnSize(UINT nType, int cx, int cy)
{
	CView::OnSize(nType, cx, cy);

	if (m_wndReport.GetSafeHwnd())
	{
		m_wndReport.MoveWindow(0, 0, cx, cy);
	}
}

BOOL CPropertiesView::OnEraseBkgnd(CDC* /*pDC*/)
{
	return TRUE;
}

void CPropertiesView::OnSetFocus(CWnd* pOldWnd)
{
	CView::OnSetFocus(pOldWnd);

	m_wndReport.SetFocus();
}

void CPropertiesView::OnPropertyChanged(NMHDR * pNotifyStruct, LRESULT * /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pItemNotify = (XTP_NM_REPORTRECORDITEM*) pNotifyStruct;

	CXTPReportControl* pTargetReport = GetTargetReport();

	switch (pItemNotify->pItem->GetItemData())
	{
	case ID_PROPERTY_MULTIPLESELECTION:
		pTargetReport->SetMultipleSelection(CPropertyRecordBool::GetValue(pItemNotify));
		break;
	case ID_PROPERTY_PREVIEWMODE:
		pTargetReport->EnablePreviewMode(CPropertyRecordBool::GetValue(pItemNotify));
		pTargetReport->Populate();
		break;
	case ID_PROPERTY_GROUPBOXVISIBLE:
		pTargetReport->ShowGroupBy(CPropertyRecordBool::GetValue(pItemNotify));
		break;
	case ID_PROPERTY_FOCUSSUBITEMS:
		pTargetReport->FocusSubItems(CPropertyRecordBool::GetValue(pItemNotify));
		break;
	case ID_PROPERTY_ALLOWCOLUMNREMOVE:
		pTargetReport->GetReportHeader()->AllowColumnRemove(CPropertyRecordBool::GetValue(pItemNotify));
		break;
	case ID_PROPERTY_ALLOWCOLUMNREORDER:
		pTargetReport->GetReportHeader()->AllowColumnReorder(CPropertyRecordBool::GetValue(pItemNotify));
		break;
	case ID_PROPERTY_ALLOWCOLUMNRESIZE:
		pTargetReport->GetReportHeader()->AllowColumnResize(CPropertyRecordBool::GetValue(pItemNotify));
		break;
	case ID_PROPERTY_FLATHEADER:
		pTargetReport->GetPaintManager()->SetColumnStyle((CPropertyRecordBool::GetValue(pItemNotify))? xtpReportColumnFlat: xtpReportColumnShaded);
		break;
	case ID_PROPERTY_HIDESELECTION:
		pTargetReport->GetPaintManager()->m_bHideSelection = (CPropertyRecordBool::GetValue(pItemNotify));
		break;
	case ID_PROPERTY_TREEINDENT:
		pTargetReport->GetPaintManager()->m_nTreeIndent = CPropertyRecordInt::GetValue(pItemNotify);
		pTargetReport->RedrawControl();
		break;
	case ID_PROPERTY_ITEM_TEXT:
		msgInf(_T("This is Text Item"));
		break;
	case ID_PROPERTY_ITEM_DOUBLE:
		msgInf(_T("This is Double Item"));
		break;
	case ID_PROPERTY_ITEM_INT:
		msgInf(_T("This is Int Item"));
		break;
	case ID_PROPERTY_ITEM_BOOL:
		msgInf(_T("This is Bool Item"));
		break;
	case ID_PROPERTY_ITEM_VARIANT:
		msgInf(_T("This is Variant Item"));
		break;
	}
}
