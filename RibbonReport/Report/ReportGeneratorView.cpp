// ReportGeneratorView.cpp : implementation of the CReportGeneratorView class
//

#include "stdafx.h"
#include "RibbonReport.h"

#include "MainFrm.h"

#include "RibbonReportDoc.h"
#include "ReportGeneratorView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CReportGeneratorView

IMPLEMENT_DYNCREATE(CReportGeneratorView, CView)

BEGIN_MESSAGE_MAP(CReportGeneratorView, CView)
	//{{AFX_MSG_MAP(CReportGeneratorView)
	//}}AFX_MSG_MAP
	// Standard printing commands
	ON_COMMAND(ID_FILE_PRINT, CView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, CView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, CView::OnFilePrintPreview)
	ON_COMMAND(ID_REPORT_GENERATOR, OnActiveRibbonReportView)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CReportGeneratorView construction/destruction

CReportGeneratorView::CReportGeneratorView()
{
	m_output = _T("A demonstration on how to add the report generator to a doc/view application.\r\n\r\nSelect Load report file from the filemenu, select a template file and then select Print or Print preview to see the report.");
}

CReportGeneratorView::~CReportGeneratorView()
{
}

BOOL CReportGeneratorView::PreCreateWindow(CREATESTRUCT& cs)
{
	return CView::PreCreateWindow(cs);
}

/////////////////////////////////////////////////////////////////////////////
// CReportGeneratorView drawing

void CReportGeneratorView::OnDraw(CDC* pDC)
{
	CRibbonReportDoc* pDoc = GetDocument();
	if(!pDoc) return;
	CRect rect;
	GetClientRect(rect);
	rect.InflateRect(- 8, -8);
	pDC->DrawText(m_output, rect, DT_WORDBREAK);
}

/////////////////////////////////////////////////////////////////////////////
// CReportGeneratorView printing

BOOL CReportGeneratorView::OnPreparePrinting(CPrintInfo* pInfo)
{
	// Setting up number of pages
	pInfo->SetMinPage(1);
	pInfo->SetMaxPage(m_rptGenerator.CalculatePages());

	// Default preparation
	return DoPreparePrinting(pInfo);
}

/////////////////////////////////////////////////////////////////////////////
// CReportGeneratorView diagnostics

#ifdef _DEBUG
void CReportGeneratorView::AssertValid() const
{
	CView::AssertValid();
}

void CReportGeneratorView::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}

