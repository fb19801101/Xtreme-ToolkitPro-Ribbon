// ReportRecordView.h : interface of the CReportRecordView class
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

#if !defined(AFX_REPORTRECORDVIEW_H__0026E756_0D53_4DD8_8B2B_D3795245FBAE__INCLUDED_)
#define AFX_REPORTRECORDVIEW_H__0026E756_0D53_4DD8_8B2B_D3795245FBAE__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "MainFrm.h"
#include "ReportListBoxControl.h"

#define XTP_REPORT_ITEM_CTRL_NULL       0x00000000L
#define XTP_REPORT_ITEM_CTRL_LINK       0x00000010L
#define XTP_REPORT_ITEM_CTRL_BUTTON     0x00000020L
#define XTP_REPORT_ITEM_CTRL_BOLD       0x00000100L
#define XTP_REPORT_ITEM_CTRL_ALIGN      0x00000200L
#define XTP_REPORT_ITEM_CTRL_COLOR      0x00001000L
#define XTP_REPORT_ITEM_CTRL_FORM       0x00002000L
#define XTP_REPORT_ITEM_CTRL_CHECKBOX   0x00010000L
#define XTP_REPORT_ITEM_CTRL_COMBOBOX   0x00020000L
#define XTP_REPORT_ITEM_CTRL_EXPAND     0x00100000L
#define XTP_REPORT_ITEM_CTRL_SPIN       0x00200000L
#define XTP_REPORT_TABLE_TYPE_XL        0x00010L
#define XTP_REPORT_TABLE_TYPE_TP        0x00020L
#define XTP_REPORT_TABLE_TYPE_TV        0x00100L
#define XTP_REPORT_TABLE_TYPE_TB        0x00200L

typedef struct STRU_RECORDITEMCTRLDATA
{
public:
	int column;
	DWORD  ctrl;
	CString table;
	CString fields;
	CString sql;
	BOOL visible;
	BOOL header;
	BOOL editable;
	DWORD  alignment;
	DWORD_PTR ptr;
	XTPREPORTMSADODB::_RecordsetPtr rst;

	STRU_RECORDITEMCTRLDATA()
	{
		column = -1;
		ctrl = XTP_REPORT_ITEM_CTRL_NULL;
		table = _T("");
		fields = _T("");
		sql = _T("");
		header = FALSE;
		editable = TRUE;
		alignment = xtpItemControlUnknown;
		ptr = NULL;
		rst = NULL;
	}

	STRU_RECORDITEMCTRLDATA(int _column, DWORD _ctrl, CString _table, CString _fields, CString _sql, XTPREPORTMSADODB::_RecordsetPtr _rst, BOOL _visible = TRUE, BOOL _header = FALSE, BOOL _editable = TRUE, DWORD _alignment = xtpItemControlUnknown, DWORD_PTR _ptr = NULL)
	{
		column = _column;
		ctrl = _ctrl;
		table = _table;
		fields = _fields;
		sql = _sql;
		visible = _visible;
		header = _header;
		editable = _editable;
		alignment = _alignment;
		ptr = _ptr;
		rst = _rst;
	}

	STRU_RECORDITEMCTRLDATA(const STRU_RECORDITEMCTRLDATA& src)
	{
		column = src.column;
		ctrl = src.ctrl;
		table = src.table;
		fields = src.fields;
		sql = src.sql;
		visible = src.visible;
		header = src.header;
		editable = src.editable;
		alignment = src.alignment;
		ptr = src.ptr;
		rst = src.rst;
	}
	
	STRU_RECORDITEMCTRLDATA& operator=(const STRU_RECORDITEMCTRLDATA& src)
	{
		column = src.column;
		ctrl = src.ctrl;
		table = src.table;
		fields = src.fields;
		sql = src.sql;
		visible = src.visible;
		header = src.header;
		editable = src.editable;
		alignment = src.alignment;
		ptr = src.ptr;
		rst = src.rst;
		return *this;
	}
}RCDICTRLDATA,*LPRCDICTRLDATA;
typedef xtp_vector<RCDICTRLDATA> RCDICTRLDATALIST;

class CRibbonReportDoc;
class CReportRecordPaintManager;
class CPropertiesView;
class CReportListBoxControl;

