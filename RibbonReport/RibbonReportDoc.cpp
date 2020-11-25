// RibbonReportDoc.cpp : implementation of the CRibbonReportDoc class
//

#include "stdafx.h"
#include "RibbonReport.h"

#include "RibbonReportDoc.h"
#include "RibbonReportView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CRibbonReportDoc

IMPLEMENT_DYNCREATE(CRibbonReportDoc, CDocument)

BEGIN_MESSAGE_MAP(CRibbonReportDoc, CDocument)
	//{{AFX_MSG_MAP(CReportSampleDoc)
	// NOTE - the ClassWizard will add and remove mapping macros here.
	//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CRibbonReportDoc construction/destruction

CRibbonReportDoc::CRibbonReportDoc()
{
	// TODO: add one-time construction code here

}

CRibbonReportDoc::~CRibbonReportDoc()
{
}

BOOL CRibbonReportDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	// TODO: add reinitialization code here
	// (SDI documents will reuse this document)

	return TRUE;
}



/////////////////////////////////////////////////////////////////////////////
// CRibbonReportDoc serialization

void CRibbonReportDoc::Serialize(CArchive& ar)
{
	POSITION pos = GetFirstViewPosition();
	while (pos != NULL)
	{
		CView* pView = GetNextView(pos);
		CRibbonReportView* pRibbonReportView = DYNAMIC_DOWNCAST(CRibbonReportView, pView);
		pRibbonReportView->GetReportCtrl().SerializeState(ar);
	}
}

/////////////////////////////////////////////////////////////////////////////
// CRibbonReportDoc diagnostics

#ifdef _DEBUG
void CRibbonReportDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CRibbonReportDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CRibbonReportDoc commands
