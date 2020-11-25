// DlgTrayIcon.cpp : implementation file
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
#include "DlgTrayIcon.h"
#include "MainFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

bool CDlgTrayIcon::m_bMinimized = false;
CDlgTrayIcon *CDlgTrayIcon::m_pInstance = NULL;

/////////////////////////////////////////////////////////////////////////////
// CDlgTrayIcon dialog

CDlgTrayIcon::CDlgTrayIcon(CWnd* pParentWnd /*=NULL*/)
	: CXTPResizeDialog(CDlgTrayIcon::IDD, pParentWnd)
{
	//{{AFX_DATA_INIT(CDlgTrayIcon)
	m_strToolTip = _T("Project Manager System v3.0!");

	m_bShowIcon = TRUE;
	m_bAnimateIcon = TRUE;
	m_bHideIcon = FALSE;

	m_strBalloonTitle = _T("");
	m_iTimeOut = 10;
	m_strBalloonMsg = _T("");

	m_iBalloonIcon = 1;
	//}}AFX_DATA_INIT

	m_strBalloonTitle.LoadString(IDS_TRAYICON_BALLOON_TITLE);
	m_strBalloonMsg.LoadString(IDS_TRAYICON_BALLOON_MESSAGE);

	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);

	m_pParentWnd = pParentWnd;

	m_pInstance = this;
}


void CDlgTrayIcon::DoDataExchange(CDataExchange* pDX)
{
	CXTPResizeDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CDlgTrayIcon)
	
	DDX_Control(pDX, IDC_TRAYICON_GP_TOOLTIP, m_gboxToolTip);
	DDX_Control(pDX, IDC_TRAYICON_ET_TOOLTIP, m_editTooltip);
	DDX_Control(pDX, IDC_TRAYICON_CK_SHOWICON, m_chkShowIcon);
	DDX_Control(pDX, IDC_TRAYICON_CK_ANIMATEICON, m_chkAnimateIcon);
	DDX_Control(pDX, IDC_TRAYICON_BN_TOOLTIP, m_btnTooltip);
	DDX_Control(pDX, IDC_TRAYICON_BN_MINIMIZETRAY, m_btnMinimizeToTray);
	DDX_Control(pDX, IDC_TRAYICON_TXT_INFO, m_txtInfo);
	DDX_Control(pDX, IDC_TRAYICON_CK_HIDEICON, m_chkHideIcon);

	DDX_Control(pDX, IDC_TRAYICON_GP_BALLOONTIP, m_gboxBalloonTip);
	DDX_Control(pDX, IDC_TRAYICON_TXT_BALLOONTITLE, m_txtBalloonTitle);
	DDX_Control(pDX, IDC_TRAYICON_ET_BALLOONTITLE, m_editBalloonTitle);
	DDX_Control(pDX, IDC_TRAYICON_TXT_TIMEOUT, m_txtTimeOut);
	DDX_Control(pDX, IDC_TRAYICON_ET_TIMEOUT, m_editTimeout);
	DDX_Control(pDX, IDC_TRAYICON_TXT_BALLOONMSG, m_txtBalloonMsg);
	DDX_Control(pDX, IDC_TRAYICON_ET_BALLOONMSG, m_editBalloonMsg);
	DDX_Control(pDX, IDC_TRAYICON_TXT_BALLOONICON, m_txtBalloonIcon);
	DDX_Control(pDX, IDC_TRAYICON_CB_BALLOONICON, m_comboBalloonIcon);
	DDX_Control(pDX, IDC_TRAYICON_BN_SHOWBALLOON, m_btnShowBalloon);

	DDX_Text(pDX, IDC_TRAYICON_ET_TOOLTIP, m_strToolTip);
	DDX_Check(pDX, IDC_TRAYICON_CK_SHOWICON, m_bShowIcon);
	DDX_Check(pDX, IDC_TRAYICON_CK_ANIMATEICON, m_bAnimateIcon);
	DDX_Check(pDX, IDC_TRAYICON_CK_HIDEICON, m_bHideIcon);

	DDX_Text(pDX, IDC_TRAYICON_ET_BALLOONTITLE, m_strBalloonTitle);
	DDX_Text(pDX, IDC_TRAYICON_ET_TIMEOUT, m_iTimeOut);
	DDX_Text(pDX, IDC_TRAYICON_ET_BALLOONMSG, m_strBalloonMsg);

	DDV_MaxChars(pDX, m_strBalloonTitle, 63);
	DDV_MaxChars(pDX, m_strBalloonMsg, 255);
	DDV_MinMaxInt(pDX, m_iTimeOut, 10, 30);

	DDX_CBIndex(pDX, IDC_TRAYICON_CB_BALLOONICON, m_iBalloonIcon);

	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CDlgTrayIcon, CXTPResizeDialog)
	//{{AFX_MSG_MAP(CDlgTrayIcon)
	ON_WM_DESTROY()
	ON_EN_CHANGE(IDC_TRAYICON_ET_TOOLTIP, OnChangeEditTooltip)
	ON_BN_CLICKED(IDC_TRAYICON_CK_SHOWICON, OnChkShowicon)
	ON_BN_CLICKED(IDC_TRAYICON_CK_ANIMATEICON, OnChkAnimateicon)
	ON_BN_CLICKED(IDC_TRAYICON_CK_HIDEICON, OnChkHideicon)
	ON_BN_CLICKED(IDC_TRAYICON_BN_TOOLTIP, OnBtnTooltip)
	ON_BN_CLICKED(IDC_TRAYICON_BN_SHOWBALLOON, OnBtnShowBalloon)
	ON_BN_CLICKED(IDC_TRAYICON_BN_MINIMIZETRAY, OnBtnMinimizetray)
	ON_EN_CHANGE(IDC_TRAYICON_ET_BALLOONTITLE, OnChangeEditBalloontitle)
	ON_EN_CHANGE(IDC_TRAYICON_ET_TIMEOUT, OnChangeEditTimeout)
	ON_EN_CHANGE(IDC_TRAYICON_ET_BALLOONMSG, OnChangeEditBalloonmsg)
	ON_CBN_SELENDOK(IDC_TRAYICON_CB_BALLOONICON, OnSelendokComboBalloonicon)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgTrayIcon message handlers

