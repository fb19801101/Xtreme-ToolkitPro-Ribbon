// ReportRecordView.cpp : implementation of the CReportRecordView class
//
// This file is a part of the XTREME TOOLKIT PRO MFC class library.
// (c)1998-2011 Codejock Software, All Rights Reserved.
//
// THIS SOURCE FILE IS THE PROPERTY OF CODEJOCK SOFTWARE AND IS NOT TO BE
// RE-DISTRIBUTED BY ANY MEANS WHATSOEVER WITHOUT THE EXPRESSED WRITTEN
// CONSENT OF CODEJOCK SOFTWARE.
//
// THIS SOURCE CODE CAN ONLY BE USED UNDER THE TERMS AND CONDITIONS OUTLINED
// IN THE XTREME TOOLKIT PRO LICENSE AGREEMENT. CODEJOCK SOFTWARE GRANTS TO
// YOU (ONE SOFTWARE DEVELOPER) THE LIMITED RIGHT TO USE THIS SOFTWARE ON A
// SINGLE COMPUTER.
//
// CONTACT INFORMATION:
// support@codejock.com
// http://www.codejock.com
//
/////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "RibbonReport.h"
#include "ReportRecord.h"

#include "MainFrm.h"
#include "ReportFrame.h"

#include "RibbonReportDoc.h"
#include "ReportRecordView.h"
#include "ReportRecordPaintManager.h"
#include "DlgTreeEdit.h"
#include "DlgDragDrop.h"
#include "DlgFormula.h"
#include "DlgPropertyGrid.h"
#include "MergeView.h"
#include "PerfomanceView.h"
#include "PropertiesView.h"
#include "atldbcli.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


CString cstrMarkupLong(
	_T("<StackPanel Margin='5, 5, 5, 5' VerticalAlignment='Top'")
	_T("HorizontalAlignment='Center'>")
	_T("<TextBlock Padding='0,10,0,0' TextWrapping='Wrap'><Bold>Subject:</Bold> ")
	_T("<Bold>SuitePro</Bold> <Run Foreground='Red'>2009</Run> ")
	_T("Released!</TextBlock>")
	_T("<TextBlock Padding='0,10,0,0'><Bold>Body:</Bold></TextBlock>")
	_T("<TextBlock Padding='10,10,0,0' TextWrapping='Wrap'>")
	_T("<Bold><Run Foreground='Blue'>Codejock</Run> Software</Bold> released ")
	_T("<Bold>SuitePro</Bold> <Run Foreground='Red'>2009</Run> today.  All")
	_T(" development machines <Bold>must</Bold> be updated no later than ")
	_T("<Run Foreground='Red'>06/15/08</Run>.")
	_T("</TextBlock>")
	_T("<TextBlock Padding='10,10,0,0'>")
	_T("   - Management")
	_T("</TextBlock>")
	_T("</StackPanel>"));

CString cstrMarkupShort(
	_T("<StackPanel VerticalAlignment='Top' HorizontalAlignment='Center'>")
	_T("<TextBlock><Bold>Subject:</Bold> ")
	_T("<Italic>SuitePro</Italic> <Run Foreground='Red'>2009</Run> ")
	_T("Released!</TextBlock>")
	_T("</StackPanel>"));



class CTaskPanelIconItem : public CXTPTaskPanelGroupItem
{
public:
	CTaskPanelIconItem(HICON hIcon)
	{
		m_hIcon = hIcon;

	}

	~CTaskPanelIconItem()
	{
		DestroyIcon(m_hIcon);
	}

	CRect OnReposition(CRect rc)
	{
		m_rcItem =  rc;
		m_rcItem.bottom = m_rcItem.top + 32;

		return m_rcItem;
	}
	void OnDrawItem(CDC* pDC, CRect rc)
	{
		pDC->DrawState(CPoint(rc.CenterPoint().x - 16, rc.CenterPoint().y - 16), 0, m_hIcon, 0, (CBrush*)NULL);
	}

	HICON m_hIcon;
};


/////////////////////////////////////////////////////////////////////////////
// CReportRecordView

extern CXTPADOConnection theCon;
IMPLEMENT_DYNCREATE(CReportRecordView, CXTPReportView)

BEGIN_MESSAGE_MAP(CReportRecordView, CXTPReportView)
	//{{AFX_MSG_MAP(CReportRecordView)
	ON_WM_KEYDOWN()
	ON_NOTIFY(XTP_NM_REPORT_FOCUS_CHANGING, XTP_ID_REPORT_CONTROL, OnReportFoucsChanging)
	ON_NOTIFY(XTP_NM_REPORT_VALUECHANGED, XTP_ID_REPORT_CONTROL, OnReportValueChanged)
	ON_NOTIFY(XTP_NM_REPORT_HEADER_RCLICK, XTP_ID_REPORT_CONTROL, OnReportHeaderRClick)
	ON_NOTIFY(XTP_NM_REPORT_ITEMBUTTONCLICK, XTP_ID_REPORT_CONTROL, OnReportItemButtonClick)
	ON_NOTIFY(XTP_NM_REPORT_HYPERLINK, XTP_ID_REPORT_CONTROL, OnReportHyperlink)
	ON_NOTIFY(XTP_NM_REPORT_CONSTRAINT_SELECTING, XTP_ID_REPORT_CONTROL, OnReportConstraintSelecting)
	ON_NOTIFY(XTP_NM_REPORT_CHECKED, XTP_ID_REPORT_CONTROL, OnReportChecked)
	ON_NOTIFY(XTP_NM_REPORT_ROWEXPANDED, XTP_ID_REPORT_CONTROL, OnReportRowExpanded)
	ON_NOTIFY(NM_CLICK, XTP_ID_REPORT_CONTROL, OnReportItemClick)
	ON_NOTIFY(NM_RCLICK, XTP_ID_REPORT_CONTROL, OnReportItemRClick)
	ON_NOTIFY(NM_DBLCLK, XTP_ID_REPORT_CONTROL, OnReportItemDblClick)
	//}}AFX_MSG_MAP
	// Standard printing commands
	ON_COMMAND(ID_FILE_PRINT, CXTPReportView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, CXTPReportView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, CXTPReportView::OnFilePrintPreview)
	ON_COMMAND(ID_FILE_PRINT_SETUP, CXTPReportView::OnFilePageSetup)
	//}}AFX_MSG_MAP
	// Standard Edit commands
	ON_COMMAND(ID_DATABASE_TABLE, OnDbTable)
	ON_COMMAND(ID_DATABASE_MSSQL, OnDbMssql)
	ON_COMMAND(ID_DATABASE_EXCEL, OnDbExcel)
	ON_COMMAND(ID_DATABASE_ACCESS, OnDbAccess)
	ON_COMMAND(ID_EDIT_COPY, OnEditCopy)
	ON_COMMAND(ID_EDIT_CUT, OnEditCut)
	ON_COMMAND(ID_EDIT_PASTE, OnEditPaste)
	ON_COMMAND(ID_EDIT_SELECT_ALL, OnEditSelectAll)
	ON_UPDATE_COMMAND_UI(ID_EDIT_COPY, OnUpdateEditCopy)
	ON_UPDATE_COMMAND_UI(ID_EDIT_CUT, OnUpdateEditCut)
	ON_UPDATE_COMMAND_UI(ID_EDIT_PASTE, OnUpdateEditPaste)
	ON_UPDATE_COMMAND_UI(ID_EDIT_PASTE, OnUpdateEditSelectAll)
	ON_COMMAND(ID_FILE_NEW, OnFileNew)
	ON_COMMAND(ID_FILE_OPEN, OnFileOpen)
	ON_COMMAND(ID_FILE_SAVE, OnFileSave)
	ON_COMMAND(ID_FILE_IMPORT, OnToolsImport)
	ON_COMMAND(ID_FILE_EXPORT, OnToolsExport)
	ON_WM_KEYDOWN()
	//}}AFX_MSG_MAP
	// Standard Report style commands
	ON_COMMAND(ID_REPORT_GROUP_SHOWBOX, OnReportShowGroupBox)
	ON_UPDATE_COMMAND_UI(ID_REPORT_GROUP_SHOWBOX, OnUpdateReportShowGroupBox)
	ON_COMMAND(ID_REPORT_ENABLE_PREVIEW, OnReportEnablePreview)
	ON_UPDATE_COMMAND_UI(ID_REPORT_ENABLE_PREVIEW, OnUpdateReportEnablePreview)
	ON_COMMAND(ID_REPORT_MULTIPLE_SELECTION, OnReportMultipleselection)
	ON_UPDATE_COMMAND_UI(ID_REPORT_MULTIPLE_SELECTION, OnUpdateReportMultipleselection)
	ON_COMMAND(ID_REPORT_RIGHTTOLEFT, OnReportRighttoleft)
	ON_UPDATE_COMMAND_UI(ID_REPORT_RIGHTTOLEFT, OnUpdateReportRighttoleft)
	ON_COMMAND(ID_REPORT_MARKUP, OnReportMarkup)
	ON_UPDATE_COMMAND_UI(ID_REPORT_MARKUP, OnUpdateReportMarkup)
	ON_COMMAND(ID_REPORT_WATERMARK, OnReportWatermark)
	ON_UPDATE_COMMAND_UI(ID_REPORT_WATERMARK, OnUpdateReportWatermark)
	ON_COMMAND(ID_REPORT_FREEZECOLUMNS_0, OnReportFreezecolumns0)
	ON_UPDATE_COMMAND_UI(ID_REPORT_FREEZECOLUMNS_0, OnUpdateReportFreezecolumns0)
	ON_COMMAND(ID_REPORT_FREEZECOLUMNS_1, OnReportFreezecolumns1)
	ON_UPDATE_COMMAND_UI(ID_REPORT_FREEZECOLUMNS_1, OnUpdateReportFreezecolumns1)
	ON_COMMAND(ID_REPORT_FREEZECOLUMNS_2, OnReportFreezecolumns2)
	ON_UPDATE_COMMAND_UI(ID_REPORT_FREEZECOLUMNS_2, OnUpdateReportFreezecolumns2)
	ON_COMMAND(ID_REPORT_FREEZECOLUMNS_3, OnReportFreezecolumns3)
	ON_UPDATE_COMMAND_UI(ID_REPORT_FREEZECOLUMNS_3, OnUpdateReportFreezecolumns3)
	ON_COMMAND(ID_REPORT_FREEZECOLUMNS_DIVIDER_NONE, OnReportFreezecolumnsDividerNone)
	ON_UPDATE_COMMAND_UI(ID_REPORT_FREEZECOLUMNS_DIVIDER_NONE, OnUpdateReportFreezecolumnsDividerNone)
	ON_COMMAND(ID_REPORT_FREEZECOLUMNS_DIVIDER_THIN, OnReportFreezecolumnsDividerThin)
	ON_UPDATE_COMMAND_UI(ID_REPORT_FREEZECOLUMNS_DIVIDER_THIN, OnUpdateReportFreezecolumnsDividerThin)
	ON_COMMAND(ID_REPORT_FREEZECOLUMNS_DIVIDER_BOLD, OnReportFreezecolumnsDividerBold)
	ON_UPDATE_COMMAND_UI(ID_REPORT_FREEZECOLUMNS_DIVIDER_BOLD, OnUpdateReportFreezecolumnsDividerBold)
	ON_COMMAND(ID_REPORT_FREEZECOLUMNS_DIVIDER_SHADE, OnReportFreezecolumnsDividerShade)
	ON_UPDATE_COMMAND_UI(ID_REPORT_FREEZECOLUMNS_DIVIDER_SHADE, OnUpdateReportFreezecolumnsDividerShade)
	ON_COMMAND(ID_REPORT_FREEZECOLUMNS_DIVIDER_HEADER, OnReportFreezecolumnsDividerHeader)
	ON_UPDATE_COMMAND_UI(ID_REPORT_FREEZECOLUMNS_DIVIDER_HEADER, OnUpdateReportFreezecolumnsDividerHeader)
	ON_COMMAND(ID_REPORT_ALLOWEDIT, OnReportAllowedit)
	ON_UPDATE_COMMAND_UI(ID_REPORT_ALLOWEDIT, OnUpdateReportAllowedit)
	ON_COMMAND(ID_REPORT_EDITONCLICK, OnReportEditonclick)
	ON_UPDATE_COMMAND_UI(ID_REPORT_EDITONCLICK, OnUpdateReportEditonclick)
	ON_COMMAND(ID_REPORT_FOCUS_SUBITEMS, OnReportFocussubitems)
	ON_UPDATE_COMMAND_UI(ID_REPORT_FOCUS_SUBITEMS, OnUpdateReportFocussubitems)
	ON_COMMAND(ID_REPORT_FOCUS_ALLITEMS, OnReportFocusallitems)
	ON_UPDATE_COMMAND_UI(ID_REPORT_FOCUS_ALLITEMS, OnUpdateReportFocusallitems)
	ON_COMMAND(ID_REPORT_ALLOW_COLUMNS_REMOVE, OnReportAllowcolumnsremove)
	ON_UPDATE_COMMAND_UI(ID_REPORT_ALLOW_COLUMNS_REMOVE, OnUpdateReportAllowcolumnsremove)
	ON_COMMAND(ID_REPORT_ALLOW_COLUMN_RESIZE, OnReportAllowcolumnresize)
	ON_UPDATE_COMMAND_UI(ID_REPORT_ALLOW_COLUMN_RESIZE, OnUpdateReportAllowcolumnresize)
	ON_COMMAND(ID_REPORT_ALLOW_COLUMN_REORDER, OnReportAllowcolumnreorder)
	ON_UPDATE_COMMAND_UI(ID_REPORT_ALLOW_COLUMN_REORDER, OnUpdateReportAllowcolumnreorder)
	ON_COMMAND(ID_REPORT_AUTOMATIC_COLUMNSIZING, OnReportAutomaticcolumnsizing)
	ON_UPDATE_COMMAND_UI(ID_REPORT_AUTOMATIC_COLUMNSIZING, OnUpdateReportAutomaticcolumnsizing)
	ON_COMMAND(ID_REPORT_AUTOMATIC_COLUMNBESTFIT, OnReportAutomaticcolumnbestfit)
	ON_UPDATE_COMMAND_UI(ID_REPORT_AUTOMATIC_COLUMNBESTFIT, OnUpdateReportAutomaticcolumnbestfit)
	ON_COMMAND(ID_REPORT_FULL_COLUMN_SCROLING, OnReportFullColumnScrolling)
	ON_UPDATE_COMMAND_UI(ID_REPORT_FULL_COLUMN_SCROLING, OnUpdateReportFullColumnScrolling)
	ON_COMMAND(ID_REPORT_AUTO_GROUPS, OnReportAutoGrouping)
	ON_UPDATE_COMMAND_UI(ID_REPORT_AUTO_GROUPS, OnUpdateReportAutoGrouping)
	ON_COMMAND_RANGE(ID_REPORT_HORIZONTAL_NOGRIDLINES, ID_REPORT_HORIZONTAL_SOLID, OnReportHorizontal)
	ON_UPDATE_COMMAND_UI_RANGE(ID_REPORT_HORIZONTAL_NOGRIDLINES, ID_REPORT_HORIZONTAL_SOLID, OnUpdateReportHorizontal)
	ON_COMMAND_RANGE(ID_REPORT_VERTICAL_NOGRIDLINES, ID_REPORT_VERTICAL_SOLID, OnReportVertical)
	ON_UPDATE_COMMAND_UI_RANGE(ID_REPORT_VERTICAL_NOGRIDLINES, ID_REPORT_VERTICAL_SOLID, OnUpdateReportVertical)
	ON_COMMAND_RANGE(ID_REPORT_LINECOLOR_DEFAULT, ID_REPORT_LINECOLOR_GREEN, OnReportLineColor)
	ON_UPDATE_COMMAND_UI_RANGE(ID_REPORT_LINECOLOR_DEFAULT, ID_REPORT_LINECOLOR_GREEN, OnUpdateReportLineColor)
	ON_COMMAND_RANGE(ID_REPORT_COLUMNSTYLE_SHADED, ID_REPORT_COLUMNSTYLE_OFFICE2007, OnReportColumnStyle)
	ON_UPDATE_COMMAND_UI_RANGE(ID_REPORT_COLUMNSTYLE_SHADED, ID_REPORT_COLUMNSTYLE_OFFICE2007, OnUpdateReportColumnStyle)
	ON_COMMAND(ID_REPORT_GROUPSHADE, OnReportGroupShade)
	ON_UPDATE_COMMAND_UI(ID_REPORT_GROUPSHADE, OnUpdateReportGroupShade)
	ON_COMMAND(ID_REPORT_GROUPSBOLD, OnReportGroupBold)	
	ON_UPDATE_COMMAND_UI(ID_REPORT_GROUPSBOLD, OnUpdateReportGroupBold)
	ON_COMMAND(ID_REPORT_SHOWITEMSINGROUPS, OnReportShowitemsingroups)
	ON_UPDATE_COMMAND_UI(ID_REPORT_SHOWITEMSINGROUPS, OnUpdateReportShowitemsingroups)
	ON_COMMAND(ID_REPORT_AUTOMATIC_FORMATTING, OnReportAutomaticformatting)
	ON_UPDATE_COMMAND_UI(ID_REPORT_AUTOMATIC_FORMATTING, OnUpdateReportAutomaticformatting)
	ON_COMMAND(ID_REPORT_MULTILINE, OnReportMultiline)
	ON_UPDATE_COMMAND_UI(ID_REPORT_MULTILINE, OnUpdateReportMultiline)
	ON_COMMAND(ID_REPORT_FIND_RECORDITEM, OnReportFindRecorditem)
	ON_UPDATE_COMMAND_UI(ID_REPORT_FIND_RECORDITEM, OnUpdateReportFindRecorditem)
	ON_COMMAND(ID_REPORT_ICONVIEW, OnReportIconview)
	ON_UPDATE_COMMAND_UI(ID_REPORT_ICONVIEW, OnUpdateReportIconview)
	ON_COMMAND(ID_REPORT_WYSIWYG_PRINT, OnReportWysiwygprint)
	ON_UPDATE_COMMAND_UI(ID_REPORT_WYSIWYG_PRINT, OnUpdateReportWysiwygprint)
	//}}AFX_MSG_MAP
	// Report test examples
	ON_COMMAND(ID_REPORT_PERFOMANCE, OnReportPerfomance)
	ON_COMMAND(ID_REPORT_PROPERTIES, OnReportProperties)
	ON_COMMAND(ID_REPORT_MERGE, OnReportMerge)
	ON_COMMAND(ID_REPORT_TREEEDIT, OnReportTreeEdit)
	ON_COMMAND(ID_REPORT_FORMULA, OnReportFormula)
	ON_COMMAND(ID_REPORT_DRAGDROP, OnReportDragDrop)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CReportRecordView construction/destruction

CReportRecordView::CReportRecordView()
{
	m_bAutomaticFormating = FALSE;
	m_bMultilineSample = FALSE;
	m_bWYSIWYG = FALSE;
	m_bAllowEdit = FALSE;
	m_bEditOnClick = FALSE;
	m_bFocusSubItem = FALSE;
	m_bFocusAllItem = FALSE;
	m_bFindReportItem = FALSE;
	m_bShowColumnMenu = TRUE;
	m_bShowItemMenu = TRUE;
	m_bWatermark = FALSE;
	m_bAutoBestFit = FALSE;
	m_bAutoUpdateSql = FALSE;
	m_nType = XTP_REPORT_TABLE_TYPE_XL;

	m_pFocusedRecord = NULL;
	m_pTopRow = NULL;

	m_pReportFrame = NULL;

	m_pFocusItem = NULL;

	m_imgList.Create(16, 16, ILC_COLOR24|ILC_MASK, 0, 1);
	CBitmap bmp;

	if (XTPImageManager()->IsAlphaIconsImageListSupported())
	{
		bmp.Attach((HBITMAP)LoadImage(AfxGetInstanceHandle(), MAKEINTRESOURCE(IDB_TASKLIST),
			IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE | LR_CREATEDIBSECTION));

		m_imgList.Add(&bmp, (CBitmap*)NULL);
	}
	else
	{
		bmp.LoadBitmap(IDB_TASKLIST);
		m_imgList.Add(&bmp, RGB(255, 255, 255));
	}

	m_itemCtrlDataList.clear();
}

CReportRecordView::~CReportRecordView()
{
	if(m_pFocusedRecord)
		m_pFocusedRecord = NULL;
}

BOOL CReportRecordView::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	cs.style |= WS_EX_CONTROLPARENT;

	return CXTPReportView::PreCreateWindow(cs);
}

/////////////////////////////////////////////////////////////////////////////
// CReportRecordView drawing

void CReportRecordView::OnDraw(CDC* /*pDC*/)
{
	CRibbonReportDoc* pDoc = GetDocument();
	// TODO: add draw code for native data here
}

/////////////////////////////////////////////////////////////////////////////
// CReportRecordView printing

BOOL CReportRecordView::OnPreparePrinting(CPrintInfo* pInfo)
{
	// TODO: add extra initialization prepare printing
	return CXTPReportView::OnPreparePrinting(pInfo);
}

void CReportRecordView::OnBeginPrinting(CDC* pDC, CPrintInfo* pInfo)
{
	// TODO: add extra initialization before printing
	CXTPReportView::OnBeginPrinting(pDC, pInfo);
}

void CReportRecordView::OnEndPrinting(CDC* pDC, CPrintInfo* pInfo)
{
	// TODO: add cleanup after printing
	CXTPReportView::OnEndPrinting(pDC, pInfo);
}



/////////////////////////////////////////////////////////////////////////////
// CReportRecordView diagnostics

#ifdef _DEBUG
void CReportRecordView::AssertValid() const
{
	CXTPReportView::AssertValid();
}

void CReportRecordView::Dump(CDumpContext& dc) const
{
	CXTPReportView::Dump(dc);
}

CRibbonReportDoc* CReportRecordView::GetDocument() // non-debug version is inline
{
	if(m_pDocument->IsKindOf(RUNTIME_CLASS(CRibbonReportDoc)))
		return (CRibbonReportDoc*)m_pDocument;

	return NULL;
}
#endif //_DEBUG


/////////////////////////////////////////////////////////////////////////////
// CReportRecordView message handlers

