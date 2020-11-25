// DlgMarkerProperties.cpp : implementation file
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "DlgMarkerProperties.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CDlgMarkerProperties dialog


CDlgMarkerProperties::CDlgMarkerProperties(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgMarkerProperties::IDD, pParent)
{
	//{{AFX_DATA_INIT(CDlgMarkerProperties)
	m_strCaption = _T("");
	m_nPosition = 0;
	//}}AFX_DATA_INIT
}


void CDlgMarkerProperties::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CDlgMarkerProperties)
	DDX_Text(pDX, IDC_MARKER_ET_CAPTION, m_strCaption);
	DDX_Text(pDX, IDC_MARKER_ET_POSITION, m_nPosition);
	DDV_MinMaxInt(pDX, m_nPosition, 0, 10000);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CDlgMarkerProperties, CDialog)
	//{{AFX_MSG_MAP(CDlgMarkerProperties)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgMarkerProperties message handlers
