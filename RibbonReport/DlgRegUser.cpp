// DlgRegUser.cpp : ʵ���ļ�
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "DlgRegUser.h"


/////////////////////////////////////////////////////////////////////////////
// CDlgRegUser �Ի���

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
// CDlgRegUser ��Ϣ�������
BOOL CDlgRegUser::OnInitDialog()
{
	CDialog::OnInitDialog();

	// TODO:  �ڴ���Ӷ���ĳ�ʼ��
	SetIcon(m_hIcon, TRUE);
	SetIcon(m_hIcon, FALSE);
	
	// TODO: �ڴ���ӿؼ�֪ͨ����������

	return TRUE;
	// �쳣: OCX ����ҳӦ���� FALSE
}