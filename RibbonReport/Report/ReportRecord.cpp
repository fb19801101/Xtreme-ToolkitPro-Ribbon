// ReportRecord.cpp: implementation of the CReportRecord class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "RibbonReport.h"
#include "ReportRecord.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

IMPLEMENT_SERIAL(CReportRecord, CXTPReportRecord, VERSIONABLE_SCHEMA | _XTP_SCHEMA_CURRENT)
IMPLEMENT_SERIAL(CReportRecordItemPrice, CXTPReportRecordItemNumber, VERSIONABLE_SCHEMA | _XTP_SCHEMA_CURRENT)
IMPLEMENT_SERIAL(CReportRecordItemCheck, CXTPReportRecordItem, VERSIONABLE_SCHEMA | _XTP_SCHEMA_CURRENT)
IMPLEMENT_SERIAL(CReportRecordItemImportance, CXTPReportRecordItem, VERSIONABLE_SCHEMA | _XTP_SCHEMA_CURRENT)
IMPLEMENT_SERIAL(CReportRecordItemAttachment, CXTPReportRecordItem, VERSIONABLE_SCHEMA | _XTP_SCHEMA_CURRENT)
IMPLEMENT_SERIAL(CReportRecordItemIcon, CXTPReportRecordItem, VERSIONABLE_SCHEMA | _XTP_SCHEMA_CURRENT)
IMPLEMENT_SERIAL(CReportRecordItemDate, CXTPReportRecordItemDateTime, VERSIONABLE_SCHEMA | _XTP_SCHEMA_CURRENT)

//////////////////////////////////////////////////////////////////////////
// CReportRecordItemPrice

CReportRecordItemPrice::CReportRecordItemPrice(double dValue)
: CXTPReportRecordItemNumber(dValue, _T("$ %.2f"))
{

}

CString CReportRecordItemPrice::GetGroupCaption(CXTPReportColumn* /*pColumn*/)
{
	if (m_dValue > 20)
		return _T("Record Price > 20");

	if (m_dValue > 5)
		return _T("Record Price 5 - 20");

	return _T("Record Price < 5");
}

int CReportRecordItemPrice::CompareGroupCaption(CXTPReportColumn* pColumn, CXTPReportRecordItem* pItem)
{
	return GetGroupCaption(pColumn).Compare(pItem->GetGroupCaption(pColumn));
}

//////////////////////////////////////////////////////////////////////////
// CReportRecordItemCheck

CReportRecordItemCheck::CReportRecordItemCheck(BOOL bCheck)
{
	HasCheckbox(TRUE);
	SetChecked(bCheck);
}

int CReportRecordItemCheck::GetGroupCaptionID(CXTPReportColumn* /*pColumn*/)
{
	return IsChecked() ? IDS_REPORT_ITEM_CHECKED_TRUE : IDS_REPORT_ITEM_CHECKED_FALSE;
}

int CReportRecordItemCheck::Compare(CXTPReportColumn* /*pColumn*/, CXTPReportRecordItem* pItem)
{
	return int(IsChecked()) - int(pItem->IsChecked());
}


//////////////////////////////////////////////////////////////////////////
// CReportRecordItemImportance

CReportRecordItemImportance::CReportRecordItemImportance(ENUM_IMPORTANCE eImportance)
	: m_eImportance(eImportance)
{
	SetIconIndex(eImportance == ImportanceHigh ? 6 : 
		         eImportance == ImportanceLow ? 9: -1);

	SetGroupPriority(m_eImportance == ImportanceHigh? IDS_REPORT_ITEM_IMPOPRTANCE_HIGH:
					 m_eImportance == ImportanceLow?  IDS_REPORT_ITEM_IMPOPRTANCE_LOW: IDS_REPORT_ITEM_IMPOPRTANCE_NORMAL);

	SetSortPriority(GetGroupPriority());
	
	CString strToolTip;
	strToolTip.LoadString(GetGroupPriority());
	
	SetTooltip(strToolTip);
}

void CReportRecordItemImportance::DoPropExchange(CXTPPropExchange* pPX)
{
	CXTPReportRecordItem::DoPropExchange(pPX);

	PX_Enum(pPX, _T("Importance"), m_eImportance, ImportanceNormal);
}


//////////////////////////////////////////////////////////////////////////
// CReportRecordItemAttachment

