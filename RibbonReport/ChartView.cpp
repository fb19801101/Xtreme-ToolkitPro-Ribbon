// ChartView.cpp : implementation file
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "MainFrm.h"

#include "ChartView.h"


#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


/////////////////////////////////////////////////////////////////////////////
// CResizeGroupBox

CResizeGroupBox::CResizeGroupBox()
{
}

CResizeGroupBox::~CResizeGroupBox()
{
}

IMPLEMENT_DYNAMIC(CResizeGroupBox, CXTPButton)

BEGIN_MESSAGE_MAP(CResizeGroupBox, CXTPButton)
	//{{AFX_MSG_MAP(CResizeGroupBox)
	ON_WM_ERASEBKGND()
	ON_WM_PAINT()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CResizeGroupBox message handlers

void CResizeGroupBox::Exclude(CDC* pDC, CRect& rcClient)
{
	// get a pointer to the parent.
	CWnd* pWndParent = GetParent();
	if (!pWndParent)
		return;

	// get a pointer to the parents first child.
	CWnd* pWnd = pWndParent->GetWindow(GW_CHILD);
	if (pWnd == NULL)
		return;

	// iterate thru all children and exclude those children that
	// are located inside the group box.
	CWnd* pChildWnd = pWnd->GetWindow(GW_HWNDFIRST);
	while (pChildWnd != NULL)
	{
		// make sure we do not exclude ourself
		if (pChildWnd != this && pChildWnd->IsWindowVisible())
		{
			CRect rc;
			pChildWnd->GetWindowRect(&rc);
			ScreenToClient(&rc);

			// if the parent's child is located in our group box, exclude
			// it from painting.
			if (rcClient.PtInRect(rc.TopLeft()) ||
				rcClient.PtInRect(rc.BottomRight()))
			{
				pDC->ExcludeClipRect(&rc);
			}
		}

		pChildWnd = pChildWnd->GetWindow(GW_HWNDNEXT);
	}
}

BOOL CResizeGroupBox::OnEraseBkgnd(CDC* /*pDC*/)
{
	return TRUE;
}

void CResizeGroupBox::OnPaint()
	{
		CPaintDC dc(this);

		// get the client area size.
		CRect rcClient;
		GetClientRect(&rcClient);

		// exclude controls that we "group"
		Exclude(&dc, rcClient);

		// Paint to a memory device context to help
		// eliminate screen flicker.
		CXTPBufferDC memDC(dc);

		HBRUSH hBrush = (HBRUSH)GetParent()->SendMessage(WM_CTLCOLORBTN, (WPARAM)memDC.GetSafeHdc(), (LRESULT)m_hWnd);
		if (hBrush)
		{
			::FillRect(memDC, rcClient, hBrush);
		}
		else
		{
			memDC.FillSolidRect(rcClient, GetSysColor(COLOR_3DFACE));
		}

		OnDraw(&memDC);
	}

/////////////////////////////////////////////////////////////////////////////
// CChartView

LPCTSTR lpszChartStyles = _T("Multiple Diagrams;Chart From File;Bar;StackedBar;SideStackedBar;Scatter;Bubble;Line;StepLine;FastLine;Pie;Pie3D;");
LPCTSTR lpszPalettes = _T("Victorian;Vibrant Pastel;Vibrant;Tropical;Summer;Spring Time;Rainbow;Purple;Primary Colors;Postmodern;Photodesign;Pastel;Office;Orange Green;Nature;Natural;Impresionism;Illustration;Harvest;Green Brown;Green Blue;Green;Gray;Four Color;Fire;Earth Tone;Danville;Caribbean;Cappuccino;Blue Gray;Blue;");
LPCTSTR lpszAppearances = _T("Nature;Gray;Black;");

IMPLEMENT_DYNCREATE(CChartView, CFormView)

CChartView::CChartView() : CFormView(CChartView::IDD)
{
	//{{AFX_DATA_INIT(CChartView)
	//m_hBrush.CreateSolidBrush(RGB(227,239,255));
	m_hBrush.CreateSolidBrush(RGB(238,238,238));

	m_nTimer = 0;
	m_nChartStyle = ID_CHART_STYLE_LINE;

	CreateArray(m_arrChartStyle, lpszChartStyles);
	CreateArray(m_arrPalette, lpszPalettes);
	CreateArray(m_arrAppearance, lpszAppearances);
}

CChartView::~CChartView()
{
} 

void CChartView::DoDataExchange(CDataExchange* pDX)
{
	CFormView::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CChartView)
	DDX_Control(pDX, IDC_CHART_CHARTCONTROL, m_wndChartControl);
	DDX_Control(pDX, IDC_CHART_CB_CHART_STYLE, m_wndChartStyle);
	DDX_Control(pDX, IDC_CHART_CB_APPEARANCES, m_wndAppearance);
	DDX_Control(pDX, IDC_CHART_CB_PALETTES, m_wndPalette);
	DDX_Control(pDX, IDC_CHART_BN_CHART_STYLE, m_wndChartStyle_Btn);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CChartView, CFormView)
	//{{AFX_MSG_MAP(CChartView)
	ON_CBN_SELCHANGE(IDC_CHART_CB_CHART_STYLE, OnCbnSelchangeComboChartStyle)
	ON_CBN_SELCHANGE(IDC_CHART_CB_APPEARANCES, OnCbnSelchangeComboAppearance)
	ON_CBN_SELCHANGE(IDC_CHART_CB_PALETTES, OnCbnSelchangeComboPalette)
	ON_CONTROL(BN_CLICKED, IDC_CHART_BN_CHART_STYLE, OnBtnClickedChartStyle)
	ON_CONTROL(CBN_DROPDOWN, IDC_CHART_BN_CHART_STYLE, OnBtnDropDownChartStyle)

	//}}AFX_MSG_MAP
	ON_COMMAND(ID_FILE_OPEN, OnFileOpen)
	ON_COMMAND(ID_FILE_SAVE, OnFileSave)
	ON_COMMAND(ID_FILE_PRINT, CFormView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, CFormView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, CFormView::OnFilePrintPreview)

	ON_WM_TIMER()
	ON_WM_DESTROY()
	ON_WM_SIZE()
END_MESSAGE_MAP()

#ifdef _DEBUG
void CChartView::AssertValid() const
{
	CFormView::AssertValid();
}

