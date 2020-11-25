// CustomizePageQuickAccessToolbar.cpp : implementation file
//

#include "stdafx.h"
#include "ribbonsample.h"
#include "CustomizePageQuickAccessToolbar.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CCustomizePageQuickAccessToolbar property page

CCustomizePageQuickAccessToolbar::CCustomizePageQuickAccessToolbar(CXTPCommandBars* pCommandBars)
	: CXTPRibbonCustomizeQuickAccessPage(pCommandBars)
{
	//{{AFX_DATA_INIT(CCustomizePageQuickAccessToolbar)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}

CCustomizePageQuickAccessToolbar::~CCustomizePageQuickAccessToolbar()
{
}

void CCustomizePageQuickAccessToolbar::DoDataExchange(CDataExchange* pDX)
{
	CXTPRibbonCustomizeQuickAccessPage::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CCustomizePageQuickAccessToolbar)
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CCustomizePageQuickAccessToolbar, CXTPRibbonCustomizeQuickAccessPage)
	//{{AFX_MSG_MAP(CCustomizePageQuickAccessToolbar)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CCustomizePageQuickAccessToolbar message handlers

BOOL CCustomizePageQuickAccessToolbar::OnInitDialog() 
{
	CXTPRibbonCustomizeQuickAccessPage::OnInitDialog();
	

	return TRUE;
}