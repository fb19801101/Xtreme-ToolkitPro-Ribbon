#include "afxwin.h"
#if !defined(AFX_CHARTVIEW_H__F31A2B31_B7F8_49D2_B748_57B38AF51C5F__INCLUDED_)
#define AFX_CHARTVIEW_H__F31A2B31_B7F8_49D2_B748_57B38AF51C5F__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// BarView.h : header file
//

class CResizeGroupBox : public CXTPButton
{
	DECLARE_DYNAMIC(CResizeGroupBox)

public:

	//-----------------------------------------------------------------------
	// Summary:
	//     Constructs a CXTPResizeGroupBox object
	//-----------------------------------------------------------------------
	CResizeGroupBox();

	//-----------------------------------------------------------------------
	// Summary:
	//     Destroys a CXTPResizeGroupBox object, handles cleanup and
	//     deallocation
	//-----------------------------------------------------------------------
	virtual ~CResizeGroupBox();

protected:
	//-----------------------------------------------------------------------
	// Summary:
	//     Called during paint operations to exclude the control windows
	//     that are grouped by this control.
	// Parameters:
	//     pDC      - Pointer to device context.
	//     rcClient - Client area of group box.
	//-----------------------------------------------------------------------
	virtual void Exclude(CDC* pDC, CRect& rcClient);



protected:
	//{{AFX_CODEJOCK_PRIVATE
	DECLARE_MESSAGE_MAP()

	//{{AFX_VIRTUAL(CXTPResizeGroupBox)
	//}}AFX_VIRTUAL

	//{{AFX_MSG(CXTPResizeGroupBox)
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	afx_msg void OnPaint();
	//}}AFX_MSG
	//}}AFX_CODEJOCK_PRIVATE
};



template <class TBase>
class CChartBorder : public TBase
{
public:
	CChartBorder()
	{
		CXTPChartColor color;
		color.SetFromCOLORREF(0xcf9365);

		GetContent()->GetBorder()->SetColor(color);
	}
};

/////////////////////////////////////////////////////////////////////////////
// CChartView form view

struct SeriesPoint
{
	double x,y,z;
	CString _x,_y,_z;
	void SetX(double xx) {x=xx;_x=ToString(x);}
	void SetY(double yy) {y=yy;_y=ToString(y);}
	void SetZ(double zz) {z=zz;_z=ToString(z);}
	void SetM(double xx, int fmt = 1) {x=xx;_x=FormatStat(x,fmt);}
	SeriesPoint() {x=y=z=0;_x=_y=_z=_T("");}
	SeriesPoint(double xx, double yy, double zz=0) {x=xx;y=yy;z=zz;_x=ToString(x);_y=ToString(y);_z=ToString(z);}
	SeriesPoint(const SeriesPoint& src) {x=src.x;y=src.y;z=src.z;_x=src._x;_y=src._y;_z=src._z;}
	SeriesPoint& operator=(const SeriesPoint& src) {x=src.x;y=src.y;z=src.z;_x=src._x;_y=src._y;_z=src._z;return *this;}
};

class CChartView : public CFormView
{
	DECLARE_DYNCREATE(CChartView)

public:
	CChartView();           // protected constructor used by dynamic creation

// Form Data
public:
	//{{AFX_DATA(CChartView)
	enum { IDD = IDD_VIEW_CHART };
	//CXTPComboBox	m_cboPosition;
	//CXTPButton	m_chkShowLabels;


	CXTPButton    m_wndChartStyle_Btn;
	CXTPComboBox  m_wndChartStyle;
	CXTPComboBox  m_wndAppearance;
	CXTPComboBox  m_wndPalette;
	

	//}}AFX_DATA

	CStringArray m_arrChartStyle;
	CStringArray m_arrAppearance;
	CStringArray m_arrPalette;

	UINT    m_nTimer;
	UINT    m_nChartStyle;

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CChartView)
public:
	virtual void OnInitialUpdate();
