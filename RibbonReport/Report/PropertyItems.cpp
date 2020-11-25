// Property Items.cpp : implementation file
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

#include "StdAfx.h"
#include "PropertyItems.h"


////////////////////////////////////////////////////////////////////////////////////////////////

CPropertyItemIcon::CPropertyItemIcon(CString strCaption, HICON hIcon)
	: CXTPPropertyGridItem(strCaption)
{
	m_hIcon = hIcon? CopyIcon(hIcon): 0;
	m_nFlags = xtpGridItemHasExpandButton;
}

CPropertyItemIcon::~CPropertyItemIcon(void)
{
	if (m_hIcon)
		DestroyIcon(m_hIcon);
}

BOOL CPropertyItemIcon::OnDrawItemValue(CDC& dc, CRect rcValue)
{
	if (m_hIcon)
	{
		COLORREF clr = dc.GetTextColor();
		CRect rcSample(rcValue.left - 2, rcValue.top + 1, rcValue.left + 18, rcValue.bottom - 1);
		DrawIconEx(dc, rcSample.left, rcSample.top, m_hIcon, rcSample.Width(), rcSample.Height(), 0, 0, DI_NORMAL);
		dc.Draw3dRect(rcSample, clr, clr);
	}

	CRect rcText(rcValue);
	rcText.left += 25;

	dc.DrawText( _T("(Icon)"), rcText,  DT_SINGLELINE|DT_VCENTER);

	return TRUE;
}

void CPropertyItemIcon::OnInplaceButtonDown(CXTPPropertyGridInplaceButton* /*pButton*/)
{
	const TCHAR szFilters[]=
		_T("Icon files (*.ico)|*.ico|All Files (*.*)|*.*||");

	CFileDialog dlg(TRUE, _T("ico"), _T("*.ico"), OFN_FILEMUSTEXIST| OFN_HIDEREADONLY, szFilters);

	if (dlg.DoModal() == IDOK)
	{
		if (m_hIcon)
			DestroyIcon(m_hIcon);
		m_hIcon = (HICON)LoadImage(NULL, dlg.GetPathName(), IMAGE_ICON, 0, 0, LR_LOADFROMFILE|LR_DEFAULTSIZE );


		OnValueChanged(_T(""));
		((CWnd*)m_pGrid)->Invalidate(FALSE);
	}
}



////////////////////////////////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CPropertyItemSpinInplaceButton, CSpinButtonCtrl)
	ON_NOTIFY_REFLECT(UDN_DELTAPOS, OnDeltapos)
END_MESSAGE_MAP()


void CPropertyItemSpinInplaceButton::OnDeltapos(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMUPDOWN pNMUpDown = reinterpret_cast<LPNMUPDOWN>(pNMHDR);

	m_pItem->OnValidateEdit();
	long nValue = m_pItem->GetNumber() + pNMUpDown->iDelta;

	int nLower, nUpper;
	GetRange(nLower, nUpper);
	nValue = max(nLower, min(nUpper, nValue));

	CString str;
	str.Format(_T("%i"), nValue);
	m_pItem->OnValueChanged(str);

	*pResult = 1;
}

CPropertyItemSpin::CPropertyItemSpin(CString strCaption)
	: CXTPPropertyGridItemNumber(strCaption)
{
	m_wndSpin.m_pItem = this;
}
void CPropertyItemSpin::OnDeselect()
{
	CXTPPropertyGridItemNumber::OnDeselect();

	if (m_wndSpin.m_hWnd) m_wndSpin.ShowWindow(SW_HIDE);
}

void CPropertyItemSpin::OnSelect()
{
	CXTPPropertyGridItem::OnSelect();

	if (!m_bReadOnly)
	{
		CRect rc = GetItemRect();
		rc.left = rc.right - 15;
		if (!m_wndSpin.m_hWnd)
		{
			m_wndSpin.Create(UDS_ARROWKEYS|WS_CHILD, rc, (CWnd*)m_pGrid, 0);
			m_wndSpin.SetRange(0, 100);
		}
		m_wndSpin.MoveWindow(rc);
		m_wndSpin.ShowWindow(SW_SHOW);
	}
}
CRect CPropertyItemSpin::GetValueRect()
{
	CRect rcValue(CXTPPropertyGridItem::GetValueRect());
	rcValue.right -= 17;
	return rcValue;
}


////////////////////////////////////////////////////////////////////////////////////////////////

