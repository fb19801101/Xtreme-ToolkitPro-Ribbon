// DlgLoadPwd.cpp : 实现文件
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "DlgLoadPwd.h"


/////////////////////////////////////////////////////////////////////////////
// DlgLoadPwd 对话框

CDlgLoadPwd::CDlgLoadPwd(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgLoadPwd::IDD, pParent)
	, m_strPwd(_T(""))
{
	m_hIcon= AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CDlgLoadPwd::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_LOADPWD_ET_PWD, m_strPwd);
}

BEGIN_MESSAGE_MAP(CDlgLoadPwd, CDialog)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgLoadPwd 消息处理程序
BOOL CDlgLoadPwd::OnInitDialog()
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