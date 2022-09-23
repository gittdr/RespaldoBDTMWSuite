SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetAssetInfoForInvoice]      
 @p_ordhdrnumber int,
 -- BEGIN PTS 60816 NLOKE
 @p_driver1 varchar(8),
 @p_driver2 varchar(8),
 @p_tractor varchar(8),
 @p_trailer1 varchar(15),
 @p_trailer2 varchar(15),
 @p_carrier varchar(8)
 -- END PTS 60816
   
AS 
/*   Proc to get the appropriate assets for an invoice based on GI settings

*****  SEE ALSO PROC GetAssetsFOrInvoice when making changes, does the same thing with more arguments ****

  REVISION HISTORY
  
  12/31/09 PTS48966 DPETE developed for splitting rating out of nvo_invoicing
      retrieves appropriate assets (GI otpions) and asset type information used for rating
  6/15/11 DPETE 57395 performance fix from Mindy
  1/17/12 NLOKE 60816 Added argument for assets driver1, driver2, tractor, trailer1, trailer2, carrier
  */
  
Declare @v_billto varchar(8), @v_GI_InvoiceAssets varchar(30), @v_invoiceby varchar(6),@v_mov int,@v_consignee varchar(8)
Declare @v_stpnumber int

Declare @stops table (stp_number int null)
declare @legmiles table (lgh_number int null,sumdist decimal(9,1) null,minstop int null )

-- BEGIN PTS 60816 NLOKE
Declare @assets table (ord_hdrnumber int, driver1 varchar(8), driver2 varchar(8),tractor varchar(8), trailer1 varchar(15), trailer2 varchar (15), carrier varchar(8))
Select @p_driver1= ISNULL(@p_driver1, 'UNKNOWN'),
		@p_driver2= ISNULL(@p_driver2, 'UNKNOWN'),
		@p_tractor= ISNULL (@p_tractor, 'UNKNOWN'),
		@p_trailer1= ISNULL (@p_trailer1, 'UNKNOWN'),
		@p_trailer2= ISNULL (@p_trailer2, 'UNKNOWN'),
		@p_carrier= ISNULL (@p_carrier, 'UNKNOWN')
-- END PTS 60816
		
Insert into @assets
	Select @p_ordhdrnumber, @p_driver1, @p_driver2, @p_tractor, @p_trailer1, @p_trailer2, @p_carrier

  
If exists (select 1 from invoiceheader where ord_hdrnumber = @p_ordhdrnumber) and @p_ordhdrnumber > 0 
    select @v_billto = ivh_billto,@v_invoiceby = isnull(ivh_invoiceby,'ORD'), @v_mov = mov_number, @v_consignee = ivh_destpoint
    from invoiceheader
    where ord_hdrnumber = @p_ordhdrnumber
    and ivh_hdrnumber = (select min ( ivh_hdrnumber) from invoiceheader where ord_hdrnumber = @p_ordhdrnumber )
else
    select @v_billto = ord_billto,@v_invoiceby = isnull(cmp_invoiceby,'ORD'), @v_mov = mov_number,@v_consignee = ord_consignee
    from orderheader join company on ord_billto = cmp_id
    where ord_hdrnumber = @p_ordhdrnumber
    
Select @v_GI_InvoiceAssets  = upper(gi_string1) from generalinfo where gi_name = 'InvoiceAssets'

Select @v_GI_InvoiceAssets  =  isnull(@v_GI_InvoiceAssets,'DELIVERY')


If @v_billto  is null RETURN  -- invalid order

