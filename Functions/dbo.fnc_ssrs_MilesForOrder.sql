SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--select * from stops where mov_number= 2138

--select dbo.fnc_ssrs_MilesForOrder(858,'','')


CREATE FUNCTION [dbo].[fnc_ssrs_MilesForOrder] 
(
	@OrderHeaderNumber int,
	@LoadStatus varchar(50)='ALL',
	@EmptyMileAllocationMethod varchar(50)='DivideEvenly'
)--Eventually will be two other based on loaded allocation and other TBD
/*RETURNS @FinalOrdersOnMoves TABLE (
   				mov_number int,
				ord_hdrnumber int,
				MilesForOrderOnMove int
			         )
*/
Returns float

/*Returns a result set that lists all the employees who report to given 
employee directly or indirectly.*/
AS
BEGIN
   Declare @AllocatedMilesForOrder as float


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
	 NonAllocatedLoadedMilesForMove float,
	 AllocatedEmptyMilesForOrderOnMove float,
	 NonAllocatedEmptyMilesForMove float,
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
  From      stops WITH (NOLOCK)
  Where     mov_number IN (select b.mov_number from stops b WITH (NOLOCK) where b.ord_hdrnumber = @OrderHeaderNumber)
 

   INSERT   @OrdersOnMoves
   select   stops.mov_number,
            stops.ord_hdrnumber,
            Min(stp_mfh_sequence) as MinSequence,
            Max(stp_mfh_sequence) as MaxSequence

   From     @Stops stops
   Where    stops.ord_hdrnumber >0
   Group By stops.mov_number,stops.ord_hdrnumber
   Order By stops.mov_number


   Insert   @OrderMilesOnMoves
   Select   mov_number,
            ord_hdrnumber,
	    ord_hdrnumber as copy_ord_hdrnumber,
            MilesForOrderOnMove = (Select isNull(sum(isnull(stp_lgh_mileage,0)),0) from @Stops stops where    stops.stp_loadstatus = 'LD'
													      and 
													      MovesForOrdersOnList.mov_number = stops.mov_number 
													      and 
													      stp_mfh_sequence >= MinSequence and stp_mfh_sequence <= MaxSequence
				  ),
	    NonAllocatedLoadedMilesForMove = (Select isNull(sum(isnull(stp_lgh_mileage,0)),0) from @Stops stops where 
															stops.stp_loadstatus = 'LD'
															and 
															MovesForOrdersOnList.mov_number = stops.mov_number
					     ),


	    AllocatedEmptyMilesForOrderOnMove = (Select isNull(sum(isnull(stp_lgh_mileage,0)),0) from @Stops stops where    stops.stp_loadstatus <> 'LD'
															and 
															MovesForOrdersOnList.mov_number = stops.mov_number
					   	)/IsNull((select count(distinct b.ord_hdrnumber) from @stops b where b.mov_number = MovesForOrdersOnList.mov_number and b.ord_hdrnumber>0),1),
	    NonAllocatedEmptyMilesForMove = (Select isNull(sum(isnull(stp_lgh_mileage,0)),0) from @Stops stops where    stops.stp_loadstatus <> 'LD'
															and 
															MovesForOrdersOnList.mov_number = stops.mov_number
					   ),
            cast(0 as float) as TotalMilesForOrderAllMoves,
	    cast(0 as float) as AllocatedOrderMilesOnMove
	   


   From   @OrdersOnMoves MovesForOrdersOnList


  UPDATE @OrderMilesOnMoves SET TotalMilesForOrderAllMoves = 
 	(SELECT sum(IsNull(b.MilesForOrderOnMove,0)) 
  	 FROM 
   		(SELECT 
     		       mov_number AS NewMoveNumber, 
     		       MilesForOrderOnMove as MilesForOrderOnMove 
    		 FROM  @OrderMilesOnMoves) B
  	 Where B.NewMoveNumber = mov_number
	) 
       
   Update @OrderMilesOnMoves
   Set AllocatedOrderMilesOnMove = cast(MilesForOrderOnMove as float)/cast(case when IsNull(TotalMilesForOrderAllMoves,0) = 0 Then 1 Else IsNull(TotalMilesForOrderAllMoves,0)  End as float) * NonAllocatedLoadedMilesForMove
    
   Set @AllocatedMilesForOrder = IsNull((select Case When @LoadStatus = 'LD' Then
							sum(IsNull(AllocatedOrderMilesOnMove,0)) 
						     When @LoadStatus = 'MT' Then
							sum(IsNull(AllocatedEmptyMilesForOrderOnMove,0)) 
						     Else
							sum(IsNull(AllocatedOrderMilesOnMove,0)+ IsNull(AllocatedEmptyMilesForOrderOnMove,0)) 
						End
					 from   @OrderMilesOnMoves 
					 where  ord_hdrnumber = @OrderHeaderNumber),0) 

   return @AllocatedMilesForOrder


   
END

GO