CReportRecordItemAttachment::CReportRecordItemAttachment(BOOL bHasAttachment)
	: m_bHasAttachment(bHasAttachment)
{
	SetIconIndex(bHasAttachment ? 8 : -1);
	SetGroupPriority(m_bHasAttachment? IDS_REPORT_ITEM_ATTACHMENTS_TRUE: IDS_REPORT_ITEM_ATTACHMENTS_FALSE);
	SetSortPriority(GetGroupPriority());
}

void CReportRecordItemAttachment::DoPropExchange(CXTPPropExchange* pPX)
{
	CXTPReportRecordItem::DoPropExchange(pPX);

	PX_Bool(pPX, _T("HasAttachment"), m_bHasAttachment);
}

//////////////////////////////////////////////////////////////////////////
// CReportRecordItemIcon

CReportRecordItemIcon::CReportRecordItemIcon(BOOL bRead, int nReadIndex, int nUnReadIndex)
	: m_bRead(bRead), m_nReadIndex(nReadIndex), m_nUnReadIndex(nUnReadIndex)
{
	UpdateReadIcon();
}

void CReportRecordItemIcon::UpdateReadIcon()
{
	SetIconIndex(m_bRead ? m_nReadIndex : m_nUnReadIndex);
}

int CReportRecordItemIcon::Compare(CXTPReportColumn* /*pColumn*/, CXTPReportRecordItem* pItem)
{
	return int(m_bRead) - int(((CReportRecordItemIcon*)pItem)->m_bRead);
}

CString CReportRecordItemIcon::GetGroupCaption(CXTPReportColumn* /*pColumn*/)
{
	if (m_bRead)
		return _T("Record status: Read");
	else
		return _T("Record status: Unread");
}

int CReportRecordItemIcon::CompareGroupCaption(CXTPReportColumn* pColumn, CXTPReportRecordItem* pItem)
{
	return GetGroupCaption(pColumn).Compare(pItem->GetGroupCaption(pColumn));
}

void CReportRecordItemIcon::DoPropExchange(CXTPPropExchange* pPX)
{
	CXTPReportRecordItem::DoPropExchange(pPX);

	PX_Bool(pPX, _T("Read"), m_bRead);
}


//////////////////////////////////////////////////////////////////////////
// CReportGridRecordItemSent

CReportRecordItemDate::CReportRecordItemDate(COleDateTime odtValue)
	: CXTPReportRecordItemDateTime(odtValue)
{
}

int CReportRecordItemDate::GetGroupCaptionID(CXTPReportColumn* /*pColumn*/)
{
	COleDateTime odtNow(COleDateTime::GetCurrentTime());

	if (m_odtValue.GetYear() < odtNow.GetYear())
		return IDS_REPORT_ITEM_DATE_OLDER;

	if (m_odtValue.GetMonth() < odtNow.GetMonth())
		return IDS_REPORT_ITEM_DATE_THISYEAR;

	if (m_odtValue.GetDay() < odtNow.GetDay())
		return IDS_REPORT_ITEM_DATE_THISMONTH;

	if (m_odtValue.m_dt <= odtNow.m_dt)
		return IDS_REPORT_ITEM_DATE_TODAY;

	return -1;
}



//////////////////////////////////////////////////////////////////////
// CReportRecord class

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CReportRecord::CReportRecord()
{
	m_pItemIcon = NULL;
	m_pItemReceived = NULL;
	m_pItemSize = NULL;

	CreateItems();
}

CReportRecord::CReportRecord(
					ENUM_IMPORTANCE eImportance, BOOL bChecked, int  nAttachmentBitmap,
					CString strFromName, CString strSubject,
					COleDateTime odtReceived, int nMessageSize, BOOL bRead,
					double dPrice, COleDateTime odtSent, COleDateTime odtCreated,
					CString strConversation, CString strContact, CString strMessage,
					CString strCC, CString strCategories, CString strAutoforward,
					CString strDoNotAutoarch, CString strDueBy,
					CString strPreview)
{
	AddItem(new CReportRecordItemImportance(eImportance));
	m_pItemIcon = (CReportRecordItemIcon*)AddItem(new CReportRecordItemIcon(bRead,0,1));
	AddItem(new CReportRecordItemAttachment(nAttachmentBitmap));
	AddItem(new CXTPReportRecordItemText(strFromName));
	AddItem(new CXTPReportRecordItemText(strSubject));
	m_pItemReceived = (CReportRecordItemDate*)AddItem(new CReportRecordItemDate(odtReceived));
	m_pItemSize = AddItem(new CXTPReportRecordItemNumber(nMessageSize));
	AddItem(new CReportRecordItemCheck(bChecked));
	AddItem(new CReportRecordItemPrice(dPrice));
	AddItem(new CReportRecordItemDate(odtCreated));
	AddItem(new CReportRecordItemDate(odtSent));
	AddItem(new CXTPReportRecordItemText(strConversation));
	AddItem(new CXTPReportRecordItemText(strContact));
	AddItem(new CXTPReportRecordItemText(strMessage));
	AddItem(new CXTPReportRecordItemText(strCC));
	AddItem(new CXTPReportRecordItemText(strCategories));
	AddItem(new CXTPReportRecordItemText(strAutoforward));
	AddItem(new CXTPReportRecordItemText(strDoNotAutoarch));
	AddItem(new CXTPReportRecordItemText(strDueBy));

	SetPreviewItem(new CXTPReportRecordItemPreview(strPreview));
}