CRibbonReportDoc* CReportGeneratorView::GetDocument() // non-debug version is inline
{
	if(m_pDocument->IsKindOf(RUNTIME_CLASS(CRibbonReportDoc)))
		return (CRibbonReportDoc*)m_pDocument;

	return NULL;
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CReportGeneratorView message handlers

void CReportGeneratorView::OnPrint(CDC* pDC, CPrintInfo* pInfo) 
{
	// Here, we print a single page to the printer or print preview
	m_rptGenerator.PrintPage(pDC, pInfo->m_nCurPage);
}

CRibbonReportView* CReportGeneratorView::GetReportRecordView()
{
	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();

	CRibbonReportView*& pView = pMaainFrame->m_pRibbonReportView;

	if(!pView->GetSafeHwnd()) return NULL;

	return pView;
}

void CReportGeneratorView::LoadReportFile() 
{
	XTPCHAR path[MAX_PATH];
	GetModuleFileName(AfxGetApp()->m_hInstance,path,MAX_PATH);
	CXTPString rpt(path);
	rpt = rpt.Mid(0,rpt.ReverseFind('\\'));
	rpt = rpt+"\\Report\\qty.rpt";

	if(m_rptGenerator.SetReportfile(rpt))
	{
		m_rptGenerator.Clear();
		CReportRecordView* pReportRecordView = GetReportRecordView();
		CXTPReportControl& wndReport = pReportRecordView->GetReportCtrl();
		CXTPReportRecords* pRecords = wndReport.GetRecords();
		if(pRecords)
		{
			int max = m_rptGenerator.GetTemplateSize(0);
			for(int t = 0; t < max; t++)
			{
				CString name = m_rptGenerator.GetFieldName(t);
				if(name.GetLength())
				{
					int type = m_rptGenerator.GetFieldType(name);
					switch (type)
					{
					case FIELD_TYPE_LABEL:
						{
							CXTPReportDrawObject* obj = m_rptGenerator.GetObject(name);
							obj->SetTitle(_T("已完工程数量表"));
						}
						break;
					case FIELD_TYPE_FIELD:
						{
							CXTPReportRecord* pRecord = pRecords->GetAt(0);
							if(pRecord)
							{
								if(name == _T("name"))
								{
									COleVariant vtVal = ((CXTPReportRecordItemVariant*)pRecord->GetItem(3))->GetValue();
									m_rptGenerator.Add(name, CString(vtVal.vt == VT_BSTR ? vtVal.bstrVal : NULL));
								}
								else if(name == _T("units"))
								{
									COleVariant vtVal = ((CXTPReportRecordItemVariant*)pRecord->GetItem(4))->GetValue();
									m_rptGenerator.Add(name, CString(vtVal.vt == VT_BSTR ? vtVal.bstrVal : NULL));
								}
							}
						}
						break;
					case FIELD_TYPE_GRID:
						{
							int columns = m_rptGenerator.GetFieldColumns(name);
							if(columns == 7)
							{
								int rs = pRecords->GetCount();
								CStringArray arr;
								for(int i=0; i<rs; i++)
								{
									CXTPReportRecord* pRecord = pRecords->GetAt(i);
									if(pRecord)
									{
										CString val,str;
										COleVariant vtVal = ((CXTPReportRecordItemVariant*)pRecord->GetItem(0))->GetValue();
										str.Format(_T("%s|"),CString(vtVal.vt == VT_BSTR ? vtVal.bstrVal : NULL));
										if (str.GetLength()>4)
											str = str.Mid(str.GetLength()-4,4);
										val += str;
										vtVal = ((CXTPReportRecordItemVariant*)pRecord->GetItem(4))->GetValue();
										str.Format(_T("%s|"),CString(vtVal.vt == VT_BSTR ? vtVal.bstrVal : NULL));
										val += str;
										vtVal = ((CXTPReportRecordItemVariant*)pRecord->GetItem(5))->GetValue();
										str.Format(_T("%s|"),CString(vtVal.vt == VT_BSTR ? vtVal.bstrVal : NULL));
										val += str;
										vtVal = ((CXTPReportRecordItemVariant*)pRecord->GetItem(6))->GetValue();
										str.Format(_T("%.3f|"),vtVal.vt == VT_R8 ? vtVal.dblVal : 0);
										val += str;
										vtVal = ((CXTPReportRecordItemVariant*)pRecord->GetItem(8))->GetValue();
										str.Format(_T("%.3f|"),vtVal.vt == VT_R8 ? vtVal.dblVal : 0);
										val += str;
										vtVal = ((CXTPReportRecordItemVariant*)pRecord->GetItem(10))->GetValue();
										str.Format(_T("%.3f|"),vtVal.vt == VT_R8 ? vtVal.dblVal : 0);
										val += str;
										vtVal = ((CXTPReportRecordItemVariant*)pRecord->GetItem(12))->GetValue();
										str.Format(_T("%s"),CString(vtVal.vt == VT_BSTR ? vtVal.bstrVal : NULL));
										val += str;
										arr.Add(val);
									}
								}
								m_rptGenerator.Add(name, arr);
							}
						}
						break;
					}
				}
			}
		}
	}
}

void CReportGeneratorView::OnActiveRibbonReportView()
{
	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
	if(pMaainFrame->IsActiveView((CView*)this))
		pMaainFrame->SetRibbonReportView();
}
