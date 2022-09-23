SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




































--exec sp_helptext 'SalesbyCategory'
CREATE                              Procedure [dbo].[sp_TTSTMWObjectScanner] (@nameconvention
varchar(8000),@objecttype varchar (25),@tokenkey varchar(8000), @tokenvalue
varchar(8000),@formattype varchar(8000) = '<TTS!*!TMW>')
	
--exec sp_TTSTMWObjectScanner 'vTTSTMW_Orders','V','SQLVersion','7'
As 
    --format type is unique identifier for token keys and values
    --this is used by the scanner to truly find  where a token key
    --and value exist in a object
  
    Declare @tmwobjectid as int
    Declare @count as int
    Declare @tmwobjectname as varchar(255)
    Declare @tmwobjectsqlid as int
    Declare @tmwobjectsql1 as varchar(8000)
    Declare @tmwobjectsql2 as varchar(8000) 
    Declare @tmwobjectsql3 as varchar(8000)
    Declare @tmwobjectsql4 as varchar(8000)
    Declare @tmwobjectsql5 as varchar(8000)
    Declare @tmwobjectsql6 as varchar(8000)
    Declare @tmwobjectsql7 as varchar(8000)
    Declare @tmwobjectsql8 as varchar(8000)
    Declare @tmwobjectsql9 as varchar(8000)
    Declare @tmwobjectsql10 as varchar(8000)
    Declare @tmwobjectsql11 as varchar(8000)
    Declare @tmwsqlforrow as varchar(8000)
    Declare @tmwrowcount as int
    Declare @rowlength as int
    Declare @totalsqllength as int
    Declare @varflagcounter as int
    Declare @vartokenactiveflag as char(1)
    Declare @tokenactivatebegin as varchar(8000)
    Declare @tokenactivateend as varchar(8000)    
    Declare @tokendeactivatebegin as varchar(8000)
    Declare @tokendeactivateend as varchar(8000)
    Declare @tokenactivateflag as char(1)
    Declare @tokendeactivateflag as char(1)

    --Resolve activated token value if not already set
    Select @tokenvalue = 
			
			Case
			 When @tokenkey = 'SQLVersion' Then Case When Left(Substring(@@version,23,4),1) = '7' Then '7' Else '2000+' End 
			 When @tokenkey = 'FeaturePack' Then (Select min(language) from TMWReportActiveLanguage)
			 When @tokenkey = 'SQLOptimizedForVersion' Then Case When Left(Substring(@@version,23,4),1) = '7' Then '7' Else '2000+' End 			      
    			End    
    Where @tokenvalue = ''
 
    --Set the activated tags that we are looking for	
    --Any code in between these tags will be activated or not commented out
    Set @tokenactivatebegin = '--' + @formattype + '<Begin>' + '<' + @tokenkey + '=' + @tokenvalue + '>'
    Set @tokenactivateend = '--' + @formattype + '<End>' + '<' + @tokenkey + '=' + @tokenvalue + '>'
    Set @tokendeactivatebegin =  '--' + @formattype + '<Begin>' + '<' + @tokenkey
    Set @tokendeactivateend = '--' + @formattype + '<End>' + '<' + @tokenkey

    Create Table #MRSystemProcs (SystemProcName varchar(255))

    Insert Into #MRSystemProcs Values ('sp_TTSTMWReplaceSQLInRow')
    Insert Into #MRSystemProcs Values ('sp_TTSTMWGetLoginMethod')
    Insert Into #MRSystemProcs Values ('sp_TTSTMWGetAvailableCurrencies')
    Insert Into #MRSystemProcs Values ('sp_TTSTMWExecutePermissionOnSQLObject')
    Insert Into #MRSystemProcs Values ('sp_TTSTMWGetAvailableRolesAndLogins')
    Insert Into #MRSystemProcs Values ('sp_TTSTMWGetManagementReportingObjects')
    Insert Into #MRSystemProcs Values ('sp_TTSTMWGetMRSystemObjects')
    Insert Into #MRSystemProcs Values ('sp_TTSTMWGetPermissionsForMRSysObjects')
    Insert Into #MRSystemProcs Values ('sp_TTSTMWGetReportWizardAssociatedReports')
    Insert Into #MRSystemProcs Values ('sp_TTSTMWGetRolesAndLoginsForObject')
    Insert Into #MRSystemProcs Values ('sp_TTSTMWGrantSQLObject')
    Insert Into #MRSystemProcs Values ('sp_TTSTMWUpdateObjectPermissions')
    Insert Into #MRSystemProcs Values ('sp_TTSTMWUpdateSQLRolesFromTMWGroups')
	
    --First get the collection of objects that we will be scanning
    --and looking for token keys(SQL Version#'s,field names,etc.)
    --and once the token keys are found we will comment out the 
    --token values not being used 
    --and un comment token values
    --that are being used(this is the token key being passed in to the
--proc)
 
    --If Version 2000 was passed in as the token key
    --we would know to 
    --For example SQLVersion-> Token Key
    --			 7.0-> Token Value

    --		  SQLVersion-> Token Key
    --			2000-> Token Value			
    select identity(int,1,1) as TMWObjectID,name as SQLServerObject 
    into #TempSQLObjects
    from sysobjects 
    where xtype = @objecttype 
          and 
          name Like @nameconvention + '%'
          and
          name Not Like 'sp_TTSTMWObject%'
	  and
          name Not In (select * from #MRSystemProcs)

    Drop Table #MRSystemProcs

       
    
--from sysobjects where xtype = 'V' and name Like 'Sales%'
	
    Select @tmwobjectid = Min(TMWObjectID)
	from #TempSQLObjects	


    --Loop through each object and scan for tokens
    
    --First create temp table to store each row of the
--object(view,proc,etc.)
    --Each row of the object is determined by the carriage return
    --each time a carriage return is present sql server will return a new
row

	  While @tmwobjectid Is Not Null
	  Begin
	    Set
		@Count = @Count + 1


	   Create Table #TempTMWObjectContent
	   (
	      rowid int Not Null Identity(1,1),
	      rowcontent varchar(1000)
	   )

	  Select
	     @tmwobjectname = (select SQLServerObject from #TempSQLObjects
where TMWObjectID = @tmwobjectid)   

	   Insert into #TempTMWObjectContent(rowcontent) 
	   Exec sp_helptext @tmwobjectname

	   --Delete from #TempTMWObjectContent where rowid = (select max(rowid) from #TempTMWObjectContent)

	   --Detect # number of token types are in object
	   --if # begins = # ends then it is likely that
	   --the developer began and closed the token correctly
	   
		
	       Select @tmwobjectsqlid = Min(rowid)
			from #TempTMWObjectContent
			
			Set @tmwrowcount = 1
			Set @rowlength = 0
			Set @totalsqllength = 0 
			Set @tmwobjectsql1 = ''
			Set @tmwobjectsql2 = ''
			Set @tmwobjectsql3 = ''
			Set @tmwobjectsql4 = ''
			Set @tmwobjectsql5 = ''
			Set @tmwobjectsql6 = ''
			Set @tmwobjectsql7 = ''
		        Set @tmwobjectsql8 = ''
			Set @tmwobjectsql9 = ''
			Set @tmwobjectsql10 = ''
			Set @tmwobjectsql11 = ''
			Set @varflagcounter = 1
			Set @tokenactivateflag = 'F'
			Set @tokendeactivateflag = 'F'
			While  @tmwobjectsqlid Is Not Null
				Begin
					
					--grab the line of sql
					Select @tmwsqlforrow = rowcontent 
					from   #TempTMWObjectContent
					where  rowid = @tmwobjectsqlid 
					
					Set @rowlength = len(@tmwsqlforrow)
					Set @totalsqllength = (@totalsqllength + @rowlength)
					
					If @totalsqllength >= 8000
						Begin
							Set @varflagcounter = @varflagcounter + 1
							Set @totalsqllength = @rowlength
						End

					
					If charindex(@tokenactivateend,@tmwsqlforrow) > 0 
					Begin
					     Set @tokenactivateflag = 'F'
					End

					If charindex(@tokendeactivateend,@tmwsqlforrow) > 0 and charindex(@tokenactivateend,@tmwsqlforrow) = 0 
					Begin
					     Set @tokendeactivateflag = 'F'
					End

					If @tmwrowcount >= 1 and @varflagcounter = 1
					Begin
						
						exec sp_TTSTMWReplaceSQLInRow @tmwsqlforrow,@tokenactivateflag,@tokendeactivateflag,@tmwobjectsql1 OUTPUT		
						
						--print 'VarLen: ' + convert(varchar(255),len(@tmwobjectsql1))
					End
					Else If @tmwrowcount > 1 and @varflagcounter = 2
					Begin
						
						exec sp_TTSTMWReplaceSQLInRow @tmwsqlforrow,@tokenactivateflag,@tokendeactivateflag,@tmwobjectsql2 OUTPUT		
						
						--print 'TotalSQLLen: ' + convert(varchar(255),@totalsqllength) 
						--print 'RowLen: ' + convert(varchar(255),@rowlength)
						
						--print 'VarLen: ' + convert(varchar(255),len(@tmwobjectsql2))
					End
					Else If @tmwrowcount > 1 and @varflagcounter = 3
					Begin
						exec sp_TTSTMWReplaceSQLInRow @tmwsqlforrow,@tokenactivateflag,@tokendeactivateflag,@tmwobjectsql3 OUTPUT		
					End 
					Else If @tmwrowcount > 1 and @varflagcounter = 4
					Begin
					        exec sp_TTSTMWReplaceSQLInRow @tmwsqlforrow,@tokenactivateflag,@tokendeactivateflag,@tmwobjectsql4 OUTPUT		
					End
					Else If @tmwrowcount > 1 and @varflagcounter = 5
					Begin
					        exec sp_TTSTMWReplaceSQLInRow @tmwsqlforrow,@tokenactivateflag,@tokendeactivateflag,@tmwobjectsql5 OUTPUT		
					End				
					Else If @tmwrowcount > 1 and @varflagcounter = 6
					Begin
					        exec sp_TTSTMWReplaceSQLInRow @tmwsqlforrow,@tokenactivateflag,@tokendeactivateflag,@tmwobjectsql6 OUTPUT		
					End	
					Else If @tmwrowcount > 1 and @varflagcounter = 7
					Begin
					        exec sp_TTSTMWReplaceSQLInRow @tmwsqlforrow,@tokenactivateflag,@tokendeactivateflag,@tmwobjectsql7 OUTPUT		
					End	
					Else If @tmwrowcount > 1 and @varflagcounter = 8
					Begin
					        exec sp_TTSTMWReplaceSQLInRow @tmwsqlforrow,@tokenactivateflag,@tokendeactivateflag,@tmwobjectsql8 OUTPUT		
					End
					Else If @tmwrowcount > 1 and @varflagcounter = 9
					Begin
					        exec sp_TTSTMWReplaceSQLInRow @tmwsqlforrow,@tokenactivateflag,@tokendeactivateflag,@tmwobjectsql9 OUTPUT		
					End
					Else If @tmwrowcount > 1 and @varflagcounter = 10
					Begin
					        exec sp_TTSTMWReplaceSQLInRow @tmwsqlforrow,@tokenactivateflag,@tokendeactivateflag,@tmwobjectsql10 OUTPUT		
					End
					Else If @tmwrowcount > 1 and @varflagcounter = 11
					Begin
					        exec sp_TTSTMWReplaceSQLInRow @tmwsqlforrow,@tokenactivateflag,@tokendeactivateflag,@tmwobjectsql11 OUTPUT		
					End
					
				Select
	     				@tmwobjectsqlid = min(rowid)
	    			From
	      				#TempTMWObjectContent
	    			Where
	      				rowid > @tmwobjectsqlid

					Set @tmwrowcount = @tmwrowcount + 1

 				--print @tokenactivatebegin
				--print @tmwsqlforrow
				If charindex(@tokenactivatebegin,@tmwsqlforrow) > 0 --Like '%--<TTS!*!TMW><Begin><SQLVersion=2000+>%'
					Begin
					     	
						Set @tokenactivateflag = 'T'
					End
				
				If charindex(@tokendeactivatebegin,@tmwsqlforrow) > 0  and charindex(@tokenactivatebegin,@tmwsqlforrow) = 0 
					Begin
					       
						Set @tokendeactivateflag = 'T' 
					End
			End

			--Re Execute object sql with the new changes
			--Print (@tmwobjectsql1 + @tmwobjectsql2)
			--print @tmwobjectsql1 + '********END1'
			--print @tmwobjectsql2
			--print @tmwobjectsql3
			--print @tmwobjectsql4			
			--print @tmwobjectsql6
			--SET QUOTED_IDENTIFIER ON
			Exec (@tmwobjectsql1 + @tmwobjectsql2 + @tmwobjectsql3 + @tmwobjectsql4 + @tmwobjectsql5 + @tmwobjectsql6 + @tmwobjectsql7 + @tmwobjectsql8 + @tmwobjectsql9 + @tmwobjectsql10 + @tmwobjectsql11)
			 


	   drop Table #TempTMWObjectContent
	    

	    Select
	     @tmwobjectid = min(TMWObjectID)
	    From
	      #TempSQLObjects 
	    Where
	      TMWObjectID > @tmwobjectid

	  
	  End
	


	
	







































GO