void CChartView::Dump(CDumpContext& dc) const
{
	CFormView::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CChartView message handlers


BOOL CChartView::PreCreateWindow(CREATESTRUCT& cs) 
{
	if (!CFormView::PreCreateWindow(cs))
		return FALSE;

	cs.dwExStyle &= ~WS_EX_CLIENTEDGE;

	return TRUE;
}

void CChartView::OnInitialUpdate() 
{
	CFormView::OnInitialUpdate();

	ModifyStyle(0, WS_CLIPCHILDREN | WS_CLIPSIBLINGS);

	m_wndGroupBoxLabels.SubclassDlgItem(IDC_CHART_GP_LABELS, this);	
	//m_wndGroupBoxLabels.SetTheme(xtpControlThemeResource);

	m_wndChartStyle_Btn.SetPushButtonStyle(xtpButtonSplitDropDown);
	//m_wndChartStyle_Btn.SetTheme(xtpControlThemeResource);

	CXTPWindowRect rc(m_wndChartControl);
	ScreenToClient(rc);
	m_nTopGap = rc.top;
	m_nLeftGap = rc.left;

	for (int i = 0; i < m_arrChartStyle.GetSize(); i++)
		m_wndChartStyle.AddString(m_arrChartStyle[i]);
	m_wndChartStyle.SetCurSel(7);
	//m_wndChartStyle.SetTheme(xtpControlThemeResource);

	for (int i = 0; i < m_arrAppearance.GetSize(); i++)
		m_wndAppearance.AddString(m_arrAppearance[i]);
	m_wndAppearance.SetCurSel(0);
	//m_wndAppearance.SetTheme(xtpControlThemeResource);

	for (int i = 0; i < m_arrPalette.GetSize(); i++)
		m_wndPalette.AddString(m_arrPalette[i]);
	m_wndPalette.SetCurSel(0);
	//m_wndPalette.SetTheme(xtpControlThemeResource);

	UpdateData(FALSE);
	CreateChart();
}

void CChartView::OnFileOpen() 
{
	CString strFilter = _T("XML Document (*.xml)|*.xml|All files (*.*)|*.*||");

	CFileDialog fd(TRUE, _T("xml"), NULL, OFN_FILEMUSTEXIST| OFN_HIDEREADONLY, strFilter);
	if (fd.DoModal() != IDOK)
		return;

	CXTPPropExchangeXMLNode px(TRUE, NULL, _T("ChartControl"));

	if (!px.LoadFromFile(fd.GetPathName()))
		return;

	m_wndChartControl.GetContent()->DoPropExchange(&px);
}

void CChartView::OnFileSave() 
{
	CString strFilter = _T("XML Document (*.xml)|*.xml|All files (*.*)|*.*||");

	CFileDialog fd(FALSE, _T("xml"), NULL, OFN_HIDEREADONLY|OFN_OVERWRITEPROMPT, strFilter);
	if (fd.DoModal() != IDOK)
		return;

	CXTPPropExchangeXMLNode px(FALSE, 0, _T("ChartControl"));
	m_wndChartControl.GetContent()->DoPropExchange(&px);

	px.SaveToFile(fd.GetPathName());

	msgInf(_T("数据保存成功！"));
}


/////////////////////////////////////////////////////////////////////////////
// CChartView printing

void CChartView::OnPrint(CDC* pDC, CPrintInfo* pInfo)
{
	m_wndChartControl.PrintToDC(pDC->m_hDC, pInfo->m_rectDraw);
}

BOOL CChartView::OnPreparePrinting(CPrintInfo* pInfo)
{
	pInfo->m_nNumPreviewPages = 1;
	pInfo->SetMinPage(1);
	pInfo->SetMaxPage(1);

	// default preparation
	return DoPreparePrinting(pInfo);
}

void CChartView::OnPrepareDC(CDC* pDC, CPrintInfo* pInfo)
{
	if (!pDC || !pInfo)
		return;

	pDC->SetMapMode(MM_ANISOTROPIC);

	pDC->SetViewportExt(pDC->GetDeviceCaps(LOGPIXELSX),	pDC->GetDeviceCaps(LOGPIXELSY));

	pDC->SetWindowExt(96, 96);

	// ptOrg is in logical coordinates
	pDC->OffsetWindowOrg(0, 0);
}

void CChartView::OnBeginPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add extra initialization before printing
}

void CChartView::OnEndPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add cleanup after printing
}

void CChartView::OnCbnSelchangeComboChartStyle()
{
	m_nChartStyle = m_wndChartStyle.GetCurSel()+ID_CHART_STYLE_DIAGRAMS;
	UpdateData();
	CreateChart();
	((CMainFrame*)AfxGetMainWnd())->RefreshPanes();
}

void CChartView::OnBtnClickedChartStyle()
{
	m_nChartStyle = ID_CHART_STYLE_LINE;
	UpdateData();
	CreateChart();
}

void CChartView::OnBtnDropDownChartStyle()
{
	CMenu menu;
	menu.LoadMenu(IDR_CONTENT_CHART_STYLE);

	CMenu* pPopup = menu.GetSubMenu(0);
	if(!pPopup) return;

	if(!m_wndChartStyle_Btn.IsDropDownStyle()) return;
	DWORD dwStyle = m_wndChartStyle_Btn.GetPushButtonStyle();

	CXTPWindowRect rect(m_wndChartStyle_Btn);

	m_nChartStyle = TrackPopupMenu(pPopup->GetSafeHmenu(), TPM_LEFTALIGN | TPM_LEFTBUTTON | TPM_VERTICAL |TPM_RETURNCMD,
		dwStyle == xtpButtonDropDownRight ? rect.right : rect.left, dwStyle == xtpButtonDropDownRight ? rect.top : rect.bottom, 0, m_hWnd, 0);

	UpdateData();
	CreateChart();
}

void CChartView::OnCbnSelchangeComboAppearance()
{
	UpdateData();
	CString strAppearance(m_arrAppearance[m_wndAppearance.GetCurSel()]);
	strAppearance.MakeUpper();
	m_wndChartControl.GetContent()->GetAppearance()->LoadAppearance(_T("CHART_APPEARANCE_") + strAppearance);
	m_wndChartControl.GetContent()->OnChartChanged();
}

void CChartView::OnCbnSelchangeComboPalette()
{
	UpdateData();
	CString strPalette(m_arrPalette[m_wndPalette.GetCurSel()]);
	strPalette.MakeUpper();
	strPalette.Replace(_T(" "), _T(""));

	m_wndChartControl.GetContent()->GetAppearance()->LoadPalette(_T("CHART_PALETTE_") + strPalette);
	m_wndChartControl.GetContent()->OnChartChanged();
}

void SetAxisTitle(CXTPChartDiagram2D* pDiagram, CString strAxisX, CString strAxisY, int nAxisX = 0, int nAxisY = 0)
{
	if (pDiagram)
	{
		CXTPChartAxis* pAxisX = pDiagram->GetAxisX();
		pAxisX->GetLabel()->SetAngle(nAxisX);
		if (pAxisX)
		{
			CXTPChartAxisTitle* pTitle = pAxisX->GetTitle();
			if (pTitle)
			{
				pTitle->SetText(strAxisX);
				pTitle->SetVisible(TRUE);
			}
		}

		CXTPChartAxis* pAxisY = pDiagram->GetAxisY();
		pAxisY->GetLabel()->SetAngle(nAxisY);
		if (pAxisY)
		{
			CXTPChartAxisTitle* pTitle = pAxisY->GetTitle();
			if (pTitle)
			{
				pTitle->SetText(strAxisY);
				pTitle->SetVisible(TRUE);
			}
		}
	}
}

