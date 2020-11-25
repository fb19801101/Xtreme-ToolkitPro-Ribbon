// CustomizePageRibbon.cpp : implementation file
//

#include "stdafx.h"
#include "ribbonsample.h"
#include "CustomizePageRibbon.h"
#include "Mainfrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CCustomizePageRibbon property page


CCustomizePageRibbon::CCustomizePageRibbon(CXTPCommandBars* pCommandBars) : CXTPRibbonCustomizePage(pCommandBars)
{
	//{{AFX_DATA_INIT(CCustomizePageRibbon)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}

CCustomizePageRibbon::~CCustomizePageRibbon()
{
}

void CCustomizePageRibbon::DoDataExchange(CDataExchange* pDX)
{
	CXTPRibbonCustomizePage::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CCustomizePageRibbon)
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CCustomizePageRibbon, CXTPRibbonCustomizePage)
	//{{AFX_MSG_MAP(CCustomizePageRibbon)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CCustomizePageRibbon message handlers

BOOL CCustomizePageRibbon::OnInitDialog() 
{
	CXTPRibbonCustomizePage::OnInitDialog();
	
	return TRUE;
}

