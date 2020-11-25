// TaskTrackView.cpp : implementation file
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "MainFrm.h"

#include "RibbonReportDoc.h"
#include "TaskTrackView.h"
#include "DlgTimeLineProperties.h"
#include "DlgMarkerProperties.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

const COLORREF clrTable[] =
{
	RGB(0, 0, 0),       // xtpTabColor黑     : 黑 tab color used when OneNote colors enabled.
	RGB(255, 0, 0),     // xtpTabColor红     : 红 tab color used when OneNote colors enabled.
	RGB(0, 255, 0),     // xtpTabColor绿     : 绿 tab color used when OneNote colors enabled.
	RGB(0, 0, 255),     // xtpTabColor蓝     : 蓝 tab color used when OneNote colors enabled.
	RGB(255, 255, 0),   // xtpTabColor黄     : 黄 tab color used when OneNote colors enabled.
	RGB(0, 255, 255),   // xtpTabColor靛     : 靛 tab color used when OneNote colors enabled.
	RGB(255, 0, 255),   // xtpTabColor紫     : 紫 tab color used when OneNote colors enabled.
	RGB(108, 108, 108), // xtpTabColor灰     : 灰 tab color used when OneNote colors enabled.
	RGB(138, 168, 228), // xtpTabColorBlue    : Blue tab color used when OneNote colors enabled.
	RGB(255, 219, 117), // xtpTabColorYellow  : Yellow tab color used when OneNote colors enabled.
	RGB(189, 205, 159), // xtpTabColorGreen   : Green tab color used when OneNote colors enabled.
	RGB(240, 158, 159), // xtpTabColorRed     : Red tab color used when OneNote colors enabled.
	RGB(186, 166, 225), // xtpTabColorPurple  : Purple tab color used when OneNote colors enabled.
	RGB(154, 191, 180), // xtpTabColorCyan    : Cyan tab color used when OneNote colors enabled.
	RGB(247, 182, 131), // xtpTabColorOrange  : Orange tab color used when OneNote colors enabled.
	RGB(216, 171, 192)  // xtpTabColorMagenta : Magenta tab color used when OneNote colors enabled.
};

class CTrackControlPaintManager : public CXTPTrackPaintManager
{
public:
	CTrackControlPaintManager()
	{
		m_columnStyle = xtpReportColumnResource;
		RefreshMetrics();
	}

	void RefreshMetrics()
	{
		CXTPTrackPaintManager::RefreshMetrics();

		SetDrawGridForEmptySpace(TRUE);
		SetGridStyle(0, xtpReportGridSolid);
		SetGridStyle(1, xtpReportGridSolid);

		SetHeaderRowsDividerStyle(xtpReportFixedRowsDividerBold);
		SetFooterRowsDividerStyle(xtpReportFixedRowsDividerBold);
		m_clrHeaderRowsDivider = RGB(255,0,0);
		m_clrFooterRowsDivider = RGB(0,0,255);

		SetLastColumnWidthWYSIWYG(TRUE);


		SetHeaderRowsDividerStyle(xtpReportFixedRowsDividerBold);
		SetFooterRowsDividerStyle(xtpReportFixedRowsDividerBold);
		m_clrHeaderRowsDivider = RGB(0,255,0);
		m_clrFooterRowsDivider = RGB(0,0,255);

		SetDrawGridForEmptySpace(TRUE);
		m_bUseAlternativeBackground = TRUE;

		m_clrControlBack = RGB(166,166,166);
		m_clrAlternativeBackground = RGB(160,160,160);
		m_clrHighlight = RGB(145,145,145);
		m_clrSelectedRow = RGB(145,145,145);
		m_clrGroupBoxBack = RGB(128,128,128);
		m_clrGroupRowText = RGB(255,255,255);

		m_clrGridLine = RGB(193,193,193);

		m_clrColumnOffice2007CustomTheme = RGB(122,122,122);

		m_grcGradientColumnPushed.SetStandardValue(RGB(193,193,193), RGB(169, 169, 169));
		m_grcGradientColumnHot.SetStandardValue(RGB(193,193,193), RGB(169, 169, 169));
		m_grcGradientColumn.SetStandardValue(RGB(193,193,193), RGB(169, 169, 169));
		m_clrGradientColumnShadow.SetStandardValue(RGB(122,122,122));
		m_clrGradientColumnSeparator.SetStandardValue(RGB(122,122,122));
		m_clrGroupBoxBack.SetStandardValue(RGB(166,166,166));
		m_crlNoGroupByText.SetStandardValue(0);
		m_clrGroupShadeBack.SetStandardValue(RGB(166,166,166));


		m_bShadeSortColumn = FALSE;


		m_clrWorkArea = RGB(175, 175, 175);
		m_clrTrackHeader = RGB(166, 166, 166);
		m_clrTrackTimeArea = RGB(166, 166, 166);

		m_clrTimeHeaderDarkDark = RGB(70, 70, 70);
		m_clrTimeHeaderDark = RGB(122, 122, 122);
		m_clrTimeSliderBackground = RGB(96, 96, 96);

		m_clrTimeHeaderDivider = RGB(146, 146, 146);

		m_clrScrollBarLight = RGB(210, 210, 210);
		m_clrScrollBarDark = RGB(190, 190, 190);

		m_clrMarker = RGB(217, 217, 217);
		m_clrSelectedArea = RGB(70, 70, 70);
	}

	void DrawTimeLine(CDC* pDC)
	{
		CXTPTrackControl* pTrackControl = (CXTPTrackControl*)m_pControl;
		CRect rcTimeLineArea = pTrackControl->GetTimelineArea();
		CRect rcHeaderArea = pTrackControl->GetElementRect(xtpReportElementRectHeaderArea);

		CXTPReportColumn* pTrackColumn = pTrackControl->GetTrackColumn();
		int nLeftOffset = pTrackColumn->GetRect().left;
		int nRightOffset = pTrackColumn->GetRect().right;

		CRect rcSliderArea(nLeftOffset, rcTimeLineArea.top, nRightOffset, rcTimeLineArea.top + 10);
		CRect rcTimeArea(nLeftOffset, rcSliderArea.bottom, nRightOffset, rcHeaderArea.top);

		rcTimeArea.DeflateRect(7, 0);

		pDC->FillSolidRect(rcTimeArea, m_clrTrackTimeArea);

		int nTimeScaleMin = pTrackControl->GetTimeLineMin();
		int nTimeScaleMax = pTrackControl->GetTimeLineMax();

		int delta = pTrackControl->PositionToTrack(100) - pTrackControl->PositionToTrack(0);

		int dx = 1;
		if (m_bTimeLineStepAuto)
		{
			if (delta < 30)
				dx = 1000;
			else if (delta < 150)
				dx = 100;
			else if (delta < 300)
				dx = 20;
			else if (delta < 500)
				dx = 10;
			else if (delta < 2000)
				dx = 5;
			else
				dx = 1;

			m_nTimeLineStep = dx;
		}
		else
		{
			dx = m_nTimeLineStep;
		}
		
		CXTPFontDC dcFont(pDC, pTrackControl->GetTrackPaintManager()->GetTextFont());
		pDC->SetTextColor(0);

		int nFirstPos = nTimeScaleMin / dx * dx;
		if (nFirstPos < nTimeScaleMin)
			nFirstPos += dx;

		for (int pos = nFirstPos; pos < nTimeScaleMax; pos += dx)
		{
			CTime t = GetPosTime(pos);
			int m = t.GetMonth();
			int d = t.GetDay();

			if(pos > nFirstPos)
			{
				if(pos == nFirstPos+dx)
					if(d%m_nTimeLineStep != 0) pos -= d%m_nTimeLineStep;

				if(m==1 ||m==3 ||m==5 ||m==7 ||m==8 ||m==10 ||m==12)
				{
					if(d == 30) pos += 1;
					if(m == 3 && d < m_nTimeLineStep) pos -= d%m_nTimeLineStep;
				}
			}

			int x = pTrackControl->PositionToTrack(pos);

			if (x < nLeftOffset - 20 || x > nRightOffset + 20)
				continue;

			pDC->FillSolidRect(x, rcTimeArea.bottom - 4, 1, 8, RGB(35, 35, 35));

			CString strCaption = FormatTime(pos);
			if(pos == nFirstPos)
				strCaption = GetPosTimeStr(pos,2);
			else
			{
				if(d == m_nTimeLineStep)
				{
					if(m == 1)
						strCaption = GetPosTimeStr(pos,2);
					else
						strCaption = GetPosTimeStr(pos,1);
				}
				else
					strCaption = GetPosTimeStr(pos);
			}

			int dx = pDC->GetTextExtent(strCaption).cx;
			pDC->DrawText(strCaption, CRect (x - dx / 2, rcTimeArea.top,x - dx / 2 + dx, rcTimeArea.bottom), DT_VCENTER | DT_SINGLELINE);
		}
	}

	void SetTimeLineRange(CTime begin, CTime end)
	{
		m_tBegin = begin;
		m_tEnd = end;
		CTimeSpan ts = end-begin;
		CXTPTrackControl* pTrackControl = (CXTPTrackControl*)m_pControl;
		pTrackControl->SetTimeLineRange(0, ts.GetDays());
	}

	CTime GetPosTime(int pos)
	{
		CTimeSpan ts(pos,0,0,0);
		return m_tBegin+ts;
	}

	CString GetPosTimeStr(int pos, int fmt = 0)
	{
		CTimeSpan ts(pos,0,0,0);
		CTime t = m_tBegin+ts;
		CString strTime;
		switch (fmt)
		{
		case 0:
			strTime = t.Format("%d");
			break;
		case 1:
			strTime = t.Format("%m/%d");
			break;
		case 2:
			strTime = t.Format("%y/%m/%d");
			break;
		}

		return strTime;
	}

private:
	
	CTime m_tBegin, m_tEnd;
};

CTime g_tBegin, g_tEnd;
class CTaskTrackRecord : public CXTPReportRecord
{
	DECLARE_SERIAL(CTaskTrackRecord)
public:
	CTaskTrackRecord() {}
	CTaskTrackRecord(CString code, CString prj, CTime begin, CTime end, int idx=0, BOOL bKey=FALSE);
	CTaskTrackRecord(CString code, vector<CString> prjs, CTime begin, CTime end, int idx=0, BOOL bKey=FALSE);
};

IMPLEMENT_SERIAL(CTaskTrackRecord, CXTPReportRecord, VERSIONABLE_SCHEMA | _XTP_SCHEMA_CURRENT)
CTaskTrackRecord::CTaskTrackRecord(CString code, CString prj, CTime begin, CTime end, int idx, BOOL bKey)
{
	int d = (end-begin).GetDays();
	int d1 = (begin-g_tBegin).GetDays();
	CXTPReportRecordItem* pItemRcd = AddItem(new CXTPReportRecordItemText(code));
	pItemRcd->SetEditable(TRUE);
	pItemRcd = AddItem(new CXTPReportRecordItemText(prj));
	pItemRcd->SetEditable(TRUE);
	SYSTEMTIME st;
	if(begin.GetAsSystemTime(st))
		pItemRcd = AddItem(new CXTPReportRecordItemDateTime(COleDateTime(st)));
	else
		pItemRcd = AddItem(new CXTPReportRecordItemDateTime(COleDateTime(begin.GetYear(),begin.GetMonth(),begin.GetDay(),begin.GetHour(),begin.GetMinute(),begin.GetSecond())));
	pItemRcd->SetEditable(TRUE);
	pItemRcd->SetFormatString(_T("%Y-%m-%d"));
	if(end.GetAsSystemTime(st))
		pItemRcd = AddItem(new CXTPReportRecordItemDateTime(COleDateTime(st)));
	else
		pItemRcd = AddItem(new CXTPReportRecordItemDateTime(COleDateTime(end.GetYear(),end.GetMonth(),end.GetDay(),end.GetHour(),end.GetMinute(),end.GetSecond())));
	pItemRcd->SetEditable(TRUE);
	pItemRcd->SetFormatString(_T("%Y-%m-%d"));
	pItemRcd = AddItem(new CXTPReportRecordItemNumber(d));
	pItemRcd->SetEditable(TRUE);

	CXTPTrackControlItem* pItemCtrl = (CXTPTrackControlItem*)AddItem(new CXTPTrackControlItem());
	pItemCtrl->SetEditable(FALSE);
	CString strToolTip;
	CXTPTrackBlock* pBlock = new CXTPTrackBlock();
	pBlock->SetPosition(d1);
	pBlock->SetLength(d);
	pBlock->SetColor(clrTable[idx]);
	pBlock->SetMinLength(1);
	pBlock->SetMaxLength((g_tEnd-g_tBegin).GetDays());
	pBlock->SetLocked(TRUE);
	pBlock->SetHeightPercent(2.0 / 3.0);
	strToolTip.Format(_T("%s: %s-%s,工期 %d 天"), prj,begin.Format(_T("%Y-%m-%d")),end.Format(_T("%Y-%m-%d")),d);
	pBlock->SetTooltip(strToolTip);
	pBlock->SetDescriptionText(strToolTip);
	pItemCtrl->Add(pBlock);

	if(bKey)
	{
		CXTPTrackKey* pTrackKey = new CXTPTrackKey();
		pTrackKey->SetPosition(d1);
		pTrackKey->SetColor(clrTable[3]);
		strToolTip.Format(_T("关键工序：%s %s-%s 工期 %d 天"), prj,begin.Format(_T("%Y-%m-%d")),end.Format(_T("%Y-%m-%d")),d);
		pTrackKey->SetTooltip(strToolTip);
		pTrackKey->SetVerticalAlignment(DT_TOP);
		pItemCtrl->Add(pTrackKey);
	}

	pItemCtrl->RecalcLayout();
}

