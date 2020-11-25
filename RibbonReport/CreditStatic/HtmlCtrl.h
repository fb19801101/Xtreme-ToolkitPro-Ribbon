// HtmlCtrl.h : header file
//
//
// HtmlCtrl static control. Will open the default browser with the given URL
// when the user clicks on the link.
//
// Copyright Chris Maunder, 1997
// Feel free to use and distribute. May not be sold for profit. 

#if !defined(AFX_HTMLCTRL_H__D1625061_574B_11D1_ABBA_00A0243D1382__INCLUDED_)
#define AFX_HTMLCTRL_H__D1625061_574B_11D1_ABBA_00A0243D1382__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

/////////////////////////////////////////////////////////////////////////////
// CHtmlCtrl window

class CHtmlCtrl : public CHtmlView
{
	DECLARE_DYNAMIC(CHtmlCtrl)
	// Construction/destruction
public:
	CHtmlCtrl();
	virtual ~CHtmlCtrl();

	// Attributes
public:
	static void GetUrl(CString sURL);
	static BOOL ShowHtml(LPWSTR url);

	// Operations
public:
	BOOL CreateFromStatic(UINT nID, CWnd* pParent);

	// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CHyperLink)
protected:
	// Normally, CHtmlView destroys itself in PostNcDestroy,
	// but we don't want to do that for a control since a control
	// is usually implemented as a stack object in a dialog.
	//
	virtual void PostNcDestroy() {  }
	//}}AFX_VIRTUAL
	
	// Generated message map functions
protected:
	//{{AFX_MSG(CHyperLink)
	// overrides to bypass MFC doc/view frame dependencies
	afx_msg void OnDestroy();
	afx_msg int  OnMouseActivate(CWnd* pDesktopWnd, UINT nHitTest, UINT msg);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_HTMLCTRL_H__D1625061_574B_11D1_ABBA_00A0243D1382__INCLUDED_)