class CReportRecordView : public CXTPReportView
{
protected: // create from serialization only
	CReportRecordView();
	DECLARE_DYNCREATE(CReportRecordView)

// Attributes
public:
	CRibbonReportDoc* GetDocument();

// Operations
public:
	void SetTable(CString strTable, BOOL bAuto = TRUE);
	void SetView(CString strView, BOOL bAuto = TRUE);
	void SetPreview(CString strPreview, BOOL bAuto = TRUE);
	void SetType(UINT nType = XTP_REPORT_TABLE_TYPE_TV);
	CString GetCurTable();
	CString GetTable();
	CString GetView();
	CString GetPreview();
	CString GetBackup();
	int GetType();
	BOOL IsTable();
	BOOL IsView();
	BOOL IsPreview();
	void AddRcdToRst();
	void SetRcdToRst(CXTPReportRecordItem* pItem = NULL);
	void DelRcdOfRst();
	void EncodeRcdOfRst(CXTPReportRecordItem* pItem);
	void DecodeRcdOfRst(CXTPReportRecordItem* pItem);
	BOOL FindInReport();
	void SetAutoUpdateSql(BOOL bAutoUpdateSql = TRUE);
	BOOL IsAutoUpdateSql();

	void ShowFilterEdit();
	void ShowFieldSubList();
	void ShowDataListBox();
	void DataBindRecordset(XTPREPORTMSADODB::_RecordsetPtr rst = NULL, BOOL init = TRUE);
	void ShowGroupRowFormula(CString strFormula);
	void ShowHeaderRows(BOOL bShow);
	void ShowFooterRows(BOOL bShow);
	void Populate();
	void PopulateHeaderRows();
	void PopulateFooterRows();
	CXTPReportSelectedRows* GetSelectedRows();
	CXTPReportRow* GetFocusedRow();
	CXTPReportColumn* GetFocusedColumn();
	CXTPReportRecords* GetRecords();
	CXTPReportColumns* GetColumns();
	CXTPReportRows* GetRows();
	CXTPReportPaintManager* GetPaintManager();
	CXTPImageManager* GetImageManager();
	CXTPMarkupContext* GetMarkupContext();
	BOOL IsShowHeaderRows();
	BOOL IsShowFooterRows();
	void AllowEdit(BOOL bEdit);
	void AllowHeaderEdit(BOOL bEdit);
	void AllowFooterEdit(BOOL bEdit);
	BOOL IsAllowEdit();
	BOOL IsAllowHeaderEdit();
	BOOL IsAllowFooterEdit();
	void AllowMultipleSelection(BOOL bAllow);
	void AllowFocusSubItems(BOOL bAllow);
	BOOL IsAllowMultipleSelection();
	BOOL IsAllowFocusSubItems();
	void ShowGroupBox(BOOL bShow);
	void ExpandAll();
	void CollapseAll();
	void ExpandCurAll(CXTPReportRow* pRow);
	void CollapseCurAll(CXTPReportRow* pRow);
	void SetGridStyle(BOOL bVert, XTPReportGridStyle style);
	XTPReportGridStyle GetGridStyle(BOOL bVert);
	COLORREF SetGridColor(COLORREF clrGrid);
	COLORREF GetGridColor();
	void SetEnablePreview(BOOL bEnable = FALSE);
	BOOL IsEnablePreview();
	void SetEnableMarkup(BOOL bEnable = FALSE);
	BOOL IsEnableMarkup();

	void ShowColumnMenu(BOOL bShow = TRUE);
	void ShowItemMenu(BOOL bShow = TRUE);
	BOOL IsShowColumnMenu();
	BOOL IsShowItemMenu();
	void SetImageList(UINT nBmpID);
	void SetImageList(CImageList* pImageList);

	void SetGroupsOrder(CXTPReportColumn* pColumn);
	CXTPReportColumnOrder* GetGroupsOrder();