/* BEGIN PTS 60816 NLOKE - Commented out section below
-- Handle special "invoiceby" options when selecting assets 
If   @v_invoiceby = 'MOV'
   Insert into @stops
   Select stp_number
   from orderheader
   join stops on orderheader.ord_hdrnumber = stops.ord_hdrnumber
   where orderheader.mov_number = @v_mov
   and ord_billto = @v_billto
if  @v_invoiceby = 'CON'
   Insert into @stops
   Select stp_number
   from orderheader
   join stops on orderheader.ord_hdrnumber = stops.ord_hdrnumber
   where orderheader.mov_number = @v_mov
   and ord_billto = @v_billto
   and ord_consignee = @v_consignee
If @v_invoiceby <> 'MOV' and @v_invoiceby <> 'CON'
   Insert into @stops
   Select stp_number
   from stops 
   where ord_hdrnumber = @p_ordhdrnumber
   and ord_hdrnumber > 0
       

-- GI setting dicatates which leg to get the assets from 

	  If @v_GI_InvoiceAssets = 'DELIVERY' 
	    BEGIN  -- get assets for delivery leg
	
	      select @v_stpnumber =  (select top 1 stops.stp_number
          from @stops st
          join stops on st.stp_number = stops.stp_number
          where stops.stp_type = 'DRP'
          order by stops.stp_sequence ,stops.stp_arrivaldate desc)
   
	      select @p_ordhdrnumber ord_hdrnumber,
	       evt_driver1,
	       evt_driver2,
	       evt_tractor,
	       evt_trailer1,
	       evt_trailer2,
	       evt_carrier,
	       d1.mpp_type1,
	       d1.mpp_type2,
	       d1.mpp_type3,
	       d1.mpp_type4,
	       tc.trc_type1,
	       tc.trc_type2,
	       tc.trc_type3,
	       tc.trc_type4,
	       tl1.trl_type1,
	       tl1.trl_type2,
	       tl1.trl_type3,
	       tl1.trl_type4,
	       car_type1,
	       car_type2,
	       car_type3,
	       car_type4,
	       car_board
	       from event
	       join manpowerprofile d1 on evt_driver1 = mpp_id
	       join tractorprofile tc on evt_tractor = trc_number
	       join trailerprofile tl1 on evt_trailer1 = trl_id
	       join carrier on evt_carrier = car_id
	       where event.stp_number = @v_stpnumber
	       and evt_sequence = 1
	           
	     END   -- get assets for delivery leg
	     
	   If @v_GI_InvoiceAssets = 'MOSTMILES' 
	     BEGIN  -- get assets for leg with most miles
	       insert into @legmiles (lgh_number,sumdist,minstop)
	       select lgh_number,sum(isnull(stp_lgh_mileage,0)),min(stops.stp_number)
	       from @stops st
         join stops on st.stp_number = stops.stp_number
	       group by lgh_number
	       order by sum(isnull(stp_ord_mileage,0)) desc
	                      
	       select @v_stpnumber = (select top 1 minstop 
	       from @legmiles)
	                           
	       select @p_ordhdrnumber ord_hdrnumber,
	       evt_driver1,
	       evt_driver2,
	       evt_tractor,
	       evt_trailer1,
	       evt_trailer2,
	       evt_carrier,
	       d1.mpp_type1,
	       d1.mpp_type2,
	       d1.mpp_type3,
	       d1.mpp_type4,
	       tc.trc_type1,
	       tc.trc_type2,
	       tc.trc_type3,
	       tc.trc_type4,
	       tl1.trl_type1,
	       tl1.trl_type2,
	       tl1.trl_type3,
	       tl1.trl_type4,
	       car_type1,
	       car_type2,
	       car_type3,
	       car_type4,
	       car_board
	       from event
	       join manpowerprofile d1 on evt_driver1 = mpp_id
	       join tractorprofile tc on evt_tractor = trc_number
	       join trailerprofile tl1 on evt_trailer1 = trl_id
	       join carrier on evt_carrier = car_id
	       where event.stp_number = @v_stpnumber
	       and evt_sequence = 1
	           
	     END   -- get assets for most miles leg
	         
	   -- **** DEFAULT - MAKE LAST *****   default is pickup leg
	   If @v_GI_InvoiceAssets <> 'DELIVERY' and @v_GI_InvoiceAssets <> 'MOSTMILES'
	     BEGIN  -- get assets for pickup leg
	       select @v_stpnumber =  (select top 1 stops.stp_number
             from @stops st
             join stops on st.stp_number = stops.stp_number 
             where stp_type = 'PUP'
             order by stp_mfh_sequence)
                 
	           select @p_ordhdrnumber ord_hdrnumber,
	       evt_driver1,
	       evt_driver2,
	       evt_tractor,
	       evt_trailer1,
	       evt_trailer2,
	       evt_carrier,
	       d1.mpp_type1,
	       d1.mpp_type2,
	       d1.mpp_type3,
	       d1.mpp_type4,
	       tc.trc_type1,
	       tc.trc_type2,
	       tc.trc_type3,
	       tc.trc_type4,
	       tl1.trl_type1,
	       tl1.trl_type2,
	       tl1.trl_type3,
	       tl1.trl_type4,
	       car_type1,
	       car_type2,
	       car_type3,
	       car_type4,
	       car_board
	       from event
	       join manpowerprofile d1 on evt_driver1 = mpp_id
	       join tractorprofile tc on evt_tractor = trc_number
	       join trailerprofile tl1 on evt_trailer1 = trl_id
	       join carrier on evt_carrier = car_id
	       where event.stp_number = @v_stpnumber
	       and evt_sequence = 1
	           
	     END   -- get assets for pickup leg
-- End commenting out for PTS 60816
*/

-- BEGIN PTS 60816 NLOKE
select @p_ordhdrnumber ord_hdrnumber,
       @p_driver1 evt_driver1,
       @p_driver2 evt_driver2,
       @p_tractor evt_tractor,
       @p_trailer1 evt_trailer1,
       @p_trailer2 evt_trailer1,
       @p_carrier evt_carrier,
       d1.mpp_type1,
       d1.mpp_type2,
       d1.mpp_type3,
       d1.mpp_type4,
       tc.trc_type1,
       tc.trc_type2,
       tc.trc_type3,
       tc.trc_type4,
       tl1.trl_type1,
       tl1.trl_type2,
       tl1.trl_type3,
       tl1.trl_type4,
       car_type1,
       car_type2,
       car_type3,
       car_type4,
       car_board
from 
	@assets ast
	left outer join manpowerprofile d1 on ast.driver1=d1.mpp_id
	left outer join tractorprofile tc on ast.tractor=tc.trc_number
	left outer join trailerprofile tl1 on ast.trailer1=tl1.trl_id
	left outer join carrier on ast.carrier=carrier.car_id 
-- END PTS 60816
	      
      
       
GO
GRANT EXECUTE ON  [dbo].[GetAssetInfoForInvoice] TO [public]
GO
