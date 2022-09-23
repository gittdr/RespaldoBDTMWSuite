SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[WatchDogColumnNames] 
(
	@WatchName varchar(255),
	@ColumnMode varchar (50) = 'Selected',
	@SQLForWatchDog bit = 0,
	@SELECTCOLSQL varchar(4000)='' OUTPUT,
	@DateToUse datetime = '01/01/1950'
)

As
	SET NOCOUNT ON


--Revision History 
--1. V 1.6 (Handled RowCount1 and then RowCount0 when calling the Proc to get column names

Declare @ProcName varchar(255)
Declare @ColumnID int
Declare @ColumnName varchar(255)
Declare @TempTableWatchResults varchar(255)
Declare @SQL varchar(255)
Declare @DepartmentType varchar(255)
Declare @DateToUseForGetDate datetime
Declare @Prefix varchar(255)
Declare @Server varchar(4000)

--Get the ProcName for the Watch
Select @ProcName = SqlStatement 
From               WatchDogItem
Where WatchName  = @WatchName

If Len(@Prefix)>0
Begin

	Set @ProcName = @Prefix + 'dbo.' + @ProcName


End



--Check For WorkFlow Parameters
Set @DepartmentType = (Select ParameterValue from watchdogparameter where ParameterName = '@DepartmentType' And subheading = @WatchName)

Set @DateToUseForGetDate = (Select ParameterValue from watchdogparameter where ParameterName = '@DateToUse' And subheading = @WatchName)

Set @Prefix = dbo.fnc_TMWRN_TmwSuiteLiveConnectionInfo()

Set @Server = IsNull((select gi_string1 from generalinfo where gi_name = 'TMWSUITELIVESERVER'),'')

If @ColumnMode = 'Selected' 
     Begin
		If (select count(*) from WatchDogColumn where WatchName = @WatchName) = 0
			Begin
				
				If @SQLForWatchDog = 0 --just need to pass back empty result set
				Begin
					--Quickly returns the columns for only 1 row is returned
					Set RowCount 1
					If @DepartmentType Is Not Null
					Begin
						EXEC @ProcName @ColumnNamesOnly=1,@DepartmentType=@DepartmentType
					End
					Else
					Begin
						EXEC @ProcName @ColumnNamesOnly=1
					End
					
					Set RowCount 0
				End
				Else
				Begin --we just care about returning the sql
					Set @SELECTCOLSQL = ' ,* '
				End
				
				
			End
			Else --pull columns that user has already pre-selected
			Begin
				-- 12/27/2005 DAG: Problem at Gulick with ordering of columns in ASP page and in email.
				--		http://support.microsoft.com/default.aspx?scid=kb;en-us;273586
				--		Article title: "The behavior of the IDENTITY function when used with SELECT INTO or INSERT .. SELECT queries that contain an ORDER BY clause"

				/* -- Old method: Still concern that all stored procedures use this method. */				
				/*
				select   identity(int,1,1) as ColumnID,WatchName,ColumnName
				into     #TempColumnNameRecords
				From     WatchDogColumn
				Where    WatchName = @WatchName
				Order By DisplayOrder
				*/
				 
				create table #TempColumnNameRecords  (
					ColumnID int identity,
					WatchName varchar(75), 
					ColumnName varchar(50),
				)
				 
				INSERT INTO #TempColumnNameRecords (watchname, columnname)
				select watchname, columnname
					From     WatchDogColumn
					Where    WatchName = @WatchName
					Order By DisplayOrder   
			    
				Select @ColumnID = Min(ColumnID) 
				from   #TempColumnNameRecords
						
				Set @SELECTCOLSQL = ', '
					
				While @ColumnID IS NOT NULL
				Begin
					Set @ColumnName = (select ColumnName from #TempColumnNameRecords Where ColumnID = @ColumnID)
					
					IF @SQLForWatchDog = 0 --just used in displaying html
					Begin
						Set @SELECTCOLSQL = @SELECTCOLSQL + ' ' + '1' + ' as ' + '[' + @ColumnName + ']' + ',' 
					End
					Else
					Begin --generating sql for the watch dog proc to use
						Set @SELECTCOLSQL = @SELECTCOLSQL + ' ' + '[' + @ColumnName + ']' + ',' 
					End
	
					Select
	     					@ColumnID = min(ColumnID)
	    				From
	      					#TempColumnNameRecords 
	   	 			Where
	      					ColumnID > @ColumnID			

				End
		
				Set @SELECTCOLSQL = Left(@SELECTCOLSQL,Len(@SELECTCOLSQL)-1)
	
				If @SQLForWatchDog = 0 --were using for html display
				Begin
					Set @SELECTCOLSQL = 'Select ' + Substring(@SELECTCOLSQL,2,Len(@SELECTCOLSQL))
					Exec (@SELECTCOLSQL)
				End
				

			End

	End
	Else If @ColumnMode = 'Available'
	Begin

		If (select count(*) from WatchDogColumn where WatchName = @WatchName) > 0
			Begin
								
				create table #TempAllColumns (
				TABLE_QUALIFIER sysname,
				table_owner sysname,
				table_name sysname,
				column_name sysname,
				data_type smallint,
				type_name varchar(13),
				percision int,
				length int,
				scale smallint,
				radix smallint,
				nullable smallint,
				remarks varchar (254),
				column_def varchar(254),
				sql_data_type smallint,
				sql_datetime_sub smallint,
				char_octet_length int,
				ordinal_position int,
				is_nullable varchar(254),
				ss_datatype tinyint)		
	
				Set @TempTableWatchResults = '##TempGlobalWatchResults' + cast(@@spid as varchar(25))
				
	
				Set RowCount 1
				If @DepartmentType Is Not Null
				Begin
					EXEC @ProcName @TempTableName=@TempTableWatchResults,@ColumnMode='All',@DepartmentType=@DepartmentType
				End
				Else
				Begin
					
					EXEC @ProcName @TempTableName=@TempTableWatchResults,@ColumnMode='All'
					
				End

				Set RowCount 0
			
				
				If Len(@Prefix)>0
				Begin

					Set @SQL = 'Exec ' + @Prefix + 'tempdb.dbo.' + 'sp_columns' + '''' + @TempTableWatchResults + ''''

					Insert Into #TempAllColumns
					Exec(@SQL)

				End
				Else
				Begin

					
					Insert Into #TempAllColumns
					EXEC tempdb..sp_columns @TempTableWatchResults


				End


