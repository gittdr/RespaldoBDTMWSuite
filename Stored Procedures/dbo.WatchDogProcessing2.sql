SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[WatchDogProcessing2]
(
	@WatchNamePassed varchar(255) = Null,
	@ShowDetail int =0,
	@DateToUse varchar(20) = '01/01/1950',
	@FileNameOverride varchar(255)='',
	@SubjectOverride varchar(255)='',
	@EmailOverride varchar(255)='',
	@RestrictionHeader varchar(4000)='' OUTPUT
)
AS


Set NoCount On

/*
Revision History
Version 1.5 
1. Added code to handle the usage of the Scheduled Job
   Vs Schedule less often (this only affected previous versions before 1.2)
   Since versions prior to V 1.2 didn't have the ScheduledJob bit field
   those fields never were populated with 1 or 0 value. They remained
   NULL so basically those watch dogs would never run until the
   watch dog was saved through the application. Version 1.5 on
   will allow NULL ScheduledJob to run.
Version 1.6
2. Display Parameters on watch dog email were not getting reset
   Added code that would reset the RestrictionHeader Variable so not all watch dogs
   would use parameter info that was on another watch dog.
   THIS IS ONLY FOR DISPLAY PURPOSES ONLY. The functionality of the
   watch dog was not affected.

PTS 34718 BYoung 10/4/06
	Adding Drop Table for #wfLaunch

*/





declare @DateToUseAsGetDate datetime

If @DateToUse = '01/01/1950'
	SET @DateToUseAsGetDate = GETDATE()
Else
	IF isdate(@DateToUse) = 1
		Set @DateToUseAsGetDate = cast(@DateToUse as datetime)
	Else
		IF isnumeric(@DateToUse) =1
			SET @DateToUseAsGetDate = DateAdd(day,-cast(@DateToUse as int),GETDATE())
		ELSE
			SET @DateToUseAsGetDate = GETDATE()
	
	   
Declare @sn int
Declare @SQL nvarchar(4000)
Declare @emailaddress varchar(8000)
Declare @operator varchar(25)
Declare @begindate datetime
Declare @enddate datetime
Declare @STRbegindate char(17)
Declare @STRenddate char(17)
Declare @wherepos int
Declare @Result as decimal(30,2)
Declare @BeginDateMinusDays int
Declare @EndDatePlusDays int
Declare @DateField varchar(255)
Declare @ThresholdValue varchar(255)
Declare @WatchName varchar(150)
Declare @ParentWatchName varchar(150)
Declare @ThresholdDirection varchar(255)
Declare @hasoris varchar(3)
Declare @samplemessage varchar(255)
Declare @QueryType varchar(255)
Declare @sprocname varchar(255)
Declare @TempTableWatchResults varchar(255)
Declare @ResultCount int
Declare @MinsBack varchar(255)
Declare @HTMLTemplateFlag bit
Declare @paramsn int
Declare @NextParameterValue varchar(255)
Declare @NextParameter varchar(255)
Declare @ParmDefinition nvarchar(500)
Declare @ProcName varchar(255)
Declare @LastRunDate datetime
Declare @ScheduleInterval int
Declare @CurrDate datetime
Declare @TimeType varchar(255)
Declare @RunMinsBackFromScheduleTime bit
Declare @ScheduleWatchDog bit
Declare @DisplayParameterOnEmail bit
Declare @ProcRunDuration decimal(9, 3)
Declare @RunDurationLast decimal(9,3)
--Declare @RunDurationMin decimal(9,3)
--Declare @RunDurationMax decimal(9,3)
Declare @ProcTimeStart datetime
Declare @ProcTimeEnd datetime
DECLARE @object int
DECLARE @hr int
DECLARE @src varchar(255),@desc varchar(255)
Declare @object2 int
Declare @EmailID int
Declare @EmailSendAddress varchar(4000)
Declare @EmailSendTempTable varchar(255)

Set @CurrDate = GetDate()

Set @SQL = ''
Set @RestrictionHeader = ''

Set @TempTableWatchResults = '##TempGlobalWatchResults' + cast(@@spid as varchar(25))

Set @SQL = 'If Not OBJECT_ID(' + '''' + 'tempdb..' + @TempTableWatchResults + '''' + ', ' + '''' + 'U' + '''' + ') IS NULL' + ' Drop Table ' + @TempTableWatchResults