void CReportRecord::CreateItems()
{
	// Initialize record items with empty values
	
	COleDateTime dtNow(COleDateTime::GetCurrentTime());

	// 0 
	AddItem(new CReportRecordItemImportance(ImportanceNormal));

	// 1 ***
	m_pItemIcon = (CReportRecordItemIcon*)AddItem(new CReportRecordItemIcon(TRUE));
	
	// 2 
	AddItem(new CReportRecordItemAttachment(0));
	
	// 3 
	AddItem(new CXTPReportRecordItemText(_T("")));

	// 4 
	AddItem(new CXTPReportRecordItemText(_T("")));

	// 5 ***
	m_pItemReceived = (CReportRecordItemDate*)AddItem(new CReportRecordItemDate(dtNow));

	// 6 ***
	m_pItemSize = AddItem(new CXTPReportRecordItemNumber(0));
	
	AddItem(new CReportRecordItemCheck(FALSE));
	AddItem(new CReportRecordItemPrice(0));
	AddItem(new CReportRecordItemDate(dtNow));
	AddItem(new CReportRecordItemDate(dtNow));
	AddItem(new CXTPReportRecordItemText(_T("")));
	AddItem(new CXTPReportRecordItemText(_T("")));
	AddItem(new CXTPReportRecordItemText(_T("")));
	AddItem(new CXTPReportRecordItemText(_T("")));
	AddItem(new CXTPReportRecordItemText(_T("")));
	AddItem(new CXTPReportRecordItemText(_T("")));
	AddItem(new CXTPReportRecordItemText(_T("")));
	AddItem(new CXTPReportRecordItemText(_T("")));

	SetPreviewItem(new CXTPReportRecordItemPreview(_T("")));
}

CReportRecord::~CReportRecord()
{

}

BOOL CReportRecord::SetRead()
{
	if(!m_pItemIcon) return FALSE;
	if(m_pItemIcon->m_bRead) return FALSE;

	m_pItemIcon->m_bRead = TRUE;
	m_pItemIcon->UpdateReadIcon();

	return TRUE;
}

void CReportRecord::GetItemMetrics(XTP_REPORTRECORDITEM_DRAWARGS* pDrawArgs, XTP_REPORTRECORDITEM_METRICS* pItemMetrics)
{
	CXTPReportRecord::GetItemMetrics(pDrawArgs, pItemMetrics);
}

void CReportRecord::DoPropExchange(CXTPPropExchange* pPX)
{
	CXTPReportRecord::DoPropExchange(pPX);

	if (pPX->IsLoading())
	{
		// 1 - m_pItemIcon = (CReportRecordItemIcon*)AddItem(new CReportRecordItemIcon(TRUE));
		ASSERT_KINDOF(CReportRecordItemIcon, GetItem(1));
		m_pItemIcon = DYNAMIC_DOWNCAST(CReportRecordItemIcon, GetItem(1));
		if(!m_pItemIcon) return;
		
		// 5 - m_pItemReceived = (CReportRecordItemDate*)AddItem(new CReportRecordItemDate(dtNow));
		ASSERT_KINDOF(CReportRecordItemDate, GetItem(5));
		m_pItemReceived = DYNAMIC_DOWNCAST(CReportRecordItemDate, GetItem(5));
		if(!m_pItemReceived) return;
		
		// 6 - m_pItemSize = AddItem(new CXTPReportRecordItemNumber(0));
		ASSERT_KINDOF(CXTPReportRecordItemNumber, GetItem(6));
		m_pItemSize = DYNAMIC_DOWNCAST(CXTPReportRecordItemNumber, GetItem(6));
		if(!m_pItemSize) return;		
	}
}
