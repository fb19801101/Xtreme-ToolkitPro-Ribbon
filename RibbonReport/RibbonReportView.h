// RibbonReportView.h : interface of the CRibbonReportView class
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

#if !defined(AFX_RIBBONREPORTVIEW_H__0026E756_0D53_4DD8_8B2B_D3795245FBAE__INCLUDED_)
#define AFX_RIBBONREPORTVIEW_H__0026E756_0D53_4DD8_8B2B_D3795245FBAE__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Report/ReportRecordView.h"

class CRibbonReportView : public CReportRecordView
{
protected: // create from serialization only
	CRibbonReportView();
	DECLARE_DYNCREATE(CRibbonReportView)

	// Attributes
public:

	// Operations
public:
	void SetReportRecordValue(CXTPReportSelectedRows* pRows);
	void MergePlateData();
	void MergePlateDataOledb();
	void ClacRailData();
	void SetChartViewDataColor(CXTPReportRecords* pRecords);
	void SetChartViewSumDataColor(CXTPReportRecords* pRecords);
	void ShowFinanceRate(CXTPReportSelectedRows* pRows);
	void ShowPlateHorizon(CXTPReportSelectedRows* pRows);
	void ShowPlateVertical(CXTPReportSelectedRows* pRows);
	void ShowPlateMileage(CXTPReportSelectedRows* pRows);
	void ShowPlateRideIn(CXTPReportSelectedRows* pRows);
	void ShowPlateRideOut(CXTPReportSelectedRows* pRows);
	void ShowPlateRate(CXTPReportSelectedRows* pRows);
	void ShowRailRide(CXTPReportSelectedRows* pRows);
	void ShowRailRate(CXTPReportSelectedRows* pRows);
	void ShowProblemRate(CXTPReportSelectedRows* pRows);


	// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CReportRecordView)
public:
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	virtual void OnInitialUpdate();
protected:
	//}}AFX_VIRTUAL
	CPoint m_ptLastSel;

