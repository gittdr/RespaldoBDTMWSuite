SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
  Finds the next order with an ord_hdrnumber larger than
  the one passed which should be auto rated
     Criterea   - not already rated (ord_charge = 0)
                  ord_status labelfine code in between 200 (AVL) and 900 (HSt) 
                  no invoice exist for the order	
		  invoicestatus = 'PND' 
     When found, make sure there is no invoice (Status codes have been
     known to go bad) by looking for one.
  Returns information from the orderheader table needed for auto rating.
   
*/
  



CREATE PROC [dbo].[d_ordhdrdataforrating_sp] (@ordhdrnumber int)
AS

--DECLARE @nextord int 
DECLARE @Invoicecount int

-- Build local file for acceptable status codes
SELECT abbr
INTO #lbl
FROM labelfile 
WHERE labeldefinition = 'DispStatus'
AND code between 201 and 899

--SELECT @nextord = @ordhdrnumber  -- initialize

-- Look for the next candidate order
WHILE 1  = 1
  BEGIN
    SELECT  @ordhdrnumber = MIN(o.Ord_hdrnumber)
    FROM   orderheader o, #lbl l
    where o.ord_hdrnumber > @ordhdrnumber
    AND   o.ord_charge = 0.00
    and   o.ord_invoicestatus = 'PND'
    and   o.ord_status = l.abbr
       

    If @ordhdrnumber IS NULL BREAK

    -- verify there is no invoice (cannot trust invoicestatus)
    SELECT @invoicecount = COUNT(*)
    FROM   invoiceheader
    WHERE  ord_hdrnumber = @ordhdrnumber

    If @invoicecount = 0 
	 BREAK

    CONTINUE
  END

-- Retrieve the order information

  SELECT  orderheader.cht_itemcode,
	  orderheader.cmd_code,

	  oc.cty_nmstct from_cty_nmstct,
	  orderheader.ord_accessorial_chrg,
	  orderheader.ord_billto,
 	  orderheader.ord_charge,
	  orderheader.ord_currency,
	  orderheader.ord_currencydate,
	  orderheader.ord_description,
	  orderheader.ord_destpoint,
	  orderheader.ord_destcity,
	  orderheader.ord_hdrnumber,
	  orderheader.ord_height,
	  orderheader.ord_heightunit,
	  orderheader.ord_length,
	  orderheader.ord_lengthunit,
	  orderheader.ord_number,
	  orderheader.ord_odmetermiles,
	  orderheader.ord_originpoint,
	  orderheader.ord_origincity,
	  orderheader.ord_quantity,
	  orderheader.ord_quantity_type,
	  orderheader.ord_rate, 
	  ord_rateby,
	  orderheader.ord_rateunit,
	  orderheader.ord_remark,
	  orderheader.ord_revtype1,
	  orderheader.ord_revtype2,
	  orderheader.ord_revtype3,
	  orderheader.ord_revtype4,
	  orderheader.ord_subcompany,
	  orderheader.ord_totalcharge,
	  orderheader.ord_totalcountunits,
	  orderheader.ord_totalmiles,
	  orderheader.ord_totalpieces,

	  orderheader.ord_totalvolume,
	  orderheader.ord_totalvolumeunits,
	  orderheader.ord_totalweight,
	  orderheader.ord_totalweightunits,
	  orderheader.ord_unit,
	  orderheader.ord_width,
	  orderheader.ord_widthunit,
	  orderheader.ord_company,

	  orderheader.trl_type1,
	  orderheader.tar_tariffitem,
	  orderheader.tar_tarriffnumber,
	  orderheader.tar_number,
	  orderheader.ord_bookdate ,
	  dc.cty_nmstct to_cty_nmstct 
	FROM orderheader, city dc, city oc
	WHERE orderheader.ord_hdrnumber = @ordhdrnumber
        AND  oc.cty_code = orderheader.ord_origincity
	AND  dc.cty_code = orderheader.ord_destcity

GO
GRANT EXECUTE ON  [dbo].[d_ordhdrdataforrating_sp] TO [public]
GO
