SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edi_210_record_id_3_sp] 
	@invoice_number varchar( 12 ),
	@trpid varchar(20)
 as
declare @ivh_hdrnumber integer
declare @emptystring varchar(30)
declare @varchar8 varchar(8)

select @emptystring='',@varchar8 = ''


select @ivh_hdrnumber=ivh_hdrnumber from invoiceheader where ivh_invoicenumber=@invoice_number

-- retrieve most of the data into a temp table
SELECT 
vc_weight=convert( varchar( 12 ), ivd_wgt),	-- weight
ivd_wgtunit,					-- weight qualifier
ivd_description,				-- commodity desc
vc_quantity=convert( varchar( 12 ),convert(float, ivd_quantity)),	-- Quantity
ivd_quantity,                        -- need numeric version for final select
ivd_unit,					-- Quantity qualifier
vc_charge=convert( varchar( 12 ), ivd_charge),
ivd_charge,                                 	-- charges
vc_rate=convert( varchar( 12 ),convert(float, ivd_rate)),  -- rate

ivd_rateunit,					-- Rate qualifier
cur_code,
d.cht_itemcode,
cmd_code,					-- currency
cht_basisunit,
ivh_billto,
ivd_type,                                     -- bill to company
weight_qualifier=@emptystring,
quantity_qualifier=@emptystring,
charges_qualifier=@emptystring,
rate_qualifier=@emptystring,
freight_class=@emptystring,
billedas_quantity=@emptystring,
billedas_qualifier=@emptystring,
NMFC=@emptystring,
usercommodity=@varchar8,
primarycharge=@emptystring
into #210_inv_temp
FROM invoicedetail d, invoiceheader h
WHERE d.ivh_hdrnumber=@ivh_hdrnumber
and d.Ivh_hdrnumber = h.ivh_hdrnumber

-- Set the primary charge flag 
update #210_inv_temp 
set #210_inv_temp.primarycharge = c.cht_primary
from chargetype c 
where #210_inv_temp.cht_itemcode = c.cht_itemcode

-- Set the  cht_basisunit ONLY if null (sometimes the code needs to override)
update #210_inv_temp 
set #210_inv_temp.cht_basisunit = c.cht_basisunit
from chargetype c 
where #210_inv_temp.cht_itemcode = c.cht_itemcode
AND   #210_inv_temp.cht_basisunit IS NULL

-- set freight class for linehaul charges
update #210_inv_temp
set freight_class = '002'
where primarycharge = 'Y'
-- set freight slass for accessorials
update #210_inv_temp
set freight_class = '003'
where primarycharge <> 'Y'
-- reset freight class of accessorial for stop off charges
update #210_inv_temp
set freight_class = 'SOC'
where primarycharge <> 'Y'
and cht_itemcode = 'SO'
-- Set GST freight class

update #210_inv_temp
set freight_class = 'GST'
where  cht_itemcode = 'GST'
-- Set GST freight class
update #210_inv_temp
set freight_class = 'QST'
where  cht_itemcode = 'QST'


-- Get edi code for quantity qualifier through generalinfo and labelfile
update #210_inv_temp set quantity_qualifier= convert(char(3),edicode)
from labelfile ,generalinfo 
where labeldefinition=gi_string1 and abbr=ivd_unit and gi_name='UnitBasis'+#210_inv_temp.cht_basisunit

-- Get edi code for rate qualifier through labelfile
update #210_inv_temp set rate_qualifier= convert(char(2),edicode)
from #210_inv_temp,labelfile
where labeldefinition='RateBy' and abbr=ivd_rateunit

-- Get edi code for weight qualifier through labelfile
--update #210_inv_temp set weight_qualifier= convert(char(3),edicode)
update #210_inv_temp set weight_qualifier= convert(char(2),edicode)
from #210_inv_temp,labelfile
where labeldefinition='WeightUnits' and abbr=ivd_wgtunit

-- Get the EDI equivalent for the commodity and place in the temp
update #210_inv_temp set 
--	ivd_description = e.edi_cmd_code,  DPETE 6/14/99 pts5861
	usercommodity = e.edi_cmd_code
from edicommodity e
where #210_inv_temp.ivh_billto = e.cmp_id
and   #210_inv_temp.cmd_code   = e.cmd_code 

