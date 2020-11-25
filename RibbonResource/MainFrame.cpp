// MainFrame.cpp : implementation of the CMainFrame class
//

#include "stdafx.h"
#include "RibbonResource.h"

#include "MainFrame.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CMainFrame

IMPLEMENT_DYNAMIC(CMainFrame, CXTPMDIFrameWnd)

BEGIN_MESSAGE_MAP(CMainFrame, CXTPMDIFrameWnd)
	//{{AFX_MSG_MAP(CMainFrame)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	ON_WM_CREATE()
	//}}AFX_MSG_MAP

	ON_COMMAND_RANGE(ID_VIEW_APPLOOK_OFF_2007_BLUE, ID_VIEW_APPLOOK_WINDOWS_7, OnApplicationLook)
	ON_UPDATE_COMMAND_UI_RANGE(ID_VIEW_APPLOOK_OFF_2007_BLUE, ID_VIEW_APPLOOK_WINDOWS_7, OnUpdateApplicationLook)

END_MESSAGE_MAP()

static UINT indicators[] =
{
	ID_SEPARATOR,           // status line indicator
	ID_INDICATOR_CAPS,
	ID_INDICATOR_NUM,
	ID_INDICATOR_SCRL,
};


/////////////////////////////////////////////////////////////////////////////
// CMainFrame construction/destruction
CMainFrame::CMainFrame()
{
	m_nAppLook = 0;


	TCHAR szStylesPath[_MAX_PATH];
	
	VERIFY(::GetModuleFileName(
		AfxGetApp()->m_hInstance, szStylesPath, _MAX_PATH));		
	
	CString csStylesPath(szStylesPath);
	int nIndex  = csStylesPath.ReverseFind(_T('\\'));
	if (nIndex > 0) {
		csStylesPath = csStylesPath.Left(nIndex);
	}
	else {
		csStylesPath.Empty();
	}
	m_csStylesPath += csStylesPath + _T("\\Styles\\");
}

CMainFrame::~CMainFrame()
{
}

int CMainFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (CXTPMDIFrameWnd::OnCreate(lpCreateStruct) == -1)
		return -1;

	if (!m_wndStatusBar.Create(this) ||
		!m_wndStatusBar.SetIndicators(indicators,
		  sizeof(indicators)/sizeof(UINT)))
	{
		TRACE0("Failed to create status bar\n");
		return -1;      // fail to create
	}

	if (!InitCommandBars())
		return -1;
	
	CXTPCommandBars* pCommandBars = GetCommandBars();
	

	XTPPaintManager()->SetTheme(xtpThemeRibbon);


	CXTPRibbonBar* pRibbonBar = (CXTPRibbonBar*)pCommandBars->Add(_T("The Ribbon"), xtpBarTop, RUNTIME_CLASS(CXTPRibbonBar));
	if (!pRibbonBar)
	{
		return FALSE;
	}

	CXTPRibbonBuilder builder;
	if (builder.LoadFromResource(IDR_RIBBON))
	{
		builder.Build(pRibbonBar);
	}
	
	
	pRibbonBar->EnableDocking(0);
	pRibbonBar->EnableFrameTheme();

	pCommandBars->GetCommandBarsOptions()->bShowKeyboardTips = TRUE;


	// Enable MDI tabs.
	VERIFY(m_wndTabClient.Attach(this, TRUE));
	m_wndTabClient.EnableToolTips();


	OnApplicationLook(ID_VIEW_APPLOOK_WINDOWS_7);

	return 0;
}

BOOL CMainFrame::PreCreateWindow(CREATESTRUCT& cs)
{
	if( !CXTPMDIFrameWnd::PreCreateWindow(cs) )
		return FALSE;
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// CMainFrame diagnostics

#ifdef _DEBUG
void CMainFrame::AssertValid() const
{
	CXTPMDIFrameWnd::AssertValid();
}

void CMainFrame::Dump(CDumpContext& dc) const
{
	CXTPMDIFrameWnd::Dump(dc);
}

#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CMainFrame message handlers


void CMainFrame::OnApplicationLook(UINT nStyle)
{
	CWaitCursor wait;
	
	m_nAppLook = nStyle;

	HMODULE hModule = AfxGetInstanceHandle();

	
	LPCTSTR lpszIniFile = 0;
	switch (nStyle)
	{
	case ID_VIEW_APPLOOK_OFF_2007_BLUE: 
		lpszIniFile = _T("OFFICE2007BLUE.INI"); break;
	
	case ID_VIEW_APPLOOK_OFF_2007_BLACK: 
		lpszIniFile = _T("OFFICE2007BLACK.INI"); break;
	
	case ID_VIEW_APPLOOK_OFF_2007_AQUA: 
		lpszIniFile = _T("OFFICE2007AQUA.INI"); break;
	
	case ID_VIEW_APPLOOK_OFF_2007_SILVER: 
		lpszIniFile = _T("OFFICE2007SILVER.INI"); break;

	case ID_VIEW_APPLOOK_WINDOWS_7: 
		hModule = LoadLibrary(m_csStylesPath + _T("Windows7.dll"));
		lpszIniFile = _T("WINDOWS7BLUE.INI"); break;
	}
	
	
	XTPResourceImages()->SetHandle(hModule, lpszIniFile);
	
	XTPPaintManager()->RefreshMetrics();
	GetCommandBars()->GetImageManager()->RefreshAll();
	GetCommandBars()->RedrawCommandBars();
	
	m_wndTabClient.GetPaintManager()->RefreshMetrics();
	

	
	RedrawWindow(0, 0, RDW_ALLCHILDREN|RDW_INVALIDATE);
	
	AfxGetApp()->WriteProfileInt(_T("Settings"), _T("ApplicationLook"), m_nAppLook);
}

void CMainFrame::OnUpdateApplicationLook(CCmdUI* pCmdUI)
{
	pCmdUI->SetRadio(m_nAppLook == pCmdUI->m_nID);
}