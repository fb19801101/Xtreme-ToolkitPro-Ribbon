// DlgLogin.cpp : 实现文件
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "DlgLogin.h"
#include "DlgSetPwd.h"
#include "DlgRegUser.h"


/////////////////////////////////////////////////////////////////////////////
// CDlgLogin 对话框

CDlgLogin::CDlgLogin(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgLogin::IDD, pParent)
	, m_strUser(_T(""))
	, m_strPwd(_T(""))
	,m_bRemberPwd(FALSE)
	,m_bAutoLogin(FALSE)
	,m_bAutoFrame(FALSE)
{
	m_hIcon= AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CDlgLogin::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_LOGIN_ET_USER, m_strUser);
	DDX_Text(pDX, IDC_LOGIN_ET_PWD, m_strPwd);
	DDX_Check(pDX, IDC_LOGIN_CK_LOGIN, m_bAutoLogin);
	DDX_Check(pDX, IDC_LOGIN_CK_PWD, m_bRemberPwd);
	DDX_Check(pDX, IDC_LOGIN_CK_FRAME, m_bAutoFrame);
	DDX_Control(pDX, IDC_LOGIN_BN_USER, m_bnUser);
	DDX_Control(pDX, IDC_LOGIN_BN_PWD, m_bnPwd);
}

BEGIN_MESSAGE_MAP(CDlgLogin, CDialog)
	ON_BN_CLICKED(IDC_LOGIN_BN_USER, &CDlgLogin::OnBnClickedLoginBnUser)
	ON_BN_CLICKED(IDC_LOGIN_BN_PWD, &CDlgLogin::OnBnClickedLoginBnPwd)
	ON_BN_CLICKED(IDC_LOGIN_CK_PWD, &CDlgLogin::OnBnClickedLoginCkPwd)
	ON_BN_CLICKED(IDC_LOGIN_CK_LOGIN, &CDlgLogin::OnBnClickedLoginCkLogin)
	ON_BN_CLICKED(IDC_LOGIN_CK_FRAME, &CDlgLogin::OnBnClickedLoginCkFrame)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgLogin 消息处理程序
BOOL CDlgLogin::OnInitDialog()
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

void CDlgLogin::OnBnClickedLoginBnUser()
{
	// TODO: 在此添加控件通知处理程序代码
	CDlgRegUser dlg;
	if(dlg.DoModal() == IDOK)
	{
		if(dlg.m_strPwd == dlg.m_strPwd2)
		{
			g_SysUser = dlg.m_strUser;
			g_SysPwd = dlg.m_strPwd2;
			if(AddSysUser())
			{
				((CEdit*)GetDlgItem(IDC_LOGIN_ET_USER))->SetWindowText(g_SysUser);
				((CEdit*)GetDlgItem(IDC_LOGIN_ET_PWD))->SetWindowText(g_SysPwd);
				msgInf(_T("注册成功！"));
			}
			else msgErr(_T("注册失败！"));
		}
		else msgErr(_T("两次输入密码不同！"));
	}
}

void CDlgLogin::OnBnClickedLoginBnPwd()
{
	// TODO: 在此添加控件通知处理程序代码
	CDlgSetPwd dlg;
	dlg.m_strUser = m_strUser;
	dlg.m_strPwd = m_strPwd;
	if(dlg.DoModal() == IDOK)
	{
		if(dlg.m_strPwd2 == dlg.m_strPwd3)
		{
			if(dlg.m_strPwd != dlg.m_strPwd2)
			{
				g_SysUser = dlg.m_strUser;
				g_SysPwd = dlg.m_strPwd2;
				if(SetSysPwd())
				{
					((CEdit*)GetDlgItem(IDC_LOGIN_ET_USER))->SetWindowText(g_SysUser);
					((CEdit*)GetDlgItem(IDC_LOGIN_ET_PWD))->SetWindowText(g_SysPwd);
					msgInf(_T("密码修改成功！"));
				}
				else msgErr(_T("密码修改失败！"));
			}
			else msgErr(_T("原密码与新密码相同！"));
		}
		else msgErr(_T("两次输入密码不同！"));
	}
}

void CDlgLogin::OnBnClickedLoginCkPwd()
{
	// TODO: 在此添加控件通知处理程序代码
	UpdateData(TRUE);
	g_SysRemberPwd = m_bRemberPwd ? true: false;
	g_SysAutoLogin = false;
	((CButton*)GetDlgItem(IDC_LOGIN_CK_LOGIN))->SetCheck(FALSE);
}

void CDlgLogin::OnBnClickedLoginCkLogin()
{
	// TODO: 在此添加控件通知处理程序代码
	UpdateData(TRUE);
	g_SysRemberPwd = true;
	g_SysAutoLogin = m_bAutoLogin ? true: false;
	((CButton*)GetDlgItem(IDC_LOGIN_CK_PWD))->SetCheck(TRUE);
}

void CDlgLogin::OnBnClickedLoginCkFrame()
{
	// TODO: 在此添加控件通知处理程序代码
	UpdateData(TRUE);
	g_SysAutoFrame = m_bAutoFrame ? true: false;
}

void CDlgLogin::OnOK()
{
	// TODO: 在此添加专用代码和/或调用基类
	UpdateData(TRUE);
	g_SysUser = m_strUser;
	g_SysPwd = m_strPwd;
	g_SysRemberPwd = m_bRemberPwd ? true: false;
	g_SysAutoLogin = m_bAutoLogin ? true: false;
	g_SysAutoFrame = m_bAutoFrame ? true: false;
	SetSysStatus(g_SysRemberPwd,g_SysAutoLogin,g_SysAutoFrame);
	CDialog::OnOK();
}