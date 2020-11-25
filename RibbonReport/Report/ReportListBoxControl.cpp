// ReportListBoxControl.cpp : implementation of the CReportListBoxControl class.
//

#include "stdafx.h"
#include "ReportListBoxControl.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

extern CXTPADOConnection theCon;
IMPLEMENT_DYNAMIC(CReportListBoxControl, CListBox)
/////////////////////////////////////////////////////////////////////////////
// CReportListBoxControl

CReportListBoxControl::CReportListBoxControl()
{
	m_pReportCtrl = NULL;
}

CReportListBoxControl::~CReportListBoxControl()
{
}


BEGIN_MESSAGE_MAP(CReportListBoxControl, CListBox)
	//{{AFX_MSG_MAP(CReportListBoxControl)
	ON_WM_ERASEBKGND()
	ON_WM_PAINT()
	ON_MESSAGE(WM_PRINTCLIENT, OnPrintClient)
	ON_WM_LBUTTONDOWN()
	ON_WM_MOUSEMOVE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CReportListBoxControl attributes

BOOL CReportListBoxControl::SetReportCtrl(CXTPReportControl* pReportCtrl)
{
	if (pReportCtrl == NULL)
		return FALSE;

	ASSERT_KINDOF(CXTPReportControl, pReportCtrl);

	if (m_pReportCtrl != pReportCtrl)
	{
		m_pReportCtrl = pReportCtrl;
		UpdateList();
		m_tipWindow.Create(this);
		m_tipWindow.ShowWindow(SW_HIDE);
	}

	return TRUE;
}

CXTPReportControl* CReportListBoxControl::GetReportCtrl()
{
	return m_pReportCtrl;
}

BOOL CReportListBoxControl::UpdateList()
{
	if (m_pReportCtrl == NULL)
		return FALSE;

	CClientDC dc(this);
	CXTPFontDC fnt(&dc, &m_pReportCtrl->GetPaintManager()->m_fontCaption);
	int nHeight = dc.GetTextExtent(_T(" "), 1).cy + 5;

	if (GetItemHeight(0) != nHeight) SetItemHeight(0, nHeight);

	CXTPReportRecords* pRecords = m_pReportCtrl->GetRecords();
	if(pRecords)
	{
		// add the rest of invisible items
		ResetContent();
		for (int i = 0; i < pRecords->GetCount(); i++)
		{
			CXTPReportRecord* pRecord = pRecords->GetAt(i);
			if (pRecord)
			{
				int item = AddString(pRecord->GetItem(0)->GetCaption());

				if (item >= 0)
					SetItemData(item, (DWORD_PTR)pRecord);
			}
		}

		EnableWindow(GetCount() > 0);
		return TRUE;
	}

	return FALSE;
}

CXTPReportRecord* CReportListBoxControl::GetItemRecord(int nIndex)
{
	if(nIndex < 0)
		return NULL;
	return (CXTPReportRecord*)GetItemData(nIndex);
}

CString CReportListBoxControl::GetItemCaption(int nIndex)
{
	if (nIndex < 0)
		return _T("");

	CString str;
	GetText(nIndex, str);
	return str;
}

CXTPReportRecord* CReportListBoxControl::GetCurItemRecord()
{
	return (CXTPReportRecord*)GetItemRecord(GetCurSel());
}

CString CReportListBoxControl::GetCurItemCaption()
{
	return GetItemCaption(GetCurSel());
}

void CReportListBoxControl::PreSubclassWindow()
{
	CListBox::PreSubclassWindow();
}