	int AddRecord(CXTPReportRecord* pRecord, CXTPReportRecord* pParentRecord);
	int AddRow(CXTPReportRow* pRow, CXTPReportRow* pParentRow);
	void AddChildRecords(CXTPReportRecord* pParentRecord, CXTPReportRecords* pRecords);
	void AddChildRows(CXTPReportRow* pParentRow, CXTPReportRows* pRows);
	void InsertRecord(int nIndex, CXTPReportRecord* pRecord, CXTPReportRecord* pParentRecord);
	void InsertRow(int nIndex, CXTPReportRow* pRow, CXTPReportRow* pParentRow);
	BOOL RemoveRecord(CXTPReportRecord* pRecord, BOOL bAdjustLayout, BOOL bRemoveFromParent);
	BOOL RemoveRow(CXTPReportRow* pRow, BOOL bAdjustLayout);
	void UpdateRecord(CXTPReportRecord* pRecord);
	void UpdateRecord(CXTPReportRecord* pRecord, BOOL bUpdateChildren);
	void UpdateRow(CXTPReportRow* pRow, BOOL bUpdateChildren);
	void UpdateRecordItems(CXTPReportRecord* pRecord);
	CXTPReportColumn* AddColumn(CXTPReportColumn* pColumn);
	CXTPReportColumn* AddColumn(int nItemIndex, LPCTSTR strName, int nWidth, BOOL bAutoSize = TRUE, int nIconID = XTP_REPORT_NOICON , BOOL bSortable = TRUE, BOOL bVisible = TRUE);
	CXTPReportColumn* AddColumn(int nItemIndex, LPCTSTR strDisplayName, LPCTSTR strInternalName, int nWidth, BOOL bAutoSize = TRUE, int nIconID = XTP_REPORT_NOICON , BOOL bSortable = TRUE, BOOL bVisible = TRUE);
	CXTPReportColumn* SetColumn(int nItemIndex, LPCTSTR strName, int nWidth, BOOL bAutoSize = TRUE, int nIconID = XTP_REPORT_NOICON , BOOL bSortable = TRUE, BOOL bVisible = TRUE);
	CXTPReportColumn* SetColumn(int nItemIndex, LPCTSTR strDisplayName, LPCTSTR strInternalName, int nWidth, BOOL bAutoSize = TRUE, int nIconID = XTP_REPORT_NOICON , BOOL bSortable = TRUE, BOOL bVisible = TRUE);
	void SetColumnStyle(XTPReportColumnStyle columnStyle = xtpReportColumnResource);
	void SetToolTipStyle(XTPToolTipStyle tooltipStyle = xtpToolTipResource);
	void SetRowGroup(int nRolBgen, int nRolEnd);

	void SetPlusMinus(int nColumn, BOOL bPlusMinus = TRUE, BOOL bExpand = TRUE, int nNextVisualBlock = 0);
	RCDICTRLDATALIST& GetRecordItemCtrlDataList();
	void AddRecordItemCtrlData(RCDICTRLDATA& itemCtrlData);
	void DelRecordItemCtrlData(int index);
	void InitRecordItemControlDataList();
	void SetRecordItemControl();
	void SetRecordItemControl(RCDICTRLDATA& itemCtrlData);
	void SetRecordItemControl(RCDICTRLDATALIST& vecItemCtrlData);
	void SetRecordItemControl(int column, DWORD ctrl, CString table, CString fields = _T(""), CString sql = _T(""), XTPREPORTMSADODB::_RecordsetPtr rst = NULL, BOOL visible = TRUE, BOOL header = FALSE, BOOL editable = TRUE, DWORD alignment = xtpItemControlUnknown, DWORD_PTR ptr = NULL);
	void SetHeaderRecordItemControl();
	void SetHeaderRecordItemControl(RCDICTRLDATA& itemCtrlData);
	void SetHeaderRecordItemControl(RCDICTRLDATALIST& vecItemCtrlData);
	void SetHeaderRecordItemControl(int column, DWORD ctrl, CString table, CString fields = _T(""), CString sql = _T(""), XTPREPORTMSADODB::_RecordsetPtr rst = NULL, BOOL visible = TRUE, BOOL header = FALSE, BOOL editable = TRUE, DWORD alignment = xtpItemControlUnknown, DWORD_PTR ptr = NULL);
	void SetFooterRecordItemControl();
	void SetFooterRecordItemControl(RCDICTRLDATA& itemCtrlData);
	void SetFooterRecordItemControl(RCDICTRLDATALIST& vecItemCtrlData);
	void SetFooterRecordItemControl(int column, DWORD ctrl, CString table, CString fields = _T(""), CString sql = _T(""), XTPREPORTMSADODB::_RecordsetPtr rst = NULL, BOOL visible = TRUE, BOOL header = FALSE, BOOL editable = TRUE, DWORD alignment = xtpItemControlUnknown, DWORD_PTR ptr = NULL);
	void SetRecordItemEditable();
	void SetRecordItemEditable(int nColumn, BOOL bEditable = FALSE);
	void SetRecordItemEditable(xtp_vector<int> nColumns, BOOL bEditable = FALSE);
	void SetRecordItemColor(int nColumn, COLORREF clrText = RGB(0,0,0), COLORREF clrBackground = RGB(238,238,238));
	void SetRecordItemColor(xtp_vector<int> vecColumn, COLORREF clrText = RGB(0,0,0), COLORREF clrBackground = RGB(238,238,238));
	