void CChartView::CreateChart()
{
	if (0 != m_nTimer) KillTimer(m_nTimer);

	vector<SeriesPoint> vecSeries;
	SeriesPoint sp(1900, 726, 10);
	vecSeries.push_back(sp);
	sp = SeriesPoint(1950, 1483, 20);
	vecSeries.push_back(sp);
	sp = SeriesPoint(1990, 1799, 5);
	vecSeries.push_back(sp);
	sp = SeriesPoint(2000, 1897, 5);
	vecSeries.push_back(sp);
	sp = SeriesPoint(2008, 1949, 20);
	vecSeries.push_back(sp);
	sp = SeriesPoint(2010, 2149, 40);
	vecSeries.push_back(sp);

	switch(m_nChartStyle)
	{
	case ID_CHART_STYLE_DIAGRAMS:
		CreateChartDiagrams(_T("左幅横向偏差"), vecSeries);
		break;
	case ID_CHART_STYLE_FILE:
		CreateChartFromFile();
		break;
	case ID_CHART_STYLE_BAR:
		CreateChartBar(_T("左幅横向偏差"), vecSeries);
		break;
	case ID_CHART_STYLE_STACKEDBAR:
		CreateChartStackedBar(_T("左幅横向偏差"), vecSeries);
		break;
	case ID_CHART_STYLE_SIDEBAR:
		CreateChartSideStackedBar(_T("左幅横向偏差"), vecSeries);
		break;
	case ID_CHART_STYLE_SCATTER:
		CreateChartScatter(_T("左幅横向偏差"), vecSeries);
		break;
	case ID_CHART_STYLE_BUBBLE:
		CreateChartBubble(_T("%.3f%%"), vecSeries);
		break;
	case ID_CHART_STYLE_LINE:
		CreateChartLine(_T("左幅横向偏差"), vecSeries);
		break;
	case ID_CHART_STYLE_STEPLINE:
		CreateChartStepLine(_T("左幅横向偏差"), vecSeries);
		break;
	case ID_CHART_STYLE_FASTLINE:
		CreateChartFastLine();
		break;
	case ID_CHART_STYLE_PIE:
		CreateChartPie(_T("%.3f%%"), vecSeries);
		break;
	case ID_CHART_STYLE_PIE3D:
		CreateChartPie3D(_T("%.3f%%"), vecSeries);
		break;
	}
}

void CChartView::ClearChartSeries()
{
	m_wndChartControl.GetContent()->GetSeries()->RemoveAll();
}

void CChartView::AddChartSeries(CString strSeriesName, vector<SeriesPoint>& vecSeries, CXTPChartSeriesStyle* pStyle, BOOL bAddDiagram)
{
	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
	pSeries->SetName(strSeriesName);
	pSeries->SetStyle(pStyle);
	for(int i=0; i<vecSeries.size(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[i]._x, vecSeries[i].y));
		pPoint->SetTooltipText(vecSeries[i]._x);
	}
	SetLabelPosition(xtpChartBarLabelTop);

	if ((bAddDiagram))
	{
		CXTPChartDiagram2D* pDiagram = DYNAMIC_DOWNCAST(CXTPChartDiagram2D, pSeries->GetDiagram());
		SetAxisTitle(pDiagram, _T("里程桩号/轨道板号m"), _T("横向/高程偏差mm"));
		pDiagram->SetAllowZoom(TRUE);
		pDiagram->SetAllowScroll(TRUE);
		pDiagram->GetAxisX()->GetLabel()->SetAngle(360-45);
		pDiagram->GetAxisX()->SetMinorCount(5);
	}
}

void CChartView::AddChartSideBarSeries(int idx, CString strSeriesName, vector<SeriesPoint>& vecSeries, BOOL bAddDiagram)
{
	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
	pSeries->SetName(strSeriesName);
	CXTPChartStackedBarSeriesStyle* pStyle = new CXTPChartStackedBarSeriesStyle();
	pSeries->SetStyle(pStyle);
	pStyle->SetStackGroup(idx);
	for(int i=0; i<vecSeries.size(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[i]._x, vecSeries[i].y));
		pPoint->SetTooltipText(vecSeries[i]._x);
	}
	SetLabelPosition(xtpChartBarLabelTop);

	if ((bAddDiagram))
	{
		CXTPChartDiagram2D* pDiagram = DYNAMIC_DOWNCAST(CXTPChartDiagram2D, pSeries->GetDiagram());
		SetAxisTitle(pDiagram, _T("横向/高程偏差范围"), _T("横向/高程偏差百分比%"));
		pDiagram->SetAllowZoom(TRUE);
		pDiagram->SetAllowScroll(TRUE);
		pDiagram->GetAxisX()->GetLabel()->SetAngle(360-45);
		pDiagram->GetAxisX()->SetMinorCount(5);
	}
}

void CChartView::AddChartPieSeries(CString strSeriesFormat, vector<SeriesPoint>& vecSeries, int nDoughnut)
{
	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
	CXTPChartPieSeriesStyle* pStyle = new CXTPChartPieSeriesStyle();
	pSeries->SetStyle(pStyle);
	pStyle->GetLabel()->SetFormat(strSeriesFormat);
	pStyle->SetHolePercent(nDoughnut);
	for(int i=0; i<vecSeries.size(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[i].x,vecSeries[i].z));
		pPoint->SetLegentText(vecSeries[i]._x);
		pPoint->m_bSpecial = TRUE;
		pPoint->SetTooltipText(vecSeries[i]._x);
	}
}

void CChartView::SaveAsImage(CSize szBounds)
{
	TCHAR szFilter[] = _T("图像文件|*.bmp|*jpg|*.png|所有文件|*.*||");
	CFileDialog FileDlg(FALSE, _T("bmp"), NULL, 0, szFilter, this);
	if(IDOK == FileDlg.DoModal())
		m_wndChartControl.SaveAsImage(FileDlg.GetPathName(), szBounds);
}

void CChartView::SetChartTitle(CString strTitle, CString strSubTitle)
{
	CXTPChartTitleCollection* pTitles = m_wndChartControl.GetContent()->GetTitles();
	if(pTitles != NULL && pTitles->GetCount() > 1)
	{
		CXTPChartTitle* pTitle = pTitles->GetAt(0);
		if(!strTitle.IsEmpty()) pTitle->SetText(strTitle);
		CXTPChartTitle* pSubTitle = pTitles->GetAt(1);
		if(!strSubTitle.IsEmpty()) pSubTitle->SetText(strSubTitle);
	}
}

//Bar
void CChartView::CreateChartBar(CString strSeriesName, vector<SeriesPoint>& vecSeries)
{
	m_wndChartControl.GetContent()->GetLegend()->SetVisible(TRUE);
	m_wndChartControl.GetContent()->GetTitles()->RemoveAll();
	m_wndChartControl.GetContent()->GetSeries()->RemoveAll();
	m_wndChartControl.EnableToolTips(TRUE);
	CXTPToolTipContext* pToolTipContext = m_wndChartControl.GetToolTipContext();
	pToolTipContext->SetStyle(xtpToolTipResource);

	CXTPChartTitle* pTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pTitle->SetText(_T("CRTSⅢ型轨道板几何位置复测数据分析图"));
	CXTPChartTitle* pSubTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pSubTitle->SetText(_T("The Bar Chart"));
	pSubTitle->SetDocking(xtpChartDockBottom);
	pSubTitle->SetAlignment(xtpChartAlignFar);
	pSubTitle->SetFont(CXTPChartFont::GetTahoma8());
	pSubTitle->SetTextColor(CXTPChartColor::Gray);

	SetLabelPosition(xtpChartBarLabelTop);

	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
	pSeries->SetName(strSeriesName);
	pSeries->SetStyle(new CXTPChartBarSeriesStyle());
	for(int i=0; i<vecSeries.size(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[i].x, vecSeries[i].y));
		pPoint->SetTooltipText(vecSeries[i]._x);
	}

	CXTPChartDiagram2D* pDiagram = DYNAMIC_DOWNCAST(CXTPChartDiagram2D, pSeries->GetDiagram());
	SetAxisTitle(pDiagram, _T("里程桩号m"), _T("横向/高程偏差mm"));
}