void CReportRecordView::OnInitialUpdate()
{
	CXTPReportView::OnInitialUpdate();

	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.SetImageList(&m_imgList);
	wndReport.AllowEdit(FALSE);
	wndReport.HeaderRowsAllowEdit(FALSE);
	wndReport.FooterRowsAllowEdit(FALSE);
	wndReport.FocusSubItems(TRUE);

	wndReport.EnableDragDrop(_T("ReportRecordView"), xtpReportAllowDrag | xtpReportAllowDrop);
	wndReport.GetToolTipContext()->SetStyle(xtpToolTipStandard);
	wndReport.GetImageManager()->SetImageList(IDB_TASKLIST, 32, 0,  RGB(255, 0, 255));
	wndReport.m_bSortedDragDrop = TRUE;

	m_pPaintManager = new CReportRecordPaintManager();
	wndReport.SetPaintManager(m_pPaintManager);
	//m_pPaintManager->SetColumnStyle(xtpReportColumnResource);
	m_pPaintManager->SetColumnWidthWYSIWYG(m_bWYSIWYG);
	//XTP_REPORTRECORDITEM_DRAWARGS* pDrawArgs; XTP_REPORTRECORDITEM_METRICS* pMetrics;
	//wndReport.GetItemMetrics(pDrawArgs, pMetrics);

	OnReportWatermark();

	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
	if (m_wndSubList.GetSafeHwnd() == NULL)
	{
		m_wndSubList.SubclassDlgItem(IDC_BAR_SUBLIST, &pMaainFrame->m_wndSubList);
		wndReport.GetColumns()->GetReportHeader()->SetSubListCtrl(&m_wndSubList);
	}
	
	if (m_wndFilterEdit.GetSafeHwnd() == NULL)
	{
		m_wndFilterEdit.SubclassDlgItem(IDC_BAR_FILTEREDIT, &pMaainFrame->m_wndFilterEdit);
		m_wndFilterEdit.SetHint(_T("~{JdHk9}BKNDWV~}"));
		wndReport.GetColumns()->GetReportHeader()->SetFilterEditCtrl(&m_wndFilterEdit);
	}

	if (m_wndListBox.GetSafeHwnd() == NULL)
	{
		m_wndListBox.SubclassDlgItem(IDC_BAR_LISTBOX, &pMaainFrame->m_wndListBox);
		m_wndListBox.SetReportCtrl(&wndReport);
	}
}

BOOL CReportRecordView::PreTranslateMessage(MSG* pMsg)
{
	if(pMsg->message == WM_KEYDOWN && (pMsg->wParam == VK_ESCAPE || pMsg->wParam == VK_RETURN || pMsg->wParam == VK_TAB))
		return FALSE;

	return CXTPReportView::PreTranslateMessage(pMsg);
}

void CReportRecordView::LoadReportState()
{
	CXTPReportControl& wndReport = GetReportCtrl();
#ifdef XML_STATE
	CXTPPropExchangeXMLNode px(TRUE, 0, _T("ReportControl"));
	if (!px.LoadFromFile(_T("c:\\ReportControl.xml")))
		return;

	wndReport.DoPropExchange(&px);

	CXTPPropExchangeSection secOthers(px.GetSection(_T("Others")));	
	BOOL bMultilineSample = FALSE;
	PX_Bool(&secOthers, _T("Multiline"), bMultilineSample, FALSE);

	m_bMultilineSample = !bMultilineSample;
	OnReportcontrolMultilinesample();

#else	
	UINT nBytes = 0;
	LPBYTE pData = 0;

	if (!AfxGetApp()->GetProfileBinary(_T("ReportControl"), _T("State"), &pData, &nBytes))
		return;

	CMemFile memFile(pData, nBytes);
	CArchive ar (&memFile,CArchive::load);

	try
	{
		wndReport.SerializeState(ar);

	}
	catch (COleException* pEx)
	{
		pEx->Delete ();
	}
	catch (CArchiveException* pEx)
	{
		pEx->Delete ();
	}

	ar.Close();
	memFile.Close();
	delete[] pData;

	// others
	m_bMultilineSample = !AfxGetApp()->GetProfileInt(_T("ReportControl"), _T("Multiline"), 0);
	OnReportMultiline();
#endif
}

void CReportRecordView::SaveReportState()
{
	CXTPReportControl& wndReport = GetReportCtrl();
#ifdef XML_STATE

	CXTPPropExchangeXMLNode px(FALSE, 0, _T("ReportControl"));
	wndReport.DoPropExchange(&px);

	CXTPPropExchangeSection secOthers(px.GetSection(_T("Others")));	
	BOOL bMultilineSample = m_bMultilineSample;
	PX_Bool(&secOthers, _T("Multiline"), bMultilineSample, FALSE);

	// Save All Records
	//CXTPPropExchangeSection secRecords(px.GetSection(_T("Records")));
	//wndReport.GetRecords()->DoPropExchange(&secRecords);

	px.SaveToFile(_T("c:\\ReportControl.xml"));

#else
	CMemFile memFile;
	CArchive ar (&memFile,CArchive::store);

	wndReport.SerializeState(ar);

	ar.Flush();

	DWORD nBytes = (DWORD)memFile.GetPosition();
	LPBYTE pData = memFile.Detach();

	AfxGetApp()->WriteProfileBinary(_T("ReportControl"), _T("State"), pData, nBytes);

	ar.Close();
	memFile.Close();
	free(pData);

	AfxGetApp()->WriteProfileInt(_T("ReportControl"), _T("Multiline"), m_bMultilineSample);
#endif
}

void CReportRecordView::SetCheckBoxState(int index)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportRecords* pRecords = wndReport.GetRecords();
	if(pRecords != NULL)
	{
		int iRows = pRecords->GetCount();
		for(int i=0; i<iRows; i++)
		{
			CXTPReportRecord* pRecord = pRecords->GetAt(i);
			if(pRecord != NULL)
			{
				CXTPReportRecordItem* pItem = pRecord->GetItem(index);
				if(pItem != NULL)
				{
					pItem->HasCheckbox(TRUE);
					BOOL bCheck= ((CXTPReportRecordItemVariant*)pItem)->GetValue().boolVal ? TRUE:FALSE;
					pItem->SetChecked(bCheck);
					pItem->SetCaption(bCheck ? _T("~{JG~}"):_T("~{7q~}"));
				}
			}
		}
	}
}

CXTPReportControl& CReportRecordView::ShowReportProperties()
{
	if (m_pReportFrame)
	{
		m_pReportFrame->ActivateFrame();
	}
	else
	{
		CCreateContext contextT;
		// if no context specified, generate one from the
		// currently selected client if possible.
		contextT.m_pLastView       = NULL;
		contextT.m_pCurrentFrame   = NULL;
		contextT.m_pNewDocTemplate = NULL;
		contextT.m_pCurrentDoc     = NULL;
		contextT.m_pNewViewClass   = RUNTIME_CLASS(CPropertiesView);


		m_pReportFrame = new CReportFrame(this);

		DWORD dwStyle = WS_OVERLAPPEDWINDOW|MFS_SYNCACTIVE;

		if (m_pReportFrame->Create(0, _T("Properties"), dwStyle, CRect(0, 0, 600, 400),
			this, 0, 0L, &contextT))
		{
			m_pReportFrame->InitialUpdateFrame(NULL, FALSE);

			m_pReportFrame->CenterWindow(this);
			m_pReportFrame->ShowWindow(SW_SHOW);
		}
	}

	return ((CPropertiesView*)m_pReportFrame->GetActiveView())->m_wndReport;
}

int CReportRecordView::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (CXTPReportView::OnCreate(lpCreateStruct) == -1)
		return -1;

	//m_wndVScrollBar.Create(WS_CHILD | WS_VISIBLE | SBS_VERT, CRect(0, 0, 0, 0), this, 100);
	//m_wndVScrollBar.SetScrollBarStyle(xtpScrollStyleOffice2007Dark);
	//SetScrollBarCtrl(&m_wndVScrollBar);

	//m_wndHScrollBar.Create(WS_CHILD | SBS_HORZ, CRect(0, 0, 0, 0), this, 100);
	//m_wndHScrollBar.SetScrollBarStyle(xtpScrollStyleOffice2007Dark);

	return 0;
}

void CReportRecordView::OnReportFoucsChanging(NMHDR* pNMHDR, LRESULT* /*result*/)
{
	return;
	XTP_NM_REPORTRECORDITEM* pItemNotify = (XTP_NM_REPORTRECORDITEM*) pNMHDR;
	if(!pItemNotify) return;
	if(!pItemNotify->pRow || !pItemNotify->pColumn) return;

	CXTPReportRow* pNewRow = pItemNotify->pRow;
	CXTPReportColumn* pNewCol = pItemNotify->pColumn;
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportRecord* pNewRecord = pNewRow->GetRecord();

	if(!pNewRecord) return;

	// add new record
	CXTPReportRow* pFocusedRow = wndReport.GetFocusedRow();
	if(!pFocusedRow) return;

	if(pFocusedRow->GetType() == xtpRowTypeHeader && pNewRow->GetType() != xtpRowTypeHeader && pNewRow != pFocusedRow)
	{
		CXTPReportRecord* pFocusedRecord = pFocusedRow->GetRecord();
		if(!pFocusedRecord) return;
		pFocusedRecord->InternalAddRef();

		if(FAILED(wndReport.GetDataManager()->AddRecord(pFocusedRecord, TRUE)))
		{
			pFocusedRecord->InternalRelease();
			return;
		}

		pFocusedRecord = NULL;
		if(FAILED(wndReport.GetDataManager()->CreateEmptyRecord(&pFocusedRecord) && pFocusedRecord != NULL)) return;

		wndReport.GetHeaderRecords()->RemoveAll();
		wndReport.GetHeaderRecords()->Add(pFocusedRecord);
		wndReport.PopulateHeaderRows();
	}
}

void CReportRecordView::OnReportValueChanged(NMHDR* pNMHDR, LRESULT* /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pItemNotify = (XTP_NM_REPORTRECORDITEM*) pNMHDR;
	if(!pItemNotify) return;
	if(!pItemNotify->pRow || !pItemNotify->pItem) return;

	CXTPReportRow* pSelRow = pItemNotify->pRow;
	CXTPReportRecordItem* pSelItem = pItemNotify->pItem;
	CXTPReportControl& wndReport = GetReportCtrl();

	if(pSelRow->GetType() != xtpRowTypeHeader)
	{
		CXTPReportRecord* pSelItemRcd = pSelItem->GetRecord();
		if(!pSelItemRcd) return;
		CString strTable = GetCurTable();
		CString field = GetFieldName(strTable,pSelItem->GetIndex()+1);
		
		COleVariant val = ((CXTPReportRecordItemVariant*)pSelItemRcd->GetItem(0))->GetValue();
		switch (val.vt)
		{
		case VT_BSTR:
			{
				CString code = val.bstrVal;
				SetRecordset(strTable,field,code,((CXTPReportRecordItemVariant*)pSelItem)->GetValue());
			}
			break;
		case VT_I4:
			{
				int id = val.lVal;
				SetRecordset(strTable,field,id,((CXTPReportRecordItemVariant*)pSelItem)->GetValue());
			}
			break;
		}
	}
}

void CReportRecordView::OnReportHyperlink(NMHDR * pNMHDR, LRESULT * /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pItemNotify = (XTP_NM_REPORTRECORDITEM*) pNMHDR;
	if(!pItemNotify) return;
	if (!pItemNotify->pRow || !pItemNotify->pItem) return;

	if (pItemNotify->nHyperlink >= 0)
		if(m_itemCtrlDataList.size()) ShowReportPerfomance((CXTPReportRecordItemVariant*&)pItemNotify->pItem);
}

void CReportRecordView::OnReportItemButtonClick(NMHDR * pNMHDR, LRESULT*)
{
	XTP_NM_REPORTITEMCONTROL* pItemNotify = (XTP_NM_REPORTITEMCONTROL*) pNMHDR;
	if(!pItemNotify) return;
	if(!(pItemNotify->pRow || pItemNotify->pItem || pItemNotify->pItemControl))	return;

	DWORD itemID = pItemNotify->pItem->GetItemData();
	switch(itemID)
	{
	case XTP_REPORT_ITEM_CTRL_BOLD | XTP_REPORT_ITEM_CTRL_ALIGN | XTP_REPORT_ITEM_CTRL_COLOR:
		{
			switch(pItemNotify->pItemControl->GetIndex())
			{
			case 0:// button "Alignment"
				{
					int nIcon = pItemNotify->pItemControl->GetIconIndex(PBS_NORMAL);
					if(++nIcon > 10) nIcon = 8;
					pItemNotify->pItemControl->SetIconIndex(PBS_NORMAL, nIcon);
					if(++nIcon > 10) nIcon = 8;
					pItemNotify->pItemControl->SetIconIndex(PBS_PRESSED, nIcon);
					switch(pItemNotify->pItemControl->GetIconIndex(PBS_NORMAL))
					{
					case 8:
						pItemNotify->pItem->SetAlignment(xtpColumnTextLeft);
						break;
					case 9:
						pItemNotify->pItem->SetAlignment(xtpColumnTextCenter);
						break;
					case 10:
						pItemNotify->pItem->SetAlignment(xtpColumnTextRight);
						break;
					}
				}
				break;
			case 1:// button "Color"
				{
					int nIcon = pItemNotify->pItemControl->GetIconIndex(PBS_NORMAL);
					if(++nIcon > 15) nIcon = 13;
					pItemNotify->pItemControl->SetIconIndex(PBS_NORMAL, nIcon);
					if(++nIcon > 15) nIcon = 13;
					pItemNotify->pItemControl->SetIconIndex(PBS_PRESSED, nIcon);
					switch(pItemNotify->pItemControl->GetIconIndex(PBS_NORMAL))
					{
					case 13:
						pItemNotify->pItem->SetTextColor(RGB(0, 0, 0));
						break;
					case 14:
						pItemNotify->pItem->SetTextColor(RGB(0, 0, 255));
						break;
					case 15:
						pItemNotify->pItem->SetTextColor(RGB(255, 0, 0));
						break;
					}
				}
				break;
			case 2 :// button "Bold"
				pItemNotify->pItem->SetBold(!pItemNotify->pItem->IsBold());
				break;
			}
		}
		break;
	case XTP_REPORT_ITEM_CTRL_BOLD:
		pItemNotify->pItem->SetBold(!pItemNotify->pItem->IsBold());
		break;
	case XTP_REPORT_ITEM_CTRL_ALIGN:
		{
			int nIcon = pItemNotify->pItemControl->GetIconIndex(PBS_NORMAL);
			if(++nIcon > 10) nIcon = 8;
			pItemNotify->pItemControl->SetIconIndex(PBS_NORMAL, nIcon);
			if(++nIcon > 10) nIcon = 8;
			pItemNotify->pItemControl->SetIconIndex(PBS_PRESSED, nIcon);
			switch(pItemNotify->pItemControl->GetIconIndex(PBS_NORMAL))
			{
			case 8:
				pItemNotify->pItem->SetAlignment(xtpColumnTextLeft);
				break;
			case 9:
				pItemNotify->pItem->SetAlignment(xtpColumnTextCenter);
				break;
			case 10:
				pItemNotify->pItem->SetAlignment(xtpColumnTextRight);
				break;
			}
		}
		break;
	case XTP_REPORT_ITEM_CTRL_COLOR:
		{
			int nIcon = pItemNotify->pItemControl->GetIconIndex(PBS_NORMAL);
			if(++nIcon > 15) nIcon = 13;
			pItemNotify->pItemControl->SetIconIndex(PBS_NORMAL, nIcon);
			if(++nIcon > 15) nIcon = 13;
			pItemNotify->pItemControl->SetIconIndex(PBS_PRESSED, nIcon);
			switch(pItemNotify->pItemControl->GetIconIndex(PBS_NORMAL))
			{
			case 13:
				pItemNotify->pItem->SetTextColor(RGB(0, 0, 0));
				break;
			case 14:
				pItemNotify->pItem->SetTextColor(RGB(0, 0, 255));
				break;
			case 15:
				pItemNotify->pItem->SetTextColor(RGB(255, 0, 0));
				break;
			}
		}
		break;
	case XTP_REPORT_ITEM_CTRL_FORM:
		if(m_itemCtrlDataList.size()) ShowReportPerfomance((CXTPReportRecordItemVariant*&)pItemNotify->pItem);
		break;
	case XTP_REPORT_ITEM_CTRL_LINK | XTP_REPORT_ITEM_CTRL_FORM:
		{
			int nIcon = pItemNotify->pItemControl->GetIconIndex(PBS_NORMAL);
			if(++nIcon > 5) nIcon = 4;
			pItemNotify->pItemControl->SetIconIndex(PBS_NORMAL, nIcon);
			if(++nIcon > 5) nIcon = 4;
			pItemNotify->pItemControl->SetIconIndex(PBS_PRESSED, nIcon);

			ShowFieldSubList();
		}
		break;
	case XTP_REPORT_ITEM_CTRL_BUTTON:
		{
			int nIcon = pItemNotify->pItemControl->GetIconIndex(PBS_NORMAL);
			if(++nIcon > 7) nIcon = 6;
			pItemNotify->pItemControl->SetIconIndex(PBS_NORMAL, nIcon);
			if(++nIcon > 7) nIcon = 6;
			pItemNotify->pItemControl->SetIconIndex(PBS_PRESSED, nIcon);

			if(m_itemCtrlDataList.size()) ShowReportPerfomance((CXTPReportRecordItemVariant*&)pItemNotify->pItem);
		}
		break;
	}
}

