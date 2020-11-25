// RibbonResourceDoc.cpp : implementation of the CRibbonResourceDoc class
//

#include "stdafx.h"
#include "RibbonResource.h"

#include "RibbonResourceDoc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CRibbonResourceDoc

IMPLEMENT_DYNCREATE(CRibbonResourceDoc, CDocument)

BEGIN_MESSAGE_MAP(CRibbonResourceDoc, CDocument)
	//{{AFX_MSG_MAP(CRibbonResourceDoc)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CRibbonResourceDoc construction/destruction

CRibbonResourceDoc::CRibbonResourceDoc()
{
	// TODO: add one-time construction code here

}

CRibbonResourceDoc::~CRibbonResourceDoc()
{
}

BOOL CRibbonResourceDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;

	// TODO: add reinitialization code here
	// (SDI documents will reuse this document)

	return TRUE;
}


CRichEditCntrItem* CRibbonResourceDoc::CreateClientItem(REOBJECT* preo) const
{
	// cast away constness of this
	return new CRichEditCntrItem(preo, (CRibbonResourceDoc*) this);
}




/////////////////////////////////////////////////////////////////////////////
// CRibbonResourceDoc serialization

void CRibbonResourceDoc::Serialize(CArchive& ar)
{
	CRichEditDoc::Serialize(ar);
	
}

/////////////////////////////////////////////////////////////////////////////
// CRibbonResourceDoc diagnostics

#ifdef _DEBUG
void CRibbonResourceDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CRibbonResourceDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CRibbonResourceDoc commands
