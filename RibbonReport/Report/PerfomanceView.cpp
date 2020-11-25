// PerfomanceView.cpp : implementation file
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
#include "PerfomanceView.h"
#include "ReportFrame.h"
#include "ReportRecord.h"
#include "Resource.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


/////////////////////////////////////////////////////////////////////////////
// CPerfomanceView

IMPLEMENT_DYNCREATE(CPerfomanceView, CReportRecordView)

CPerfomanceView::CPerfomanceView()
{
	m_pItem = NULL;
	m_bDblClickClose = TRUE;
}

CPerfomanceView::~CPerfomanceView()
{
}

BEGIN_MESSAGE_MAP(CPerfomanceView, CReportRecordView)
	//{{AFX_MSG_MAP(CPerfomanceView)
	ON_NOTIFY(NM_DBLCLK, XTP_ID_REPORT_CONTROL, OnReportItemDblClick)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPerfomanceView drawing

void CPerfomanceView::OnDraw(CDC*)
{
}

/////////////////////////////////////////////////////////////////////////////
// CPerfomanceView diagnostics

#ifdef _DEBUG
void CPerfomanceView::AssertValid() const
{
	CReportRecordView::AssertValid();
}

void CPerfomanceView::Dump(CDumpContext& dc) const
{
	CReportRecordView::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CPerfomanceView message handlers

CReportRecordView* CPerfomanceView::GetTargetReportView()
{
	return (CReportRecordView*)((CReportFrame*)GetParent())->m_pOwnerView;
}

void CPerfomanceView::OnReportItemDblClick(NMHDR* pNMHDR, LRESULT* /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pItemNotify = (XTP_NM_REPORTRECORDITEM*) pNMHDR;
	if(!pItemNotify->pRow || !pItemNotify->pItem) return;

	CXTPReportControl& wndReport = GetReportCtrl();
	if(wndReport.IsFocusSubItems())
	{
		COleVariant vtValue = ((CXTPReportRecordItemVariant*)pItemNotify->pItem)->GetValue();
		if(m_pItem) m_pItem->SetValue(vtValue);
	}
	else
	{
		COleVariant vtValue = ((CXTPReportRecordItemVariant*)pItemNotify->pRow->GetRecord()->GetItem(0))->GetValue();
		if(m_pItem) m_pItem->SetValue(vtValue);
	}

	CXTPReportRecord* pSelItemRcd = m_pItem->GetRecord();
	if(!pSelItemRcd) return;

	CReportRecordView* pTargetReportView = GetTargetReportView();
	if(pTargetReportView != NULL)
	{
		CString strTable = pTargetReportView->GetCurTable();
		CString field = GetFieldName(strTable,m_pItem->GetIndex()+1);
		COleVariant val = ((CXTPReportRecordItemVariant*)pSelItemRcd->GetItem(0))->GetValue();
		switch (val.vt)
		{
		case VT_BSTR:
			{
				CString code = val.bstrVal;
				SetRecordset(strTable,field,code,((CXTPReportRecordItemVariant*)m_pItem)->GetValue());
			}
			break;
		case VT_I4:
			{
				int id = val.lVal;
				SetRecordset(strTable,field,id,((CXTPReportRecordItemVariant*)m_pItem)->GetValue());
			}
			break;
		}

		pTargetReportView->UpdateRecord(pSelItemRcd);

		if(m_bDblClickClose)
		{
			//GetParent()->SendMessage(WM_CLOSE);
			::PostMessage(GetParent()->m_hWnd, WM_CLOSE, 0, 0);
		}
	}
}

void CPerfomanceView::SetRecordItem(CXTPReportRecordItemVariant*& pItem)
{
	m_pItem = pItem;
}