void CReportRecordView::OnReportHeaderRClick(NMHDR* pNMHDR, LRESULT* /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pItemNotify = (XTP_NM_REPORTRECORDITEM*) pNMHDR;
	if(!pItemNotify) return;
	if(!pItemNotify->pColumn || !m_bShowColumnMenu) return;

	CPoint ptClick = pItemNotify->pt;

	CXTPReportControl& wndReport = GetReportCtrl();

	CMenu menuHeader;
	if(!menuHeader.CreatePopupMenu()) return;

	// create main menu items
	menuHeader.AppendMenu(MF_STRING, ID_REPORT_SORT_ASC, LoadResourceString(ID_REPORT_SORT_ASC));
	menuHeader.AppendMenu(MF_STRING, ID_REPORT_SORT_DESC, LoadResourceString(ID_REPORT_SORT_DESC));
	menuHeader.AppendMenu(MF_STRING, ID_REPORT_SORT_NO, LoadResourceString(ID_REPORT_SORT_NO));
	menuHeader.AppendMenu(MF_SEPARATOR, (UINT)-1, (LPCTSTR)NULL);
	menuHeader.AppendMenu(MF_STRING, ID_REPORT_GROUP_BYFIELD, LoadResourceString(ID_REPORT_GROUP_BYFIELD));
	menuHeader.AppendMenu(MF_STRING, ID_REPORT_GROUP_SHOWBOX, LoadResourceString(ID_REPORT_GROUP_SHOWBOX));
	menuHeader.AppendMenu(MF_STRING, ID_REPORT_COLUMN_AUTOUPDATESQL, LoadResourceString(ID_REPORT_COLUMN_AUTOUPDATESQL));
	menuHeader.AppendMenu(MF_SEPARATOR, (UINT)-1, (LPCTSTR)NULL);
	menuHeader.AppendMenu(MF_STRING, ID_REPORT_COLUMN_REMOVE, LoadResourceString(ID_REPORT_COLUMN_REMOVE));
	menuHeader.AppendMenu(MF_STRING, ID_REPORT_COLUMN_FILTEREDIT, LoadResourceString(ID_REPORT_COLUMN_FILTEREDIT));
	menuHeader.AppendMenu(MF_STRING, ID_REPORT_COLUMN_SUBLIST, LoadResourceString(ID_REPORT_COLUMN_SUBLIST));
	menuHeader.AppendMenu(MF_SEPARATOR, (UINT)-1, (LPCTSTR)NULL);
	menuHeader.AppendMenu(MF_STRING, ID_REPORT_COLUMN_AUTOSIZING, LoadResourceString(ID_REPORT_COLUMN_AUTOSIZING));
	menuHeader.AppendMenu(MF_STRING, ID_REPORT_COLUMN_AUTOBESTFIT, LoadResourceString(ID_REPORT_COLUMN_AUTOBESTFIT));
	menuHeader.AppendMenu(MF_STRING, ID_REPORT_COLUMN_FREEZE, LoadResourceString(ID_REPORT_COLUMN_FREEZE));
	menuHeader.AppendMenu(MF_STRING, ID_REPORT_COLUMN_ROWNUMBER, LoadResourceString(ID_REPORT_COLUMN_ROWNUMBER));

	if (wndReport.IsGroupByVisible()) menuHeader.CheckMenuItem(ID_REPORT_GROUP_SHOWBOX, MF_BYCOMMAND|MF_CHECKED);
	if (wndReport.GetReportHeader()->IsShowItemsInGroups()) menuHeader.EnableMenuItem(ID_REPORT_GROUP_BYFIELD, MF_BYCOMMAND|MF_DISABLED);

	CXTPReportColumns* pColumns = wndReport.GetColumns();
	CXTPReportColumn* pColumn = pItemNotify->pColumn;

	// create arrange by items
	CMenu menuArrange;
	if(!menuArrange.CreatePopupMenu()) return;
	int nColumnCount = pColumns->GetCount();
	int nColumn;
	for (nColumn = 0; nColumn < nColumnCount; nColumn++)
	{
		CXTPReportColumn* pCol = pColumns->GetAt(nColumn);
		if (pCol && pCol->IsVisible())
		{
			CString sCaption = pCol->GetCaption();
			if (!sCaption.IsEmpty()) menuArrange.AppendMenu(MF_STRING, ID_REPORT_COLUMN_ARRANGEBY + nColumn, sCaption);
		}
	}

	menuArrange.AppendMenu(MF_SEPARATOR, 60, (LPCTSTR)NULL);
	menuArrange.AppendMenu(MF_STRING, ID_REPORT_COLUMN_ARRANGEBY + nColumnCount, LoadResourceString(ID_REPORT_COLUMN_SHOWINGROUPS));
	menuArrange.CheckMenuItem(ID_REPORT_COLUMN_ARRANGEBY + nColumnCount, MF_BYCOMMAND | ((wndReport.GetReportHeader()->IsShowItemsInGroups()) ? MF_CHECKED : MF_UNCHECKED)  );
	
	menuHeader.InsertMenu(0, MF_BYPOSITION | MF_POPUP, (UINT_PTR) menuArrange.m_hMenu, LoadResourceString(ID_REPORT_COLUMN_ARRANGEBY));

	// create columns items
	CMenu menuColumns;
	if(!menuColumns.CreatePopupMenu()) return;
	for (nColumn = 0; nColumn < nColumnCount; nColumn++)
	{
		CXTPReportColumn* pCol = pColumns->GetAt(nColumn);
		CString sCaption = pCol->GetCaption();
		//if (!sCaption.IsEmpty())
		menuColumns.AppendMenu(MF_STRING, ID_REPORT_COLUMN_SHOW + nColumn, sCaption);
		menuColumns.CheckMenuItem(ID_REPORT_COLUMN_SHOW + nColumn, MF_BYCOMMAND | (pCol->IsVisible() ? MF_CHECKED : MF_UNCHECKED) );
	}

	menuHeader.InsertMenu(0, MF_BYPOSITION | MF_POPUP, (UINT_PTR) menuColumns.m_hMenu, LoadResourceString(ID_REPORT_COLUMN_COLUMNS));

	////  create Text alignment menu
	CMenu menuAlignText;
	if(!menuAlignText.CreatePopupMenu()) return;

	menuAlignText.AppendMenu(MF_STRING, ID_REPORT_COLUMN_TEXT_ALIGNMENT_LEFT,
		LoadResourceString(ID_REPORT_COLUMN_TEXT_ALIGNMENT_LEFT));
	menuAlignText.AppendMenu(MF_STRING, ID_REPORT_COLUMN_TEXT_ALIGNMENT_RIGHT,
		LoadResourceString(ID_REPORT_COLUMN_TEXT_ALIGNMENT_RIGHT));
	menuAlignText.AppendMenu(MF_STRING, ID_REPORT_COLUMN_TEXT_ALIGNMENT_CENTER,
		LoadResourceString(ID_REPORT_COLUMN_TEXT_ALIGNMENT_CENTER));

	int nAlignOption = 0;
	switch (pColumn->GetAlignment() & xtpColumnTextMask)
	{
	case xtpColumnTextLeft:
		nAlignOption = ID_REPORT_COLUMN_TEXT_ALIGNMENT_LEFT;
		break;
	case xtpColumnTextRight:
		nAlignOption = ID_REPORT_COLUMN_TEXT_ALIGNMENT_RIGHT;
		break;
	case xtpColumnTextCenter:
		nAlignOption = ID_REPORT_COLUMN_TEXT_ALIGNMENT_CENTER;
		break;
	}

	menuAlignText.CheckMenuItem(nAlignOption, MF_BYCOMMAND | MF_CHECKED);

	////  create Icon alignment menu
	CMenu menuAlignIcon;
	if(!menuAlignIcon.CreatePopupMenu()) return;

	menuAlignIcon.AppendMenu(MF_STRING, ID_REPORT_COLUMN_ICON_ALIGNMENT_LEFT, LoadResourceString(ID_REPORT_COLUMN_ICON_ALIGNMENT_LEFT));
	menuAlignIcon.AppendMenu(MF_STRING, ID_REPORT_COLUMN_ICON_ALIGNMENT_RIGHT, LoadResourceString(ID_REPORT_COLUMN_ICON_ALIGNMENT_RIGHT));
	menuAlignIcon.AppendMenu(MF_STRING, ID_REPORT_COLUMN_ICON_ALIGNMENT_CENTER, LoadResourceString(ID_REPORT_COLUMN_ICON_ALIGNMENT_CENTER));

	nAlignOption = 0;
	switch (pColumn->GetAlignment() & xtpColumnIconMask)
	{
	case xtpColumnIconLeft:
		nAlignOption = ID_REPORT_COLUMN_ICON_ALIGNMENT_LEFT;
		break;
	case xtpColumnIconRight:
		nAlignOption = ID_REPORT_COLUMN_ICON_ALIGNMENT_RIGHT;
		break;
	case xtpColumnIconCenter:
		nAlignOption = ID_REPORT_COLUMN_ICON_ALIGNMENT_CENTER;
		break;
	}

	menuAlignIcon.CheckMenuItem(nAlignOption, MF_BYCOMMAND | MF_CHECKED);

	// create alignment submenu
	CMenu menuAlign;
	if(!menuAlign.CreatePopupMenu()) return;
	menuAlign.InsertMenu(1, MF_BYPOSITION | MF_POPUP, (UINT_PTR) menuAlignText.m_hMenu,_T("~{ND1>~}"));
	menuAlign.InsertMenu(2, MF_BYPOSITION | MF_POPUP, (UINT_PTR) menuAlignIcon.m_hMenu, _T("~{M<1j~}"));

	///	
	menuHeader.InsertMenu(11, MF_BYPOSITION | MF_POPUP, (UINT_PTR) menuAlign.m_hMenu, LoadResourceString(ID_REPORT_COLUMN_ALIGNMENT));

	// track menu
	int nMenuResult = CXTPCommandBars::TrackPopupMenu(&menuHeader, TPM_NONOTIFY | TPM_RETURNCMD | TPM_LEFTALIGN |TPM_RIGHTBUTTON, ptClick.x, ptClick.y, this, NULL);


	// arrange by items
	if (nMenuResult >= ID_REPORT_COLUMN_ARRANGEBY && nMenuResult < ID_REPORT_COLUMN_ALIGNMENT)
	{
		for (int nColumn = 0; nColumn < nColumnCount; nColumn++)
		{
			CXTPReportColumn* pCol = pColumns->GetAt(nColumn);
			if (pCol && pCol->IsVisible())
			{
				if (nMenuResult == ID_REPORT_COLUMN_ARRANGEBY + nColumn)
				{
					nMenuResult = ID_REPORT_SORT_ASC;
					pColumn = pCol;
					break;
				}
			}
		}
		// group by item
		if (ID_REPORT_COLUMN_ARRANGEBY + nColumnCount == nMenuResult) wndReport.GetReportHeader()->ShowItemsInGroups(!wndReport.GetReportHeader()->IsShowItemsInGroups());
	}

	// process Alignment options
	if (nMenuResult > ID_REPORT_COLUMN_ALIGNMENT_TEXT && nMenuResult < ID_REPORT_COLUMN_ALIGNMENT_ICON)
	{
		int nAlign = pColumn->GetAlignment();
		nAlign &= ~~(xtpColumnTextLeft | xtpColumnTextCenter | xtpColumnTextRight);

		switch (nMenuResult)
		{
		case ID_REPORT_COLUMN_TEXT_ALIGNMENT_LEFT :
			pColumn->SetAlignment(nAlign | xtpColumnTextLeft);
			break;
		case ID_REPORT_COLUMN_TEXT_ALIGNMENT_RIGHT :
			pColumn->SetAlignment(nAlign | xtpColumnTextRight);
			break;
		case ID_REPORT_COLUMN_TEXT_ALIGNMENT_CENTER  :
			pColumn->SetAlignment(nAlign | xtpColumnTextCenter);
			break;
		}
	}

	// process Alignment options
	if (nMenuResult > ID_REPORT_COLUMN_ALIGNMENT_ICON && nMenuResult < ID_REPORT_COLUMN_SHOW)
	{
		int nAlign = pColumn->GetAlignment();
		nAlign &= ~~(xtpColumnIconLeft | xtpColumnIconCenter | xtpColumnIconRight);

		switch (nMenuResult)
		{
		case ID_REPORT_COLUMN_ICON_ALIGNMENT_LEFT:
			pColumn->SetAlignment(nAlign | xtpColumnIconLeft);
			break;
		case ID_REPORT_COLUMN_ICON_ALIGNMENT_RIGHT:
			pColumn->SetAlignment(nAlign | xtpColumnIconRight);
			break;
		case ID_REPORT_COLUMN_ICON_ALIGNMENT_CENTER:
			pColumn->SetAlignment(nAlign | xtpColumnIconCenter);
			break;
		}
	}

	// process column selection item
	if (nMenuResult >= ID_REPORT_COLUMN_SHOW)
	{
		CXTPReportColumn* pCol = pColumns->GetAt(nMenuResult - ID_REPORT_COLUMN_SHOW);
		if (pCol) pCol->SetVisible(!pCol->IsVisible());
	}

	// other general items
	switch (nMenuResult)
	{
	case ID_REPORT_COLUMN_REMOVE:
		pColumn->SetVisible(FALSE);
		wndReport.Populate();
		break;
	case ID_REPORT_SORT_ASC:
	case ID_REPORT_SORT_DESC:
		if (pColumn && pColumn->IsSortable())
		{
			pColumns->SetSortColumn(pColumn, nMenuResult == ID_REPORT_SORT_ASC);
			wndReport.Populate();
		}
		break;
	case ID_REPORT_SORT_NO:
		pColumns->GetSortOrder()->Clear();
		break;
	case ID_REPORT_GROUP_BYFIELD:
		if (pColumns->GetGroupsOrder()->IndexOf(pColumn) < 0) pColumns->GetGroupsOrder()->Add(pColumn);
		wndReport.ShowGroupBy(TRUE);
		wndReport.Populate();
		break;
	case ID_REPORT_GROUP_SHOWBOX:
		wndReport.ShowGroupBy(!wndReport.IsGroupByVisible());
		break;
	case ID_REPORT_COLUMN_FILTEREDIT:
		ShowFilterEdit();
		break;
	case ID_REPORT_COLUMN_SUBLIST:
		ShowFieldSubList();
		break;
	case ID_REPORT_COLUMN_AUTOSIZING:
		wndReport.GetReportHeader()->SetAutoColumnSizing(!wndReport.GetReportHeader()->IsAutoColumnSizing());
		break;
	case ID_REPORT_COLUMN_AUTOBESTFIT:
		if(!wndReport.GetReportHeader()->IsAutoColumnSizing())
		{
			CXTPReportColumns* pColums = wndReport.GetColumns();
			CXTPReportHeader* pHeader = wndReport.GetReportHeader();
			for(int i=0; i<pColums->GetCount(); i++)
			{
				CXTPReportColumn* pColumn = pColums->GetAt(i);
				if (pColumn != NULL) pHeader->BestFit(pColumn);
			}
			wndReport.RedrawControl();
		}
		break;
	case ID_REPORT_COLUMN_FREEZE:
		{
			wndReport.SetFreezeColumnsCount(pColumn->GetIndex()+1);	
			int nStyle = m_pPaintManager->GetFreezeColsDividerStyle();
			nStyle &= ~~(xtpReportFreezeColsDividerBold | xtpReportFreezeColsDividerThin);
			nStyle |= xtpReportFreezeColsDividerBold;
			m_pPaintManager->SetFreezeColsDividerStyle(nStyle);
			wndReport.RedrawControl();
		}
		break;
	case ID_REPORT_COLUMN_ROWNUMBER:
		m_pPaintManager->SetDrawRowNumber(!m_pPaintManager->GetDrawRowNumber());
	    wndReport.RedrawControl();
		break;
	case ID_REPORT_COLUMN_AUTOUPDATESQL:
		m_bAutoUpdateSql = !m_bAutoUpdateSql;
		if(m_bAutoUpdateSql)
		{
			CXTPReportControl& wndReport = GetReportCtrl();
			CXTPReportSelectedRows* pSelectedRows = wndReport.GetSelectedRows();
			if(!pSelectedRows) return;
			int rs = pSelectedRows->GetCount();
			if(rs < 0) return;

			for(int i=0; i<rs; i++)
			{
				CXTPReportRecord* pRecord = pSelectedRows->GetAt(i)->GetRecord();
				if(pRecord)
				{
					CString val(((CXTPReportRecordItemVariant*)pRecord->GetItem(0))->GetValue().bstrVal);
					CString strTable = GetCurTable();
					int ret = AddRecordset(strTable, val);
					if(ret == 1)
					{
						int cs = pRecord->GetItemCount();
						CXTPADOData data(0,1,0,cs-1);
						if(cs > 0)
						{
							_variant_t* val = new _variant_t[cs];
							for(int j=0;j<cs;j++)
							{
								COleVariant va = ((CXTPReportRecordItemVariant*)pRecord->GetItem(j))->GetValue();
								val[j] = ((CXTPReportRecordItemVariant*)pRecord->GetItem(j))->GetValue();
							}
							data.vals[1] = val;
						}
						SetRecordset(strTable, data);
					}
				}
			}
		}
		wndReport.RedrawControl();
		break;
	}
}

void CReportRecordView::OnReportConstraintSelecting(NMHDR* pNMHDR, LRESULT* /*result*/)
{
	XTP_NM_REPORTCONSTRAINTSELECTING* pItemNotify = (XTP_NM_REPORTCONSTRAINTSELECTING*) pNMHDR;
	if(!pItemNotify) return;
	if(!pItemNotify->pRow || !pItemNotify->pItem || pItemNotify->pConstraint) return;

	CXTPReportRow* pSelRow = pItemNotify->pRow;
	CXTPReportRecordItem* pSelItem = pItemNotify->pItem;
	CXTPReportControl& wndReport = GetReportCtrl();

	if(pSelRow->GetType() != xtpRowTypeHeader)
	{
		CXTPReportRecord* pSelItemRcd = pSelItem->GetRecord();
		if(!pSelItemRcd) return;
		pSelItem->SetCaption(pItemNotify->pConstraint->m_strConstraint);
		CString strTable = GetCurTable();
		CString field = GetFieldName(strTable,pSelItem->GetIndex()+1);
		CString code = ((CXTPReportRecordItemVariant*)pSelItemRcd->GetItem(0))->GetValue().bstrVal;
		SetRecordset(strTable,field,code,_variant_t(pItemNotify->pConstraint->m_strConstraint));
	}

	Populate();
}

void CReportRecordView::OnReportChecked(NMHDR*  pNotifyStruct, LRESULT* /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pItemNotify = (XTP_NM_REPORTRECORDITEM*) pNotifyStruct;
	if(!pItemNotify) return;
	if(!pItemNotify->pRow || !pItemNotify->pItem) return;

	CXTPReportRow* pSelRow = pItemNotify->pRow;
	CXTPReportRecordItem* pSelItem = pItemNotify->pItem;
	CXTPReportControl& wndReport = GetReportCtrl();

	if(pSelRow->GetType() != xtpRowTypeHeader)
	{
		CXTPReportRecord* pSelItemRcd = pSelItem->GetRecord();
		if(!pSelItemRcd) return;
		pSelItem->SetCaption(pSelItem->IsChecked() ? _T("~{JG~}"):_T("~{7q~}"));
		CString strTable = GetCurTable();
		CString field = GetFieldName(strTable,pSelItem->GetIndex()+1);
		CString code = ((CXTPReportRecordItemVariant*)pSelItemRcd->GetItem(0))->GetValue().bstrVal;
		SetRecordset(strTable,field,code,_variant_t(pSelItem->IsChecked()?true:false));
	}
}

void CReportRecordView::OnReportRowExpanded(NMHDR*  pNotifyStruct, LRESULT* /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pItemNotify = (XTP_NM_REPORTRECORDITEM*) pNotifyStruct;
	if(!pItemNotify) return;
	if(!pItemNotify->pRow || !pItemNotify->pItem) return;

	CXTPReportRow* pSelRow = pItemNotify->pRow;
	CXTPReportRecordItem* pSelItem = pItemNotify->pItem;
}

void CReportRecordView::OnReportItemClick(NMHDR* pNMHDR, LRESULT* /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pItemNotify = (XTP_NM_REPORTRECORDITEM*) pNMHDR;
	if(!pItemNotify) return;
	if(!pItemNotify->pRow || !pItemNotify->pItem) return;
	m_pFocusItem = pItemNotify->pItem;
}

void CReportRecordView::OnReportItemRClick(NMHDR* pNMHDR, LRESULT* /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pItemNotify = (XTP_NM_REPORTRECORDITEM*) pNMHDR;
	if(!pItemNotify) return;
	if(!pItemNotify->pRow || !m_bShowItemMenu) return;

	CXTPReportRow* pSelRow = pItemNotify->pRow;
	CXTPReportControl& wndReport = GetReportCtrl();
	CPoint ptClick = pItemNotify->pt;

	if (pSelRow->IsGroupRow())
	{
		CMenu menu;
		if(!menu.CreatePopupMenu()) return;
		menu.AppendMenu(MF_STRING, ID_REPORT_GROUP_EXPANDALL, LoadResourceString(ID_REPORT_GROUP_EXPANDALL));
		menu.AppendMenu(MF_STRING, ID_REPORT_GROUP_COLLAPSEALL, LoadResourceString(ID_REPORT_GROUP_COLLAPSEALL));
		menu.AppendMenu(MF_SEPARATOR, (UINT)-1, (LPCTSTR)NULL);
		menu.AppendMenu(MF_STRING, ID_REPORT_GROUP_EXPANDCURALL, LoadResourceString(ID_REPORT_GROUP_EXPANDCURALL));
		menu.AppendMenu(MF_STRING, ID_REPORT_GROUP_COLLAPSECURALL, LoadResourceString(ID_REPORT_GROUP_COLLAPSECURALL));

		int nMenuResult = CXTPCommandBars::TrackPopupMenu(&menu, TPM_NONOTIFY | TPM_RETURNCMD | TPM_LEFTALIGN | TPM_RIGHTBUTTON, ptClick.x, ptClick.y, this, NULL);

		switch (nMenuResult)
		{
		case ID_REPORT_GROUP_EXPANDALL:
			ExpandAll();
			break;
		case ID_REPORT_GROUP_COLLAPSEALL:
			CollapseAll();
			break;
		case ID_REPORT_GROUP_EXPANDCURALL:
			ExpandCurAll(pSelRow);
			break;
		case ID_REPORT_GROUP_COLLAPSECURALL:
			CollapseCurAll(pSelRow);
			break;
		}
	} 
	else
	{
		if (!pItemNotify->pItem) return;
		CXTPReportRecordItem* pSelItem = pItemNotify->pItem;

		CMenu menu;
		if(!menu.CreatePopupMenu()) return;
		menu.AppendMenu(MF_STRING, ID_REPORT_RECORD_EDIT, LoadResourceString(ID_REPORT_RECORD_EDIT));
		menu.AppendMenu(MF_SEPARATOR, (UINT)-1, (LPCTSTR)NULL);
		menu.AppendMenu(MF_STRING, ID_REPORT_RECORD_ADD, LoadResourceString(ID_REPORT_RECORD_ADD));
		menu.AppendMenu(MF_STRING, ID_REPORT_RECORD_ADD, LoadResourceString(ID_REPORT_RECORD_SET));
		menu.AppendMenu(MF_STRING, ID_REPORT_RECORD_DEL, LoadResourceString(ID_REPORT_RECORD_DEL));
		menu.AppendMenu(MF_SEPARATOR, (UINT)-1, (LPCTSTR)NULL);
		menu.AppendMenu(MF_STRING, ID_REPORT_RECORD_IMP, LoadResourceString(ID_REPORT_RECORD_IMP));
		menu.AppendMenu(MF_STRING, ID_REPORT_RECORD_EXP, LoadResourceString(ID_REPORT_RECORD_EXP));
		menu.AppendMenu(MF_SEPARATOR, (UINT)-1, (LPCTSTR)NULL);
		menu.AppendMenu(MF_STRING, ID_REPORT_RECORD_ENCODE, LoadResourceString(ID_REPORT_RECORD_ENCODE));
		menu.AppendMenu(MF_STRING, ID_REPORT_RECORD_DECODE, LoadResourceString(ID_REPORT_RECORD_DECODE));


		int nMenuResult = CXTPCommandBars::TrackPopupMenu(&menu, TPM_NONOTIFY | TPM_RETURNCMD | TPM_LEFTALIGN | TPM_RIGHTBUTTON, ptClick.x, ptClick.y, this, NULL);

		switch (nMenuResult)
		{
		case ID_REPORT_RECORD_EDIT:
			wndReport.AllowEdit(TRUE);
			break;
		case ID_REPORT_RECORD_ADD:
			AddRcdToRst();
			break;
		case ID_REPORT_RECORD_SET:
			SetRcdToRst(pSelItem);
			break;
		case ID_REPORT_RECORD_DEL:
			DelRcdOfRst();
			break;
		case ID_REPORT_RECORD_IMP:
			OnToolsImport();
			break;
		case ID_REPORT_RECORD_EXP:
			OnToolsExport();
			break;
		case ID_REPORT_RECORD_ENCODE:
			EncodeRcdOfRst(pSelItem);
			break;
		case ID_REPORT_RECORD_DECODE:
			DecodeRcdOfRst(pSelItem);
			break;
		}

		wndReport.Populate();
	}
}

void CReportRecordView::OnReportItemDblClick(NMHDR* pNMHDR, LRESULT* /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pItemNotify = (XTP_NM_REPORTRECORDITEM*) pNMHDR;
	if(!pItemNotify) return;
	if(!pItemNotify->pRow || !pItemNotify->pItem)
	{

		CString filePath;
		filePath.Format(_T("%s\\Excel\\temp.csv"), GetCurPath());
		CStdioFile file;
		if(file.Open(filePath, CFile::modeCreate | CFile::modeReadWrite))
		{
			setlocale(LC_ALL,"");
			CXTPReportControl& wndReport = GetReportCtrl();
			file.Seek(CFile::begin,0);

			CXTPReportRecords* pRecords = wndReport.GetRecords();
			if(pRecords != NULL)
			{
				long rows = pRecords->GetCount();
				CXTPReportColumns* pColums = wndReport.GetColumns();
				if(pColums != NULL)
				{
					int cols = pColums->GetCount();
					CString strColums = pColums->GetAt(0)->GetCaption();
					file.WriteString(strColums);
					for(int i=1;i<cols-1;i++)
					{
						strColums = _T(",")+pColums->GetAt(i)->GetCaption();
						file.WriteString(strColums);
					}
					strColums.Format(_T(",%s\n"),pColums->GetAt(cols-1)->GetCaption());
					file.WriteString(strColums);

					for(long i=0; i<rows; i++)
					{
						CXTPReportRecord* pRecord = pRecords->GetAt(i);
						if(pRecord != NULL)
						{
							COleVariant vRecord = ((CXTPReportRecordItemVariant*)pRecord->GetItem(0))->GetValue();
							CString strRecord,str;
							if(vRecord.vt==VT_NULL) strRecord =  _T("");
							else if(vRecord.vt==VT_BSTR) strRecord =  vRecord.bstrVal;
							else if(vRecord.vt==VT_DECIMAL) strRecord = ToString(vRecord.lVal);
							else if(vRecord.vt==VT_R8) strRecord = ToString(vRecord.dblVal);
							else if(vRecord.vt==VT_I4) strRecord = ToString(vRecord.intVal);
							else if(vRecord.vt==VT_BOOL) strRecord = vRecord.boolVal ? _T("TRUE"):_T("FALSE");
							file.WriteString(strRecord);
							for(int j=1; j<cols-1; j++)
							{
								vRecord = ((CXTPReportRecordItemVariant*)pRecord->GetItem(j))->GetValue();
								if(vRecord.vt==VT_NULL) str =  _T("");
								else if(vRecord.vt==VT_BSTR) str =  vRecord.bstrVal;
								else if(vRecord.vt==VT_DECIMAL) str = ToString(vRecord.lVal);
								else if(vRecord.vt==VT_R8) str = ToString(vRecord.dblVal);
								else if(vRecord.vt==VT_I4) str = ToString(vRecord.intVal);
								else if(vRecord.vt==VT_BOOL) str = vRecord.boolVal ? _T("TRUE"):_T("FALSE");
								strRecord = _T(",")+str;
								file.WriteString(strRecord);
							}
							vRecord = ((CXTPReportRecordItemVariant*)pRecord->GetItem(cols-1))->GetValue();
							if(vRecord.vt==VT_NULL) str =  _T("");
							else if(vRecord.vt==VT_BSTR) str =  vRecord.bstrVal;
							else if(vRecord.vt==VT_DECIMAL) str = ToString(vRecord.lVal);
							else if(vRecord.vt==VT_R8) str = ToString(vRecord.dblVal);
							else if(vRecord.vt==VT_I4) str = ToString(vRecord.intVal);
							else if(vRecord.vt==VT_BOOL) str = vRecord.boolVal ? _T("TRUE"):_T("FALSE");
							strRecord.Format(_T(",%s\n"),str);
							file.WriteString(strRecord);
						}
					}
				}
			}
		}

		file.Close();

		ShellExecuteOpen(CXTPString(filePath));
	}
}

