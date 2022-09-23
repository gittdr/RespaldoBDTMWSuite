SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollReferenceNumberView] AS

	--Order ref
	SELECT	ref.*, oh.ord_billto, oh.ord_startdate, oh.ord_hdrnumber as orderheader_ord_hdrnumber, ivh.ivh_billdate
	FROM	dbo.RowSecuredOrderheaderNoLockView oh 
			INNER JOIN dbo.ReferenceNumber as ref WITH(NOLOCK) ON	(	ref.ord_hdrnumber = oh.ord_hdrnumber
																		AND ref.ref_table = 'orderheader'
																	)
			LEFT OUTER JOIN invoiceheader ivh on oh.ord_hdrnumber = ivh.ord_hdrnumber
	UNION

	--freight detail
	SELECT	ref.*, oh.ord_billto, oh.ord_startdate, oh.ord_hdrnumber as orderheader_ord_hdrnumber, ivh.ivh_billdate
	FROM	dbo.RowSecuredOrderheaderNoLockView oh 
			INNER JOIN stops stp WITH (NOLOCK) ON	(	oh.ord_hdrnumber = stp.ord_hdrnumber
														AND stp.ord_hdrnumber <> 0
													)
			INNER JOIN freightdetail fgt WITH (NOLOCK) ON stp.stp_number = fgt.stp_number
			INNER JOIN referencenumber ref WITH (NOLOCK) ON (	fgt.fgt_number = ref.ref_tablekey
																AND ref.ref_table = 'freightdetail'
															)
			LEFT OUTER JOIN invoiceheader ivh on oh.ord_hdrnumber = ivh.ord_hdrnumber

	UNION
	
	--invoice
	SELECT	ref.*, oh.ord_billto, oh.ord_startdate, oh.ord_hdrnumber as orderheader_ord_hdrnumber, ivh.ivh_billdate
	FROM	dbo.InvoiceHeaderRowRestrictedView ivh 
			INNER JOIN dbo.ReferenceNumber as ref WITH(NOLOCK) on	(	ivh.ivh_hdrnumber = ref.ref_tablekey 
																		AND ref.ref_table = 'invoiceheader'
																	) 
			LEFT OUTER JOIN orderheader oh on ivh.ord_hdrnumber = oh.ord_hdrnumber

	UNION 
	
	--stops
	SELECT	ref.*, oh.ord_billto, oh.ord_startdate, oh.ord_hdrnumber as orderheader_ord_hdrnumber, ivh.ivh_billdate
	FROM	dbo.RowSecuredOrderheaderNoLockView oh 
			INNER JOIN stops stp WITH (NOLOCK) ON	(	oh.ord_hdrnumber = stp.ord_hdrnumber
														AND stp.ord_hdrnumber <> 0
													)
			INNER JOIN referencenumber ref WITH (NOLOCK) ON	(	stp.stp_number = ref.ref_tablekey
																AND ref.ref_table = 'stops'
															)
			LEFT OUTER JOIN invoiceheader ivh on oh.ord_hdrnumber = ivh.ord_hdrnumber
	UNION

	--Let any else go through not otherwise selected above
	SELECT	ref.*, null as ord_billto, null as ord_startdate, null as orderheader_ord_hdrnumber, null as ivh_billdate
	FROM	dbo.ReferenceNumber as ref WITH(NOLOCK) 
	WHERE	ref.ref_table NOT IN ('orderheader', 'freightdetail', 'invoiceheader', 'stops')
	
GO
GRANT DELETE ON  [dbo].[TMWScrollReferenceNumberView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollReferenceNumberView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollReferenceNumberView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollReferenceNumberView] TO [public]
GO
