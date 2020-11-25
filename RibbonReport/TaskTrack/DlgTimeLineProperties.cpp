// DlgTimeLineProperties.cpp : implementation file
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "DlgTimeLineProperties.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CDlgTimeLineProperties dialog


CDlgTimeLineProperties::CDlgTimeLineProperties(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgTimeLineProperties::IDD, pParent)
{
	//{{AFX_DATA_INIT(CDlgTimeLineProperties)
	m_nMin = 0;
	m_nMax = 0;
	//}}AFX_DATA_INIT
}


void CDlgTimeLineProperties::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CDlgTimeLineProperties)
	DDX_Text(pDX, IDC_PROPERTIES_ET_MIN, m_nMin);
	DDV_MinMaxInt(pDX, m_nMin, 0, 10000);
	DDX_Text(pDX, IDC_PROPERTIES_ET_MAX, m_nMax);
	DDV_MinMaxInt(pDX, m_nMax, 0, 10000);
	//}}AFX_DATA_MAP
	DDV_MinMaxInt(pDX, m_nMax, m_nMin + 1, 10000);
}


BEGIN_MESSAGE_MAP(CDlgTimeLineProperties, CDialog)
	//{{AFX_MSG_MAP(CDlgTimeLineProperties)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgTimeLineProperties message handlers