void CReportRecordView::OnDbTable()
{
	ShowDataListBox();
}

void CReportRecordView::OnDbMssql() 
{
	HRESULT hr;

	// choose database
	CDataSource dsConnection;
	if(FAILED(hr = dsConnection.Open(AfxGetMainWnd()->GetSafeHwnd())))
		return;

	BSTR bstrConnection/* = _T("Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=ProjectManage;Data Source=WIN-BIM001;Use Procedure for Prepare=1;Auto Translate=True;Packet Size=4096;Workstation ID=WIN-BIM001;Use Encryption for Data=False;Tag with column collation when possible=False")*/;
	if(FAILED(hr = dsConnection.GetInitializationString(&bstrConnection)))
		return;
	dsConnection.Close();

	try
	{
		if(theCon.Open(CString(bstrConnection)))
		{
			CString sql = _T("select name,xtype from sysobjects where xtype='U' or xtype='V' order by name");

			CXTPADORecordset rst(theCon);
			if(rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc))
				DataBindRecordset(rst);

			m_wndListBox.UpdateList();
		}
	}
	catch(...){}
}

void CReportRecordView::OnDbExcel() 
{
	TCHAR szFilter[] = _T("Excel2007~{ND<~~}|*.xlsx|Excel2003~{ND<~~}|*.xls|~{KySPND<~~}|*.*||");
	CFileDialog fd(TRUE, _T("xlsx"), NULL, 0, szFilter, this);
	if(IDOK == fd.DoModal())
	{
		CXTPADOConnection con;
		con.SetDataDriver(CXTPADOConnection::xtpAdoACEExcel);
		con.SetDataBase(fd.GetPathName());
		con.InitConnectionString();
		if (con.Open())
		{
			CString sql = _T("select * from [sheet1$]");

			CXTPADORecordset rst(con);
			if(rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc))
				DataBindRecordset(rst);

			m_wndListBox.UpdateList();
		}
	}
}

void CReportRecordView::OnDbAccess() 
{
	TCHAR szFilter[] = _T("Access2007~{ND<~~}|*.accdb|Access2003~{ND<~~}|*.mdb|~{KySPND<~~}|*.*||");
	CFileDialog fd(TRUE, _T("accdb"), NULL, 0, szFilter, this);
	if(IDOK == fd.DoModal())
	{
		CXTPADOConnection con;
		con.SetDataDriver(CXTPADOConnection::xtpAdoACEAccess);
		con.SetDataBase(fd.GetPathName());
		con.InitConnectionString();
		if (con.Open())
		{
			CString sql = _T("select * from employee8");

			CXTPADORecordset rst(con);
			if(rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc))
				DataBindRecordset(rst);

			m_wndListBox.UpdateList();
		}
	}
}

void CReportRecordView::OnEditCopy() 
{
	CXTPReportView::OnEditCopy();
}

void CReportRecordView::OnEditCut() 
{
	CXTPReportView::OnEditCut();
}

void CReportRecordView::OnEditPaste() 
{
	CXTPReportView::OnEditPaste();

	if(m_bAutoUpdateSql)
	{
		CXTPReportControl& wndReport = GetReportCtrl();
		CXTPReportSelectedRows* pSelectedRows = wndReport.GetSelectedRows();
		if(!pSelectedRows) return;
		int rs = pSelectedRows->GetCount();
		if(rs < 0) return;

		for(int i=0; i<rs; i++)
		{
			CXTPReportRecord* pRecord = pSelectedRows->GetAt(i)->GetRecord();
			if(pRecord)
			{
				CString val(((CXTPReportRecordItemVariant*)pRecord->GetItem(0))->GetValue().bstrVal);
				CString strTable = GetCurTable();
				int ret = AddRecordset(strTable, val);
				if(ret == 1)
				{
					int cs = pRecord->GetItemCount();
					CXTPADOData data(0,1,0,cs-1);
					if(cs > 0)
					{
						_variant_t* val = new _variant_t[cs];
						for(int j=0;j<cs;j++)
						{
							COleVariant va = ((CXTPReportRecordItemVariant*)pRecord->GetItem(j))->GetValue();
							val[j] = ((CXTPReportRecordItemVariant*)pRecord->GetItem(j))->GetValue();
						}
						data.vals[1] = val;
					}
					SetRecordset(strTable, data);
				}
			}
		}
	}
}

void CReportRecordView::OnEditSelectAll() 
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportRows* pRows = wndReport.GetRows();
	for (int i = 0; i<pRows->GetCount(); i++)
		pRows->GetAt(i)->SetSelected(TRUE);
}

void CReportRecordView::OnUpdateEditCopy(CCmdUI* pCmdUI) 
{
	CXTPReportView::OnUpdateEditCut(pCmdUI);
}

void CReportRecordView::OnUpdateEditCut(CCmdUI* pCmdUI) 
{
	CXTPReportView::OnUpdateEditCut(pCmdUI);
}

void CReportRecordView::OnUpdateEditPaste(CCmdUI* pCmdUI) 
{
	CXTPReportView::OnUpdateEditPaste(pCmdUI);
}

void CReportRecordView::OnUpdateEditSelectAll(CCmdUI* pCmdUI) 
{
	pCmdUI->SetCheck(m_bFocusSubItem);
}

void CReportRecordView::OnFileNew() 
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.ResetContent();
	wndReport.GetColumns()->Clear();

	for (int i=0; i<26; i++)
	{
		CXTPString sName(ToColumnLabel(i));
		CXTPReportColumn* pColumn =  wndReport.AddColumn(new CXTPReportColumn(i, sName, 100));
		pColumn->SetHeaderAlignment(DT_CENTER);
	}

	for (int i=0; i<50; i++)
	{
		CXTPReportRecord* pRecord = wndReport.AddRecord(new CXTPReportRecord());

		for (int j=0; j<26; j++)
		{
			pRecord->AddItem(new CXTPReportRecordItemText());
		}
	}

	wndReport.Populate();
}

void CReportRecordView::OnFileOpen() 
{
	CString strFilter = _T("XML Document (*.xml)|*.xml|All files (*.*)|*.*||");

	CFileDialog fd(TRUE, _T("xml"), NULL, OFN_FILEMUSTEXIST| OFN_HIDEREADONLY, strFilter);
	if (fd.DoModal() != IDOK)
		return;

	CXTPPropExchangeXMLNode px(TRUE, NULL, _T("ReportControl"));

	if (!px.LoadFromFile(fd.GetPathName()))
		return;

	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.DoPropExchange(&px);

	CXTPPropExchangeSection sec(px.GetSection(_T("Records")));
	wndReport.GetRecords()->DoPropExchange(&sec);

	wndReport.Populate();
}

void CReportRecordView::OnFileSave() 
{
	CString strFilter = _T("XML Document (*.xml)|*.xml|All files (*.*)|*.*||");

	CFileDialog fd(FALSE, _T("xml"), NULL, OFN_HIDEREADONLY|OFN_OVERWRITEPROMPT, strFilter);
	if (fd.DoModal() != IDOK)
		return;

	CXTPPropExchangeXMLNode px(FALSE, 0, _T("ReportControl"));
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.DoPropExchange(&px);

	CXTPPropExchangeSection sec(px.GetSection(_T("Records")));
	wndReport.GetRecords()->DoPropExchange(&sec);

	px.SaveToFile(fd.GetPathName());

	msgInf(_T("~{J}>]1#4f3I9&#!~}"));
}

void CReportRecordView::OnToolsImport()
{
	TCHAR szFilter[] = _T("CSV~{ND<~~}|*.csv|~{ND1>ND<~~}|*.txt|~{KySPND<~~}|*.*||");
	CFileDialog FileDlg(TRUE, _T("csv"), NULL, 0, szFilter, this);
	if(IDOK == FileDlg.DoModal())
	{
		CStdioFile file;
		if(file.Open(FileDlg.GetPathName(), CFile::modeRead))
		{
			setlocale(LC_ALL,"");
			CXTPReportControl& wndReport = GetReportCtrl();

			CString strLine;
			if(file.ReadString(strLine))
			{
				strLine.Trim();
				if(strLine.GetLength())
				{
					wndReport.GetColumns()->Clear();
					CXTPString xtpstr(strLine);
					vector<CXTPString> strs;
					xtpstr.ParseSubStrByDelimiter(strs,_T(","));
					for(int i=0; i<strs.size(); i++)
					{
						wndReport.AddColumn(new CXTPReportColumn(i,strs[i].t_str(),50));
					}
				}
			}

			wndReport.ResetContent();
			while(file.ReadString(strLine))
			{
				strLine.Trim();
				if(strLine.GetLength() == 0)
					continue;

				CXTPString xtpstr(strLine);
				vector<CXTPString> strs;
				xtpstr.ParseSubStrByDelimiter(strs,_T(","));

				CXTPReportRecord* pRecord = wndReport.AddRecord(new CXTPReportRecord());
				for(int i=0; i<strs.size(); i++)
				{
					pRecord->AddItem(new CXTPReportRecordItemVariant(COleVariant(strs[i].t_str())));
				}
			}

			file.Close();
			wndReport.Populate();
			msgInf(FileDlg.GetFileName() + " ~{ND<~5<Hk3I9&~}!");
		}
	}

	/*
	TCHAR szFilter[] = _T("Excel 2007|*.xlsx|Excel 2003|*.xls|CSV~{ND<~~}|*.csv|~{KySPND<~~}|*.*||");
	CFileDialog FileDlg(TRUE, _T("xlsx"), NULL, 0, szFilter, this);
	if(IDOK == FileDlg.DoModal())
	{
		CXTPReportControl& wndReport = GetReportCtrl();

		CXTPExcelUtil excel;
		excel.InitExcel();

		CString strFileName = FileDlg.GetFileName();
		CString strFilePath = FileDlg.GetPathName();
		strFilePath = strFilePath.Mid(0, strFilePath.ReverseFind('\\'));

		excel.OpenExcel(strFileName,strFilePath);
		excel.LoadSheet(1);
		long rows = excel.GetRowCount();
		int cols = excel.GetColCount();

		CXTPReportColumns* pColums = wndReport.GetColumns();
		pColums->Clear();
		for(int i=0;i<cols;i++)
		{
			CXTPReportColumn* pColum = new CXTPReportColumn(i,excel.GetCellString(1,i+1),excel.GetColumnWidth(i+1));
			pColums->Add(pColum);
		}

		CXTPReportRecords* pRecords = wndReport.GetRecords();
		pRecords->RemoveAll();
		for(long i=0; i<rows; i++)
		{
			CXTPReportRecord* pRecord = new CXTPReportRecord;
			for(int j=0; j<cols; j++)
				pRecord->AddItem(new CXTPReportRecordItemVariant(excel.GetCell(i+2,j+1)));

			pRecords->Add(pRecord);
		}

		excel.CloseExcel();
		excel.ReleaseExcel();

		wndReport.Populate();
		msgInf(FileDlg.GetFileName() + " ~{ND<~5<Hk3I9&~}!");
	}
	*/
}

void CReportRecordView::OnToolsExport()
{
	TCHAR szFilter[] = _T("CSV~{ND<~~}|*.csv|~{ND1>ND<~~}|*.txt|~{KySPND<~~}|*.*||");
	CFileDialog FileDlg(FALSE, _T("csv"), NULL, 0, szFilter, this);
	if(IDOK == FileDlg.DoModal())
	{
		CStdioFile file;
		if(file.Open(FileDlg.GetPathName(), CFile::modeCreate | CFile::modeReadWrite))
		{
			setlocale(LC_ALL,"");
			CXTPReportControl& wndReport = GetReportCtrl();
			file.Seek(CFile::begin,0);

			CXTPReportSelectedRows* pRows = wndReport.GetSelectedRows();
			if(pRows != NULL && pRows->GetCount() > 1)
			{
				long rows = pRows->GetCount();
				CXTPReportColumns* pColums = wndReport.GetColumns();
				if(pColums != NULL)
				{
					int cols = pColums->GetCount();
					CString strColums = pColums->GetAt(0)->GetCaption();
					file.WriteString(strColums);
					for(int i=1;i<cols-1;i++)
					{
						strColums = _T(",")+pColums->GetAt(i)->GetCaption();
						file.WriteString(strColums);
					}
					strColums.Format(_T(",%s\n"),pColums->GetAt(cols-1)->GetCaption());
					file.WriteString(strColums);

					for(long i=0; i<rows; i++)
					{
						CXTPReportRow* pRow = pRows->GetAt(i);
						if(pRow != NULL)
						{
							CXTPReportRecord* pRecord = pRow->GetRecord();
							if(pRecord != NULL)
							{
								COleVariant vRecord = ((CXTPReportRecordItemVariant*)pRecord->GetItem(0))->GetValue();
								CString strRecord,str;
								if(vRecord.vt==VT_NULL) strRecord =  _T("");
								else if(vRecord.vt==VT_BSTR) strRecord =  vRecord.bstrVal;
								else if(vRecord.vt==VT_DECIMAL) strRecord = ToString(vRecord.lVal);
								else if(vRecord.vt==VT_R8) strRecord = ToString(vRecord.dblVal);
								else if(vRecord.vt==VT_I4) strRecord = ToString(vRecord.intVal);
								else if(vRecord.vt==VT_BOOL) strRecord = vRecord.boolVal ? _T("TRUE"):_T("FALSE");
								file.WriteString(strRecord);
								for(int j=1; j<cols-1; j++)
								{
									vRecord = ((CXTPReportRecordItemVariant*)pRecord->GetItem(j))->GetValue();
									if(vRecord.vt==VT_NULL) str =  _T("");
									else if(vRecord.vt==VT_BSTR) str =  vRecord.bstrVal;
									else if(vRecord.vt==VT_DECIMAL) str = ToString(vRecord.lVal);
									else if(vRecord.vt==VT_R8) str = ToString(vRecord.dblVal);
									else if(vRecord.vt==VT_I4) str = ToString(vRecord.intVal);
									else if(vRecord.vt==VT_BOOL) str = vRecord.boolVal ? _T("TRUE"):_T("FALSE");
									strRecord = _T(",")+str;
									file.WriteString(strRecord);
								}
								vRecord = ((CXTPReportRecordItemVariant*)pRecord->GetItem(cols-1))->GetValue();
								if(vRecord.vt==VT_NULL) str =  _T("");
								else if(vRecord.vt==VT_BSTR) str =  vRecord.bstrVal;
								else if(vRecord.vt==VT_DECIMAL) strRecord = ToString(vRecord.lVal);
								else if(vRecord.vt==VT_R8) str = ToString(vRecord.dblVal);
								else if(vRecord.vt==VT_I4) str = ToString(vRecord.intVal);
								else if(vRecord.vt==VT_BOOL) str = vRecord.boolVal ? _T("TRUE"):_T("FALSE");
								strRecord.Format(_T(",%s\n"),str);
								file.WriteString(strRecord);
							}
						}
					}
				}
			}
			else
			{
				CXTPReportRecords* pRecords = wndReport.GetRecords();
				if(pRecords != NULL)
				{
					long rows = pRecords->GetCount();
					CXTPReportColumns* pColums = wndReport.GetColumns();
					if(pColums != NULL)
					{
						int cols = pColums->GetCount();
						CString strColums = pColums->GetAt(0)->GetCaption();
						file.WriteString(strColums);
						for(int i=1;i<cols-1;i++)
						{
							strColums = _T(",")+pColums->GetAt(i)->GetCaption();
							file.WriteString(strColums);
						}
						strColums.Format(_T(",%s\n"),pColums->GetAt(cols-1)->GetCaption());
						file.WriteString(strColums);

						for(long i=0; i<rows; i++)
						{
							CXTPReportRecord* pRecord = pRecords->GetAt(i);
							if(pRecord != NULL)
							{
								COleVariant vRecord = ((CXTPReportRecordItemVariant*)pRecord->GetItem(0))->GetValue();
								CString strRecord,str;
								if(vRecord.vt==VT_NULL) strRecord =  _T("");
								else if(vRecord.vt==VT_BSTR) strRecord =  vRecord.bstrVal;
								else if(vRecord.vt==VT_DECIMAL) strRecord = ToString(vRecord.lVal);
								else if(vRecord.vt==VT_R8) strRecord = ToString(vRecord.dblVal);
								else if(vRecord.vt==VT_I4) strRecord = ToString(vRecord.intVal);
								else if(vRecord.vt==VT_BOOL) strRecord = vRecord.boolVal ? _T("TRUE"):_T("FALSE");
								file.WriteString(strRecord);
								for(int j=1; j<cols-1; j++)
								{
									vRecord = ((CXTPReportRecordItemVariant*)pRecord->GetItem(j))->GetValue();
									if(vRecord.vt==VT_NULL) str =  _T("");
									else if(vRecord.vt==VT_BSTR) str =  vRecord.bstrVal;
								    else if(vRecord.vt==VT_DECIMAL) str = ToString(vRecord.lVal);
									else if(vRecord.vt==VT_R8) str = ToString(vRecord.dblVal);
									else if(vRecord.vt==VT_I4) str = ToString(vRecord.intVal);
									else if(vRecord.vt==VT_BOOL) str = vRecord.boolVal ? _T("TRUE"):_T("FALSE");
									strRecord = _T(",")+str;
									file.WriteString(strRecord);
								}
								vRecord = ((CXTPReportRecordItemVariant*)pRecord->GetItem(cols-1))->GetValue();
								if(vRecord.vt==VT_NULL) str =  _T("");
								else if(vRecord.vt==VT_BSTR) str =  vRecord.bstrVal;
								else if(vRecord.vt==VT_DECIMAL) str = ToString(vRecord.lVal);
								else if(vRecord.vt==VT_R8) str = ToString(vRecord.dblVal);
								else if(vRecord.vt==VT_I4) str = ToString(vRecord.intVal);
								else if(vRecord.vt==VT_BOOL) str = vRecord.boolVal ? _T("TRUE"):_T("FALSE");
								strRecord.Format(_T(",%s\n"),str);
								file.WriteString(strRecord);
							}
						}
					}
				}
			}

			file.Close();
			msgInf(FileDlg.GetFileName() + " ~{ND<~5<3v3I9&~}!");
		}	
	}

	/*
	TCHAR szFilter[] = _T("Excel 2007|*.xlsx|Excel 2003|*.xls|CSV~{ND<~~}|*.csv|~{KySPND<~~}|*.*||");
	CFileDialog FileDlg(FALSE, _T("xlsx"), NULL, 0, szFilter, this);
	if(IDOK == FileDlg.DoModal())
	{
		CXTPReportControl& wndReport = GetReportCtrl();

		CXTPExcelUtil excel;
		excel.InitExcel();

		CString strFileName = FileDlg.GetFileName();
		CString strFilePath = FileDlg.GetPathName();
		strFilePath = strFilePath.Mid(0, strFilePath.ReverseFind('\\'));

		excel.CreateExcel(strFileName,strFilePath);
		excel.OpenExcel(strFileName,strFilePath);
		excel.LoadSheet(1);

		CXTPReportRecords* pRecords = wndReport.GetRecords();
		long rows = pRecords->GetCount();
		CXTPReportColumns* pColums = wndReport.GetColumns();
		int cols = pColums->GetCount();
		for(int i=0;i<cols;i++)
			excel.SetCell(pColums->GetAt(i)->GetCaption(),1,i+1);

		for(long i=0; i<rows; i++)
		{
			CXTPReportRecord* pRecord = pRecords->GetAt(i);
			for(int j=0; j<cols; j++)
				excel.SetCell(((CXTPReportRecordItemVariant*)pRecord->GetItem(j))->GetValue(),i+2,j+1);
		}

		excel.Save();
		excel.CloseExcel();
		excel.ReleaseExcel();

		msgInf(FileDlg.GetFileName() + " ~{ND<~5<3v3I9&~}!");
	}
	*/
}

void CReportRecordView::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags) 
{
	CXTPReportControl& wndReport = GetReportCtrl();
	switch(nChar)
	{
	case VK_DELETE :
		DelRcdOfRst();
		break;
	case VK_INSERT :
		AddRcdToRst();
		break;
	case VK_RETURN :
		{
			CXTPReportRow* pFocusedRow = wndReport.GetFocusedRow();
			if(pFocusedRow && pFocusedRow->GetType() == xtpRowTypeHeader)
			{
				CXTPReportRecord* pRecord = pFocusedRow->GetRecord();
				if(!pRecord)
					break;
				pRecord->InternalAddRef();
				HRESULT hr;
				if(FAILED(hr = wndReport.GetDataManager()->AddRecord(pRecord, TRUE)))
				{
					pRecord->InternalRelease();
					break;
				}
				pRecord = NULL;
				if(FAILED(hr = wndReport.GetDataManager()->CreateEmptyRecord(&pRecord)) || pRecord == NULL)
					break;
				wndReport.GetHeaderRecords()->RemoveAll();
				wndReport.GetHeaderRecords()->Add(pRecord);
				wndReport.PopulateHeaderRows();
			}
		}
		break;
	}

	CXTPReportView::OnKeyDown(nChar, nRepCnt, nFlags);
}

