SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fnc_ssrs_MilesForOrderOnLegHeader] (@OrderHeaderNumber int,@LegHeaderNumber int,@MoveNumber int,@LoadStatus varchar(50)='ALL',@EmptyMileAllocationMethod varchar(50)='DivideEvenly')
/*RETURNS @FinalOrdersOnLegHeaders TABLE (  
       mov_number int,  
    ord_hdrnumber int,  
    MilesForOrderOnLegHeader int  
            )  
*/  
Returns float  
  
/*Returns a result set that lists all the employees who report to given   
employee directly or indirectly.*/  
AS  
BEGIN  
   Declare @AllocatedMilesForOrder as float  
  
  
   -- table variable to hold accumulated results  
   DECLARE @OrdersOnLegHeader TABLE   
 (lgh_number int,   
        ord_hdrnumber int,  
         MinSequence int,  
         MaxSequence int)  
  
  
   DECLARE @OrderMilesOnLegHeader TABLE   
 (lgh_number int,   
        ord_hdrnumber int,  
  copy_ord_hdrnumber int,  
         MilesForOrderOnLegHeader float,  
  NonAllocatedLoadedMilesForLegHeader float,  
  AllocatedEmptyMilesForOrderOnLegHeader float,  
  NonAllocatedEmptyMilesForLegHeader float,  
  TotalMilesForOrderAllLegHeaders float,  
  AllocatedOrderMilesOnLegHeader float  
    
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
   select   stops.mov_number,  
            case when stops.ord_hdrnumber = 0 then legheader.ord_hdrnumber Else stops.ord_hdrnumber End,  
     stops.lgh_number,  
     stops.stp_mfh_sequence,  
           IsNull(stops.stp_lgh_mileage,0),  
     stops.stp_loadstatus  
  From      stops  with(nolock) 
  Inner Join legheader  with(nolock)  On stops.lgh_number = legheader.lgh_number  
  Where     stops.mov_number = @MoveNumber--stops.lgh_number = @LegHeaderNumber  
   
  
   INSERT   @OrdersOnLegHeader  
   select   stops.lgh_number,  
            stops.ord_hdrnumber,  
            MinSequence = (select min(b.stp_mfh_sequence) from @stops b where b.mov_number = stops.mov_number and b.ord_hdrnumber = stops.ord_hdrnumber),  
     MaxSequence = (select max(b.stp_mfh_sequence) from @stops b where b.mov_number = stops.mov_number and b.ord_hdrnumber = stops.ord_hdrnumber)  
     --case when Min(stp_mfh_sequence) = Max(stp_mfh_sequence) then (select min(b.stp_mfh_sequence) from @stops b where b.lgh_number = stops.lgh_number) Else Min(stp_mfh_sequence) End as MinSequence,  
     --case when Min(stp_mfh_sequence) = Max(stp_mfh_sequence) then (select max(b.stp_mfh_sequence) from @stops b where b.lgh_number = stops.lgh_number) Else Max(stp_mfh_sequence) End as MaxSequence  
       
   From     @Stops stops  
   Where    stops.ord_hdrnumber >0  
     And  
     stops.lgh_number = @LegHeaderNumber  
   Group By stops.lgh_number,stops.ord_hdrnumber,stops.mov_number  
   Order By stops.lgh_number  
  
   Insert   @OrderMilesOnLegHeader  
   Select   lgh_number,  
            ord_hdrnumber,  
     ord_hdrnumber as copy_ord_hdrnumber,  
            MilesForOrderOnLegHeader = (Select isNull(sum(isnull(stp_lgh_mileage,0)),0) from @Stops stops where    stops.stp_loadstatus = 'LD'  
                   and   
                   LegHeaderForOrdersOnList.lgh_number = stops.lgh_number   
                   and   
                   stp_mfh_sequence > MinSequence and stp_mfh_sequence <= MaxSequence  
      ),  
     NonAllocatedLoadedMilesForLegHeader = (Select isNull(sum(isnull(stp_lgh_mileage,0)),0) from @Stops stops where   
               stops.stp_loadstatus = 'LD'  
               and   
               LegHeaderForOrdersOnList.lgh_number = stops.lgh_number  
          ),  
  
  
     AllocatedEmptyMilesForOrderOnLegHeader = (Select isNull(sum(isnull(stp_lgh_mileage,0)),0) from @Stops stops where    stops.stp_loadstatus <> 'LD'  
               and   
               LegHeaderForOrdersOnList.lgh_number = stops.lgh_number  
         )/IsNull((select count(distinct b.ord_hdrnumber) from @stops b where b.lgh_number = LegHeaderForOrdersOnList.lgh_number and b.ord_hdrnumber>0),1),  
     NonAllocatedEmptyMilesForLegHeader = (Select isNull(sum(isnull(stp_lgh_mileage,0)),0) from @Stops stops where    stops.stp_loadstatus <> 'LD'  
               and   
               LegHeaderForOrdersOnList.lgh_number = stops.lgh_number  
        ),  
            cast(0 as float) as TotalMilesForOrderAllLegHeaders,  
     cast(0 as float) as AllocatedOrderMilesOnLegHeader  
      
  
  
   From   @OrdersOnLegHeader LegHeaderForOrdersOnList  
  
  
  UPDATE @OrderMilesOnLegHeader SET TotalMilesForOrderAllLegHeaders =   
  (SELECT sum(IsNull(b.MilesForOrderOnLegHeader,0))   
    FROM   
     (SELECT   
              lgh_number AS NewLegHeaderNumber,   
              MilesForOrderOnLegHeader as MilesForOrderOnLegHeader   
       FROM  @OrderMilesOnLegHeader) B  
    Where B.NewLegHeaderNumber = lgh_number  
 )   
         
   Update @OrderMilesOnLegHeader  
   Set AllocatedOrderMilesOnLegHeader = cast(MilesForOrderOnLegHeader as float)/cast(case when IsNull(TotalMilesForOrderAllLegHeaders,0) = 0 Then 1 Else IsNull(TotalMilesForOrderAllLegHeaders,0)  End as float) * NonAllocatedLoadedMilesForLegHeader  
      
   Set @AllocatedMilesForOrder = IsNull((select Case When @LoadStatus = 'LD' Then  
       sum(IsNull(AllocatedOrderMilesOnLegHeader,0))   
           When @LoadStatus = 'MT' Then  
       sum(IsNull(AllocatedEmptyMilesForOrderOnLegHeader,0))   
           Else  
       sum(IsNull(AllocatedOrderMilesOnLegHeader,0)+ IsNull(AllocatedEmptyMilesForOrderOnLegHeader,0))   
      End  
      from   @OrderMilesOnLegHeader   
      where  ord_hdrnumber = @OrderHeaderNumber),0)   
  
   return @AllocatedMilesForOrder  
  
  
     
END  
  
  
  
  
  
  
  
GO