	// Implementation
public:
	virtual ~CRibbonReportView();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
protected:
	//{{AFX_MSG(CReportRecordView)
	//}}AFX_MSG
	UINT m_idReportSetCmd,m_idCostManagerCmd,m_idMaterManagerCmd,m_idFinanceManagerCmd,m_idOrbitalManagerCmd,m_idProblemManagerCmd,m_idBudgetManagerCmd;
	afx_msg void OnReportSetCommand(UINT nID);
	afx_msg void OnCostManagerCommand(UINT nID);
	afx_msg void OnMaterManagerCommand(UINT nID);
	afx_msg void OnFinanceManagerCommand(UINT nID);
	afx_msg void OnOrbitalManagerCommand(UINT nID);
	afx_msg void OnProblemManagerCommand(UINT nID);
	afx_msg void OnPullWorkManagerCommand(UINT nID);
	afx_msg void OnPaneShowhideCommand(UINT nID);
	afx_msg void OnUpdatePaneShowhideCommand(CCmdUI* pCmdUI);
	//}}AFX_MSG

	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);

	afx_msg void OnUpdateRibbonTab(CCmdUI* pCmdUI);

	UINT m_idGroupOptionCmd;
	afx_msg void OnGroupOptionCommand(UINT nID);
	afx_msg void OnUpdateGroupOptionCommand(CCmdUI* pCmdUI);

	afx_msg void OnEditFormatPainter();
	afx_msg void OnEditUndo(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnEditRedo(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnUpdateEditFormatPainter(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditUndo(CCmdUI* pCmdUI);
	afx_msg void OnUpdateEditRedo(CCmdUI* pCmdUI);

	UINT m_idFontCmd,m_idFontUnderline,m_idFontBorders,FontCharfield;
	afx_msg void OnFontCommand(UINT nID);
	afx_msg void OnFontUnderlineCommand(UINT nID);
	afx_msg void OnFontBordersCommand(UINT nID);
	afx_msg void OnFontCharfieldCommand(UINT nID);
	afx_msg void OnUpdateFontCommand(CCmdUI* pCmdUI);
	afx_msg void OnUpdateFontUnderlineCommand(CCmdUI* pCmdUI);
	afx_msg void OnUpdateFontBordersCommand(CCmdUI* pCmdUI);
	afx_msg void OnUpdateFontCharfieldCommand(CCmdUI* pCmdUI);

	UINT m_idFaceColor,m_idBackColor,m_idGalleryFontFaceColor;
	afx_msg void OnBtnFontFaceColor();
	afx_msg void OnGalleryFontFaceColor(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnFontFaceAutoColor();
	afx_msg void OnFontFaceOtherColor();
	afx_msg void OnUpdateBtnFontFaceColor(CCmdUI* pCmdUI);
	afx_msg void OnUpdateGalleryFontFaceColor(CCmdUI* pCmdUI);
	afx_msg void OnUpdateFontFaceAutoColor(CCmdUI* pCmdUI);
	afx_msg void OnUpdateFontFaceOtherColor(CCmdUI* pCmdUI);

	COLORREF m_clrFace,m_clrBack;
	UINT m_idGalleryFontBackColor;
	afx_msg void OnBtnFontBackColor();
	afx_msg void OnGalleryFontBackColor(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnFontBackNoColors();
	afx_msg void OnUpdateBtnFontBackColor(CCmdUI* pCmdUI);
	afx_msg void OnUpdateGalleryFontBackColor(CCmdUI* pCmdUI);
	afx_msg void OnUpdateFontBackNoColors(CCmdUI* pCmdUI);

	UINT m_idFontFace,m_idFontSize,m_idGalleryFontSize,m_idGalleryFontFace;
	afx_msg void OnEditFontSize(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnEditFontFace(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnFontOther();
	afx_msg void OnUpdateFontSize(CCmdUI* pCmdUI);
	afx_msg void OnUpdateFontFace(CCmdUI* pCmdUI);
	afx_msg void OnUpdateFontOther(CCmdUI* pCmdUI);
	afx_msg void OnUpdateGalleryFontSize(CCmdUI* pCmdUI);
	afx_msg void OnUpdateGalleryFontFace(CCmdUI* pCmdUI);

	UINT m_idAlignmentCmd,m_idAlignmentDirect,m_idAlignmentMerge;
	afx_msg void OnAlignmentCommand(UINT nID);
	afx_msg void OnAlignmentDirect(UINT nID);
	afx_msg void OnAlignmentMerge(UINT nID);
	afx_msg void OnUpdateAlignmentCommand(CCmdUI* pCmdUI);
	afx_msg void OnUpdateAlignmentDirect(CCmdUI* pCmdUI);
	afx_msg void OnUpdateAlignmentMerge(CCmdUI* pCmdUI);

	CString m_strNumberFormat;int m_nNumberFormat;
	UINT m_idNumberCmd,m_idNumberAccountant,m_idGalleryNumber;
	afx_msg void OnEditNumberFormat(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnNumberFormatOther();
	afx_msg void OnNumberCommand(UINT nID);
	afx_msg void OnNumberAccountant(UINT nID);
	afx_msg void OnUpdateNumberFormat(CCmdUI* pCmdUI);
	afx_msg void OnUpdateGalleryNumber(CCmdUI* pCmdUI);
	afx_msg void OnUpdateNumberFormatOther(CCmdUI* pCmdUI);
	afx_msg void OnUpdateNumberCommand(CCmdUI* pCmdUI);
	afx_msg void OnUpdateNumberAccountant(CCmdUI* pCmdUI);

	UINT m_idGalleryHighLight,m_idGalleryItemSelect,m_idGalleryDataBars,m_idGalleryClrValeur,m_idGalleryIconList;
	UINT m_idStylesCmd,m_idCondition,m_idConditionCmd,m_idStyleFormat,m_idStylesCell;
	afx_msg void OnStylesCommand(UINT nID);
	afx_msg void OnCondition(UINT nID);
	afx_msg void OnConditionCommand(UINT nID);
	afx_msg void OnStyleFormat(UINT nID);
	afx_msg void OnStyleCell(UINT nID);
	afx_msg void OnGalleryConditionHighlight(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnGalleryConditionItemselect(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnGalleryConditionDatabars(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnGalleryConditionClrValeur(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnGalleryConditionIconlist(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnGalleryStylesFormat(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnGalleryStylesCell(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnUpdateStylesCommand(CCmdUI* pCmdUI);
	afx_msg void OnUpdateCondition(CCmdUI* pCmdUI);
	afx_msg void OnUpdateConditionCommand(CCmdUI* pCmdUI);
	afx_msg void OnUpdateStyleFormat(CCmdUI* pCmdUI);
	afx_msg void OnUpdateStyleCell(CCmdUI* pCmdUI);
	afx_msg void OnUpdateGalleryConditionHighlight(CCmdUI* pCmdUI);
	afx_msg void OnUpdateGalleryConditionItemselect(CCmdUI* pCmdUI);
	afx_msg void OnUpdateGalleryConditionDatabars(CCmdUI* pCmdUI);
	afx_msg void OnUpdateGalleryConditionClrValeur(CCmdUI* pCmdUI);
	afx_msg void OnUpdateGalleryConditionIconlist(CCmdUI* pCmdUI);
	afx_msg void OnUpdateGalleryStylesFormat(CCmdUI* pCmdUI);
	afx_msg void OnUpdateGalleryStylesCell(CCmdUI* pCmdUI);

	UINT m_idCellCmd,m_idCellInsert,m_idCellDelete,m_idCellFormat;
	afx_msg void OnCellCommand(UINT nID);
	afx_msg void OnCellInsert(UINT nID);
	afx_msg void OnCellDelete(UINT nID);
	afx_msg void OnCellFormat(UINT nID);
	afx_msg void OnUpdateCellCommand(CCmdUI* pCmdUI);
	afx_msg void OnUpdateCellInsert(CCmdUI* pCmdUI);
	afx_msg void OnUpdateCellDelete(CCmdUI* pCmdUI);
	afx_msg void OnUpdateCellFormat(CCmdUI* pCmdUI);

	UINT m_idModifyCmd,m_idModifySum,m_idModifyFill,m_idModifyClear,m_idModifySortFilter,m_idModifyFindSelect;
	afx_msg void OnModifyCommand(UINT nID);
	afx_msg void OnModifySum(UINT nID);
	afx_msg void OnModifyFill(UINT nID);
	afx_msg void OnModifyClear(UINT nID);
	afx_msg void OnModifySortFilter(UINT nID);
	afx_msg void OnModifyFindSelect(UINT nID);
	afx_msg void OnUpdateModifyCommand(CCmdUI* pCmdUI);
	afx_msg void OnUpdateModifySum(CCmdUI* pCmdUI);
	afx_msg void OnUpdateModifyFill(CCmdUI* pCmdUI);
	afx_msg void OnUpdateModifyClear(CCmdUI* pCmdUI);
	afx_msg void OnUpdateModifySortFilter(CCmdUI* pCmdUI);
	afx_msg void OnUpdateModifyFindSelect(CCmdUI* pCmdUI);

	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_RIBBONREPORTVIEW_H__0026E756_0D53_4DD8_8B2B_D3795245FBAE__INCLUDED_)