CTaskTrackRecord::CTaskTrackRecord(CString code, vector<CString> prjs, CTime begin, CTime end, int idx, BOOL bKey)
{
	int d = (end-begin).GetDays();
	int d1 = (begin-g_tBegin).GetDays();
	CXTPReportRecordItem* pItemRcd = AddItem(new CXTPReportRecordItemText(code));
	pItemRcd->SetEditable(TRUE);
	for(int i=0; i<prjs.size();i++)
		pItemRcd = AddItem(new CXTPReportRecordItemText(prjs[i]));
	pItemRcd->SetEditable(TRUE);
	SYSTEMTIME st;
	if(begin.GetAsSystemTime(st))
		pItemRcd = AddItem(new CXTPReportRecordItemDateTime(COleDateTime(st)));
	else
		pItemRcd = AddItem(new CXTPReportRecordItemDateTime(COleDateTime(begin.GetYear(),begin.GetMonth(),begin.GetDay(),begin.GetHour(),begin.GetMinute(),begin.GetSecond())));
	pItemRcd->SetEditable(TRUE);
	pItemRcd->SetFormatString(_T("%Y-%m-%d"));
	if(end.GetAsSystemTime(st))
		pItemRcd = AddItem(new CXTPReportRecordItemDateTime(COleDateTime(st)));
	else
		pItemRcd = AddItem(new CXTPReportRecordItemDateTime(COleDateTime(end.GetYear(),end.GetMonth(),end.GetDay(),end.GetHour(),end.GetMinute(),end.GetSecond())));
	pItemRcd->SetEditable(TRUE);
	pItemRcd->SetFormatString(_T("%Y-%m-%d"));
	pItemRcd = AddItem(new CXTPReportRecordItemNumber(d));
	pItemRcd->SetEditable(TRUE);

	CXTPTrackControlItem* pItemCtrl = (CXTPTrackControlItem*)AddItem(new CXTPTrackControlItem());
	pItemCtrl->SetEditable(FALSE);
	CString strToolTip;
	CXTPTrackBlock* pBlock = new CXTPTrackBlock();
	pBlock->SetPosition(d1);
	pBlock->SetLength(d);
	pBlock->SetColor(clrTable[idx]);
	pBlock->SetMinLength(1);
	pBlock->SetMaxLength((g_tEnd-g_tBegin).GetDays());
	pBlock->SetLocked(TRUE);
	pBlock->SetHeightPercent(2.0 / 3.0);
	strToolTip.Format(_T("%s: %s-%s,工期 %d 天"), prjs[0]+prjs[prjs.size()-1],begin.Format(_T("%Y-%m-%d")),end.Format(_T("%Y-%m-%d")),d);
	pBlock->SetTooltip(strToolTip);
	pBlock->SetDescriptionText(strToolTip);
	pItemCtrl->Add(pBlock);

	if(bKey)
	{
		CXTPTrackKey* pTrackKey = new CXTPTrackKey();
		pTrackKey->SetPosition(d1);
		pTrackKey->SetColor(clrTable[3]);
		strToolTip.Format(_T("关键工序：%s %s-%s 工期 %d 天"), prjs[0]+prjs[prjs.size()-1],begin.Format(_T("%Y-%m-%d")),end.Format(_T("%Y-%m-%d")),d);
		pTrackKey->SetTooltip(strToolTip);
		pTrackKey->SetVerticalAlignment(DT_TOP);
		pItemCtrl->Add(pTrackKey);
	}

	pItemCtrl->RecalcLayout();
}


/////////////////////////////////////////////////////////////////////////////
// CTaskTrackView dialog

IMPLEMENT_DYNCREATE(CTaskTrackView, CXTPResizeFormView)
CTaskTrackView::CTaskTrackView()
	: CXTPResizeFormView(CTaskTrackView::IDD)
{
	//{{AFX_DATA_INIT(CTaskTrackView)
	// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32

	g_tBegin = CTime::GetCurrentTime();
	g_tEnd = g_tBegin+CTimeSpan(365*4,0,0,0);
	m_nTimeStep = 5;
	m_bTimeStepAuto = FALSE;
	m_bClassicStyle = FALSE;

	//m_vecRecord.push_back(TASKTRACKITEM("1","路基土石方",CTime(2016,5,10,0,0,0),CTime(2016,5,20,0,0,0),0));
	//m_vecRecord.push_back(TASKTRACKITEM("1.1","路堑挖方",CTime(2016,5,20,0,0,0),CTime(2016,6,10,0,0,0),1));
	//m_vecRecord.push_back(TASKTRACKITEM("1.2","路堤填方",CTime(2016,5,15,0,0,0),CTime(2016,5,25,0,0,0),2));
	//m_vecRecord.push_back(TASKTRACKITEM("2","桥梁工程",CTime(2016,6,1,0,0,0),CTime(2016,6,20,0,0,0),3));
	//m_vecRecord.push_back(TASKTRACKITEM("2.1","下部结构",CTime(2016,5,1,0,0,0),CTime(2016,5,20,0,0,0),4));
	//m_vecRecord.push_back(TASKTRACKITEM("2.2","上部结构",CTime(2016,5,15,0,0,0),CTime(2016,5,20,0,0,0),5));
	//m_vecRecord.push_back(TASKTRACKITEM("3","轨道工程",CTime(2016,5,1,0,0,0),CTime(2016,5,25,0,0,0),6));
	//m_vecRecord.push_back(TASKTRACKITEM("4","四电工程",CTime(2016,7,1,0,0,0),CTime(2016,7,20,0,0,0),7));
	//m_vecRecord.push_back(TASKTRACKITEM("5","隧道工程",CTime(2016,6,1,0,0,0),CTime(2016,7,10,0,0,0),8));
	//m_vecRecord.push_back(TASKTRACKITEM("5.1","暗洞开挖",CTime(2016,5,1,0,0,0),CTime(2016,9,20,0,0,0),9));
	//m_vecRecord.push_back(TASKTRACKITEM("5.2","仰拱施工",CTime(2016,6,1,0,0,0),CTime(2016,7,20,0,0,0),10));
	//m_vecRecord.push_back(TASKTRACKITEM("5.3","洞身施工",CTime(2016,6,15,0,0,0),CTime(2016,8,12,0,0,0),11));
	//m_vecRecord.push_back(TASKTRACKITEM("6","绿化工程",CTime(2016,7,6,0,0,0),CTime(2016,9,23,0,0,0),12));
	//m_vecRecord.push_back(TASKTRACKITEM("7","临建工程",CTime(2016,5,1,0,0,0),CTime(2016,12,20,0,0,0),13));
	//m_vecRecord.push_back(TASKTRACKITEM("7.1","拌合站",CTime(2016,5,13,0,0,0),CTime(2016,11,11,0,0,0),14));
	//m_vecRecord.push_back(TASKTRACKITEM("7.2","钢筋加工厂",CTime(2016,9,1,0,0,0),CTime(2016,10,10,0,0,0),15));

	m_pPrintOptions = new CXTPReportViewPrintOptions();

	m_bPrintSelection = FALSE;
	m_bPaginated = FALSE;

	m_bPrintDirect = FALSE;

	m_nStartColumn = 0;
	m_nEndColumn = 0;
	m_nStartIndex = 0;
	m_bSwitchMode = FALSE;
}

CTaskTrackView::~CTaskTrackView()
{
	CMDTARGET_RELEASE(m_pPrintOptions);
}

void CTaskTrackView::DoDataExchange(CDataExchange* pDX)
{
	CXTPResizeFormView::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CTaskTrackView)
	DDX_Control(pDX, IDC_TASKTRACK_SLIDER, m_wndSlider);
	DDX_Control(pDX, IDC_TASKTRACK_SCROLLBAR, m_wndScrollBar);
	DDX_Control(pDX, IDC_TASKTRACK_REPORTCTRL, m_wndTrackControl);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CTaskTrackView, CXTPResizeFormView)
	//{{AFX_MSG_MAP(CTaskTrackView)
	ON_COMMAND(ID_FILE_OPEN, OnFileOpen)
	ON_COMMAND(ID_FILE_SAVE, OnFileSave)
	ON_COMMAND(ID_FILE_PRINT, OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_SETUP, OnFilePrintSetup)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, CXTPResizeFormView::OnFilePrintPreview)
	ON_COMMAND(ID_EDIT_UNDO, OnEditUndo)
	ON_COMMAND(ID_EDIT_REDO, OnEditRedo)
	ON_COMMAND(ID_EDIT_COPY, OnEditCopy)
	ON_COMMAND(ID_EDIT_CUT, OnEditCut)
	ON_COMMAND(ID_EDIT_PASTE, OnEditPaste)
	ON_UPDATE_COMMAND_UI(ID_EDIT_UNDO, OnUpdateEditUndo)
	ON_UPDATE_COMMAND_UI(ID_EDIT_REDO, OnUpdateEditRedo)
	ON_UPDATE_COMMAND_UI(ID_EDIT_COPY, OnUpdateEditCopy)
	ON_UPDATE_COMMAND_UI(ID_EDIT_CUT, OnUpdateEditCut)
	ON_UPDATE_COMMAND_UI(ID_EDIT_PASTE, OnUpdateEditPaste)
	ON_COMMAND(ID_FILE_IMPORT, OnToolsImport)
	ON_COMMAND(ID_FILE_EXPORT, OnToolsExport)
	ON_WM_DESTROY()
	ON_WM_HSCROLL()
	ON_COMMAND(ID_TASKTRACK_TIMEOFFSET, OnUseTimeOffsetMode)
	ON_COMMAND(ID_TASKTRACK_GROUPBOX, OnViewGroupbox)
	ON_UPDATE_COMMAND_UI(ID_TASKTRACK_GROUPBOX, OnUpdateViewGroupbox)
	ON_COMMAND(ID_TASKTRACK_CLASSICSTYLE, OnViewClassicStyle)
	ON_COMMAND(ID_TASKTRACK_FLEXIBLEDRAG, OnFlexibleDrag)
	ON_UPDATE_COMMAND_UI(ID_TASKTRACK_CLASSICSTYLE, OnUpdateViewClassicStyle)
	ON_UPDATE_COMMAND_UI(ID_TASKTRACK_FLEXIBLEDRAG, OnUpdateFlexibleDrag)
	ON_COMMAND(ID_TASKTRACK_SNAPTOBLOCKS, OnSnapToBlocks)
	ON_UPDATE_COMMAND_UI(ID_TASKTRACK_SNAPTOBLOCKS, OnUpdateSnapToBlocks)
	ON_COMMAND(ID_TASKTRACK_SNAPTOMARKERS, OnSnapToMarkers)
	ON_UPDATE_COMMAND_UI(ID_TASKTRACK_SNAPTOMARKERS, OnUpdateSnapToMarkers)
	ON_COMMAND(ID_TASKTRACK_ALLOWBLOCKMOVE, OnAllowblockmove)
	ON_UPDATE_COMMAND_UI(ID_TASKTRACK_ALLOWBLOCKMOVE, OnUpdateAllowblockmove)
	ON_COMMAND(ID_TASKTRACK_ALLOWBLOCKSCALE, OnAllowblockscale)
	ON_UPDATE_COMMAND_UI(ID_TASKTRACK_ALLOWBLOCKSCALE, OnUpdateAllowblockscale)
	ON_COMMAND(ID_TASKTRACK_ALLOWROWRESIZE, OnAllowRowResize)
	ON_UPDATE_COMMAND_UI(ID_TASKTRACK_ALLOWROWRESIZE, OnUpdateAllowRowResize)
	ON_COMMAND(ID_TASKTRACK_SCALEONRESIZE, OnScaleOnResize)
	ON_UPDATE_COMMAND_UI(ID_TASKTRACK_SCALEONRESIZE, OnUpdateScaleOnResize)
	ON_COMMAND(ID_TASKTRACK_ALLOWBLOCKREMOVE, OnAllowblockRemove)
	ON_UPDATE_COMMAND_UI(ID_TASKTRACK_ALLOWBLOCKREMOVE, OnUpdateAllowblockRemove)
	ON_COMMAND(ID_TASKTRACK_SHOWWORKAREA, OnShowWorkarea)
	ON_UPDATE_COMMAND_UI(ID_TASKTRACK_SHOWWORKAREA, OnUpdateShowWorkarea)
	//}}AFX_MSG_MAP
	ON_NOTIFY(XTP_NM_REPORT_VALUECHANGED, IDC_TASKTRACK_REPORTCTRL, OnValueChanged)
	ON_NOTIFY(NM_RCLICK, IDC_TASKTRACK_REPORTCTRL, OnRClick)
	ON_NOTIFY(XTP_NM_REPORT_HEADER_RCLICK, IDC_TASKTRACK_REPORTCTRL, OnHeaderRClick)
	ON_NOTIFY(NM_DBLCLK, IDC_TASKTRACK_REPORTCTRL, OnDblClick)
	ON_NOTIFY(XTP_NM_TRACK_SLIDERCHANGED, IDC_TASKTRACK_REPORTCTRL, OnTrackSliderChanged)
	ON_NOTIFY(XTP_NM_TRACK_TIMELINECHANGED, IDC_TASKTRACK_REPORTCTRL, OnTrackTimeLineChanged)
	ON_NOTIFY(XTP_NM_TRACK_MARKERCHANGED, IDC_TASKTRACK_REPORTCTRL, OnTrackMarkerChanged)
	ON_NOTIFY(XTP_NM_TRACK_BLOCKCHANGED, IDC_TASKTRACK_REPORTCTRL, OnTrackBlockChanged)
	ON_NOTIFY(XTP_NM_TRACK_SELECTEDBLOCKSCHANGED, IDC_TASKTRACK_REPORTCTRL, OnTrackSelectedBlocksChanged)
