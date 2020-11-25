// WebHtmlView.cpp : implementation file
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
#include "RibbonReport.h"
#include "WebHtmlView.h"
#include "MainFrm.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#ifndef DISPID_NEWWINDOW3
#define DISPID_NEWWINDOW3 273
#endif

/////////////////////////////////////////////////////////////////////////////
// CWebHtmlView

IMPLEMENT_DYNCREATE(CWebHtmlView, CHtmlView)

CWebHtmlView::CWebHtmlView()
{
	//{{AFX_DATA_INIT(CWebHtmlView)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT

	m_hinstance = NULL;
}

CWebHtmlView::~CWebHtmlView()
{
}

void CWebHtmlView::DoDataExchange(CDataExchange* pDX)
{
	CHtmlView::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CWebHtmlView)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CWebHtmlView, CHtmlView)
	//{{AFX_MSG_MAP(CWebHtmlView)
		// NOTE - the ClassWizard will add and remove mapping macros here.
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

BEGIN_EVENTSINK_MAP(CWebHtmlView, CHtmlView)
	ON_EVENT(CWebHtmlView, AFX_IDW_PANE_FIRST, DISPID_NEWWINDOW3, OnNewWindow3, VTS_PDISPATCH VTS_PBOOL VTS_UI4 VTS_BSTR VTS_BSTR)
END_EVENTSINK_MAP()

/////////////////////////////////////////////////////////////////////////////
// CWebHtmlView diagnostics

#ifdef _DEBUG
void CWebHtmlView::AssertValid() const
{
	CHtmlView::AssertValid();
}

void CWebHtmlView::Dump(CDumpContext& dc) const
{
	CHtmlView::Dump(dc);
}
#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CWebHtmlView message handlers

void CWebHtmlView::OnInitialUpdate()
{
	//TODO: This code navigates to a popular spot on the web.
	//Change the code to go where you'd like.

	XTPCHAR path[MAX_PATH];
	GetModuleFileName(AfxGetApp()->m_hInstance,path,MAX_PATH);
	CXTPString xml(path),val;
	xml = xml.Mid(0,xml.ReverseFind('\\'));
	theCon.SetDataPath(xml);
	xml = xml+"\\RibbonReport.xml";
	CXTPTinyXmlDocument doc(xml);
	if(doc.LoadFile())
	{
		CXTPTinyXmlNode* node = doc.RootElement();
		if(!node) return;
		CXTPTinyXmlElement* root = node->ToElement();
		if(!root) return;
		val = CXTPString(root->Attribute("Net"));
		Navigate2(val);
		doc.SaveFile();
	}
}

BOOL CWebHtmlView::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Add your specialized code here and/or call the base class
	cs.dwExStyle |= WS_EX_CONTROLPARENT;
		cs.style |= WS_CLIPCHILDREN|WS_CLIPSIBLINGS;

	return CHtmlView::PreCreateWindow(cs);
}

void CWebHtmlView::OnNewWindow2(LPDISPATCH* ppDisp, BOOL* Cancel)
{ 
	if(m_hinstance == NULL)
		m_hinstance = ShellExecuteOpen(m_strURL);

	*Cancel=TRUE;
	CHtmlView::OnNewWindow2(ppDisp,Cancel);
}

void CWebHtmlView::OnBeforeNavigate2(LPCTSTR lpszURL, DWORD nFlags, LPCTSTR lpszTargetFrameName, CByteArray& baPostedData, LPCTSTR lpszHeaders, BOOL* pbCancel)
{
	m_strURL = lpszURL;
}

void CWebHtmlView::OnNavigateComplete2(LPCTSTR strURL)
{
	if(m_strURL != strURL)
		m_strURL = strURL;
}

void CWebHtmlView::OnNewWindow3( LPDISPATCH* ppDisp, BOOL* Cancel, DWORD dwFlags, LPCTSTR bstrUrlContext, LPCTSTR bstrUrl)
{
	*Cancel = TRUE;
	Navigate2(bstrUrl);
}

void CWebHtmlView::NavigateURL(CString strURL)
{
	m_strURL = strURL;
	Navigate2(m_strURL);
}