BOOL CDlgTrayIcon::OnInitDialog()
{
	CXTPResizeDialog::OnInitDialog();

	// Set the icon for this dialog.
	SetIcon(m_hIcon, TRUE);         // Set big icon
	SetIcon(m_hIcon, FALSE);        // Set small icon

	// Set control resizing.
	SetResize(IDC_TRAYICON_GP_TOOLTIP,       XTP_ANCHOR_TOPLEFT,     XTP_ANCHOR_TOPRIGHT);
	SetResize(IDC_TRAYICON_ET_TOOLTIP,       XTP_ANCHOR_TOPLEFT,     XTP_ANCHOR_TOPRIGHT);
	SetResize(IDC_TRAYICON_BN_TOOLTIP,       XTP_ANCHOR_TOPRIGHT,    XTP_ANCHOR_TOPRIGHT);
	SetResize(IDC_TRAYICON_BN_MINIMIZETRAY,  XTP_ANCHOR_TOPRIGHT,    XTP_ANCHOR_TOPRIGHT);
	SetResize(IDOK,                          XTP_ANCHOR_TOPRIGHT,    XTP_ANCHOR_TOPRIGHT);
	SetResize(IDC_TRAYICON_TXT_INFO,         XTP_ANCHOR_TOPLEFT,     XTP_ANCHOR_TOPRIGHT);
	SetResize(IDC_TRAYICON_GP_BALLOONTIP,    XTP_ANCHOR_TOPLEFT,     XTP_ANCHOR_TOPRIGHT);
	SetResize(IDC_TRAYICON_TXT_TIMEOUT,      XTP_ANCHOR_TOPRIGHT,    XTP_ANCHOR_TOPRIGHT);
	SetResize(IDC_TRAYICON_ET_BALLOONTITLE,  XTP_ANCHOR_TOPLEFT,     XTP_ANCHOR_TOPRIGHT);
	SetResize(IDC_TRAYICON_ET_TIMEOUT,       XTP_ANCHOR_TOPRIGHT,    XTP_ANCHOR_TOPRIGHT);
	SetResize(IDC_TRAYICON_ET_BALLOONMSG,    XTP_ANCHOR_TOPLEFT,     XTP_ANCHOR_BOTTOMRIGHT);
	SetResize(IDC_TRAYICON_TXT_BALLOONICON,  XTP_ANCHOR_BOTTOMLEFT,  XTP_ANCHOR_BOTTOMLEFT);
	SetResize(IDC_TRAYICON_CB_BALLOONICON,   XTP_ANCHOR_BOTTOMLEFT,  XTP_ANCHOR_BOTTOMRIGHT);
	SetResize(IDC_TRAYICON_BN_SHOWBALLOON,   XTP_ANCHOR_BOTTOMRIGHT, XTP_ANCHOR_BOTTOMRIGHT);

	// Load window placement
	LoadPlacement(_T("DlgTrayIcon"));
	EnableControls();

	// display the balloon tooltip.
	OnBtnTooltip();
	//OnBtnShowBalloon();

	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

void CDlgTrayIcon::OnDestroy()
{
	// Save window placement
	SavePlacement(_T("DlgTrayIcon"));

	m_pInstance = NULL;

	CXTPResizeDialog::OnDestroy();
}

void CDlgTrayIcon::OnChkShowicon()
{
	UpdateData();

	CMainFrame* pMainFrame = (CMainFrame*)AfxGetMainWnd();

	if (m_bShowIcon) {
		pMainFrame->m_wndTrayIcon.AddIcon();
	}
	else {
		pMainFrame->m_wndTrayIcon.RemoveIcon();
	}
}

void CDlgTrayIcon::OnChkAnimateicon()
{
	UpdateData();

	CMainFrame* pMainFrame = (CMainFrame*)AfxGetMainWnd();

	if (m_bAnimateIcon) {
		pMainFrame->m_wndTrayIcon.StartAnimation();
	}
	else {
		pMainFrame->m_wndTrayIcon.StopAnimation();
	}
}

void CDlgTrayIcon::OnChkHideicon()
{
	UpdateData();

	CMainFrame* pMainFrame = (CMainFrame*)AfxGetMainWnd();

	if (m_bHideIcon) {
		pMainFrame->m_wndTrayIcon.HideIcon();
	}
	else {
		pMainFrame->m_wndTrayIcon.ShowIcon();
	}
}

void CDlgTrayIcon::OnChangeEditTooltip()
{
	UpdateData();
}

void CDlgTrayIcon::OnBtnTooltip()
{
	UpdateData();

	CMainFrame* pMainFrame = (CMainFrame*)AfxGetMainWnd();

	pMainFrame->m_wndTrayIcon.SetTooltipText(m_strToolTip);
}

void CDlgTrayIcon::OnChangeEditBalloontitle()
{
	UpdateData();
}

void CDlgTrayIcon::OnChangeEditTimeout()
{
}

void CDlgTrayIcon::OnChangeEditBalloonmsg()
{
	UpdateData();
}

void CDlgTrayIcon::OnSelendokComboBalloonicon()
{
	UpdateData();
}

UINT balloonIcon[] =
{
	NIIF_ERROR,  // Error icon.
	NIIF_INFO,   // Information icon.
	NIIF_NONE,   // No icon.
	NIIF_WARNING // Warning icon.
};

void CDlgTrayIcon::OnBtnShowBalloon()
{
	if (!UpdateData())
		return;

	CMainFrame* pMainFrame = (CMainFrame*)AfxGetMainWnd();

	pMainFrame->m_wndTrayIcon.ShowBalloonTip(m_strBalloonMsg, m_strBalloonTitle,
		balloonIcon[m_iBalloonIcon], m_iTimeOut);

}

void CDlgTrayIcon::MinMaxWindow()
{
	CMainFrame* pMainFrame = (CMainFrame*)AfxGetMainWnd();

	m_bMinimized = !m_bMinimized;

	if (m_bMinimized)
	{
		pMainFrame->m_wndTrayIcon.MinimizeToTray(pMainFrame);
		if (m_pInstance)
		{
			m_pInstance->m_btnMinimizeToTray.SetWindowText(
				_T("&Maximize from Tray..."));
		}
	}
	else
	{
		pMainFrame->m_wndTrayIcon.MaximizeFromTray(pMainFrame);
		if (m_pInstance)
		{
			m_pInstance->m_btnMinimizeToTray.SetWindowText(
				_T("&Minimize to Tray..."));
		}
	}
}

void CDlgTrayIcon::OnBtnMinimizetray()
{
	MinMaxWindow();
}

void CDlgTrayIcon::EnableControls()
{
	CMainFrame* pMainFrame = (CMainFrame*)AfxGetMainWnd();
	BOOL bEnable = pMainFrame->m_wndTrayIcon.IsShellVersion5();

	// Requirements:
	// Windows 2000 or later, VC6 with platform SDK or
	// later to use these features.

	m_chkHideIcon.      EnableWindow(bEnable);
	m_txtBalloonTitle.  EnableWindow(bEnable);
	m_editBalloonTitle. EnableWindow(bEnable);
	m_txtTimeOut.       EnableWindow(bEnable);
	m_editTimeout.      EnableWindow(bEnable);
	m_txtBalloonMsg.    EnableWindow(bEnable);
	m_editBalloonMsg.   EnableWindow(bEnable);
	m_txtBalloonIcon.   EnableWindow(bEnable);
	m_comboBalloonIcon. EnableWindow(bEnable);
	m_btnShowBalloon.   EnableWindow(bEnable);

	m_editBalloonMsg.SetBackColor(bEnable ?
		GetXtremeColor(COLOR_WINDOW) : GetXtremeColor(COLOR_3DFACE));
}

INT_PTR CDlgTrayIcon::DoModal(CWnd* pParentWnd)
{
	m_pParentWnd = pParentWnd;
	return CXTPResizeDialog::DoModal();
}
