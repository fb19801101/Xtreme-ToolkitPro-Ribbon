// ReportFrame.cpp : implementation file
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
#include "ReportFrame.h"
#include "ReportRecordView.h"
#include "ReportRecord.h"
#include "Resource.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


/////////////////////////////////////////////////////////////////////////////
// CReportFrame

CReportFrame::CReportFrame(CView* pOwnerView)
{
	m_pOwnerView = pOwnerView;
}

CReportFrame::~CReportFrame()
{
}


BEGIN_MESSAGE_MAP(CReportFrame, CMiniFrameWnd)
	//{{AFX_MSG_MAP(CReportFrame)
	ON_WM_CREATE()
	ON_WM_DESTROY()

	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CReportFrame message handlers

int CReportFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (CMiniFrameWnd::OnCreate(lpCreateStruct) == -1)
		return -1;

	if (!InitCommandBars())
		return -1;

	CXTPCommandBars* pCommandBars = GetCommandBars();

	CXTPToolBar* pToolBar = pCommandBars->Add(_T("Options"), xtpBarTop);
	pToolBar->LoadToolBar(IDR_MENU_MINITOOLBAR, FALSE);
	pToolBar->SetCloseable(FALSE);

	return 0;
}

void CReportFrame::OnDestroy()
{
	((CReportRecordView*)m_pOwnerView)->m_pReportFrame = NULL;

	CMiniFrameWnd::OnDestroy();
}