Exec (@SQL)

--go through and execute each watch and see if 
--exceeds,equals, or lower then the threshold

IF @WatchNamePassed IS NULL
	BEGIN
		Select @sn = Min(sn)
		from   WatchDogItem
		Where  ActiveFlag = 1
		 
		
	END
	ELSE
	BEGIN
		
		Select @sn = Min(sn)
		from   WatchDogItem
		Where  --ActiveFlag = 1
		       --And
		       WatchName = @WatchNamePassed 

	END


While @sn Is Not Null
	Begin
	      
	      --Unless Otherwise noted
	      --Set the @EndDate to today and minute before midnight
	      Set @EndDate =  cast(floor(cast(getdate() as float)) as datetime) + '23:59:59'								--		+8: Disable refresh history.

	      --Unless otherwise noted
	      --Set the @BeginDate to today starting at midnight
	      Set @BeginDate = cast(floor(cast(getdate() as float)) as datetime)


	      Select 		@SQL = SqlStatement, 
				@BeginDate = IsNull(BeginDate, @BeginDate),
				@EndDate = IsNull(EndDate, @EndDate),
				@BeginDateMinusDays = IsNull(BeginDateMinusDays, 0),
				@EndDatePlusDays = IsNull(EndDatePlusDays, 0),
				@DateField = DateField,
				@Operator = IsNull(Operator,'='),
				@WatchName = WatchName,
				@ParentWatchName = IsNull(ParentWatchName,''),
				@EmailAddress = EmailAddress,
				@QueryType = QueryType,
				@sprocname = procname,
				@HTMLTemplateFlag = HTMLTemplateFlag,
				@ScheduleWatchDog = ScheduleWatchDog,
				@RunMinsBackFromScheduleTime = RunMinsBackFromScheduleTime,
				@LastRunDate = LastRunDate,
				@ScheduleInterval = TimeValue,
				@TimeType = TimeType