void CChartView::CreateChartStackedBar(CString strSeriesName, vector<SeriesPoint>& vecSeries)
{
	m_wndChartControl.GetContent()->GetLegend()->SetVisible(TRUE);
	m_wndChartControl.GetContent()->GetTitles()->RemoveAll();
	m_wndChartControl.GetContent()->GetSeries()->RemoveAll();
	m_wndChartControl.EnableToolTips(TRUE);
	CXTPToolTipContext* pToolTipContext = m_wndChartControl.GetToolTipContext();
	pToolTipContext->SetStyle(xtpToolTipResource);

	CXTPChartTitle* pTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pTitle->SetText(_T("CRTSⅢ型轨道板几何位置复测数据分析图"));
	CXTPChartTitle* pSubTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pSubTitle->SetText(_T("The Stacked Bar Chart"));
	pSubTitle->SetDocking(xtpChartDockBottom);
	pSubTitle->SetAlignment(xtpChartAlignFar);
	pSubTitle->SetFont(CXTPChartFont::GetTahoma8());
	pSubTitle->SetTextColor(CXTPChartColor::Gray);

	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
	pSeries->SetName(strSeriesName);
	pSeries->SetStyle(new CXTPChartStackedBarSeriesStyle());
	for(int i=0; i<vecSeries.size(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[i].x, vecSeries[i].y));
		pPoint->SetTooltipText(vecSeries[i]._x);
	}

	CXTPChartDiagram2D* pDiagram = DYNAMIC_DOWNCAST(CXTPChartDiagram2D, pSeries->GetDiagram());
	SetAxisTitle(pDiagram, _T("里程桩号m"), _T("横向/高程偏差mm"));
	SetLabelPosition(xtpChartBarLabelTop);
}

void CChartView::CreateChartSideStackedBar(CString strSeriesName, vector<SeriesPoint>& vecSeries)
{
	m_wndChartControl.GetContent()->GetLegend()->SetVisible(TRUE);
	m_wndChartControl.GetContent()->GetTitles()->RemoveAll();
	m_wndChartControl.GetContent()->GetSeries()->RemoveAll();
	m_wndChartControl.EnableToolTips(TRUE);
	CXTPToolTipContext* pToolTipContext = m_wndChartControl.GetToolTipContext();
	pToolTipContext->SetStyle(xtpToolTipResource);

	CXTPChartTitle* pTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pTitle->SetText(_T("CRTSⅢ型轨道板几何位置复测数据分析图"));
	CXTPChartTitle* pSubTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pSubTitle->SetText(_T("The SideStacked Bar Chart"));
	pSubTitle->SetDocking(xtpChartDockBottom);
	pSubTitle->SetAlignment(xtpChartAlignFar);
	pSubTitle->SetFont(CXTPChartFont::GetTahoma8());
	pSubTitle->SetTextColor(CXTPChartColor::Gray);

	for (int i = 0; i < 4; i++)
	{
		CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
		CString strName;
		strName.Format(_T("%s_%d"), strSeriesName, i + 1);
		pSeries->SetName(strName);
		CXTPChartStackedBarSeriesStyle* pStyle = new CXTPChartStackedBarSeriesStyle();
		pSeries->SetStyle(pStyle);
		pStyle->SetStackGroup(i);
		for(int j=0; j<vecSeries.size(); j++)
		{
			CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[j].x, vecSeries[j].y));
			pPoint->SetTooltipText(vecSeries[j]._x);
		}
	}

	SetLabelPosition(xtpChartBarLabelTop);
}

int CChartView::GetSeriesCount()
{
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();
	return pSeriesCollection->GetCount();
}

CXTPChartSeries* CChartView::GetSeries(int index)
{
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();
	return pSeriesCollection->GetAt(index);
}

CString CChartView::GetSeriesName(int index)
{
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();
	return pSeriesCollection->GetAt(index)->GetName();
}

void CChartView::ShowSeries(int index, BOOL bShowSeries) 
{
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();
	pSeriesCollection->GetAt(index)->SetVisible(bShowSeries);
}

void CChartView::ShowLabels(BOOL bShowLabels) 
{
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();

	for (int i = 0; i < pSeriesCollection->GetCount(); i++)
	{
		CXTPChartSeriesStyle* pStyle = (CXTPChartSeriesStyle*)pSeriesCollection->GetAt(i)->GetStyle();
		pStyle->GetLabel()->SetVisible(bShowLabels);
	}
}

void CChartView::SetLabelPosition(int nPosition)
{
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();

	for (int i = 0; i < pSeriesCollection->GetCount(); i++)
	{
		CXTPChartBarSeriesStyle* pStyle = (CXTPChartBarSeriesStyle*)pSeriesCollection->GetAt(i)->GetStyle();
		CXTPChartBarSeriesLabel* pLabel = (CXTPChartBarSeriesLabel*)pStyle->GetLabel();
		pLabel->SetPosition((XTPChartBarLabelPosition)nPosition);
	}
}

void CChartView::SetRotated(BOOL bRotated)
{
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();
	CXTPChartDiagram2D* pDiagram = STATIC_DOWNCAST(CXTPChartDiagram2D, pSeriesCollection->GetAt(0)->GetDiagram());

	pDiagram->SetRotated(bRotated);
}

void CChartView::SetChartGroup(int nChartGroup)
{
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();
	if(!pSeriesCollection) return;
	for (int i = 0; i < pSeriesCollection->GetCount(); i++)
	{
		CXTPChartSeries* pSeries = pSeriesCollection->GetAt(i);

		CXTPChartStackedBarSeriesStyle* pStyle = DYNAMIC_DOWNCAST(CXTPChartStackedBarSeriesStyle, pSeries->GetStyle());
		if(!pStyle) return;

		pStyle->SetStackGroup(i % nChartGroup);			
	}
}

// Scatter
void CChartView::CreateChartScatter(CString strSeriesName, vector<SeriesPoint>& vecSeries)
{
	m_wndChartControl.GetContent()->GetLegend()->SetVisible(TRUE);
	m_wndChartControl.GetContent()->GetTitles()->RemoveAll();
	m_wndChartControl.GetContent()->GetSeries()->RemoveAll();
	m_wndChartControl.EnableToolTips(TRUE);
	CXTPToolTipContext* pToolTipContext = m_wndChartControl.GetToolTipContext();
	pToolTipContext->SetStyle(xtpToolTipResource);

	CXTPChartTitle* pTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pTitle->SetText(_T("CRTSⅢ型轨道板几何位置复测数据分析图"));
	CXTPChartTitle* pSubTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pSubTitle->SetText(_T("The Scatter Point Chart"));
	pSubTitle->SetDocking(xtpChartDockBottom);
	pSubTitle->SetAlignment(xtpChartAlignFar);
	pSubTitle->SetFont(CXTPChartFont::GetTahoma8());
	pSubTitle->SetTextColor(CXTPChartColor::Gray);

	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
	pSeries->SetArgumentScaleType(xtpChartScaleNumerical);
	pSeries->SetName(strSeriesName);
	pSeries->SetStyle(new CXTPChartPointSeriesStyle());
	for(int i=0; i<vecSeries.size(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[i].x, vecSeries[i].y));
		pPoint->SetTooltipText(vecSeries[i]._x);
	}
}

void CChartView::SetScatterAngle(int nScatterAngle)
{
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();

	for (int i = 0; i < pSeriesCollection->GetCount(); i++)
	{
		CXTPChartPointSeriesStyle* pStyle = (CXTPChartPointSeriesStyle*)pSeriesCollection->GetAt(i)->GetStyle();

		CXTPChartPointSeriesLabel* pLabel = (CXTPChartPointSeriesLabel*)pStyle->GetLabel();

		pLabel->SetAngle(nScatterAngle);
	}
}

