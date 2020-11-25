#if !defined(AFX_TASKTRACKVIEW_H__F31A2B31_B7F8_49D2_B748_57B38AF51C5F__INCLUDED_)
#define AFX_TASKTRACKVIEW_H__F31A2B31_B7F8_49D2_B748_57B38AF51C5F__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// TaskTrackView.h : header file

/////////////////////////////////////////////////////////////////////////////
// CTaskTrackView

class CRibbonReportDoc;
class CTaskTrackView : public CXTPResizeFormView
{
	DECLARE_DYNCREATE(CTaskTrackView)
	// Construction
public:
	CTaskTrackView();	// standard constructor
	CRibbonReportDoc* GetDocument();

	struct TASKTRACKITEM
	{
		CString code;
		vector<CString> prjs;
		CTime   bct;
		CTime   ect;
		int     clr;
		BOOL    key;

		TASKTRACKITEM(CString c, CString p, CTime b, CTime e, int i=0, BOOL k=FALSE)
		{
			code = c;
			prjs.push_back(p);
			bct = b;
			ect = e;
			clr = i;
			key = k;
		}
		TASKTRACKITEM(char* c, char* p, CTime b, CTime e, int i=0, BOOL k=FALSE)
		{
			code = c;
			prjs.push_back(CXTPString(p).t_str());
			bct = b;
			ect = e;
			clr = i;
			key = k;
		}
		TASKTRACKITEM(CString c, CString p, COleDateTime b, COleDateTime e, int i=0, BOOL k=FALSE)
		{
			code = c;
			prjs.push_back(p);

			SYSTEMTIME st;
			if(b.GetAsSystemTime(st))
				bct = CTime(st);
			else
				bct = CTime(b.GetYear(),b.GetMonth(),b.GetDay(),b.GetHour(),b.GetMinute(),b.GetSecond());

			if(e.GetAsSystemTime(st))
				ect = CTime(st);
			else
				ect = CTime(b.GetYear(),b.GetMonth(),b.GetDay(),b.GetHour(),b.GetMinute(),b.GetSecond());

			clr = i;
			key = k;
		}
		TASKTRACKITEM(char* c, char* p, COleDateTime b, COleDateTime e, int i=0, BOOL k=FALSE)
		{
			code = c;
			prjs.push_back(CXTPString(p).t_str());

			SYSTEMTIME st;
			if(b.GetAsSystemTime(st))
				bct = CTime(st);
			else
				bct = CTime(b.GetYear(),b.GetMonth(),b.GetDay(),b.GetHour(),b.GetMinute(),b.GetSecond());

			if(e.GetAsSystemTime(st))
				ect = CTime(st);
			else
				ect = CTime(b.GetYear(),b.GetMonth(),b.GetDay(),b.GetHour(),b.GetMinute(),b.GetSecond());

			clr = i;
			key = k;
		}
		
		TASKTRACKITEM(const TASKTRACKITEM& src)
		{
			code = src.code;
			prjs = src.prjs;
			bct = src.bct;
			ect = src.ect;
			clr = src.clr;
			key = src.key;
		}
		TASKTRACKITEM& operator=(const TASKTRACKITEM& src)
		{
			code = src.code;
			prjs = src.prjs;
			bct = src.bct;
			ect = src.ect;
			clr = src.clr;
			key = src.key;
			return *this;
		}

		void add(char* p) {prjs.push_back(CXTPString(p).t_str());}
		void add(CString p) {prjs.push_back(p);}
	};

	// Dialog Data
	//{{AFX_DATA(CTaskTrackView)
	enum { IDD = IDD_VIEW_TASKTRACK };
	CSliderCtrl	m_wndSlider;
	CScrollBar	m_wndScrollBar;
	CXTPTrackControl m_wndTrackControl;
	vector<TASKTRACKITEM> m_vecRecord;
	int   m_nTimeStep;
	BOOL  m_bTimeStepAuto;
	//}}AFX_DATA

	void Import();
	void Export();

	// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CChartView)
public:
	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	virtual void OnInitialUpdate();
protected:
	virtual void DoDataExchange(CDataExchange* pDX); 
	virtual void OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar); 
	virtual CScrollBar* GetScrollBarCtrl(int nBar) const;

	void RepositionControls();

	// Implementation
protected:
	virtual ~CTaskTrackView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Implementation
protected:
	//-----------------------------------------------------------------------
	// Summary:
	//     This method is called to print single page of report control.
	// Parameters:
	//     pDC         - Pointer to a device context for page output.
	//     pInfo       - Points to a CPrintInfo structure that describes the
	//                   current print job.
	//     rcPage      - Page bounding rectangle
	//     nIndexStart - First row to print
	// Remarks:
	//     This method prints page header, page footer and call PrintReport method.
	// Returns:
	//     Index of last printed row
	//-----------------------------------------------------------------------
	virtual long PrintPage(CDC* pDC, CPrintInfo* pInfo, CRect rcPage, long nIndexStart);

	//-----------------------------------------------------------------------
	// Summary:
	//     This method is called to print report control (columns header and rows)
	//     on the page.
	// Parameters:
	//     pDC         - Pointer to a device context for page output.
	//     pInfo       - Points to a CPrintInfo structure that describes the current print job.
	//     rcPage      - Report bounding rectangle on the page
	//     nIndexStart - First row to print
	// Remarks:
	//     This method call PrintHeader, PrintRows methods.
	// Returns:
	//     Index of last printed row
	//-----------------------------------------------------------------------
	virtual long PrintTrack (CDC* pDC, CPrintInfo* pInfo, CRect rcPage, long nIndexStart);

	//-----------------------------------------------------------------------
	// Summary:
	//     Returns calculated rows height.
	// Parameters:
	//  pRows - CXTPReportRows*
	//  nTotalWidth - Width of the row
	//  nMaxHeight - The maximum rows height to stop calculation.
	//                  Set this parameter as -1 to calculate all rows height.
	// Returns:
	//     The height of the default rectangle where row's items will draw.
	// Example:
	//     <code>int nHeaderRowsHeight = GetRowHeight(pDC, pRow)</code>
	//-----------------------------------------------------------------------
	virtual int GetRowsHeight(CXTPReportRows* pRows, int nTotalWidth, int nMaxHeight = -1);

	//-----------------------------------------------------------------------
	// Summary:
	//     This method is called to print header of each page.
	// Parameters:
	//     pDC      - Pointer to a device context for page output.
	//     rcHeader - Header bounding rectangle
	//-----------------------------------------------------------------------
	virtual void PrintHeader(CDC* pDC, CRect rcHeader);

	int GetColumnWidth(CXTPReportColumn* pColumnTest, int nTotalWidth);

	//-----------------------------------------------------------------------
	// Summary:
	//     This method is called to print footer of each page.
	// Parameters:
	//     pDC      - Pointer to a device context for page output.
	//     rcFooter - Header bounding rectangle
	//-----------------------------------------------------------------------
	virtual void PrintFooter(CDC* pDC, CRect rcFooter);

	//-----------------------------------------------------------------------
	// Summary:
	//     This method is called to draw all rows inside bounding rectangle.
	// Parameters:
	//     pDC         - Pointer to a device context for page output.
	//     rcRows      - Bounding rectangle of rows
	//     nIndexStart - First row to print
	//     pPrintedRowsHeight - Height of the printed rows.
	// Returns:
	//     Index of last printed row
	//-----------------------------------------------------------------------
	virtual int PrintRows(CDC* pDC, CRect rcRows, long nIndexStart, int* pPrintedRowsHeight = NULL);

	//-----------------------------------------------------------------------
	// Summary:
	//     This method is called by PrintRows to print single row.
	// Parameters:
	//     pDC   - Pointer to a device context for page output.
	//     pRow  - Row to print.
	//     rcRow - Bounding rectangle of row
	//     nPreviewHeight - Height of preview
	//-----------------------------------------------------------------------
	virtual void PrintRow(CDC* pDC, CXTPReportRow* pRow, CRect rcRow, int nPreviewHeight);

	//-----------------------------------------------------------------------
	// Summary:
	//     This method is called to print the page header of the report control
	// Parameters:
	//     pDC              - Print device context
	//     pInfo            - Points to a CPrintInfo structure that describes the current print job.
	//     rcPage           - Page print area
	//     bOnlyCalculate   - TRUE = only calculate
	//                        FALSE = calculate and print
	//     nPageNumber      - The printed page number
	//     nNumberOfPages   - The total number of printed pages
	//     nHorizontalPageNumber - The printed horizontal page number
	//     nNumberOfHorizontalPages - The total number of printed horizontal pages
	// Returns:
	//     The header height in device units.
	//-----------------------------------------------------------------------
	virtual int PrintPageHeader(CDC* pDC, CPrintInfo* pInfo, CRect rcPage, BOOL bOnlyCalculate, int nPageNumber, int nNumberOfPages, int nHorizontalPageNumber, int nNumberOfHorizontalPages);

	//-----------------------------------------------------------------------
	// Summary:
	//     This method is called to print the page footer of the report control
	// Parameters:
	//     pDC              - Print device context
	//     pInfo            - Points to a CPrintInfo structure that describes the current print job.
	//     rcPage           - Page print area
	//     bOnlyCalculate   - TRUE = only calculate
	//                        FALSE = calculate and print
	//     nPageNumber      - The printed page number
	//     nNumberOfPages   - The total number of printed pages
	//     nHorizontalPageNumber - The printed horizontal page number
	//     nNumberOfHorizontalPages - The total number of printed horizontal pages
	// Returns:
	//     The footer height in device units.
	//-----------------------------------------------------------------------
	virtual int PrintPageFooter(CDC* pDC, CPrintInfo* pInfo, CRect rcPage, BOOL bOnlyCalculate, int nPageNumber, int nNumberOfPages, int nHorizontalPageNumber, int nNumberOfHorizontalPages);

	//-----------------------------------------------------------------------
	// Summary:
	//     This method prints either header or footer rows.
	// Parameters:
	//     pDC      - Pointer to a device context for page output.
	//     rcClient - Bounding rectangle of fixed rows
	//     bHeaderRows - If TRUE, prints the header rows.
	// Returns:
	//     Height of printed rows.
	//-----------------------------------------------------------------------
	int  PrintFixedRows(CDC* pDC, CRect rcClient, BOOL bHeaderRows);

	//-----------------------------------------------------------------------
	// Summary:
	//     This method prints either header or footer divider.
	// Parameters:
	//     pDC  - Pointer to a device context for page output.
	//     rc   - Bounding rectangle of the divider.
	//     bHeaderRows - If TRUE, prints the header divider.
	// Returns:
	//     Height of printed rows.
	//-----------------------------------------------------------------------
	int PrintFixedRowsDivider(CDC* pDC, const CRect& rc, BOOL bHeaderRows);

	int SetupStartCol(CDC* pDC, CPrintInfo* pInfo);

	CXTPReportViewPrintOptions* GetPrintOptions();

	//{{AFX_VIRTUAL(CXTPReportView)
	virtual BOOL PaginateTo(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnPrepareDC(CDC* pDC, CPrintInfo* pInfo);
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	virtual void OnBeginPrinting(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnEndPrinting(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnPrint(CDC* pDC, CPrintInfo* pInfo);
	//}}AFX_VIRTUAL


	BOOL m_bClassicStyle;

	// Generated message map functions
	//{{AFX_MSG(CTaskTrackView)
	afx_msg void OnFileOpen();
	afx_msg void OnFileSave();
	afx_msg void OnFilePrint();
	afx_msg void OnFilePrintSetup();
	afx_msg void OnEditUndo();
	afx_msg void OnUpdateEditUndo(CCmdUI* pCmdUI);
	afx_msg void OnEditRedo();
	afx_msg void OnUpdateEditRedo(CCmdUI* pCmdUI);
	afx_msg void OnEditCopy();
	afx_msg void OnUpdateEditCopy(CCmdUI* pCmdUI);
	afx_msg void OnEditCut();
	afx_msg void OnUpdateEditCut(CCmdUI* pCmdUI);
	afx_msg void OnEditPaste();
	afx_msg void OnUpdateEditPaste(CCmdUI* pCmdUI);
	afx_msg void OnToolsImport();
	afx_msg void OnToolsExport();
	afx_msg void OnDestroy();
	afx_msg void OnUseTimeOffsetMode();
	afx_msg void OnViewGroupbox();
	afx_msg void OnUpdateViewGroupbox(CCmdUI* pCmdUI);
	afx_msg void OnViewClassicStyle();
	afx_msg void OnFlexibleDrag();
	afx_msg void OnUpdateViewClassicStyle(CCmdUI* pCmdUI);
	afx_msg void OnUpdateFlexibleDrag(CCmdUI* pCmdUI);
	afx_msg void OnSnapToBlocks();
	afx_msg void OnUpdateSnapToBlocks(CCmdUI* pCmdUI);
	afx_msg void OnSnapToMarkers();
	afx_msg void OnUpdateSnapToMarkers(CCmdUI* pCmdUI);
	afx_msg void OnAllowblockmove();
	afx_msg void OnUpdateAllowblockmove(CCmdUI* pCmdUI);
	afx_msg void OnAllowblockscale();
	afx_msg void OnUpdateAllowblockscale(CCmdUI* pCmdUI);
	afx_msg void OnAllowRowResize();
	afx_msg void OnUpdateAllowRowResize(CCmdUI* pCmdUI);
	afx_msg void OnScaleOnResize();
	afx_msg void OnUpdateScaleOnResize(CCmdUI* pCmdUI);
	afx_msg void OnAllowblockRemove();
	afx_msg void OnUpdateAllowblockRemove(CCmdUI* pCmdUI);
	afx_msg void OnShowWorkarea();
	afx_msg void OnUpdateShowWorkarea(CCmdUI* pCmdUI);
	//}}AFX_MSG
	afx_msg void OnRClick(NMHDR * pNotifyStruct, LRESULT * result);
	afx_msg void OnHeaderRClick(NMHDR * pNotifyStruct, LRESULT * result);
	afx_msg void OnValueChanged(NMHDR * pNotifyStruct, LRESULT * result);
	afx_msg void OnDblClick(NMHDR * pNotifyStruct, LRESULT * result);

	afx_msg void OnTrackSliderChanged(NMHDR * pNotifyStruct, LRESULT * result);
	afx_msg void OnTrackTimeLineChanged(NMHDR * pNotifyStruct, LRESULT * result);
	afx_msg void OnTrackMarkerChanged(NMHDR * pNotifyStruct, LRESULT * result);
	afx_msg void OnTrackBlockChanged(NMHDR * pNotifyStruct, LRESULT * result);
	afx_msg void OnTrackSelectedBlocksChanged(NMHDR * pNotifyStruct, LRESULT * result);

	DECLARE_MESSAGE_MAP()

	BOOL m_bSwitchMode; 
	BOOL m_bShowRowNumber;
	BOOL m_bPrintDirect;
	BOOL m_bPrintSelection;  

	CBitmap m_bmpGrayDC;
	CXTPReportViewPrintOptions* m_pPrintOptions;

	UINT m_nStartColumn;
	UINT m_nEndColumn;
	UINT m_nStartIndex;

	CUIntArray m_aPageStart;
	BOOL m_bPaginated;
};

/////////////////////////////////////////////////////////////////////////////
AFX_INLINE CXTPReportViewPrintOptions* CTaskTrackView::GetPrintOptions()
{
	return m_pPrintOptions;
}

#ifndef _DEBUG  // debug version in TaskPanelView.cpp
inline CRibbonReportDoc* CTaskTrackView::GetDocument()
{ return (CRibbonReportDoc*)m_pDocument; }
#endif

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif
