// ReportRecordPaintManager.h: interface for the CReportRecordPaintManager class.
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

#if !defined(AFX_REPORTRECORDPAINTMANAGER_H__INCLUDED_)
#define AFX_REPORTRECORDPAINTMANAGER_H__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

//////////////////////////////////////////////////////////////////////////
// This class is a customization of standard Report Paint Manager, 
// which allows drawing record items text with word wrapping.
// You can test this customization sample with "Multiline Sample" menu option.
// It is implemented using DT_WORDBREAK mode, and uses 2 methods overriding.
class CReportRecordPaintManager : public CXTPReportPaintManager
{
public:
	CReportRecordPaintManager();
	virtual ~CReportRecordPaintManager();

	void SetDrawRowNumber(BOOL bDrawRowNumber = TRUE) {m_bDrawRowNumber = bDrawRowNumber;}
	BOOL GetDrawRowNumber() {return m_bDrawRowNumber;}

	// Draws Item Caption with word wrapping.
	virtual void DrawItemCaption(XTP_REPORTRECORDITEM_DRAWARGS* pDrawArgs, XTP_REPORTRECORDITEM_METRICS* pMetrics);

	// Customized calculation of the row height in word wrapping mode, 
	// which is required in other report drawing methods.
	virtual int GetRowHeight(CDC* pDC, CXTPReportRow* pRow, int nWidth);

	virtual void DrawHorizontalLine(CDC* pDC, int x, int y, int cx, COLORREF clr);

	virtual void DrawVerticalLine(CDC* pDC, int x, int y, int cy, COLORREF clr);

	virtual void RefreshMetrics();

private:
	BOOL m_bDrawRowNumber;

	COLORREF m_clrHorizontalLine;
	COLORREF m_clrVerticalLine;
};


//////////////////////////////////////////////////////////////////////////
// This class is a customization of standard Report Paint Manager, 
// which allows drawing record items text with word wrapping.
// You can test this customization sample with "Multiline Sample" menu option.
// It is implemented using DT_WORDBREAK mode, and uses 2 methods overriding.
class CReportMultilinePaintManager : public CXTPReportPaintManager
{
public:
	CReportMultilinePaintManager();
	virtual ~CReportMultilinePaintManager();

	// Draws Item Caption with word wrapping.
	void DrawItemCaption(XTP_REPORTRECORDITEM_DRAWARGS* pDrawArgs, XTP_REPORTRECORDITEM_METRICS* pMetrics);

	// Customized calculation of the row height in word wrapping mode, 
	// which is required in other report drawing methods.
	int GetRowHeight(CDC* pDC, CXTPReportRow* pRow, int nWidth);

};

#endif // !defined(AFX_REPORTRECORDPAINTMANAGER_H__INCLUDED_)