protected:
	virtual void DoDataExchange(CDataExchange* pDX); 
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	//}}AFX_VIRTUAL

	//}}AFX_VIRTUAL
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	virtual void OnBeginPrinting(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnEndPrinting(CDC* pDC, CPrintInfo* pInfo);
	//}}AFX_VIRTUAL
	void OnPrint(CDC* pDC, CPrintInfo* pInfo);
	void OnPrepareDC(CDC* pDC, CPrintInfo* pInfo);

	// Implementation
protected:
	virtual ~CChartView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

// Implementation
public:
	
	// Generated message map functions
	//{{AFX_MSG(CChartView)
	afx_msg void OnCbnSelchangeComboChartStyle();
	afx_msg void OnCbnSelchangeComboAppearance();
	afx_msg void OnCbnSelchangeComboPalette();
	afx_msg void OnBtnClickedChartStyle();
	afx_msg void OnBtnDropDownChartStyle();

	void CreateChart();
	void ClearChartSeries();
	void AddChartSeries(CString strSeriesName, vector<SeriesPoint>& vecSeries, CXTPChartSeriesStyle* pStyle, BOOL bAddDiagram=FALSE);
	void AddChartSideBarSeries(int idx, CString strSeriesName, vector<SeriesPoint>& vecSeries, BOOL bAddDiagram=FALSE);
	void AddChartPieSeries(CString strSeriesFormat, vector<SeriesPoint>& vecSeries, int nDoughnut=0);
	void SaveAsImage(CSize szBounds);
	void SetChartTitle(CString strTitle, CString strSubTitle);

	// Bar
	void CreateChartBar(CString strSeriesName, vector<SeriesPoint>& vecSeries);
	void CreateChartStackedBar(CString strSeriesName, vector<SeriesPoint>& vecSeries);
	void CreateChartSideStackedBar(CString strSeriesName, vector<SeriesPoint>& vecSeries);
	int GetSeriesCount();
	CXTPChartSeries* GetSeries(int index);
	CString GetSeriesName(int index);
	void ShowSeries(int index, BOOL bShowSeries);
	void ShowLabels(BOOL bShowLabels);
	void SetLabelPosition(int nPosition);
	void SetRotated(BOOL bRotated);
	void SetChartGroup(int nChartGroup);

	// Scatter Bubble Point
	void CreateChartScatter(CString strSeriesName, vector<SeriesPoint>& vecSeries);
	void CreateChartBubble(CString strSeriesFormat, vector<SeriesPoint>& vecSeries);
	void SetScatterAngle(int nScatterAngle);
	void SetBubbleTransparency(int nTransparency);
	void SetBubbleSize(double fBubbleMinSize, double fBubbleMaxSize);

	// Line
	void CreateChartOrbit(CString strSeriesName);
	void CreateChartLine(CString strSeriesName, vector<SeriesPoint>& vecSeries);
	void CreateChartStepLine(CString strSeriesName, vector<SeriesPoint>& vecSeries);
	void ShowMarkers(BOOL bShowMarkers);
	void SetMarkerSize(int nMarkerSize);
	void SetMarkerType(int nMarkerType);
	void SetInvertedStep(BOOL bInvertedStep);

	// Pie
	void CreateChartPie(CString strSeriesFormat, vector<SeriesPoint>& vecSeries, int nDoughnut=0);
	void CreateChartPie3D(CString strSeriesFormat, vector<SeriesPoint>& vecSeries, int nDoughnut=0);
	void SetnExplodedPoints(int nExplodedPoints);
	void SetDoughnut(int nDoughnut);

	// FastLine
	void AddPoint();
	void AddPoint(vector<SeriesPoint>* pVecSeries);
	void CreateChartFastLine(int nSeries=1, int nInterval=100, BOOL bAntialiased=TRUE);
	void CreateChartFastLine(CString strSeriesName, int nInterval, BOOL bAntialiased);
	void SetSeries(int nSeries, int nInterval, BOOL bAntialiased);
	void SetInterval(int nInterval);
	void GoIntervalStep(int nStep);
	void SetInterlaced(BOOL bInterlaced);
	void SetAntialiased(BOOL m_bAntialiased);

	// Chart From Builder File
	void CreateChartFromFile();

	//Multiple Diagrams
	void CreateChartDiagrams(CString strSeriesName, vector<SeriesPoint>& vecSeries, int nDoughnut=0);


	//}}AFX_MSG
	afx_msg void OnFileOpen();
	afx_msg void OnFileSave();
	afx_msg void OnTimer(UINT_PTR nIDEvent);
	afx_msg void OnDestroy();
	afx_msg void OnSize(UINT nType, int cx, int cy);

	DECLARE_MESSAGE_MAP()

private:
	CBrush m_hBrush;
	CChartBorder<CXTPChartControl> m_wndChartControl;
	CResizeGroupBox m_wndGroupBoxLabels;

	int m_nTopGap;
	int m_nLeftGap;
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PAGECHART_H__F31A2B31_B7F8_49D2_B748_57B38AF51C5F__INCLUDED_)