void CReportListBoxControl::DrawItem(LPDRAWITEMSTRUCT lpDrawItemStruct)
{
	CDC* pDC = CDC::FromHandle(lpDrawItemStruct->hDC);

	CRect rcItem(lpDrawItemStruct->rcItem);

	CXTPReportPaintManager* pPaintManager = m_pReportCtrl ? m_pReportCtrl->GetPaintManager() : NULL;
	COLORREF clrBack = pPaintManager ? pPaintManager->m_clrControlBack : ::GetXtremeColor(COLOR_WINDOW);


	if (GetCount() > 0 && m_pReportCtrl && pPaintManager)
	{
		CXTPFontDC fnt(pDC, &pPaintManager->m_fontCaption);

		if (GetExStyle() & WS_EX_STATICEDGE)
		{
			pDC->Draw3dRect(rcItem, pPaintManager->m_clrHighlightText, pPaintManager->m_clrControlDark);
			rcItem.DeflateRect(1, 1);
			pDC->FillSolidRect(rcItem, pPaintManager->m_clrControlBack);
			rcItem.DeflateRect(1, 1);
		}
		else
		{
			pDC->FillSolidRect(rcItem, pPaintManager->m_clrHeaderControl);
			pDC->Draw3dRect(rcItem, pPaintManager->m_clrBtnFace, GetXtremeColor(COLOR_3DDKSHADOW));
			rcItem.DeflateRect(1, 1);
			pDC->Draw3dRect(rcItem, pPaintManager->m_clrControlBack, pPaintManager->m_clrControlDark);
			rcItem.DeflateRect(1, 1);
		}

		pDC->SetBkMode(TRANSPARENT);

		BOOL bSelected = lpDrawItemStruct->itemState & ODS_SELECTED;
		pDC->SetTextColor(pPaintManager->m_clrCaptionText);

		if (bSelected)
		{
			pDC->FillSolidRect(rcItem, GetXtremeColor(COLOR_3DFACE));
			pDC->InvertRect(rcItem);
			pDC->SetTextColor(lpDrawItemStruct->itemData ? ::GetXtremeColor(COLOR_BTNFACE) : ::GetXtremeColor(COLOR_3DHIGHLIGHT));
		}

		CString str = GetItemCaption(lpDrawItemStruct->itemID);
		if (!lpDrawItemStruct->itemData && !bSelected)
		{
			pDC->SetTextColor(::GetXtremeColor(COLOR_3DHIGHLIGHT));

			CRect rect = rcItem;
			rect.OffsetRect(1, 1);

			pDC->DrawText(str, rect, DT_SINGLELINE | DT_NOPREFIX | DT_NOCLIP | DT_VCENTER | DT_END_ELLIPSIS | DT_LEFT);
			pDC->SetTextColor(::GetXtremeColor(COLOR_3DSHADOW));
		}

		pDC->DrawText(str, rcItem, DT_SINGLELINE | DT_NOPREFIX | DT_NOCLIP | DT_VCENTER | DT_END_ELLIPSIS | DT_LEFT);
	}
	else
		pDC->FillSolidRect(rcItem, clrBack);
}

void CReportListBoxControl::OnPaint()
{
	CPaintDC dcPaint(this);
	CRect rc;
	GetClientRect(rc);

	CXTPBufferDC dc(dcPaint, rc);

	CXTPReportPaintManager* pPaintManager = m_pReportCtrl ? m_pReportCtrl->GetPaintManager() : NULL;
	COLORREF clrBack = pPaintManager ? pPaintManager->m_clrControlBack : GetXtremeColor(COLOR_WINDOW);

	dc.FillSolidRect(rc, IsWindowEnabled() ? clrBack : GetXtremeColor(COLOR_BTNFACE));

	if (GetCount() > 0 || !pPaintManager)
		CWnd::DefWindowProc(WM_PAINT, (WPARAM)dc.m_hDC, 0);
	else
	{
		dc.SetTextColor(GetXtremeColor(COLOR_3DSHADOW));
		dc.SetBkMode(TRANSPARENT);
		CXTPFontDC fnt(&dc, &pPaintManager->m_fontCaption);

		dc.DrawText(pPaintManager->m_strNoFieldsAvailable, rc, DT_SINGLELINE | DT_CENTER | DT_VCENTER | DT_NOPREFIX);
	}
}

LRESULT CReportListBoxControl::OnPrintClient(WPARAM wParam, LPARAM lParam)
{
	CListBox::DefWindowProc(WM_ERASEBKGND, wParam, 0);
	return CListBox::DefWindowProc(WM_PRINTCLIENT, wParam, lParam);
}

BOOL CReportListBoxControl::OnEraseBkgnd(CDC* /*pDC*/)
{
	return TRUE;
}

void CReportListBoxControl::OnLButtonDown(UINT nFlags, CPoint point)
{
	BOOL bOutside = TRUE;
	int item = ItemFromPoint(point, bOutside);
	if (item == LB_ERR)
		return;

	SetCurSel(item);

	CString sql = _T("select * from ")+GetItemCaption(item);
	CXTPADORecordset rst(theCon);
	if(rst.Open(sql,CXTPADORecordset::xtpAdoRstStoredProc))
	{
		CXTPReportDataManager* pDataManager = m_pReportCtrl->GetDataManager();
		pDataManager->SetDataSource(rst.GetInterfacePtr());
		pDataManager->DataBind();
		m_pReportCtrl->Populate();
	}

	CXTPListBox::OnLButtonDown(nFlags, point);
}

void CReportListBoxControl::OnMouseMove(UINT nFlags, CPoint point)
{
	BOOL bOutside = TRUE;
	int item = ItemFromPoint(point, bOutside);
	if (item == LB_ERR)
		return;

	CString str = GetItemCaption(item);
	int txtLen = GetTextLen(item);

	CRect rect;
	GetItemRect(item, rect);
	if(txtLen > 13)
	{
		str.Replace(_T("\r\n"), _T("\n")); //Avoid ugly outputted rectangle character in the tip window
		m_tipWindow.SetMargins(CSize(1,1));
		m_tipWindow.SetLineSpace(0);
		m_tipWindow.SetTipText(_T(""), str);
		m_tipWindow.ShowTipWindow(rect, point, TWS_XTP_ALPHASHADOW, 0, 0, false, FALSE);
	}

	CXTPListBox::OnMouseMove(nFlags, point);
}