class CPropertyItemChilds::CPropertyItemChildsAll : public CXTPPropertyGridItemNumber
{
public:
	CPropertyItemChildsAll(CString strCaption) : CXTPPropertyGridItemNumber(strCaption) {}
	virtual void OnValueChanged(CString strValue)
	{
		SetValue(strValue);

		CPropertyItemChilds* pParent = ((CPropertyItemChilds*)m_pParent);
		CRect& rc = pParent->m_rcValue;
		rc.left = rc.right = rc.top = rc.bottom = GetNumber();
		pParent->OnValueChanged(pParent->RectToString(rc));
	}
};

class CPropertyItemChilds::CPropertyItemChildsPad : public CXTPPropertyGridItemNumber
{
public:
	CPropertyItemChildsPad(CString strCaption, LONG& nPad) : CXTPPropertyGridItemNumber(strCaption), m_nPad(nPad) {}
	virtual void OnValueChanged(CString strValue)
	{
		SetValue(strValue);

		CPropertyItemChilds* pParent = ((CPropertyItemChilds*)m_pParent);
		m_nPad = GetNumber();
		pParent->m_itemAll->SetNumber(0);
		pParent->OnValueChanged(pParent->RectToString(pParent->m_rcValue));

	}
	LONG& m_nPad;
};

CPropertyItemChilds::CPropertyItemChilds(CString strCaption, CRect rcValue)
	: CXTPPropertyGridItem(strCaption)
{
	m_rcValue = rcValue;
	m_strValue = RectToString(rcValue);
	m_nFlags = 0;
}

void CPropertyItemChilds::OnAddChildItem()
{
	m_itemAll = (CPropertyItemChildsAll*)AddChildItem(new CPropertyItemChildsAll(_T("All")));
	m_itemLeft = (CPropertyItemChildsPad*)AddChildItem(new CPropertyItemChildsPad(_T("Left"), m_rcValue.left));
	m_itemTop = (CPropertyItemChildsPad*)AddChildItem(new CPropertyItemChildsPad(_T("Top"), m_rcValue.top));
	m_itemRight = (CPropertyItemChildsPad*)AddChildItem(new CPropertyItemChildsPad(_T("Right"), m_rcValue.right));
	m_itemBottom = (CPropertyItemChildsPad*)AddChildItem(new CPropertyItemChildsPad(_T("Bottom"), m_rcValue.bottom));

	UpdateChilds();
}

void CPropertyItemChilds::UpdateChilds()
{
	m_itemLeft->SetNumber(m_rcValue.left);
	m_itemRight->SetNumber(m_rcValue.right);
	m_itemTop->SetNumber(m_rcValue.top);
	m_itemBottom->SetNumber(m_rcValue.bottom);
}

void CPropertyItemChilds::SetValue(CString strValue)
{
	CXTPPropertyGridItem::SetValue(strValue);
	UpdateChilds();
}

CString CPropertyItemChilds::RectToString(CRect rc)
{
	CString str;
	str.Format(_T("%i; %i; %i; %i"), rc.left, rc.top, rc.right, rc.bottom);
	return str;
}


///////////////////////////////////////////////////////////////////////////////


class CPropertyItemColorPopup: public CXTPColorPopup
{
	friend class CPropertyItemColor;
public:
	CPropertyItemColorPopup() : CXTPColorPopup(TRUE) {}
private:
	DECLARE_MESSAGE_MAP()
	afx_msg LRESULT OnSelEndOK(WPARAM wParam, LPARAM lParam);

	CPropertyItemColor* m_pItem;
};

BEGIN_MESSAGE_MAP(CPropertyItemColorPopup, CXTPColorPopup)
	ON_MESSAGE(CPN_XTP_SELENDOK, OnSelEndOK)
END_MESSAGE_MAP()


LRESULT CPropertyItemColorPopup::OnSelEndOK(WPARAM wParam, LPARAM /*lParam*/)
{
	m_pItem->OnValueChanged(m_pItem->RGBToString((COLORREF)wParam));
	return 0;
}


CPropertyItemColor::CPropertyItemColor(CString strCaption, COLORREF clr)
	: CXTPPropertyGridItemColor(strCaption, clr)
{
	m_nFlags = xtpGridItemHasComboButton|xtpGridItemHasEdit;
	SetColor(clr);
	m_strDefaultValue = m_strValue;
}


