// DlgFormula.cpp : implementation of the CDlgFormula class
//
// This file is a part of the XTREME TOOLKIT PRO MFC class library.
// (c)1998-2012 Codejock Software, All Rights Reserved.
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
#include "DlgFormula.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


/////////////////////////////////////////////////////////////////////////////
// CDlgFormula dialog


CDlgFormula::CDlgFormula(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgFormula::IDD, pParent)
{
	//{{AFX_DATA_INIT(CDlgFormula)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CDlgFormula::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CDlgFormula)
	DDX_Control(pDX, IDC_REPORT_CONTROL, m_wndReport);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CDlgFormula, CDialog)
	//{{AFX_MSG_MAP(CDlgFormula)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgFormula message handlers

BOOL CDlgFormula::OnInitDialog()
{
	CDialog::OnInitDialog();

	CXTPReportColumn *pColumnProduct = m_wndReport.AddColumn(new CXTPReportColumn(0, _T("Product"), 150));
	CXTPReportColumn *pColumnState   = m_wndReport.AddColumn(new CXTPReportColumn(1, _T("State"),   150));
	CXTPReportColumn *pColumnSales   = m_wndReport.AddColumn(new CXTPReportColumn(2, _T("Sales"),   150));

	pColumnState->SetAlignment(DT_RIGHT);
	//pColumnState->SetAlignment(DT_LEFT);

	struct Item 
	{
		LPCTSTR pszProduct;
		LPCTSTR pszState;
		double fSales;
	};

	Item items[] = {
		{_T("Pen"),		_T("NSW"), 20.5},
		{_T("Paper"),	_T("NSW"), 10.2},
		{_T("Books"),	_T("NSW"), 10.2},

		{_T("Pen"),		_T("SA"), 20.2},
		{_T("Paper"),	_T("SA"), 10.2},
		{_T("Books"),	_T("SA"), 10.2},
		
		{_T("Pen"),		_T("WA"), 20.0},
		{_T("Paper"),	_T("WA"), 10.0},
		{_T("Books"),	_T("WA"), 10.0},
	};

	CXTPReportRecord *pRecord;
	int i;

	for (i=0; i<_countof(items); i++)
	{
		pRecord = m_wndReport.AddRecord(new CXTPReportRecord());
		pRecord->AddItem(new CXTPReportRecordItemText(items[i].pszProduct));
		pRecord->AddItem(new CXTPReportRecordItemText(items[i].pszState));
		pRecord->AddItem(new CXTPReportRecordItemNumber(items[i].fSales,_T("%.1f")));
	}

	m_wndReport.GetColumns()->GetGroupsOrder()->Add(pColumnProduct);
	m_wndReport.Populate();

	for (i=0; i<m_wndReport.GetRows()->GetCount(); i++)
	{
		CXTPReportRow *pRow = m_wndReport.GetRows()->GetAt(i);

		if (pRow->IsGroupRow())
		{
			CXTPReportGroupRow *pGroupRow = reinterpret_cast<CXTPReportGroupRow*>(pRow);
			pGroupRow->SetFormatString(_T(" Subtotal $=%.1f"));
			pGroupRow->SetFormula(_T("SUMSUB(R*C1:R*C8)"));
			pGroupRow->SetCaption(_T("x"));
		}
	}

	return FALSE;
}

void CDlgFormula::OnOK()
{
	CDialog::OnOK();
}
