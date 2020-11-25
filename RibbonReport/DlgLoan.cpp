// DlgLoan.cpp : ʵ���ļ�
//

#include "stdafx.h"
#include "RibbonReport.h"
#include "DlgLoan.h"
#include "math.h"


/////////////////////////////////////////////////////////////////////////////
// CDlgLoan �Ի���

CDlgLoan::CDlgLoan(CWnd* pParent /*=NULL*/)
	: CDialog(CDlgLoan::IDD, pParent)
{
	m_fYearRate = 0.051;
	m_fTotalInterest = 0.0;
	m_nLoanYears = 20;
	m_fMonthRepayment = 0.0;
	m_fLoanTotal = 20.0;
	m_fYearRepayment = 0.0;
	m_fMonthRate = 0.0;
	m_fMonthRate2 = 0.0;
	m_fYearRate2 = 0.051;
	m_fTotalInterest2 = 0.0;
	m_fDayRate = 0.0;
	m_bEqualMonthRate = FALSE;

	m_hIcon= AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CDlgLoan::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_LOAN_INTEREST, m_listInterest);
	DDX_Control(pDX, IDC_LOAN_PRINCIPAL, m_listPrincipal);
	DDX_Text(pDX, IDC_LOAN_YEAR_RATE, m_fYearRate);
	DDV_MinMaxDouble(pDX, m_fYearRate, 0., 1.);
	DDX_Text(pDX, IDC_LOAN_TOTAL_INTEREST, m_fTotalInterest);
	DDX_Text(pDX, IDC_LOAN_YEARS, m_nLoanYears);
	DDX_Text(pDX, IDC_LOAN_MONTH_REPAYMENT, m_fMonthRepayment);
	DDX_Text(pDX, IDC_LOAN_TOTAL, m_fLoanTotal);
	DDX_Text(pDX, IDC_LOAN_YEAR_REPAYMENT, m_fYearRepayment);
	DDX_Text(pDX, IDC_LOAN_MONTH_RATE, m_fMonthRate);
	DDX_Text(pDX, IDC_LOAN_MONTH_RATE2, m_fMonthRate2);
	DDX_Text(pDX, IDC_LOAN_YEAR_RATE2, m_fYearRate2);
	DDV_MinMaxDouble(pDX, m_fYearRate2, 0., 1.);
	DDX_Text(pDX, IDC_LOAN_TOTAL_INTEREST2, m_fTotalInterest2);
	DDX_Text(pDX, IDC_LOAN_DAY_RATE, m_fDayRate);
	DDX_Check(pDX, IDC_LOAN_EQUAL_MONTH_RATE, m_bEqualMonthRate);
}

BEGIN_MESSAGE_MAP(CDlgLoan, CDialog)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_LOAN_CLAC_EQUAL_MORTGAGE, OnBnCalcequalmortgage)
	ON_BN_CLICKED(IDC_LOAN_CHECK_YEAR_PRINCIPAL, OnBnCheckyearprincipal)
	ON_BN_CLICKED(IDC_LOAN_CLAC_MONTH_MORTGAGE, OnBnClacmonthmortgage)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDlgLoan ��Ϣ�������

BOOL CDlgLoan::OnInitDialog()
{
	CDialog::OnInitDialog();

	// TODO:  �ڴ���Ӷ���ĳ�ʼ��
	SetIcon(m_hIcon, TRUE);
	SetIcon(m_hIcon, FALSE);

	// TODO: �ڴ���ӿؼ�֪ͨ����������
	InitListInterest();
	InitListPrincipal(1);

	UpdateData(FALSE);
	return TRUE;
	// �쳣: OCX ����ҳӦ���� FALSE
}

void CDlgLoan::OnBnCalcequalmortgage() 
{
	// TODO: �ڴ���ӿؼ�֪ͨ����������
	UpdateData(true);

	m_fMonthRate=m_fYearRate/12;             //����������

    double fMonthRate2=m_fMonthRate;         //������
	double fLoanTotal=m_fLoanTotal;          //�����
	double fMonthRepayment=1;                //ÿ�»���Ŀ
	int    nLoanMonths=m_nLoanYears*12;      //��������

    double temp=pow(1+fMonthRate2,nLoanMonths);
	fMonthRepayment=fLoanTotal*(fMonthRate2*temp/(temp-1)) ;
	
	m_fMonthRepayment=fMonthRepayment*10000;
    m_fTotalInterest=fMonthRepayment*nLoanMonths-fLoanTotal;
    m_fYearRepayment=fMonthRepayment*12*10000;
	UpdateData(false);
}

void CDlgLoan::OnBnCheckyearprincipal() 
{
	// TODO: �ڴ���ӿؼ�֪ͨ����������
	UpdateData(true);
	m_listInterest.DeleteAllItems();
	CString str;
	m_fMonthRate=m_fYearRate/12;        //����������

    double fMonthRate2=m_fMonthRate;    //������
	double fLoanTotal=m_fLoanTotal;     //�����
	double fMonthRepayment=0;           //ÿ�»�����Ŀ
	int    nLoanMonths=m_nLoanYears*12; //��������
	
 	double fTotalRepayment=0.0;        //��������

	double temp=pow(1+fMonthRate2,nLoanMonths);
	fMonthRepayment=fLoanTotal*(fMonthRate2*temp/(temp-1)) ;

	int i=1,j=1;
	for(i=1;i<=m_nLoanYears;i++)
	{
		str.Format(_T("%02d��"),i);  
		m_listInterest.InsertItem(i-1,str); 
        
		double a1=fLoanTotal;
		temp=0;
		for(j=1;j<=12;j++)
		{
            double a2=a1*(1+fMonthRate2)-fMonthRepayment;
 		    temp=a1*fMonthRate2+temp;
			a1=a2;
		}

		fLoanTotal=a1;
   		
		str.Format(_T("%lf"),temp);
        m_listInterest.SetItemText(i-1,1,str);

		str.Format(_T("%lf"),fLoanTotal);
		m_listInterest.SetItemText(i-1,2,str);

	    str.Format(_T("%lf"),fMonthRepayment*i*12);
        m_listInterest.SetItemText(i-1,3,str);
	}
}

