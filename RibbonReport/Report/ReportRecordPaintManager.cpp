// ReportRecordPaintManager.cpp: implementation of the CReportRecordPaintManager class.
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
#include "ReportRecordPaintManager.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CReportRecordPaintManager::CReportRecordPaintManager()
{
	m_bFixedRowHeight = FALSE;
	m_bDrawRowNumber = FALSE;
	m_clrHorizontalLine = RGB(0,0,0);
	m_clrVerticalLine = RGB(0,0,0);
}

CReportRecordPaintManager::~CReportRecordPaintManager()
{

}

int CReportRecordPaintManager::GetRowHeight(CDC* pDC, CXTPReportRow* pRow, int nTotalWidth)
{
	if (pRow->IsGroupRow() || !pRow->IsItemsVisible())
		return CXTPReportPaintManager::GetRowHeight(pDC, pRow, nTotalWidth);

	CXTPReportColumns* pColumns = pRow->GetControl()->GetColumns();
	int nColumnCount = pColumns->GetCount();

	XTP_REPORTRECORDITEM_DRAWARGS drawArgs;
	drawArgs.pControl = pRow->GetControl();
	drawArgs.pDC = pDC;
	drawArgs.pRow = pRow;

	int nHeight = 0;

	for (int nColumn = 0; nColumn < nColumnCount; nColumn++)
	{
		CXTPReportColumn* pColumn = pColumns->GetAt(nColumn);
		if (pColumn && pColumn->IsVisible())
		{
			CXTPReportRecordItem* pItem = pRow->GetRecord()->GetItem(pColumn);
			drawArgs.pItem = pItem;

			XTP_REPORTRECORDITEM_METRICS itemMetrics;
			pRow->GetItemMetrics(&drawArgs, &itemMetrics);

			CXTPFontDC fnt(pDC, itemMetrics.pFont);

			int nWidth = pDC->IsPrinting() ? pColumn->GetPrintWidth(nTotalWidth): pColumn->GetWidth();

			CRect rcItem(0, 0, nWidth - 4, 0);
			pRow->ShiftTreeIndent(rcItem, pColumn);

			pItem->GetCaptionRect(&drawArgs, rcItem);
			//pDC->DrawText(pItem->GetCaption(pColumn), rcItem, DT_WORDBREAK|DT_CALCRECT);

			nHeight = max(	nHeight, rcItem.Height());
		}
	}


	return max(nHeight + 5, m_nRowHeight) + (IsGridVisible(FALSE)? 1: 0);
}

void CReportRecordPaintManager::DrawItemCaption(XTP_REPORTRECORDITEM_DRAWARGS* pDrawArgs, XTP_REPORTRECORDITEM_METRICS* pMetrics)
{
	CXTPReportPaintManager::DrawItemCaption(pDrawArgs, pMetrics);

	if(pDrawArgs->pColumn->GetIndex() == 0 && m_bDrawRowNumber)
	{
		CXTPReportRow* pRow = pDrawArgs->pRow;
		int lag = pRow->GetControl()->GetRows()->GetCount() > 10000 ? 40:30;
		CDC* pDC = pDrawArgs->pDC;
		CRect rcNumber = pDrawArgs->rcItem;
		rcNumber.right = rcNumber.left+lag;

		if (m_columnStyle == xtpReportColumnResource)
		{
			XTPDrawHelpers()->GradientFill(pDC, rcNumber, m_grcGradientColumn, FALSE);
			pDC->Draw3dRect(rcNumber, m_clrGradientColumnShadow, m_clrGradientColumnShadow);
		}
		else
		{
			FillItemShade(pDC, rcNumber);
			pDC->Draw3dRect(rcNumber, m_clrControlLightLight, m_clrControlDark);
		}

		DrawRowNumber(pDC, rcNumber, pRow);
		rcNumber.left = rcNumber.left+lag+5;
		rcNumber.right = pDrawArgs->rcItem.right;
		pDC->DrawText(pMetrics->strText, &rcNumber, pDrawArgs->nTextAlign);
	}
}

