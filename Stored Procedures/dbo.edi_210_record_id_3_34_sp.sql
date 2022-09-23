SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edi_210_record_id_3_34_sp] 
	@invoice_number varchar( 12 ),
	@trpid varchar(20),
	@docid varchar(30)
 as
declare @ivh_hdrnumber integer
declare @emptystring varchar(30)
declare @varchar8 varchar(8)

select @emptystring=' ',@varchar8 = ' '


select @ivh_hdrnumber=ivh_hdrnumber from invoiceheader where ivh_invoicenumber=@invoice_number

-- retrieve most of the data into a temp table
SELECT 
vc_weight=RIGHT(convert( varchar( 12 ), ISNULL(ivd_wgt,0)),7),	-- weight
ivd_wgtunit = ISNULL(ivd_wgtunit,' '),					-- weight qualifier
ivd_description = LEFT(ISNULL(ivd_description,'  '),30),				-- commodity desc
vc_quantity=RIGHT(convert( varchar( 12 ),convert(int, ISNULL(ivd_quantity,0.00)*100)),9),	
ivd_quantity = ISNULL(ivd_quantity,0.00),                        -- need numeric version for final select
ivd_unit = ISNULL(ivd_unit,' '),				-- Quantity qualifier
vc_charge=RIGHT(convert( varchar( 12 ), convert(int,ISNULL(ivd_charge,0.00)*100)),9),
ivd_charge = ISNULL(ivd_charge,0.00),                                 	-- charges
vc_rate=RIGHT(convert( varchar( 12 ),convert(int, ISNULL(ivd_rate,0.00)*100)),9),  -- rate
ivd_rateunit= ISNULL(ivd_rateunit,'  '),					-- Rate qualifier
cur_code = ISNULL(cur_code,'US'),
cht_itemcode = ISNULL(d.cht_itemcode,' ') ,
cmd_code = ISNULL(cmd_code,'UNKNOWN'),					-- currency
cht_basisunit,
ivh_billto,
ivd_type,                                     -- bill to company
weight_qualifier=@emptystring,
quantity_qualifier=@emptystring,
charges_qualifier=@emptystring,
rate_qualifier=@emptystring,
freight_class=
  Case d.cht_itemcode
   When 'QST' Then 'QST'
   When 'GST' Then 'GST'
   When 'SO' Then 'SOC'
   ELSE '?'
  End,
billedas_quantity=@emptystring,
billedas_qualifier=@emptystring,
NMFC=@emptystring,
usercommodity=@varchar8,
primarycharge=@emptystring
into #210_inv_temp
FROM invoicedetail d, invoiceheader h
WHERE d.ivh_hdrnumber=@ivh_hdrnumber
and d.Ivh_hdrnumber = h.ivh_hdrnumber

-- Set the primary charge and basisunit , reset freightclass if based on primary flag 
update #210_inv_temp 
set primarycharge = c.cht_primary,
   cht_basisunit = c.cht_basisunit,
   Freight_class = 
     Case c.cht_primary + freight_class
       When 'Y?' Then '002'
       When 'N?' Then '003'
       Else freight_class 
     End,
   ivd_description = 
     Case 
        When c.cht_primary = 'N' then LEFT(UPPER(ISNULL(c.cht_description,' ')),30)
        When #210_inv_temp.ivd_description = 'UNKNOWN' then LEFT(UPPER(ISNULL(c.cht_description,' ')),30)
        Else #210_inv_temp.ivd_description 
     end
from chargetype c 
where #210_inv_temp.cht_itemcode = c.cht_itemcode


-- Get edi code for quantity qualifier through generalinfo and labelfile
update #210_inv_temp set quantity_qualifier= CONVERT(char(2),LEFT(ISNULL(edicode,' '),2))
from labelfile ,generalinfo 
where labeldefinition=gi_string1 and abbr=ivd_unit 
and gi_name='UnitBasis'+#210_inv_temp.cht_basisunit

-- Get edi code for rate qualifier through labelfile
update #210_inv_temp set rate_qualifier= CONVERT(char(2),LEFT(ISNULL(edicode,' '),2))
from #210_inv_temp,labelfile
where labeldefinition='RateBy' and abbr=ivd_rateunit

-- Get edi code for weight qualifier through labelfile
--update #210_inv_temp set weight_qualifier= convert(char(3),LEFT(ISNULL(edicode,' '),3))
update #210_inv_temp set weight_qualifier= convert(char(2),LEFT(ISNULL(edicode,' '),2))
from #210_inv_temp,labelfile
where labeldefinition='WeightUnits' and abbr=ivd_wgtunit

