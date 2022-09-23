SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  Procedure [dbo].[WatchDog_SameLegCityNonZeroMiles] ( 
   @MinThreshold float = 200, 
   @MinsBack int=-20, 
   @TempTableName varchar(255) = '##WatchDogGlobalSameLegCity', 
   @WatchName varchar(255)='WatchSameLegCity', 
   @ThresholdFieldName varchar(255) = 'Same Leg City', 
   @ColumnNamesOnly bit = 0, 
   @ExecuteDirectly bit = 0, 
   @ColumnMode varchar(50) = 'Selected' 
  
     ) 
  
As 
  
--Reserved/Mandatory WatchDog Variables 
        Declare @SQL varchar(8000) 
        Declare @COLSQL varchar(4000) 
        --Reserved/Mandatory WatchDog Variables 
  
Select legheader_active.lgh_number 
        
into   #LegList 
From   legheader_active (NOLOCK) 
   
Where lgh_updatedon >= DateAdd(mi,@MinsBack,GetDate()) 
  

Select   [Order Number], 
  IsNull((select cty_nmstct from city (NOLOCK) where a.stp_city = cty_code),'') as 'Origin City/State', 
  [Dest City/State], 
  [Miles], 
  a.mov_number as [Move Number] 
  
 into   #TempResults 
 from   stops a (NOLOCK), 
  ( 
        Select 
              IsNull((select cty_nmstct from city (NOLOCK) where a.stp_city = cty_code),'') as 'Dest City/State', 
              IsNull(a.stp_lgh_mileage,0) as [Miles], 
       a.stp_city as DestCityCode, 
              (select ord_number from orderheader (NOLOCK) where a.ord_hdrnumber = orderheader.ord_hdrnumber) as [Order Number],

               a.stp_mfh_sequence, 
                a.mov_number 
  
 from   #LegList,stops a (NOLOCK) 
 where  #LegList.lgh_number = a.lgh_number 
        and 
         ( 
    (a.lgh_number = (select min(b.lgh_number) from legheader b (NOLOCK) where b.mov_number = a.mov_number and b.lgh_outstatus <> 'CAN') and a.stp_mfh_sequence > (select min(b.stp_mfh_sequence) from stops b (NOLOCK) where b.lgh_number = a.lgh_number))

    OR 
    (a.lgh_number > (select min(b.lgh_number) from legheader b (NOLOCK) where b.mov_number = a.mov_number and b.lgh_outstatus <> 'CAN') and a.stp_mfh_sequence >= (select min(b.stp_mfh_sequence) from stops b (NOLOCK) where b.lgh_number = a.lgh_number))

  
         ) 
        ) as TempDestination 
  
  
 where  a.stp_mfh_sequence = (select max(b.stp_mfh_sequence) from stops b (NOLOCK) where b.stp_mfh_sequence < TempDestination.stp_mfh_sequence and b.mov_number = TempDestination.mov_number)

        and 
        a.mov_number = TempDestination.mov_number 
        and 
        [Miles] <> 0 
        and 
              a.stp_city = DestCityCode 
 Order By [Move Number],a.stp_mfh_sequence 



--Commits the results to be used in the wrapper 
        If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1 
        Begin 
                Set @SQL = 'Select * from #TempResults' 
        End 
        Else 
        Begin 
                Set @COLSQL = '' 
                Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT

                Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'

        End 
        
        Exec (@SQL) 
        
        set nocount off 




GO
