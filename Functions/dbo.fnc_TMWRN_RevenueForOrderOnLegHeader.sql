SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE           FUNCTION [dbo].[fnc_TMWRN_RevenueForOrderOnLegHeader] (@OrderHeaderNumber int,@LegHeaderNumber int,@MoveNumber int,@NonAllocatedRevenueForOrder float)
/*RETURNS @FinalOrdersOnMoves TABLE (
   				mov_number int,
				ord_hdrnumber int,
				LoadedMilesForOrderOnMove int
			         )
*/
Returns money

/*Returns a result set that lists all the employees who report to given 
employee directly or indirectly.*/
AS
BEGIN
   DECLARE @AllocatedRevenueForLegHeader money
   DECLARE @LegHeaderMiles float
   Declare @AllocatedRevenueForOrderOnMove money
   Declare @LGHMileagePercentofMove float
   Declare @MoveMiles float
   Declare @LoadStatus varchar(150)

   Set @LoadStatus = 'LD'


  
   -- table variable to hold accumulated results
   DECLARE @OrdersOnMoves TABLE 
	(mov_number int, 
      	 ord_hdrnumber int,
         MinSequence int,
         MaxSequence int)


   DECLARE @OrderMilesOnMoves TABLE 
	(mov_number int, 
      	 ord_hdrnumber int,
	 copy_ord_hdrnumber int,
         MilesForOrderOnMove float,
	 NonAllocatedMilesForMove float,
	 AllocatedRevenueForOrderOnMove money,
	 TotalMilesForOrderAllMoves float,
	 AllocatedOrderMilesOnMove float
	)
        

   Declare @Stops TABLE
	(mov_number int,
	 ord_hdrnumber int,
	 lgh_number int,
	 stp_mfh_sequence int,
	 stp_lgh_mileage float,
	 stp_loadstatus varchar(40)
	)   


   Insert   @Stops
   select   mov_number,
            ord_hdrnumber,
	    lgh_number,
	    stp_mfh_sequence,
            IsNull(stp_lgh_mileage,0),
	    stp_loadstatus
  From      stops (NOLOCK)
  Where     mov_number IN (select b.mov_number from stops b (NOLOCK) where b.ord_hdrnumber = @OrderHeaderNumber)
 


   INSERT   @OrdersOnMoves
   select   stops.mov_number,
            stops.ord_hdrnumber,
            Min(stp_mfh_sequence) as MinSequence,
            Max(stp_mfh_sequence) as MaxSequence

   From     @Stops stops
   Where    stops.ord_hdrnumber = @OrderHeaderNumber
   Group By stops.mov_number,stops.ord_hdrnumber
   Order By stops.mov_number


   Insert   @OrderMilesOnMoves
   Select   mov_number,
            ord_hdrnumber,
	    ord_hdrnumber as copy_ord_hdrnumber,
            MilesForOrderOnMove = (Select isNull(sum(isnull(stp_lgh_mileage,0)),0) from @Stops stops where    (
														(@LoadStatus = 'ALL')
        		        										 Or
														(@LoadStatus = 'LD' And stops.stp_loadstatus = 'LD')
														 Or
														(@LoadStatus = 'MT' And stops.stp_loadstatus <> 'LD')
			       										      )
													      and 
													      MovesForOrdersOnList.mov_number = stops.mov_number 
													      and 
													      stp_mfh_sequence >= MinSequence and stp_mfh_sequence <= MaxSequence
				  ),
	    NonAllocatedMilesForMove = (Select isNull(sum(isnull(stp_lgh_mileage,0)),0) from @Stops stops where (
														  (@LoadStatus = 'ALL')
        		        										  Or
														  (@LoadStatus = 'LD' And stops.stp_loadstatus = 'LD')
														  Or
														  (@LoadStatus = 'MT' And stops.stp_loadstatus <> 'LD')
			       										        ) 
														and 
														MovesForOrdersOnList.mov_number = stops.mov_number
					),
	    cast(0 as money) as AllocatedRevenueForOrderOnMove,
            cast(0 as float) as TotalMilesForOrderAllMoves,
	    cast(0 as float) as AllocatedOrderMilesOnMove
	   


   From   @OrdersOnMoves MovesForOrdersOnList


     UPDATE @OrderMilesOnMoves SET TotalMilesForOrderAllMoves = 
 	(SELECT sum(IsNull(b.MilesForOrderOnMove,0)) 
  	 FROM 
   		(SELECT 
		       ord_hdrnumber as NewOrderHeaderNumber,
     		       MilesForOrderOnMove as MilesForOrderOnMove 
    		 FROM  @OrderMilesOnMoves)B
  	 Where
	       B.NewOrderHeaderNumber = ord_hdrnumber
	) 

   Update @OrderMilesOnMoves
   Set AllocatedRevenueForOrderOnMove = Case When IsNull(TotalMilesForOrderAllMoves,0) = 0 Then
						@NonAllocatedRevenueForOrder/case when IsNull((select count (distinct mov_number ) from @OrderMilesOnMoves),0) = 0 Then 1 Else (select count (distinct mov_number ) from @OrderMilesOnMoves) End  
					Else
						(MilesForOrderOnMove/TotalMilesForOrderAllMoves) * @NonAllocatedRevenueForOrder
					End
   --Where LoadedMilesForOrderOnMove > 0

   Set @LegHeaderMiles = IsNull((Select sum(IsNull(stp_lgh_mileage,0)) from @Stops stops where stops.lgh_number = @LegHeaderNumber),0)

   
   Set @MoveMiles = IsNull((Select sum(IsNull(stp_lgh_mileage,0)) from @Stops stops where stops.mov_number = @MoveNumber and lgh_number In (select b.lgh_number from @stops b where b.ord_hdrnumber = @OrderHeaderNumber)),0)
   --Set @AllocatedRevenue = (select min(mov_number) from @OrderMilesOnMoves b where )

   Set @AllocatedRevenueForOrderOnMove = IsNull((Select AllocatedRevenueForOrderOnMove from @OrderMilesOnMoves Where ord_hdrnumber = @OrderHeaderNumber and mov_number = @MoveNumber),@NonAllocatedRevenueForOrder)
   

   Set @LGHMileagePercentofMove =0

   -- as 'Total Revenue',
   IF (@MoveMiles>0)
   BEGIN
	Set @LGHMileagePercentofMove =
		@LegHeaderMiles/@MoveMiles
   END 
   
   If @LGHMileagePercentofMove = 0
   Begin
	Set @AllocatedRevenueForLegHeader =@AllocatedRevenueForOrderOnMove/Case When IsNull((select count (distinct lgh_number) from @stops where ord_hdrnumber = @OrderHeaderNumber),0) = 0 Then 1 Else (select count (distinct lgh_number) from @stops where ord_hdrnumber = @OrderHeaderNumber) End
   End
   Else
   Begin 
	Set @AllocatedRevenueForLegHeader =@LGHMileagePercentofMove * @AllocatedRevenueForOrderOnMove
   End

   

   return @AllocatedRevenueForLegHeader

   
END















GO
