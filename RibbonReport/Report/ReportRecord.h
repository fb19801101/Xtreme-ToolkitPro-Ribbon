// ReportRecord.h: interface for the CReportRecord class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_REPORTRECORD_H__INCLUDED_)
#define AFX_REPORTRECORD_H__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000


//////////////////////////////////////////////////////////////////////////
// Customized record item, used for displaying prices.
class CReportRecordItemPrice : public CXTPReportRecordItemNumber
{
	DECLARE_SERIAL(CReportRecordItemPrice)
public:
	// Constructs record item with the initial decimal price value.
	CReportRecordItemPrice(double dValue = .0);

	// Provides custom group captions depending on the price.
	virtual CString GetGroupCaption(CXTPReportColumn* pColumn);

	// Provides custom group values comparison based on price value, 
	// instead of based on captions.
	virtual int CompareGroupCaption(CXTPReportColumn* pColumn, CXTPReportRecordItem* pItem);
};

//////////////////////////////////////////////////////////////////////////
// Customized record item, used for displaying checkboxes.
class CReportRecordItemCheck : public CXTPReportRecordItem
{
	DECLARE_SERIAL(CReportRecordItemCheck)
public:
	// Constructs record item with the initial checkbox value.
	CReportRecordItemCheck(BOOL bCheck = FALSE);

	// Provides custom group captions depending on checkbox value.
	// Returns caption string ID to be read from application resources.
	virtual int GetGroupCaptionID(CXTPReportColumn* pColumn);

	// Provides custom records comparison by this item based on checkbox value, 
	// instead of based on captions.
	virtual int Compare(CXTPReportColumn* pColumn, CXTPReportRecordItem* pItem);
};

//////////////////////////////////////////////////////////////////////////
// Enumerates possible Message Importance values for using by 
// CReportRecordItemImportance class
typedef enum ENUM_IMPORTANCE
{
	ImportanceNormal,
	ImportanceHigh,
	ImportanceLow
};

//////////////////////////////////////////////////////////////////////////
// Customized record item, used for displaying importance icons.
class CReportRecordItemImportance : public CXTPReportRecordItem
{
	DECLARE_SERIAL(CReportRecordItemImportance)
public:
	// Constructs record item with the initial value.
	CReportRecordItemImportance(ENUM_IMPORTANCE eImportance = ImportanceNormal);
	
	virtual void DoPropExchange(CXTPPropExchange* pPX);
protected:
	ENUM_IMPORTANCE m_eImportance;   // Message importance
};

//////////////////////////////////////////////////////////////////////////
// Customized record item, used for displaying attachments icons.
class CReportRecordItemAttachment : public CXTPReportRecordItem
{
	DECLARE_SERIAL(CReportRecordItemAttachment)
public:
	// Constructs record item with the initial value.
	CReportRecordItemAttachment(BOOL bHasAttachment = FALSE);

	virtual void DoPropExchange(CXTPPropExchange* pPX);
protected:
	BOOL m_bHasAttachment;	// TRUE when message has attachments, FALSE otherwise.
};

//////////////////////////////////////////////////////////////////////////
// Customized record item, used for displaying read/unread icons.
class CReportRecordItemIcon : public CXTPReportRecordItem
{
	DECLARE_SERIAL(CReportRecordItemIcon)
public:
	// Constructs record item with the initial read/unread value.
	CReportRecordItemIcon(BOOL bRead = FALSE, int nReadIndex = 0, int nUnReadIndex = 0);

	// Provides custom group captions depending on the read/unread value.
	virtual CString GetGroupCaption(CXTPReportColumn* pColumn);

	// Provides custom group values comparison based on read/unread value, 
	// instead of based on captions.
	virtual int CompareGroupCaption(CXTPReportColumn* pColumn, CXTPReportRecordItem* pItem);

	// Updates record item icon index depending on read/unread value.
	void UpdateReadIcon();

	// Provides custom records comparison by this item based on read/unread value, 
	// instead of based on captions.
	int Compare(CXTPReportColumn* pColumn, CXTPReportRecordItem* pItem);

	virtual void DoPropExchange(CXTPPropExchange* pPX);

public:
	BOOL m_bRead;	// TRUE for read, FALSE for unread.
	int m_nReadIndex, m_nUnReadIndex;
};

