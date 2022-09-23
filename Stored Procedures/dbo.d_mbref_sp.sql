SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE PROC [dbo].[d_mbref_sp]       (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @revtype2 varchar(6),@mbstatus varchar(6),
	                       @shipstart datetime,@shipend datetime,@billdate datetime, 
                               @shipper varchar(8), @consignee varchar(8),
                               @copy int,@ivh_invoicenumber varchar(12))
AS

DECLARE @int0  int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'

CREATE TABLE #masterbill_ref ( ref_number varchar(30),
				ref_type   varchar(20),
				ord_hdrnumber int)

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN
    insert into #masterbill_ref
    SELECT 	ref_number,
		isnull(lab.name, ref.ref_type) ref_type,
		--lab.name ref_type,
		invoiceheader.ord_hdrnumber
    FROM 	invoiceheader, 
		referencenumber ref,
		labelfile lab
    WHERE	( invoiceheader.ivh_mbnumber = @mbnumber )and
		ref.ref_table = 'orderheader' and
		ref_tablekey = invoiceheader.ord_hdrnumber and
		(ref.ref_number is not null and ref.ref_number <> '')
		AND  lab.labeldefinition = 'referencenumbers' 
		AND  lab.abbr = ref.ref_type

  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
      insert into #masterbill_ref
    	SELECT 	ref_number,
		isnull(lab.name, ref.ref_type) ref_type,
		--lab.name ref_type,
		invoiceheader.ord_hdrnumber
	FROM 	invoiceheader, 
		referencenumber ref,
		labelfile lab
	WHERE 	( invoiceheader.ivh_billto = @billto )  
		AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
		AND     (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK')) 
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		AND (@ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master'))
		AND  ref.ref_table = 'orderheader' 
		AND  ref_tablekey = invoiceheader.ord_hdrnumber 
		AND  (ref.ref_number is not null and ref.ref_number <> '')
		AND  lab.labeldefinition = 'referencenumbers' 
		AND  lab.abbr = ref.ref_type

  END

  select       ref_number,ref_type, min(ord_hdrnumber) ord_hdrnumber
  into         #resultset
  from         #masterbill_ref
  group by     ref_number,ref_type
  order by     ord_hdrnumber
  
  select top 10 *
  from   #resultset
GO
GRANT EXECUTE ON  [dbo].[d_mbref_sp] TO [public]
GO