/*
Adding fields:
				@TotalMailDynamicSend_YN varchar(1),
				@TotalMailDynamicSend_AddressTypeForRecipient varchar(1),	-- L=TotalMail Logon, T=Dispatch System Truck, D=Dispatch System Driver, G=TotalMail Dispatch Group
				@TotalMailDynamicSend_FieldToUse varchar(1),  -- Field in the Dawg alert result set to use for address.
				@TotalMailDynamicSend_ReferenceLookup varchar(255) -- Either "Value" or a stored procedure / web service method call that has ONE parameter from value in field @TotalMailDynamicSend_FieldToUse.
*/
			From WatchDogItem 
			where sn = @sn


	      --Re calculate the days with the minus days
              --for the begin date

	      Set @BeginDate = (@BeginDate - @BeginDateMinusDays)
	    
	      --Re calculate the days with the minus days
              --for the end date

	      Set @EndDate = (@EndDate + @EndDatePlusDays)

	      Set @wherepos = charindex('where',@SQL)

	      Set @STRbegindate = cast(DatePart(yyyy,@BeginDate) as char(4)) + 
				  Case When len(cast(DatePart(mm,@BeginDate) as varchar(2))) < 2 Then '0' + cast(DatePart(mm,@BeginDate) as char(1)) Else cast(DatePart(mm,@BeginDate) as char(2)) End +
				  Case When len(cast(DatePart(dd,@BeginDate) as varchar(2))) < 2 Then '0' + cast(DatePart(dd,@BeginDate) as char(1)) Else cast(DatePart(dd,@BeginDate) as char(2)) End + ' ' + 
				  Case When len(cast(DatePart(hh,@BeginDate) as varchar(2))) < 2 Then '0' + cast(DatePart(hh,@BeginDate) as char(1)) Else cast(DatePart(hh,@BeginDate) as char(2)) End + ':' + 
				  Case When len(cast(DatePart(mi,@BeginDate) as varchar(2))) < 2 Then '0' + cast(DatePart(mi,@BeginDate) as char(1)) Else cast(DatePart(mi,@BeginDate) as char(2)) End + ':' +
				  Case When len(cast(DatePart(ss,@BeginDate) as varchar(2))) < 2 Then '0' + cast(DatePart(ss,@BeginDate) as char(1)) Else cast(DatePart(ss,@BeginDate) as char(2)) End 

	      Set @STRenddate = cast(DatePart(yyyy,@EndDate) as char(4)) + 
				  Case When len(cast(DatePart(mm,@EndDate) as varchar(2))) < 2 Then '0' + cast(DatePart(mm,@EndDate) as char(1)) Else cast(DatePart(mm,@EndDate) as char(2)) End +

				  Case When len(cast(DatePart(dd,@EndDate) as varchar(2))) < 2 Then '0' + cast(DatePart(dd,@EndDate) as char(1)) Else cast(DatePart(dd,@EndDate) as char(2)) End + ' ' + 
				  Case When len(cast(DatePart(hh,@EndDate) as varchar(2))) < 2 Then '0' + cast(DatePart(hh,@EndDate) as char(1)) Else cast(DatePart(hh,@EndDate) as char(2)) End + ':' + 
				  Case When len(cast(DatePart(mi,@EndDate) as varchar(2))) < 2 Then '0' + cast(DatePart(mi,@EndDate) as char(1)) Else cast(DatePart(mi,@EndDate) as char(2)) End + ':' +
				  Case When len(cast(DatePart(ss,@EndDate) as varchar(2))) < 2 Then '0' + cast(DatePart(ss,@EndDate) as char(1)) Else cast(DatePart(ss,@EndDate) as char(2)) End 	     

	        
		Set @ProcName = @SQL


		--convert to minutes if needed 
		Select @ScheduleInterval = 
			Case @TimeType
				When 'Days' Then (@ScheduleInterval * 1440)	
	 			When 'Hours' Then (@ScheduleInterval * 60)
  				Else @ScheduleInterval 
			End
		Where @ScheduleInterval Is Not Null
           
		-- RUN WATCH DOG BASED ON THE FOLLOWING CONDITIONS
		-- The first part (PART I) of the IF is dependent
		-- on if the Watch Dog has the Scheduler enabled and only wants to
		-- run a specific Watch Dog less often then SQL Server Job
		-- The second part (PART II) (@ScheduleWatchDog = 0) indicates that the 
		-- Watch Dog can run either by running it manually or 
		-- whenever the SQL job is supposed to run
		
		--Part I condition
		--If Scheduling Less Often switch is enabled (@ScheduleWatchDog = 1) 
		--then 1 of the following happens to determine when the watchdog runs
			--A. If watchdog has never ran (LastRunDate = Null) then
			--   the watchdog automatically runs
			--B. If watchdog has ran before (LastRunDate IS NOT NULL) then   

		--Part II condition
		--If the Scheduling Less Often switch is disabled 
		--(@ScheduleWatchDog = 0)-> Watch Dog will run automatically
		--from one of the two actions 
			--A. Executed from SQL Server Job
			--B. Executed manually by using SQL Statement (Exec WatchDogProcessing 'code') 				


		Set @LastRunDate = Case When DateDiff(day,@LastRunDate,getdate()) > 31 Then DateAdd(day,-31,getdate()) Else @LastRunDate End 

		If (@ScheduleWatchDog = 1 And (DateDiff(mi,@LastRunDate,@CurrDate) >= @ScheduleInterval Or @LastRunDate Is Null)) 
		      OR
		   (@ScheduleWatchDog = 1 AND @ShowDetail=1)
		      Or
		   (@ScheduleWatchDog = 0) --Run no matter what because 
					   --the watchdog is either supposed to  
					   --run in pace with the SQL Job
					   --OR the user could be running it manually
		     Or			   --Fixed in Ver 1.5 to allow NULL
		   (@ScheduleWatchDog IS Null) --NULL means the same thing as zero	
			 or 
		   (@ScheduleWatchDog = 1 AND @ShowDetail=2)			  
           
		Begin
      			
 			--generate Proc SQL attaching any parameters if selected
			SET @SQL = 'EXEC '+ @SQL + ' '	
			SET @SQL = @SQL + '@WatchName' + '=''' + @WatchName + ''','
			Set @SQL = @SQL + '@TempTableName' + '=''' + @TempTableWatchResults + ''','	

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
			

			SELECT @RestrictionHeader = ''
	
			While @paramsn Is Not Null

			
				Begin
					
					SELECT @NextParameterValue = ParameterValue, 
					       @NextParameter = ParameterName,
					       @DisplayParameterOnEmail = IsNull(DisplayOnEmail,0)
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
		   				Case When @RunMinsBackFromScheduleTime = 1 Then

					 
							'-' + cast(@ScheduleInterval as varchar(50))
							
						Else
	     
							
							Case When Left(@NextParameterValue,1) = '-' then
					        		Case When DateDiff(mi,@LastRunDate,getdate()) > (cast(@NextParameterValue as int) * -1) Then
											Cast(DateDiff(mi,@LastRunDate,getdate()) * -1 as varchar(255))
									Else
											@NextParameterValue
									End
	      						Else
									Case When DateDiff(mi,@LastRunDate,getdate()) > cast(@NextParameterValue as int) Then
											'-' + Cast(DateDiff(mi,@LastRunDate,getdate()) as varchar(255))
									Else
											'-' + @NextParameterValue
									End
		  						End

						End
					
					Where  @NextParameter = '@MinsBack'     
						
					Select @ThresholdValue = @NextParameterValue
					Where  @NextParameter = '@MinThreshold'

					
/*					
					Select @RestrictionHeader = @RestrictionHeader + dbo.fnc_WatchDogGetLabelHeader(Substring(@NextParameter,2,len(@NextParameter))) + ': ' + IsNull(@NextParameterValue,'') + '<br>'
					Where @NextParameter Not In ('@MinsBack','@MinThreshold','@ThresholdFieldName','@TempTableName','@WatchName','@ColumnNamesOnly','@ExecuteDirectly','@ColumnMode','@DateToUse')
					      And
					      @NextParameterValue Is Not Null And LTrim(RTrim(@NextParameterValue)) <> ''					 
					      And
					      @DisplayParameterOnEmail = 1
*/
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

			--Execute the SQL or Proc that we are watching
			--Exec @SQL @ThresholdValue,@MinsBack,@TempTableWatchResults,@WatchName
			--select @SQL
			IF Exists (Select * from watchdogparameter where ParameterName = '@DateToUse' and SubHeading = @watchname)	
			BEGIN	
				select @SQL = @SQL + ',@DateToUse='''+cast(@DateToUse as varchar(20))+''''
				print 'EXECUTING WATCHDOG NAME SQL: ' + @SQL
			END
			ELSE
			BEGIN
				print 'EXECUTING WATCHDOG NAME SQL: ' + @SQL
			END

			
			Set @ProcTimeStart = GetDate()
			
			--SQL2000OBS EXEC sp_executesql @SQL, @ParmDefinition 
			EXEC (@SQL)
			Set @ProcTimeEnd = GetDate()
			--SQL2000OBS Set @SQL = 'Select @ResultCount = count(*) from ' + @TempTableWatchResults
			
			Create Table #ResultCount (ResultCount int)
			
			Insert into #ResultCount (ResultCount)
			Exec('Select ResultCount = count(*) from ' + @TempTableWatchResults)
					
			Set @ResultCount = IsNull((select ResultCount from #ResultCount),0)

			/*
			Added Ver 1.6 (If in the future we add more columns to watch dogs,
			if users don't submit their columns they will be surprised to see
			more columns and will be confused. This will enforce a save if they
			have never explicity saved their columns before.
			*/
	
			--Exec WatchDogColumnNames @WatchName,'Insert',@DateToUse=@DateToUse

			----SQL2000OBS Exec sp_executesql @SQL,N'@ResultCount int output',@ResultCount output
			--Exec(@SQL)

			--Select * from #TempResults	
		
			--If results come back then
	       		--assume the threshold has been violated     
			If @ResultCount > 0
			Begin
	        	
				--Get the Proc Duration
				SELECT @ProcRunDuration = ROUND(ROUND(DATEDIFF(ms, @ProcTimeStart, @ProcTimeEnd) / 1000.0, 4), 5, 1)
				

				Exec WatchDogLog @WatchName,@ProcTimeEnd,@ProcRunDuration,1,'',@ThresholdValue,@TempTableWatchResults,@ResultCount,@ParentWatchName
				--select @ShowDetail 
				--If @ShowDetail = 1
			    	--Begin	
					/*Set @SQL = 'Select * from ' + @TempTableWatchResults
					--select @SQL
					Exec (@SQL)*/
				--End
				--Else
				--Begin
					
					--tempdb..
					--if exists (select * from dbo.sysobjects where id = object_id(N'[#TempColumnsInsert]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					--drop table [#TempColumnsInsert]
					--If Not OBJECT_ID('tempdb..#TempColumnsInsert', 'U') IS NULL Drop Table tempdb.dbo.#TempColumnsInsert					
					Set @SQL = 'If Not OBJECT_ID(' + '''' + 'tempdb..' + '#TempColumnsInsert' + '''' + ', ' + '''' + 'U' + '''' + ') IS NULL' + ' Drop Table ' + '#TempColumnsInsert'
					Exec (@SQL)

					Set @SQL = 'If Not OBJECT_ID(' + '''' + 'tempdb..' + '#EmailSend' + '''' + ', ' + '''' + 'U' + '''' + ') IS NULL' + ' Drop Table ' + '#EmailSend'
					Exec (@SQL)

					--Added 2.1
					--Check to see if they need dynamic email
					CREATE TABLE [#TempColumnsInsert] (
										  --[TABLE_QUALIFIER] [sysname] NOT NULL ,
										  --[TABLE_OWNER] [sysname] NOT NULL ,
										  --[TABLE_NAME] [sysname] NOT NULL ,
										  [COLUMN_NAME] [sysname] NOT NULL ,
										  [DATA_TYPE] [smallint] NULL ,
										  --[TYPE_NAME] [varchar] (13) NULL ,
										  [PRECISION] [int] NULL ,
										  [LENGTH] [int] NULL ,
										  [SCALE] [smallint] NULL ,
										  --[RADIX] [smallint] NULL ,
				                          --[NULLABLE] [smallint] NULL ,
										  --[REMARKS] [varchar] (254) NULL ,
										  --[COLUMN_DEF] [varchar] (254) NULL ,
										  --[SQL_DATA_TYPE] [smallint] NULL ,
										  --[SQL_DATETIME_SUB] [smallint] NULL ,
							              --[CHAR_OCTET_LENGTH] [int] NULL ,
										  [ORDINAL_POSITION] [int] NULL ,
										  [IS_NULLABLE] [varchar] (254) NULL ,
										  --[SS_DATE_TYPE] [tinyint] NULL 
										) ON [PRIMARY]

					/*
					select syscolumns.name
						   prec,
						   
						   
						   
						   type,
                           length,
                           scale,
                           colorder,  
                           isnullable

				    from syscolumns (NOLOCK)
					*/
 
					--Exec ('select * from ' + @TempTableWatchResults)
					
					/*
					Insert Into #TempColumnsInsert
					EXEC tempdb..sp_columns @TempTableWatchResults 
					*/					

					Insert Into #TempColumnsInsert
					Select col.name,
						   col.type,
						   col.prec,
                           col.length,
                           col.scale,
                           col.colorder,  
                           col.isnullable 
					
					from   tempdb..syscolumns col,
						   tempdb..sysobjects obj

				    Where  col.id =  obj.id
						   And
						   obj.name = @TempTableWatchResults 

 				 	Create TABLE #wfLaunch 
 					([idWorkflowTemplate] int
 					)   

					-- Kick off workflows, if applicable
					Declare @EmailWorkflows char(1)
					Declare @idWorkflowTemplate int
					Set @EmailWorkflows = 'Y'
					Set @idWorkflowTemplate = 0
					if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[wf_LaunchDawgWorkflows]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
						Begin
							Set @EmailWorkflows = IsNull((select parametervalue from watchdogparameter where heading = 'system' and subheading = 'EmailSend' and parametername = 'EmailWorkflowYN'),'Y')
							insert Into #wfLaunch 
							exec wf_LaunchDawgWorkflows @sn, @TempTableWatchResults
							set @idWorkflowTemplate = IsNull((select top 1 idWorkflowTemplate from #wfLaunch), 0)
							if @idWorkflowTemplate > 0
							BEGIN
								INSERT INTO dbo.WatchDogLogInfo (dateandtime, WatchName, MoreInfo) 		
								SELECT GETDATE(), @WatchName, 'WatchdogProcessing2: Workflow template launched using wf_LaunchDawgWorkflows.' 
								Print 'Workflow Template Launched: ' + convert(varchar (30),@idWorkflowTemplate)
							END
						End

					-- PTS 34718 
					DROP TABLE #wfLaunch

					--Bring this code into .Net
					
					If (select count(*) from #TempColumnsInsert where column_name = 'EmailSend') > 0 
					Begin			
 	 					Create Table #EmailSend (EmailSend varchar(4000),EmailID int IDENTITY (1, 1))
						Set @SQL = 'Insert into #EmailSend Select distinct REPLACE(EmailSend, CHAR(39), CHAR(39) + CHAR(39)) From ' + @TempTableWatchResults 
						Exec (@SQL)

						Select @EmailID= min(EmailID) from #EmailSend Where ISNULL(EmailSend, '') <> ''
						Set @SQL = 'If Not OBJECT_ID(' + '''' + 'tempdb..' +  @EmailSendTempTable + '''' + ', ' + '''' + 'U' + '''' + ') IS NULL' + ' Drop Table ' +  @EmailSendTempTable
						Exec (@SQL)

						While ISNULL(@EmailID, '') <> ''
						Begin
			
							
							Set @EmailSendAddress = IsNull((Select EmailSend from #EmailSend where EmailID = @EmailID),'')

							Set @EmailSendTempTable = '##EmailSend' + cast(@@spid as varchar(25))
			
						        Set @SQL = 'If Not OBJECT_ID(' + '''' + 'tempdb..' +  @EmailSendTempTable + '''' + ', ' + '''' + 'U' + '''' + ') IS NULL' + ' Drop Table ' +  @EmailSendTempTable

							Exec (@SQL)

							Set @SQL = 'Select * from ' + @TempTableWatchResults + ' Where EmailSend = ' + '''' + @EmailSendAddress + ''''

							Exec (@SQL)				

							Select @EmailID = min(EmailID) 
							from   #EmailSend 
							Where  EmailID > @EmailID 
								AND ISNULL(EmailSend, '') <> ''

						End
				
					End

/*
-- create table xyx (sn int identity, dt datetime DEFAULT(GETDATE()), WatchName varchar(255))
					IF (SELECT COUNT(*) FROM #TempColumnsInsert where column_name = 'TotalMailSend') > 0 
					BEGIN
INSERT INTO xyx (WatchName) SELECT @WatchNamePassed
					END
*/					
-- select * from watchdogitem
					if exists (select * from dbo.sysobjects where id = object_id(N'[#TempColumnsInsert]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					drop table [#TempColumnsInsert]
					--select @emailaddress BRING THIS CODE INTO .NET
					/* 
					If @EmailWorkflows = 'Y' or @idWorkflowTemplate = 0
						Exec WatchDogSend @TempTableWatchResults,@EmailAddress,@WatchName,@HTMLTemplateFlag,@RestrictionHeader,@ProcName,@FileNameOverride,@SubjectOverride,@EmailOverride
					*/

				     Set @SQL = 'Select * from ' + @TempTableWatchResults
					 --select @SQL
					 Exec (@SQL)

					 --select * from #TempColumnsInsert
				--End
		      End
		      Else
		      Begin
				Print @WatchName + ' ' + 'did not exceed or go below the threshold'
		      End
		
			    --Update Last Run Date to Now Regardless

			    --if the watch has went beyond the threshold
			IF @ShowDetail<>1 and @ShowDetail<>2
			    Update WatchDogItem
			    Set    LastRunDate = @CurrDate
			    Where  WatchName  = @WatchName  

			
		
			--Exec ('Drop Table ' + @TempTableWatchResults)
			Set @SQL = 'If Not OBJECT_ID(' + '''' + 'tempdb..' +  @TempTableWatchResults + '''' + ', ' + '''' + 'U' + '''' + ') IS NULL' + ' Drop Table ' +  @TempTableWatchResults

			--print @SQL
			exec (@SQL)
	End
	Else
	Begin
		print 'WatchDog ' + @WatchName + ' currently not scheduled to run.'
	End

			IF @WatchNamePassed IS NOT NULL
			Begin
				SELECT @sn = NULL
			End
			ELSE
			Begin
				Select @sn = min(sn) From WatchDogItem Where sn > @sn And ActiveFlag = 1
			End
End



Set NoCount Off


/* 
EXEC Watchdogprocessing2 'DawgSetupAlert', 2, @CalledFromDawgProcessing_YN = 'Y'
*/
Return
GO
GRANT EXECUTE ON  [dbo].[WatchDogProcessing2] TO [public]
GO