//////////////////////////////////////////////////////////////////////////
// Customized record Date/Time item.
// Main customization purpose is overriding GetGroupCaptionID and providing
// application-specific caption when Report control data is grouped via this item.
class CReportRecordItemDate : public CXTPReportRecordItemDateTime
{
	DECLARE_SERIAL(CReportRecordItemDate)
public:
	// Construct record item from COleDateTime value.
	CReportRecordItemDate(COleDateTime odtValue = COleDateTime::GetCurrentTime());

	// Provides custom group captions depending on the item date value.
	virtual int GetGroupCaptionID(CXTPReportColumn* pColumn);
};

//////////////////////////////////////////////////////////////////////////
// This class is your main custom Record class which you'll manipulate with.
// It contains any kind of specific methods like different types of constructors,
// any additional custom data as class members, any data manipulation methods.
class CReportRecord : public CXTPReportRecord
{
	DECLARE_SERIAL(CReportRecord)
public:
	
	// Construct record object using empty values on each field
	CReportRecord();
	
	// Construct record object from detailed values on each field
	CReportRecord(
		ENUM_IMPORTANCE eImportance, BOOL bChecked, int  nAttachmentBitmap,
		CString strFromName, CString strSubject,
		COleDateTime odtSent, int nMessageSize, BOOL bRead,
		double dPrice, COleDateTime odtReceived, COleDateTime odtCreated,
		CString strConversation, CString strContact, CString strMessage,
		CString strCC, CString strCategories, CString strAutoforward,
		CString strDoNotAutoarch, CString strDueBy,
		CString strPreview
		);

	// Clean up internal objects
	virtual ~CReportRecord();

	// Create record fields using empty values
	virtual void CreateItems();

	// Set message as read
	BOOL SetRead();

	// Overridden callback method, where we can customize any drawing item metrics.
	virtual void GetItemMetrics(XTP_REPORTRECORDITEM_DRAWARGS* pDrawArgs, XTP_REPORTRECORDITEM_METRICS* pItemMetrics);

	virtual void DoPropExchange(CXTPPropExchange* pPX);

	CReportRecordItemIcon* m_pItemIcon;	// Display read/unread icon.
	CReportRecordItemDate* m_pItemReceived;// Contains message receive time.
	CXTPReportRecordItem*	m_pItemSize;	// Message size. 
											// We are storing pointer to this item for further use.
};


class CPropertyRecordGroup : public CXTPReportRecord
{
public:
	CPropertyRecordGroup(CString strCaption)
	{
		AddItem(new CXTPReportRecordItemText(strCaption));

		CXTPReportRecordItem* pItem = AddItem(new CXTPReportRecordItemText(_T("")));
		pItem->SetEditable(FALSE);

		AddItem(new CXTPReportRecordItemText(_T("")));
	}
};

class CPropertyRecordVariant : public CXTPReportRecord
{
public:
	CPropertyRecordVariant(UINT nID, CString strCaption, COleVariant vValue)
	{
		AddItem(new CXTPReportRecordItemText(strCaption));

		CXTPReportRecordItem* pItem = AddItem(new CXTPReportRecordItemVariant(vValue));
		pItem->SetItemData(nID);
		AddItem(new CXTPReportRecordItemText(_T("Variant")));
	}

	static COleVariant GetValue(XTP_NM_REPORTRECORDITEM* pItemNotify)
	{
		return ((CXTPReportRecordItemVariant*)pItemNotify->pItem)->GetValue();
	}
};

class CPropertyRecordInt : public CXTPReportRecord
{
public:
	CPropertyRecordInt(UINT nID, CString strCaption, int nValue)
	{
		AddItem(new CXTPReportRecordItemText(strCaption));

		CXTPReportRecordItem* pItem = AddItem(new CXTPReportRecordItemNumber(nValue));
		pItem->SetItemData(nID);

		AddItem(new CXTPReportRecordItemText(_T("Int")));
	}

	static int GetValue(XTP_NM_REPORTRECORDITEM* pItemNotify)
	{
		return (int)((CXTPReportRecordItemNumber*)pItemNotify->pItem)->GetValue();
	}
};

