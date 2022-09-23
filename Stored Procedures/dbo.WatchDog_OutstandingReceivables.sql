SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[WatchDog_OutstandingReceivables] 
(
	@MinThreshold float = 0,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalOustandingReceivables',
	@WatchName varchar(255) = 'OustandingReceivables',
	@ThresholdFieldName varchar(255) = 'Charge',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@RevType1 varchar(140)='',
	@RevType2 varchar(140)='',
	@RevType3 varchar(140)='',
	@RevType4 varchar(140)='',
	@BillToID varchar(140)='',
	@CacheResultsWithNoRepetitionYN varchar(1)='N',
	@DaysToMaintainCache int = 1000

)

As

        Set NoCount On

 

            /*

            Procedure Name:    WatchDog_OutstandingReceivables

            Author/CreateDate: Brent Keeton / 8-25-2004

            Purpose:              

            Revision History: 
			
			Notes: This alert requires a SQL job to activate the stored Procedure daily - TMWRN_OutstandingReceivablesProcessing_GP 

            */

 

 

            --Reserved/Mandatory WatchDog Variables

            Declare @SQL varchar(8000)

            Declare @COLSQL varchar(4000)

            --Reserved/Mandatory WatchDog Variables

 

            Set @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','

            Set @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','

            Set @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','

            Set @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','

            Set @BillToID= ',' + RTrim(ISNULL(@BillToID,'')) + ','

 

            select ord_number as [Order #],

                        InvoiceHeader.ivh_invoicenumber as [Invoice Number],

                        InvoiceHeader.ivh_totalcharge as [Invoice Amount],

                        AmountReceived as [Amount Received],

                        mov_number as [Move #],

                        ivh_shipper as [Shipper ID],

                        (select cty_name from city (NOLOCK) Where cty_code = ivh_origincity) as [Origin City],

                        ivh_consignee as [Consignee ID],

                        (select cty_name from city (NOLOCK) Where cty_code = ivh_destcity) as [Destination City],

                        (select cmp_name from company (NOLOCK) Where cmp_id = ivh_billto) as [BillTo],

                        ivh_billto as [BillTo ID],

                        ivh_revtype1 as RevType1,

                        ivh_revtype2 as RevType2,

                        ivh_revtype3 as RevType3,

                        ivh_revtype4 as RevType4,

                        BatchDate as [Doc Date],

                        OpenACCTInvoiceAmount as [Total Open Amount],

                        LastPaymentAppliedDate as [Last Payment Date],

                        DateDiff(day,BatchDate,GetDate()) as [Days Open]

            INTO   #TempResultsPreCache   

            From   ACCT_OutstandingReceivables (NOLOCK) Join invoiceheader (NOLOCK) On ACCT_OutstandingReceivables.InvoiceNumber = InvoiceHeader.ivh_invoicenumber

            Where (@RevType1 =',,' or CHARINDEX(',' + ivh_revtype1 + ',', @RevType1) >0)

                        AND (@RevType2 =',,' or CHARINDEX(',' + ivh_revtype2 + ',', @RevType2) >0)

                        AND (@RevType3 =',,' or CHARINDEX(',' + ivh_revtype3 + ',', @RevType3) >0)

                        AND (@RevType4 =',,' or CHARINDEX(',' + ivh_revtype4 + ',', @RevType4) >0)

                        AND (@BillToID=',,' or CHARINDEX(',' + ivh_billto + ',', @BillToID) >0)

                        And DateDiff(day,BatchDate,GetDate()) >= @MinThreshold

 

            IF @CacheResultsWithNoRepetitionYN = 'Y'

            BEGIN

                        DELETE FROM WatchDogCache

                        WHERE CacheDate < DateAdd(day,-@DaysToMaintainCache,GETDATE())


                        DELETE FROM #TempResultsPreCache

                        WHERE EXISTS (

                                                                        SELECT * 

                                                                        from WatchDogCache

                                                                        where #TempResultsPreCache.[Invoice Number] = WatchDogCache.[Identifier]

                                                                        and WatchName = @WatchName 

                                                            )

                        

                        Insert Into WatchDogCache

                        SELECT            @WatchName,

                                                [Invoice Number],

                                                GETDATE() as CacheDate

                        FROM #TempResultsPreCache

                        where Isnull([Invoice Number],'') > ''
 

            END


            SELECT * into #TempResults from #TempResultsPreCache         


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

 

            Set NoCount Off


GO