-- Get the EDI equivalent for the accessorial cht_itemcode and place in the temp
update #210_inv_temp set 
--	ivd_description = e.edi_accessorial_code,   DPETE 6/14/99 pts5861
	usercommodity = e.edi_accessorial_code
from ediaccessorial e
where   #210_inv_temp.ivh_billto = e.cmp_id
and   #210_inv_temp.cht_itemcode   = e.cht_itemcode

--dpete pts5861 User request description by PS description, not user EDI equivalent
-- Get the descripton for accessorialcharges 
update #210_inv_temp 
set #210_inv_temp.ivd_Description = UPPER(c.cht_description)
from chargetype c 
where #210_inv_temp.cht_itemcode = c.cht_itemcode
and  c.cht_primary = 'N'

-- pts6013 7/12/99 this should apply only to customers using the
-- ORDFLT charge type in rating orders (places FLAT CHARGE in description)
update #210_inv_temp
set usercommodity = 'FLT'
where  cht_itemcode = 'ORDFLT'

-- for Minimum charges and quantities set the description to MINIMUM
-- (PTS 6013 7/12/99) and the usercommodity code to MIN
update #210_inv_temp
set ivd_description = 'MINIMUM',
    usercommodity = 'MIN'
where  cht_itemcode = 'MIN'

update #210_inv_temp set
vc_weight = '0' where vc_weight = ' '

update #210_inv_temp set
vc_weight=isnull(vc_weight,'0'),
weight_qualifier = ISNULL(weight_qualifier,''),
ivd_wgtunit=isnull(ivd_wgtunit,' '),
ivd_description=isnull(ivd_description,' '),
vc_quantity=ISNULL(vc_quantity,'0'),
quantity_qualifier=ISNULL(quantity_qualifier,''),
vc_charge=ISNULL(vc_charge,'0.00'),
charges_qualifier=ISNULL(charges_qualifier,''),
billedas_qualifier=ISNULL(billedas_qualifier,''),
ivd_unit=isnull(ivd_unit,''),
vc_rate=isnull(vc_rate,'0000.00'),
rate_qualifier=ISNULL(rate_qualifier,''),
NMFC=ISNULL(NMFC,''),
Freight_class=ISNULL(freight_class,''),
Usercommodity=ISNULL(usercommodity,''),
ivd_rateunit=isnull(ivd_rateunit,''),
cur_code=isnull(substring(cur_code,1,1),'')


-- then insert results into edi_210
INSERT edi_210
SELECT 
data_col = '3' +			-- Record ID
'10' +					-- Record Version
	replicate('0',7-datalength(vc_weight)) +
vc_weight +				-- weight 
weight_qualifier +			-- weight qualifier
	replicate(' ',2-datalength(weight_qualifier)) +
ivd_description +			-- commodity desc
	replicate(' ',30-datalength(ivd_description)) +
	replicate('0',7-datalength(vc_quantity)) +
vc_quantity +				-- Quantity
quantity_qualifier +			-- Quantity qualifier
	replicate(' ',3-datalength(quantity_qualifier)) +
	replicate('0',7-datalength(vc_charge)) +
vc_charge +				-- charges
charges_qualifier +			-- charges qualifier
	replicate(' ',3-datalength(charges_qualifier)) +
	replicate('0',7-datalength(vc_quantity)) +
vc_quantity +					-- billed as quantity
billedas_qualifier +					-- billed as quantity qualifier
	replicate(' ',2-datalength(billedas_qualifier)) +
	replicate('0',7-datalength(vc_rate)) +
vc_rate +				-- rate
rate_qualifier +			-- rate qualifier
	replicate(' ',2-datalength(rate_qualifier)) +
NMFC +					-- NMFC
	replicate(' ',7-datalength(NMFC)) +
freight_class +				-- freight class
	replicate(' ',7-datalength(freight_class)) +
usercommodity +					-- user commodity
	replicate(' ',8-datalength(usercommodity)) +
cur_code +				-- currency
	replicate(' ',1-datalength(cur_code)),
trp_id=@trpid


FROM #210_inv_temp
Where ivd_quantity <> 0 or primarycharge = 'N'
--Warning do not change the above where without checking on affect on Florida 
--Rock.  They need to map line items with billing quantities and zero charge














GO
GRANT EXECUTE ON  [dbo].[edi_210_record_id_3_sp] TO [public]
GO
