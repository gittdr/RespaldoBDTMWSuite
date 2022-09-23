SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/*******************************************************************************************
 NAME:		d_masterbill105_sp
 TYPE:		Stored procedure
 DATABASE:	TMW
 PURPOSE:       Called as part of Master Billing print process

 DEPENDANCIES:

 PROCESS:
 RETURNS:
 ---------------------------------------------------------------------------

				CONFIDENTIAL AND PROPRIETARY
				COPYRIGHT 1998 MBI DATA SERVICES LTD
				ALL RIGHTS RESERVED

 ---------------------------------------------------------------------------
REVISION LOG
DATE            WHO             REASON
----            ---             ------
Feb 16,2006     L.Appleby       Initial creation - removed SQL code from powerbuilder 
                                datawindow d_queue_summary_invoice_trim and move to stored 
                                procedure. In addition, added sql code to prevent transferred
                                invoices from being picked up and reset to PRN (caused several
                                thousand invoices to be reset for a branch).
Nov 21,2007     R.Hing          Imported for TMW
Dec 3, 2007     kdecelle        Made all joins ANSI compliant

EXECUTION and INPUTS:
exec dbo.d_masterbill105_sp @status    = "RTP",
                          @billto    = "HUSCAL",
                          @shipper   = "UNKNOWN",
                          @consignee = "UNKNOWN",
                          @shipdate1 = "01-01-1950",
                          @shipdate2 = "12-31-2049",
                          @deldate1  = "01-01-1950",
                          @deldate2  = "12-31-2049",
                          @rev1      = "UNK",
                          @rev2      = "UNK",
                          @rev3      = "UNK",
                          @rev4      = "UNK",
                          @orderedby   = "UNKNOWN"
*******************************************************************************************/

create procedure [dbo].[d_masterbill105_sp]
        @billto     varchar(50),
        @status     varchar(50),
        @shipper    varchar(50),
        @consignee  varchar(50),
        @shipdate1  datetime,
        @shipdate2  datetime,
        @deldate1   datetime,
        @deldate2   datetime,
        @rev1       varchar(50),
        @rev2       varchar(50),
        @rev3       varchar(50),
        @rev4       varchar(50),
        @orderedby  varchar(50)

as

SELECT cmp_billto.cmp_id,
    cmp_billto.cmp_name,
    cmp_billto.cmp_address1,
    cmp_billto.cmp_address2,
    city_billto.cty_nmstct,
    cmp_billto.cmp_zip,
    ivh.ivh_billdate,
    ivh.ivh_totalcharge,
    ordh.ord_number,
    ivh.ivh_ref_number,
    ivh.ivh_invoicenumber,
    ivh.ivh_hdrnumber,
    ivh.ivh_totalmiles,
    ordh.ord_stopcount,
    ordh.ord_bookdate
FROM invoiceheader ivh
inner join company cmp_billto on ivh.ivh_billto = cmp_billto.cmp_id
inner join city city_billto on cmp_billto.cmp_city = city_billto.cty_code
inner join orderheader ordh on ivh.ord_hdrnumber = ordh.ord_hdrnumber
WHERE 
    (ivh.ivh_billto = @billto)
    and (ivh.ivh_invoicestatus <> 'XFR')            --change from original dw to prevent transferred invoices being picked up
    and (@status in ('ALL', ivh.ivh_mbstatus))
    and (@shipper in ('UNKNOWN', ivh.ivh_shipper))
    and (@consignee in ('UNKNOWN', ivh.ivh_consignee))
    and (@orderedby in ('UNKNOWN', ivh.ivh_order_by))
    and (ivh.ivh_shipdate between @shipdate1 and @shipdate2)
    and (ivh.ivh_deliverydate between @deldate1 and @deldate2)
    and (@rev1 in ('UNK', ivh.ivh_revtype1))
    and (@rev2 in ('UNK', ivh.ivh_revtype2))
    and (@rev3 in ('UNK', ivh.ivh_revtype3))
    and (@rev4 in ('UNK', ivh.ivh_revtype4))

GO
GRANT EXECUTE ON  [dbo].[d_masterbill105_sp] TO [public]
GO