-- Get the EDI equivalent for the commodity and place in the temp
update #210_inv_temp set 
--	ivd_description = e.edi_cmd_code,  DPETE 6/14/99 pts5861
	usercommodity = LEFT(e.edi_cmd_code,8)
from edicommodity e
where #210_inv_temp.ivh_billto = e.cmp_id
and   #210_inv_temp.cmd_code   = e.cmd_code 

-- Get the EDI equivalent for the accessorial cht_itemcode and place in the temp
update #210_inv_temp set 
--	ivd_description = e.edi_accessorial_code,   DPETE 6/14/99 pts5861
	usercommodity = 
	 Case #210_inv_temp.cht_itemcode
            When 'ORDFLT' then 'FLT'
            WHEN 'MIN' then 'MIN'
            Else LEFT(ISNULL(e.edi_accessorial_code,' '),8)
	 END 
from ediaccessorial e
where   #210_inv_temp.ivh_billto = e.cmp_id
and   #210_inv_temp.cht_itemcode   = e.cht_itemcode


-- for Minimum charges and quantities set the description to MINIMUM
-- (PTS 6013 7/12/99) and the usercommodity code to MIN
update #210_inv_temp
set ivd_description = 'MINIMUM',
    usercommodity = 'MIN'
where  cht_itemcode = 'MIN'


-- Pad to the right size and handle negative numbers 
update #210_inv_temp set
vc_weight=
  Case Left(vc_weight,1)
    WHEN '-' then '-' + replicate('0',7 - datalength(vc_weight)) + REPLACE(vc_weight,'-','')
    ELSE  replicate('0',7 - datalength(vc_weight)) + vc_weight
  END,
vc_quantity=
   Case LEFT(vc_quantity,1)
      WHEN '-' then '-' + replicate('0',9 - datalength(vc_quantity))+ REPLACE(vc_quantity,'-','')
      ELSE replicate('0',9 - datalength(vc_quantity))+ vc_quantity
   END ,
vc_charge=
   Case LEFT(vc_charge,1)
      WHEN '-' then '-' + replicate('0',9 - datalength(vc_charge)) + REPLACE(vc_charge,'-','')
      ELSE replicate('0',9 - datalength(vc_charge))+ vc_charge
   END ,
charges_qualifier=ISNULL(charges_qualifier,''),    -- not yet used
billedas_qualifier=ISNULL(billedas_qualifier,''),
vc_rate=
  Case Left(vc_rate,1)
    WHEN '-' then '-' + replicate('0',9 - datalength(vc_rate)) + REPLACE(vc_rate,'-','')
    ELSE  replicate('0',9 - datalength(vc_rate)) + vc_rate
  End,
rate_qualifier=ISNULL(rate_qualifier,''),
NMFC=ISNULL(NMFC,''),
Freight_class=ISNULL(freight_class,''),
Usercommodity=ISNULL(usercommodity,''),
ivd_rateunit=isnull(ivd_rateunit,''),
cur_code=substring(cur_code,1,1)


-- then insert results into edi_210
INSERT edi_210
SELECT 
data_col = '3' +			-- Record ID
'34' +					-- Record Version
vc_weight +				-- weight 
weight_qualifier +			-- weight qualifier
	replicate(' ',2-datalength(weight_qualifier)) +
ivd_description +			-- commodity desc
	replicate(' ',30-datalength(ivd_description)) +
vc_quantity +				-- Quantity
quantity_qualifier +			-- Quantity qualifier
	replicate(' ',3-datalength(quantity_qualifier)) +
vc_charge +				-- charges
charges_qualifier +			-- charges qualifier
	replicate(' ',3-datalength(charges_qualifier)) +
LEFT(vc_quantity,7) +					-- billed as quantity
quantity_qualifier + -- special for Jodi billedas_qualifier +					-- billed as quantity qualifier
	replicate(' ',2-datalength(quantity_qualifier)) +
vc_rate +				-- rate
rate_qualifier +			-- rate qualifier
	replicate(' ',2-datalength(rate_qualifier)) +
NMFC +					-- NMFC
	replicate(' ',7-datalength(NMFC)) +
freight_class +				-- freight class
	replicate(' ',7-datalength(freight_class)) +
usercommodity +					-- user commodity
	replicate(' ',8-datalength(usercommodity)) +
cur_code ,
trp_id=@trpid,
doc_id = @docid

FROM #210_inv_temp
Where ivd_quantity <> 0 or primarycharge = 'N'
--Warning do not change the above where without checking on affect on Florida 
--Rock.  They need to map line items with billing quantities and zero charge


GO
GRANT EXECUTE ON  [dbo].[edi_210_record_id_3_34_sp] TO [public]
GO