	void SetPreviewRecord(int nRow = -1, CString strPreview = _T("this is a test button and hyperlink record!"));
	
	void SetColumnEditable(int nColumn, BOOL bEditable = FALSE);
	void SetColumnEditable(xtp_vector<int> nColumns, BOOL bEditable = FALSE);
	void SetColumnVisible(int nColumn, BOOL bVisible = FALSE);
	void SetColumnVisible(xtp_vector<int> nColumns, BOOL bVisible = FALSE);
	void SetColumnSortable(int nColumn, BOOL bSortable = FALSE);
	void SetColumnSortable(xtp_vector<int> nColumns, BOOL bSortable = FALSE);
	void SetColumnGroupable(int nColumn, BOOL bGroupable = FALSE);
	void SetColumnGroupable(xtp_vector<int> nColumns, BOOL bGroupable = FALSE);
	void SetColumnFixed(int nColumn, BOOL bFixed = FALSE);
	void SetColumnFixed(xtp_vector<int> nColumns, BOOL bFixed = FALSE);
	void SetColumnFrozen(int nColumn, BOOL bFrozen = FALSE);
	void SetColumnFrozen(xtp_vector<int> nColumns, BOOL bFrozen = FALSE);

	void LoadReportState();
	void SaveReportState();
	void SetCheckBoxState(int index);

