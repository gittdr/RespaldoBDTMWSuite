SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fnc_TMWRN_Miles] 
(
	@Mode varchar(255) = 'Segment',
	@MilesType varchar(50) = 'Travel',--Billed,Travel,NonBilled possibly hub someday
	@CalculationType varchar(50) = 'Miles',--DHPCT,LDPCT,Miles are choices
	@MoveNumber int = Null,
	@OrderHeaderNumber int = Null,
	@LegHeaderNumber int = Null,
	@StopNumber int = Null,
	@LoadStatus varchar(255) = 'ALL', --LD or MT or ALL (in future possible LIST)
	@StopStatusList varchar(255) = '',
	@InvoiceHeaderNumber int,
	@BillToID varchar(100) = ''
) 

Returns float
As
Begin 
 
/*
Function Name:     fnc_TMWRN_Miles
Author/CreateDate: Brent Keeton / 7-14-2004
Purpose: 	   Serves as the bridge between different types
		   of mileage calculations
Revision History:  1. 7/14/2004 LBK -> Fixed Billed Miles and LegHeader Miles
				       to return correct value.
				       Basically both were not setting the @Miles variable

PTS 37022 B.Young - 
Desc:
--this is a new parm that will return the ivd_quantity from a mileage based LH and use it
as the miles

*/


Declare @Miles float         
Declare @MoveMiles float
Declare @LoadedMiles float
Declare @EmptyMiles float
Declare @LegHeaderMiles float
Declare @ReturnMiles float
Declare @BilledMilesOnly char(1)
Declare @NonBilledMilesOnly char(1)


If @MilesType = 'Billed'
   Begin
	Set @BilledMilesOnly = 'Y'
   End
   Else
   Begin
	Set @BilledMilesOnly = 'N'
   End
       

If @MilesType = 'NonBilled'
   Begin
	Set @NonBilledMilesOnly = 'Y'
   End
   Else
   Begin
	Set @NonBilledMilesOnly = 'N'
   End

--this is a new parm that will return the ivd_quantity from a mileage based LH and use it
--as the miles
--It will have to sum the ivd qty on each order to see if it was billed by miles
--this is not ideal, but it will only fire if
declare @imiles int
select 	@iMiles = 0

If (@MilesType = 'ActualOnInvoice')
begin
	select	@imiles = isNull(sum(isNull(i.ivd_quantity,0)),0)
	  from 	invoicedetail i join chargetype c on i.cht_itemcode = c.cht_itemcode
					join invoiceheader ih on i.ivh_hdrnumber = ih.ivh_hdrnumber and ih.mov_number = @MoveNumber
					and ih.ivh_hdrnumber = (select max(ih2.ivh_hdrnumber) from invoiceheader ih2 where ih2.mov_number = @MoveNumber )
	 where 	i.ivd_type = 'sub' and c.cht_rateunit = 'MIL'
	if @imiles > 0 
	begin
		Set @Miles = @imiles
	end
end


--if the imiles are still zero then keep processing with the normal logic
if (@iMiles = 0)
-- @MilesType must be Billed or Non-billed
begin --start iMiles = 0

If @Mode = 'Invoice' --*********************INVOICE LEVEL*****************
Begin

	
		--If this is the first invoice for the billto account
		--for the billed miles
		Select @ReturnMiles = IsNull(dbo.fnc_TMWRN_InvoiceMiles(@InvoiceHeaderNumber,@OrderHeaderNumber,@MoveNumber,@BillToID,@LoadStatus,@StopStatusList,@BilledMilesOnly,@NonBilledMilesOnly),0)		
		
		--******************Return the output Percentage or Mileage
		--Deadhead Percent (Empty Miles/Billed Miles)
		If @CalculationType = 'DHPCT'
		Begin
			Set @EmptyMiles = IsNull(dbo.fnc_TMWRN_InvoiceMiles(@InvoiceHeaderNumber,@OrderHeaderNumber,default,'','MT',@StopStatusList,@BilledMilesOnly,@NonBilledMilesOnly),0)	
			If @ReturnMiles > 0  
				Begin
					Set @Miles = @EmptyMiles/@ReturnMiles
				End
		End
		--Loaded Percent (Loaded Miles/Billed Miles)
		Else If @CalculationType = 'LDPCT'
		Begin
			Set @LoadedMiles = IsNull(dbo.fnc_TMWRN_InvoiceMiles(@InvoiceHeaderNumber,@OrderHeaderNumber,default,'','LD',@StopStatusList,@BilledMilesOnly,@NonBilledMilesOnly),0)	
			If @ReturnMiles > 0  
				Begin
					Set @Miles = @LoadedMiles/@ReturnMiles
				End
		End
		Else --Assume Default Miles Calc Type
		Begin
					Set @Miles = @ReturnMiles

		End		   

	