void CReportRecordView::OnDestroy()
{
	SaveReportState();

	if (m_pReportFrame)
		m_pReportFrame->DestroyWindow();
	if (m_pReportFrame)
		m_pReportFrame->DestroyWindow();

	CXTPReportView::OnDestroy();
}

void CReportRecordView::OnSetFocus(CWnd* pOldWnd)
{
	CXTPReportView::OnSetFocus(pOldWnd);

	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.SetFocus();
}

void CReportRecordView::SetTable(CString strTable, BOOL bAuto)
{
	m_strTable = strTable;
	if(bAuto)
	{
		m_nType = XTP_REPORT_TABLE_TYPE_TB;
		m_strView = _T("tv")+m_strTable.Mid(2,m_strTable.GetLength());
		m_strPreview = _T("tp")+m_strTable.Mid(2,m_strTable.GetLength());
	}
}

void CReportRecordView::SetView(CString strView, BOOL bAuto)
{
	m_strView = strView;
	if(bAuto)
	{
		m_nType = XTP_REPORT_TABLE_TYPE_TV;
		m_strTable = _T("tb")+m_strView.Mid(2,m_strView.GetLength());
		m_strPreview = _T("tp")+m_strView.Mid(2,m_strView.GetLength());
	}
}

void CReportRecordView::SetPreview(CString strPreview, BOOL bAuto)
{
	m_strPreview = strPreview;
	if(bAuto)
	{
		m_nType = XTP_REPORT_TABLE_TYPE_TP;
		m_strTable = _T("tb")+m_strPreview.Mid(2,m_strPreview.GetLength());
		m_strView = _T("tv")+m_strPreview.Mid(2,m_strPreview.GetLength());
	}
}


void CReportRecordView::SetType(UINT nType)
{
	m_nType = nType;
}

CString CReportRecordView::GetCurTable()
{
	switch (m_nType)
	{
	case XTP_REPORT_TABLE_TYPE_TV:
		return m_strView;
	case XTP_REPORT_TABLE_TYPE_TP:
		return m_strPreview;
	}

	return m_strTable;
}

CString CReportRecordView::GetTable()
{
	return m_strTable;
}

CString CReportRecordView::GetView()
{
	return m_strView;
}

CString CReportRecordView::GetPreview()
{
	return m_strPreview;
}

CString CReportRecordView::GetBackup()
{
	return m_strTable+_T("_bkp");
}

int CReportRecordView::GetType()
{
	return m_nType;
}

BOOL CReportRecordView::IsTable()
{
	return m_nType == XTP_REPORT_TABLE_TYPE_TB;
}

BOOL CReportRecordView::IsView()
{
	return m_nType == XTP_REPORT_TABLE_TYPE_TV;
}

BOOL CReportRecordView::IsPreview()
{
	return m_nType == XTP_REPORT_TABLE_TYPE_TP;
}

void CReportRecordView::SetAutoUpdateSql(BOOL bAutoUpdateSql)
{
	m_bAutoUpdateSql = bAutoUpdateSql;
}

BOOL CReportRecordView::IsAutoUpdateSql()
{
	return m_bAutoUpdateSql;
}

void CReportRecordView::AddRcdToRst()
{
	if(IsPreview()) return;

	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportSelectedRows* pSelectedRows = wndReport.GetSelectedRows();
	if(!pSelectedRows) return;
	int nRow = pSelectedRows->GetCount();
	CString strTable = GetCurTable();
	if(!nRow)
	{
		CString code;
		AddRecordset(strTable,code);
		CXTPADOData data;
		GetRecord(data, strTable, code, _T("*"));
		CXTPReportRecord* pRecord = new CXTPReportRecord;
		_variant_t* vals = (_variant_t*)data.vals[1];
		for(int i=0; i<data.cols; i++)
			pRecord->AddItem(new CXTPReportRecordItemVariant(vals[i]));
		wndReport.AddRecord(pRecord);
	}
	else
	{
		CWaitCursor wc;
		while(nRow-- >  0)
		{
			CString code;
			AddRecordset(strTable,code);
			CXTPADOData data;
			GetRecord(data, strTable, code, _T("*"));
			CXTPReportRecord* pRecord = new CXTPReportRecord;
			_variant_t* vals = (_variant_t*)data.vals[1];
			for(int i=0; i<data.cols; i++)
				pRecord->AddItem(new CXTPReportRecordItemVariant(vals[i]));
			wndReport.AddRecord(pRecord);
		}
	}

	wndReport.Populate();
	SetRecordItemControl();
	SetRecordItemEditable();
	CXTPReportRow* pSelRow = wndReport.GetRows()->GetAt(wndReport.GetRows()->GetCount()-1);
	wndReport.SetFocusedRow(pSelRow ? pSelRow : wndReport.GetFocusedRow());
}

void CReportRecordView::SetRcdToRst(CXTPReportRecordItem* pItem)
{
	if(IsPreview()) return;
	if(pItem)
	{
		CXTPReportRecord* pRcd = pItem->GetRecord();
		if(!pRcd) return;

		CString strTable = GetCurTable();
		CString field = GetFieldName(strTable,pItem->GetIndex()+1);
		CString code = ((CXTPReportRecordItemVariant*)pRcd->GetItem(0))->GetValue().bstrVal;
		SetRecordset(strTable,field,code,((CXTPReportRecordItemVariant*)pItem)->GetValue());
	}
	else
	{
		CXTPReportControl& wndReport = GetReportCtrl();
		CXTPReportRow* pRow = wndReport.GetFocusedRow();
		if(!pRow) return;

		CXTPReportRecord* pRcd = pRow->GetRecord();
		if(!pRcd) return;
		CString strTable = GetCurTable();
		CXTPADOData data;
		int nItems = pRcd->GetItemCount();
		COleVariant* vals = new COleVariant[nItems];
		for(int i=0; i<pRcd->GetItemCount(); i++)
			vals[i] = ((CXTPReportRecordItemVariant*)pRcd->GetItem(i))->GetValue();
		data.vals[1] = vals;
		data.col2=nItems-1;
		data.rows=1;
		data.cols = nItems;
		SetRecordset(strTable,data);
	}
}

void CReportRecordView::DelRcdOfRst() 
{
	if(IsPreview()) return;

	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportSelectedRows* pSelectedRows = wndReport.GetSelectedRows();
	if(!pSelectedRows) return;
	int nRow = pSelectedRows->GetCount();
	if(!nRow) return;

	CWaitCursor wc;
	CXTPReportRow* pSelRow = pSelectedRows->GetAt(--nRow);
	pSelRow = wndReport.GetRows()->GetAt(pSelRow->GetIndex() + 1);
	CString strTable = GetTable();
	while(nRow >=  0)
	{
		CXTPReportRecord* pRecord = pSelectedRows->GetAt(nRow)->GetRecord();
		if(pRecord)
		{
			CString val(((CXTPReportRecordItemVariant*)pRecord->GetItem(0))->GetValue().bstrVal);
			DelRecordset(strTable, val);
			wndReport.RemoveRowEx(pSelectedRows->GetAt(nRow--));
		}
		
		if(nRow >= pSelectedRows->GetCount())
			nRow = pSelectedRows->GetCount() - 1;
	}

	wndReport.Populate();
	wndReport.SetFocusedRow(pSelRow ? pSelRow : wndReport.GetFocusedRow());
}

void CReportRecordView::EncodeRcdOfRst(CXTPReportRecordItem* pItem)
{
	if(pItem)
	{
		COleVariant val = ((CXTPReportRecordItemVariant*)pItem)->GetValue();
		CString str = EnCodeStr(CString(val.bstrVal)).t_str();
		((CXTPReportRecordItemVariant*)pItem)->SetValue(COleVariant(str));
		SetRcdToRst(pItem);
	}
}

void CReportRecordView::DecodeRcdOfRst(CXTPReportRecordItem* pItem)
{
	if(pItem)
	{
		COleVariant val = ((CXTPReportRecordItemVariant*)pItem)->GetValue();
		CString str = DeCodeStr(CString(val.bstrVal)).t_str();
		((CXTPReportRecordItemVariant*)pItem)->SetValue(COleVariant(str));
		SetRcdToRst(pItem);
	}
}

BOOL CReportRecordView::FindInReport()
{
	//CString sIn(_T("James HOWLETT"));
	//CString sIn(_T("james howlett"));
	//CString sIn(_T("James "));
	CString sIn(_T("ames "));
	//CString sIn(_T("JaMes hOWlETT"));
	CString sOut;
	int iR, iC;
	CXTPReportControl& wndReport = GetReportCtrl();
	int iCols = wndReport.GetColumns()->GetCount();
	int iRows = wndReport.GetRows()->GetCount();
	iR = iRows - 1;
	iC = iCols - 1;
	CXTPReportRecordItem* 
		pItem = wndReport.GetRecords()->FindRecordItem(0, iRows - 1, 0, iCols - 1, 0, 0, 
		sIn, 
		//xtpReportTextSearchExactPhrase 
		//| xtpReportTextSearchMatchCase
		//| 
		xtpReportTextSearchExactStart
		);// was == 3 - now 11

	if (pItem)
	{
		AfxMessageBox(sIn + _T(" <- xtpReportTextSearchExactStart -> ") + pItem->GetCaption(NULL));
		pItem->SetTextColor(RGB(255,0,0));
	}
	else
		AfxMessageBox(sIn + _T(" <- xtpReportTextSearchExactStart -> Not Found for ames"));

	sIn = _T("James ");
	pItem = wndReport.GetRows()->FindRecordItemByRows(0, iRows - 1, 0, iCols - 1, 0, 0, 
		sIn, 
		//xtpReportTextSearchExactPhrase 
		//| xtpReportTextSearchMatchCase
		//| 
		xtpReportTextSearchExactStart
		);// was == 3 - now 11

	if (pItem)
	{
		AfxMessageBox(sIn + _T(" <- FindRecordItemByRows|xtpReportTextSearchExactStart -> ") + pItem->GetCaption(NULL));
		pItem->SetTextColor(RGB(255,0,0));
	}
	else
		AfxMessageBox(sIn + _T(" <- FindRecordItemByRows|xtpReportTextSearchExactStart -> Not Found for James"));

	pItem = wndReport.GetRecords()->FindRecordItem(0, iRows - 1, 0, iCols - 1, 0, 0, 
		sIn, 
		//xtpReportTextSearchExactPhrase 
		//| xtpReportTextSearchMatchCase
		//| 
		xtpReportTextSearchExactStart
		);// was == 3 - now 11

	if (pItem)
	{
		AfxMessageBox(sIn + _T(" <- ExactStart -> ") + pItem->GetCaption(NULL));
		pItem->SetTextColor(RGB(255,0,0));
	}
	else
		AfxMessageBox(sIn + _T(" <- ExactStart -> Not Found for How"));

	pItem = wndReport.GetRecords()->FindRecordItem(0, iRows - 1, 0, iCols - 1, 0, 0, 
		sIn, xtpReportTextSearchMatchCase); // == 2

	if (pItem)
	{
		AfxMessageBox(sIn + _T(" <- M -> ") + pItem->GetCaption(NULL));
		pItem->SetTextColor(RGB(255,0,0));
	}
	else
		AfxMessageBox(sIn + _T(" <- M -> Not Found"));

	pItem =  wndReport.GetRecords()->FindRecordItem(0, iRows - 1, 0, iCols - 1, 0, 0, 
		sIn, xtpReportTextSearchExactPhrase); // == 1

	if (pItem)
	{
		iR = pItem->GetRecord()->GetIndex();
		iC = pItem->GetIndex();
		sOut.Format(_T("R=%d C=%d %s"), iR, iC, pItem->GetCaption(NULL));
		AfxMessageBox(sIn + _T(" <- E -> ") + sOut);
		pItem->SetTextColor(RGB(255,0,0));
	}
	else
		AfxMessageBox(sIn + _T(" <- E -> Not Found"));

	pItem = wndReport.GetRecords()->FindRecordItem(0, iRows - 1, 0, iCols - 1, iR, iC, 
		sIn, 0);

	if (pItem)
	{
		iR = pItem->GetRecord()->GetIndex();
		iC = pItem->GetIndex();
		sOut.Format(_T("R=%d C=%d %s"), iR, iC, pItem->GetCaption(NULL));
		AfxMessageBox(sIn + _T(" <- S (FindNext)-> ") + sOut);
		pItem->SetTextColor(RGB(255,0,0));
	}
	else
		AfxMessageBox(sIn + _T(" <- S (FindNext)-> Not Found"));

	pItem = wndReport.GetRecords()->FindRecordItem(0, iRows - 1, 0, iCols - 1, iR, iC, 
		sIn, xtpReportTextSearchBackward);

	if (pItem)
	{
		iR = pItem->GetRecord()->GetIndex();
		iC = pItem->GetIndex();
		sOut.Format(_T("R=%d C=%d %s"), iR, iC, pItem->GetCaption(NULL));
		AfxMessageBox(sIn + _T(" <- Backward (FindNext)-> ") + sOut);
		pItem->SetTextColor(RGB(255,0,0));
	}
	else
		AfxMessageBox(sIn + _T(" <- Backward (FindNext)-> Not Found"));

	return TRUE;
}

void CReportRecordView::ShowFilterEdit()
{
	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
	if (pMaainFrame)
	{
		BOOL bShow = !pMaainFrame->m_wndFilterEdit.IsVisible();
		pMaainFrame->ShowControlBar(&pMaainFrame->m_wndFilterEdit, bShow, FALSE);
		pMaainFrame->DockControlBar(&pMaainFrame->m_wndFilterEdit);
		CRect rc;
		GetWindowRect(&rc);
		CPoint point(rc.left+rc.Width()/4,rc.top+rc.Height()/5);
		pMaainFrame->FloatControlBar(&pMaainFrame->m_wndFilterEdit, point);
	}
}

void CReportRecordView::ShowFieldSubList()
{
	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
	if (pMaainFrame)
	{
		BOOL bShow = !pMaainFrame->m_wndSubList.IsVisible();
		pMaainFrame->ShowControlBar(&pMaainFrame->m_wndSubList, bShow, FALSE);
		pMaainFrame->DockControlBar(&pMaainFrame->m_wndSubList);
		CRect rc;
		GetWindowRect(&rc);
		CPoint point(rc.left+rc.Width()/4,rc.top+rc.Height()/5);
		pMaainFrame->FloatControlBar(&pMaainFrame->m_wndSubList, point);
	}
}

void CReportRecordView::ShowDataListBox()
{
	CMainFrame* pMaainFrame = (CMainFrame*)AfxGetMainWnd();
	if (pMaainFrame)
	{
		BOOL bShow = !pMaainFrame->m_wndListBox.IsVisible();
		pMaainFrame->ShowControlBar(&pMaainFrame->m_wndListBox, bShow, FALSE);
		pMaainFrame->DockControlBar(&pMaainFrame->m_wndListBox);
		CRect rc;
		GetWindowRect(&rc);
		CPoint point(rc.left+rc.Width()/4,rc.top+rc.Height()/5);
		pMaainFrame->FloatControlBar(&pMaainFrame->m_wndListBox, point);
	}
}

void CReportRecordView::DataBindRecordset(XTPREPORTMSADODB::_RecordsetPtr rst, BOOL init)
{
	ShowHeaderRows(FALSE);
	ShowFooterRows(FALSE);
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportDataManager* pDataManager = wndReport.GetDataManager();
	CString strTable = GetCurTable();
	if(rst != NULL)
		pDataManager->SetDataSource(rst);
	else
		pDataManager->SetDataSource(GetRecordset(strTable));
	pDataManager->DataBind();
	
	if(init) InitRecordItemControlDataList();

	CXTPReportColumns* pColums = wndReport.GetColumns();
	for(int i=0; i<pColums->GetCount(); i++)
	{
		pColums->GetAt(i)->SetHeaderAlignment(DT_CENTER);
		pColums->GetAt(i)->SetAlignment(DT_CENTER);
	}

	wndReport.Populate();
}

void CReportRecordView::ShowGroupRowFormula(CString strFormula)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	for (int i=0; i<wndReport.GetRows()->GetCount(); i++)
	{
		CXTPReportRow *pRow = m_wndReport.GetRows()->GetAt(i);

		if (pRow->IsGroupRow())
		{
			CXTPReportGroupRow *pGroupRow = reinterpret_cast<CXTPReportGroupRow*>(pRow);
			pGroupRow->SetFormatString(_T(" Total $=%d"));
			pGroupRow->SetFormula(strFormula);
			pGroupRow->SetCaption(_T("x"));
		}
	}
}

void CReportRecordView::ShowHeaderRows(BOOL bShow)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.ShowHeaderRows(bShow);
	// add empty header row
	m_pPaintManager->SetHeaderRowsDividerStyle(xtpReportFixedRowsDividerOutlook);
	wndReport.GetHeaderRecords()->RemoveAll();
	CXTPReportRecord* pRecord = NULL;
	if(SUCCEEDED(wndReport.GetDataManager()->CreateEmptyRecord(&pRecord)) && pRecord != NULL)
		wndReport.GetHeaderRecords()->Add(pRecord);

	wndReport.PopulateHeaderRows();
}

void CReportRecordView::ShowFooterRows(BOOL bShow)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.ShowFooterRows(bShow);
	m_pPaintManager->SetFooterRowsDividerStyle(xtpReportFixedRowsDividerOutlook);
	wndReport.GetFooterRecords()->RemoveAll();

	if (bShow)
	{
		CXTPReportRecord* pRecord = NULL;
		if(SUCCEEDED(wndReport.GetDataManager()->CreateEmptyRecord(&pRecord)) && pRecord != NULL)
			wndReport.GetFooterRecords()->Add(pRecord);

		if(pRecord != NULL)
		{
			CXTPReportRecordItemVariant* pItem = ((CXTPReportRecordItemVariant*)pRecord->GetItem(0));
			pItem->InitItem(&wndReport,pRecord);
			pItem->SetFormula(_T("COUNT(R0C0:R*C0)"));
			pItem->SetCaption(_T("x"));

			for(int i=1; i<pRecord->GetItemCount(); i++)
			{
				pItem = ((CXTPReportRecordItemVariant*)pRecord->GetItem(i));
				pItem->InitItem(&wndReport,pRecord);
				COleVariant vtValue = pItem->GetValue();
				CString formula;
				switch(vtValue.vt)
				{
				case VT_I4:
				case VT_R8:
				case VT_BOOL:
					formula.Format(_T("SUM(R*C%d:R*C%d)"),i,i);
					break;
				case VT_BSTR:
					formula.Format(_T("COUNT(R*C%d:R*C%d)"),i,i);
					break;
				}

				pItem->SetFormatString(_T("%.02f"));
				pItem->SetFormula(formula);
				pItem->SetCaption(_T("x"));
			}

			wndReport.PopulateFooterRows();
		}
	}
}

void CReportRecordView::Populate()
{
	CXTPReportControl& wndReport = GetReportCtrl();

	wndReport.Populate();
}

void CReportRecordView::PopulateHeaderRows()
{
	CXTPReportControl& wndReport = GetReportCtrl();

	wndReport.PopulateHeaderRows();
}

void CReportRecordView::PopulateFooterRows()
{
	CXTPReportControl& wndReport = GetReportCtrl();

	wndReport.PopulateFooterRows();
}

CXTPReportSelectedRows* CReportRecordView::GetSelectedRows()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.GetSelectedRows();
}

CXTPReportRow* CReportRecordView::GetFocusedRow()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.GetFocusedRow();
}

CXTPReportColumn* CReportRecordView::GetFocusedColumn()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.GetFocusedColumn();
}

CXTPReportRecords* CReportRecordView::GetRecords()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.GetRecords();
}

CXTPReportColumns* CReportRecordView::GetColumns()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.GetColumns();
}

CXTPReportRows* CReportRecordView::GetRows()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.GetRows();
}

CXTPReportPaintManager* CReportRecordView::GetPaintManager()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.GetPaintManager();
}

CXTPImageManager* CReportRecordView::GetImageManager()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.GetImageManager();
}

CXTPMarkupContext* CReportRecordView::GetMarkupContext()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.GetMarkupContext();
}

BOOL CReportRecordView::IsShowHeaderRows()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.IsHeaderRowsVisible();
}

BOOL CReportRecordView::IsShowFooterRows()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.IsFooterRowsVisible();
}

void CReportRecordView::AllowEdit(BOOL bEdit)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.AllowEdit(bEdit);
}

void CReportRecordView::AllowHeaderEdit(BOOL bEdit)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.HeaderRowsAllowEdit(bEdit);
}

void CReportRecordView::AllowFooterEdit(BOOL bEdit)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.FooterRowsAllowEdit(bEdit);
}

BOOL CReportRecordView::IsAllowEdit()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.IsAllowEdit();
}

BOOL CReportRecordView::IsAllowHeaderEdit()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.IsHeaderRowsAllowEdit();
}

BOOL CReportRecordView::IsAllowFooterEdit()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.IsFooterRowsAllowEdit();
}

void CReportRecordView::AllowMultipleSelection(BOOL bAllow)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.SetMultipleSelection(bAllow);
}

void CReportRecordView::AllowFocusSubItems(BOOL bAllow)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.FocusSubItems(bAllow);
}

BOOL CReportRecordView::IsAllowMultipleSelection()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.IsMultipleSelection();
}

BOOL CReportRecordView::IsAllowFocusSubItems()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.IsFocusSubItems();
}

void CReportRecordView::ShowGroupBox(BOOL bShow)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.ShowGroupBy(bShow);
}

void CReportRecordView::ExpandAll()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.ExpandAll();
}

void CReportRecordView::CollapseAll()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.CollapseAll();
}

void CReportRecordView::ExpandCurAll(CXTPReportRow* pRow)
{
	if(pRow != NULL && pRow->IsGroupRow())
	{
		pRow->SetExpanded(TRUE);
		if(pRow->HasChildren())
		{
			CXTPReportRows* pRows = pRow->GetChilds();
			if (pRows != NULL)
			{
				for (int i=0; i<pRows->GetCount();i++)
				{
					ExpandCurAll(pRows->GetAt(i));
				}
			}
		}
	}
}