END_MESSAGE_MAP()


#ifdef _DEBUG
void CTaskTrackView::AssertValid() const
{
	CXTPResizeFormView::AssertValid();
}

void CTaskTrackView::Dump(CDumpContext& dc) const
{
	CXTPResizeFormView::Dump(dc);
}

CRibbonReportDoc* CTaskTrackView::GetDocument() // non-debug version is inline
{
	if(m_pDocument->IsKindOf(RUNTIME_CLASS(CRibbonReportDoc)))
		return (CRibbonReportDoc*)m_pDocument;

	return NULL;
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CTaskTrackView message handlers


BOOL CTaskTrackView::PreCreateWindow(CREATESTRUCT& cs) 
{
	if (!CXTPResizeFormView::PreCreateWindow(cs))
		return FALSE;

	cs.dwExStyle &= ~WS_EX_CLIENTEDGE;

	return TRUE;
}

void CTaskTrackView::OnInitialUpdate()
{
	CXTPResizeFormView::OnInitialUpdate();
	
	m_wndTrackControl.ModifyStyle(0, WS_CLIPSIBLINGS | WS_CLIPCHILDREN);
	ModifyStyle(0, WS_CLIPSIBLINGS | WS_CLIPCHILDREN);

	CString name[6] = {_T("序号"),_T("项目名称"),_T("开始日期"),_T("完成日期"),_T("工期(天)"),_T("")};
	int     with[6] = {40,120,80,80,60,80};
	for(int i=0; i<6; i++)
	{
		CXTPReportColumn* pCol = m_wndTrackControl.AddColumn(new CXTPReportColumn(i, name[i], with[i]));
		pCol->EnableResize(TRUE);
		pCol->SetHeaderAlignment(DT_CENTER);
		pCol->SetAlignment(DT_CENTER);
	}

	m_wndTrackControl.GetReportHeader()->SetMaxColumnWidth(300);

	m_wndTrackControl.Populate();

	CTrackControlPaintManager* pTpm = new CTrackControlPaintManager;
	m_wndTrackControl.SetPaintManager(pTpm);
	m_wndTrackControl.GetReportHeader()->SetAutoColumnSizing(FALSE);
	m_wndTrackControl.m_bSortedDragDrop = TRUE;
	m_wndTrackControl.AllowEdit(TRUE);
	m_wndTrackControl.EditOnClick(FALSE);
	m_wndTrackControl.SetMultipleSelection(FALSE);

	m_wndTrackControl.EnableMarkup(TRUE);

	m_wndTrackControl.GetColumns()->GetFirstVisibleColumn()->SetAutoSize(TRUE);

	m_wndTrackControl.m_bFreeHeightMode = TRUE;

	m_wndTrackControl.EnableDragDrop(_T("TrackView"), xtpReportAllowDrag | xtpReportAllowDrop);

	pTpm->m_nTimeLineStep = m_nTimeStep;
	pTpm->m_bTimeLineStepAuto = m_bTimeStepAuto;
	pTpm->SetTimeLineRange(g_tBegin, g_tEnd);
	m_wndTrackControl.SetViewPort(0, 90);
	m_wndTrackControl.SetWorkArea(0, 60);

	m_wndTrackControl.SetTimeLinePosition(1);

	m_wndTrackControl.GetMarkers()->Add(5, _T("上旬"));
	m_wndTrackControl.GetMarkers()->Add(15, _T("中旬"));
	m_wndTrackControl.GetMarkers()->Add(25, _T("下旬"));

	m_wndTrackControl.GetReportHeader()->SetLastColumnExpand(TRUE, TRUE);
	m_wndTrackControl.GetReportHeader()->SetAutoColumnSizing(TRUE);

	m_wndTrackControl.GetColumns()->GetLastVisibleColumn()->SetAllowDrag(FALSE);
	m_wndTrackControl.GetColumns()->GetLastVisibleColumn()->SetSortable(FALSE);

	m_wndTrackControl.GetReportHeader()->AllowColumnRemove(TRUE);

	m_wndTrackControl.m_hMoveCursor = AfxGetApp()->LoadCursor(IDC_CURSOR_MOVE);
	m_wndTrackControl.m_hResizeCursor = AfxGetApp()->LoadCursor(IDC_CURSOR_HRESIZE);

	m_wndTrackControl.m_bScaleOnResize = FALSE;

	RepositionControls();

	OnTrackSliderChanged(0, 0);

	m_wndTrackControl.GetUndoManager()->Clear();

	// Set Time Units
	// m_wndTrackControl.m_strTimeFormat = _T("%d ms");

	// Set control resizing.
	SetResize(IDC_TASKTRACK_REPORTCTRL, XTP_ANCHOR_TOPLEFT, XTP_ANCHOR_BOTTOMRIGHT);
	SetResize(IDC_TASKTRACK_SLIDER, XTP_ANCHOR_BOTTOMLEFT, XTP_ANCHOR_BOTTOMLEFT);
	SetResize(IDC_TASKTRACK_SCROLLBAR, XTP_ANCHOR_BOTTOMLEFT, XTP_ANCHOR_BOTTOMRIGHT);

	// Load window placement
	LoadPlacement(_T("CTaskTrackView"));
}

void CTaskTrackView::OnDraw(CDC* pDC)
{
	UNREFERENCED_PARAMETER(pDC);
	CRibbonReportDoc* pDoc = GetDocument();
}

BOOL CTaskTrackView::OnPreparePrinting(CPrintInfo* pInfo)
{
	if (m_wndTrackControl.IsIconView())
	{
		m_wndTrackControl.SetIconView(FALSE);
		m_bSwitchMode = TRUE;
	}

	m_bShowRowNumber = m_wndTrackControl.IsShowRowNumber();
	m_wndTrackControl.ShowRowNumber(FALSE);

	if (m_wndTrackControl.GetSelectedRows()->GetCount() > 0)
		pInfo->m_pPD->m_pd.Flags &= ~PD_NOSELECTION;

	pInfo->m_bDirect = m_bPrintDirect;

	// default preparation
	if (!DoPreparePrinting(pInfo))
		return FALSE;

	m_bPrintSelection = pInfo->m_pPD->PrintSelection();

	return TRUE;
}

void CTaskTrackView::OnEndPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	m_aPageStart.RemoveAll();

	if (m_pPrintOptions->m_bBlackWhitePrinting)
		m_bmpGrayDC.DeleteObject();

	if (m_bSwitchMode)
	{
		m_wndTrackControl.SetIconView(TRUE);
		m_bSwitchMode = FALSE;
	}
	m_wndTrackControl.ShowRowNumber(m_bShowRowNumber);
}

int CTaskTrackView::GetColumnWidth(CXTPReportColumn* pColumnTest, int nTotalWidth)
{
	return pColumnTest->GetPrintWidth(nTotalWidth);
}

void CTaskTrackView::PrintHeader(CDC* pDC, CRect rcHeader)
{
	CXTPReportColumns* pColumns = m_wndTrackControl.GetColumns();

	m_wndTrackControl.GetTrackPaintManager()->FillHeaderControl(pDC, rcHeader);

	int x = rcHeader.left;
	int nWidth;
	for (UINT i = m_nStartColumn; i < m_nEndColumn; i++)
	{
		CXTPReportColumn* pColumn = pColumns->GetAt(i);
		if (!pColumn->IsVisible())
			continue;

		if (m_wndTrackControl.GetTrackPaintManager()->IsColumnWidthWYSIWYG())
			nWidth = pColumn->GetWidth();
		else
			nWidth = GetColumnWidth(pColumn, rcHeader.Width());
		CRect rcItem(x, rcHeader.top, x + nWidth, rcHeader.bottom);
		m_wndTrackControl.GetTrackPaintManager()->DrawColumn(pDC, pColumn, m_wndTrackControl.GetReportHeader(), rcItem);
		x += nWidth;
	}
}

void CTaskTrackView::PrintFooter(CDC* pDC, CRect rcFooter)
{
	CXTPReportColumns* pColumns = m_wndTrackControl.GetColumns();

	m_wndTrackControl.GetTrackPaintManager()->FillFooter(pDC, rcFooter);

	int x = rcFooter.left;
	int nWidth(0);
	for (UINT i = m_nStartColumn; i < m_nEndColumn; i++)
	{
		CXTPReportColumn* pColumn = pColumns->GetAt(i);
		if (!pColumn->IsVisible())
			continue;

		if (m_wndTrackControl.GetTrackPaintManager()->IsColumnWidthWYSIWYG())
			nWidth = pColumn->GetWidth();
		else
			nWidth = GetColumnWidth(pColumn, rcFooter.Width());
		CRect rcItem(x, rcFooter.top, x + nWidth, rcFooter.bottom);
		m_wndTrackControl.GetTrackPaintManager()->DrawColumnFooter(pDC, pColumn, m_wndTrackControl.GetReportHeader(), rcItem);
		x += nWidth;
	}
}

