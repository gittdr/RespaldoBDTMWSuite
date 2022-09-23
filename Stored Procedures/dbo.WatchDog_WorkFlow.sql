SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[WatchDog_WorkFlow] 
(
 @MinThreshold float = 1,
 @MinsBack int=0,
 @TempTableName varchar(255)='##WatchDogGlobalWorkFlow',
 @WatchName varchar(255)='WorkFlow',
 @ThresholdFieldName varchar(255) = 'Days',
 @ColumnNamesOnly bit = 0,
 @ExecuteDirectly bit = 0,
 @ColumnMode varchar (50) ='Selected',
 --Additional/Optional Parameters
   @RevType1 varchar(140)='',
    @RevType2 varchar(140)='',
    @RevType3 varchar(140)='',
   @RevType4 varchar(140)='',
   @OrderStatus varchar(140)='STD,CMP',
   @DepartmentType varchar(140) = '',
 @MandatoryPaperworkTypes varchar(255) = '',
    @UseCompletionDateToTodayForImagingLagYN char(1) = 'N',
 @ExcludeRevType1 varchar(140)='',
 @ExcludeRevType2 varchar(140)='',
 @ExcludeRevType3 varchar(140)='',
 @ExcludeRevType4 varchar(140)='',
 @OnlyBillToID varchar(255)='',
 @ExcludeBillToID varchar(255)='',
 @CacheResultsWithNoRepetitionYN varchar(1)='N',
 @DaysToMaintainCache int = 1000
)
      
 
As
 
set nocount on
 
Declare @SQL nvarchar(4000)
 
Set @RevType1= ',' + ISNULL(@RevType1,'') + ','
Set @RevType2= ',' + ISNULL(@RevType2,'') + ','
Set @RevType3= ',' + ISNULL(@RevType3,'') + ','
Set @RevType4= ',' + ISNULL(@RevType4,'') + ','
Set @OrderStatus= ',' + ISNULL(@OrderStatus,'') + ','
Set @MandatoryPaperworkTypes= ',' + ISNULL(@MandatoryPaperworkTypes,'') + ','
 
Set @ExcludeRevType1= ',' + ISNULL(@ExcludeRevType1,'') + ','
Set @ExcludeRevType2= ',' + ISNULL(@ExcludeRevType2,'') + ','
Set @ExcludeRevType3= ',' + ISNULL(@ExcludeRevType3,'') + ','
Set @ExcludeRevType4= ',' + ISNULL(@ExcludeRevType4,'') + ','
 
Set @OnlyBillToID= ',' + ISNULL(@OnlyBillToID,'') + ','
Set @ExcludeBillToID= ',' + ISNULL(@ExcludeBillToID,'') + ','
 

--Reserved/Mandatory WatchDog Variables
 
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables
 
--Create SQL and return results into #TempResults
 