void CReportRecordView::CollapseCurAll(CXTPReportRow* pRow)
{
	if(pRow != NULL && pRow->IsGroupRow())
	{
		pRow->SetExpanded(FALSE);
		if(pRow->HasChildren())
		{
			CXTPReportRows* pRows = pRow->GetChilds();
			if (pRows != NULL)
			{
				for (int i=0; i<pRows->GetCount();i++)
				{
					CollapseCurAll(pRows->GetAt(i));
				}
			}
		}
	}
}

void CReportRecordView::SetGridStyle(BOOL bVert, XTPReportGridStyle style)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.SetGridStyle(bVert, style);
}

XTPReportGridStyle CReportRecordView::GetGridStyle(BOOL bVert)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.GetGridStyle(bVert);
}

COLORREF CReportRecordView::SetGridColor(COLORREF clrGrid)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	COLORREF clrOld = wndReport.SetGridColor(clrGrid);
	wndReport.RedrawControl();
	return clrOld;
}

COLORREF CReportRecordView::GetGridColor()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.GetPaintManager()->GetGridColor();
}

void CReportRecordView::SetEnablePreview(BOOL bEnable)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.EnablePreviewMode(bEnable);
	wndReport.Populate();
}

BOOL CReportRecordView::IsEnablePreview()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.IsPreviewMode();
}

void CReportRecordView::SetEnableMarkup(BOOL bEnable)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.EnableMarkup(bEnable);
	wndReport.Populate();
}

BOOL CReportRecordView::IsEnableMarkup()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.GetMarkupContext() != NULL;
}

void CReportRecordView::ShowColumnMenu(BOOL bShow)
{
	m_bShowColumnMenu = bShow;
}

void CReportRecordView::ShowItemMenu(BOOL bShow)
{
	m_bShowItemMenu = bShow;
}

BOOL CReportRecordView::IsShowColumnMenu()
{
	return m_bShowColumnMenu;
}

BOOL CReportRecordView::IsShowItemMenu()
{
	return m_bShowItemMenu;
}

void CReportRecordView::SetImageList(UINT nBmpID)
{
	m_imgList.DeleteImageList();
	CBitmap bmp;

	if (XTPImageManager()->IsAlphaIconsImageListSupported())
	{
		bmp.Attach((HBITMAP)LoadImage(AfxGetInstanceHandle(), MAKEINTRESOURCE(nBmpID),
			IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE | LR_CREATEDIBSECTION));

		m_imgList.Add(&bmp, (CBitmap*)NULL);
	}
	else
	{
		bmp.LoadBitmap(nBmpID);
		m_imgList.Add(&bmp, RGB(255, 255, 255));
	}

	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.SetImageList(&m_imgList);
}

void CReportRecordView::SetImageList(CImageList* pImageList)
{
	m_imgList.DeleteImageList();
	m_imgList.Create(pImageList);

	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.SetImageList(&m_imgList);
}

void CReportRecordView::SetGroupsOrder(CXTPReportColumn* pColumn)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.GetColumns()->GetGroupsOrder()->Add(pColumn);
	wndReport.Populate();
}

CXTPReportColumnOrder* CReportRecordView::GetGroupsOrder()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.GetColumns()->GetGroupsOrder();
}

int CReportRecordView::AddRecord(CXTPReportRecord* pRecord, CXTPReportRecord* pParentRecord)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	if(pParentRecord == NULL)
	{
		wndReport.AddRecord(pRecord);
		return wndReport.GetRecords()->GetCount();
	}
	else
	{
		pParentRecord->GetChilds()->Add(pRecord);
		return pParentRecord->GetChilds()->GetCount();
	}
}

int CReportRecordView::AddRow(CXTPReportRow* pRow, CXTPReportRow* pParentRow)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	if(pParentRow == NULL)
	{
		return wndReport.GetRows()->Add(pRow);
	}
	else
	{
		pParentRow->AddChild(pRow);
		return pParentRow->GetChilds()->GetCount()-1;
	}
}

void CReportRecordView::AddChildRecords(CXTPReportRecord* pParentRecord, CXTPReportRecords* pRecords)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	if(pParentRecord != NULL)
	{
		CXTPReportRecords* pChildRecords = pParentRecord->GetChilds();
		for(int i=0; i,pRecords->GetCount(); i++)
		{
			pChildRecords->Add(pRecords->GetAt(i));
		}
	}
}

void CReportRecordView::AddChildRows(CXTPReportRow* pParentRow, CXTPReportRows* pRows)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	if(pParentRow != NULL)
	{
		for(int i=0; i,pRows->GetCount(); i++)
		{
			pParentRow->AddChild(pRows->GetAt(i));
		}
	}
}

void CReportRecordView::InsertRecord(int nIndex, CXTPReportRecord* pRecord, CXTPReportRecord* pParentRecord)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	if(pParentRecord == NULL)
	{
		wndReport.GetRecords()->InsertAt(nIndex, pRecord);
	}
	else
	{
		pParentRecord->GetChilds()->InsertAt(nIndex, pRecord);
	}
}

void CReportRecordView::InsertRow(int nIndex, CXTPReportRow* pRow, CXTPReportRow* pParentRow)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	if(pParentRow == NULL)
	{
		wndReport.GetRows()->InsertAt(nIndex, pRow);
	}
	else
	{
		pParentRow->GetChilds()->InsertAt(nIndex, pRow);
	}
}

BOOL CReportRecordView::RemoveRecord(CXTPReportRecord* pRecord, BOOL bAdjustLayout, BOOL bRemoveFromParent)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.RemoveRecordEx(pRecord, bAdjustLayout, bRemoveFromParent);
}

BOOL CReportRecordView::RemoveRow(CXTPReportRow* pRow, BOOL bAdjustLayout)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.RemoveRowEx(pRow, bAdjustLayout);
}

void CReportRecordView::UpdateRecord(CXTPReportRecord* pRecord)
{
	if(pRecord)
	{
		CXTPReportControl& wndReport = GetReportCtrl();
		CXTPADOData data;
		CString strTable = GetCurTable();
		CString code = ((CXTPReportRecordItemVariant*)pRecord->GetItem(0))->GetValue().bstrVal;
		GetRecord(data, strTable, code, _T("*"));
		_variant_t* vals = (_variant_t*)data.vals[1];
		for(int i=0; i<data.cols; i++)
		{
			_variant_t val = vals[i];
			((CXTPReportRecordItemVariant*)pRecord->GetItem(i))->SetValue(val);
		}

		wndReport.Populate();
	}
}

void CReportRecordView::UpdateRecord(CXTPReportRecord* pRecord, BOOL bUpdateChildren)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.UpdateRecord(pRecord, bUpdateChildren);
}

void CReportRecordView::UpdateRow(CXTPReportRow* pRow, BOOL bUpdateChildren)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.UpdateRecord(pRow->GetRecord(), bUpdateChildren);
}

CXTPReportColumn* CReportRecordView::AddColumn(CXTPReportColumn* pColumn)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.AddColumn(pColumn);
}

CXTPReportColumn* CReportRecordView::AddColumn(int nItemIndex, LPCTSTR strName, int nWidth, BOOL bAutoSize, int nIconID, BOOL bSortable, BOOL bVisible)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.AddColumn(new CXTPReportColumn(nItemIndex, strName, nWidth, bAutoSize, nIconID, bSortable, bVisible));
}

CXTPReportColumn* CReportRecordView::AddColumn(int nItemIndex, LPCTSTR strDisplayName, LPCTSTR strInternalName, int nWidth, BOOL bAutoSize, int nIconID, BOOL bSortable, BOOL bVisible)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	return wndReport.AddColumn(new CXTPReportColumn(nItemIndex, strDisplayName, strInternalName, nWidth, bAutoSize, nIconID, bSortable, bVisible));
}

CXTPReportColumn* CReportRecordView::SetColumn(int nItemIndex, LPCTSTR strName, int nWidth, BOOL bAutoSize, int nIconID, BOOL bSortable, BOOL bVisible)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumn* pColumn = wndReport.GetColumns()->GetAt(nItemIndex);
	pColumn = new CXTPReportColumn(nItemIndex, strName, nWidth, bAutoSize, nIconID, bSortable, bVisible);
	return pColumn;
}

CXTPReportColumn* CReportRecordView::SetColumn(int nItemIndex, LPCTSTR strDisplayName, LPCTSTR strInternalName, int nWidth, BOOL bAutoSize, int nIconID, BOOL bSortable, BOOL bVisible)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumn* pColumn = wndReport.GetColumns()->GetAt(nItemIndex);
	pColumn = new CXTPReportColumn(nItemIndex, strDisplayName, strInternalName, nWidth, bAutoSize, nIconID, bSortable, bVisible);
	return pColumn;
}

void CReportRecordView::SetColumnStyle(XTPReportColumnStyle columnStyle)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.GetPaintManager()->SetColumnStyle(columnStyle);
}

void CReportRecordView::SetToolTipStyle(XTPToolTipStyle tooltipStyle)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.GetToolTipContext()->SetStyle(tooltipStyle);
}

void CReportRecordView::SetRowGroup(int nRolBgen, int nRolEnd)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportRecords* pRecords = wndReport.GetRecords();
	if(nRolBgen < 0) nRolBgen = 0;
	if(nRolEnd > pRecords->GetCount()) nRolBgen = pRecords->GetCount()-1;
	CPropertyRecordGroup* pRecordGroup = (CPropertyRecordGroup*)pRecords->GetAt(nRolBgen);
	pRecordGroup->SetExpanded(TRUE);
	CXTPReportRecords* pChildRecords = pRecordGroup->GetChilds();
	for(int i=nRolBgen+1; i<nRolEnd; i++)
	{
		pChildRecords->Add(pRecords->GetAt(i));
	}

	for(int i=nRolBgen+1; i<nRolEnd; i++)
	{
		pRecords->RemoveAt(i);
	}
}

void CReportRecordView::SetPlusMinus(int nColumn, BOOL bPlusMinus, BOOL bExpand, int nNextVisualBlock)
{
	CXTPReportColumn* pColumn = GetColumns()->GetAt(nColumn);
	pColumn->SetPlusMinus(bPlusMinus);
	pColumn->SetExpanded(bExpand);
	pColumn->SetNextVisualBlock(nNextVisualBlock);
}

CXTPReportControl& CReportRecordView::ShowReportPerfomance(CXTPReportRecordItemVariant*& pItem, bool bHeader)
{
	if (m_pReportFrame)
	{
		m_pReportFrame->ActivateFrame();
	}
	else
	{
		CCreateContext contextT;
		// if no context specified, generate one from the
		// currently selected client if possible.
		contextT.m_pLastView       = NULL;
		contextT.m_pCurrentFrame   = NULL;
		contextT.m_pNewDocTemplate = NULL;
		contextT.m_pCurrentDoc     = NULL;
		contextT.m_pNewViewClass   = RUNTIME_CLASS(CPerfomanceView);


		m_pReportFrame = new CReportFrame(this);

		DWORD dwStyle = WS_OVERLAPPEDWINDOW|MFS_SYNCACTIVE;

		if (m_pReportFrame->Create(0, _T("Perfomance"), dwStyle, CRect(0, 0, 600, 400),
			this, 0, 0L, &contextT))
		{
			m_pReportFrame->InitialUpdateFrame(NULL, FALSE);

			m_pReportFrame->CenterWindow(this);
			m_pReportFrame->ShowWindow(SW_SHOW);
		}
	}

	CPerfomanceView* pView = (CPerfomanceView*)m_pReportFrame->GetActiveView();

	for(int i=0; i<m_itemCtrlDataList.size(); i++)
	{
		RCDICTRLDATA& itemCtrlData = m_itemCtrlDataList[i];

		if(pView != NULL && itemCtrlData.column == pItem->GetIndex() && itemCtrlData.ctrl == XTP_REPORT_ITEM_CTRL_LINK)
		{
			pView->SetRecordItem(pItem);
			CXTPReportDataManager* pDataManager = pView->m_wndReport.GetDataManager();
			if (itemCtrlData.rst != NULL)
				pDataManager->SetDataSource(itemCtrlData.rst);
			else if (!itemCtrlData.table.IsEmpty() && !itemCtrlData.sql.IsEmpty())
			{
				CString sql;
				COleVariant val = pItem->GetValue();
				switch (val.vt)
				{
				case VT_BSTR:
					sql.Format(_T("where %s = '%s'"),itemCtrlData.sql,val.bstrVal);
					break;
				case VT_I4:
					sql.Format(_T("where %s = %d"),itemCtrlData.sql,val.lVal);
					break;
				case VT_R8:
					sql.Format(_T("where %s = %.3f"),itemCtrlData.sql,val.dblVal);
					break;
				}
				
				if (itemCtrlData.fields.IsEmpty())
					pDataManager->SetDataSource(GetRecordset(itemCtrlData.table,_T(""),sql));
				else
					pDataManager->SetDataSource(GetRecordset(itemCtrlData.table,itemCtrlData.fields,sql));
			}
			else if (!itemCtrlData.table.IsEmpty() && itemCtrlData.sql.IsEmpty())
			{
				if (itemCtrlData.fields.IsEmpty())
					pDataManager->SetDataSource(GetRecordset(itemCtrlData.table));
				else
					pDataManager->SetDataSource(GetRecordset(itemCtrlData.table,itemCtrlData.fields));
			}
			pDataManager->DataBind();
		}
	}

	pView->ShowColumnMenu(FALSE);
	pView->ShowItemMenu(FALSE);
	return pView->m_wndReport;
}

CXTPReportControl& CReportRecordView::ShowReportPerfomance(int nColumn, bool bHeader)
{
	if (m_pReportFrame)
	{
		m_pReportFrame->ActivateFrame();
	}
	else
	{
		CCreateContext contextT;
		// if no context specified, generate one from the
		// currently selected client if possible.
		contextT.m_pLastView       = NULL;
		contextT.m_pCurrentFrame   = NULL;
		contextT.m_pNewDocTemplate = NULL;
		contextT.m_pCurrentDoc     = NULL;
		contextT.m_pNewViewClass   = RUNTIME_CLASS(CPerfomanceView);


		m_pReportFrame = new CReportFrame(this);

		DWORD dwStyle = WS_OVERLAPPEDWINDOW|MFS_SYNCACTIVE;

		if (m_pReportFrame->Create(0, _T("Perfomance"), dwStyle, CRect(0, 0, 600, 400),
			this, 0, 0L, &contextT))
		{
			m_pReportFrame->InitialUpdateFrame(NULL, FALSE);

			m_pReportFrame->CenterWindow(this);
			m_pReportFrame->ShowWindow(SW_SHOW);
		}
	}

	CPerfomanceView* pView = (CPerfomanceView*)m_pReportFrame->GetActiveView();

	for(int i=0; i<m_itemCtrlDataList.size(); i++)
	{
		RCDICTRLDATA& itemCtrlData = m_itemCtrlDataList[i];

		if(pView != NULL && itemCtrlData.column == nColumn && itemCtrlData.column == XTP_REPORT_ITEM_CTRL_LINK)
		{
			CXTPReportDataManager* pDataManager = pView->m_wndReport.GetDataManager();
			if (itemCtrlData.rst != NULL)
				pDataManager->SetDataSource(itemCtrlData.rst);
			else if (!itemCtrlData.table.IsEmpty() && !itemCtrlData.sql.IsEmpty())
			{
				CXTPReportControl& wndReport = GetReportCtrl();
				CXTPReportRecordItemVariant *pItem = (CXTPReportRecordItemVariant*)wndReport.GetFocusedRecordItem();
				if (pItem)
				{
					CString sql;
					COleVariant val = pItem->GetValue();
					switch (val.vt)
					{
					case VT_BSTR:
						sql.Format(_T("where %s = '%s'"),itemCtrlData.sql,val.bstrVal);
						break;
					case VT_I4:
						sql.Format(_T("where %s = %d"),itemCtrlData.sql,val.lVal);
						break;
					case VT_R8:
						sql.Format(_T("where %s = %.3f"),itemCtrlData.sql,val.dblVal);
						break;
					}

					if (itemCtrlData.fields.IsEmpty())
						pDataManager->SetDataSource(GetRecordset(itemCtrlData.table,_T(""),sql));
					else
						pDataManager->SetDataSource(GetRecordset(itemCtrlData.table,itemCtrlData.fields,sql));
				}
			}
			else if (!itemCtrlData.table.IsEmpty() && itemCtrlData.sql.IsEmpty())
			{
				if (itemCtrlData.fields.IsEmpty())
					pDataManager->SetDataSource(GetRecordset(itemCtrlData.table));
				else
					pDataManager->SetDataSource(GetRecordset(itemCtrlData.table,itemCtrlData.fields));
			}
			pDataManager->DataBind();
		}
	}

	pView->ShowColumnMenu(FALSE);
	pView->ShowItemMenu(FALSE);
	return pView->m_wndReport;
}

RCDICTRLDATALIST& CReportRecordView::GetRecordItemCtrlDataList()
{
	return m_itemCtrlDataList;
}

void CReportRecordView::AddRecordItemCtrlData(RCDICTRLDATA& itemCtrlData)
{
	m_itemCtrlDataList.push_back(itemCtrlData);
}

void CReportRecordView::DelRecordItemCtrlData(int index)
{
	m_itemCtrlDataList.erase(m_itemCtrlDataList.begin()+index);
}

void CReportRecordView::InitRecordItemControlDataList()
{
	m_itemCtrlDataList.clear();
	CXTPReportControl& wndReport = GetReportCtrl();
	for(int i=0; i<wndReport.GetColumns()->GetCount(); i++)
	{
		RCDICTRLDATA itemCtrlData;
		itemCtrlData.column = i;
		if(m_nType == XTP_REPORT_TABLE_TYPE_TP) itemCtrlData.editable = FALSE;
		m_itemCtrlDataList.push_back(itemCtrlData);
	}
}

void CReportRecordView::SetRecordItemControl()
{
	for(int i=0; i<m_itemCtrlDataList.size(); i++)
	{
		SetRecordItemControl(m_itemCtrlDataList[i]);
	}
}

void CReportRecordView::SetRecordItemControl(RCDICTRLDATA& itemCtrlData)
{
	m_itemCtrlDataList[itemCtrlData.column] = itemCtrlData;

	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns *pColumns = m_wndReport.GetColumns();
	if(!pColumns) return;
	CXTPReportColumn *pColumn = pColumns->GetAt(itemCtrlData.column);
	if(!pColumn) return;
	CXTPReportRecords* pRecords = wndReport.GetRecords();
	if(!pRecords) return;
	int iRows = pRecords->GetCount();
	for(int i=0; i<iRows; i++)
	{
		CXTPReportRecord* pRecord = pRecords->GetAt(i);
		if(!pRecord) return;
		pRecord->SetPreviewItem(new CXTPReportRecordItemPreview(_T("this is a test button and hyperlink record!")));
		CXTPReportRecordItem* pItem = pRecord->GetItem(itemCtrlData.column);
		if(!pItem) return;
		int nSize = pItem->GetCaption().GetLength();
		pItem->SetItemData((DWORD_PTR)(itemCtrlData.ctrl));
		pItem->SetEditable(itemCtrlData.editable);
		switch(itemCtrlData.ctrl)
		{
		case XTP_REPORT_ITEM_CTRL_LINK:
			pItem->AddHyperlink(new CXTPReportHyperlink(0, nSize));
			break;
		case XTP_REPORT_ITEM_CTRL_LINK|XTP_REPORT_ITEM_CTRL_FORM:
			{
				pItem->AddHyperlink(new CXTPReportHyperlink(0, nSize));
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 4);
				pButton->SetIconIndex(PBS_PRESSED, 5);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BUTTON:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 6);
				pButton->SetIconIndex(PBS_PRESSED, 7);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BOLD|XTP_REPORT_ITEM_CTRL_ALIGN|XTP_REPORT_ITEM_CTRL_COLOR:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlLeft);
				pButton->SetIconIndex(PBS_NORMAL, 8);
				pButton->SetIconIndex(PBS_PRESSED, 9);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 13);
				pButton->SetIconIndex(PBS_PRESSED, 14);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(0, 11);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BOLD|XTP_REPORT_ITEM_CTRL_ALIGN:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlLeft);
				pButton->SetIconIndex(PBS_NORMAL, 8);
				pButton->SetIconIndex(PBS_PRESSED, 9);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 13);
				pButton->SetIconIndex(PBS_PRESSED, 14);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BOLD|XTP_REPORT_ITEM_CTRL_COLOR:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlLeft);
				pButton->SetIconIndex(PBS_NORMAL, 8);
				pButton->SetIconIndex(PBS_PRESSED, 9);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 13);
				pButton->SetIconIndex(PBS_PRESSED, 14);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(0, 11);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_COLOR:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 13);
				pButton->SetIconIndex(PBS_PRESSED, 14);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_ALIGN:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlLeft);
				pButton->SetIconIndex(PBS_NORMAL, 8);
				pButton->SetIconIndex(PBS_PRESSED, 9);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BOLD:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(0, 11);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_FORM:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 4);
				pButton->SetIconIndex(PBS_PRESSED, 5);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_CHECKBOX:
			{
				pItem->HasCheckbox(TRUE);
				BOOL bCheck= ((CXTPReportRecordItemVariant*)pItem)->GetValue().boolVal ? TRUE:FALSE;
				pItem->SetChecked(bCheck);
				pItem->SetCaption(bCheck ? _T("~{JG~}"):_T("~{7q~}"));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_COMBOBOX:
			{
				CString* ptr = (CString*)itemCtrlData.ptr;
				if(ptr != NULL)
				{
					CStringArray strs;
					CreateArray(strs, *ptr);
					CXTPReportRecordItemEditOptions* pEditOptions = pColumn->GetEditOptions();
					if(pEditOptions != NULL)
					{
						for(int j=0; j<strs.GetCount(); j++)
							pEditOptions->AddConstraint(strs[j]);
						pEditOptions->m_bConstraintEdit = FALSE;
						pEditOptions->m_bAllowEdit = FALSE;
						pEditOptions->AddComboButton(TRUE);
					}
				}
			}
			return;
		case XTP_REPORT_ITEM_CTRL_EXPAND:
			{
				CString* ptr = (CString*)itemCtrlData.ptr;
				if(ptr != NULL)
				{
					CStringArray strs;
					CreateArray(strs, *ptr);
					CXTPReportRecordItemEditOptions* pEditOptions = pColumn->GetEditOptions();
					if(pEditOptions != NULL)
					{
						for(int j=0; j<strs.GetCount(); j++)
							pEditOptions->AddConstraint(strs[j]);
						pEditOptions->m_bConstraintEdit = FALSE;
						pEditOptions->m_bAllowEdit = FALSE;
						pEditOptions->AddExpandButton(TRUE);
					}
				}
			}
			return;
		case XTP_REPORT_ITEM_CTRL_SPIN:
			{
				CString* ptr = (CString*)itemCtrlData.ptr;
				if(ptr != NULL)
				{
					CStringArray strs;
					CreateArray(strs, *ptr);
					CXTPReportRecordItemEditOptions* pEditOptions = pColumn->GetEditOptions();
					if(pEditOptions != NULL)
					{
						for(int j=0; j<strs.GetCount(); j++)
							pEditOptions->AddConstraint(strs[j]);
						pEditOptions->m_bConstraintEdit = FALSE;
						pEditOptions->m_bAllowEdit = FALSE;
						pEditOptions->AddSpinButton(TRUE);
					}
				}
			}
			return;
		}
	}
}