void CTaskTrackView::PrintRow(CDC* pDC, CXTPReportRow* pRow, CRect rcRow, int nPreviewHeight)
{
	CXTPReportControl& wndReport = m_wndTrackControl;
	CXTPReportColumns* pColumns = wndReport.GetColumns();
	CXTPTrackPaintManager* pPaintManager = m_wndTrackControl.GetTrackPaintManager();

	if (pRow->IsGroupRow())
	{
		CRect rcItem(rcRow);
		rcItem.bottom = rcItem.bottom - nPreviewHeight;
		BOOL bFirstVisibleColumn = TRUE;

		int x = rcRow.left;
		// paint record items
		for (UINT nColumn = m_nStartColumn; nColumn < m_nEndColumn; nColumn++)
		{
			CXTPReportColumn* pColumn = pColumns->GetAt(nColumn);
			if (pColumn && pColumn->IsVisible())
			{
				rcItem.left = x;
				if (m_wndTrackControl.GetTrackPaintManager()->IsColumnWidthWYSIWYG())
					x = rcItem.right = rcItem.left + pColumn->GetWidth();
				else
					x = rcItem.right = rcItem.left + GetColumnWidth(pColumn, rcRow.Width());

				if (bFirstVisibleColumn)
				{
					rcItem.left += wndReport.GetHeaderIndent();
					bFirstVisibleColumn = FALSE;
				}
			}
		}

		pRow->Draw(pDC, rcRow, 0,0,CXTPReportRecordMergeItems(),0,0);
		return;
	}


	XTP_REPORTRECORDITEM_DRAWARGS drawArgs;
	drawArgs.pDC = pDC;
	drawArgs.pControl = &wndReport;
	drawArgs.pRow = pRow;
	int nIndentWidth = wndReport.GetHeaderIndent();

	// paint row background
	pPaintManager->FillRow(pDC, pRow, rcRow);

	CRect rcItem(rcRow);
	rcItem.bottom = rcItem.bottom - nPreviewHeight;

	CXTPReportRecord* pRecord = pRow->GetRecord();
	if (pRecord) // if drawing record, not group
	{
		BOOL bFirstVisibleColumn = TRUE;
		int x = rcRow.left;
		// paint record items
		for (UINT nColumn = m_nStartColumn; nColumn < m_nEndColumn; nColumn++)
		{
			CXTPReportColumn* pColumn = pColumns->GetAt(nColumn);
			if (pColumn && pColumn->IsVisible() && pRow->IsItemsVisible())
			{
				rcItem.left = x;
				if (m_wndTrackControl.GetTrackPaintManager()->IsColumnWidthWYSIWYG())
					x = rcItem.right = rcItem.left + pColumn->GetWidth();
				else
					x = rcItem.right = rcItem.left + GetColumnWidth(pColumn, rcRow.Width());

				if (bFirstVisibleColumn)
				{
					rcItem.left += nIndentWidth;
					bFirstVisibleColumn = FALSE;
				}

				CRect rcGridItem(rcItem);
				rcGridItem.left--;

				CXTPReportRecordItem* pItem = pRecord->GetItem(pColumn);

				if (pItem)
				{
					drawArgs.pColumn = pColumn;
					drawArgs.rcItem = rcItem;
					drawArgs.nTextAlign = pColumn->GetAlignment();
					drawArgs.pItem = pItem;
					pItem->Draw(&drawArgs);
				}

				if (pRow->GetType() == xtpRowTypeHeader
					&& pColumn->GetDrawHeaderRowsVGrid())
					pPaintManager->DrawGrid(pDC, xtpReportOrientationVertical, rcGridItem);
				else if (pRow->GetType() == xtpRowTypeFooter
					&& pColumn->GetDrawFooterRowsVGrid())
					pPaintManager->DrawGrid(pDC, xtpReportOrientationVertical, rcGridItem);
				else
					pPaintManager->DrawGrid(pDC, xtpReportOrientationVertical, rcGridItem);
			}
		}

		if (nIndentWidth > 0)
		{
			CRect rcIndent(rcRow);
			rcIndent.right = rcRow.left + nIndentWidth;
			pPaintManager->FillIndent(pDC, rcIndent);
		}

		if (pRow->IsPreviewVisible())
		{
			CXTPReportRecordItemPreview* pItem = pRecord->GetItemPreview();

			CRect rcPreviewItem(rcRow);
			rcPreviewItem.DeflateRect(nIndentWidth, rcPreviewItem.Height() - nPreviewHeight, 0, 0);

			drawArgs.rcItem = rcPreviewItem;
			drawArgs.nTextAlign = DT_LEFT;
			drawArgs.pItem = pItem;
			drawArgs.pColumn = NULL;

			drawArgs.pItem->Draw(&drawArgs);
		}
	}

	BOOL bGridVisible = pPaintManager->IsGridVisible(FALSE);

	CRect rcFocus(rcRow.left, rcRow.top, rcRow.right, rcRow.bottom - (bGridVisible ? 1 : 0));

	if (pRow->GetIndex() < wndReport.GetRows()->GetCount() - 1 && nIndentWidth > 0)
	{
		CXTPReportRow* pNextRow = wndReport.GetRows()->GetAt(pRow->GetIndex() + 1);
		if (pNextRow)
			rcFocus.left = rcRow.left +  min(nIndentWidth, pPaintManager->m_nTreeIndent * pNextRow->GetTreeDepth());
	}

	pPaintManager->DrawGrid(pDC, xtpReportOrientationHorizontal, rcFocus);
}

int CTaskTrackView::PrintRows(CDC* pDC, CRect rcClient, long nIndexStart, int* pnPrintedRowsHeight)
{
	int y = rcClient.top;
	CXTPReportRows* pRows = m_wndTrackControl.GetRows();

	for (; nIndexStart < pRows->GetCount(); nIndexStart++)
	{
		CXTPReportRow* pRow = pRows->GetAt(nIndexStart);

		if (m_bPrintSelection && !pRow->IsSelected())
			continue;

		int nHeight = pRow->GetHeight(pDC, rcClient.Width());
		int nPreviewHeight = 0;

		if (pRow->IsPreviewVisible())
		{
			CXTPReportRecordItemPreview* pItem = pRow->GetRecord()->GetItemPreview();
			nPreviewHeight = pItem->GetPreviewHeight(pDC, pRow, rcClient.Width());
			nPreviewHeight = m_wndTrackControl.GetTrackPaintManager()->GetPreviewItemHeight(pDC, pRow, rcClient.Width(), nPreviewHeight);
			nHeight += nPreviewHeight;
		}

		CRect rcRow(rcClient.left, y, rcClient.right, y + nHeight);

		if (rcRow.bottom > rcClient.bottom)
			break;

		PrintRow(pDC, pRow, rcRow, nPreviewHeight);

		y += rcRow.Height();
	}

	if (pnPrintedRowsHeight != NULL)
		*pnPrintedRowsHeight = y - rcClient.top; // height of the printed rows

	return nIndexStart;
}

long CTaskTrackView::PrintTrack(CDC* pDC, CPrintInfo* pInfo, CRect rcPage, long nIndexStart)
{
	int nMaxPages = -1;
	if (pInfo->GetMaxPage() != 65535)
		nMaxPages = pInfo->GetMaxPage();

	int nHeaderHeight = PrintPageHeader(pDC, pInfo, rcPage, FALSE,
		pInfo->m_nCurPage, nMaxPages,
		m_nStartIndex, (int) m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetSize() - 1);

	int nFooterHeight = PrintPageFooter(pDC, pInfo, rcPage, FALSE,
		pInfo->m_nCurPage, nMaxPages,
		m_nStartIndex, (int) m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetSize() - 1);

	CRect rcRows(rcPage);

	if (m_wndTrackControl.GetTrackPaintManager()->m_bPrintPageRectangle)
		rcRows.DeflateRect(1,1);

	rcRows.top += nHeaderHeight;
	rcRows.bottom -= nFooterHeight;
	int nFooterTop = rcRows.bottom;

	if (m_wndTrackControl.GetTrackPaintManager()->m_bPrintWatermark)
	{
		CRect rcWater(rcRows);
		rcWater.top += m_wndTrackControl.GetTrackPaintManager()->GetHeaderHeight();
		rcWater.bottom -= m_wndTrackControl.GetTrackPaintManager()->GetFooterHeight(&m_wndTrackControl, pDC);
		m_wndTrackControl.DrawWatermark(pDC, rcWater, rcPage);
	}
	// print header rows (if exist and visible)
	if (m_wndTrackControl.GetHeaderRows()->GetCount() > 0 && m_wndTrackControl.IsHeaderRowsVisible())
	{
		// print on the first page, at least
		if (0 == nIndexStart || m_pPrintOptions->m_bRepeatHeaderRows)
		{
			rcRows.top += PrintFixedRows(pDC, rcRows, TRUE);

			// print divider
			rcRows.top += PrintFixedRowsDivider(pDC, rcRows, TRUE);
		}
	}

	// calculate space for footer rows
	int nNeedForFooterRows = 0;

	if (m_wndTrackControl.GetFooterRows()->GetCount() > 0 && m_wndTrackControl.IsFooterRowsVisible())
	{
		nNeedForFooterRows = GetRowsHeight(m_wndTrackControl.GetFooterRows(), rcRows.Width());
		nNeedForFooterRows += m_wndTrackControl.GetTrackPaintManager()->GetSectionDividerHeight(xtpReportSectionDividerStyleBold);

		if (m_pPrintOptions->m_bRepeatFooterRows)
		{
			// decrease space for body rows, if footer rows to be repeated on every page.
			rcRows.bottom = nFooterTop - nNeedForFooterRows;
		}
	}
	// print body rows
	int nPrintedBodyRowsHeight = 0;
	nIndexStart = PrintRows(pDC, rcRows, nIndexStart, &nPrintedBodyRowsHeight);

	// print footer rows (if exist and visible)
	if (nNeedForFooterRows > 0)
	{
		CRect rcFooterRows(rcRows);
		rcFooterRows.top = rcRows.top + nPrintedBodyRowsHeight; //immediately after body rows
		//rcFooterRows.bottom = rcFooter.top;
		rcFooterRows.bottom = nFooterTop;

		// one more check, if there is enough space for footer divider + footer rows
		if (rcFooterRows.Height() > nNeedForFooterRows)
		{
			// print divider
			rcFooterRows.top += PrintFixedRowsDivider(pDC, rcFooterRows, FALSE);

			// print footer rows
			PrintFixedRows(pDC, rcFooterRows, FALSE);
		}
	}

	if (m_wndTrackControl.GetTrackPaintManager()->m_bPrintPageRectangle)
		pDC->Draw3dRect(rcPage, 0, 0);

	m_wndTrackControl.GetTrackPaintManager()->DrawTimeLine(pDC);

	return nIndexStart;
}

int CTaskTrackView::GetRowsHeight(CXTPReportRows* pRows, int nTotalWidth, int nMaxHeight)
{
	int nRowsHeight = 0;

	CWindowDC dc (this);

	for (int i = 0; i < pRows->GetCount(); ++i)
	{
		nRowsHeight += m_wndTrackControl.GetPaintManager()->GetRowHeight(&dc, pRows->GetAt(i), nTotalWidth);

		if (nMaxHeight >= 0 && nRowsHeight > nMaxHeight)
			return nRowsHeight;
	}

	return nRowsHeight;
}

int CTaskTrackView::PrintFixedRowsDivider(CDC* pDC, const CRect& rc, BOOL bHeaderRows)
{
	CRect rcDivider(rc);
	int nHeight = bHeaderRows ? m_wndTrackControl.GetTrackPaintManager()->GetSectionDividerHeight(xtpReportFixedRowsDividerBold) : m_wndTrackControl.GetTrackPaintManager()->GetSectionDividerHeight(xtpReportFixedRowsDividerBold);

	rcDivider.bottom = rcDivider.top + nHeight;

	m_wndTrackControl.GetTrackPaintManager()->DrawSectionDivider(pDC, rcDivider, xtpReportSectionDividerPositionBottom, xtpReportSectionDividerStyleBold, CXTPPaintManagerColor(COLORREF_NULL));

	return nHeight;
}

long CTaskTrackView::PrintPage(CDC* pDC, CPrintInfo* pInfo, CRect rcPage, long nIndexStart)
{
	if (!m_pPrintOptions || !pDC || !pInfo)
		return INT_MAX;

	CRect rcPageHeader = rcPage;
	CRect rcPageFooter = rcPage;

	CString strTitle = CXTPPrintPageHeaderFooter::GetParentFrameTitle(this);

	int N = (int) m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetSize() - 1;
	int nVirPage(0);
	if (N > 0)
		nVirPage = 1 + m_nStartIndex;

	if (m_wndTrackControl.GetTrackPaintManager()->m_bPrintVirtualPageNumber)
	{
		m_pPrintOptions->GetPageHeader()->FormatTexts(pInfo, strTitle, nVirPage);
		m_pPrintOptions->GetPageFooter()->FormatTexts(pInfo, strTitle, nVirPage);
	}
	else
	{
		m_pPrintOptions->GetPageHeader()->FormatTexts(pInfo, strTitle);
		m_pPrintOptions->GetPageFooter()->FormatTexts(pInfo, strTitle);
	}

	pDC->SetBkColor(RGB(255, 255, 255));
	m_pPrintOptions->GetPageFooter()->Draw(pDC, rcPageFooter, TRUE);
	m_pPrintOptions->GetPageHeader()->Draw(pDC, rcPageHeader);

	CRect rcReport = rcPage;
	rcReport.top += rcPageHeader.Height() + 2;
	rcReport.bottom -= rcPageFooter.Height() + 2;

	long nNextRow = PrintTrack(pDC, pInfo, rcReport, nIndexStart);

	pDC->SetBkColor(RGB(255, 255, 255));
	m_pPrintOptions->GetPageFooter()->Draw(pDC, rcPageFooter);

	return nNextRow;
}

int CTaskTrackView::PrintPageHeader(CDC* pDC, CPrintInfo* pInfo, CRect rcPage,
									BOOL bOnlyCalculate, int nPageNumber, int nNumberOfPages,
									int nHorizontalPageNumber, int nNumberOfHorizontalPages)
{
	UNREFERENCED_PARAMETER(pInfo);
	UNREFERENCED_PARAMETER(nPageNumber);
	UNREFERENCED_PARAMETER(nNumberOfPages);
	UNREFERENCED_PARAMETER(nHorizontalPageNumber);
	UNREFERENCED_PARAMETER(nNumberOfHorizontalPages);
	UNREFERENCED_PARAMETER(bOnlyCalculate);
	UNREFERENCED_PARAMETER(nPageNumber);
	UNREFERENCED_PARAMETER(nHorizontalPageNumber);
	UNREFERENCED_PARAMETER(nNumberOfHorizontalPages);

	int nHeaderHeight = 0;

	if (m_wndTrackControl.GetTrackPaintManager()->m_bPrintPageRectangle)
		rcPage.DeflateRect(1,1);

	if (m_wndTrackControl.IsHeaderVisible())
		nHeaderHeight = m_wndTrackControl.GetTrackPaintManager()->GetHeaderHeight(&m_wndTrackControl, pDC, rcPage.Width());

	rcPage.bottom = rcPage.top + nHeaderHeight;

	if (nHeaderHeight)
		PrintHeader(pDC, rcPage);

	return nHeaderHeight;
}

