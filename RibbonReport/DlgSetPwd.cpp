// DlgSetPwd.cpp : 实现文件
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "DlgSetPwd.h"


/////////////////////////////////////////////////////////////////////////////
// CDlgSetPwd 对话框

CDlgSetPwd::CDlgSetPwd(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgSetPwd::IDD, pParent)
	, m_strUser(_T(""))
	, m_strPwd(_T(""))
	, m_strPwd2(_T(""))
	, m_strPwd3(_T(""))
{
	m_hIcon= AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CDlgSetPwd::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_SETPWD_ET_USER, m_strUser);
	DDX_Text(pDX, IDC_SETPWD_ET_PWD, m_strPwd);
	DDX_Text(pDX, IDC_SETPWD_ET_PWD2, m_strPwd2);
	DDX_Text(pDX, IDC_SETPWD_ET_PWD3, m_strPwd3);
}

BEGIN_MESSAGE_MAP(CDlgSetPwd, CDialog)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgSetPwd 消息处理程序
BOOL CDlgSetPwd::OnInitDialog()
{
	CDialog::OnInitDialog();

	// TODO:  在此添加额外的初始化
	SetIcon(m_hIcon, TRUE);
	SetIcon(m_hIcon, FALSE);
	
	// TODO: 在此添加控件通知处理程序代码

	UpdateData(FALSE);
	return TRUE;
	// 异常: OCX 属性页应返回 FALSE
}