	CXTPReportControl& ShowReportPerfomance(CXTPReportRecordItemVariant*& pItem, bool bHeader = false);
	CXTPReportControl& ShowReportPerfomance(int nColumn, bool bHeader = false);
	CXTPReportControl& ShowReportProperties();

public:
	CFrameWnd* m_pReportFrame;
	CXTPReportSubListControl m_wndSubList;
	CXTPReportFilterEditControl m_wndFilterEdit;
	CReportListBoxControl m_wndListBox;
	CXTPReportRecordItem* m_pFocusItem;

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CReportRecordView)
	public:
	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	virtual void OnInitialUpdate();
	virtual BOOL PreTranslateMessage(MSG* pMsg);
	protected:
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	virtual void OnBeginPrinting(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnEndPrinting(CDC* pDC, CPrintInfo* pInfo);
	//}}AFX_VIRTUAL

// Implementation
public:
	virtual ~CReportRecordView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

// Generated message map functions
protected:
	//{{AFX_MSG(CReportRecordView)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnReportFoucsChanging(NMHDR* pNMHDR, LRESULT* /*result*/);
	afx_msg void OnReportValueChanged(NMHDR* pNMHDR, LRESULT* /*result*/);
	afx_msg void OnReportHyperlink(NMHDR* pNMHDR, LRESULT* /*result*/);
	afx_msg void OnReportItemButtonClick(NMHDR* pNMHDR, LRESULT* /*result*/);
	afx_msg void OnReportHeaderRClick(NMHDR* pNMHDR, LRESULT* /*result*/);
	afx_msg void OnReportConstraintSelecting(NMHDR* pNMHDR, LRESULT* /*result*/);
	afx_msg void OnReportChecked(NMHDR* pNMHDR, LRESULT* /*result*/);
	afx_msg void OnReportRowExpanded(NMHDR* pNMHDR, LRESULT* /*result*/);
	afx_msg void OnReportItemClick(NMHDR* pNMHDR, LRESULT* /*result*/);
	afx_msg void OnReportItemRClick(NMHDR* pNMHDR, LRESULT* /*result*/);
	afx_msg void OnReportItemDblClick(NMHDR* pNMHDR, LRESULT* /*result*/);
	//}}AFX_MSG
	afx_msg void OnDbTable();
	afx_msg void OnDbMssql();
	afx_msg void OnDbExcel();
	afx_msg void OnDbAccess();
	afx_msg void OnEditCopy();
	afx_msg void OnUpdateEditCopy(CCmdUI* pCmdUI);
	afx_msg void OnEditCut();
	afx_msg void OnUpdateEditCut(CCmdUI* pCmdUI);
	afx_msg void OnEditPaste();
	afx_msg void OnUpdateEditPaste(CCmdUI* pCmdUI);
	afx_msg void OnEditSelectAll();
	afx_msg void OnUpdateEditSelectAll(CCmdUI* pCmdUI);
	afx_msg void OnFileNew();
	afx_msg void OnFileOpen();
	afx_msg void OnFileSave();
	afx_msg void OnToolsImport();
	afx_msg void OnToolsExport();
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg void OnSetFocus(CWnd* pOldWnd);
	afx_msg void OnDestroy();
	//}}AFX_MSG

	afx_msg void OnReportShowGroupBox();
	afx_msg void OnUpdateReportShowGroupBox(CCmdUI* pCmdUI);
	afx_msg void OnReportEnablePreview();
	afx_msg void OnUpdateReportEnablePreview(CCmdUI* pCmdUI);
	afx_msg void OnReportMultipleselection();
	afx_msg void OnUpdateReportMultipleselection(CCmdUI* pCmdUI);
	afx_msg void OnReportRighttoleft();
	afx_msg void OnUpdateReportRighttoleft(CCmdUI* pCmdUI);
	afx_msg void OnReportMarkup();
	afx_msg void OnUpdateReportMarkup(CCmdUI* pCmdUI);
	afx_msg void OnReportWatermark();
	afx_msg void OnUpdateReportWatermark(CCmdUI* pCmdUI);
	afx_msg void OnReportFreezecolumns0();
	afx_msg void OnUpdateReportFreezecolumns0(CCmdUI* pCmdUI);
	afx_msg void OnReportFreezecolumns1();
	afx_msg void OnUpdateReportFreezecolumns1(CCmdUI* pCmdUI);
	afx_msg void OnReportFreezecolumns2();
	afx_msg void OnUpdateReportFreezecolumns2(CCmdUI* pCmdUI);
	afx_msg void OnReportFreezecolumns3();
	afx_msg void OnUpdateReportFreezecolumns3(CCmdUI* pCmdUI);
	afx_msg void OnReportFreezecolumnsDividerNone();
	afx_msg void OnUpdateReportFreezecolumnsDividerNone(CCmdUI* pCmdUI);
	afx_msg void OnReportFreezecolumnsDividerThin();
	afx_msg void OnUpdateReportFreezecolumnsDividerThin(CCmdUI* pCmdUI);
	afx_msg void OnReportFreezecolumnsDividerBold();
	afx_msg void OnUpdateReportFreezecolumnsDividerBold(CCmdUI* pCmdUI);
	afx_msg void OnReportFreezecolumnsDividerShade();
	afx_msg void OnUpdateReportFreezecolumnsDividerShade(CCmdUI* pCmdUI);
	afx_msg void OnReportFreezecolumnsDividerHeader();
	afx_msg void OnUpdateReportFreezecolumnsDividerHeader(CCmdUI* pCmdUI);
	afx_msg void OnReportAllowedit();
	afx_msg void OnUpdateReportAllowedit(CCmdUI* pCmdUI);
	afx_msg void OnReportEditonclick();
	afx_msg void OnUpdateReportEditonclick(CCmdUI* pCmdUI);
	afx_msg void OnReportFocussubitems();
	afx_msg void OnUpdateReportFocussubitems(CCmdUI* pCmdUI);
	afx_msg void OnReportFocusallitems();
	afx_msg void OnUpdateReportFocusallitems(CCmdUI* pCmdUI);
	afx_msg void OnReportAllowcolumnsremove();
	afx_msg void OnUpdateReportAllowcolumnsremove(CCmdUI* pCmdUI);
	afx_msg void OnReportAllowcolumnresize();
	afx_msg void OnUpdateReportAllowcolumnresize(CCmdUI* pCmdUI);
	afx_msg void OnReportAllowcolumnreorder();
	afx_msg void OnUpdateReportAllowcolumnreorder(CCmdUI* pCmdUI);
	afx_msg void OnReportAutomaticcolumnsizing();
	afx_msg void OnUpdateReportAutomaticcolumnsizing(CCmdUI* pCmdUI);
	afx_msg void OnReportAutomaticcolumnbestfit();
	afx_msg void OnUpdateReportAutomaticcolumnbestfit(CCmdUI* pCmdUI);
	afx_msg void OnReportFullColumnScrolling();
	afx_msg void OnUpdateReportFullColumnScrolling(CCmdUI* pCmdUI);
	afx_msg void OnReportAutoGrouping();
	afx_msg void OnUpdateReportAutoGrouping(CCmdUI* pCmdUI);
	afx_msg void OnReportHorizontal(UINT id);
	afx_msg void OnUpdateReportHorizontal(CCmdUI* pCmdUI);
	afx_msg void OnReportVertical(UINT id);
	afx_msg void OnUpdateReportVertical(CCmdUI* pCmdUI);
	afx_msg void OnReportLineColor(UINT id);
	afx_msg void OnUpdateReportLineColor(CCmdUI* pCmdUI);
	afx_msg void OnReportColumnStyle(UINT id);
	afx_msg void OnUpdateReportColumnStyle(CCmdUI* pCmdUI);
	afx_msg void OnReportGroupShade();
	afx_msg void OnUpdateReportGroupShade(CCmdUI* pCmdUI);
	afx_msg void OnReportGroupBold();	
	afx_msg void OnUpdateReportGroupBold(CCmdUI* pCmdUI);
	afx_msg void OnReportShowitemsingroups();
	afx_msg void OnUpdateReportShowitemsingroups(CCmdUI* pCmdUI);
	afx_msg void OnReportAutomaticformatting();
	afx_msg void OnUpdateReportAutomaticformatting(CCmdUI* pCmdUI);
	afx_msg void OnReportMultiline();
	afx_msg void OnUpdateReportMultiline(CCmdUI* pCmdUI);
	afx_msg void OnReportFindRecorditem();
	afx_msg void OnUpdateReportFindRecorditem(CCmdUI* pCmdUI);
	afx_msg void OnReportIconview();
	afx_msg void OnUpdateReportIconview(CCmdUI* pCmdUI);
	afx_msg void OnReportWysiwygprint();
	afx_msg void OnUpdateReportWysiwygprint(CCmdUI* pCmdUI);
	afx_msg void OnReportPerfomance();
	afx_msg void OnReportProperties();
	afx_msg void OnReportMerge();
	afx_msg void OnReportTreeEdit();
	afx_msg void OnReportFormula();
	afx_msg void OnReportDragDrop();

	DECLARE_MESSAGE_MAP()


private:
	CReportRecordPaintManager* m_pPaintManager;
	CXTPReportRecord* m_pFocusedRecord;
	CXTPReportRow* m_pTopRow;
	CImageList m_imgList;

	CString m_strTable;
	CString m_strView;
	CString m_strPreview;
	int m_nType;//XTP_REPORT_TABLE_TYPE_TV tv,XTP_REPORT_TABLE_TYPE_TP tp, XTP_REPORT_TABLE_TYPE_TB tb

	BOOL m_bAutomaticFormating;
	BOOL m_bMultilineSample;
	BOOL m_bWYSIWYG;
	BOOL m_bAllowEdit;
	BOOL m_bEditOnClick;
	BOOL m_bFocusSubItem;
	BOOL m_bFocusAllItem;
	BOOL m_bFindReportItem;
	BOOL m_bWatermark;
	BOOL m_bAutoBestFit;
	BOOL m_bAutoUpdateSql;

	BOOL m_bShowColumnMenu;
	BOOL m_bShowItemMenu;

	RCDICTRLDATALIST m_itemCtrlDataList;
};

#ifndef _DEBUG  // debug version in ReportRecordView.cpp
inline CRibbonReportDoc* CReportRecordView::GetDocument()
	{ return (CRibbonReportDoc*)m_pDocument; }
#endif

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_REPORTRECORDVIEW_H__0026E756_0D53_4DD8_8B2B_D3795245FBAE__INCLUDED_)