class CPropertyRecordDouble : public CXTPReportRecord
{
public:
	CPropertyRecordDouble(UINT nID, CString strCaption, double fValue, CString fmt=_T("%.3f"))
	{
		AddItem(new CXTPReportRecordItemText(strCaption));

		CXTPReportRecordItem* pItem = AddItem(new CXTPReportRecordItemNumber(fValue,fmt));
		pItem->SetItemData(nID);

		AddItem(new CXTPReportRecordItemText(_T("Double")));
	}

	static double GetValue(XTP_NM_REPORTRECORDITEM* pItemNotify)
	{
		return ((CXTPReportRecordItemNumber*)pItemNotify->pItem)->GetValue();
	}
};

class CPropertyRecordText : public CXTPReportRecord
{
public:
	CPropertyRecordText(UINT nID, CString strCaption, CString strValue)
	{
		AddItem(new CXTPReportRecordItemText(strCaption));

		CXTPReportRecordItem* pItem = AddItem(new CXTPReportRecordItemText(strValue));
		pItem->SetItemData(nID);

		AddItem(new CXTPReportRecordItemText(_T("Text")));
	}

	static CString GetValue(XTP_NM_REPORTRECORDITEM* pItemNotify)
	{
		return ((CXTPReportRecordItemText*)pItemNotify->pItem)->GetValue();
	}
};

class CPropertyRecordBool : public CXTPReportRecord
{
protected:
	class CPropertyRecordItemBool : public CXTPReportRecordItem
	{
	public:
		CPropertyRecordItemBool(BOOL bValue)
		{
			m_bValue = bValue;
			GetEditOptions(NULL)->AddConstraint(_T("True"), TRUE);
			GetEditOptions(NULL)->AddConstraint(_T("False"), FALSE);
			GetEditOptions(NULL)->m_bConstraintEdit = TRUE;
			GetEditOptions(NULL)->AddComboButton();
		}

		CString GetCaption(CXTPReportColumn* /*pColumn*/)
		{
			CXTPReportRecordItemConstraint* pConstraint = GetEditOptions(NULL)->FindConstraint(m_bValue);
			if(!pConstraint) return _T("");
			return pConstraint->m_strConstraint;
		}

		void OnConstraintChanged(XTP_REPORTRECORDITEM_ARGS* /*pItemArgs*/, CXTPReportRecordItemConstraint* pConstraint)
		{
			m_bValue = (BOOL)pConstraint->m_dwData;
		}

		BOOL GetValue()
		{
			return m_bValue;
		}

	protected:
		BOOL m_bValue;
	};

public:
	CPropertyRecordBool(UINT nID, CString strCaption, BOOL bValue)
	{
		AddItem(new CXTPReportRecordItemText(strCaption));

		CXTPReportRecordItem* pItem = AddItem(new CPropertyRecordItemBool(bValue));
		pItem->SetItemData(nID);

		AddItem(new CXTPReportRecordItemText(_T("bool")));
	}

	static BOOL GetValue(XTP_NM_REPORTRECORDITEM* pItemNotify)
	{
		return ((CPropertyRecordItemBool*)pItemNotify->pItem)->GetValue();
	}
};

class CPropertyRecordCheck : public CXTPReportRecord
{
public:
	CPropertyRecordCheck(UINT nID, CString strCaption, BOOL bValue)
	{
		AddItem(new CXTPReportRecordItemText(strCaption));

		CXTPReportRecordItem* pItem = AddItem(new CXTPReportRecordItemNumber(bValue));
		pItem->SetItemData(nID);
		pItem->HasCheckbox(TRUE);
		pItem->SetChecked(bValue);

		AddItem(new CXTPReportRecordItemText(_T("Check")));
	}

	static BOOL GetValue(XTP_NM_REPORTRECORDITEM* pItemNotify)
	{
		return (BOOL)((CXTPReportRecordItemNumber*)pItemNotify->pItem)->GetValue();
	}
};

class CPropertyRecordDate : public CXTPReportRecord
{
public:
	CPropertyRecordDate(UINT nID, CString strCaption, COleDateTime odtValue)
	{
		AddItem(new CXTPReportRecordItemText(strCaption));

		CXTPReportRecordItem* pItem = AddItem(new CXTPReportRecordItemDateTime(odtValue));
		pItem->SetItemData(nID);

		AddItem(new CXTPReportRecordItemText(_T("Date")));
	}

