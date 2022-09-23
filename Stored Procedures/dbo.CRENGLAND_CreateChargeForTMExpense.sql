SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[CRENGLAND_CreateChargeForTMExpense] (@pl_ordhdr int , @ps_paytype  varchar(8),@pdec_pydamount money,@o_msg varchar(100) output) 
as
/* Custom for CR England to create an invoice detial charge from a Total Mail macro

  SAMPLE CALL:
     declare @msg varchar(100)
     exec  dbo.CRENGLAND_CreateChargeForTMExpense 8303 , 'CRECUP',12.5,@msg output
     select @msg 

PTS59928 11/21/11 created DPETE
   Returns
     '' success
     'invalid order'  no orderheader record could be found for the ord_hdrnumber passed (or ord_billto is null)
     'invoice exists' an invoice exists for the order
     ''unable to create accessorial' one of the following
          the pay type does not exist in the paytype table
          the pay type has no charge type
          the pay type is retired
          the charge type for the pay type is retired
          the charge type on the pay type is UNK
     

*/
declare @billto varchar(8)
declare @msg varchar(100)
declare @chargetype varchar(8)
declare @ivdnumber int 

select @msg = ''

select @billto = ord_billto from orderheader where ord_hdrnumber = @pl_ordhdr
if @billto is null
 BEGIN
   SELECT @msg = 'Ivalid order'
   GOTO Exit_Point
 END
    
If exists (select 1 from invoiceheader where ord_hdrnumber = @pl_ordhdr)
  BEGIN
   SELECT @msg = 'invoice exists'
   GOTO Exit_Point
  END
 
Select @chargetype = p.cht_itemcode 
from paytype p join chargetype c on p.cht_itemcode = c.cht_itemcode 
where pyt_itemcode = @ps_paytype
and ISNULL(pyt_retired,'N') <> 'Y'
and ISNULL(cht_retired,'N') <> 'Y'

if @chargetype is null select @chargetype = 'UNK'

if @chargetype = 'UNK'
  BEGIN
   Select @msg = 'unable to create accessorial'
   GOTO Exit_Point
  END
   
EXEC @ivdnumber =  dbo.getsystemnumber_gateway 'INVDET', NULL, 1
   
INSERT INTO invoicedetail ( 
cht_itemcode
, ivd_description
, cmp_id
, ivd_quantity
, ivd_rate
, ivd_charge
, ivd_billto
, ivh_hdrnumber
, ivd_number
, ord_hdrnumber
, ivd_glnum
, ivd_type
, ivd_unit
, cur_code
, ivd_currencydate
, ivd_rateunit
, ivd_sequence
, ivd_invoicestatus
, cmd_code
, ivd_reftype
, ivd_sign
, cht_basisunit
, ivd_fromord
, cht_class
, cht_rollintolh
, ivd_charge_type
,cht_lh_min
,cht_lh_rev
,cht_lh_stl
,cht_lh_rpt
) 

Select cht_itemcode
,'UNKNOWN'
,'UNKNOWN'
,@pdec_pydamount --????????quantity per SR is the "amount of the pay detail"
,0.0
,0.0
,@billto
,0
,@ivdnumber
,@pl_ordhdr
,cht_glnum  
,'LI'
,cht_unit
,cht_currunit  
,GETDATE()
,cht_rateunit
,9999
,'HLD'
,'UNKNOWN'
,'UNK'
,1
,cht_basisunit
,'Y'
,cht_class
,cht_rollintolh
,0
,cht_lh_min
,cht_lh_rev
,cht_lh_stl
,cht_lh_rpt
from chargetype 
where cht_itemcode = @chargetype

   
select @msg =  'success'

EXIT_POINT:

 select @o_msg = @msg
GO
GRANT EXECUTE ON  [dbo].[CRENGLAND_CreateChargeForTMExpense] TO [public]
GO
