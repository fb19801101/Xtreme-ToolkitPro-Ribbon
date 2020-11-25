// DlgTaskPanel.cpp : implementation file
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
#include "DlgTaskPanel.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CDlgTaskPanel dialog


CDlgTaskPanel::CDlgTaskPanel(CWnd* pParent /*=NULL*/)
	: CDialog((UINT)0, pParent)
{
	//{{AFX_DATA_INIT(CDlgTaskPanel)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	m_pItem = 0;
}


void CDlgTaskPanel::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CDlgTaskPanel)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CDlgTaskPanel, CDialog)
	//{{AFX_MSG_MAP(CDlgTaskPanel)
	ON_WM_SIZE()
	ON_WM_ERASEBKGND()
	ON_WM_CTLCOLOR()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgTaskPanel message handlers

void CDlgTaskPanel::OnSize(UINT nType, int cx, int cy)
{
	CDialog::OnSize(nType, cx, cy);

	Invalidate(FALSE);

}

void CDlgTaskPanel::UpdateColors()
{
	if (!m_pItem)
		return;

	COLORREF clrBack = m_pItem->GetBackColor();

	if (!m_brushBack.GetSafeHandle() || clrBack != m_clrBack)
	{
		m_brushBack.DeleteObject();
		m_brushBack.CreateSolidBrush(clrBack);
		m_clrBack = clrBack;
	}
}


BOOL CDlgTaskPanel::OnEraseBkgnd(CDC* pDC)
{
	UpdateColors();

	pDC->FillSolidRect(CXTPClientRect(this), m_clrBack);

	return TRUE;
}

HBRUSH CDlgTaskPanel::OnCtlColor(CDC* pDC, CWnd* pWnd, UINT nCtlColor)
{
	if (nCtlColor != CTLCOLOR_BTN && nCtlColor !=CTLCOLOR_STATIC)
		return CDialog::OnCtlColor(pDC, pWnd, nCtlColor);

	UpdateColors();
	pDC->SetBkMode(TRANSPARENT);

	return m_brushBack;
}