// Bubble
void CChartView::CreateChartBubble(CString strSeriesFormat, vector<SeriesPoint>& vecSeries)
{
	m_wndChartControl.GetContent()->GetLegend()->SetVisible(TRUE);
	m_wndChartControl.GetContent()->GetTitles()->RemoveAll();
	m_wndChartControl.GetContent()->GetSeries()->RemoveAll();
	m_wndChartControl.EnableToolTips(TRUE);
	CXTPToolTipContext* pToolTipContext = m_wndChartControl.GetToolTipContext();
	pToolTipContext->SetStyle(xtpToolTipResource);

	CXTPChartTitle* pTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pTitle->SetText(_T("CRTSⅢ型轨道板几何位置复测数据分析图"));
	CXTPChartTitle* pSubTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pSubTitle->SetText(_T("The Bubble Point Chart"));
	pSubTitle->SetDocking(xtpChartDockBottom);
	pSubTitle->SetAlignment(xtpChartAlignFar);
	pSubTitle->SetFont(CXTPChartFont::GetTahoma8());
	pSubTitle->SetTextColor(CXTPChartColor::Gray);

	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
	pSeries->SetArgumentScaleType(xtpChartScaleNumerical);
	CXTPChartBubbleSeriesStyle* pStyle = new CXTPChartBubbleSeriesStyle();
	pSeries->SetStyle(pStyle);
	for(int i=0; i<vecSeries.size(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[i].x,vecSeries[i].z));
		pPoint->SetLegentText(vecSeries[i]._x);
		if(i==0 || i== 3) pPoint->m_bSpecial = TRUE;
		pPoint->SetTooltipText(vecSeries[i]._x);
	}

	pStyle->GetLabel()->SetFormat(strSeriesFormat);
	pStyle->SetMinSize(190);
	pStyle->SetMaxSize(200);
	pStyle->SetTransparency(135);

	CXTPChartDiagram2D* pDiagram = DYNAMIC_DOWNCAST(CXTPChartDiagram2D, pSeries->GetDiagram());
	if (!pDiagram) return;

	// Set the X and Y Axis title for the series.
	pDiagram->GetAxisX()->GetTitle()->SetText(_T("里程桩号"));
	pDiagram->GetAxisX()->GetTitle()->SetVisible(TRUE);

	pDiagram->GetAxisX()->SetReversed(TRUE);
	pDiagram->GetAxisX()->GetLabel()->SetVisible(TRUE);
	pDiagram->GetAxisX()->GetTickMarks()->SetVisible(TRUE);
	pDiagram->GetAxisY()->GetRange()->SetAutoRange(TRUE);
	pDiagram->GetAxisX()->GetRange()->SetShowZeroLevel(TRUE);
}

void CChartView::SetBubbleTransparency(int nTransparency)
{
	if (nTransparency > 255) nTransparency = 255;

	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->GetAt(0);

	CXTPChartBubbleSeriesStyle* pStyle = DYNAMIC_DOWNCAST(CXTPChartBubbleSeriesStyle, pSeries->GetStyle());
	if(!pStyle) return;

	pStyle->SetTransparency(nTransparency);
}

void CChartView::SetBubbleSize(double fBubbleMinSize, double fBubbleMaxSize)
{
	if (fBubbleMinSize <= fBubbleMaxSize)
	{
		CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->GetAt(0);

		CXTPChartBubbleSeriesStyle* pStyle = DYNAMIC_DOWNCAST(CXTPChartBubbleSeriesStyle, pSeries->GetStyle());
		if(!pStyle) return;

		pStyle->SetMinSize(fBubbleMinSize);
		pStyle->SetMaxSize(fBubbleMaxSize);
	}
}

// Line
void CChartView::CreateChartLine(CString strSeriesName, vector<SeriesPoint>& vecSeries)
{
	m_wndChartControl.GetContent()->GetLegend()->SetVisible(TRUE);
	m_wndChartControl.GetContent()->GetTitles()->RemoveAll();
	m_wndChartControl.GetContent()->GetSeries()->RemoveAll();
	m_wndChartControl.EnableToolTips(TRUE);
	CXTPToolTipContext* pToolTipContext = m_wndChartControl.GetToolTipContext();
	pToolTipContext->SetStyle(xtpToolTipResource);

	CXTPChartTitle* pTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pTitle->SetText(_T("CRTSⅢ型轨道板几何位置复测数据分析图"));
	CXTPChartTitle* pSubTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pSubTitle->SetText(_T("The Line Chart"));
	pSubTitle->SetDocking(xtpChartDockBottom);
	pSubTitle->SetAlignment(xtpChartAlignFar);
	pSubTitle->SetFont(CXTPChartFont::GetTahoma8());
	pSubTitle->SetTextColor(CXTPChartColor::Gray);
	
	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
	pSeries->SetName(strSeriesName);
	pSeries->SetStyle(new CXTPChartLineSeriesStyle());
	for(int i=0; i<vecSeries.size(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[i].x, vecSeries[i].y));
		pPoint->SetTooltipText(vecSeries[i]._x);
	}

	CXTPChartDiagram2D* pDiagram = DYNAMIC_DOWNCAST(CXTPChartDiagram2D, pSeries->GetDiagram());
	SetAxisTitle(pDiagram, _T("里程桩号m"), _T("横向/高程偏差mm"));
}

void CChartView::CreateChartStepLine(CString strSeriesName, vector<SeriesPoint>& vecSeries)
{
	m_wndChartControl.GetContent()->GetLegend()->SetVisible(TRUE);
	m_wndChartControl.GetContent()->GetTitles()->RemoveAll();
	m_wndChartControl.GetContent()->GetSeries()->RemoveAll();
	m_wndChartControl.EnableToolTips(TRUE);
	CXTPToolTipContext* pToolTipContext = m_wndChartControl.GetToolTipContext();
	pToolTipContext->SetStyle(xtpToolTipResource);

	CXTPChartTitle* pTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pTitle->SetText(_T("CRTSⅢ型轨道板几何位置复测数据分析图"));
	CXTPChartTitle* pSubTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pSubTitle->SetText(_T("The Line Chart"));
	pSubTitle->SetDocking(xtpChartDockBottom);
	pSubTitle->SetAlignment(xtpChartAlignFar);
	pSubTitle->SetFont(CXTPChartFont::GetTahoma8());
	pSubTitle->SetTextColor(CXTPChartColor::Gray);

	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
	pSeries->SetName(strSeriesName);
	for(int i=0; i<vecSeries.size(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[i]._x, vecSeries[i].y));
		pPoint->SetTooltipText(vecSeries[i]._x);
	}

	CXTPChartStepLineSeriesStyle* pStyle = (CXTPChartStepLineSeriesStyle*)pSeries->SetStyle(new CXTPChartStepLineSeriesStyle());
	pStyle->SetColorEach(TRUE);
	pStyle->GetMarker()->SetType(xtpChartMarkerSquare);
	pStyle->GetMarker()->SetSize(12);
	pStyle->GetLabel()->SetLineLength(10);

	CXTPChartDiagram2D* pDiagram = DYNAMIC_DOWNCAST(CXTPChartDiagram2D, pSeries->GetDiagram());
	SetAxisTitle(pDiagram, _T("轨道板编号"), _T("横向/高程偏差mm"));
}

void CChartView::ShowMarkers(BOOL bShowMarkers) 
{
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();

	for (int i = 0; i < pSeriesCollection->GetCount(); i++)
	{
		CXTPChartPointSeriesStyle* pStyle = (CXTPChartPointSeriesStyle*)pSeriesCollection->GetAt(i)->GetStyle();
		pStyle->GetMarker()->SetVisible(bShowMarkers);
	}
}

