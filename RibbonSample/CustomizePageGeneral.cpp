// CustomizePageGeneral.cpp : implementation file
//

#include "stdafx.h"

#include "RibbonSample.h"
#include "CustomizePageGeneral.h"
#include "MainFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CCustomizePageGeneral property page

IMPLEMENT_DYNCREATE(CCustomizePageGeneral, CXTPPropertyPage)

CCustomizePageGeneral::CCustomizePageGeneral() : CXTPPropertyPage(CCustomizePageGeneral::IDD)
{
	//{{AFX_DATA_INIT(CCustomizePageGeneral)
	m_bShowKeyboardTips = FALSE;
	m_bShowMiniToolbar = FALSE;
	m_nColor = -1;
	//}}AFX_DATA_INIT
}

CCustomizePageGeneral::~CCustomizePageGeneral()
{
}

void CCustomizePageGeneral::DoDataExchange(CDataExchange* pDX)
{
	CXTPPropertyPage::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CCustomizePageGeneral)
	DDX_Check(pDX, IDC_CHECK_SHOWEYBOARDTIPS, m_bShowKeyboardTips);
	DDX_Check(pDX, IDC_CHECK_SHOWMINITOOLBAR, m_bShowMiniToolbar);
	DDX_Control(pDX, IDC_CAPTION_1, m_wndCaption1);
	DDX_Control(pDX, IDC_TITLE, m_wndTitle);
	DDX_CBIndex(pDX, IDC_COMBO_COLOR, m_nColor);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CCustomizePageGeneral, CXTPPropertyPage)
	//{{AFX_MSG_MAP(CCustomizePageGeneral)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CCustomizePageGeneral message handlers
BOOL CCustomizePageGeneral::OnInitDialog() 
{
	CXTPPropertyPage::OnInitDialog();
	

	ModifyStyle(0, WS_CLIPCHILDREN | WS_VSCROLL);
	
	SetResize(IDC_CAPTION_1, XTP_ANCHOR_TOPLEFT, XTP_ANCHOR_TOPRIGHT);

	m_wndTitle.SetMarkupTextEx(_T("<StackPanel Orientation='Horizontal'><Image Source='res://IDB_OPTIONSICON_GENERAL'/>")
		_T("<TextBlock Padding='3, 0, 0, 0' FontSize='13' VerticalAlignment='Center'>%s</TextBlock></StackPanel>"));

	m_wndCaption1.SetMarkupTextEx(_T("<Grid Background='#f0f2f5'>")
		_T("<TextBlock Padding='5, 0, 0, 0' FontWeight='Bold'  Foreground='#3b3b3b' VerticalAlignment='Center'>%s</TextBlock>")
		_T("<Border Height='1' Background='#e2e4e7' VerticalAlignment='Bottom'/></Grid>"));


	CMainFrame* pMainFrame = (CMainFrame*)AfxGetMainWnd();

	m_bShowMiniToolbar = pMainFrame->m_bShowMiniToolbar;
	m_bShowKeyboardTips = pMainFrame->GetCommandBars()->GetCommandBarsOptions()->bShowKeyboardTips;
	m_nColor = pMainFrame->m_nRibbonStyle - ID_OPTIONS_STYLEBLUE2007;

	UpdateData(FALSE);
	
	return TRUE;  // return TRUE unless you set the focus to a control
	// EXCEPTION: OCX Property Pages should return FALSE
}

void CCustomizePageGeneral::OnOK() 
{
	UpdateData();
	CMainFrame* pMainFrame = (CMainFrame*)AfxGetMainWnd();

	pMainFrame->m_bShowMiniToolbar = m_bShowMiniToolbar;
	pMainFrame->GetCommandBars()->GetCommandBarsOptions()->bShowKeyboardTips = m_bShowKeyboardTips;

	if (m_nColor != (int)pMainFrame->m_nRibbonStyle - ID_OPTIONS_STYLEBLUE2007)
	{
		pMainFrame->OnOptionsStyle(m_nColor + ID_OPTIONS_STYLEBLUE2007);
	}
	
	
	CXTPPropertyPage::OnOK();
}
