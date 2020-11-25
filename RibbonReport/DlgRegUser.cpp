// DlgRegUser.cpp : 实现文件
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "DlgRegUser.h"


/////////////////////////////////////////////////////////////////////////////
// CDlgRegUser 对话框

CDlgRegUser::CDlgRegUser(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgRegUser::IDD, pParent)
	, m_strUser(_T(""))
	, m_strPwd(_T(""))
	, m_strPwd2(_T(""))
{
	m_hIcon= AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CDlgRegUser::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_REGUSER_ET_USER, m_strUser);
	DDX_Text(pDX, IDC_REGUSER_ET_PWD, m_strPwd);
	DDX_Text(pDX, IDC_REGUSER_ET_PWD2, m_strPwd2);
}

BEGIN_MESSAGE_MAP(CDlgRegUser, CDialog)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgRegUser 消息处理程序
BOOL CDlgRegUser::OnInitDialog()
{
	CDialog::OnInitDialog();

	// TODO:  在此添加额外的初始化
	SetIcon(m_hIcon, TRUE);
	SetIcon(m_hIcon, FALSE);
	
	// TODO: 在此添加控件通知处理程序代码

	return TRUE;
	// 异常: OCX 属性页应返回 FALSE
}