void CDlgLoan::InitListInterest()
{
     CString str;
	 m_listInterest.ModifyStyle(LVS_EDITLABELS,0L);
	 m_listInterest.ModifyStyle(0L,LVS_REPORT);
	 m_listInterest.ModifyStyle(0L,LVS_SHOWSELALWAYS);
	 m_listInterest.SetExtendedStyle(
		 LVS_EX_FULLROWSELECT|
		 LVS_EX_GRIDLINES|
		 LVS_EX_ONECLICKACTIVATE//| LVS_EX_FLATSB
		);
	 str=_T("����");
	 m_listInterest.InsertColumn(0,str,LVCFMT_LEFT,40);
	 str=_T("����Ϣ(��)");
     m_listInterest.InsertColumn(1,str,LVCFMT_LEFT,75);
	 str=_T("ʣ����(��)");
     m_listInterest.InsertColumn(2,str,LVCFMT_LEFT,75);
	 str=_T("�ۼƻ���(��)");
     m_listInterest.InsertColumn(3,str,LVCFMT_LEFT,90);
}

void CDlgLoan::OnBnClacmonthmortgage() 
{
	// TODO: �ڴ���ӿؼ�֪ͨ����������
	UpdateData(true);
	m_listPrincipal.DeleteAllItems();

	CString str;
	m_fMonthRate2=m_fYearRate2/12;     //����������
    double fMonthRate=m_fMonthRate2;  //������
	double fDayRate=fMonthRate/30;          //�����ʣ�������ʹ涨��һ������31�죬С�º�2����30��ƣ�
	                                   //ÿ����360���,�����ʣ�������/360��
	                                   //���Դ���Ҫ��һ�����ʡ�
	m_fDayRate=fDayRate;
	double fLoanTotal=m_fLoanTotal;                    //�����
	int    nLoanMonths=m_nLoanYears*12;                //��������
	double fMonthRepayment=fLoanTotal/nLoanMonths;     //ÿ��Ҫ������

	double a1=fLoanTotal;
	m_fTotalInterest2=0;
	for(int i=1;i<=nLoanMonths;i++)
	{
		int j=i/12;
		int k=i%12;
		if(k==0) { k=12; j=j-1; }
		str.Format(_T("%02d��%02d��"),j+1,k);
        m_listPrincipal.InsertItem(i-1,str);

		double a2=fLoanTotal-fMonthRepayment*(i-1);         //��ʣ����

	    j=i%12;
		switch(j)
		{
		case 1:   //���·�31�����ʶ��һ������
		case 3:
		case 5:
		case 7:
		case 8:
		case 10:
		case 0:   //12�±���ʱ
             a1=a2*(fMonthRate+fDayRate);
			 break;
		case 2:   //2�·�28��Ҫ������������
			 a1=a2*(fMonthRate-2*fDayRate);
			 break; 
		default:  //С�·�30��
			 a1=a2*fMonthRate;
             break;
		}

        if(m_bEqualMonthRate) a1=a2*fMonthRate;

	    str.Format(_T("%lf"),a1);
	    m_listPrincipal.SetItemText(i-1,1,str);
	    double temp=fMonthRepayment+a1;
		m_fTotalInterest2=a1+m_fTotalInterest2;
        str.Format(_T("%lf"),temp);
	    m_listPrincipal.SetItemText(i-1,2,str);
        str.Format(_T("%lf"),a2-fMonthRepayment);
	    m_listPrincipal.SetItemText(i-1,3,str);

	}
	UpdateData(false);
}

void CDlgLoan::InitListPrincipal(int flag)
{
     CString str;
	 m_listPrincipal.ModifyStyle(LVS_EDITLABELS,0L);
	 m_listPrincipal.ModifyStyle(0L,LVS_REPORT);
	 m_listPrincipal.ModifyStyle(0L,LVS_SHOWSELALWAYS);
	 m_listPrincipal.SetExtendedStyle(
		 LVS_EX_FULLROWSELECT|
		 LVS_EX_GRIDLINES|
		 LVS_EX_ONECLICKACTIVATE//| LVS_EX_FLATSB
		);
	 str=_T("����");
	 m_listPrincipal.InsertColumn(0,str,LVCFMT_LEFT,55);
	 str=_T("����Ϣ(��)");
     m_listPrincipal.InsertColumn(1,str,LVCFMT_LEFT,75);
	 str=_T("�°���(��)");
     m_listPrincipal.InsertColumn(2,str,LVCFMT_LEFT,75);
	 str=_T("ʣ����(��)");
     m_listPrincipal.InsertColumn(3,str,LVCFMT_LEFT,75);
}