void CChartView::SetMarkerSize(int nMarkerSize)
{
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();

	for (int i = 0; i < pSeriesCollection->GetCount(); i++)
	{
		CXTPChartPointSeriesStyle* pStyle = (CXTPChartPointSeriesStyle*)pSeriesCollection->GetAt(i)->GetStyle();

		pStyle->GetMarker()->SetSize(nMarkerSize);
	}
}

void CChartView::SetMarkerType(int nMarkerType)
{
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();

	for (int i = 0; i < pSeriesCollection->GetCount(); i++)
	{
		CXTPChartPointSeriesStyle* pStyle = (CXTPChartPointSeriesStyle*)pSeriesCollection->GetAt(i)->GetStyle();

		pStyle->GetMarker()->SetType((XTPChartMarkerType)nMarkerType);
	}
}

void CChartView::SetInvertedStep(BOOL bInvertedStep)
{
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();

	for (int i = 0; i < pSeriesCollection->GetCount(); i++)
	{
		CXTPChartStepLineSeriesStyle* pStyle = (CXTPChartStepLineSeriesStyle*)pSeriesCollection->GetAt(i)->GetStyle();

		pStyle->SetInvertedStep(bInvertedStep);
	}
}

// Pie
void CChartView::CreateChartPie(CString strSeriesFormat, vector<SeriesPoint>& vecSeries, int nDoughnut)
{
	m_wndChartControl.GetContent()->GetLegend()->SetVisible(TRUE);
	m_wndChartControl.GetContent()->GetTitles()->RemoveAll();
	m_wndChartControl.GetContent()->GetSeries()->RemoveAll();
	m_wndChartControl.EnableToolTips(TRUE);
	CXTPToolTipContext* pToolTipContext = m_wndChartControl.GetToolTipContext();
	pToolTipContext->SetStyle(xtpToolTipResource);

	CXTPChartTitle* pTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pTitle->SetText(_T("CRTSⅢ型轨道板几何位置复测数据分析图"));
	CXTPChartTitle* pSubTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pSubTitle->SetText(_T("The Pie Chart"));
	pSubTitle->SetDocking(xtpChartDockBottom);
	pSubTitle->SetAlignment(xtpChartAlignFar);
	pSubTitle->SetFont(CXTPChartFont::GetTahoma8());
	pSubTitle->SetTextColor(CXTPChartColor::Gray);

	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
	CXTPChartPieSeriesStyle* pStyle = new CXTPChartPieSeriesStyle();
	pSeries->SetStyle(pStyle);
	pStyle->GetLabel()->SetFormat(strSeriesFormat);
	pStyle->SetHolePercent(nDoughnut);
	for(int i=0; i<vecSeries.size(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[i].x,vecSeries[i].z));
		pPoint->SetLegentText(vecSeries[i]._x);
		if(i==0 || i== 3) pPoint->m_bSpecial = TRUE;
		pPoint->SetTooltipText(vecSeries[i]._x);
	}
}

void CChartView::CreateChartPie3D(CString strSeriesFormat, vector<SeriesPoint>& vecSeries, int nDoughnut)
{
	CreateChartPie(strSeriesFormat, vecSeries, nDoughnut);
	CXTPChartTitle* pSubTitle = m_wndChartControl.GetContent()->GetTitles()->GetAt(1);
	pSubTitle->SetText(_T("The Pie3D Chart"));

	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();
	if(!pSeriesCollection) return;
	for(int i=0; i<pSeriesCollection->GetCount(); i++)
	{
		CXTPChartPieSeriesStyle* pStyle = new CXTPChartPieSeriesStyle();
		pStyle->GetLabel()->SetFormat(strSeriesFormat);
		pStyle->SetHolePercent(nDoughnut);
		pSeriesCollection->GetAt(i)->SetStyle(pStyle);
	}
}

void CChartView::SetnExplodedPoints(int nExplodedPoints)
{
	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->GetAt(0);

	int i;
	for (i = 0; i < pSeries->GetPoints()->GetCount(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->GetAt(i);
		pPoint->m_bSpecial = nExplodedPoints == 1;
	}

	if (nExplodedPoints == 2)
	{
		pSeries->GetPoints()->GetAt(0)->m_bSpecial = TRUE;
		pSeries->GetPoints()->GetAt(4)->m_bSpecial = TRUE;
		pSeries->GetPoints()->GetAt(7)->m_bSpecial = TRUE;

	}
	m_wndChartControl.OnChartChanged();
}

void CChartView::SetDoughnut(int nDoughnut)
{
	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->GetAt(0);
	CXTPChartPieSeriesStyle* pStyle = (CXTPChartPieSeriesStyle*)pSeries->GetStyle();
	pStyle->SetHolePercent(nDoughnut);
	m_wndChartControl.OnChartChanged();
}

//FastLine
void CChartView::AddPoint()
{
	CXTPChartSeriesCollection* pCollection = m_wndChartControl.GetContent()->GetSeries();

	int nCount;

	if (pCollection)
	{
		for (int s = 0; s < pCollection->GetCount(); s++)
		{
			CXTPChartSeries* pSeries = pCollection->GetAt(s);
			if (pSeries)
			{
				int nValue = 50;

				nCount = pSeries->GetPoints()->GetCount();

				if (nCount)
					nValue = (int)pSeries->GetPoints()->GetAt(nCount - 1)->GetValue(0);

				nValue = nValue + (rand() % 20) - 10;

				if (nValue < 0) nValue = 0;
				if (nValue > 100) nValue = 100;

				pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(nCount, nValue));
			}
		}
	}

	CXTPChartDiagram2D* pDiagram = DYNAMIC_DOWNCAST(CXTPChartDiagram2D, 
		m_wndChartControl.GetContent()->GetPanels()->GetAt(0));
	if (!pDiagram) return;


	if (nCount > 100)
	{
		CXTPChartAxisRange* pRange = pDiagram->GetAxisX()->GetRange();

		BOOL bAutoScroll = pRange->GetViewMaxValue() == pRange->GetMaxValue();

		pRange->SetMaxValue(nCount);

		if (bAutoScroll)
		{
			double delta = pRange->GetViewMaxValue() - pRange->GetViewMinValue();

			pRange->SetViewAutoRange(FALSE);
			pRange->SetViewMaxValue(nCount);
			pRange->SetViewMinValue(nCount - delta);
		}

	}

}
int nPts = 0;
void CChartView::AddPoint(vector<SeriesPoint>* pVecSeries)
{
	CXTPChartSeriesCollection* pCollection = m_wndChartControl.GetContent()->GetSeries();

	if (pCollection)
	{
		for(int i=0; i<pCollection->GetCount();i++)
		{
			vector<SeriesPoint> vecSeries = pVecSeries[i];
			CXTPChartSeries* pSeries = pCollection->GetAt(i);
			if (pSeries)
			{
				nPts = pSeries->GetPoints()->GetCount();

				CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[nPts].x, vecSeries[nPts].y));
				pPoint->SetTooltipText(vecSeries[nPts]._x);
			}
		}
	}

	CXTPChartDiagram2D* pDiagram = DYNAMIC_DOWNCAST(CXTPChartDiagram2D, m_wndChartControl.GetContent()->GetPanels()->GetAt(0));
	if (!pDiagram) return;

	if (nPts > 100 && nPts <= pVecSeries[0].size())
	{
		CXTPChartAxisRange* pRange = pDiagram->GetAxisX()->GetRange();

		BOOL bAutoScroll = pRange->GetViewMaxValue() == pRange->GetMaxValue();

		pRange->SetMaxValue(nPts);

		if (bAutoScroll)
		{
			double delta = pRange->GetViewMaxValue() - pRange->GetViewMinValue();

			pRange->SetViewAutoRange(FALSE);
			pRange->SetViewMaxValue(nPts);
			pRange->SetViewMinValue(nPts - delta);
		}
	}
}

