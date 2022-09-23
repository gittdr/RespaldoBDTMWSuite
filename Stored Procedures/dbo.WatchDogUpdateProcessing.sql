SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[WatchDogUpdateProcessing]
(
	@WatchNamePassed varchar(255) = Null
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS


Set NoCount On
Declare @ThresholdValue varchar(255)
Declare @WatchName varchar(150)
Declare @sn int
Declare @paramsn int
Declare @ProcTimeStart datetime
Declare @ProcTimeEnd datetime
Declare @NextParameterValue varchar(255)
Declare @NextParameter varchar(255)
Declare @ParmDefinition nvarchar(500)
Declare @ProcName varchar(255)
Declare @ScheduleInterval int
Declare @TimeType varchar(255)
Declare @ScheduleWatchDog bit
Declare @LastRunDate datetime
Declare @CurrDate datetime
declare @SQL as varchar(4000)

Set @CurrDate = GetDate()
Set @SQL = ''
IF @WatchNamePassed IS NULL
	BEGIN
		Select @sn = Min(sn)
		from   WatchDogItem
		Where  UpdateFlag = 1
	END
	ELSE
	BEGIN
		
		Select @sn = Min(sn)
		from   WatchDogItem
		Where  WatchName = @WatchNamePassed 

	END


While @sn Is Not Null
Begin

	      Select 	@procname = SqlStatement, 
					@WatchName = WatchName,
					@ScheduleWatchDog = ScheduleWatchDog,
					@LastRunDate = LastRunDate,
					@ScheduleInterval = TimeValue,
					@TimeType = TimeType
			From WatchDogItem 
			where sn = @sn

	--convert to minutes if needed 
	Select @ScheduleInterval = 
		Case @TimeType
			When 'Days' Then (@ScheduleInterval * 1440)	
 			When 'Hours' Then (@ScheduleInterval * 60)
			Else @ScheduleInterval 
		End
	Where @ScheduleInterval Is Not Null

	If (@ScheduleWatchDog = 1 And (DateDiff(mi,@LastRunDate,@CurrDate) >= @ScheduleInterval Or @LastRunDate Is Null)) 
	      Or
	   (IsNull(@ScheduleWatchDog,0) = 0) 
		  Or
	   (@WatchNamePassed IS Not NULL)
	Begin
 			--generate Proc SQL attaching any parameters if selected
			SET @SQL = 'EXEC '+ @procname + ' '	
			SET @SQL = @SQL + '@WatchName' + '=''' + @WatchName + ''','

			--Loop Through Parameters and attach any selected parameters
			--and their values if they exist in WatchDogParameter table
			Select  @paramsn = Min(sn)
			from   WatchDogParameter,syscolumns,sysobjects
			WHERE  WatchDogParameter.Heading = 'WatchDogStoredProc'
		       		AND 
		       		WatchDogParameter.SubHeading = @WatchName
		       		AND
		      		 sysobjects.name = @ProcName
		       		AND
		       		sysobjects.id = syscolumns.id
		       		AND
		       		sysobjects.xtype = 'P'
		       		AND
		       		WatchDogParameter.Parametername = syscolumns.name
			
			While @paramsn Is Not Null
				Begin
					

					SELECT @NextParameterValue = ParameterValue, 
					       @NextParameter = ParameterName
					from   WatchDogParameter
					WHERE  WatchDogParameter.Heading = 'WatchDogStoredProc'
		       				AND 
		       				WatchDogParameter.SubHeading = @WatchName
						And
		       				sn = @paramsn
			     	  --AND 
			       --ISNULL(ParmSort,0) = @NextParmSort

					Select @NextParameterValue = 
							
						--If the user is using the scheduler mins back
						--functionality then convert the time
						--to mins if not already
	     
							Case When Left(@NextParameterValue,1) = '-' then
				        		@NextParameterValue
     						Else
		  						'-' + @NextParameterValue
       						End

					Where  @NextParameter = '@MinsBack'     
						
					Select @ThresholdValue = @NextParameterValue
					Where  @NextParameter = '@MinThreshold'

					IF @NextParameterValue IS NOT NULL					
						SET @SQL = @SQL + @NextParameter + '=''' + @NextParameterValue + '''' + ','	 --+ @CRLF

						Select @paramsn = min(sn)
	        					from   WatchDogParameter,syscolumns,sysobjects
						WHERE  WatchDogParameter.Heading = 'WatchDogStoredProc'
		       				AND 
		       				WatchDogParameter.SubHeading = @WatchName
		       				AND
			       			sysobjects.name = @ProcName
			      			AND
		       				sysobjects.id = syscolumns.id
		       				AND
		       				sysobjects.xtype = 'P'
		       				AND
		       				WatchDogParameter.Parametername = syscolumns.name
				 	        And
						sn > @paramsn	 

			End
			
			SET @SQL = LEFT(@SQL, LEN(@SQL)-1)

			BEGIN
				print 'EXECUTING WATCHDOG NAME SQL: ' + @SQL
			END

			
			Set @ProcTimeStart = GetDate()

			EXEC (@SQL)

			Set @ProcTimeEnd = GetDate()
			Update WatchDogItem
			Set LastRunDate = @ProcTimeEnd 
			Where WatchName = @WatchName
          END -- schedule

			IF @WatchNamePassed IS NOT NULL
			Begin
				SELECT @sn = NULL
			End
			ELSE
			Begin
				Select
	     	  	  		@sn = min(sn)
	        		From
	      	 			WatchDogItem
	        		Where
	      	    			sn > @sn
		   	 		And
				    	UpdateFlag = 1
			End

End
GO
GRANT EXECUTE ON  [dbo].[WatchDogUpdateProcessing] TO [public]
GO