int CTaskTrackView::PrintPageFooter(CDC* pDC, CPrintInfo* pInfo, CRect rcPage,
									BOOL bOnlyCalculate, int nPageNumber, int nNumberOfPages,
									int nHorizontalPageNumber, int nNumberOfHorizontalPages)
{
	UNREFERENCED_PARAMETER(pInfo);
	UNREFERENCED_PARAMETER(nPageNumber);
	UNREFERENCED_PARAMETER(nNumberOfPages);
	UNREFERENCED_PARAMETER(nHorizontalPageNumber);
	UNREFERENCED_PARAMETER(nNumberOfHorizontalPages);
	UNREFERENCED_PARAMETER(bOnlyCalculate);
	UNREFERENCED_PARAMETER(nPageNumber);
	UNREFERENCED_PARAMETER(nHorizontalPageNumber);
	UNREFERENCED_PARAMETER(nNumberOfHorizontalPages);

	int nFooterHeight = 0;

	if (m_wndTrackControl.GetTrackPaintManager()->m_bPrintPageRectangle)
		rcPage.DeflateRect(1,1);

	if (m_wndTrackControl.IsFooterVisible())
		nFooterHeight = m_wndTrackControl.GetTrackPaintManager()->GetFooterHeight(&m_wndTrackControl, pDC, rcPage.Width());

	rcPage.top = rcPage.bottom - nFooterHeight;

	if (nFooterHeight)
		PrintFooter(pDC, rcPage);

	return nFooterHeight;
}

int CTaskTrackView::SetupStartCol(CDC* pDC, CPrintInfo* pInfo)
{
	CSize PaperPPI(pDC->GetDeviceCaps(LOGPIXELSX), pDC->GetDeviceCaps(LOGPIXELSY));
	CSize PaperSize = CSize(pDC->GetDeviceCaps(HORZRES), pDC->GetDeviceCaps(VERTRES));

	pDC->SetMapMode(MM_ANISOTROPIC);
	pDC->SetViewportExt(pDC->GetDeviceCaps(LOGPIXELSX), pDC->GetDeviceCaps(LOGPIXELSY));
	pDC->SetWindowExt(96, 96);
	pDC->OffsetWindowOrg(0, 0);

	pInfo->m_rectDraw.SetRect(0, 0, pDC->GetDeviceCaps(HORZRES), pDC->GetDeviceCaps(VERTRES));
	pDC->DPtoLP(&pInfo->m_rectDraw);

	CRect rcMargins = m_pPrintOptions->GetMarginsLP(pDC);
	CRect rc = pInfo->m_rectDraw;
	rc.DeflateRect(rcMargins);
	m_wndTrackControl.GetTrackPaintManager()->m_PrintPageWidth = rc.Width();
	m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.RemoveAll();
	m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.Add(0);
	CXTPReportColumns* pColumns = m_wndTrackControl.GetColumns();
	int nColumnCount = pColumns->GetCount();
	if (m_wndTrackControl.GetTrackPaintManager()->IsColumnWidthWYSIWYG())
	{
		int x = 0, y = 0;
		for (int nColumn = 0; nColumn < nColumnCount; nColumn++)
		{
			CXTPReportColumn* pColumn = pColumns->GetAt(nColumn);
			if (pColumn && pColumn->IsVisible())
			{
				x = pColumn->GetWidth();
				if (y + x <= m_wndTrackControl.GetTrackPaintManager()->m_PrintPageWidth)
					y += x;
				else
				{
					m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.Add(nColumn);
					y = x;
				}
			}
		}
	}
	m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.Add(nColumnCount);

	return (int) m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetSize() - 1;
}

//struct CPrintInfo // Printing information structure
//  CPrintDialog* m_pPD;     // pointer to print dialog
//  BOOL m_bPreview;         // TRUE if in preview mode
//  BOOL m_bDirect;          // TRUE if bypassing Print Dialog
//  BOOL m_bContinuePrinting;// set to FALSE to prematurely end printing
//  UINT m_nCurPage;         // Current page
//  UINT m_nNumPreviewPages; // Desired number of preview pages
//  CString m_strPageDesc;   // Format string for page number display
//  void SetMinPage(UINT nMinPage);
//  void SetMaxPage(UINT nMaxPage);
//  UINT GetMinPage() const;
//  UINT GetMaxPage() const;
//  UINT GetFromPage() const;
//  UINT GetToPage() const;
void CTaskTrackView::OnBeginPrinting(CDC* pDC, CPrintInfo* pInfo)
{
	m_aPageStart.RemoveAll();
	m_aPageStart.Add(0);

	int nVirtualPages = SetupStartCol(pDC, pInfo);
	if (pInfo->m_bPreview)
	{
		pInfo->m_nNumPreviewPages = 1;
		AfxGetApp()->m_nNumPreviewPages = pInfo->m_nNumPreviewPages;
	}

	CString str1, str2;
	if (m_pPrintOptions && m_pPrintOptions->GetPageHeader())
		str1 = m_pPrintOptions->GetPageHeader()->m_strFormatString;
	if (m_pPrintOptions && m_pPrintOptions->GetPageFooter())
		str2 = m_pPrintOptions->GetPageFooter()->m_strFormatString;

	if (nVirtualPages > 1 && m_pPrintOptions->GetPageHeader()->m_strFormatString.IsEmpty())
		m_pPrintOptions->GetPageHeader()->m_strFormatString = _T(" &p/&P ");

	UINT pFr = pInfo->GetFromPage();
	UINT pTo = pInfo->GetToPage();
	if (pFr > 0)
	{
		pInfo->SetMinPage(pFr);
		pInfo->m_nCurPage = pFr;
	}
	if (pTo < 65535)
		pInfo->SetMaxPage(pTo);

	if (m_wndTrackControl.m_bForcePagination)
		m_bPaginated = FALSE;
	if ((!pInfo->m_bPreview || m_wndTrackControl.m_bForcePagination)
		&& (str1.Find(_T("&P")) >= 0
		|| nVirtualPages > 1
		|| pFr > 1
		|| pTo < 65535
		|| str2.Find(_T("&P")) >= 0))
	{
		m_nStartIndex = 0;
		m_nStartColumn = m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetAt(0);
		m_nEndColumn = m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetAt(1);

		int nCurPage = pInfo->m_nCurPage;
		pInfo->m_nCurPage = 65535;

		if (PaginateTo(pDC, pInfo))
			pInfo->SetMaxPage((int) m_aPageStart.GetSize() - 1 - m_nStartIndex);

		pInfo->m_nCurPage = nCurPage;
		if (m_wndTrackControl.m_bForcePagination)
			m_bPaginated = TRUE;
	}
	m_nStartIndex = 0;
	m_nStartColumn = m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetAt(0);
	m_nEndColumn = m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetAt(1);
}

void CTaskTrackView::OnPrint(CDC* pDC, CPrintInfo* pInfo)
{
	if (!m_pPrintOptions || !pDC || !pInfo)
		return;

	CRect rcMargins = m_pPrintOptions->GetMarginsLP(pDC);
	CRect rc = pInfo->m_rectDraw;
	rc.DeflateRect(rcMargins);

	UINT nVirtualPages = (UINT) m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetSize() - 1;
	UINT nPage = pInfo->m_nCurPage;
	int nSize = (int) m_aPageStart.GetSize();

	if(nPage <= (UINT) nSize) return;

	UINT nIndex = m_aPageStart[nPage - 1];
	UINT mIndex(0);
	//TRACE(_T("pInfo->m_nCurPage=%d nIndex=%d\n"), pInfo->m_nCurPage, nIndex);

	if (m_bPaginated)
	{
		m_nStartIndex = (pInfo->m_nCurPage - 1) % nVirtualPages;
		m_nStartColumn = m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetAt(m_nStartIndex);
		m_nEndColumn = m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetAt(m_nStartIndex + 1);
	}

	if (!m_pPrintOptions->m_bBlackWhitePrinting)
	{
		mIndex = PrintPage(pDC, pInfo, rc, nIndex);
	}
	else
	{
		CRect rc00(0, 0, rc.Width(), rc.Height());

		CDC memDC;
		if(!memDC.CreateCompatibleDC(pDC)) return;
		memDC.m_bPrinting = TRUE;

		if (!m_bmpGrayDC.m_hObject
			|| m_bmpGrayDC.GetBitmapDimension() != rc00.Size())
		{
			m_bmpGrayDC.DeleteObject();
			m_bmpGrayDC.CreateCompatibleBitmap(pDC, rc00.Width(), rc00.Height());
		}

		CXTPBitmapDC autpBmp(&memDC, &m_bmpGrayDC);

		memDC.FillSolidRect(rc00, RGB(255, 255, 255));

		mIndex = PrintPage(&memDC, pInfo, rc00, nIndex);

		int nCC = max(0, min(m_pPrintOptions->m_nBlackWhiteContrast, 255));
		XTPImageManager()->BlackWhiteBitmap(memDC, rc00, nCC);

		pDC->BitBlt(rc.left, rc.top, rc.Width(), rc.Height(), &memDC, 0, 0, SRCCOPY);
	}

	if (!m_bPaginated)
	{
		m_nStartIndex++;
		if (m_nStartIndex >= nVirtualPages) //done with the page!
			m_nStartIndex = 0;

		m_nStartColumn = m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetAt(m_nStartIndex);
		m_nEndColumn = m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetAt(m_nStartIndex + 1);

		if (m_nStartIndex > 0)
		{
			if (nPage == (UINT) nSize)
				m_aPageStart.Add(nIndex);
			else if (nPage < (UINT) nSize)
				m_aPageStart[nPage] = nIndex;
		}
		else
		{
			if (nPage == (UINT) nSize)
				m_aPageStart.Add(mIndex);
			else if (nPage < (UINT) nSize)
				m_aPageStart[nPage] = mIndex;

			if ((int) mIndex == m_wndTrackControl.GetRows()->GetCount())
				pInfo->SetMaxPage(pInfo->m_nCurPage);
		}
	}
	if (pInfo->m_bPreview)
	{
		//TRACE(_T("pInfo->m_nCurPage=%d\n"), pInfo->m_nCurPage);
		pInfo->m_nCurPage++;
	}
}

BOOL CTaskTrackView::PaginateTo(CDC* pDC, CPrintInfo* pInfo)
{
	if(!pDC) return FALSE;

	UINT nVirtualPages = (UINT) m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetSize() - 1;
	BOOL bAborted = FALSE;
	CXTPPrintingDialog PrintStatus(this);
	CString strTemp;
	if (GetParentFrame())
		GetParentFrame()->GetWindowText(strTemp);

	PrintStatus.SetWindowText(_T("Calculating pages..."));
	PrintStatus.SetDlgItemText(AFX_IDC_PRINT_DOCNAME, strTemp);
	PrintStatus.SetDlgItemText(AFX_IDC_PRINT_PRINTERNAME, pInfo->m_pPD->GetDeviceName());
	PrintStatus.SetDlgItemText(AFX_IDC_PRINT_PORTNAME, pInfo->m_pPD->GetPortName());
	PrintStatus.ShowWindow(SW_SHOW);
	PrintStatus.UpdateWindow();

	CRect rectSave = pInfo->m_rectDraw;
	UINT nPageSave = pInfo->m_nCurPage;
	BOOL bBlackWhiteSaved = m_pPrintOptions->m_bBlackWhitePrinting;
	m_pPrintOptions->m_bBlackWhitePrinting = FALSE;

	if(nPageSave < 1) return FALSE;
	if(nPageSave >= (UINT) m_aPageStart.GetSize()) return FALSE;
	if(!pDC->SaveDC()) return FALSE;

	pDC->IntersectClipRect(0, 0, 0, 0);
	UINT nCurPage = (UINT) m_aPageStart.GetSize();
	pInfo->m_nCurPage = nCurPage;

	while (pInfo->m_nCurPage < nPageSave && pInfo->m_nCurPage <= pInfo->GetMaxPage())
	{
		if (pInfo->m_bPreview)
			if(pInfo->m_nCurPage == (UINT) m_aPageStart.GetSize()) return FALSE;

		OnPrepareDC(pDC, pInfo);

		if (!pInfo->m_bContinuePrinting)
			break;
		if (nVirtualPages > 1)
			strTemp.Format(_T("%d [%d - %d]"),
			pInfo->m_nCurPage,
			1 + (pInfo->m_nCurPage / nVirtualPages),
			1 + (pInfo->m_nCurPage % nVirtualPages));
		else
			strTemp.Format(_T("%d"), pInfo->m_nCurPage);

		PrintStatus.SetDlgItemText(AFX_IDC_PRINT_PAGENUM, strTemp);

		pInfo->m_rectDraw.SetRect(0, 0, pDC->GetDeviceCaps(HORZRES), pDC->GetDeviceCaps(VERTRES));
		pDC->DPtoLP(&pInfo->m_rectDraw);

		OnPrint(pDC, pInfo);

		if (!pInfo->m_bPreview)
			pInfo->m_nCurPage++;

		if (pInfo->GetMaxPage() == 65535)
			pInfo->SetMaxPage(max(pInfo->GetMaxPage(), pInfo->m_nCurPage));

		if (!_XTPAbortProc(0, 0))
		{
			bAborted = TRUE;
			break;
		}
	}
	PrintStatus.DestroyWindow();

	BOOL bResult = !bAborted
		&& (pInfo->m_nCurPage == nPageSave || nPageSave == 65535);

	pInfo->m_bContinuePrinting = bResult;
	pDC->RestoreDC(-1);
	m_pPrintOptions->m_bBlackWhitePrinting = bBlackWhiteSaved;
	pInfo->m_nCurPage = nPageSave;

	pInfo->m_rectDraw = rectSave;

	return bResult;
}