void CReportRecordPaintManager::DrawHorizontalLine(CDC* pDC, int x, int y, int cx, COLORREF clr)
{
	pDC->FillSolidRect(x, y, cx, 1, clr);
}

void CReportRecordPaintManager::DrawVerticalLine(CDC* pDC, int x, int y, int cy, COLORREF clr)
{
	pDC->FillSolidRect(x, y, 1, cy, clr);
}

void CReportRecordPaintManager::RefreshMetrics()
{
	CXTPReportPaintManager::RefreshMetrics();

	SetGridStyle(0, xtpReportGridSolid);
	SetGridStyle(1, xtpReportGridSolid);

	SetHeaderRowsDividerStyle(xtpReportFixedRowsDividerBold);
	SetFooterRowsDividerStyle(xtpReportFixedRowsDividerBold);
	ShowWYSIWYGMarkers(TRUE);
	m_clrHeaderRowsDivider = RGB(255,0,0);
	m_clrFooterRowsDivider = RGB(0,0,255);
	m_bShowLockIcon = TRUE;
}



//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CReportMultilinePaintManager::CReportMultilinePaintManager()
{
	m_bFixedRowHeight = FALSE;
}

CReportMultilinePaintManager::~CReportMultilinePaintManager()
{

}

int CReportMultilinePaintManager::GetRowHeight(CDC* pDC, CXTPReportRow* pRow, int nTotalWidth)
{
	if (pRow->IsGroupRow() || !pRow->IsItemsVisible())
		return CXTPReportPaintManager::GetRowHeight(pDC, pRow, nTotalWidth);

	CXTPReportColumns* pColumns = pRow->GetControl()->GetColumns();
	int nColumnCount = pColumns->GetCount();

	XTP_REPORTRECORDITEM_DRAWARGS drawArgs;
	drawArgs.pControl = pRow->GetControl();
	drawArgs.pDC = pDC;
	drawArgs.pRow = pRow;

	int nHeight = 0;

	for (int nColumn = 0; nColumn < nColumnCount; nColumn++)
	{
		CXTPReportColumn* pColumn = pColumns->GetAt(nColumn);
		if (pColumn && pColumn->IsVisible())
		{
			CXTPReportRecordItem* pItem = pRow->GetRecord()->GetItem(pColumn);
			drawArgs.pItem = pItem;

			XTP_REPORTRECORDITEM_METRICS itemMetrics;
			pRow->GetItemMetrics(&drawArgs, &itemMetrics);

			CXTPFontDC fnt(pDC, itemMetrics.pFont);

			int nWidth = pDC->IsPrinting()? pColumn->GetPrintWidth(nTotalWidth): pColumn->GetWidth();

			CRect rcItem(0, 0, nWidth - 4, 0);
			pRow->ShiftTreeIndent(rcItem, pColumn);

			pItem->GetCaptionRect(&drawArgs, rcItem);
			pDC->DrawText(pItem->GetCaption(pColumn), rcItem, DT_WORDBREAK|DT_CALCRECT);

			nHeight = max(nHeight, rcItem.Height());
		}
	}


	return max(nHeight + 5, m_nRowHeight) + (IsGridVisible(FALSE)? 1: 0);
}

void CReportMultilinePaintManager::DrawItemCaption(XTP_REPORTRECORDITEM_DRAWARGS* pDrawArgs, XTP_REPORTRECORDITEM_METRICS* pMetrics)
{
	CRect& rcItem = pDrawArgs->rcItem;
	CDC* pDC = pDrawArgs->pDC;
	CString strText = pMetrics->strText;

	// draw item text
	if(!strText.IsEmpty())
	{
		rcItem.DeflateRect(2, 1, 2, 0);
		pDC->DrawText(strText, rcItem, pDrawArgs->nTextAlign|DT_WORDBREAK);
	}
}