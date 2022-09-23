SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






--WatchDogLogExtraction 'Header'
CREATE      Procedure [dbo].[WatchDogLogExtraction] (@Mode varchar(255) = 'Header',@sn int=0)

As
SET NOCOUNT ON

Declare @SQL varchar(8000)
Declare @RowID int
Declare @ColumnName varchar(100)


	If @Mode = 'Header'
		Begin

			Select  CarrierName,
				ParentWatchName,
				WatchName,
			        LogDate,
				ThresholdValue,
			        TransactionCount
				
		        From    WatchDogLogHeader
		End
		Else	
		Begin
			
			Set @SQL = ''

	 
			Select Distinct identity(int,1,1) as RowID,
	       		TempDetailLog.*
	
			into #TempLogDetail
			From

			(

				Select distinct sn,FldName
				From   WatchDogLogDetail
				Where   sn = @sn

			) as TempDetailLog

			Select @RowID = Min(RowID)
			from   #TempLogDetail
		

	
			Select @SQL = 'Select Distinct WatchDogLogHeader.sn,WatchName,LogDate,RunDuration,ThresholdValue,RowID,'

			While @RowID Is Not Null     
			Begin
		
				Select @ColumnName = FldName From #TempLogDetail where RowID = @RowID 

				Set @SQL = @SQL + '(select fldvalue from  WatchDogLogDetail where fldName=' + '''' +  @ColumnName + '''' + ' and a.RowID=WatchDogLogDetail.RowID) as [' + @ColumnName + ']' + ','
	
				Select
	     				@RowID = min(rowid)
	    			From
	      				#TempLogDetail
	    			Where
	      				rowid > @rowid
				
				Set @SQL = Left(@SQL,Len(@SQL)-1)

				Set @SQL = @SQL + ' From WatchDogLogDetail a,WatchDogLogHeader Where WatchDogLogHeader.sn = a.sn'

				Exec (@SQL)
	
			End
		End

	










GO