void CPropertyItemColor::OnInplaceButtonDown(CXTPPropertyGridInplaceButton* /*pButton*/)
{
	CPropertyItemColorPopup *pColorPopup = new CPropertyItemColorPopup();
	pColorPopup->SetTheme(xtpControlThemeOffice2003);

	CRect rcItem= GetItemRect();
	m_pGrid->ClientToScreen(&rcItem);

	pColorPopup->Create(rcItem, m_pGrid, CPS_XTP_RIGHTALIGN|CPS_XTP_USERCOLORS|CPS_XTP_EXTENDED|CPS_XTP_MORECOLORS|CPS_XTP_SHOW3DSELECTION|CPS_XTP_SHOWHEXVALUE, GetColor(), GetColor());
	pColorPopup->SetOwner(m_pGrid);
	pColorPopup->SetFocus();
	pColorPopup->AddListener(pColorPopup->GetSafeHwnd());
	pColorPopup->m_pItem = this;

}


///////////////////////////////////////////////////////////////////////////////

CPropertyItemFileBox::CPropertyItemFileBox(CString strCaption)
	: CXTPPropertyGridItem(strCaption)
{
	m_nFlags = xtpGridItemHasExpandButton|xtpGridItemHasEdit;
}
void CPropertyItemFileBox::OnInplaceButtonDown(CXTPPropertyGridInplaceButton* /*pButton*/)
{
	CFileDialog dlg( TRUE, NULL,  GetValue(), OFN_HIDEREADONLY|OFN_OVERWRITEPROMPT, NULL, m_pGrid);
	if ( dlg.DoModal( ) == IDOK )
	{
		OnValueChanged( dlg.GetPathName());
		m_pGrid->Invalidate( FALSE );
	}
};

///////////////////////////////////////////////////////////////////////////////


BEGIN_MESSAGE_MAP(CGridInplaceCheckBox, CButton)
	ON_MESSAGE(BM_SETCHECK, OnCheck)
	ON_WM_CTLCOLOR_REFLECT()
END_MESSAGE_MAP()

HBRUSH CGridInplaceCheckBox::CtlColor(CDC* pDC, UINT /*nCtlColor*/)
{
	class CGridView : public CXTPPropertyGridView
	{
		friend class CGridInplaceCheckBox;
	};

	CGridView* pGrid = (CGridView*)m_pItem->m_pGrid;

	COLORREF clr = pGrid->GetPaintManager()->GetItemMetrics()->m_clrBack;

	if (clr != m_clrBack || !m_brBack.GetSafeHandle())
	{
		m_brBack.DeleteObject();
		m_brBack.CreateSolidBrush(clr);
		m_clrBack = clr;
	}

	pDC->SetBkColor(m_clrBack);
	return m_brBack;
}

LRESULT CGridInplaceCheckBox::OnCheck(WPARAM wParam, LPARAM lParam)
{
	m_pItem->m_bValue = (wParam == BST_CHECKED);
	m_pItem->OnValueChanged(m_pItem->GetValue());

	return CButton::DefWindowProc(BM_SETCHECK, wParam, lParam);
}

CPropertyItemCheckBox::CPropertyItemCheckBox(CString strCaption)
	: CXTPPropertyGridItem(strCaption)
{
	m_wndCheckBox.m_pItem = this;
	m_nFlags = 0;
	m_bValue = FALSE;
}

void CPropertyItemCheckBox::OnDeselect()
{
	CXTPPropertyGridItem::OnDeselect();

	if (m_wndCheckBox.m_hWnd) m_wndCheckBox.DestroyWindow();
}

void CPropertyItemCheckBox::OnSelect()
{
	CXTPPropertyGridItem::OnSelect();

	if (!m_bReadOnly)
	{
		CRect rc = GetValueRect();
		rc.left -= 15;
		rc.right = rc.left + 15;

		if (!m_wndCheckBox.m_hWnd)
		{
			m_wndCheckBox.Create(NULL, WS_CHILD|BS_AUTOCHECKBOX|BS_FLAT, rc, (CWnd*)m_pGrid, 0);

		}
		if (m_wndCheckBox.GetCheck() != m_bValue) m_wndCheckBox.SetCheck(m_bValue);
		m_wndCheckBox.MoveWindow(rc);
		m_wndCheckBox.ShowWindow(SW_SHOW);
	}
}

CRect CPropertyItemCheckBox::GetValueRect()
{
	CRect rcValue(CXTPPropertyGridItem::GetValueRect());
	rcValue.left += 17;
	return rcValue;
}