	static COleDateTime GetValue(XTP_NM_REPORTRECORDITEM* pItemNotify)
	{
		return (COleDateTime)((CXTPReportRecordItemDateTime*)pItemNotify->pItem)->GetValue();
	}
};

class CPropertyRecordIcon : public CXTPReportRecord
{
public:
	CPropertyRecordIcon(UINT nID, CString strCaption, int nValue)
	{
		AddItem(new CXTPReportRecordItemText(strCaption));

		CXTPReportRecordItem* pItem = AddItem(new CXTPReportRecordItemNumber(nValue));
		pItem->SetItemData(nID);
		pItem->SetIconIndex(nValue);

		AddItem(new CXTPReportRecordItemText(_T("Icon")));
	}

	static int GetValue(XTP_NM_REPORTRECORDITEM* pItemNotify)
	{
		return (int)((CXTPReportRecordItemNumber*)pItemNotify->pItem)->GetValue();
	}
};

class CPropertyRecordComboBox : public CXTPReportRecord
{
protected:
	class CPropertyRecordItemComboBox : public CXTPReportRecordItem
	{
	public:
		CPropertyRecordItemComboBox(CStringArray& strValues)
		{
			m_nValue = -1;
			for(int i=0; i<strValues.GetCount(); i++)
			{
				GetEditOptions(NULL)->AddConstraint(strValues[i], i);
				m_strValues.Add(strValues[i]);
			}

			GetEditOptions(NULL)->m_bConstraintEdit = TRUE;
			GetEditOptions(NULL)->AddComboButton();
		}

		CString GetCaption(CXTPReportColumn* /*pColumn*/)
		{
			CXTPReportRecordItemConstraint* pConstraint = GetEditOptions(NULL)->FindConstraint(m_nValue);
			if(!pConstraint) return _T("");
			return pConstraint->m_strConstraint;
		}

		void OnConstraintChanged(XTP_REPORTRECORDITEM_ARGS* /*pItemArgs*/, CXTPReportRecordItemConstraint* pConstraint)
		{
			m_nValue = (int)pConstraint->m_dwData;
		}

		int GetValue()
		{
			return m_nValue;
		}

		CString GetString()
		{
			return m_strValues[m_nValue];
		}

	protected:
		int     m_nValue;
		CStringArray m_strValues;
	};

public:
	CPropertyRecordComboBox(UINT nID, CString strCaption, CStringArray& strValues)
	{
		AddItem(new CXTPReportRecordItemText(strCaption));

		CXTPReportRecordItem* pItem = AddItem(new CPropertyRecordItemComboBox(strValues));
		pItem->SetItemData(nID);

		AddItem(new CXTPReportRecordItemText(_T("ComboBox")));
	}

	static int GetValue(XTP_NM_REPORTRECORDITEM* pItemNotify)
	{
		return ((CPropertyRecordItemComboBox*)pItemNotify->pItem)->GetValue();
	}
};

class CPropertyRecordColor : public CXTPReportRecord
{
public:
	class CPropertyRecordItemColor : public CXTPReportRecordItem
	{
	public:
		CPropertyRecordItemColor(COLORREF clrValue)
		{
			m_clrValue = clrValue;
		}

		virtual void OnDrawCaption(	XTP_REPORTRECORDITEM_DRAWARGS *pDrawArgs, XTP_REPORTRECORDITEM_METRICS  *pMetrics)
		{
			CXTPReportRecordItem::OnDrawCaption(pDrawArgs, pMetrics);

			CString strText = pMetrics->strText;

			// draw item text
			if (!strText.IsEmpty())
			{
				CRect rcItem(pDrawArgs->rcItem);
				CXTPFontDC font(pDrawArgs->pDC, pMetrics->pFont);
				COLORREF clr = pDrawArgs->pDC->GetTextColor();
				CRect rcSample(rcItem.left - 2, rcItem.top + 1, rcItem.left + 18, rcItem.bottom - 1);
				CXTPPenDC pen(pDrawArgs->pDC->m_hDC, clr);
				CXTPBrushDC brush(pDrawArgs->pDC->m_hDC, StringToRGB(strText));
				pDrawArgs->pDC->Rectangle(rcSample);

				CRect rcText(rcItem);
				rcText.left += 25;

				pDrawArgs->pDC->DrawText(strText, rcText, DT_SINGLELINE | DT_VCENTER);
			}
		}