void CTaskTrackView::OnPrepareDC(CDC* pDC, CPrintInfo* pInfo)
{
	if(!pDC) return;
	if (!pInfo)
		return;

	if (!m_bPaginated)
	{
		int nRowCount = m_wndTrackControl.GetRows()->GetCount();
		int nSize = (int) m_aPageStart.GetSize();
		int nPage = pInfo->m_nCurPage;
		UINT nVirtualPages = (UINT) m_wndTrackControl.GetTrackPaintManager()->m_arStartCol.GetSize() - 1;
		UINT nVirPage(0);
		if (nVirtualPages > 0)
			nVirPage = 1 + m_nStartIndex;

		if (nPage == 1 && nRowCount == 0)                       //First page?
			pInfo->m_bContinuePrinting = TRUE;
		else if (nVirPage > 0 && nVirPage < nVirtualPages)      //not finished page
			pInfo->m_bContinuePrinting = TRUE;
		else if (nPage == nSize && m_aPageStart[nPage - 1] >= (UINT) nRowCount
			&& m_nStartIndex >= nVirtualPages - 1)              //Last page?
			pInfo->m_bContinuePrinting = FALSE;                 // can't paginate to that page
		else if (nPage > nSize
			&& m_nStartIndex > nVirtualPages - 1
			&& !PaginateTo(pDC, pInfo))                         //Can be last page?
			pInfo->m_bContinuePrinting = FALSE;                 // can't paginate to that page

		if (pInfo->m_nCurPage > pInfo->GetMaxPage())
			pInfo->m_bContinuePrinting = FALSE;
		//TRACE(_T("OnPrepareDC pInfo->m_nCurPage=%d\n"), pInfo->m_nCurPage);
	}
	pDC->SetMapMode(MM_ANISOTROPIC);
	pDC->SetViewportExt(pDC->GetDeviceCaps(LOGPIXELSX), pDC->GetDeviceCaps(LOGPIXELSY));
	pDC->SetWindowExt(96, 96);
	pDC->OffsetWindowOrg(0, 0);

	if (pInfo->m_bPreview) //PRINT MODE in RTL does not work!
	{
		//------------------------------------------------------------
		if (m_wndTrackControl.GetExStyle() & WS_EX_RTLREADING)
			pDC->SetTextAlign(TA_RTLREADING);

		if (m_wndTrackControl.GetExStyle() & WS_EX_LAYOUTRTL)
			//if (m_wndTrackControl.IsLayoutRTL())
				XTPDrawHelpers()->SetContextRTL(pDC, LAYOUT_RTL);
		//------------------------------------------------------------
	}
}

int CTaskTrackView::PrintFixedRows(CDC* pDC, CRect rcClient, BOOL bHeaderRows)
{
	int y = rcClient.top;

	CXTPReportRows* pRows = bHeaderRows ? m_wndTrackControl.GetHeaderRows() : m_wndTrackControl.GetFooterRows();

	for (int i = 0; i < pRows->GetCount(); ++i)
	{
		CXTPReportRow* pRow = pRows->GetAt(i);

		int nHeight = pRow->GetHeight(pDC, rcClient.Width());

		CRect rcRow(rcClient.left, y, rcClient.right, y + nHeight);

		if (rcRow.bottom > rcClient.bottom)
			break;

		PrintRow(pDC, pRow, rcRow, 0);

		y += rcRow.Height();
	}

	return y - rcClient.top; // height of all printed rows
}

void CTaskTrackView::RepositionControls()
{
	CXTPWindowRect rc(m_wndTrackControl);

	CRect rcSlider(rc.left + 240, rc.bottom, rc.left + 300, rc.bottom + GetSystemMetrics(SM_CYHSCROLL) + 5);
	CRect rcScrollBar(rcSlider.right, rc.bottom, rc.right - GetSystemMetrics(SM_CXVSCROLL), rc.bottom + GetSystemMetrics(SM_CYHSCROLL));

	ScreenToClient(&rcScrollBar);
	ScreenToClient(&rcSlider);

	m_wndSlider.MoveWindow(rcSlider);
	m_wndScrollBar.MoveWindow(rcScrollBar);

}

void CTaskTrackView::OnFileOpen() 
{
	CString strFilter = _T("XML Document (*.xml)|*.xml|All files (*.*)|*.*||");

	CFileDialog fd(TRUE, _T("xml"), NULL, OFN_FILEMUSTEXIST| OFN_HIDEREADONLY, strFilter);
	if (fd.DoModal() != IDOK)
		return;

	CXTPPropExchangeXMLNode px(TRUE, NULL, _T("TrackControl"));

	if (!px.LoadFromFile(fd.GetPathName()))
		return;

	m_wndTrackControl.DoPropExchange(&px);

	CXTPPropExchangeSection sec(px.GetSection(_T("Tracks")));
	m_wndTrackControl.GetRecords()->DoPropExchange(&sec);

	m_wndTrackControl.Populate();
}

void CTaskTrackView::OnFileSave() 
{
	CString strFilter = _T("XML Document (*.xml)|*.xml|All files (*.*)|*.*||");

	CFileDialog fd(FALSE, _T("xml"), NULL, OFN_HIDEREADONLY|OFN_OVERWRITEPROMPT, strFilter);
	if (fd.DoModal() != IDOK)
		return;


	CXTPPropExchangeXMLNode px(FALSE, 0, _T("TrackControl"));

	m_wndTrackControl.DoPropExchange(&px);

	CXTPPropExchangeSection sec(px.GetSection(_T("Tracks")));
	m_wndTrackControl.GetRecords()->DoPropExchange(&sec);


	px.SaveToFile(fd.GetPathName());
}

void CTaskTrackView::OnFilePrint()
{
	CDC dc;

	CPrintDialog* pPrntDialog = new CPrintDialog(FALSE);
	if (pPrntDialog->DoModal() != IDOK)             // Get printer settings from user
		return;

	dc.Attach(pPrntDialog->GetPrinterDC());     // attach a printer DC

	dc.m_bPrinting = TRUE;

	CString strTitle;
	strTitle.LoadString(AFX_IDS_APP_TITLE);

	if( strTitle.IsEmpty() )
	{
		CWnd *pParentWnd = GetParent();
		while (pParentWnd)
		{
			pParentWnd->GetWindowText(strTitle);
			if (strTitle.GetLength())  // can happen if it is a CView, CChildFrm has the title
				break;
			pParentWnd = pParentWnd->GetParent();
		}
	}

	DOCINFO di;                                 // Initialise print doc details
	memset(&di, 0, sizeof (DOCINFO));
	di.cbSize = sizeof (DOCINFO);
	di.lpszDocName = strTitle;

	BOOL bPrintingOK = dc.StartDoc(&di);        // Begin a new print job

	CPrintInfo Info;
	Info.m_rectDraw.SetRect(0,0, dc.GetDeviceCaps(HORZRES), dc.GetDeviceCaps(VERTRES));

	OnBeginPrinting(&dc, &Info);                // Initialise printing
	for (UINT page = Info.GetMinPage(); page <= Info.GetMaxPage() && bPrintingOK; page++)
	{
		dc.StartPage();                         // begin new page
		Info.m_nCurPage = page;
		OnPrint(&dc, &Info);                    // Print page
		bPrintingOK = (dc.EndPage() > 0);       // end page
	}
	OnEndPrinting(&dc, &Info);                  // Clean up after printing

	if (bPrintingOK)
		dc.EndDoc();                            // end a print job
	else
		dc.AbortDoc();                          // abort job.

	dc.Detach();                                // detach the printer DC
}

void CTaskTrackView::OnFilePrintSetup()
{
	DWORD dwFlags = PSD_MARGINS | PSD_INWININIINTLMEASURE;
	CXTPReportPageSetupDialog dlgPageSetup(GetPrintOptions(), dwFlags, this);

	XTPGetPrinterDeviceDefaults(dlgPageSetup.m_psd.hDevMode, dlgPageSetup.m_psd.hDevNames);

	int nDlgRes = (int) dlgPageSetup.DoModal();

	if (nDlgRes == IDOK)
		AfxGetApp()->SelectPrinter(dlgPageSetup.m_psd.hDevNames, dlgPageSetup.m_psd.hDevMode, FALSE);
}

void CTaskTrackView::OnEditUndo()
{
	m_wndTrackControl.GetUndoManager()->Undo();
}

void CTaskTrackView::OnUpdateEditUndo(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(m_wndTrackControl.GetUndoManager()->CanUndo());
}

void CTaskTrackView::OnEditRedo()
{
	m_wndTrackControl.GetUndoManager()->Redo();
}

void CTaskTrackView::OnUpdateEditRedo(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(m_wndTrackControl.GetUndoManager()->CanRedo());
}

void CTaskTrackView::OnEditCopy() 
{
	m_wndTrackControl.Copy();
}

void CTaskTrackView::OnUpdateEditCopy(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(m_wndTrackControl.CanCopy());
}

void CTaskTrackView::OnEditCut() 
{
	m_wndTrackControl.Cut();
}

void CTaskTrackView::OnUpdateEditCut(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(m_wndTrackControl.CanCut());
}

void CTaskTrackView::OnEditPaste() 
{
	m_wndTrackControl.Paste();
}

void CTaskTrackView::OnUpdateEditPaste(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(m_wndTrackControl.CanPaste());
}

void CTaskTrackView::OnToolsImport()
{
	TCHAR szFilter[] = _T("Excel 2007|*.xlsx|Excel 2003|*.xls|CSV文件|*.csv|所有文件|*.*||");
	CFileDialog FileDlg(TRUE, _T("xlsx"), NULL, 0, szFilter, this);
	if(IDOK == FileDlg.DoModal())
	{
		CXTPExcelUtil excel;
		excel.InitExcel();

		CString strFileName = FileDlg.GetFileName();
		CString strFilePath = FileDlg.GetPathName();
		strFilePath = strFilePath.Mid(0, strFilePath.ReverseFind('\\'));

		excel.OpenExcel(strFileName,strFilePath);
		excel.LoadSheet(1);
		long rows = excel.GetRowCount();
		int cols = excel.GetColCount();

		m_vecRecord.clear();
		g_tBegin = excel.GetCellDateTime(1,2);
		g_tEnd = excel.GetCellDateTime(1,3);
		m_nTimeStep = excel.GetCellDouble(1,4);
		m_bTimeStepAuto = excel.GetCellBool(1,5);
		m_bClassicStyle = excel.GetCellBool(1,6);

		CXTPReportColumns* pColums = m_wndTrackControl.GetColumns();
		pColums->Clear();
		for(int i=0;i<cols;i++)
		{
			CXTPReportColumn* pColum = new CXTPReportColumn(i,excel.GetCellString(3,i+1),excel.GetColumnWidth(i+1));
			pColums->Add(pColum);
		}
		pColums->Add(new CXTPReportColumn(cols,_T(""),0));

		CTrackControlPaintManager* pTpm = (CTrackControlPaintManager*)m_wndTrackControl.GetPaintManager();
		pTpm->m_nTimeLineStep = m_nTimeStep;
		pTpm->m_bTimeLineStepAuto = m_bTimeStepAuto;
		pTpm->SetTimeLineRange(g_tBegin, g_tEnd);

		for(long i=4; i<=rows;i++)
		{
			TASKTRACKITEM tti(excel.GetCellString(i,1),
						  excel.GetCellString(i,2),
						  excel.GetCellDateTime(i,cols-2),
						  excel.GetCellDateTime(i,cols-1),
						  excel.GetCellDouble(i,cols));
			for(int j=3;j<cols-2;j++) tti.add(excel.GetCellString(i,j));
			m_vecRecord.push_back(tti);
		}

		excel.CloseExcel();
		excel.ReleaseExcel();

		msgInf(strFileName + " 文件导入成功!");
	}

	for (int i = 0; i < (int)m_vecRecord.size(); i++) 
		m_wndTrackControl.AddRecord(new CTaskTrackRecord(
		m_vecRecord[i].code,
		m_vecRecord[i].prjs,
		m_vecRecord[i].bct,
		m_vecRecord[i].ect,
		m_vecRecord[i].clr,
		m_vecRecord[i].key
		));

	m_wndTrackControl.Populate();
}