BOOL CPropertyItemCheckBox::OnDrawItemValue(CDC& dc, CRect rcValue)
{
	CRect rcText(rcValue);

	if (m_wndCheckBox.GetSafeHwnd() == 0 && m_bValue)
	{
		CRect rcCheck(rcText.left , rcText.top, rcText.left + 13, rcText.bottom -1);
		dc.DrawFrameControl(rcCheck, DFC_MENU, DFCS_MENUCHECK);
	}

	rcText.left += 17;
	dc.DrawText( GetValue(), rcText,  DT_SINGLELINE|DT_VCENTER);
	return TRUE;
}


BOOL CPropertyItemCheckBox::GetBool()
{
	return m_bValue;
}
void CPropertyItemCheckBox::SetBool(BOOL bValue)
{
	m_bValue = bValue;

	if (m_wndCheckBox.GetSafeHwnd())
		m_wndCheckBox.SetCheck(bValue);
}

BOOL CPropertyItemCheckBox::IsValueChanged()
{
	return !m_bValue;
}



IMPLEMENT_DYNAMIC(CInplaceUpperCase, CXTPPropertyGridInplaceEdit)

BEGIN_MESSAGE_MAP(CInplaceUpperCase, CXTPPropertyGridInplaceEdit)
	//{{AFX_MSG_MAP(CXTPPropertyGridInplaceEdit)
	//}}AFX_MSG_MAP
	ON_WM_CHAR()
END_MESSAGE_MAP()

void CInplaceUpperCase::OnChar(UINT nChar, UINT nRepCnt, UINT nFlags)
{
	CString strChar((TCHAR)nChar), strUpper((TCHAR)nChar);
	strUpper.MakeUpper();

	if (strChar != strUpper) ReplaceSel(strUpper, TRUE);
	else CXTPPropertyGridInplaceEdit::OnChar(nChar, nRepCnt, nFlags);
}


////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////


BEGIN_MESSAGE_MAP(CInplaceSlider, CSliderCtrl)
	ON_WM_CTLCOLOR_REFLECT()
	ON_NOTIFY_REFLECT(NM_CUSTOMDRAW, OnCustomDraw)
END_MESSAGE_MAP()

HBRUSH CInplaceSlider::CtlColor(CDC* pDC, UINT /*nCtlColor*/)
{
	class CGridView : public CXTPPropertyGridView
	{
		friend class CInplaceSlider;
	};

	CGridView* pGrid = (CGridView*)m_pItem->m_pGrid;

	COLORREF clr = pGrid->GetPaintManager()->GetItemMetrics()->m_clrBack;

	if (clr != m_clrBack || !m_brBack.GetSafeHandle())
	{
		m_brBack.DeleteObject();
		m_brBack.CreateSolidBrush(clr);
		m_clrBack = clr;
	}

	pDC->SetBkColor(m_clrBack);
	return m_brBack;
}

void CInplaceSlider::OnCustomDraw(NMHDR* pNMHDR, LRESULT* pResult)
{
	LPNMCUSTOMDRAW lpCustDraw = (LPNMCUSTOMDRAW)pNMHDR;
	if(lpCustDraw->dwDrawStage == CDDS_PREPAINT)
	{
		int nValue = GetPos();
		if (nValue != m_nValue)
		{
			m_nValue = nValue;
			m_pItem->SetNumber(nValue);
			m_pItem->OnValueChanged(m_pItem->GetValue());
			m_pItem->GetGrid()->Invalidate(FALSE);
		}
	}

	*pResult = CDRF_DODEFAULT;
}


CPropertyItemSlider::CPropertyItemSlider(CString strCaption)
	: CXTPPropertyGridItemNumber(strCaption)
{
	m_wndSlider.m_pItem = this;
	m_nFlags = 0;
}

void CPropertyItemSlider::OnDeselect()
{
	CXTPPropertyGridItem::OnDeselect();

	if (m_wndSlider.m_hWnd) m_wndSlider.DestroyWindow();
}

void CPropertyItemSlider::OnSelect()
{
	CXTPPropertyGridItem::OnSelect();

	CRect rc = GetValueRect();

	if (!m_bReadOnly)
	{

		CWindowDC dc(m_pGrid);
		CXTPFontDC font (&dc, GetGrid()->GetFont());
		m_nWidth = dc.GetTextExtent(_T("XXX")).cx;

		rc.left += m_nWidth + 2;

		if (rc.left >= rc.right)
			return;

		if (!m_wndSlider.m_hWnd)
		{
			m_wndSlider.Create(WS_CHILD|TBS_HORZ, rc, (CWnd*)m_pGrid, 0);

		}
		m_wndSlider.SetPos(GetNumber());
		m_wndSlider.SetRange(0, 100);

		m_wndSlider.MoveWindow(rc);
		m_wndSlider.ShowWindow(SW_SHOW);
	}
}