void CChartView::CreateChartFastLine(int nSeries, int nInterval, BOOL bAntialiased)
{
	m_wndChartControl.GetContent()->GetLegend()->SetVisible(TRUE);
	m_wndChartControl.GetContent()->GetTitles()->RemoveAll();
	m_wndChartControl.GetContent()->GetSeries()->RemoveAll();

	CXTPChartTitle* pTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pTitle->SetText(_T("CRTSⅢ型轨道板几何位置复测数据分析图"));
	CXTPChartTitle* pSubTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pSubTitle->SetText(_T("The Fast Line Chart"));
	pSubTitle->SetDocking(xtpChartDockBottom);
	pSubTitle->SetAlignment(xtpChartAlignFar);
	pSubTitle->SetFont(CXTPChartFont::GetTahoma8());
	pSubTitle->SetTextColor(CXTPChartColor::Gray);

	CXTPChartSeriesCollection* pCollection = m_wndChartControl.GetContent()->GetSeries();
	if (pCollection)
	{
		for (int s = 0; s < nSeries; s++)
		{
			CXTPChartSeries* pSeries = pCollection->Add(new CXTPChartSeries());
			if (pSeries)
			{
				pSeries->SetName(_T("Series"));				

				CXTPChartFastLineSeriesStyle*pStyle = new CXTPChartFastLineSeriesStyle();
				pSeries->SetStyle(pStyle);

				pStyle->SetAntialiasing(bAntialiased);				

				pSeries->SetArgumentScaleType(xtpChartScaleNumerical);
			}
		}
	}

	// Set the X and Y Axis title for the series.
	CXTPChartDiagram2D* pDiagram = DYNAMIC_DOWNCAST(CXTPChartDiagram2D, pCollection->GetAt(0)->GetDiagram());
	if (!pDiagram) return;
	SetAxisTitle(pDiagram, _T("里程桩号m"), _T("横向/高程偏差mm"));

	pDiagram->SetAllowZoom(TRUE);
	pDiagram->GetAxisY()->GetRange()->SetMaxValue(100.1);
	pDiagram->GetAxisY()->GetRange()->SetAutoRange(FALSE);
	pDiagram->GetAxisY()->SetAllowZoom(FALSE);

	pDiagram->GetAxisX()->GetRange()->SetMaxValue(100.1);
	pDiagram->GetAxisX()->GetRange()->SetAutoRange(FALSE);
	pDiagram->GetAxisX()->GetRange()->SetZoomLimit(10);

	pDiagram->GetAxisX()->SetInterlaced(FALSE);
	pDiagram->GetAxisY()->SetInterlaced(FALSE);	

	pDiagram->GetPane()->GetFillStyle()->SetFillMode(xtpChartFillSolid);

	if (0 != m_nTimer) KillTimer(m_nTimer);
	m_nTimer = (int)SetTimer(1, nInterval, NULL);
}

void CChartView::CreateChartFastLine(CString strSeriesName, int nInterval, BOOL bAntialiased)
{
	m_wndChartControl.GetContent()->GetLegend()->SetVisible(TRUE);
	m_wndChartControl.GetContent()->GetTitles()->RemoveAll();
	m_wndChartControl.GetContent()->GetSeries()->RemoveAll();
	m_wndChartControl.EnableToolTips(TRUE);
	CXTPToolTipContext* pToolTipContext = m_wndChartControl.GetToolTipContext();
	pToolTipContext->SetStyle(xtpToolTipResource);

	CXTPChartTitle* pTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pTitle->SetText(_T("CRTSⅢ型轨道板几何位置复测数据分析图"));
	CXTPChartTitle* pSubTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pSubTitle->SetText(_T("The Line Chart"));
	pSubTitle->SetDocking(xtpChartDockBottom);
	pSubTitle->SetAlignment(xtpChartAlignFar);
	pSubTitle->SetFont(CXTPChartFont::GetTahoma8());
	pSubTitle->SetTextColor(CXTPChartColor::Gray);

	CXTPChartSeriesCollection* pCollection = m_wndChartControl.GetContent()->GetSeries();
	if (pCollection)
	{
		CXTPChartSeries* pSeries = pCollection->Add(new CXTPChartSeries());
		if(pSeries)
		{
			pSeries->SetName(strSeriesName);
			CXTPChartFastLineSeriesStyle*pStyle = new CXTPChartFastLineSeriesStyle();
			pSeries->SetStyle(pStyle);
			pStyle->SetAntialiasing(bAntialiased);
			pSeries->SetArgumentScaleType(xtpChartScaleNumerical);
		}
	}

	// Set the X and Y Axis title for the series.
	CXTPChartDiagram2D* pDiagram = DYNAMIC_DOWNCAST(CXTPChartDiagram2D, pCollection->GetAt(0)->GetDiagram());
	if (!pDiagram) return;

	pDiagram->SetAllowZoom(TRUE);

	pDiagram->GetAxisY()->GetRange()->SetMaxValue(100.1);
	pDiagram->GetAxisY()->GetRange()->SetAutoRange(FALSE);
	pDiagram->GetAxisY()->SetAllowZoom(FALSE);

	pDiagram->GetAxisX()->GetRange()->SetMaxValue(100.1);
	pDiagram->GetAxisX()->GetRange()->SetAutoRange(FALSE);
	pDiagram->GetAxisX()->GetRange()->SetZoomLimit(10);

	pDiagram->GetAxisX()->SetInterlaced(FALSE);
	pDiagram->GetAxisY()->SetInterlaced(FALSE);	

	pDiagram->GetPane()->GetFillStyle()->SetFillMode(xtpChartFillSolid);

	if (0 != m_nTimer) KillTimer(m_nTimer);
	m_nTimer = (int)SetTimer(1, nInterval, NULL);
}

void CChartView::SetSeries(int nSeries, int nInterval, BOOL bAntialiased)
{
	m_wndChartControl.GetContent()->GetLegend()->SetVisible(TRUE);
	if(!m_wndChartControl.GetContent()) return;
	CXTPChartTitleCollection* pTitlesCollection = m_wndChartControl.GetContent()->GetTitles();
	if(!pTitlesCollection) return;
	pTitlesCollection->RemoveAll();
	CXTPChartSeriesCollection* pSeriesCollection = m_wndChartControl.GetContent()->GetSeries();
	if(!pSeriesCollection)  return;
	pSeriesCollection->RemoveAll();

	CreateChartFastLine(nSeries, nInterval, bAntialiased);
}

void CChartView::SetInterval(int nInterval)
{
	if (0 != m_nTimer) KillTimer(m_nTimer);
	m_nTimer = (int)SetTimer(1, nInterval, NULL);
}

void CChartView::GoIntervalStep(int nStep)
{
	for (int i = 0; i < nStep; i++)
		AddPoint();
}

void CChartView::SetInterlaced(BOOL bInterlaced)
{
	CXTPChartDiagram2D* pDiagram = DYNAMIC_DOWNCAST(CXTPChartDiagram2D, 
		m_wndChartControl.GetContent()->GetPanels()->GetAt(0));
	if (!pDiagram)  return;

	pDiagram->GetAxisY()->SetInterlaced(bInterlaced);
}