select [ord_number] As [Order Number],
       [ord_completiondate] As [Delivery Date],
       'Updated Date' = (select max(lgh_updatedon) from legheader (NOLOCK) where legheader.ord_hdrnumber = orderheader.ord_hdrnumber),
       'PaperWork Received Date' =  (select top 1 pw_dt from paperwork (NOLOCK) where pw_received = 'Y' and paperwork.ord_hdrnumber = orderheader.ord_hdrnumber and (@MandatoryPaperworkTypes =',,' or CHARINDEX(',' + abbr + ',', @MandatoryPaperworkTypes) >0)),
       ord_invoicestatus as InvoiceStatus,
       case when ord_invoicestatus = 'PPD' Then
  convert(money,IsNull((select sum(IsNull(dbo.fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),0))
       Else
  convert(money,IsNull(dbo.fnc_convertcharge(ord_totalcharge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))
       End As [Total Revenue],
       ord_revtype1 as RevType1,
       ord_billto as [Bill To ID],
       ord_shipper as [Shipper ID],
       ord_consignee as [Consignee ID],
       'Driver Name' = IsNull((select mpp_lastfirst from manpowerprofile (NOLOCK) where mpp_id = ord_driver1),''), 
       ord_status As [Order Status],
       mov_number,
       ord_hdrnumber,
       IsNull((select Min('Y') from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = OrderHeader.ord_hdrnumber and ivh_invoicestatus <> 'CAN'),'N') as InvoiceExists
      
into   #TempPaperwork      
From   OrderHeader (NOLOCK) 
Where   (@RevType1 =',,' or CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
        AND (@RevType2 =',,' or CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
        AND (@RevType3 =',,' or CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
        AND (@RevType4 =',,' or CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
        And (@OrderStatus =',,' or CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
        And ord_completiondate > Dateadd(mi,@MinsBack,GetDate())
        And (
    (@ColumnMode = 'ALL' And 1=0)
     oR
    (@ColumnMode <> 'ALL')
         )
  AND (@ExcludeRevType1 =',,' or CHARINDEX(',' + ord_revtype1 + ',', @ExcludeRevType1) =0)
     AND (@ExcludeRevType2 =',,' or CHARINDEX(',' + ord_revtype2 + ',', @ExcludeRevType2) =0)
  AND (@ExcludeRevType3 =',,' or CHARINDEX(',' + ord_revtype3 + ',', @ExcludeRevType3) =0)
  AND (@ExcludeRevType4 =',,' or CHARINDEX(',' + ord_revtype4 + ',', @ExcludeRevType4) =0)
  AND (@OnlyBillToID =',,' or CHARINDEX(',' + ord_billto + ',', @OnlyBillToID) >0)
  AND (@ExcludeBillToID =',,' or CHARINDEX(',' + IsNull(ord_billto,'') + ',', @ExcludeBillToID) =0)
 
Select TempOrders2.*,
       (IsNull([Delivery to Released Date Lag],0) + IsNull([Released to Paperwork Received Date Lag],0) + ISNull([Paperwork to Todays Date Lag],0)) as TotalLagAllDepartments
 
INTO   #TempOrders
From
 
(
 

Select #TempPaperWork .*,
       DateDiff(day,[Delivery Date],[Updated Date]) as [Delivery to Released Date Lag],
       DateDiff(day,[Delivery Date],GetDate()) as [Delivery to Todays Date Lag],
       DateDiff(day,[Updated Date],GetDate()) as [Released to Todays Date Lag],
       DateDiff(day,[Updated Date],[Paperwork Received Date]) as [Released to Paperwork Received Date Lag],
       DateDiff(day,[Paperwork Received Date],GetDate()) as [Paperwork to Todays Date Lag],
      (select max(lgh_updatedby) from legheader (NOLOCK) where legheader.ord_hdrnumber = #TempPaperwork.ord_hdrnumber and legheader.lgh_updatedon = [Updated Date]) as 'Updated By'
 
From   #TempPaperWork     
) as TempOrders2
 
 
 
IF @DepartmentType = 'Dispatch'
 
    Begin
  
 --Dispatch will always receive orders that are not at
 --a completed status 
           Select    [Order Number],
                            [Delivery Date],
                            [Order Status], 
                            [Delivery to Todays Date Lag] as [Dispatch Lag],
                            [Updated Date],
                     [Updated By],
       RevType1
     
            into      #TempResultsPreCache
            From     #TempOrders 
     Where    [Order Status] <> 'CMP'
       And
       [Delivery to Todays Date Lag] > @MinThreshold
 
     Order By RevType1 ASC,[Updated By] ASC,[Delivery to Todays Date Lag] Desc
 
IF @CacheResultsWithNoRepetitionYN = 'Y'
            BEGIN
                        DELETE FROM WatchDogCache
                        WHERE CacheDate < DateAdd(day,-@DaysToMaintainCache,GETDATE())
                        DELETE FROM #TempResultsPreCache
                        WHERE EXISTS (
                                                                        SELECT * 
                                                                        from WatchDogCache
                                                                        where #TempResultsPreCache.[Order Number] = WatchDogCache.[Identifier]
                                                                        and WatchName = @WatchName 
                                                            )

                        Insert Into WatchDogCache
                        SELECT            @WatchName,
                                                 [Order Number],
                                                GETDATE() as CacheDate
                        FROM #TempResultsPreCache
                        where Isnull([Order Number],'') > ''
            END

            SELECT * into #TempResultsDispatch from #TempResultsPreCache         

    --Commits the results to be used in the wrapper
  If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
  Begin
   Set @SQL = 'Select * from #TempResultsDispatch'
  End
  Else
  Begin
   Set @COLSQL = ''
   Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
   Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResultsDispatch'
  End  
 
   
 
    End
    
 
ELSE IF @DepartmentType = 'Imaging'
 
    Begin
 
 --Imaging/Paperwork Processing
 --will only get completed loads that 
 --don't have paperwork
 
 Select [Order Number],
        Case When @UseCompletionDateToTodayForImagingLagYN = 'Y' Then
   [Delivery Date]
        Else
   [Updated Date]
        End as [Dispatch Completion Date],
        [Updated By] as [Completed By],
               Case When @UseCompletionDateToTodayForImagingLagYN = 'Y' Then
   [Delivery to Todays Date Lag]
        Else
   [Released to Todays Date Lag]
        End as [Imaging Lag],
        [Order Status], 
           RevType1,
        InvoiceStatus,
        [Shipper ID],
        [Bill To ID],
     [Total Revenue]
   
        into   #TempResultsImaging
        From   #TempOrders 
        Where  [Order Status] = 'CMP'
        And
        [Paperwork Received Date] Is Null
        And
       (
  (@UseCompletionDateToTodayForImagingLagYN = 'N' And [Released to Todays Date Lag] > @MinThreshold)
          OR
  (@UseCompletionDateToTodayForImagingLagYN = 'Y' And [Delivery to Todays Date Lag] > @MinThreshold)
        )
 
        Order By RevType1 ASC,[Updated By] ASC,[Released to Todays Date Lag] Desc
 
      
        --Set @SQL = 'Select identity(int,1,1) as RowID,* into ' + @TempTableName + ' from #TempResultsImaging'
 
 --Commits the results to be used in the wrapper
 If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
 Begin
  Set @SQL = 'Select * from #TempResultsImaging'
 End
 Else
 Begin
  Set @COLSQL = ''
  Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
  Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResultsImaging'
 End   
 
 
 
   End
 
ELSE IF @DepartmentType = 'Billing'
 
    Begin
 
  --Billing Dept gets anything that is
  --EITHER 1 OF THE 2 SCENARIOS
  --1. Paperwork is Received
  --   Load is not completed
  --   Invoice is not prepared
 
  --2. Paperwork is Received
  --   Load is completed 
  --   Invoice is prepared
 
            Select [Order Number],
     [Paperwork to Todays Date Lag] as [Billing Lag],
     [PaperWork Received Date], 
     [Order Status],
            RevType1,
     [Shipper ID],
     [Bill To ID]
         
 
                   into   #TempResultsBilling
            From   #TempOrders
     Where  [Paperwork Received Date] Is Not Null 
                  And 
                  InvoiceExists = 'N'
     And
 
     [Order Status] = 'CMP'
     And
     [Paperwork to Todays Date Lag] > @MinThreshold
     And
 
                          InvoiceStatus <> 'XIN'
 
    Order By RevType1 ASC,[Updated By] ASC,[Paperwork to Todays Date Lag] Desc
 

 --Commits the results to be used in the wrapper
 If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
 Begin
  Set @SQL = 'Select * from #TempResultsBilling'
 End
 Else
 Begin
  Set @COLSQL = ''
  Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
  Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResultsBilling'
 End        
 
 
 

    End
 

ELSE IF @DepartmentType = 'HighPriority'
 
    Begin
 

  
  --Billing Dept gets anything that is
  --EITHER 1 OF THE 2 SCENARIOS
  --1. Paperwork is Received
  --   Load is not completed
  --   Invoice is not prepared
 
  --2. Paperwork is Received
  --   Load is completed 
  --   Invoice is prepared
 
            Select [Order Number],
     [Paperwork to Todays Date Lag] as [Billing Lag],
     [Order Status],
            RevType1
         
 
                   into   #TempResultsHighPriority
            From   #TempOrders
     Where  [Paperwork Received Date] Is Not Null 
                  And 
                  InvoiceExists = 'N'
     And
     [Order Status] <> 'CMP'
     And
                          InvoiceStatus <> 'XIN'
 
    Order By RevType1 ASC,[Updated By] ASC,[Paperwork to Todays Date Lag] Desc
 
        --Set @SQL = 'Select identity(int,1,1) as RowID,* into ' + @TempTableName + ' from #TempResultsHighPriority'
 
 --Commits the results to be used in the wrapper
 If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
 Begin
  Set @SQL = 'Select * from #TempResultsHighPriority'
 End
 Else
 Begin
  Set @COLSQL = ''
  Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
  Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResultsHighPriority'
 End
 
 
 

    End
 
 
 
 
 
Else --must be for administrators
 
    Begin
 
 
 
           Select #TempOrders.* 
                  into   #TempResults  
           From   #TempOrders
 
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
 
    End
 

--Commits the results to be used in the wrapper
 

Exec (@SQL)
 

set nocount off
 

GO