End
Else If @Mode= 'Movement' --*********************MOVEMENT LEVEL*****************
Begin
	
	
			Set @ReturnMiles = IsNull(dbo.fnc_TMWRN_MoveMiles(@MoveNumber,@LegHeaderNumber,0,@LoadStatus,@StopStatusList,@BilledMilesOnly,@NonBilledMilesOnly),0)					

			If @CalculationType = 'DHPCT'
			Begin
				Set @EmptyMiles = IsNull(dbo.fnc_TMWRN_MoveMiles(@MoveNumber,@LegHeaderNumber,0,'MT',@StopStatusList,@BilledMilesOnly,@NonBilledMilesOnly),0)		
				If @ReturnMiles > 0  
					Begin
						Set @Miles = @EmptyMiles/@ReturnMiles
					End
			End
			Else If @CalculationType = 'LDPCT'
			Begin
				Set @LoadedMiles = IsNull(dbo.fnc_TMWRN_MoveMiles(@MoveNumber,@LegHeaderNumber,0,'LD',@StopStatusList,@BilledMilesOnly,@NonBilledMilesOnly),0)		
				If @ReturnMiles > 0  
				Begin
					Set @Miles = @LoadedMiles/@ReturnMiles
				End
			End
			Else --Assume Default Miles Calc Type
			Begin
				Set @Miles = @ReturnMiles

			End		


	
End
Else If @Mode = 'Order' --*********************ORDER LEVEL*****************
			--Eventually this will allocate mileage back to order
Begin
	
			Select @MoveNumber = mov_number from orderheader (NOLOCK) where ord_hdrnumber = @OrderHeaderNumber

			Set @ReturnMiles = IsNull(dbo.fnc_TMWRN_MilesForOrder(@OrderHeaderNumber,@LoadStatus,'DivideEvenly'),0)--IsNull(dbo.fnc_TMWRN_MoveMiles(@MoveNumber,@LegHeaderNumber,0,@LoadStatus,@StopStatusList,@BilledMilesOnly,@NonBilledMilesOnly),0)					

			If @CalculationType = 'DHPCT'
			Begin
			
				Set @EmptyMiles = IsNull(dbo.fnc_TMWRN_MilesForOrder(@OrderHeaderNumber,'MT','DivideEvenly'),0)--IsNull(dbo.fnc_TMWRN_MoveMiles(@MoveNumber,@LegHeaderNumber,0,'MT',@StopStatusList,@BilledMilesOnly,@NonBilledMilesOnly),0)		
				If @ReturnMiles > 0  
					Begin
						Set @Miles = @EmptyMiles/@ReturnMiles
					End
			End
			Else If @CalculationType = 'LDPCT'
			Begin
				Set @LoadedMiles = IsNull(dbo.fnc_TMWRN_MilesForOrder(@OrderHeaderNumber,'LD','DivideEvenly'),0)--IsNull(dbo.fnc_TMWRN_MoveMiles(@MoveNumber,@LegHeaderNumber,0,'LD',@StopStatusList,@BilledMilesOnly,@NonBilledMilesOnly),0)		
				If @ReturnMiles > 0  
				Begin
					Set @Miles = @LoadedMiles/@ReturnMiles
				End
			End
			Else --Assume Default Miles Calc Type
			Begin
				Set @Miles = @ReturnMiles

			End		


	
	
End
Else If @Mode = 'Stops' --*********************STOP LEVEL*****************
Begin
	Set @Miles = IsNull(dbo.fnc_TMWRN_StopMiles(@StopNumber,0,@LoadStatus,@StopStatusList),0)		
End
Else --*********************LEGHEADER/TRIP SEGMENT LEVEL*****************
Begin
	


			Set @ReturnMiles = IsNull(dbo.fnc_TMWRN_LegHeaderMiles(@LegHeaderNumber,0,@LoadStatus,@StopStatusList,@BilledMilesOnly,@NonBilledMilesOnly),0)		

			If @CalculationType = 'DHPCT'
			Begin
				Set @EmptyMiles = IsNull(dbo.fnc_TMWRN_LegHeaderMiles(@LegHeaderNumber,0,'MT',@StopStatusList,@BilledMilesOnly,@NonBilledMilesOnly),0)		
				
				If @MoveMiles > 0  
				Begin
					Set @Miles = @EmptyMiles/@ReturnMiles
				End
			End
			Else If @CalculationType = 'LDPCT'
			Begin
				Set @LoadedMiles = IsNull(dbo.fnc_TMWRN_LegHeaderMiles(@LegHeaderNumber,0,'LD',@StopStatusList,@BilledMilesOnly,@NonBilledMilesOnly),0)		
				
				If @MoveMiles > 0  
				Begin
					Set @Miles = @LoadedMiles/@ReturnMiles
				End
			End
			Else --Assume Default Miles Calc Type
			Begin
				Set @Miles = @ReturnMiles

			End		
End

END --end iMiles = 0
Return @Miles

End


GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_Miles] TO [public]
GO