//////////////////////////////////////////////////////////////////////////
// CPropertyItemButton



BEGIN_MESSAGE_MAP(CInplaceButton, CXTPButton)
	ON_CONTROL_REFLECT(BN_CLICKED, OnClicked)
	ON_WM_SETCURSOR()
END_MESSAGE_MAP()

void CInplaceButton::OnClicked()
{
	m_pItem->m_bValue = !m_pItem->m_bValue;
	m_pItem->OnValueChanged(m_pItem->GetValue());
	
	SetChecked(m_pItem->m_bValue);
}

BOOL CInplaceButton::OnSetCursor(CWnd* /*pWnd*/, UINT /*nHitTest*/, UINT /*message*/)
{
	::SetCursor(AfxGetApp()->LoadStandardCursor(MAKEINTRESOURCE(32649)));
	return TRUE;
}

CPropertyItemButton::CPropertyItemButton(CString strCaption, BOOL bFullRowButton, BOOL bValue)
	: CXTPPropertyGridItem(bFullRowButton? _T(""): strCaption)
{
	m_wndButton.m_pItem = this;
	m_nFlags = 0;
	m_bValue = bValue;
	m_strButtonText = strCaption;
	m_bFullRowButton = bFullRowButton;

	m_wndFont.CreateFont(12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, _T("Tahoma"));
}

BOOL CPropertyItemButton::GetBool()
{
	return m_bValue;
}
void CPropertyItemButton::SetBool(BOOL bValue)
{
	m_bValue = bValue;

	if (m_wndButton.GetSafeHwnd())
		m_wndButton.SetCheck(bValue);
}

BOOL CPropertyItemButton::IsValueChanged()
{
	return !m_bValue;
}

void CPropertyItemButton::CreateButton()
{
	if (IsVisible())
	{	
		CRect rc;
		if (m_bFullRowButton)
		{		
			rc = GetItemRect();
			rc.DeflateRect( m_nIndent * 14, 0, 0, 1);
		} else
		{
			rc = GetValueRect();
		}

		
		if (!m_wndButton.m_hWnd)
		{
			m_wndButton.Create(m_strButtonText, WS_CHILD|BS_FLAT|BS_NOTIFY|WS_VISIBLE|BS_OWNERDRAW, rc, (CWnd*)m_pGrid, 100);
			m_wndButton.SetFont(&m_wndFont);
			m_wndButton.SetTheme(xtpControlThemeOfficeXP);
		}
		if (m_wndButton.GetChecked() != m_bValue) m_wndButton.SetChecked(m_bValue);
		m_wndButton.MoveWindow(rc);
		m_wndButton.Invalidate(FALSE);
	}
	else
	{
		m_wndButton.DestroyWindow();
	}
}


void CPropertyItemButton::SetVisible(BOOL bVisible)
{
	CXTPPropertyGridItem::SetVisible(bVisible);
	CreateButton();
}

void CPropertyItemButton::OnIndexChanged()
{
	CreateButton();	
}

BOOL CPropertyItemButton::OnDrawItemValue(CDC& /*dc*/, CRect /*rcValue*/)
{
	CreateButton();
	return FALSE;
}



//////////////////////////////////////////////////////////////////////////
// CPropertyItemMenu

void CPropertyItemMenu::OnInplaceButtonDown(CXTPPropertyGridInplaceButton* pButton)
{
	CMenu menu;
	menu.CreatePopupMenu();

	menu.InsertMenu(0, MF_BYPOSITION | MF_STRING, 1, _T("Choose 1"));
	menu.InsertMenu(1, MF_BYPOSITION | MF_STRING, 2, _T("Choose 2"));
	menu.InsertMenu(2, MF_BYPOSITION | MF_STRING, 3, _T("Choose 3"));

	CRect rc = pButton->GetRect();
	pButton->GetGrid()->ClientToScreen(&rc);

	XTPPaintManager()->SetTheme(xtpThemeWhidbey);
	UINT nCmd = CXTPCommandBars::TrackPopupMenu(&menu, TPM_RETURNCMD|TPM_NONOTIFY, 
		rc.right, rc.top, pButton->GetGrid(), 0);
	
	if (nCmd >0)
	{
		CString str;
		menu.GetMenuString(nCmd, str, MF_BYCOMMAND);

		OnValueChanged(str);
	}
}