		virtual void OnClick(XTP_REPORTRECORDITEM_CLICKARGS* pClickArgs)
		{
			CXTPReportRecordItem::OnClick(pClickArgs);

			CWnd* pWnd = pClickArgs->pControl;
			int clrType = xtpGridItemColorPopup;

			if (clrType == xtpGridItemColorPopup)
			{
				CXTPColorPopup *pColorPopup = new CXTPColorPopup();
				pColorPopup->SetTheme(xtpControlThemeOfficeXP);

				CRect rcItem = pClickArgs->rcItem;
				pWnd->ClientToScreen(&rcItem);

				COLORREF clrDefault = RGB(0,0,0);
				pColorPopup->Create(rcItem, pWnd, CPS_XTP_RIGHTALIGN|CPS_XTP_USERCOLORS|CPS_XTP_EXTENDED|CPS_XTP_MORECOLORS|CPS_XTP_SHOW3DSELECTION|CPS_XTP_SHOWHEXVALUE, m_clrValue, clrDefault);
				pColorPopup->SetOwner(pWnd);
				pColorPopup->SetFocus();
				pColorPopup->AddListener(pColorPopup->GetSafeHwnd());

				InternalAddRef();
			}
			else if (clrType == xtpGridItemColorExtendedDialog)
			{
				InternalAddRef();

				CXTPColorDialog dlg(m_clrValue, m_clrValue, CPS_XTP_SHOW3DSELECTION|CPS_XTP_SHOWEYEDROPPER, pWnd);

				if (dlg.DoModal() == IDOK)
				{
					m_clrValue = dlg.GetColor();
				}

				InternalRelease();
			}
			else
			{
				InternalAddRef();

				CColorDialog dlg(m_clrValue, 0, pWnd);

				if (dlg.DoModal() == IDOK)
				{
					m_clrValue = dlg.GetColor();
				}

				InternalRelease();
			}
		}

		COLORREF GetValue()
		{
			return m_clrValue;
		}

		static int NextNumber(LPCTSTR& str)
		{
			int nResult = 0;

			if (!str || !*str)
				return nResult;

			while (*str && *str != '-' && (*str < '0' || *str > '9'))
				str++;

			BOOL bHasSign = *str == '-';
			if (bHasSign)
				str++;

			while (*str >= '0' && *str <= '9')
			{
				nResult = nResult * 10 + (*str - '0');
				str++;
			}

			return bHasSign ? -nResult : nResult;
		}

		static COLORREF StringToRGB(LPCTSTR str)
		{
			int nRed = NextNumber(str);
			int nGreen = NextNumber(str);
			int nBlue = NextNumber(str);

			return RGB(__min(nRed, 255), __min(nGreen, 255), __min(nBlue, 255));
		}

		static CString RGBToString(COLORREF clr)
		{
			CString str;
			str.Format(_T("%i; %i; %i"), GetRValue(clr), GetGValue(clr), GetBValue(clr));
			return str;
		}

	protected:
		COLORREF m_clrValue;
	};

	CPropertyRecordColor(UINT nID, CString strCaption, COLORREF clrValue)
	{
		AddItem(new CXTPReportRecordItemText(strCaption));

		CXTPReportRecordItem* pItem = AddItem(new CPropertyRecordItemColor(clrValue));
		pItem->SetItemData(nID);

		CXTPReportRecordItemControl* pButton = pItem->GetItemControls()->AddControl(xtpItemControlTypeButton);
		if(pButton)
		{
			pButton->SetAlignment(xtpItemControlRight);
			pButton->SetCaption(_T("..."));
		}

		AddItem(new CXTPReportRecordItemText(_T("Color")));
	}

	static COLORREF GetValue(XTP_NM_REPORTRECORDITEM* pItemNotify)
	{
		return ((CPropertyRecordItemColor*)pItemNotify->pItem)->GetValue();
	}
};


#endif // !defined(AFX_REPORTRECORD_H__INCLUDED_)