void CReportRecordView::SetRecordItemControl(RCDICTRLDATALIST& vecItemData)
{
	for(int i=0; i<vecItemData.size(); i++)
	{
		m_itemCtrlDataList[vecItemData[i].column] = vecItemData[i];
		SetRecordItemControl(vecItemData[i]);
	}
}

void CReportRecordView::SetRecordItemControl(int column, DWORD ctrl, CString table, CString fields, CString sql, XTPREPORTMSADODB::_RecordsetPtr rst, BOOL visible, BOOL header, BOOL editable, DWORD alignment, DWORD_PTR ptr)
{
	m_itemCtrlDataList[column] = RCDICTRLDATA(column,ctrl,table,fields,sql,rst,visible,header,editable,alignment,ptr);
	SetRecordItemControl(m_itemCtrlDataList[column]);
}

void CReportRecordView::SetHeaderRecordItemControl()
{
	for(int i=0; i<m_itemCtrlDataList.size(); i++)
	{
		SetHeaderRecordItemControl(m_itemCtrlDataList[i]);
	}
}

void CReportRecordView::SetHeaderRecordItemControl(RCDICTRLDATA& itemCtrlData)
{
	m_itemCtrlDataList[itemCtrlData.column] = itemCtrlData;

	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns *pColumns = m_wndReport.GetColumns();
	if(!pColumns) return;
	CXTPReportColumn *pColumn = pColumns->GetAt(itemCtrlData.column);
	if(!pColumn) return;
	CXTPReportRecords* pRecords = wndReport.GetHeaderRecords();
	if(!pRecords) return;
	int iRows = pRecords->GetCount();
	for(int i=0; i<iRows; i++)
	{
		CXTPReportRecord* pRecord = pRecords->GetAt(i);
		if(!pRecord) return;
		pRecord->SetPreviewItem(new CXTPReportRecordItemPreview(_T("this is a test button and hyperlink record!")));
		CXTPReportRecordItem* pItem = pRecord->GetItem(itemCtrlData.column);
		if(!pItem) return;
		int nSize = pItem->GetCaption().GetLength();
		pItem->SetItemData((DWORD_PTR)(itemCtrlData.ctrl));
		pItem->SetEditable(itemCtrlData.editable);
		switch(itemCtrlData.ctrl)
		{
		case XTP_REPORT_ITEM_CTRL_LINK:
			pItem->AddHyperlink(new CXTPReportHyperlink(0, nSize));
			break;
		case XTP_REPORT_ITEM_CTRL_LINK|XTP_REPORT_ITEM_CTRL_FORM:
			{
				pItem->AddHyperlink(new CXTPReportHyperlink(0, nSize));
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 4);
				pButton->SetIconIndex(PBS_PRESSED, 5);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BUTTON:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 6);
				pButton->SetIconIndex(PBS_PRESSED, 7);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BOLD|XTP_REPORT_ITEM_CTRL_ALIGN|XTP_REPORT_ITEM_CTRL_COLOR:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlLeft);
				pButton->SetIconIndex(PBS_NORMAL, 8);
				pButton->SetIconIndex(PBS_PRESSED, 9);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 13);
				pButton->SetIconIndex(PBS_PRESSED, 14);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(0, 11);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BOLD|XTP_REPORT_ITEM_CTRL_ALIGN:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlLeft);
				pButton->SetIconIndex(PBS_NORMAL, 8);
				pButton->SetIconIndex(PBS_PRESSED, 9);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 13);
				pButton->SetIconIndex(PBS_PRESSED, 14);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BOLD|XTP_REPORT_ITEM_CTRL_COLOR:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlLeft);
				pButton->SetIconIndex(PBS_NORMAL, 8);
				pButton->SetIconIndex(PBS_PRESSED, 9);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 13);
				pButton->SetIconIndex(PBS_PRESSED, 14);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(0, 11);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_COLOR:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 13);
				pButton->SetIconIndex(PBS_PRESSED, 14);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_ALIGN:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlLeft);
				pButton->SetIconIndex(PBS_NORMAL, 8);
				pButton->SetIconIndex(PBS_PRESSED, 9);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BOLD:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(0, 11);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_FORM:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 4);
				pButton->SetIconIndex(PBS_PRESSED, 5);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_CHECKBOX:
			{
				pItem->HasCheckbox(TRUE);
				BOOL bCheck= ((CXTPReportRecordItemVariant*)pItem)->GetValue().boolVal ? TRUE:FALSE;
				pItem->SetChecked(bCheck);
				pItem->SetCaption(bCheck ? _T("~{JG~}"):_T("~{7q~}"));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_COMBOBOX:
			{
				CString* ptr = (CString*)itemCtrlData.ptr;
				if(ptr != NULL)
				{
					CStringArray strs;
					CreateArray(strs, *ptr);
					CXTPReportRecordItemEditOptions* pEditOptions = pColumn->GetEditOptions();
					if(pEditOptions != NULL)
					{
						for(int j=0; j<strs.GetCount(); j++)
							pEditOptions->AddConstraint(strs[j]);
						pEditOptions->m_bConstraintEdit = FALSE;
						pEditOptions->m_bAllowEdit = FALSE;
						pEditOptions->AddComboButton(TRUE);
					}
				}
			}
			return;
		case XTP_REPORT_ITEM_CTRL_EXPAND:
			{
				CString* ptr = (CString*)itemCtrlData.ptr;
				if(ptr != NULL)
				{
					CStringArray strs;
					CreateArray(strs, *ptr);
					CXTPReportRecordItemEditOptions* pEditOptions = pColumn->GetEditOptions();
					if(pEditOptions != NULL)
					{
						for(int j=0; j<strs.GetCount(); j++)
							pEditOptions->AddConstraint(strs[j]);
						pEditOptions->m_bConstraintEdit = FALSE;
						pEditOptions->m_bAllowEdit = FALSE;
						pEditOptions->AddExpandButton(TRUE);
					}
				}
			}
			return;
		case XTP_REPORT_ITEM_CTRL_SPIN:
			{
				CString* ptr = (CString*)itemCtrlData.ptr;
				if(ptr != NULL)
				{
					CStringArray strs;
					CreateArray(strs, *ptr);
					CXTPReportRecordItemEditOptions* pEditOptions = pColumn->GetEditOptions();
					if(pEditOptions != NULL)
					{
						for(int j=0; j<strs.GetCount(); j++)
							pEditOptions->AddConstraint(strs[j]);
						pEditOptions->m_bConstraintEdit = FALSE;
						pEditOptions->m_bAllowEdit = FALSE;
						pEditOptions->AddSpinButton(TRUE);
					}
				}
			}
			return;
		}
	}
}

void CReportRecordView::SetHeaderRecordItemControl(RCDICTRLDATALIST& vecItemData)
{
	for(int i=0; i<vecItemData.size(); i++)
	{
		m_itemCtrlDataList[vecItemData[i].column] = vecItemData[i];
		SetHeaderRecordItemControl(vecItemData[i]);
	}
}

void CReportRecordView::SetHeaderRecordItemControl(int column, DWORD ctrl, CString table, CString fields, CString sql, XTPREPORTMSADODB::_RecordsetPtr rst, BOOL visible, BOOL header, BOOL editable, DWORD alignment, DWORD_PTR ptr)
{
	m_itemCtrlDataList[column] = RCDICTRLDATA(column,ctrl,table,fields,sql,rst,visible,header,editable,alignment,ptr);
	SetHeaderRecordItemControl(m_itemCtrlDataList[column]);
}

void CReportRecordView::SetFooterRecordItemControl()
{
	for(int i=0; i<m_itemCtrlDataList.size(); i++)
	{
		SetFooterRecordItemControl(m_itemCtrlDataList[i]);
	}
}

void CReportRecordView::SetFooterRecordItemControl(RCDICTRLDATA& itemCtrlData)
{
	m_itemCtrlDataList[itemCtrlData.column] = itemCtrlData;

	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns *pColumns = m_wndReport.GetColumns();
	if(!pColumns) return;
	CXTPReportColumn *pColumn = pColumns->GetAt(itemCtrlData.column);
	if(!pColumn) return;
	CXTPReportRecords* pRecords = wndReport.GetFooterRecords();
	if(!pRecords) return;
	int iRows = pRecords->GetCount();
	for(int i=0; i<iRows; i++)
	{
		CXTPReportRecord* pRecord = pRecords->GetAt(i);
		if(!pRecord) return;
		pRecord->SetPreviewItem(new CXTPReportRecordItemPreview(_T("this is a test button and hyperlink record!")));
		CXTPReportRecordItem* pItem = pRecord->GetItem(itemCtrlData.column);
		if(!pItem) return;
		int nSize = pItem->GetCaption().GetLength();
		pItem->SetItemData((DWORD_PTR)(itemCtrlData.ctrl));
		pItem->SetEditable(itemCtrlData.editable);
		switch(itemCtrlData.ctrl)
		{
		case XTP_REPORT_ITEM_CTRL_LINK:
			pItem->AddHyperlink(new CXTPReportHyperlink(0, nSize));
			break;
		case XTP_REPORT_ITEM_CTRL_LINK|XTP_REPORT_ITEM_CTRL_FORM:
			{
				pItem->AddHyperlink(new CXTPReportHyperlink(0, nSize));
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 4);
				pButton->SetIconIndex(PBS_PRESSED, 5);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BUTTON:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 6);
				pButton->SetIconIndex(PBS_PRESSED, 7);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BOLD|XTP_REPORT_ITEM_CTRL_ALIGN|XTP_REPORT_ITEM_CTRL_COLOR:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlLeft);
				pButton->SetIconIndex(PBS_NORMAL, 8);
				pButton->SetIconIndex(PBS_PRESSED, 9);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 13);
				pButton->SetIconIndex(PBS_PRESSED, 14);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(0, 11);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BOLD|XTP_REPORT_ITEM_CTRL_ALIGN:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlLeft);
				pButton->SetIconIndex(PBS_NORMAL, 8);
				pButton->SetIconIndex(PBS_PRESSED, 9);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 13);
				pButton->SetIconIndex(PBS_PRESSED, 14);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BOLD|XTP_REPORT_ITEM_CTRL_COLOR:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlLeft);
				pButton->SetIconIndex(PBS_NORMAL, 8);
				pButton->SetIconIndex(PBS_PRESSED, 9);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 13);
				pButton->SetIconIndex(PBS_PRESSED, 14);
				pButton->SetSize(CSize(22, 0));
				pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(0, 11);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_COLOR:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 13);
				pButton->SetIconIndex(PBS_PRESSED, 14);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_ALIGN:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlLeft);
				pButton->SetIconIndex(PBS_NORMAL, 8);
				pButton->SetIconIndex(PBS_PRESSED, 9);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_BOLD:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(0, 11);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_FORM:
			{
				CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
				if(!pButton) break;
				pButton->SetAlignment(xtpItemControlRight);
				pButton->SetIconIndex(PBS_NORMAL, 4);
				pButton->SetIconIndex(PBS_PRESSED, 5);
				pButton->SetSize(CSize(22, 0));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_CHECKBOX:
			{
				pItem->HasCheckbox(TRUE);
				BOOL bCheck= ((CXTPReportRecordItemVariant*)pItem)->GetValue().boolVal ? TRUE:FALSE;
				pItem->SetChecked(bCheck);
				pItem->SetCaption(bCheck ? _T("~{JG~}"):_T("~{7q~}"));
			}
			break;
		case XTP_REPORT_ITEM_CTRL_COMBOBOX:
			{
				CString* ptr = (CString*)itemCtrlData.ptr;
				if(ptr != NULL)
				{
					CStringArray strs;
					CreateArray(strs, *ptr);
					CXTPReportRecordItemEditOptions* pEditOptions = pColumn->GetEditOptions();
					if(pEditOptions != NULL)
					{
						for(int j=0; j<strs.GetCount(); j++)
							pEditOptions->AddConstraint(strs[j]);
						pEditOptions->m_bConstraintEdit = FALSE;
						pEditOptions->m_bAllowEdit = FALSE;
						pEditOptions->AddComboButton(TRUE);
					}
				}
			}
			return;
		case XTP_REPORT_ITEM_CTRL_EXPAND:
			{
				CString* ptr = (CString*)itemCtrlData.ptr;
				if(ptr != NULL)
				{
					CStringArray strs;
					CreateArray(strs, *ptr);
					CXTPReportRecordItemEditOptions* pEditOptions = pColumn->GetEditOptions();
					if(pEditOptions != NULL)
					{
						for(int j=0; j<strs.GetCount(); j++)
							pEditOptions->AddConstraint(strs[j]);
						pEditOptions->m_bConstraintEdit = FALSE;
						pEditOptions->m_bAllowEdit = FALSE;
						pEditOptions->AddExpandButton(TRUE);
					}
				}
			}
			return;
		case XTP_REPORT_ITEM_CTRL_SPIN:
			{
				CString* ptr = (CString*)itemCtrlData.ptr;
				if(ptr != NULL)
				{
					CStringArray strs;
					CreateArray(strs, *ptr);
					CXTPReportRecordItemEditOptions* pEditOptions = pColumn->GetEditOptions();
					if(pEditOptions != NULL)
					{
						for(int j=0; j<strs.GetCount(); j++)
							pEditOptions->AddConstraint(strs[j]);
						pEditOptions->m_bConstraintEdit = FALSE;
						pEditOptions->m_bAllowEdit = FALSE;
						pEditOptions->AddSpinButton(TRUE);
					}
				}
			}
			return;
		}
	}
}

void CReportRecordView::SetFooterRecordItemControl(RCDICTRLDATALIST& vecItemData)
{
	for(int i=0; i<vecItemData.size(); i++)
	{
		m_itemCtrlDataList[vecItemData[i].column] = vecItemData[i];
		SetFooterRecordItemControl(vecItemData[i]);
	}
}

void CReportRecordView::SetFooterRecordItemControl(int column, DWORD ctrl, CString table, CString fields, CString sql, XTPREPORTMSADODB::_RecordsetPtr rst, BOOL visible, BOOL header, BOOL editable, DWORD alignment, DWORD_PTR ptr)
{
	m_itemCtrlDataList[column] = RCDICTRLDATA(column,ctrl,table,fields,sql,rst,visible,header,editable,alignment,ptr);
	SetFooterRecordItemControl(m_itemCtrlDataList[column]);
}

void CReportRecordView::SetRecordItemEditable()
{
	if(!m_itemCtrlDataList.size()) return;

	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportRecords* pRecords = wndReport.GetRecords();

	if(!pRecords) return;
	int iRows = pRecords->GetCount();
	for(int i=0; i<iRows; i++)
	{
		CXTPReportRecord* pRecord = pRecords->GetAt(i);
		if(!pRecord) return;
		for(int j=0; j<m_itemCtrlDataList.size(); j++)
		{
			CXTPReportRecordItem* pItem = pRecord->GetItem(m_itemCtrlDataList[j].column);
			if(!pItem) return;
			pItem->SetEditable(m_itemCtrlDataList[j].editable);
		}
	}
}

void CReportRecordView::SetRecordItemEditable(int nColumn, BOOL bEditable)
{
	m_itemCtrlDataList[nColumn].editable = bEditable;
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportRecords* pRecords = wndReport.GetRecords();

	if(!pRecords) return;
	int iRows = pRecords->GetCount();
	for(int i=0; i<iRows; i++)
	{
		CXTPReportRecord* pRecord = pRecords->GetAt(i);
		if(!pRecord) return;
		CXTPReportRecordItem* pItem = pRecord->GetItem(nColumn);
		if(!pItem) return;
		pItem->SetEditable(bEditable);
	}
}

void CReportRecordView::SetRecordItemEditable(xtp_vector<int> nColumns, BOOL bEditable)
{
	for(int i=0; i<nColumns.size(); i++)
		m_itemCtrlDataList[nColumns[i]].editable = bEditable;

	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportRecords* pRecords = wndReport.GetRecords();
	if(!pRecords) return;
	int iRows = pRecords->GetCount();
	for(int i=0; i<iRows; i++)
	{
		CXTPReportRecord* pRecord = pRecords->GetAt(i);
		if(!pRecord) return;
		for(int j=0; j<nColumns.size(); j++)
		{
			CXTPReportRecordItem* pItem = pRecord->GetItem(nColumns[j]);
			if(!pItem) return;
			pItem->SetEditable(bEditable);
		}
	}
}

void CReportRecordView::SetRecordItemColor(int nColumn, COLORREF clrText, COLORREF clrBackground)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportRecords* pRecords = wndReport.GetRecords();
	if(pRecords != NULL)
	{
		int iRows = pRecords->GetCount();
		for(int i=0; i<iRows; i++)
		{
			CXTPReportRecord* pRecord = pRecords->GetAt(i);
			if(pRecord != NULL)
			{
				if(nColumn == -1)
				{
					for(int j=0; j<pRecord->GetItemCount();j++)
					{
						CXTPReportRecordItem* pItem = pRecord->GetItem(j);
						if(pItem != NULL)
						{
							pItem->SetTextColor(clrText);
							pItem->SetBackgroundColor(clrBackground);
						}
					}
				}
				else
				{
					CXTPReportRecordItem* pItem = pRecord->GetItem(nColumn);
					if(pItem != NULL)
					{
						pItem->SetTextColor(clrText);
						pItem->SetBackgroundColor(clrBackground);
					}
				}
			}
		}
	}
}

void CReportRecordView::SetRecordItemColor(xtp_vector<int> vecColumn, COLORREF clrText, COLORREF clrBackground)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportRecords* pRecords = wndReport.GetRecords();
	if(pRecords != NULL)
	{
		int iRows = pRecords->GetCount();
		for(int i=0; i<iRows; i++)
		{
			CXTPReportRecord* pRecord = pRecords->GetAt(i);
			if(pRecord != NULL)
			{
				for(int j=0; i<vecColumn.size(); j++)
				{
					CXTPReportRecordItem* pItem = pRecord->GetItem(vecColumn[j]);
					if(pItem != NULL)
					{
						pItem->SetTextColor(clrText);
						pItem->SetBackgroundColor(clrBackground);
					}
				}
			}
		}
	}
}

void CReportRecordView::SetPreviewRecord(int nRow, CString strPreview)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportRecords* pRecords = wndReport.GetRecords();
	if(!pRecords) return;
	if(nRow == -1)
	{
		int iRows = pRecords->GetCount();
		for(int i=0; i<iRows; i++)
		{
			CXTPReportRecord* pRecord = pRecords->GetAt(i);
			if(pRecord) return;
			pRecord->SetPreviewItem(new CXTPReportRecordItemPreview(strPreview));
		}
	}
	else
	{
		CXTPReportRecord* pRecord = pRecords->GetAt(nRow);
		if(!pRecord) return;
		pRecord->SetPreviewItem(new CXTPReportRecordItemPreview(strPreview));
	}
}

void CReportRecordView::SetColumnEditable(int nColumn, BOOL bEditable)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns* pColumns = wndReport.GetColumns();
	if(!pColumns) return;

	CXTPReportColumn* pColumn = pColumns->GetAt(nColumn);
	if(pColumn) pColumn->SetEditable(bEditable);
}

void CReportRecordView::SetColumnEditable(xtp_vector<int> nColumns, BOOL bEditable)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns* pColumns = wndReport.GetColumns();
	if(!pColumns) return;

	for(int i=0; i<nColumns.size(); i++)
	{
		CXTPReportColumn* pColumn = pColumns->GetAt(nColumns[i]);
		if(pColumn) pColumn->SetEditable(bEditable);
	}
}

void CReportRecordView::SetColumnVisible(int nColumn, BOOL bVisible)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns* pColumns = wndReport.GetColumns();
	if(!pColumns) return;

	CXTPReportColumn* pColumn = pColumns->GetAt(nColumn);
	if(pColumn) pColumn->SetVisible(bVisible);
}

void CReportRecordView::SetColumnVisible(xtp_vector<int> nColumns, BOOL bVisible)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns* pColumns = wndReport.GetColumns();
	if(!pColumns) return;

	for(int i=0; i<nColumns.size(); i++)
	{
		CXTPReportColumn* pColumn = pColumns->GetAt(nColumns[i]);
		if(pColumn) pColumn->SetVisible(bVisible);
	}
}

void CReportRecordView::SetColumnSortable(int nColumn, BOOL bSortable)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns* pColumns = wndReport.GetColumns();
	if(!pColumns) return;

	CXTPReportColumn* pColumn = pColumns->GetAt(nColumn);
	if(pColumn) pColumn->SetSortable(bSortable);
}

void CReportRecordView::SetColumnSortable(xtp_vector<int> nColumns, BOOL bSortable)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns* pColumns = wndReport.GetColumns();
	if(!pColumns) return;

	for(int i=0; i<nColumns.size(); i++)
	{
		CXTPReportColumn* pColumn = pColumns->GetAt(nColumns[i]);
		if(pColumn) pColumn->SetSortable(bSortable);
	}
}

void CReportRecordView::SetColumnGroupable(int nColumn, BOOL bGroupable)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns* pColumns = wndReport.GetColumns();
	if(!pColumns) return;

	CXTPReportColumn* pColumn = pColumns->GetAt(nColumn);
	if(pColumn) pColumn->SetGroupable(bGroupable);
}

