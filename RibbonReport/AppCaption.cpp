// AppCaption.cpp : implementation file
//

#include "stdafx.h"
#include "RibbonProject.h"
#include "AppCaption.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CAppCaption

CAppCaption::CAppCaption()
{

	m_strTime = CTime::GetCurrentTime().Format(_T("%Y-%m-%d %H:%M:%S"));
	m_strContent = _T("中铁十二局集团第一工程有限公司欢迎您！         ");

	LOGFONT lf;
	//XTPAuxData().fontBold.GetLogFont(&lf);
	XTPDrawHelpers()->GetIconLogFont(&lf);
	STRCPY_S(lf.lfFaceName, LF_FACESIZE, _T("Segoe UI"));
	lf.lfHeight = 18;
	m_ftCaption.CreateFontIndirect(&lf);
}

CAppCaption::~CAppCaption()
{
	::KillTimer(NULL, m_nIDTimer);
}


void CAppCaption::OnUpdateCmdUI(CFrameWnd* pTarget, BOOL bDisableIfNoHndler)
{
	// update the dialog controls added to the status bar
	UpdateDialogControls(pTarget, bDisableIfNoHndler);
}

void CAppCaption::Create(CWnd* pParentWnd)
{
	m_dwStyle = CBRS_TOP;

	CControlBar::Create(AfxRegisterWndClass(0, AfxGetApp()->LoadStandardCursor(IDC_ARROW)), 0, WS_CHILD | WS_VISIBLE| CBRS_TOP, 
		CRect(0, 0, 0, 0), pParentWnd, 0xE806);

	m_nIDTimer = SetTimer(1, 1000, NULL);
}

CSize CAppCaption::CalcFixedLayout(BOOL, BOOL /*bHorz*/)
{
	ASSERT_RET(this, CSize());
	ASSERT_RET(::IsWindow(m_hWnd), CSize());
	
	CSize size(32767, 23);
	return size;
}



BEGIN_MESSAGE_MAP(CAppCaption, CControlBar)
	//{{AFX_MSG_MAP(CAppCaption)
	ON_WM_PAINT()
	ON_WM_TIMER()
	ON_WM_SIZE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// CAppCaption message handlers

void CAppCaption::OnPaint()
{
	CPaintDC dcPaint(this); // device context for painting
	
	CXTPBufferDC dc(dcPaint);
	
	CXTPFontDC font(&dc, &m_ftCaption);

	CXTPClientRect rc(this);

	dc.FillSolidRect(rc, RGB(227,239,255));
	rc.DeflateRect(10, 0);
	
	dc.SetBkMode(TRANSPARENT);
	dc.SetTextColor(0);
	dc.DrawText(m_strContent+m_strTime, rc, DT_VCENTER | DT_SINGLELINE | DT_END_ELLIPSIS | DT_NOPREFIX);
}

void CAppCaption::SetContent(CString str)
{
	m_strContent = str;
	Invalidate();
}

void CAppCaption::OnTimer(UINT_PTR nIDEvent)
{
	m_strTime = CTime::GetCurrentTime().Format(_T("%Y-%m-%d %H:%M:%S"));
	Invalidate();
}

void CAppCaption::OnSize(UINT nType, int cx, int cy)
{
	CControlBar::OnSize(nType, cx, cy);
	Invalidate(FALSE);
}
