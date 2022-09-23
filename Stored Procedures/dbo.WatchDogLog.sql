SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO








--watchdogprocessing 'largemtmoves'

CREATE                    Procedure [dbo].[WatchDogLog](@WatchName varchar(255),@LogDate datetime ,@ProcRunDuration decimal(9,3),@DismissedFlag bit = 1,@MessageText varchar(255)='',@ThresholdValue float = 0,@TempTableName varchar(255)='',@ResultCount int = 0,@ParentWatchName varchar(25) = '')

As

			Set NoCount On			

	
			Declare @sql varchar(8000)
			Declare @sn int
			Declare @LogHeaderYN char(1)
			Declare @LogDetailYN char(1)

			Set @LogHeaderYN = IsNull((Select ParameterValue From WatchDogParameter (NOLOCK) Where Heading = 'system' and subheading = 'WatchDogLog' and parametername = 'LogHeaderYN'),'N')
			Set @LogDetailYN = IsNull((Select ParameterValue From WatchDogParameter (NOLOCK) Where Heading = 'system' and subheading = 'WatchDogLog' and parametername = 'LogDetailYN'),'N')

			If @LogHeaderYN = 'Y'
				Begin
			
					--Insert the Log Header Record
					Insert into WatchDogLogHeader (WatchName,LogDate,RunDuration,DismissedFlag,MessageText,ThresholdValue,TransactionCount,ParentWatchName)
					Values (@WatchName,@LogDate,@ProcRunDuration,1,'',cast(@ThresholdValue as float),@ResultCount,@ParentWatchName)
				End

			If @LogDetailYN = 'Y' And @LogHeaderYN = 'Y'
				Begin
					--get the last sn (Assume if it didn't error the last would represent the record on the header)
					Select @sn = Max(sn) from WatchDogLogHeader (NOLOCK)
	
					--Put the detail for the WatchDog(the result set) in the Log Detail
					SELECT @sql = ''
	
					SELECT @sql = @sql +  'SELECT ' + cast(@sn as varchar(20)) + ' as sn, ' + '''' + column_name + ''' AS FieldName, 
			      	     	       IsNull(Convert(varchar(50),[' + column_name + ']),' + '''' + '' + '''' + ') AS Value, [RowID] FROM ' + table_name + ' UNION ALL '
					FROM tempdb.information_schema.columns 
					WHERE table_name=@TempTableName and column_name <> 'RowID' And Data_Type In ('int','float','decimal','money')

					IF ISNULL(@SQL,'') <> ''
					BEGIN
						SELECT @sql =   'Insert into watchdoglogdetail ' +
								'Select TempDetail.* ' +
								'From (' + 
								Left(@sql,Len(@sql)-5) + 
								') as TempDetail'
						--print @SQL
						EXEC (@sql)
					END
				End




			Set NoCount Off















GO
