SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_flarock_payxface_det]
AS
/**
 * 
 * REVISION HISTORY:
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @vchar12 varchar(12), @money money, @int int, @vchar8 varchar(8)


SELECT @money = 0.00, @int = 0, @vchar8 = '        '
SELECT @vchar12 = '            '
 
CREATE TABLE #payview_det (	pyd_number int,

			pyd_amount money,
			revtype1 int NULL,
			lgh_tractor varchar(8) NULL,
			ord_number varchar(12) NULL,
			pyt_basis varchar(6) NULL,
			pyd_status varchar(6) NULL,
			mpp_ssn varchar(9) NULL,
			psd_date datetime NULL,
			ord_hdrnumber int NULL,
			lgh_number int NULL,
			ivh_invoice_number varchar(12) NULL)

INSERT INTO #payview_det
SELECT	pd.pyd_number,
	IsNull(pd.pyd_amount,0),
	0,
	@vchar8,
	@vchar12,
	IsNull(pt.pyt_basis, 'ANC'),
	IsNull(pd.pyd_status, ''),
	IsNull(mp.mpp_ssn, ''),
	ps.psd_date,
	IsNull(pd.ord_hdrnumber, 0),
	IsNull(pd.lgh_number, 0),
	@vchar12
FROM  paydetail pd  LEFT OUTER JOIN  manpowerprofile mp  ON  pd.asgn_id  = mp.mpp_id   
			LEFT OUTER JOIN  payschedulesdetail ps  ON  pd.psd_id  = ps.psd_id   
			LEFT OUTER JOIN  paytype pt  ON  pd.pyt_itemcode  = pt.pyt_itemcode  
WHERE	 (pd.pyd_status  = 'REL')
 AND	(pd.asgn_type  = 'DRV')

-- Update the order header number from the order table
UPDATE #payview_det
set ord_number =       (SELECT Min(IsNull(ord_number, ''))
			FROM orderheader oh
			WHERE 	( #payview_det.ord_hdrnumber = oh.ord_hdrnumber )
			)

-- Update the terminal through the labelfile table
UPDATE #payview_det
set revtype1 =         (SELECT Min(IsNull(lf.code, 0))
			FROM labelfile lf, orderheader oh
			WHERE 	(#payview_det.ord_hdrnumber = oh.ord_hdrnumber )
			AND	( oh.ord_revtype1 = lf.abbr )
			AND	( lf.labeldefinition = 'RevType1' ) 
			)

-- Update the tractor through the legheader
UPDATE #payview_det
set lgh_tractor =      (SELECT Min(IsNull(lh.lgh_tractor, ''))
			FROM legheader lh
			WHERE ( #payview_det.lgh_number = lh.lgh_number )
			)


-- Update the invoicenumber
UPDATE #payview_det
set ivh_invoice_number = 	(SELECT MIN(ivh_invoicenumber)
				FROM invoiceheader
				WHERE ( #payview_det.ord_hdrnumber = invoiceheader.ord_hdrnumber )
				)

SELECT * from #payview_det
GO
GRANT EXECUTE ON  [dbo].[d_flarock_payxface_det] TO [public]
GO
