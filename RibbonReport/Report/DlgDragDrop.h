// DlgDragDrop.h
//
// This file is a part of the XTREME TOOLKIT PRO MFC class library.
// (c)1998-2012 Codejock Software, All Rights Reserved.
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

#if !defined(AFX_DLG_DRAGDROP_H__INCLUDED_)
#define AFX_DLG_DRAGDROP_H__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CDlgDragDrop dialog

class CDlgDragDrop : public CDialog
{
public:
	CDlgDragDrop(CWnd *pParent = NULL);

	//{{AFX_DATA(CDlgDragDrop)
	enum { IDD = IDD_DLG_DRAGDROP };
	BOOL	m_bDragDropSorted1;
	BOOL	m_bDragDropSorted2;
	//}}AFX_DATA

	//{{AFX_VIRTUAL(CDlgDragDrop)
	public:
	protected:
	virtual void DoDataExchange(CDataExchange *pDX);   // DDX/DDV support
	//}}AFX_VIRTUAL

protected:
	CImageList m_ilTree;

	//{{AFX_MSG(CDlgDragDrop)
	virtual BOOL OnInitDialog();
	virtual void OnOK();
	afx_msg void OnDragDropSorted1();
	afx_msg void OnDragDropSorted2();
	afx_msg void OnReportBeginDrag1(NMHDR *pNotifyStruct, LRESULT *pResult);
	afx_msg void OnReportDrop2(NMHDR *pNotifyStruct, LRESULT *pResult);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:
	CXTPOfficeBorder<CXTPReportControl,false> m_wndReport1;
	CXTPOfficeBorder<CXTPReportControl,false> m_wndReport2;
};

//{{AFX_INSERT_LOCATION}}

#endif // !defined(AFX_DLG_DRAGDROP_H__INCLUDED_)