void CTaskTrackView::OnToolsExport()
{
	TCHAR szFilter[] = _T("Excel 2007|*.xlsx|Excel 2003|*.xls|CSV文件|*.csv|所有文件|*.*||");
	CFileDialog FileDlg(FALSE, _T("xlsx"), NULL, 0, szFilter, this);
	if(IDOK == FileDlg.DoModal())
	{
		CXTPExcelUtil excel;
		excel.InitExcel();

		CString strFileName = FileDlg.GetFileName();
		CString strFilePath = FileDlg.GetPathName();
		strFilePath = strFilePath.Mid(0, strFilePath.ReverseFind('\\'));

		excel.CreateExcel(strFileName,strFilePath);
		excel.OpenExcel(strFileName,strFilePath);
		excel.LoadSheet(1);

		CXTPReportSelectedRows* pRows = m_wndTrackControl.GetSelectedRows();
		if(pRows != NULL && pRows->GetCount() > 1)
		{
			long rows = pRows->GetCount();
			CXTPReportColumns* pColums = m_wndTrackControl.GetColumns();
			if(pColums != NULL)
			{
				int cols = pColums->GetCount();
				for(int i=0;i<cols;i++)
					excel.SetCell(pColums->GetAt(i)->GetCaption(),1,i+1);

				for(long i=0; i<rows; i++)
				{
					CXTPReportRow* pRow = pRows->GetAt(i);
					if(pRow != NULL)
					{
						CXTPReportRecord* pRecord = pRow->GetRecord();
						if(pRecord != NULL)
						{
							for(int j=0; j<cols; j++)
								excel.SetCell(pRecord->GetItem(j)->GetCaption(),i+2,j+1);
						}
					}
				}
			}
		}
		else
		{
			CXTPReportRecords* pRecords = m_wndTrackControl.GetRecords();
			if(pRecords != NULL)
			{
				long rows = pRecords->GetCount();
				CXTPReportColumns* pColums = m_wndTrackControl.GetColumns();
				if(pColums != NULL)
				{
					int cols = pColums->GetCount();
					for(int i=0;i<cols;i++)
						excel.SetCell(pColums->GetAt(i)->GetCaption(),1,i+1);

					for(long i=0; i<rows; i++)
					{
						CXTPReportRecord* pRecord = pRecords->GetAt(i);
						if(pRecord != NULL)
						{
							for(int j=0; j<cols; j++)
								excel.SetCell(pRecord->GetItem(j)->GetCaption(),i+2,j+1);
						}
					}
				}
			}
		}

		excel.Save();
		excel.CloseExcel();
		excel.ReleaseExcel();

		msgInf(FileDlg.GetFileName() + " 文件导出成功!");
	}
}

void CTaskTrackView::OnDestroy() 
{
	CXTPResizeFormView::OnDestroy();

	// Save window placement
	SavePlacement(_T("CTaskTrackView"));

}

void CTaskTrackView::OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
{
	CXTPResizeFormView::OnHScroll(nSBCode, nPos, pScrollBar);

	if (pScrollBar == (CScrollBar*)&m_wndSlider)
	{
		if (nSBCode != SB_THUMBTRACK)
			nPos = m_wndSlider.GetPos();
		{
			int nCenter = (m_wndTrackControl.GetViewPortMax() + m_wndTrackControl.GetViewPortMin()) / 2;

			int nDelta = (m_wndTrackControl.GetTimeLineMax() - m_wndTrackControl.GetTimeLineMin()) * (100 - nPos) / 100;
			if (nDelta == 0)
				nDelta = 1;

			int nViewPortMin = nCenter - nDelta / 2;
			if (nViewPortMin < m_wndTrackControl.GetTimeLineMin())
				nViewPortMin = m_wndTrackControl.GetTimeLineMin();

			if (nViewPortMin + nDelta > m_wndTrackControl.GetTimeLineMax())
				nViewPortMin = m_wndTrackControl.GetTimeLineMax() - nDelta;

			int nViewPortMax = nViewPortMin + nDelta;

			m_wndTrackControl.SetViewPort(nViewPortMin, nViewPortMax);
			m_wndTrackControl.RedrawControl();

			OnTrackSliderChanged(0, 0);
		}

		return;
	}

	if (pScrollBar == &m_wndScrollBar)
	{

		int nCurPos = m_wndTrackControl.GetViewPortMin();
		int nPage = m_wndTrackControl.GetViewPortMax() - m_wndTrackControl.GetViewPortMin();

		// decide what to do for each diffrent scroll event
		switch (nSBCode)
		{
		case SB_TOP:
			nCurPos = 0;
			break;
		case SB_BOTTOM:
			nCurPos = pScrollBar->GetScrollLimit();
			break;
		case SB_LINEUP:
			nCurPos = max(nCurPos - 1, 0);
			break;
		case SB_PAGEUP:
			nCurPos = max(nCurPos - nPage, 0);
			break;
		case SB_LINEDOWN:
			nCurPos = min(nCurPos + 1, pScrollBar->GetScrollLimit());
			break;
		case SB_PAGEDOWN:
			nCurPos = min(nCurPos + nPage, pScrollBar->GetScrollLimit());
			break;
		case SB_THUMBTRACK:
		case SB_THUMBPOSITION:
			{
				SCROLLINFO si;
				ZeroMemory(&si, sizeof(SCROLLINFO));
				si.cbSize = sizeof(SCROLLINFO);
				si.fMask = SIF_TRACKPOS;

				if (!pScrollBar->GetScrollInfo(&si))
					return;
				nCurPos = si.nTrackPos;
			}
			break;
		}


		m_wndTrackControl.SetViewPort(nCurPos, nCurPos + nPage);
		m_wndTrackControl.RedrawControl();
		OnTrackSliderChanged(0, 0);
	}
}

void CTaskTrackView::OnUseTimeOffsetMode()
{
	CDlgTimeLineProperties dlg;

	dlg.m_nMin = m_wndTrackControl.GetTimeLineMin();
	dlg.m_nMax = m_wndTrackControl.GetTimeLineMax();

	if (dlg.DoModal() == IDOK)
	{
		m_wndTrackControl.SetTimeLineRange(dlg.m_nMin, dlg.m_nMax);
	}

	if (m_wndTrackControl.GetViewPortMin() < m_wndTrackControl.GetTimeLineMin() || m_wndTrackControl.GetViewPortMax() > m_wndTrackControl.GetTimeLineMax())
	{
		m_wndTrackControl.SetViewPort(m_wndTrackControl.GetTimeLineMin(), m_wndTrackControl.GetTimeLineMax());
	}


	m_wndTrackControl.RedrawControl();
}

CScrollBar* CTaskTrackView::GetScrollBarCtrl(int nBar) const
{
	CScrollBar* pSB =  CXTPResizeFormView::GetScrollBarCtrl(nBar);
	return pSB;
}

void CTaskTrackView::OnViewGroupbox() 
{
	m_wndTrackControl.ShowGroupBy(!m_wndTrackControl.IsGroupByVisible());

}

void CTaskTrackView::OnUpdateViewGroupbox(CCmdUI* pCmdUI) 
{
	pCmdUI->SetCheck(m_wndTrackControl.IsGroupByVisible() ? 1 : 0);

}

void CTaskTrackView::OnViewClassicStyle() 
{
	m_bClassicStyle = !m_bClassicStyle;

	if (m_bClassicStyle)
		m_wndTrackControl.SetPaintManager(new CXTPTrackPaintManager());
	else
		m_wndTrackControl.SetPaintManager(new CTrackControlPaintManager());

	m_wndTrackControl.SetGridStyle(0, xtpReportGridSolid);
	m_wndTrackControl.SetGridStyle(1, xtpReportGridSolid);

}

void CTaskTrackView::OnFlexibleDrag() 
{
	m_wndTrackControl.m_bFlexibleDrag = !m_wndTrackControl.m_bFlexibleDrag;	
}

void CTaskTrackView::OnUpdateViewClassicStyle(CCmdUI* pCmdUI) 
{
	pCmdUI->SetCheck(m_bClassicStyle);

}

void CTaskTrackView::OnUpdateFlexibleDrag(CCmdUI* pCmdUI) 
{
	pCmdUI->SetCheck(m_wndTrackControl.m_bFlexibleDrag);
}

void CTaskTrackView::OnSnapToBlocks() 
{
	m_wndTrackControl.m_bSnapToBlocks ^= 1;

}

void CTaskTrackView::OnUpdateSnapToBlocks(CCmdUI* pCmdUI) 
{
	pCmdUI->SetCheck(m_wndTrackControl.m_bSnapToBlocks ? 1 : 0);	

}

void CTaskTrackView::OnSnapToMarkers() 
{
	m_wndTrackControl.m_bSnapToMarkers ^= 1;

}

void CTaskTrackView::OnUpdateSnapToMarkers(CCmdUI* pCmdUI) 
{
	pCmdUI->SetCheck(m_wndTrackControl.m_bSnapToMarkers ? 1 : 0);	
}

void CTaskTrackView::OnAllowblockmove() 
{
	m_wndTrackControl.m_bAllowBlockMove ^= 1;

}

void CTaskTrackView::OnUpdateAllowblockmove(CCmdUI* pCmdUI) 
{
	pCmdUI->SetCheck(m_wndTrackControl.m_bAllowBlockMove);

}

void CTaskTrackView::OnAllowblockscale() 
{
	m_wndTrackControl.m_bAllowBlockScale ^= 1;

}

void CTaskTrackView::OnUpdateAllowblockscale(CCmdUI* pCmdUI) 
{
	pCmdUI->SetCheck(m_wndTrackControl.m_bAllowBlockScale);

}

void CTaskTrackView::OnScaleOnResize() 
{
	m_wndTrackControl.m_bScaleOnResize ^= 1;

}

void CTaskTrackView::OnUpdateScaleOnResize(CCmdUI* pCmdUI) 
{
	pCmdUI->SetCheck(m_wndTrackControl.m_bScaleOnResize);	
}

void CTaskTrackView::OnAllowblockRemove() 
{
	m_wndTrackControl.m_bAllowBlockRemove ^= 1;

}

void CTaskTrackView::OnUpdateAllowblockRemove(CCmdUI* pCmdUI) 
{
	pCmdUI->SetCheck(m_wndTrackControl.m_bAllowBlockRemove);
}

void CTaskTrackView::OnAllowRowResize() 
{
	m_wndTrackControl.m_bFreeHeightMode = !m_wndTrackControl.m_bFreeHeightMode;

}

void CTaskTrackView::OnUpdateAllowRowResize(CCmdUI* pCmdUI) 
{
	pCmdUI->SetCheck(m_wndTrackControl.m_bFreeHeightMode ? 1 : 0);

}

void CTaskTrackView::OnShowWorkarea() 
{
	m_wndTrackControl.m_bShowWorkArea = !m_wndTrackControl.m_bShowWorkArea;
	m_wndTrackControl.RedrawControl();
}

void CTaskTrackView::OnUpdateShowWorkarea(CCmdUI* pCmdUI) 
{
	pCmdUI->SetCheck(m_wndTrackControl.m_bShowWorkArea ? 1 : 0);
}

void CTaskTrackView::OnTrackSliderChanged(NMHDR * /*pNotifyStruct*/, LRESULT * /*result*/)
{
	m_wndScrollBar.SetScrollPos(0, 100);
	m_wndSlider.SetRange(0, 100);
	m_wndSlider.SetPos(100 - (m_wndTrackControl.GetViewPortMax() - m_wndTrackControl.GetViewPortMin()) * 100 / (m_wndTrackControl.GetTimeLineMax() - m_wndTrackControl.GetTimeLineMin()));


	SCROLLINFO si;
	si.fMask = SIF_ALL;
	si.nPos = m_wndTrackControl.GetViewPortMin();
	si.nMin = m_wndTrackControl.GetTimeLineMin();
	si.nMax = m_wndTrackControl.GetTimeLineMax() - 1;
	si.nPage = m_wndTrackControl.GetViewPortMax() - m_wndTrackControl.GetViewPortMin();

	m_wndScrollBar.SetScrollInfo(&si);
}

