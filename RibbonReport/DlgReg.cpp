// DlgReg.cpp : 实现文件
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "DlgReg.h"


/////////////////////////////////////////////////////////////////////////////
// CDlgReg 对话框

CDlgReg::CDlgReg(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgReg::IDD, pParent)
{
	m_hIcon= AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CDlgReg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CDlgReg, CDialog)
	ON_BN_CLICKED(IDC_REG_BN_CODE, &CDlgReg::OnBnClickedRegBnCode)
	ON_BN_CLICKED(IDOK, &CDlgReg::OnBnClickedRegBnReg)
	ON_BN_CLICKED(IDCANCEL, &CDlgReg::OnBnClickedRegBnExit)
	ON_BN_CLICKED(IDC_REG_BN_SERIAL, &CDlgReg::OnBnClickedRegBnSerial)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgReg 消息处理程序
BOOL CDlgReg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// TODO:  在此添加额外的初始化
	SetIcon(m_hIcon, TRUE);
	SetIcon(m_hIcon, FALSE);
	
	// TODO: 在此添加控件通知处理程序代码
	((CEdit*)GetDlgItem(IDC_REG_ET_CODE))->SetReadOnly(!IsAdmin);
	GetDlgItem(IDC_REG_BN_SERIAL)->ShowWindow(IsAdmin);

	return TRUE;
	// 异常: OCX 属性页应返回 FALSE
}

void CDlgReg::OnBnClickedRegBnCode()
{
	// TODO: 在此添加控件通知处理程序代码
	CString reg_user;
	GetDlgItem(IDC_REG_ET_USER)->GetWindowText(reg_user);
	if(reg_user.IsEmpty())
	{
		msgErr(_T("用户名不能为空！"));
		return;
	}

	CString reg_code = DiskSerial()+MacAddress();

	GetDlgItem(IDC_REG_ET_CODE)->SetWindowText(reg_code);
}

void CDlgReg::OnBnClickedRegBnSerial()
{
	// TODO: 在此添加控件通知处理程序代码
	CString reg_user;
	GetDlgItem(IDC_REG_ET_USER)->GetWindowText(reg_user);
	if(reg_user.IsEmpty())
	{
		msgErr(_T("用户名不能为空！"));
		return;
	}

	CString reg_code;
	CString reg_serial;
	
	GetDlgItem(IDC_REG_ET_CODE)->GetWindowText(reg_code);
	if(reg_code.IsEmpty())
	{
		msgErr(_T("机器码不能为空！"));
		reg_code = (DiskSerial()+MacAddress()).t_str();
		GetDlgItem(IDC_REG_ET_CODE)->SetWindowText(reg_code);
	}

	CString disk = reg_code.Mid(0,8);
	CString mac = reg_code.Mid(8,19);
	reg_code = disk.Mid(3,4)+mac.Mid(4,6);
	reg_serial = SnKey(reg_code).t_str();

	GetDlgItem(IDC_REG_ET_SN1)->SetWindowText(reg_serial.Mid(0,5));
	GetDlgItem(IDC_REG_ET_SN2)->SetWindowText(reg_serial.Mid(5,5));
	GetDlgItem(IDC_REG_ET_SN3)->SetWindowText(reg_serial.Mid(10,5));
	GetDlgItem(IDC_REG_ET_SN4)->SetWindowText(reg_serial.Mid(15,5));
}

void CDlgReg::OnBnClickedRegBnReg()
{
	// TODO: 在此添加控件通知处理程序代码
	CString reg_user;
	GetDlgItem(IDC_REG_ET_USER)->GetWindowText(reg_user);
	if(reg_user.IsEmpty())
	{
		msgErr(_T("用户名不能为空！"));
		return;
	}

	CString reg_code;
	GetDlgItem(IDC_REG_ET_CODE)->GetWindowText(reg_code);
	if(reg_code.IsEmpty())
	{
		msgErr(_T("机器码不能为空！"));
		return;
	}

	HKEY key;
	//CXTPString skey="Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\App Paths\\RibbonReport";
	CXTPString skey="Software\\Microsoft\\Windows\\CurrentVersion\\App Paths\\RibbonReport";
	if(RegCreateKey(HKEY_LOCAL_MACHINE,skey,&key) == ERROR_SUCCESS)//如果没有子项就新建，有直接返回
	{
		CTime tm = CTime::GetCurrentTime();
		CString reg_date = tm.Format(_T("%Y-%m-%d"));
		RegSetValueEx(key,_T("RegDate"),0,REG_SZ,(BYTE*)reg_date.GetBuffer(),2*reg_date.GetLength());
		RegSetValueEx(key,_T("RegUser"),0,REG_SZ,(BYTE*)reg_user.GetBuffer(),2*reg_user.GetLength());
		RegSetValueEx(key,_T("RegCode"),0,REG_SZ,(BYTE*)reg_code.GetBuffer(),2*reg_code.GetLength());

		CString sn1,sn2,sn3,sn4,reg_serial;
		GetDlgItem(IDC_REG_ET_SN1)->GetWindowText(sn1);
		GetDlgItem(IDC_REG_ET_SN2)->GetWindowText(sn2);
		GetDlgItem(IDC_REG_ET_SN3)->GetWindowText(sn3);
		GetDlgItem(IDC_REG_ET_SN4)->GetWindowText(sn4);
		reg_serial = sn1+sn2+sn3+sn4;

		CString serial = SnKey(DiskSerial().Mid(3,4)+MacAddress().Mid(4,6));
		if(!reg_serial.IsEmpty())
		{
			if(reg_serial == serial)
			{
				reg_serial = reg_user+"_"+reg_serial;
				RegSetValueEx(key,_T("RegSerial"),0,REG_SZ,(BYTE*)reg_serial.GetBuffer(),2*reg_serial.GetLength());
				RegSetValueEx(key,_T("IsReged"),0,REG_SZ,(BYTE*)"1",1);
				msgInf(_T("注册成功!"));
			}
			else
			{
				reg_serial = reg_user+"_"+reg_serial;
				RegSetValueEx(key,_T("RegSerial"),0,REG_SZ,(BYTE*)serial.GetBuffer(),2*serial.GetLength());
				RegSetValueEx(key,_T("IsReged"),0,REG_SZ,(BYTE*)"0",1);
				msgErr(_T("注册失败!"));
			}
		}
		else
		{
			msgErr(_T("注册码不能为空！"));
		}
	}

	RegCloseKey(key);
}

void CDlgReg::OnBnClickedRegBnExit()
{
	// TODO: 在此添加控件通知处理程序代码
	CDialog::OnCancel();
}