void CChartView::SetAntialiased(BOOL bAntialiased)
{
	CXTPChartSeriesCollection* pCollection = m_wndChartControl.GetContent()->GetSeries();

	if (pCollection)
	{
		for (int s = 0; s < pCollection->GetCount(); s++)
		{
			CXTPChartSeries* pSeries = pCollection->GetAt(s);
			if (pSeries)
			{
				CXTPChartFastLineSeriesStyle* pStyle = (CXTPChartFastLineSeriesStyle*)pSeries->GetStyle();
				pStyle->SetAntialiasing(bAntialiased);				
			}
		}
	}	
}

// Chart From Builder File
void CChartView::CreateChartFromFile()
{
	LPCTSTR lpszResourceName = MAKEINTRESOURCE(IDR_HTML_BUILDERFILE);

	CXTPPropExchangeXMLNode px(TRUE, NULL, _T("Content"));

	if (px.LoadFromResource(AfxGetInstanceHandle(), lpszResourceName, RT_HTML))
	{
		m_wndChartControl.GetContent()->GetLegend()->SetVisible(TRUE);
		m_wndChartControl.GetContent()->GetTitles()->RemoveAll();
		m_wndChartControl.GetContent()->GetSeries()->RemoveAll();
		m_wndChartControl.EnableToolTips(TRUE);
		CXTPToolTipContext* pToolTipContext = m_wndChartControl.GetToolTipContext();
		pToolTipContext->SetStyle(xtpToolTipResource);

		m_wndChartControl.GetContent()->DoPropExchange(&px);
	}
}

//Multiple Diagrams
void CChartView::CreateChartDiagrams(CString strSeriesName, vector<SeriesPoint>& vecSeries, int nDoughnut)
{
	m_wndChartControl.GetContent()->GetLegend()->SetVisible(TRUE);
	m_wndChartControl.GetContent()->GetTitles()->RemoveAll();
	m_wndChartControl.GetContent()->GetSeries()->RemoveAll();
	m_wndChartControl.EnableToolTips(TRUE);
	CXTPToolTipContext* pToolTipContext = m_wndChartControl.GetToolTipContext();
	pToolTipContext->SetStyle(xtpToolTipResource);
	m_wndChartControl.GetContent()->GetLegend()->SetVerticalAlignment(xtpChartLegendFarOutside);
	m_wndChartControl.GetContent()->GetLegend()->SetHorizontalAlignment(xtpChartLegendCenter);
	m_wndChartControl.GetContent()->GetLegend()->SetDirection(xtpChartLegendLeftToRight);

	CXTPChartTitle* pTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pTitle->SetText(_T("CRTSⅢ型轨道板几何位置复测数据分析图"));
	CXTPChartTitle* pSubTitle = m_wndChartControl.GetContent()->GetTitles()->Add(new CXTPChartTitle());
	pSubTitle->SetText(_T("The Multiple Diagrams Chart"));
	pSubTitle->SetDocking(xtpChartDockBottom);
	pSubTitle->SetAlignment(xtpChartAlignFar);
	pSubTitle->SetFont(CXTPChartFont::GetTahoma8());
	pSubTitle->SetTextColor(CXTPChartColor::Gray);

	CXTPChartDiagram2D* pDiagram1 = (CXTPChartDiagram2D*)m_wndChartControl.GetContent()->GetPanels()->Add(new CXTPChartDiagram2D());
	CXTPChartDiagram2D* pDiagram2 = (CXTPChartDiagram2D*)m_wndChartControl.GetContent()->GetPanels()->Add(new CXTPChartDiagram2D());
	CXTPChartPieDiagram* pDiagram3 = (CXTPChartPieDiagram*)m_wndChartControl.GetContent()->GetPanels()->Add(new CXTPChartPieDiagram());

	CXTPChartSeries* pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
	pSeries->SetName(strSeriesName);
	pSeries->SetStyle(new CXTPChartBarSeriesStyle());
	for(int i=0; i<vecSeries.size(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[i].x, vecSeries[i].y));
		pPoint->SetTooltipText(vecSeries[i]._x);
	}
	pSeries->SetDiagram(pDiagram1);
	pDiagram1->SetRotated(TRUE);
	SetAxisTitle(pDiagram1, _T("里程桩号m"), _T("横向/高程偏差mm"));

	pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
	pSeries->SetName(strSeriesName);
	for(int i=0; i<vecSeries.size(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[i].x, vecSeries[i].y));
		pPoint->SetTooltipText(vecSeries[i]._x);
	}
	pSeries->SetStyle(new CXTPChartLineSeriesStyle());
	CXTPChartPointSeriesLabel* pLabel = DYNAMIC_DOWNCAST(CXTPChartPointSeriesLabel, pSeries->GetStyle()->GetLabel());
	pLabel->SetLineLength(20);
	pLabel->SetAngle(70);
	pSeries->SetDiagram(pDiagram2);
	pDiagram2->SetRotated(TRUE);
	SetAxisTitle(pDiagram2, _T("里程桩号m"), _T("横向/高程偏差mm"));
	pDiagram2->GetAxisX()->GetTitle()->SetVisible(FALSE);
	pDiagram2->GetAxisY()->GetLabel()->SetVisible(FALSE);

	pSeries = m_wndChartControl.GetContent()->GetSeries()->Add(new CXTPChartSeries());
	CXTPChartPieSeriesStyle* pStyle = new CXTPChartPieSeriesStyle();
	pSeries->SetStyle(new CXTPChartPieSeriesStyle());
	for(int i=0; i<vecSeries.size(); i++)
	{
		CXTPChartSeriesPoint* pPoint = pSeries->GetPoints()->Add(new CXTPChartSeriesPoint(vecSeries[i].x, vecSeries[i].z));
		pPoint->SetLegentText(vecSeries[i]._x);
		pPoint->SetTooltipText(vecSeries[i]._x);
	}
	pStyle->GetLabel()->SetFormat(_T("%.3f%%"));
	pStyle->SetHolePercent(nDoughnut);
	pSeries->SetDiagram(pDiagram3);
	CXTPChartPieSeriesLabel* pPieLabel = DYNAMIC_DOWNCAST(CXTPChartPieSeriesLabel, pSeries->GetStyle()->GetLabel());
	if(!pPieLabel) return;
	pPieLabel->SetPosition(xtpChartPieLabelOutside);

	m_wndChartControl.GetContent()->SetPanelDirection(xtpChartPanelHorizontal);
}


// Generated message map functions
//{{AFX_MSG(CChartView)

void CChartView::OnTimer(UINT_PTR nIDEvent)
{
	AddPoint();
}

void CChartView::OnDestroy()
{
	KillTimer(m_nTimer);
}

void CChartView::OnSize(UINT nType, int cx, int cy)
{
	CFormView::OnSize(nType, cx, cy);

	if (!m_wndGroupBoxLabels.GetSafeHwnd())
		return;

	CXTPWindowRect rc(m_wndGroupBoxLabels);

	int nWidth = max(m_totalDev.cx, cx);
	m_wndGroupBoxLabels.SetWindowPos(0, 0, 0, nWidth - 2 * m_nLeftGap, rc.Height(), SWP_NOMOVE | SWP_NOZORDER);

	int nHeight = max(m_totalDev.cy, cy);
	m_wndChartControl.SetWindowPos(0, 0, 0, nWidth - 2 * m_nLeftGap, nHeight - m_nTopGap - m_nLeftGap, SWP_NOMOVE | SWP_NOZORDER);
}