void CTaskTrackView::OnValueChanged(NMHDR * pNotifyStruct, LRESULT * /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pItemNotify = (XTP_NM_REPORTRECORDITEM*) pNotifyStruct;

	CXTPReportRecord* pRcd= pItemNotify->pRow->GetRecord();
	CXTPReportRecordItemText* pItemName = (CXTPReportRecordItemText*)pRcd->GetItem(1);
	CXTPReportRecordItemDateTime* pItemBegin = (CXTPReportRecordItemDateTime*)pRcd->GetItem(2);
	CXTPReportRecordItemDateTime* pItemEnd = (CXTPReportRecordItemDateTime*)pRcd->GetItem(3);
	CXTPReportRecordItemNumber* pItemLength = (CXTPReportRecordItemNumber*)pRcd->GetItem(4);
	CXTPTrackControlItem* pItemBlock = (CXTPTrackControlItem*)pRcd->GetItem(5);
	CXTPTrackBlock* pBlock = pItemBlock->GetBlock(0);
	int d = (pItemEnd->GetValue()-pItemBegin->GetValue()).GetDays();
	pItemLength->SetValue(d);
	SYSTEMTIME st;
	int d1 = pBlock->GetPosition();
	if(g_tBegin.GetAsSystemTime(st))
		d1 = (pItemBegin->GetValue()-COleDateTime(st)).GetDays();
	else
		d1 = (pItemBegin->GetValue()-COleDateTime(g_tBegin.GetYear(),g_tBegin.GetMonth(),g_tBegin.GetDay(),g_tBegin.GetHour(),g_tBegin.GetMinute(),g_tBegin.GetSecond())).GetDays();
	pBlock->SetPosition(d1);
	pBlock->SetLength(d);
	CString strToolTip;
	strToolTip.Format(_T("%s: %s-%s,工期 %d 天"), pItemName->GetValue(),pItemBegin->GetValue().Format(_T("%Y-%m-%d")),pItemEnd->GetValue().Format(_T("%Y-%m-%d")),d);
	pBlock->SetTooltip(strToolTip);
	pBlock->SetDescriptionText(strToolTip);
}

void CTaskTrackView::OnRClick(NMHDR * pNotifyStruct, LRESULT * /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pNMRCLick = (XTP_NM_REPORTRECORDITEM*)pNotifyStruct;
	CPoint ptScreen = pNMRCLick->pt;

	CPoint point = ptScreen;
	m_wndTrackControl.ScreenToClient(&point);

	CXTPTrackControlItem* pItem = DYNAMIC_DOWNCAST(CXTPTrackControlItem, pNMRCLick->pItem);

	if (pItem)
	{
		CXTPTrackBlock* pBlock = pItem->HitTest(point);

		if (pBlock)
		{
			if (!pBlock->IsSelected())
			{
				m_wndTrackControl.GetSelectedBlocks()->RemoveAll();
				pBlock->Select();

				m_wndTrackControl.RedrawControl();
				m_wndTrackControl.UpdateWindow();
			}

			CMenu menu;
			menu.LoadMenu(IDR_CONTENT_TASKTRACK);

			CMenu* pMenuPopup = menu.GetSubMenu(2);

			if (pItem->IsLocked()) pMenuPopup->CheckMenuItem(ID_BLOCK_LOCKTRACK, MF_CHECKED | MF_BYCOMMAND);
			if (pBlock->IsLocked()) pMenuPopup->CheckMenuItem(ID_BLOCK_LOCKBLOCK, MF_CHECKED | MF_BYCOMMAND);


			int nResult = TrackPopupMenu(pMenuPopup->GetSafeHmenu(), TPM_RETURNCMD, ptScreen.x, ptScreen.y, 0, m_hWnd, 0);

			switch (nResult)
			{
			case ID_BLOCK_LOCKBLOCK:
				{
					pBlock->SetLocked(!pBlock->IsLocked());
					m_wndTrackControl.RedrawControl();
				}
				break;
			case ID_BLOCK_REMOVEBLOCK:
				{
					CXTPTrackSelectedBlocks* pSelected = m_wndTrackControl.GetSelectedBlocks();

					CString strMessage;
					strMessage.Format(_T("Are you sure you want to remove %d block(s)"), (int)pSelected->GetCount());

					if (AfxMessageBox(strMessage, MB_YESNO) == IDYES)				
					{
						m_wndTrackControl.GetUndoManager()->StartGroup();

						for (int i = 0; i < pSelected->GetCount(); i++)
						{
							pSelected->GetAt(i)->Remove();
						}
						m_wndTrackControl.GetUndoManager()->EndGroup();

						pSelected->RemoveAll();

						m_wndTrackControl.RedrawControl();
					}
				}
				break;
			case ID_BLOCK_LOCKTRACK:
				{
					pItem->SetLocked(!pItem->IsLocked());
					m_wndTrackControl.GetSelectedBlocks()->RemoveAll();
					m_wndTrackControl.RedrawControl();
				}
				break;
			case ID_BLOCK_KEYROAD:
				{
					pBlock->SetColor(clrTable[1]);
					m_wndTrackControl.RedrawControl();
				}
				break;
			case ID_BLOCK_WORK_KEY:
				{
					pBlock->SetColor(clrTable[1]);
					m_wndTrackControl.RedrawControl();
				}
				break;
			case ID_BLOCK_WORK_COMMON:
				{
					pBlock->SetColor(clrTable[0]);
					m_wndTrackControl.RedrawControl();
				}
				break;
			case ID_BLOCK_WORK_VIRTUAL:
				{
					pBlock->SetColor(clrTable[3]);
					m_wndTrackControl.RedrawControl();
				}
				break;
			case ID_BLOCK_WORK_FREE:
				{
					pBlock->SetColor(clrTable[2]);
					m_wndTrackControl.RedrawControl();
				}
				break;
			case ID_BLOCK_WORK_OTHER:
				{
					pBlock->SetColor(clrTable[7]);
					m_wndTrackControl.RedrawControl();
				}
				break;
			}
		}
		else
		{
			CMenu menu;
			menu.LoadMenu(IDR_CONTENT_TASKTRACK);

			CMenu* pMenuPopup = menu.GetSubMenu(3);
			if (pItem->IsLocked()) pMenuPopup->CheckMenuItem(ID_BLOCK_LOCKTRACK, MF_CHECKED | MF_BYCOMMAND);

			int nResult = TrackPopupMenu(pMenuPopup->GetSafeHmenu(), TPM_RETURNCMD, ptScreen.x, ptScreen.y, 0, m_hWnd, 0);

			switch (nResult)
			{
			case ID_BLOCK_ADDBLOCK:
				{
					CXTPTrackBlock* pBlock = new CXTPTrackBlock();
					pBlock->SetPosition(m_wndTrackControl.TrackToPosition(point.x));
					pBlock->SetLength(50);
					pBlock->SetColor(clrTable[(rand() % 3) + 5]);

					pItem->Add(pBlock);
					if (!m_wndTrackControl.m_bFlexibleDrag)
						pItem->AdjustBlockPosition(pBlock);

					pItem->RecalcLayout();

					m_wndTrackControl.RedrawControl();
				}
				break;
			case ID_BLOCK_LOCKTRACK:
				{
					pItem->SetLocked(!pItem->IsLocked());
					m_wndTrackControl.GetSelectedBlocks()->RemoveAll();
					m_wndTrackControl.RedrawControl();
				}
				break;
			case ID_BLOCK_CLEAR:
				{
					m_wndTrackControl.GetRows()->Clear();
					m_wndTrackControl.RedrawControl();
				}
				break;
			}
		}
	}
}

void CTaskTrackView::OnDblClick(NMHDR * pNotifyStruct, LRESULT * /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pNMRCLick = (XTP_NM_REPORTRECORDITEM*)pNotifyStruct;
	CPoint point = pNMRCLick->pt;

	int nMarker = m_wndTrackControl.GetMarkers()->HitTest(point);

	if (nMarker != -1)
	{
		CXTPTrackMarker* pMarker = m_wndTrackControl.GetMarkers()->GetAt(nMarker);

		CDlgMarkerProperties dp;
		dp.m_strCaption = pMarker->GetCaption();
		dp.m_nPosition = pMarker->GetPosition();

		if (dp.DoModal() == IDOK)
		{
			pMarker->SetCaption(dp.m_strCaption);
			pMarker->SetPosition(dp.m_nPosition);		
		}	
	}
}

void CTaskTrackView::OnHeaderRClick(NMHDR * pNotifyStruct, LRESULT * /*result*/)
{
	XTP_NM_REPORTRECORDITEM* pNMRCLick = (XTP_NM_REPORTRECORDITEM*)pNotifyStruct;
	CPoint ptScreen = pNMRCLick->pt;

	CPoint point = ptScreen;
	m_wndTrackControl.ScreenToClient(&point);

	if (!m_wndTrackControl.GetTrackColumn()->GetRect().PtInRect(point))
		return;


	int nMarker = m_wndTrackControl.GetMarkers()->HitTest(point);

	CMenu menu;
	menu.LoadMenu(IDR_CONTENT_TASKTRACK);


	if (nMarker != -1)
	{
		int nResult = TrackPopupMenu(menu.GetSubMenu(1)->GetSafeHmenu(), TPM_RETURNCMD, ptScreen.x, ptScreen.y, 0, m_hWnd, 0);

		if (nResult == ID_HEADER_REMOVEMARKER)
		{
			m_wndTrackControl.GetMarkers()->RemoveAt(nMarker);
		}
		if (nResult == ID_HEADER_DELETEALLMARKERS)
		{
			m_wndTrackControl.GetMarkers()->RemoveAll();
		}
	}
	else
	{
		int nResult = TrackPopupMenu(menu.GetSubMenu(0)->GetSafeHmenu(), TPM_RETURNCMD, ptScreen.x, ptScreen.y, 0, m_hWnd, 0);

		if (nResult == ID_HEADER_ADDMARKER)
		{
			CString strCaption;
			strCaption.Format(_T("%d"), 1 + m_wndTrackControl.GetMarkers()->GetCount());

			m_wndTrackControl.GetMarkers()->Add(m_wndTrackControl.TrackToPosition(point.x), strCaption);
		}

	}


}

void CTaskTrackView::OnTrackTimeLineChanged(NMHDR* /*pNotifyStruct*/, LRESULT * /*result*/)
{
	TRACE(_T("TimeLine Changed\n"));
}

void CTaskTrackView::OnTrackMarkerChanged(NMHDR* /*pNotifyStruct*/, LRESULT * /*result*/)
{
	TRACE(_T("Marker Changed\n"));
}

void CTaskTrackView::OnTrackBlockChanged(NMHDR* pNotifyStruct, LRESULT * /*result*/)
{
	XTP_NM_TRACKCONTROL* pTrackCtrl = (XTP_NM_TRACKCONTROL*) pNotifyStruct;
	CXTPTrackBlock* pBlock = pTrackCtrl->pBlock;
	CXTPTrackControlItem* pItemBlock = pBlock->GetItem();
	CXTPReportRecord* pRcd= pItemBlock->GetRecord();
	CXTPReportRecordItemDateTime* pItemBegin = (CXTPReportRecordItemDateTime*)pRcd->GetItem(2);
	CXTPReportRecordItemDateTime* pItemEnd = (CXTPReportRecordItemDateTime*)pRcd->GetItem(3);
	CXTPReportRecordItemNumber* pItemLength = (CXTPReportRecordItemNumber*)pRcd->GetItem(4);
	
	int len = pBlock->GetLength();
	int pos = pBlock->GetPosition();

	pItemLength->SetValue(len);
	SYSTEMTIME st;
	if(g_tBegin.GetAsSystemTime(st))
	{
		pItemBegin->SetValue(COleDateTime(st)+COleDateTimeSpan(pos));
		pItemEnd->SetValue(COleDateTime(st)+COleDateTimeSpan(pos+len));
	}
	else
	{
		pItemBegin->SetValue(COleDateTime(g_tBegin.GetYear(),g_tBegin.GetMonth(),g_tBegin.GetDay(),g_tBegin.GetHour(),g_tBegin.GetMinute(),g_tBegin.GetSecond())+COleDateTimeSpan(pos));
		pItemEnd->SetValue(COleDateTime(g_tBegin.GetYear(),g_tBegin.GetMonth(),g_tBegin.GetDay(),g_tBegin.GetHour(),g_tBegin.GetMinute(),g_tBegin.GetSecond())+COleDateTimeSpan(pos+len));
	}
}

void CTaskTrackView::OnTrackSelectedBlocksChanged(NMHDR* /*pNotifyStruct*/, LRESULT * /*result*/)
{
	TRACE(_T("Selected Blocks Changed\n"));
}