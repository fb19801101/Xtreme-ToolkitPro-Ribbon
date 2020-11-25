// RibbonResourceView.cpp : implementation of the CRibbonResourceView class
//

#include "stdafx.h"
#include "RibbonResource.h"

#include "RibbonResourceDoc.h"
#include "RibbonResourceView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CRibbonResourceView

IMPLEMENT_DYNCREATE(CRibbonResourceView, CRichEditView)

BEGIN_MESSAGE_MAP(CRibbonResourceView, CRichEditView)
	//{{AFX_MSG_MAP(CRibbonResourceView)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	ON_WM_NCCALCSIZE()
	ON_WM_NCPAINT()
	//}}AFX_MSG_MAP
	// Standard printing commands
	ON_COMMAND(ID_FILE_PRINT, CRichEditView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, CRichEditView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, OnFilePrintPreview)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CRibbonResourceView construction/destruction

CRibbonResourceView::CRibbonResourceView()
{

	
	NONCLIENTMETRICS ncm = { sizeof(NONCLIENTMETRICS) };
	VERIFY(::SystemParametersInfo(SPI_GETNONCLIENTMETRICS, sizeof(NONCLIENTMETRICS), &ncm, 0));
	
	STRCPY_S(ncm.lfMessageFont.lfFaceName, LF_FACESIZE, _T("Courier New"));
	ncm.lfMessageFont.lfHeight = -14;
	
	m_fnt.CreateFontIndirect(&ncm.lfMessageFont);
}

CRibbonResourceView::~CRibbonResourceView()
{
}

BOOL CRibbonResourceView::PreCreateWindow(CREATESTRUCT& cs)
{
	if (!CRichEditView::PreCreateWindow(cs))
		return FALSE;

	//cs.dwExStyle &= ~WS_EX_CLIENTEDGE;
	//cs.style &= ~(ES_AUTOHSCROLL|WS_HSCROLL);	// Enable word-wrapping

	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs
	
	return TRUE;
}


/////////////////////////////////////////////////////////////////////////////
// CRibbonResourceView printing

BOOL CRibbonResourceView::OnPreparePrinting(CPrintInfo* pInfo)
{
	// default preparation
	return DoPreparePrinting(pInfo);
}
/////////////////////////////////////////////////////////////////////////////
// CRibbonResourceView diagnostics

#ifdef _DEBUG
void CRibbonResourceView::AssertValid() const
{
	CRichEditView::AssertValid();
}

void CRibbonResourceView::Dump(CDumpContext& dc) const
{
	CRichEditView::Dump(dc);
}

CRibbonResourceDoc* CRibbonResourceView::GetDocument() // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CRibbonResourceDoc)));
	return (CRibbonResourceDoc*)m_pDocument;
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CRibbonResourceView message handlers

void CRibbonResourceView::OnInitialUpdate() 
{
	CRichEditView::OnInitialUpdate();
	
	SetFont(&m_fnt);
	SendMessage(EM_SETTEXTMODE, TM_PLAINTEXT | TM_MULTILEVELUNDO);
	SendMessage(EM_SETEVENTMASK, 0, ENM_CHANGE);

	// Set the printing margins (720 twips = 1/2 inch).
	SetMargins(CRect(720, 720, 720, 720));

}


void CRibbonResourceView::OnFilePrintPreview()
{
	// In derived classes, implement special window handling here
	// Be sure to Unhook Frame Window close if hooked.
	
	// must not create this on the frame.  Must outlive this function
	CPrintPreviewState* pState = new CPrintPreviewState;
	
	// DoPrintPreview's return value does not necessarily indicate that
	// Print preview succeeded or failed, but rather what actions are necessary
	// at this point.  If DoPrintPreview returns TRUE, it means that
	// OnEndPrintPreview will be (or has already been) called and the
	// pState structure will be/has been deleted.
	// If DoPrintPreview returns FALSE, it means that OnEndPrintPreview
	// WILL NOT be called and that cleanup, including deleting pState
	// must be done here.
	
	if ( !DoPrintPreview( XTP_IDD_PREVIEW_DIALOGBAR, this,
		RUNTIME_CLASS( CXTPPreviewView ), pState ))
	{
		// In derived classes, reverse special window handling here for
		// Preview failure case
		TRACE0( "Error: DoPrintPreview failed.\n" );
		AfxMessageBox( AFX_IDP_COMMAND_FAILURE );
		delete pState;      // preview failed to initialize, delete State now

	}
}