--				Select * from #TempAllColumns
				--Return only the columns that are not being 
				--selected in the watch dog output (available)
				select column_name,SelCols.*
				from   #TempAllColumns AllCols Left Join WatchDogColumn SelCols On AllCols.column_name = SelCols.ColumnName and SelCols.WatchName = @WatchName
				where  SelCols.ColumnName Is Null 
		       		       And
		       		       column_name <> 'RowID'
		
				--Drop the Global Temp Table
				Set @SQL = 'If Not OBJECT_ID(' + '''' + 'tempdb..' + @TempTableWatchResults + '''' + ', ' + '''' + 'U' + '''' + ') IS NULL' + ' Drop Table ' + @TempTableWatchResults
				exec (@SQL)

				--Drop the Temp Table
				Drop Table #TempAllColumns
			End
			
			
	End
	Else If @ColumnMode = 'Insert'
	Begin
		If (select count(*) from WatchDogColumn where WatchName = @WatchName) = 0
		Begin
			
				create table #TempAllColumnsForInsert (
				TABLE_QUALIFIER sysname,
				table_owner sysname,
				table_name sysname,
				column_name sysname,
				data_type smallint,
				type_name varchar(13),
				percision int,
				length int,
				scale smallint,
				radix smallint,
				nullable smallint,
				remarks varchar (254),
				column_def varchar(254),
				sql_data_type smallint,
				sql_datetime_sub smallint,
				char_octet_length int,
				ordinal_position int,
				is_nullable varchar(254),
				ss_datatype tinyint)		
	
				Set @TempTableWatchResults = '##TempGlobalWatchResultsForInsert' + cast(@@spid as varchar(25))
				
	
				Set RowCount 1
				If @DepartmentType Is Not Null
				Begin
					IF @DateToUseForGetDate IS NOT NULL
						EXEC @ProcName @TempTableName=@TempTableWatchResults,@ColumnMode='All',@DepartmentType=@DepartmentType, @DateToUse=@DateToUseForGetDate
					ELSE
						EXEC @ProcName @TempTableName=@TempTableWatchResults,@ColumnMode='All',@DepartmentType=@DepartmentType
				End
				Else
				Begin
					IF @DateToUseForGetDate IS NOT NULL
						EXEC @ProcName @TempTableName=@TempTableWatchResults,@ColumnMode='All',@DateToUse=@DateToUseForGetDate
					ELSE
						EXEC @ProcName @TempTableName=@TempTableWatchResults,@ColumnMode='All'
				End

				Set RowCount 0
			

				If Len(@Prefix)>0
				Begin

					Set @SQL = 'Exec ' + @Prefix + 'tempdb.dbo.' + 'sp_columns' + '''' + @TempTableWatchResults + ''''

					Insert Into #TempAllColumns
					Exec(@SQL)

				End
				Else
				Begin

					Insert Into #TempAllColumnsForInsert
					EXEC tempdb..sp_columns @TempTableWatchResults
				End


				



				Insert into WatchDogColumn
				Select @WatchName,column_name,NULL,ordinal_position
				from   #TempAllColumnsForInsert
		       		Where  column_name <> 'RowID'
		    
				--Drop the Global Temp Table
				Set @SQL = 'If Not OBJECT_ID(' + '''' + 'tempdb..' + @TempTableWatchResults + '''' + ', ' + '''' + 'U' + '''' + ') IS NULL' + ' Drop Table ' + @TempTableWatchResults
				exec (@SQL)

				--Drop the Temp Table
				Drop Table #TempAllColumnsForInsert
		End

	End
	Else
			Begin
				Set @SELECTCOLSQL = ' ,* '
			End

GO