void CReportRecordView::SetColumnGroupable(xtp_vector<int> nColumns, BOOL bGroupable)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns* pColumns = wndReport.GetColumns();
	if(!pColumns) return;

	for(int i=0; i<nColumns.size(); i++)
	{
		CXTPReportColumn* pColumn = pColumns->GetAt(nColumns[i]);
		if(pColumn) pColumn->SetGroupable(bGroupable);
	}
}

void CReportRecordView::SetColumnFixed(int nColumn, BOOL bFixed)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns* pColumns = wndReport.GetColumns();
	if(!pColumns) return;

	CXTPReportColumn* pColumn = pColumns->GetAt(nColumn);
	if(pColumn) pColumn->SetFixed(bFixed);
}

void CReportRecordView::SetColumnFixed(xtp_vector<int> nColumns, BOOL bFixed)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns* pColumns = wndReport.GetColumns();
	if(!pColumns) return;

	for(int i=0; i<nColumns.size(); i++)
	{
		CXTPReportColumn* pColumn = pColumns->GetAt(nColumns[i]);
		if(pColumn) pColumn->SetFixed(bFixed);
	}
}

void CReportRecordView::SetColumnFrozen(int nColumn, BOOL bFrozen)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns* pColumns = wndReport.GetColumns();
	if(!pColumns) return;

	CXTPReportColumn* pColumn = pColumns->GetAt(nColumn);
	if(pColumn) pColumn->SetFrozen(bFrozen);
}

void CReportRecordView::SetColumnFrozen(xtp_vector<int> nColumns, BOOL bFrozen)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	CXTPReportColumns* pColumns = wndReport.GetColumns();
	if(!pColumns) return;

	for(int i=0; i<nColumns.size(); i++)
	{
		CXTPReportColumn* pColumn = pColumns->GetAt(nColumns[i]);
		if(pColumn) pColumn->SetFrozen(bFrozen);
	}
}

void CReportRecordView::OnReportShowGroupBox()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	ShowGroupBox(!wndReport.IsGroupByVisible());
}

void CReportRecordView::OnUpdateReportShowGroupBox(CCmdUI* pCmdUI)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.IsGroupByVisible());
}

void CReportRecordView::OnReportEnablePreview()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.EnablePreviewMode(!wndReport.IsPreviewMode());
	wndReport.Populate();
}

void CReportRecordView::OnUpdateReportEnablePreview(CCmdUI* pCmdUI)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.IsPreviewMode());
}

void CReportRecordView::OnReportMultipleselection()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	AllowMultipleSelection(!wndReport.IsMultipleSelection());
}

void CReportRecordView::OnUpdateReportMultipleselection(CCmdUI* pCmdUI)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.IsMultipleSelection());
}

void CReportRecordView::OnReportRighttoleft()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	wndReport.SetLayoutRTL(wndReport.GetExStyle() & WS_EX_LAYOUTRTL ? FALSE : TRUE);
}

void CReportRecordView::OnUpdateReportRighttoleft(CCmdUI* pCmdUI)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	if (!XTPSystemVersion()->IsLayoutRTLSupported())
	{
		pCmdUI->Enable(FALSE);
	}
	else
	{
		pCmdUI->SetCheck(wndReport.GetExStyle() & WS_EX_LAYOUTRTL ? TRUE : FALSE);
	}	
}

void CReportRecordView::OnReportMarkup()
{
	CXTPReportControl& wndReport = GetReportCtrl();
	BOOL bEnabled = wndReport.GetMarkupContext() != NULL;

	bEnabled = !bEnabled; // enable ALL

	wndReport.EnableMarkup(bEnabled);

	if (wndReport.GetMarkupContext())
	{
		wndReport.GetColumns()->GetAt(0)->SetCaption(cstrMarkupShort);
		wndReport.GetRecords()->GetAt(9)->GetItem(0)->SetCaption(cstrMarkupShort);
		wndReport.GetRecords()->GetAt(9)->GetItemPreview()->SetCaption(cstrMarkupLong);		
		wndReport.RedrawControl();
	}
}

void CReportRecordView::OnUpdateReportMarkup(CCmdUI* pCmdUI)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.GetMarkupContext() != NULL);
}

void CReportRecordView::OnReportWatermark()
{
	CXTPReportControl &wndReport = GetReportCtrl();

	m_bWatermark = !m_bWatermark;

	if (m_bWatermark)
	{
		CBitmap bmpWatermark;

		if (bmpWatermark.LoadBitmap(IDB_WATERMARK))
		{
			wndReport.SetWatermarkBitmap(bmpWatermark, 64);
			wndReport.SetWatermarkAlignment(xtpReportWatermarkCenter | xtpReportWatermarkVCenter);
			m_pPaintManager->m_bPrintWatermark = TRUE;
		}
	}
	else
	{
		wndReport.SetWatermarkBitmap(HBITMAP(NULL), 0);
		m_pPaintManager->m_bPrintWatermark = FALSE;
	}

	wndReport.RedrawControl();
}

void CReportRecordView::OnUpdateReportWatermark(CCmdUI *pCmdUI)
{
	pCmdUI->Enable(TRUE);
	pCmdUI->SetCheck(m_bWatermark ? 1 : 0);
}

void CReportRecordView::OnReportFreezecolumns0()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	wndReport.SetFreezeColumnsCount(0);
	wndReport.RedrawControl();
}

void CReportRecordView::OnUpdateReportFreezecolumns0(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.GetFreezeColumnsCount() == 0 ? 1 : 0);
}

void CReportRecordView::OnReportFreezecolumns1()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	wndReport.SetFreezeColumnsCount(1);	
	wndReport.RedrawControl();
}

void CReportRecordView::OnUpdateReportFreezecolumns1(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.GetFreezeColumnsCount() == 1 ? 1 : 0);	
}

void CReportRecordView::OnReportFreezecolumns2()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	wndReport.SetFreezeColumnsCount(2);
	wndReport.RedrawControl();
}

void CReportRecordView::OnUpdateReportFreezecolumns2(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.GetFreezeColumnsCount() == 2 ? 1 : 0);	
}

void CReportRecordView::OnReportFreezecolumns3()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	wndReport.SetFreezeColumnsCount(3);
	wndReport.RedrawControl();
}

void CReportRecordView::OnUpdateReportFreezecolumns3(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.GetFreezeColumnsCount() == 3 ? 1 : 0);
}

void CReportRecordView::OnReportFreezecolumnsDividerNone()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	int nStyle = m_pPaintManager->GetFreezeColsDividerStyle();
	nStyle = (nStyle & (xtpReportFreezeColsDividerHeader));

	m_pPaintManager->SetFreezeColsDividerStyle(nStyle);

	wndReport.RedrawControl();
}

void CReportRecordView::OnUpdateReportFreezecolumnsDividerNone(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	int nStyle = m_pPaintManager->GetFreezeColsDividerStyle();
	pCmdUI->SetCheck((nStyle & ~~xtpReportFreezeColsDividerHeader) == 0);
}

void CReportRecordView::OnReportFreezecolumnsDividerThin()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	int nStyle = m_pPaintManager->GetFreezeColsDividerStyle();
	nStyle &= ~~(xtpReportFreezeColsDividerBold | xtpReportFreezeColsDividerThin);
	nStyle |= xtpReportFreezeColsDividerThin;

	m_pPaintManager->SetFreezeColsDividerStyle(nStyle);

	wndReport.RedrawControl();	
}

void CReportRecordView::OnUpdateReportFreezecolumnsDividerThin(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	int nStyle = m_pPaintManager->GetFreezeColsDividerStyle();
	pCmdUI->SetCheck((nStyle & xtpReportFreezeColsDividerThin) != 0);
}

void CReportRecordView::OnReportFreezecolumnsDividerBold()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	int nStyle = m_pPaintManager->GetFreezeColsDividerStyle();
	nStyle &= ~~(xtpReportFreezeColsDividerBold | xtpReportFreezeColsDividerThin);
	nStyle |= xtpReportFreezeColsDividerBold;

	m_pPaintManager->SetFreezeColsDividerStyle(nStyle);

	wndReport.RedrawControl();	
}

void CReportRecordView::OnUpdateReportFreezecolumnsDividerBold(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	int nStyle = m_pPaintManager->GetFreezeColsDividerStyle();
	pCmdUI->SetCheck((nStyle & xtpReportFreezeColsDividerBold) != 0);
}

void CReportRecordView::OnReportFreezecolumnsDividerShade()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	int nStyle = m_pPaintManager->GetFreezeColsDividerStyle();
	nStyle ^= xtpReportFreezeColsDividerShade;

	m_pPaintManager->SetFreezeColsDividerStyle(nStyle);

	wndReport.RedrawControl();	
}

void CReportRecordView::OnUpdateReportFreezecolumnsDividerShade(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	int nStyle = m_pPaintManager->GetFreezeColsDividerStyle();
	pCmdUI->SetCheck((nStyle & xtpReportFreezeColsDividerShade) != 0);
}

void CReportRecordView::OnReportFreezecolumnsDividerHeader()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	int nStyle = m_pPaintManager->GetFreezeColsDividerStyle();
	nStyle ^= xtpReportFreezeColsDividerHeader;

	m_pPaintManager->SetFreezeColsDividerStyle(nStyle);

	wndReport.RedrawControl();		
}

void CReportRecordView::OnUpdateReportFreezecolumnsDividerHeader(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	int nStyle = m_pPaintManager->GetFreezeColsDividerStyle();
	pCmdUI->SetCheck((nStyle & xtpReportFreezeColsDividerHeader) != 0);
}

void CReportRecordView::OnReportAllowedit()
{
	m_bAllowEdit = !m_bAllowEdit;
	AllowEdit(m_bAllowEdit);
}

void CReportRecordView::OnUpdateReportAllowedit(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.IsAllowEdit());
}

void CReportRecordView::OnReportEditonclick()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	m_bEditOnClick = !m_bEditOnClick;
	wndReport.EditOnClick(m_bAllowEdit);
}

void CReportRecordView::OnUpdateReportEditonclick(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.IsEditOnClick());
}

void CReportRecordView::OnReportFocussubitems()
{
	m_bFocusSubItem = !m_bFocusSubItem;
	AllowFocusSubItems(m_bFocusSubItem);
}

void CReportRecordView::OnUpdateReportFocussubitems(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.IsFocusSubItems());
}

void CReportRecordView::OnReportFocusallitems()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	m_bFocusAllItem = !m_bFocusAllItem;
	CXTPReportRows* pRows = wndReport.GetRows();
	for (int i = 0; i<pRows->GetCount(); i++)
		pRows->GetAt(i)->SetSelected(m_bFocusAllItem);
}

void CReportRecordView::OnUpdateReportFocusallitems(CCmdUI* pCmdUI)
{
	pCmdUI->SetCheck(m_bFocusSubItem);
}

void CReportRecordView::OnReportAllowcolumnsremove()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	wndReport.GetReportHeader()->AllowColumnRemove(!wndReport.GetReportHeader()->IsAllowColumnRemove());
}

void CReportRecordView::OnUpdateReportAllowcolumnsremove(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.GetReportHeader()->IsAllowColumnRemove());
}

void CReportRecordView::OnReportAllowcolumnresize()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	wndReport.GetReportHeader()->AllowColumnResize(!wndReport.GetReportHeader()->IsAllowColumnResize());
}

void CReportRecordView::OnUpdateReportAllowcolumnresize(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.GetReportHeader()->IsAllowColumnResize());
}

void CReportRecordView::OnReportAllowcolumnreorder()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	wndReport.GetReportHeader()->AllowColumnReorder(!wndReport.GetReportHeader()->IsAllowColumnReorder());
}

void CReportRecordView::OnUpdateReportAllowcolumnreorder(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.GetReportHeader()->IsAllowColumnReorder());
}

void CReportRecordView::OnReportAutomaticcolumnsizing()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	wndReport.GetReportHeader()->SetAutoColumnSizing(!wndReport.GetReportHeader()->IsAutoColumnSizing());
}

void CReportRecordView::OnUpdateReportAutomaticcolumnsizing(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.GetReportHeader()->IsAutoColumnSizing());
}

void CReportRecordView::OnReportAutomaticcolumnbestfit()
{
	m_bAutoBestFit = !m_bAutoBestFit;
	if(m_bAutoBestFit)
	{
		CXTPReportControl &wndReport = GetReportCtrl();
		CXTPReportColumns* pColums = wndReport.GetColumns();
		CXTPReportHeader* pHeader = wndReport.GetReportHeader();
		for(int i=0; i<pColums->GetCount(); i++)
		{
			CXTPReportColumn* pColumn = pColums->GetAt(i);
			if (pColumn != NULL) pHeader->BestFit(pColumn);
		}
		wndReport.RedrawControl();
	}
}

void CReportRecordView::OnUpdateReportAutomaticcolumnbestfit(CCmdUI* pCmdUI)
{
	pCmdUI->SetCheck(m_bAutoBestFit);
}

void CReportRecordView::OnReportFullColumnScrolling()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	wndReport.SetFullColumnScrolling(!wndReport.IsFullColumnScrolling());
}

void CReportRecordView::OnUpdateReportFullColumnScrolling(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.IsFullColumnScrolling());
}

void CReportRecordView::OnReportAutoGrouping()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	if (wndReport.GetColumns()->GetGroupsOrder()->GetCount() == 0)
	{
		CXTPReportColumn* pColFrom = wndReport.GetColumns()->Find(0);

		wndReport.GetColumns()->GetGroupsOrder()->Clear();

		wndReport.GetColumns()->GetGroupsOrder()->Add(pColFrom);
	}
	else
	{
		wndReport.GetColumns()->GetGroupsOrder()->Clear();
	}
	wndReport.Populate();
}

void CReportRecordView::OnUpdateReportAutoGrouping(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.GetColumns()->GetGroupsOrder()->GetCount() > 0);
}

void CReportRecordView::OnReportHorizontal(UINT id)
{
	SetGridStyle(FALSE, (XTPReportGridStyle)(id - ID_REPORT_HORIZONTAL_NOGRIDLINES));
}

void CReportRecordView::OnUpdateReportHorizontal(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(((int)pCmdUI->m_nID - ID_REPORT_HORIZONTAL_NOGRIDLINES) == wndReport.GetGridStyle(FALSE));
}

void CReportRecordView::OnReportVertical(UINT id)
{
	SetGridStyle(TRUE, (XTPReportGridStyle)(id - ID_REPORT_VERTICAL_NOGRIDLINES));
}

void CReportRecordView::OnUpdateReportVertical(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(((int)pCmdUI->m_nID - ID_REPORT_VERTICAL_NOGRIDLINES) == wndReport.GetGridStyle(TRUE));
}

void CReportRecordView::OnReportLineColor(UINT id)
{
	switch(id)
	{
	case ID_REPORT_LINECOLOR_DEFAULT:
		SetGridColor(RGB(168,168,168));
		break;
	case ID_REPORT_LINECOLOR_RED:
		SetGridColor(RGB(255,0,0));
		break;
	case ID_REPORT_LINECOLOR_BLUE:
		SetGridColor(RGB(0,0,255));
		break;
	case ID_REPORT_LINECOLOR_GREEN:
		SetGridColor(RGB(0,255,0));
		break;
	}
}

void CReportRecordView::OnUpdateReportLineColor(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	switch((int)pCmdUI->m_nID)
	{
	case ID_REPORT_LINECOLOR_DEFAULT:
		pCmdUI->SetCheck(RGB(168,168,168) == GetGridColor());
		break;
	case ID_REPORT_LINECOLOR_RED:
		pCmdUI->SetCheck(RGB(255,0,0) == GetGridColor());
		break;
	case ID_REPORT_LINECOLOR_BLUE:
		pCmdUI->SetCheck(RGB(0,0,255) == GetGridColor());
		break;
	case ID_REPORT_LINECOLOR_GREEN:
		pCmdUI->SetCheck(RGB(0,255,0) == GetGridColor());
		break;
	}
}

void CReportRecordView::OnReportColumnStyle(UINT id)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	m_pPaintManager->SetColumnStyle(XTPReportColumnStyle(id - ID_REPORT_COLUMNSTYLE_SHADED));
	wndReport.RedrawControl();
}

void CReportRecordView::OnUpdateReportColumnStyle(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(m_pPaintManager->GetColumnStyle() == XTPReportColumnStyle(pCmdUI->m_nID - ID_REPORT_COLUMNSTYLE_SHADED)? TRUE: FALSE);
}

void CReportRecordView::OnReportGroupShade()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	wndReport.ShadeGroupHeadings(!wndReport.IsShadeGroupHeadingsEnabled());
}

void CReportRecordView::OnUpdateReportGroupShade(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.IsShadeGroupHeadingsEnabled());
}

void CReportRecordView::OnReportGroupBold()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	wndReport.SetGroupRowsBold(!wndReport.IsGroupRowsBold());
	wndReport.RedrawControl();
}
	
void CReportRecordView::OnUpdateReportGroupBold(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.IsGroupRowsBold());
}

void CReportRecordView::OnReportShowitemsingroups()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	wndReport.GetReportHeader()->ShowItemsInGroups(!wndReport.GetReportHeader()->IsShowItemsInGroups());

	if (!wndReport.GetReportHeader()->IsShowItemsInGroups())
	{
		wndReport.GetColumns()->GetGroupsOrder()->Clear();
		wndReport.Populate();
	}
}

void CReportRecordView::OnUpdateReportShowitemsingroups(CCmdUI* pCmdUI)
{
	CXTPReportControl &wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.GetReportHeader()->IsShowItemsInGroups());	
}

void CReportRecordView::OnReportAutomaticformatting()
{
	CXTPReportControl &wndReport = GetReportCtrl();
	m_bAutomaticFormating = !m_bAutomaticFormating;
	wndReport.RedrawControl();
}

void CReportRecordView::OnUpdateReportAutomaticformatting(CCmdUI* pCmdUI)
{
	pCmdUI->SetCheck(m_bAutomaticFormating);
}

void CReportRecordView::OnReportMultiline()
{
	m_bMultilineSample = !m_bMultilineSample;

	//	Custom implementation (from old version).	
	//	For new versions of the ReportControl this feature is built-in.
	//-----------------------------------------------------------------------------
	//	if (m_bMultilineSample)
	//	{
	//		wndReport.SetPaintManager(new CReportMultilinePaintManager());
	//		wndReport.EnableToolTips(FALSE);
	//	}
	//	else
	//	{
	//		wndReport.SetPaintManager(new CXTPReportPaintManager());
	//		wndReport.EnableToolTips(TRUE);
	//	}
	//-----------------------------------------------------------------------------

	CXTPReportControl &wndReport = GetReportCtrl();
	int nCount = wndReport.GetColumns()->GetCount();
	for( int i = 0; i < nCount; i++) 
	{
		CXTPReportColumn* pColumn = wndReport.GetColumns()->GetAt(i);
		if (pColumn) 
		{
			int nAlign = pColumn->GetAlignment();
			nAlign = m_bMultilineSample ? (nAlign | DT_WORDBREAK) : (nAlign & (~~DT_WORDBREAK));
			pColumn->SetAlignment(nAlign);
		}
	}
	m_pPaintManager->SetFixedRowHeight(!m_bMultilineSample);
	m_pPaintManager->m_bUseColumnTextAlignment = TRUE;

	//
	wndReport.AdjustScrollBars();
}

void CReportRecordView::OnUpdateReportMultiline(CCmdUI* pCmdUI)
{
	pCmdUI->SetCheck(m_bMultilineSample);
}

void CReportRecordView::OnReportFindRecorditem()
{
	m_bFindReportItem = !m_bFindReportItem;
	FindInReport();
}

void CReportRecordView::OnUpdateReportFindRecorditem(CCmdUI* pCmdUI)
{
	pCmdUI->SetCheck(m_bFindReportItem);
}

void CReportRecordView::OnReportIconview()
{
	CXTPReportControl& wndReport = GetReportCtrl();

	wndReport.AssignIconViewPropNumAndIconNum(3, 3, TRUE, 25);

	wndReport.SetIconView(!wndReport.IsIconView());
}

void CReportRecordView::OnUpdateReportIconview(CCmdUI* pCmdUI)
{
	CXTPReportControl& wndReport = GetReportCtrl();
	pCmdUI->SetCheck(wndReport.IsIconView());
}

void CReportRecordView::OnReportWysiwygprint()
{
	m_bWYSIWYG = !m_bWYSIWYG;

	CXTPReportControl& wndReport = GetReportCtrl();

	m_pPaintManager->SetColumnWidthWYSIWYG(m_bWYSIWYG);

	if (m_bWYSIWYG)
		wndReport.GetColumns()->GetGroupsOrder()->Clear();

	m_pPrintOptions->m_bRepeatFooterRows = TRUE;
	m_pPrintOptions->m_bRepeatHeaderRows = TRUE;

	wndReport.RedrawControl();
}

void CReportRecordView::OnUpdateReportWysiwygprint(CCmdUI* pCmdUI)
{
	pCmdUI->SetCheck(m_bWYSIWYG);
}

void CReportRecordView::OnReportPerfomance()
{
	if(m_itemCtrlDataList.size())
		ShowReportPerfomance(m_itemCtrlDataList[0].column);
}

void CReportRecordView::OnReportProperties()
{
	ShowReportProperties();
}

void CReportRecordView::OnReportMerge()
{
	if (m_pReportFrame)
	{
		m_pReportFrame->ActivateFrame();
	}
	else
	{
		CCreateContext context;
		context.m_pLastView       = NULL;
		context.m_pCurrentFrame   = NULL;
		context.m_pNewDocTemplate = NULL;
		context.m_pCurrentDoc     = NULL;
		context.m_pNewViewClass   = RUNTIME_CLASS(CMergeView);

		m_pReportFrame = new CReportFrame(this);
		m_pReportFrame->LoadFrame(IDR_MENU_MERGE, WS_OVERLAPPEDWINDOW|FWS_ADDTOTITLE, 0, &context);
		m_pReportFrame->InitialUpdateFrame(NULL, FALSE);
		m_pReportFrame->ShowWindow(SW_SHOW);
	}
}

void CReportRecordView::OnReportTreeEdit()
{
	CDlgTreeEdit dlgTreeEdit;
	dlgTreeEdit.DoModal();
}

void CReportRecordView::OnReportFormula()
{
	CDlgFormula dlgFormula;
	dlgFormula.DoModal();
}

void CReportRecordView::OnReportDragDrop()
{
	CDlgDragDrop dlgDragDrop;
	dlgDragDrop.DoModal();
}